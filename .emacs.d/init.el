;; -*- lexical-binding: t; -*-
;;; Tmp / backup files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

(defconst my/config-dir
  (file-name-directory
   (file-truename (or load-file-name buffer-file-name))))

;;; Defaults (ported from nano/nano-defaults.el) ------------------------------
;; Startup
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil
      initial-buffer-choice nil
      initial-major-mode 'text-mode)
(setq-default major-mode 'text-mode)

;; Frame / dialogs
(setq frame-title-format nil
      use-file-dialog nil
      use-dialog-box nil)
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

;; Mouse active in terminal
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

;; y/n for answering yes/no questions
(setq use-short-answers t)

;; No tabs, tab.space equivalence
(setq-default indent-tabs-mode nil
              tab-width 8)

;; Temporary buffers & windows
(temp-buffer-resize-mode)
(setq temp-buffer-max-height 20
      window-min-height 1)

;; Buffer encoding
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment   'utf-8)

;; ;; Unique buffer names
;; (require 'uniquify)
;; (setq uniquify-buffer-name-style 'reverse
;;       uniquify-separator " // "
;;       uniquify-after-kill-buffer-p t
;;       uniquify-ignore-buffers-re "^\\*")

;; ;; Default shell in term
;; (when (and (not (eq system-type 'windows-nt))
;;            (file-exists-p "/bin/bash"))
;;   (setq-default shell-file-name "/bin/bash")
;;   (setq explicit-shell-file-name "/bin/bash"))

;; ;; Kill term buffer when exiting
;; (defun my/term-sentinel-kill-buffer (orig proc msg)
;;   (if (memq (process-status proc) '(signal exit))
;;       (let ((buffer (process-buffer proc)))
;;         (funcall orig proc msg)
;;         (kill-buffer buffer))
;;     (funcall orig proc msg)))
;; (advice-add 'term-sentinel :around #'my/term-sentinel-kill-buffer)

;;; Nano — comment these two lines to get the regular UI ----------------------
;; (load (expand-file-name "nano/nano.el" my/config-dir))
;; (load (expand-file-name "nano/nano-custom.el" my/config-dir))

;;; Regular UI (only when nano is not loaded) ---------------------------------
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

(unless (featurep 'nano)
  (use-package gruber-darker-theme :ensure t :defer t)
  (add-to-list 'custom-theme-load-path my/config-dir)
  (set-face-attribute 'default nil :family "MononokiNerdFont Mono" :height 200)
  (load-theme my/theme-light t)
  (global-set-key (kbd "C-c t") #'my/toggle-theme))

;;; Session persistence
;; reopen a file at the last point you were 
(save-place-mode 1)
;; persist minibuffer history...
(savehist-mode 1)
;; ...and registers
(add-to-list 'savehist-additional-variables 'register-alist)

;; User status line items (ported from ~/.dotfiles/.emacs.d/init.el)
(require 'project)

;; Modes
(display-time-mode 1)
(display-battery-mode 1)
(which-function-mode 1)

;;; Editing
(setq-default delete-selection-mode t)

;;; UI
(blink-cursor-mode 0)
(add-to-list 'default-frame-alist '(undecorated . nil))
(setq-default frame-resize-pixelwise t)
(menu-bar-mode -1)

(setq-default fill-column 80)
(setq-default display-line-numbers t)

(ido-mode 1)
(fido-vertical-mode 1)
(setq xref-search-program 'ripgrep)   ; Emacs ≥ 27, needs `rg` in PATH
(setq completion-styles '(basic substring))
(setq completion-ignore-case t)
(setq icomplete-in-buffer t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

(setq-default truncate-lines nil)   ; wrap everywhere by default
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))  ; no wrap in code buffers

(global-display-fill-column-indicator-mode 1)
(ffap-bindings)
(goto-address-mode 1)
(global-subword-mode 1)

(setq-default next-screen-context-lines 9)
(setq-default scroll-preserve-screen-position t)
(setq-default delete-selection-mode t)

(setq-default compilation-scroll-output t)

(defun my/cp-file-path()
  (interactive)
  (kill-new (buffer-file-name)))

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
(global-set-key (kbd "C-c o") #'compile)         
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
(setq eglot-inlay-hints-mode 0)
(global-set-key (kbd "C-c H") #'eglot-inlay-hints-mode)

(require 'flymake)
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))


(load (expand-file-name "lsp.el" my/config-dir))
(load (expand-file-name "frontend.el" my/config-dir))
(load (expand-file-name "dotnet.el" my/config-dir))
(load (expand-file-name "pbd.el" my/config-dir))

;;; Shell PATH (needed for Magit, compile, and external tools) ----------------
;; (ensure-package 'ansi-color :ensure)
;; (ensure-package 'ansi-color)
(package-initialize)
(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter)
  :ensure t)
;; (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
;; nano maps `success' to salient (purple); give compilation Emacs' stock green
(with-eval-after-load 'compile
  (face-spec-set 'compilation-info (get 'success 'face-defface-spec))
  (set-face-attribute 'compilation-info nil :inherit 'unspecified))


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
  :config '((global-set-key (kbd "C-c o l") #'org-store-link)
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

            )
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
  :ensure t)
(use-package git-gutter
  :config '((global-git-gutter-mode t)
            (global-set-key (kbd "C-c C-h h") #'git-gutter:popup-diff)
            (global-set-key (kbd "C-c C-h n") #'git-gutter:next-hunk)
            (global-set-key (kbd "C-c C-h p") #'git-gutter:previous-hunk))
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
  :bind-keymap ("C-c c" . compilation-history-map)
  :config
  ;; Enable automatic tracking of all compilations
  (compilation-history-mode 1)
  (iswitchb-mode 1)
  (add-to-list 'iswitchb-buffer-ignore "*compilation-history"))
