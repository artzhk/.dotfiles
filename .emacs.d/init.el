;;; Tmp / backup files ---------------------------------------------------------
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)

;;; Session persistence ---------------------------------------------------------
(save-place-mode 1)              ; reopen a file at the last point you were on
(savehist-mode 1)                ; persist minibuffer history...
(add-to-list 'savehist-additional-variables 'register-alist) ; ...and registers
(desktop-save-mode 1)            ; save/restore open buffers & window layout

;;; UI -------------------------------------------------------------------------
(blink-cursor-mode 0)
;; (load-theme 'the-moment t)
(add-to-list 'default-frame-alist '(undecorated . nil))
(add-to-list 'custom-theme-load-path "~/.dotfiles/.emacs.d/")
(load-theme 'the-moment)
(setq frame-title-format '("%p - %b — Emacs"))
(setq-default frame-resize-pixelwise t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tab-bar-mode -1)
(global-display-line-numbers-mode t)
(global-visual-line-mode -1)
(set-frame-font "IosevkaTerm Nerd Font Mono 20" nil t )
(setq-default fill-column 80)
(setq-default truncate-lines nil)   ; wrap everywhere by default
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))  ; no wrap in code buffers
(add-hook 'term-mode-hook (lambda () (setq truncate-lines t)))

(global-display-fill-column-indicator-mode 1)
(ffap-bindings)
(goto-address-mode 1)

;; TODO: where that must go?

(defun my/cp-file-path()
  (interactive)
  (kill-new (buffer-file-name)))

(global-set-key (kbd "C-c k f") 'my/cp-file-path)

;; emacs windows ---------------------------------------------------------------

(global-set-key (kbd "C-c w n") 'windmove-down)
(global-set-key (kbd "C-c w p") 'windmove-up)
(global-set-key (kbd "C-c w f") 'windmove-right)
(global-set-key (kbd "C-c w b") 'windmove-left)

;;; Packages -------------------------------------------------------------------
(defun ensure-package (package)
  (unless (package-installed-p package)
    (unless package-archive-contents
      (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
      (package-initialize)
      (package-refresh-contents))
    (package-install package))
  (require package))

;;; Shell PATH (needed for Magit, compile, and external tools) ----------------
;; (ensure-package 'ansi-color :ensure)
(ensure-package 'ansi-color)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(ensure-package 'exec-path-from-shell)
(exec-path-from-shell-initialize)              ; copies PATH → exec-path
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")
;; Vanilla completion, everywhere (M-x, buffer switching, etc.): built-in
;; `flex' style = closest/subsequence match, case-insensitive. No package.
(setq completion-styles '(basic partial-completion flex))
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

;; (ensure-package 'orderless)
;; (use-package orderless
;;   :init
;;   ;; flex = subsequence match (fzf-style), not just literal substring —
;;   ;; needed for e.g. "todocontroller" to match "ToDosController.cs"
;;   (setq orderless-matching-styles '(orderless-flex orderless-literal orderless-regexp))
;;   (setq completion-category-overrides
;;         '((file (styles orderless))
;;           ;; project-find-file tags its completion table 'project-file, not
;;           ;; 'file, so it needs its own entry to actually use orderless.
;;           (project-file (styles orderless)))))

;;; Org — core settings --------------------------------------------------------

(ensure-package 'org)

(global-set-key (kbd "C-c o l") #'org-store-link)
(global-set-key (kbd "C-c o a") #'org-agenda)
(global-set-key (kbd "C-c o c") #'org-capture)

(setq org-startup-indented           t
      org-startup-with-inline-images t
      org-startup-with-latex-preview nil
      org-image-actual-width         '(800))

(add-hook 'org-babel-after-execute-hook #'org-display-inline-images)


;;; Org — TODO keywords & faces ------------------------------------------------

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "IN_PROGRESS(i!)" "|" "DONE(d!)")
        (sequence "IDEA(e)" "|" "DROPPED(x@)")))

(setq org-todo-keyword-faces
      '(("TODO"        . org-warning)
        ("NEXT"        . (:foreground "cyan"   :weight bold))
        ("IN_PROGRESS" . (:foreground "orange" :weight bold))
        ("IDEA"        . (:foreground "grey"   :slant italic))
        ("DROPPED"     . (:foreground "grey"   :strike-through t))))

;; Auto-discover all .org files — no hardcoded paths, works on any machine.
;; Custom will not override this because org-agenda-files is absent from
;; custom-set-variables below.
(setq org-agenda-files (directory-files-recursively "~/org-space/" "\\.org$"))
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

;;; Compile -------------------------------------------------------------------

;; No default global keys exist for these; everything else (g=recompile,
;; M-n/M-p=next/prev error, M-.=jump-to-error) works out of the box.
(global-set-key (kbd "C-c c") #'compile)         ; prompt & run
(global-set-key (kbd "C-c p") #'project-compile) ; from project root

;;; LSP — eglot & flymake keybindings -----------------------------------------

(ensure-package 'tree-sitter)
(ensure-package 'tree-sitter-langs)
(global-set-key (kbd "C-c b") 'previous-buffer)
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c ! l") #'flymake-show-buffer-diagnostics)
(global-set-key (kbd "C-c ! L") #'flymake-show-project-diagnostics)
(global-set-key (kbd "C-c f") #'eglot-format-buffer)
(global-set-key (kbd "C-c a") #'eglot-code-actions)
(global-set-key (kbd "C-c i") #'eglot-find-implementation)
(global-set-key (kbd "C-c C-r") #'eglot-rename)
(global-set-key (kbd "C-c h") #'eglot-inlay-hints-mode)
(setq eglot-inlay-hints-mode 0)
(global-set-key (kbd "C-c h") #'eglot-inlay-hints-mode)

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))

;;; LSP — eglot ----------------------------------------------------------------
(load (expand-file-name "lsp.el" user-emacs-directory))

;;; Optional external stuff ----------------------------------------------------
(load (expand-file-name "latex.el" user-emacs-directory))
;; (load (expand-file-name "dotnet.el" user-emacs-directory))
;; (load (expand-file-name "frontend.el" user-emacs-directory))

;;; Magit ----------------------------------------------------------------------

(ensure-package 'magit)
(ensure-package 'git-gutter)
(ensure-package 'git-gutter-fringe)
(git-gutter-mode 1)

;;; Copilot --------------------------------------------------------------------

(ensure-package 'copilot)
(global-set-key (kbd "C-c e") #'copilot-accept-completion)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("f7bda565084cc99184e37470c52c5856e832c6d2c340b3f93e48827c13596954" default))
 '(package-selected-packages
   '(copilot dape eglot-inactive-regions evil exec-path-from-shell magit orderless
	     ox-mdx-deck pdf-tools tree-sitter))
 '(send-mail-function 'mailclient-send-it))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
