;; -*- lexical-binding: t; -*-
;;; Tmp / backup files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)
(save-place-mode 1)
(savehist-mode 1)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

(set-frame-font "IosevkaTerm Nerd Font Mono 20" nil t)

;;; Defaults (ported from nano/nano-defaults.el) ------------------------------
(setq-default major-mode 'text-mode)

;; Frame / dialogs
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(tooltip-mode 0)

;; Allow splitting the current frame for popup buffers (e.g. xref);
;; with nil, Emacs falls back to creating a new frame instead
(setq pop-up-windows t
      pop-up-frames nil)

(setq indicate-empty-lines nil
      cursor-in-non-selected-windows nil
      font-lock-maximum-decoration nil
      font-lock-maximum-size nil
      confirm-nonexistent-file-or-buffer nil
      org-return-follows-link t)

;; y/n for answering yes/no questions
(setq use-short-answers t)

;; No tabs, tab.space equivalence
(setq-default indent-tabs-mode nil
              tab-width 8)

(defconst my/config-dir
  (file-name-directory
   (file-truename (or load-file-name buffer-file-name))))

;;; Regular UI (only when nano is not loaded) ---------------------------------
(load (expand-file-name "palettes.el" my/config-dir) nil t)
(defvar my/theme-light 'the-moment)
(defvar my/theme-dark 'gruber-darker)

(defun my/toggle-theme ()
  "Switch between `my/theme-dark' and `my/theme-light'."
  (interactive)
  (let ((next (if (custom-theme-enabled-p my/theme-dark)
                  my/theme-light
                my/theme-dark)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme next t)))

(use-package gruber-darker-theme :ensure t :defer t)
(add-to-list 'custom-theme-load-path my/config-dir)
(set-face-attribute 'default nil :family "IosevkaTerm Nerd Font Mono" :height 200)
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

(setq-default fill-column 80)
(setq-default display-line-numbers t)

(ffap-bindings)
(ido-mode 1)
(fido-vertical-mode 1)
(setq ido-use-filename-at-point 'guess   ; use ffap's guessing for the path at point
      ido-use-url-at-point t)            ; also open URLs at point
(setq xref-search-program 'ripgrep)   ; Emacs ≥ 27, needs `rg` in PATH
(setq completion-styles '(basic substring))
(setq completion-ignore-case t)
(setq icomplete-in-buffer t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

(setq-default truncate-lines nil)   ; wrap everywhere by default
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))  ; no wrap in code buffers

(global-display-fill-column-indicator-mode 1)

(goto-address-mode 1)
(global-subword-mode 1)

(setq-default next-screen-context-lines 9)
(setq-default scroll-preserve-screen-position t)
(setq-default delete-selection-mode t)
(setq delete-selection-mode t)

(setq-default compilation-scroll-output t)

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
(global-set-key (kbd "C-c p") #'project-compile)  
(global-set-key (kbd "C-c b") 'previous-buffer)
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c ! l") #'flymake-show-buffer-diagnostics)
(global-set-key (kbd "C-c ! L") #'flymake-show-project-diagnostics)
(global-set-key (kbd "C-c f") #'eglot-format-buffer)
(global-set-key (kbd "C-c a") #'eglot-code-actions)
(global-set-key (kbd "C-c i") #'eglot-find-implementation)
(global-set-key (kbd "C-c d") #'eglot-find-typeDefinition)
(global-set-key (kbd "C-c C-r") #'eglot-rename)
(global-set-key (kbd "C-c H") #'eglot-inlay-hints-mode)

(add-hook 'eglot-managed-mode-hook
          (lambda () (eglot-inlay-hints-mode -1)))

(require 'flymake)
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))

(load (expand-file-name "lsp.el" my/config-dir))
(load (expand-file-name "latex.el" my/config-dir))

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

(keymap-global-set "C-c C-f" #'fzf-git)   ; or fzf-async-
(keymap-global-set "C-c u" #'fzf)

;;; Org — core settings --------------------------------------------------------

(use-package org
  :config (global-set-key (kbd "C-c o l") #'org-store-link)
  (global-set-key (kbd "C-c o a") #'org-agenda)
  (global-set-key (kbd "C-c o c") #'org-capture)
  (setq org-startup-indented           t
        org-startup-with-inline-images t
        org-startup-with-latex-preview nil
        org-image-actual-width         '(800))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN_PROGRESS(i!)" "|" "DONE(d!)")
          (sequence "IDEA(e)" "|" "DROPPED(x@)")))

  (setq org-todo-keyword-faces
        '(("TODO"        . org-warning)
          ("NEXT"        . (:foreground "cyan"   :weight bold))
          ("IN_PROGRESS" . (:foreground "orange" :weight bold))
          ("IDEA"        . (:foreground "grey"   :slant italic))
          ("DROPPED"     . (:foreground "grey"   :strike-through t))))

  ;; Agenda file list lives in agenda-files (one path or directory per line),
  ;; like project.el's projects file. C-c [ / C-c ] add/remove the current file.
  (setq org-agenda-files (expand-file-name "agenda-files" user-emacs-directory))
  (setq org-agenda-custom-commands
        '(("n" "Next actions" todo "NEXT"
           ((org-agenda-prefix-format    "  %-12:c")
            (org-agenda-sorting-strategy '(priority-down category-up))))
          ("p" "All projects" tags-todo "+project-work"
           ((org-agenda-prefix-format    "  %-12:c ")
            (org-agenda-sorting-strategy '(category-up priority-down))))
          ("w" "Work" tags-todo "+work"
           ((org-agenda-prefix-format "  %-12:c ")))
          ("i" "Ideas backlog" todo "IDEA"
           ((org-agenda-prefix-format "  %-12:c")))))
  :hook (org-babel-after-execute-hook . org-display-inline-images)
  :ensure t)


;;; Org — TODO keywords & faces
;; (load (expand-file-name "latex.el" my/config-dir))

(use-package tree-sitter :ensure t)
;; Would be code to use it in dotfiles, but I have windows :clown:
(use-package tree-sitter-langs
  :config '((interactive)
            (setq tree-sitter-load-path
                  (list (expand-file-name "bin" (file-name-directory (locate-library "tree-sitter-langs")))
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
  :config
  (global-git-gutter-mode t)
  (global-set-key (kbd "C-c C-h h") #'git-gutter:popup-diff)
  (global-set-key (kbd "C-c C-h n") #'git-gutter:next-hunk)
  (global-set-key (kbd "C-c C-h p") #'git-gutter:previous-hunk)
  (defun my/git-gutter-apply-colors (&rest _)
    "Color git-gutter faces from the active theme's palette."
    (pcase-dolist (`(,kind . ,color) '((modified . niagara)
                                       (added    . green)
                                       (deleted  . red)))
      (when-let ((c (my/color color)))
        (dolist (prefix '("git-gutter:" "git-gutter-fr:"))
          (let ((face (intern (format "%s%s" prefix kind))))
            (when (facep face)
              (set-face-attribute face nil :foreground c :background c)))))))
  (my/git-gutter-apply-colors)
  (add-hook 'enable-theme-functions #'my/git-gutter-apply-colors)
  :ensure t)

(use-package git-gutter-fringe
  :ensure t)

;; Elpaca (recommended)
(use-package compilation-history
  :ensure t
  :vc (:url "https://github.com/djgoku/compilation-history" :rev :newest)
  :after compile
  ;; Bind C-c c as the prefix for compilation-history commands
  ;; C-c c c → compile, C-c c v → view history
  :bind-keymap
  ("C-c c" . compilation-history-map)

  :config
  (compilation-history-mode 1)
  ;; that stuff is deprecated(unless you dont update), but I need the way to filter my buffers...
  (iswitchb-mode 1)

  (setq compilation-history-view-split-direction 'verical
        iswitchb-buffer-ignore '("*"))
  ;; May be should be at bind-keymap, but I didn't get the lisp syntax there...
  (global-set-key (kbd "C-c c o") #'(lambda () (setq truncate-lines t)))
  (setq compilation-history-save-line-threshold 100)
  ;; Default: 'switch (select the window showing the new buffer)
  ;; Options: 'switch, 'pop (respect display-buffer-alist), nil (disabled)
  (setq compilation-history-recompile-switch-behavior 'nil)
  ;; Default: 'horizontal (above/below)
  ;; Options: 'horizontal, 'vertical (side-by-side)
  (setq compilation-history-view-split-direction 'vertical))

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C->") #'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") #'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C -?") #'mc/mark-all-like-this))

;; ~/.emacs.d/init.el
(setq gnus-select-method
      '(nnimap "purelymail"
               (nnimap-address "imap.purelymail.cpom")
               (nnimap-server-port 993)
               (nnimap-stream ssl)))

(setq send-mail-function    'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-server  "smtp.purelymail.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type  'ssl
      user-mail-address     "artemdev@worldofmail.com")
