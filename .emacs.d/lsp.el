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
