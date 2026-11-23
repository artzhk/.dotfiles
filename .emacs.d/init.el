;; -*- lexical-binding: t; -*-
;;; Tmp / backup files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)
(save-place-mode 1)
(savehist-mode 1)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)
;; bell is really killing me.... beep.. beep...
(setq visible-bell t)

(set-face-attribute 'default nil :font "IosevkaTerm Nerd Font Mono 16")

;;; Defaults (ported from nano/nano-defaults.el) ------------------------------
(setq-default major-mode 'text-mode)

;; Frame / dialogs
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(tooltip-mode 0)

(setq indicate-empty-lines nil
      cursor-in-non-selected-windows nil
      font-lock-maximum-decoration nil
      font-lock-maximum-size nil
      confirm-nonexistent-file-or-buffer nil
      org-return-follows-link t)

;; y/n for answering yes/no questions
(setq use-short-answers t)
;; Tabs where not specified
(setq-default indent-tabs-mode t
	      tab-width 8)

(defconst my/config-dir
  (file-name-directory
   (file-truename (or load-file-name buffer-file-name))))

;; file exports
(load (expand-file-name "mail.el" my/config-dir) nil t)
(load (expand-file-name "lsp.el" my/config-dir) nil t)
(load (expand-file-name "latex.el" my/config-dir) nil t)
(load (expand-file-name "org.el" my/config-dir) t t)
(load (expand-file-name "matrix.el" my/config-dir) t t)

(with-eval-after-load 'info
  (add-to-list 'Info-directory-list (expand-file-name "info/" my/config-dir)))

(defvar my/theme-light 'ivory-light)
(defvar my/theme-dark 'gruber-darker)

(defun my/toggle-theme ()
  "Switch between `my/theme-dark' and `my/theme-light'."
  (interactive)
  (let ((next (if (custom-theme-enabled-p my/theme-dark)
		  my/theme-light
		my/theme-dark)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme next t)))

;; colorschemes
(use-package gruber-darker-theme :ensure t :defer t)
(use-package ivory-themes
  :vc (:url "https://github.com/khzaw/ivory-themes.git"
	    :rev :newest)
  :custom
  (ivory-themes-bold-constructs t)
  (ivory-themes-italic-constructs t)
  :config
  (load-theme 'ivory-light t))

(load-theme my/theme-light t)
(global-set-key (kbd "C-c t") #'my/toggle-theme)

;; ...and registers
(add-to-list 'savehist-additional-variables 'register-alist)

;; User status line items (ported from ~/.dotfiles/.emacs.d/init.el)
(require 'project)

;; Modes
(display-time-mode 1)
(display-battery-mode 1)
(which-function-mode 1)

;;; UI
(blink-cursor-mode 0)
(add-to-list 'default-frame-alist '(undecorated . nil))
(setq-default frame-resize-pixelwise t)
(menu-bar-mode -1)
(set-fringe-style '(10 . 0))
(setq show-trailing-whitespace t)

(setq-default fill-column 80)
(setq-default display-line-numbers t)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)
(setq ido-use-filename-at-point 'guess
      ido-use-url-at-point t)            ; also open URLs at point
(setq ido-ignore-buffers '("\\*.*"))

(global-eldoc-mode 0)
;; use ffap's guessing for the path at point
(setq xref-search-program 'ripgrep)   ; Emacs ≥ 27, needs `rg` in PATH
(setq completion-styles '(basic substring))
(setq completion-ignore-case t)
(setq icomplete-in-buffer t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

;; wrap everywhere by default
(setq-default truncate-lines nil)
;; no wrap in code buffers
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))
(global-display-fill-column-indicator-mode 1)
(goto-address-mode 1)
(global-subword-mode 1)
(delete-selection-mode 1)
(setq-default next-screen-context-lines 9)
(setq-default scroll-preserve-screen-position t)
;; compilation
(setq compilation-skip-threshold 2)
(setq-default compilation-scroll-output t)

;; previews reuse one window, split at most once, never stack
(defun my/jump-from-list-p (_buffer-name _action)
  "Non-nil when `display-buffer' is called from a results list."
  (derived-mode-p 'compilation-mode        ; also grep-mode
                  'xref--xref-buffer-mode))

(setq display-buffer-alist
      '(("\\*Completions\\*"     (display-buffer-at-bottom))
        ("\\*eldoc.*\\*"         (display-buffer-at-bottom))
        ("COMMIT_EDITMSG"        (display-buffer-at-bottom))
        ("magit-diff:.*"         (display-buffer-at-bottom))
        ("\\*Help\\*"            (display-buffer-pop-up-window))
        ("\\*git-gutter:.*\\*"   (display-buffer-pop-up-window))
        ;; RET in compile/grep/xref: open target in the list's window
        (my/jump-from-list-p
         (display-buffer-same-window)
         (inhibit-same-window . nil))
        (".*"
         (display-buffer-reuse-window display-buffer-same-window))))

(global-set-key (kbd "C-c m SPC") #'global-whitespace-mode)
(setq whitespace-display-mappings '((space-mark 32 [183] [46])
				    (space-mark 160 [164] [95])
				    (tab-mark 9 [187 9] [92 9])))
(setq whitespace-style '(face tabs spaces space-mark tab-mark missing-newline-at-eof))

(setq pop-up-windows t
      pop-up-frames nil)

;; this seemcs to be default
(setq xref-show-definitions-function #'xref-show-definitions-buffer
      xref-show-xreffunction       #'xref--show-xref-buffer)

;; Emacs 27+: make switch-to-buffer follow the same rules
(setq switch-to-buffer-obey-display-actions t)

(defun my/cp-file-path()
  (interactive)
  (kill-new (buffer-file-name)))

(defun my/cp-file-path-loc()
  (interactive)
  (kill-new (format "%s:%d" buffer-file-name (line-number-at-pos nil t))))

;; Thanks rexim
(defun rc/duplicate-line ()
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

;; to setup the project root where I need it...
(setq project-vc-extra-root-markers '(".project"))

;; kill-ring file you know...
(global-set-key (kbd "C-c k f") 'my/cp-file-path)
(global-set-key (kbd "C-c k l") 'my/cp-file-path-loc)
(global-set-key (kbd "C-c e") 'revert-buffer)
(global-set-key (kbd "C-,") 'rc/duplicate-line)
(global-set-key (kbd "C-x k") 'kill-current-buffer)

;; emacs windows
(global-set-key (kbd "C-c w w") 'delete-other-windows)
(global-set-key (kbd "C-c w n") 'windmove-down)
(global-set-key (kbd "C-c w p") 'windmove-up)
(global-set-key (kbd "C-c w f") 'windmove-right)
(global-set-key (kbd "C-c w b") 'windmove-left)

;; Buffer
(keymap-global-set "C-x C-b" #'ibuffer)
(global-set-key (kbd "C-c y") #'compile)
(global-set-key (kbd "C-c b") 'previous-buffer)
(global-set-key (kbd "C-c ! l") #'flymake-show-buffer-diagnostics)
(global-set-key (kbd "C-c ! L") #'flymake-show-project-diagnostics)
(global-set-key (kbd "C-c f") #'eglot-format-buffer)
(global-set-key (kbd "C-c a") #'eglot-code-actions)
(global-set-key (kbd "C-c i") #'eglot-find-implementation)
(global-set-key (kbd "C-c d") #'eglot-find-typeDefinition)
(global-set-key (kbd "C-c C-r") #'eglot-rename)
(global-set-key (kbd "C-c H") #'eglot-inlay-hints-mode)
(global-set-key (kbd "C-h .") #'eldoc)

(add-hook 'eglot-managed-mode-hook
          (lambda () (eglot-inlay-hints-mode -1)))

(require 'flymake)
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))

(require 'term)
(with-eval-after-load 'term
  (define-key term-raw-map (kbd "C-y") 'term-paste))

;;; Shell PATH (needed for Magit, compile, and external tools) ----------------
(package-initialize)
(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter)
  :ensure t)

(use-package exec-path-from-shell
  :config (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK")
  :ensure t)

(use-package fzf
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
	fzf/executable "fzf"
	fzf/git-grep-args "-i --line-number %s"
	;; command used for `fzf-grep-*` functions
	;; example usage for ripgrep:
	fzf/grep-command "rg --no-heading -nH"
	;; If nil, the fzf buffer will appear at the top of the window
	fzf/position-bottom t
	fzf/window-height 15)
  :ensure t)

(global-set-key (kbd "C-c C-.") #'fzf-git)
(global-set-key (kbd "C-c u") #'fzf)

(use-package tree-sitter :ensure t)
;; Would be code to use it in dotfiles, but I have windows :clown:
(use-package tree-sitter-langs
  :config '((interactive)
            (setq tree-sitter-load-path
                  (list
		   (expand-file-name
		    "bin"
		    (file-name-directory (locate-library "tree-sitter-langs")))
		   (expand-file-name "tree-sitter" user-emacs-directory))))
  :ensure t)

;;; Magit
(use-package magit
  ;; TODO: figure out it one day
  :bind (:map magit-file-section-map
	      ("C-<return>" . magit-diff-visit-prefer-index)
	      :map magit-hunk-section-map
	      ("C-<return>" . magit-diff-visit-prefer-index))
  :config
  (setq magit-diff-visit-prefer-worktree t)
  :ensure t)

(use-package git-gutter
  :ensure t
  :custom
  (git-gutter:window-width 1)
  (git-gutter:modified-sign "=")
  (git-gutter:added-sign "+")
  (git-gutter:deleted-sign "-")
  :bind (("C-c C-h h" . git-gutter:popup-diff)
         ("C-c C-h n" . git-gutter:next-hunk)
         ("C-c C-h p" . git-gutter:previous-hunk)))
(global-git-gutter-mode t)

;; Elpaca (recommended)
(use-package compilation-history
  :ensure t
  :vc (:url "https://github.com/djgoku/compilation-history" :rev :newest)
  :after compile
  ;; Bind C-c c as the prefix for compilation-history commands
  ;; C-c c c → compile, C-c c v → view history
  :bind-keymap
  ("C-c c o" . compilation-history-mode)
  ("C-c c" . compilation-history-map)
  :config
  (compilation-history-mode 0)
  ;; May be should be at bind-keymap, but I didn't get the lisp syntax there...
  ;; (global-set-key (kbd "C-c c o") #'compilation-history-mode)
  (setq compilation-history-save-line-threshold 100)
  ;; Default: 'switch (select the window showing the new buffer)
  ;; Options: 'switch, 'pop (respect display-buffer-alist), nil (disabled)
  (setq compilation-history-recompile-switch-behavior 'nil)
  ;; Default: 'horizontal (above/below)
  ;; Options: 'horizontal, 'vertical (side-by-side)
  (setq compilation-history-view-split-direction 'vertical ido-buffer-ignore '("*" "magit-" "~")))

(defun my/compilation-history-prune (days)
  "Delete everything after n days"
  ;; check number of arguments
  (interactive (list (if current-prefix-arg (prefix-numeric-value current-prefix-arg) 1)))
  (let ((db (sqlite-open compilation-history-db-file)))
    (unwind-protect
	(progn
	  (sqlite-execute db
			  "DELETE FROM compilations WHERE start_time < datetime('now', ?)"
			  (list (format "-%d days" days)))
	  (sqlite-execute db "VACUUM"))
      (sqlite-close db)))
  (message "compilation-history: pruned entries older than %d day(s)" days))

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C->") #'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") #'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-?") #'mc/mark-all-like-this))

