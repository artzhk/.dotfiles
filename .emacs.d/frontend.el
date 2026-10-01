;;; frontend.el --- TypeScript/JS: tree-sitter grammar + dual-LSP 

;; Remove if nothing breakes
;; (when (treesit-available-p)
;;   (dolist (mapping '((tsx . "tsx/src") (typescript . "typescript/src")))
;;     (add-to-list 'treesit-language-source-alist
;;                  (list (car mapping) "https://github.com/tree-sitter/tree-sitter-typescript"
;;                        nil (cdr mapping)))
;;     (unless (treesit-language-available-p (car mapping))
;;       (ignore-errors (treesit-install-language-grammar (car mapping)))))
;;   (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
;;   (add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode)))


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

(defun my/oxlint-git-changed ()
  "Run oxlint --fix on all modified/untracked TS files per git status."
  (interactive)
  (compile
   "oxlint --fix --format=unix $(git status --untracked-files -s | grep -e '^.[??|M| M|UU].*ts\\w*$' | cut -c 4-)"))

(defun my/oxlint-current-file ()
  "Run oxlint --fix on the file visited by the current buffer."
  (interactive)
  (when buffer-file-name
    (save-buffer)
    (compile (format "oxlint --fix --format=unix %s"
                      (shell-quote-argument (expand-file-name buffer-file-name))))))

(defun my/oxfmt-current-file ()
  "Run fmt --fix on the file visited by the current buffer."
  (interactive)
  (when buffer-file-name
    (save-buffer)
    (compile (format "oxfmt %s"
                     (shell-quote-argument (expand-file-name buffer-file-name))))))

(defvar-keymap my/ox-mode-map
  "C-c L" #'my/oxlint-git-changed
  "C-c l" #'my/oxlint-current-file
  "C-c f" #'my/oxfmt-current-file)

(define-minor-mode my/ox-mode
  "Oxlint/oxfmt keys for JS/TS buffers."
  :keymap my/ox-mode-map)

(dolist (hook '(js-mode-hook          ; .js .jsx (classic)
                js-ts-mode-hook       ; .js .jsx (tree-sitter)
                typescript-ts-mode-hook ; .ts
                tsx-ts-mode-hook))    ; .tsx
  (add-hook hook #'my/ox-mode))



(provide 'frontend)
