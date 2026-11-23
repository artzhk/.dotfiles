;;; custom.el --- Custom-managed settings -*- lexical-binding: t; -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("d2bab0e613f8321b0b8bc06a5bcd8d98f6578590982371674d880079b72f1b47"
     "f7bda565084cc99184e37470c52c5856e832c6d2c340b3f93e48827c13596954" default))
 '(package-selected-packages
   '(compilation-history copilot dart-mode dotnet ement evil exec-path-from-shell
			 fzf git-gutter-fringe glsl-mode go-mode undo-tree
			 gruber-darker-theme ivory-themes lsp-mode magit
			 mermaid-mode multi-compile multiple-cursors orderless
			 pdf-tools qml-mode rust-mode tree-sitter-langs eglot
			 ido-completing-read+ xterm-color))
 '(package-vc-selected-packages
   '((ivory-themes :url "https://github.com/khzaw/ivory-themes.git")
     (fzf-async :url "https://github.com/jojojames/fzf-async")
     (fzf-native :url "https://github.com/jojojames/fzf-native")))
 '(send-mail-function 'mailclient-send-it)
 '(warning-suppress-log-types '((use-package))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(git-gutter:added ((t (:foreground "default" :background "nil"))))
 '(git-gutter:deleted ((t (:foreground "default" :background "nil"))))
 '(git-gutter:modified ((t (:foreground "default" :background "nil")))))
