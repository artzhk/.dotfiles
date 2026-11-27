;; -*- lexical-binding: t; -*-
;; ;;; Tmp / backup files
(save-place-mode 1)
(savehist-mode 1)
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(tooltip-mode 0)

;; Modes
(display-time-mode 1)
(display-battery-mode 1)
(which-function-mode 1)
(menu-bar-mode -1)
(global-eldoc-mode 0)
(blink-cursor-mode 0)
(global-display-fill-column-indicator-mode 1)
(goto-address-mode 1)
(global-subword-mode 1)
(delete-selection-mode 1)

;; Must be prebuilt
(require 'project)
(require 'term)
(require 'flymake)
(require 'eglot)
(require 'info)

(add-to-list 'default-frame-alist
             '(font . "IosevkaTerm Nerd Font Mono 16"))
;; defaults if not defined
(setq-default major-mode 'text-mode
	      indent-tabs-mode t
	      tab-width 8
	      frame-resize-pixelwise t
	      fill-column 72
	      display-line-numbers t
	      compilation-scroll-output t
	      truncate-lines nil
	      next-screen-context-lines 9
	      scroll-preserve-screen-position t)

;; defaults override
(setq indicate-empty-lines nil
      show-trailing-whitespace t
      whitespace-display-mappings '((space-mark 32 [183] [46])
				    (space-mark 160 [164] [95])
				    (tab-mark 9 [187 9] [92 9]))
      whitespace-style
      '(face tabs spaces space-mark tab-mark missing-newline-at-eof)

      pop-up-windows t
      pop-up-frames nil

      project-vc-extra-root-markers '(".project")

      ;; this seemcs to be default
      xref-show-definitions-function #'xref-show-definitions-buffer
      xref-show-xreffunction       #'xref--show-xref-buffer

      ;; Emacs 27+: make switch-to-buffer follow the same rules
      switch-to-buffer-obey-display-actions t

      ;; Emacs ≥ 27, needs `rg` in PAT
      xref-search-program 'ripgrep
      compilation-skip-threshold 2

      display-buffer-alist
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
         (display-buffer-reuse-window display-buffer-same-window)))
      completion-styles '(basic substring)
      completion-ignore-case t
      icomplete-in-buffer t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t

      ;; style miscs...
      cursor-in-non-selected-windows nil
      font-lock-maximum-decoration nil
      font-lock-maximum-size nil
      confirm-nonexistent-file-or-buffer nil
      org-return-follows-link t

      ;; spawning weird files..
      make-backup-files nil
      create-lockfiles nil
      auto-save-default nil
      custom-file (expand-file-name "custom.el" user-emacs-directory)
      ;; y/n for answering yes/no questions
      use-short-answers t)

(load custom-file t)

(defconst my/config-dir
  (file-name-directory
   (file-truename (or load-file-name buffer-file-name))))

;; file exports
(load (expand-file-name "mail.el" my/config-dir) nil t)
(load (expand-file-name "lsp.el" my/config-dir) nil t)
(load (expand-file-name "pbd.el" my/config-dir) nil t)
(load (expand-file-name "dotnet.el" my/config-dir) nil t)
(load (expand-file-name "frontend.el" my/config-dir) nil t)
(load (expand-file-name "org.el" my/config-dir) t t)
(load (expand-file-name "matrix.el" my/config-dir) t t)

;; Info manufals
(with-eval-after-load 'info
  (add-to-list 'Info-directory-list (expand-file-name "info/" my/config-dir)))

;;; UI
(add-to-list 'default-frame-alist '(undecorated . nil))
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))
(add-to-list 'savehist-additional-variables 'register-alist)

;; previews reuse one window, split at most once, never stack
(defun my/jump-from-list-p (_buffer-name _action)
  "Non-nil when `display-buffer' is called from a results list."
    (with-current-buffer (window-buffer (selected-window))
    (derived-mode-p 'compilation-mode 'xref--xref-buffer-mode)))

(defun my/cp-file-path()
  (interactive)
  (kill-new (buffer-file-name)))

(defun my/cp-file-path-loc()
  (interactive)
  (kill-new
   (format "%s:%d" buffer-file-name (line-number-at-pos nil t))))

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

;; kill-ring filepath you know...
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
(global-set-key (kbd "C-c f") #'eglot-format-buffer)
(global-set-key (kbd "C-c a") #'eglot-code-actions)
(global-set-key (kbd "C-c i") #'eglot-find-implementation)
(global-set-key (kbd "C-c d") #'eglot-find-typeDefinition)
(global-set-key (kbd "C-c C-r") #'eglot-rename)
(global-set-key (kbd "C-c H") #'eglot-inlay-hints-mode)
(global-set-key (kbd "C-h .") #'eldoc)

(add-hook 'eglot-managed-mode-hook
          (lambda ()
	    (eglot-inlay-hints-mode -1)
	    (eldoc-mode -1)))


(define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
(define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error)
(define-key term-raw-map (kbd "C-y") 'term-paste)

;; External
(package-initialize)
;; (defvar dark-themes '())
;; (defvar light-themes '())
(use-package gruber-darker-theme :ensure t
  :custom
  :defer t)
(use-package au-themes :ensure t
  :init
    ;; random theme
  (defun my/get-random-theme (POLARITY)
    (interactive)
    (let*
	((themes (au-themes-get-themes POLARITY))
	 (len (length themes))
	 (i (% (abs(random)) len)))
      (nth i themes)))
  
  (defun my/toggle-theme ()
    "Switch between `my/theme-dark' and `my/theme-light'."
    (interactive)
    (let
	((theme (nth 0 custom-enabled-themes))
	 (polarity (au-themes--theme-polarity
		    (nth 0 custom-enabled-themes))))
      (load-theme (my/get-random-theme
		   (if (eq polarity 'dark) 'light 'dark)))
      (disable-theme theme)))

  (defun my/shuffle-theme ()
    "Shuffle current theme polarity, once you get tired from the current shade."
    (interactive)
    (let
	((theme (nth 0 custom-enabled-themes))
	 (polarity (au-themes--theme-polarity
		    (nth 0 custom-enabled-themes))))
      (load-theme (my/get-random-theme polarity))
      (disable-theme theme)))
  :config
  (if (eq 0 (length custom-enabled-themes))
      (load-theme (my/get-random-theme 'light)))
  
  (global-set-key (kbd "C-c T") #'my/toggle-theme)
  (global-set-key (kbd "C-c t") #'my/shuffle-theme)
  (global-set-key (kbd "C-c m SPC") #'global-whitespace-mode))

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
(use-package tree-sitter-langs
  :ensure t
  :config '((interactive)
            (setq tree-sitter-load-path
                  (list
		   (expand-file-name
		    "bin"
		    (file-name-directory (locate-library "tree-sitter-langs")))
		   (expand-file-name "tree-sitter" user-emacs-directory)))))

;;; Magit
(use-package magit
  :ensure t
  :bind (:map magit-file-section-map
	      ("C-<return>" . magit-diff-visit-prefer-index)
	      :map magit-hunk-section-map
	      ("C-<return>" . magit-diff-visit-prefer-index))
  :config
  (setq magit-diff-highlight-indentation nil
	magit-diff-visit-prefer-worktree t
	magit-diff-paint-whitespace nil
	magit-revision-insert-related-refs nil
	flymake-no-changes-timeout 0.6))

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
  ("C-c v" . compilation-history-map)
  :config
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
  ;; if provided in bind-keymap returns:
  ;; use-package-autoload-keymap: use-package: package.el
  ;; compilation-history failed to define keymap
  ;; compilation-history-mode
  (global-set-key (kbd "C-c c o") #'compilation-history-mode)
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

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C->") #'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") #'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-?") #'mc/mark-all-like-this))

;; Example configuration for Consult
(use-package consult
  :bind (("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ("M-y" . consult-yank-pop)
         ("M-s e" . consult-isearch-history))
  :config
  (setq consult-buffer-filter
	'("\\*.*" "\\` "))
  (setq consult-preview-key "C-o")
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep
   consult-recent-file consult-xref
   consult-source-recent-file consult-source-project-recent-file)
  (setq consult-narrow-key "<"))

(use-package marginalia :ensure t :config
  (marginalia-mode))
(use-package vertico :ensure t :config
  (vertico-mode))
