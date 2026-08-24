;;; frontend.el --- TypeScript/JS: tree-sitter grammar + dual-LSP setup -*- lexical-binding: t; -*-

;;; TSX/TS tree-sitter grammar + mode routing

(when (treesit-available-p)
  (dolist (mapping '((tsx . "tsx/src") (typescript . "typescript/src")))
    (add-to-list 'treesit-language-source-alist
                 (list (car mapping) "https://github.com/tree-sitter/tree-sitter-typescript"
                       nil (cdr mapping)))
    (unless (treesit-language-available-p (car mapping))
      (ignore-errors (treesit-install-language-grammar (car mapping)))))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode)))

;;; typescript-language-server + oxlint simultaneously, multiplexed onto one
;;; connection via rass (pip install rassumfrassum:
;;; https://github.com/joaotavora/rassumfrassum). Falls back to tsserver alone
;;; if rass or oxlint isn't installed.

(with-eval-after-load 'eglot
  (cond
   ((and (executable-find "rass")
         (executable-find "typescript-language-server")
         (executable-find "oxlint"))
    (add-to-list 'eglot-server-programs
                 '((typescript-mode typescript-ts-mode tsx-ts-mode js-mode js-ts-mode)
                   "rass" "--" "typescript-language-server" "--stdio" "--" "oxlint" "--lsp")))
   ((executable-find "typescript-language-server")
    (add-to-list 'eglot-server-programs
                 '((typescript-mode typescript-ts-mode tsx-ts-mode js-mode js-ts-mode)
                   "typescript-language-server" "--stdio")))))

(provide 'frontend)
