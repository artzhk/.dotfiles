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
                 '(sql-mode "sql-language-server" "up" "--method" "stdio"))))

(dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook
                rust-mode-hook rust-ts-mode-hook
                go-mode-hook go-ts-mode-hook
                python-mode-hook python-ts-mode-hook
                typescript-mode-hook typescript-ts-mode-hook
                js-mode-hook js-ts-mode-hook tsx-ts-mode-hook
                ruby-mode-hook ruby-ts-mode-hook
                csharp-mode-hook))
  (add-hook hook #'eglot-ensure))

(defun my/go-format-buffer ()
  (interactive)
  (when (eq major-mode 'go-ts-mode)
    (let ((out (generate-new-buffer " *golines*")))
      (unwind-protect
          (when (zerop (call-process-region nil nil "golines" nil out nil
                                            "-m" "80" "--tab-len=8"))
            (replace-buffer-contents out))
	(kill-buffer out)))))

(with-eval-after-load 'go-ts-mode
  (keymap-set go-ts-mode-map "C-c f" #'my/go-format-buffer))

;; Flymake: plain straight underline under the erroneous range instead of
;; the wavy one, and no "!!"/"!" characters in the margin.
;; To keep margin markers with other chars instead, set
;; `flymake-indicator-type' to 'margins and e.g.:
;;   (setq flymake-margin-indicators-string
;;         '((error "●" compilation-error)
;;           (warning "●" compilation-warning)
;;           (note "·" compilation-info)))
(setq flymake-indicator-type nil)
(with-eval-after-load 'flymake
  (set-face-attribute 'flymake-error nil
                      :inherit 'unspecified
                      :underline '(:style line :color "#f43841"))
  (set-face-attribute 'flymake-warning nil
                      :inherit 'unspecified
                      :underline '(:style line :color "#cc8c3c"))
  (set-face-attribute 'flymake-note nil
                      :inherit 'unspecified
                      :underline '(:style line :color "#73c936")))
