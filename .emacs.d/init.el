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
(load-theme 'modus-operandi t)
(add-to-list 'default-frame-alist '(undecorated . nil))
(setq frame-title-format '("%p - %b — Emacs"))
(setq-default frame-resize-pixelwise t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)
(global-visual-line-mode 0)
(set-frame-font "IosevkaTerm Nerd Font Mono 18" nil t)
(setq-default fill-column 80)
(setq-default truncate-lines t)
(global-display-fill-column-indicator-mode 1)

(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; emacs windows ---------------------------------------------------------------

(windmove-default-keybindings 'shift)
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
(ensure-package 'ansi-color)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(ensure-package 'exec-path-from-shell)
(exec-path-from-shell-initialize)              ; copies PATH → exec-path
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")
(ensure-package 'orderless)
(use-package orderless
  :init
  (setq completion-styles '(basic))
  (setq completion-category-overrides
        '((file (styles orderless)))))

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


;;; Org — agenda views ---------------------------------------------------------

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


;;; Org-space — mirror new org files as symlinks under ~/org-space/ ------------

(defun org-space--ensure-symlink (file-path)
  "If FILE-PATH is outside ~/org-space/, replace it with a symlink into ~/org-space/."
  (let* ((home      (expand-file-name "~/"))
         (org-space (expand-file-name "~/org-space/")))
    (unless (string-prefix-p org-space (file-truename file-path))
      (let* ((rel    (file-relative-name file-path home))
             (target (expand-file-name rel org-space)))
        (make-directory (file-name-directory target) t)
        (if (file-exists-p target)
            (message "Warning: target already exists in ~/org-space/: %s" target)
          (write-region "" nil target))
        (when (file-exists-p file-path)
          (delete-file file-path))
        (make-symbolic-link target file-path t)))))

(defun org-space-maybe-mirror-new-file ()
  (when (and (derived-mode-p 'org-mode)
             (not (file-exists-p (buffer-file-name))))
    (org-space--ensure-symlink (buffer-file-name))))

(add-hook 'find-file-hook #'org-space-maybe-mirror-new-file)


;;; Org — utilities ------------------------------------------------------------

(defun merge-org-to-mobile-export (dir)
  "Merge all .org files in DIR into a single file under ~/org-space/exports/."
  (interactive "DDirectory: ")
  (let* ((export-dir  "~/org-space/exports/")
         (files       (directory-files dir t "\\.org$"))
         (folder-name (file-name-nondirectory (directory-file-name dir)))
         (output      (expand-file-name (concat folder-name ".org") export-dir)))
    (make-directory export-dir t)
    (with-temp-file output
      (dolist (file files)
        (insert (format "#+TITLE: From %s\n\n" (file-name-nondirectory file)))
        (insert-file-contents file)
        (insert "\n\n")))
    (message "Merged %d files into %s" (length files) output)))

(defun paste-screenshot ()
  "Capture a screenshot and insert an org link to it in the current buffer."
  (interactive)
  (if (eq system-type 'darwin)
      (let* ((base-dir (or (and buffer-file-name (file-name-directory buffer-file-name))
                           default-directory))
             (dir      (expand-file-name "Cache" base-dir))
             (_        (make-directory dir t))
             (filename (expand-file-name
                        (format "%s_%s.png"
                                (format-time-string "%Y%m%d_%H%M%S")
                                (substring (md5 (format "%s%s" (user-uid) (float-time))) 0 6))
                        dir))
             (status   (call-process "screencapture" nil nil nil "-i" filename)))
        (if (and (numberp status) (zerop status)
                 (file-exists-p filename)
                 (> (nth 7 (file-attributes filename)) 0))
            (progn
              (insert (concat "[[./" (file-relative-name filename base-dir) "]]"))
              (when (derived-mode-p 'org-mode) (org-display-inline-images)))
          (when (file-exists-p filename) (delete-file filename))
          (user-error "Screenshot canceled or failed; nothing inserted")))
    (let* ((dir      "./Cache/")
           (_        (make-directory dir t))
           (filename (concat dir (format-time-string "%Y%m%d_%H%M%S_") (make-temp-name "") ".png")))
      (call-process-shell-command (format "grim -g \"$(slurp)\" -t png %s" (shell-quote-argument filename)))
      (insert (concat "[[" filename "]]"))
      (org-display-inline-images))))


;;; LaTeX — inline preview (org math fragments) --------------------------------

(when (and (executable-find "latex") (executable-find "dvisvgm"))
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.7))
  (with-eval-after-load 'org
    (let ((dvisvgm-conf '(dvisvgm
                          :programs         ("latex" "dvisvgm")
                          :description      "dvi → svg"
                          :message          "Install TeX (latex) and dvisvgm."
                          :image-input-type  "dvi"
                          :image-output-type "svg"
                          :image-size-adjust (1.7 . 1.7)
                          :latex-compiler   ("latex -interaction=nonstopmode -output-directory %o %f")
                          :image-converter  ("dvisvgm --no-fonts --exact-bbox -o %O %f"))))
      (setq org-preview-latex-process-alist
            (cons dvisvgm-conf
                  (assoc-delete-all 'dvisvgm org-preview-latex-process-alist)))
      (setq org-preview-latex-default-process 'dvisvgm))))


;;; HTML — MathJax scaling -----------------------------------------------------

(with-eval-after-load 'ox-html
  (setq org-html-mathjax-options
        (cons '(scale . "200")
              (assq-delete-all 'scale org-html-mathjax-options))))


;;; Compile -------------------------------------------------------------------

;; No default global keys exist for these; everything else (g=recompile,
;; M-n/M-p=next/prev error, M-.=jump-to-error) works out of the box.
(global-set-key (kbd "C-c c") #'compile)         ; prompt & run
(global-set-key (kbd "C-c p") #'project-compile) ; from project root

;;; LSP — eglot & flymake keybindings -----------------------------------------

(ensure-package 'tree-sitter)
(global-set-key (kbd "C-c b") 'previous-buffer)
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c ! l") #'flymake-show-buffer-diagnostics)
(global-set-key (kbd "C-c ! L") #'flymake-show-project-diagnostics)
(global-set-key (kbd "C-c f") #'eglot-format-buffer)
(global-set-key (kbd "C-c a") #'eglot-code-actions)
(global-set-key (kbd "C-c i") #'eglot-find-implementation)
(global-set-key (kbd "C-c C-r") #'eglot-rename)
(global-set-key (kbd "C-M-;") #'uncomment-region)
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))

;;; LSP — eglot ----------------------------------------------------------------

;; TypeScript / JavaScript — tree-sitter grammar + dual typescript-language-server
;; + oxlint setup lives in frontend.el.
(load (expand-file-name "frontend.el" user-emacs-directory))

(with-eval-after-load 'eglot
  (when (executable-find "clangd")
    (add-to-list 'eglot-server-programs
                 '((c-mode c++-mode c-ts-mode c++-ts-mode)
                   "clangd" "--background-index" "--clang-tidy")))
  (when (executable-find "rust-analyzer")
    (add-to-list 'eglot-server-programs
                 '((rust-mode rust-ts-mode) "rust-analyzer")))
  (when (executable-find "gopls")
    (add-to-list 'eglot-server-programs
                 '((go-mode go-ts-mode) "gopls")))
  (when (executable-find "pylsp")
    (add-to-list 'eglot-server-programs
                 '((python-mode python-ts-mode) "pylsp")))
  (when (and (executable-find "ruff") (not (executable-find "pylsp")))
    (add-to-list 'eglot-server-programs
                 '((python-mode python-ts-mode) "ruff" "server")))
  (when (executable-find "ruby-lsp")
    (add-to-list 'eglot-server-programs
                 '((ruby-mode ruby-ts-mode) "ruby-lsp")))
  (when (executable-find "sql-language-server")
    (add-to-list 'eglot-server-programs
                 '(sql-mode "sql-language-server" "up" "--method" "stdio")))
  (when (executable-find "csharp-ls")
    (add-to-list 'eglot-server-programs
                 '(csharp-mode "csharp-ls"))))

(dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook
                rust-mode-hook rust-ts-mode-hook
                go-mode-hook go-ts-mode-hook
                python-mode-hook python-ts-mode-hook
                typescript-mode-hook typescript-ts-mode-hook
                js-mode-hook js-ts-mode-hook tsx-ts-mode-hook
                ruby-mode-hook ruby-ts-mode-hook
                csharp-mode-hook))
  (add-hook hook #'eglot-ensure))

;;; Debugging — dape (netcoredbg for dotnet) ------------------------------------

(when (executable-find "netcoredbg")
  (ensure-package 'dape)
  ;; PBD.Core.Web — dotnet run --project ./src/PBD.Core.Web/... -lp https -c Development
  ;; Paths are relative to the project root (via dape-cwd), so this works from
  ;; the main checkout or any worktree copy, not just one hardcoded location.
  (unless (assq 'pbd-web dape-configs)
    (push
     `(pbd-web
       modes (csharp-mode csharp-ts-mode)
       ensure dape-ensure-command
       command "netcoredbg"
       command-args ["--interpreter=vscode"]
       :request "launch"
       :cwd (expand-file-name "src/PBD.Core.Web" (dape-cwd))
       :program (car (file-expand-wildcards
                      (expand-file-name "src/PBD.Core.Web/bin/Development/*/PBD.Core.Web.dll"
                                         (dape-cwd))))
       :env (:ASPNETCORE_ENVIRONMENT "Development"
             :ASPNETCORE_URLS "https://pbd-core-web.dev.localhost:44337;http://localhost:51100")
       :stopAtEntry nil)
     dape-configs)))


;;; pdf-tools ------------------------------------------------------------------

(when (executable-find "epdfinfo")
  (unless (package-installed-p 'pdf-tools)
    (package-install 'pdf-tools))
  (add-hook 'after-init-hook (lambda () (pdf-tools-install t))))


;;; Magit ----------------------------------------------------------------------

(ensure-package 'magit)

;;; Copilot --------------------------------------------------------------------

(ensure-package 'copilot)
(global-set-key (kbd "C-c e") #'copilot-accept-completion)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("019184a760d9747744783826fcdb1572f9efefc5c19ed43b6243e66638fb9960" default))
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
