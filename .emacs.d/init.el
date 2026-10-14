;;; Tmp / backup files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)

;;; Custom
;; Keep Custom's output out of init.el so it can't silently override setq's
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

;;; Nano (optional)
;; Customised nano (font, nano.el, light/dark colors) lives in nano-custom.el.
;; Default Emacs is the fallback: start with `emacs -no-nano' to skip it, and
;; if it is missing or fails to load, init continues with a warning.
(add-to-list 'command-switch-alist '("-no-nano" . ignore))
(let ((nano-custom (expand-file-name "nano-custom.el" user-emacs-directory)))
  (when (and (file-exists-p nano-custom)
             (not (member "-no-nano" command-line-args)))
    (condition-case err
        (load nano-custom)
      (error (display-warning
              'nano (format "nano-custom.el failed, using default Emacs: %S"
                            err))))))

;;; Session persistence
(save-place-mode 1)              ; reopen a file at the last point you were on
(savehist-mode 1)                ; persist minibuffer history...
(add-to-list 'savehist-additional-variables 'register-alist) ; ...and registers
(desktop-save-mode 1)            ; save/restore open buffers & window layout((

;;; Editing
(setq-default delete-selection-mode t)

;;; UI
(blink-cursor-mode 0)
(add-to-list 'default-frame-alist '(undecorated . nil))
(setq frame-title-format '("%p - %b — Emacs"))
(setq-default frame-resize-pixelwise t)
(menu-bar-mode -1)
(setq-default fill-column 80)
(setq-default display-line-numbers t)

;; With nano, the status line (project, which-func, %I %p L:C, time,
;; battery) lives in nano's header line: see nano-modeline.el and nano.el

(setq-default truncate-lines nil)   ; wrap everywhere by default
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))  ; no wrap in code buffers
(add-hook 'org-mode-hook (lambda () (setq truncate-lines nil)))
(add-hook 'term-mode-hook (lambda () (setq truncate-lines -1)))

(global-display-fill-column-indicator-mode 1)
(ffap-bindings)
(goto-address-mode 1)
(global-subword-mode 1)

(setq-default next-screen-context-lines 9)
(setq-default scroll-preserve-screen-position t)
(setq-default delete-selection-mode t)

;; TODO: where that must go?
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

(global-set-key (kbd "C-c k f") 'my/cp-file-path)
(global-set-key (kbd "C-c e") 'revert-buffer)
(global-set-key (kbd "C-,") 'rc/duplicate-line)
(global-set-key (kbd "C-x k") 'kill-current-buffer) ; no prompt (from nano-bindings)

(setq project-vc-extra-root-markers '(".project"))
;; emacs windows ---------------------------------------------------------------

(global-set-key (kbd "C-c w w") 'delete-other-windows)
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

(load (expand-file-name "lsp.el" user-emacs-directory))
(load (expand-file-name "dotnet.el" user-emacs-directory))
(load (expand-file-name "frontend.el" user-emacs-directory))

;;; Shell PATH (needed for Magit, compile, and external tools) ----------------
;; (ensure-package 'ansi-color :ensure)
(ensure-package 'ansi-color)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
;; nano maps `success' to salient (purple); give compilation Emacs' stock green
(with-eval-after-load 'compile
  (face-spec-set 'compilation-info (get 'success 'face-defface-spec))
  (set-face-attribute 'compilation-info nil :inherit 'unspecified))

(ensure-package 'exec-path-from-shell)
(exec-path-from-shell-initialize)              ; copies PATH → exec-path
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")

;; Vanilla completion, everywhere (M-x, buffer switching, etc.): built-in
;; `flex' style = closest/subsequence match, case-insensitive. No package.
(ido-mode 1)
(fido-vertical-mode 1)
(setq xref-search-program 'ripgrep)   ; Emacs ≥ 27, needs `rg` in PATH
(setq completion-styles '(basic substring))
(setq completion-ignore-case t)
(setq icomplete-in-buffer t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

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
        fzf/window-height 15))

(keymap-global-set "C-c C-f" #'fzf-git)   ; or fzf-async-
(keymap-global-set "C-c u" #'fzf)

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

;;; Buffer --------------------------------------------------------------------
(keymap-global-set "C-x C-b" #'ibuffer)

;; No default global keys exist for these; everything else (g=recompile,
;; M-n/M-p=next/prev error, M-.=jump-to-error) works out of the box.
(global-set-key (kbd "C-c c") #'compile)         ; prompt & run
(global-set-key (kbd "C-c p") #'project-compile) ; from project 

(ensure-package 'tree-sitter)
(ensure-package 'tree-sitter-langs)
(setq tree-sitter-load-path
      (list (expand-file-name "bin" (file-name-directory (locate-library "tree-sitter-langs")))
            (expand-file-name "tree-sitter" user-emacs-directory)))

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

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))

;;; Magit ----------------------------------------------------------------------
(ensure-package 'magit)
(ensure-package 'git-gutter)
(ensure-package 'git-gutter-fringe)
(global-git-gutter-mode 1)

(global-set-key (kbd "C-c C-h h") #'git-gutter:popup-diff)
(global-set-key (kbd "C-c C-h n") #'git-gutter:next-diff)
(global-set-key (kbd "C-c C-h p") #'git-gutter:previous-diff)


;;; Copilot --------------------------------------------------------------------
(ensure-package 'copilot)
(global-set-key (kbd "C-c C-e") #'copilot-accept-completion)
(copilot-mode 1)
