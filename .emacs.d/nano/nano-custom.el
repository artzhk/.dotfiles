;; -*- lexical-binding: t; -*-
;;; Nano -----------------------------------------------------------------------
;; Font must be set before nano.el loads: every theme refresh (`nano-faces')
;; re-applies `nano-font-family-monospaced' (default "Roboto Mono", not
;; installed) and `nano-font-size' to the default face.
(setq nano-font-family-monospaced
      (or (and (display-graphic-p)
               (seq-find (lambda (family) (find-font (font-spec :family family)))
                         '("MononokiNerdFont Mono 20" "MononokiNerdFont Mono")))
          "MononokiNerdFont Mono"))
(setq nano-font-size 25)

;; Light: nano background, region and header line + syntax colors
;; (strings, functions, keywords...) from the-moment theme.
;; Dark: nano layout with gruber-darker colors (palette from
;; https://github.com/rexim/gruber-darker-theme).
(add-to-list 'custom-theme-load-path
             (file-name-directory (file-truename user-init-file)))
(load-theme 'the-moment t t)            ; load face specs without enabling

(defconst my/gruber-darker-syntax
  '((font-lock-builtin-face           :foreground "#ffdd33")
    (font-lock-comment-face           :foreground "#cc8c3c")
    (font-lock-comment-delimiter-face :foreground "#cc8c3c")
    (font-lock-constant-face          :foreground "#95a99f")
    (font-lock-doc-face               :foreground "#73c936")
    (font-lock-function-name-face     :foreground "#96a6c8")
    (font-lock-keyword-face           :foreground "#ffdd33" :bold t)
    (font-lock-preprocessor-face      :foreground "#95a99f")
    (font-lock-string-face            :foreground "#73c936")
    (font-lock-type-face              :foreground "#95a99f")
    (font-lock-variable-name-face     :foreground "#f4f4ff")
    (font-lock-warning-face           :foreground "#f43841"))
  "Gruber-darker font-lock faces, as (FACE . ATTRS).")

(defun my/the-moment-syntax ()
  "Return the-moment's font-lock faces, as (FACE . ATTRS)."
  (let (faces)
    (dolist (setting (get 'the-moment 'theme-settings) faces)
      (pcase setting
        (`(theme-face ,face the-moment ((t ,attrs)))
         (when (string-prefix-p "font-lock-" (symbol-name face))
           (push (cons face attrs) faces)))))))

(defun my/set-syntax-faces (faces)
  "Apply FACES, a list of (FACE . ATTRS), replacing nano's font-lock faces."
  (pcase-dolist (`(,face . ,attrs) faces)
    (set-face-attribute face nil
                        :inherit 'unspecified
                        :foreground (plist-get attrs :foreground)
                        :slant (if (plist-get attrs :normal) 'normal 'normal)
                        :weight (if (plist-get attrs :bold) 'bold 'normal))))

(defun my/gruber-darker-palette ()
  "Replace nano's dark (Nord) palette with gruber-darker colors."
  (setq nano-color-foreground "#e4e4ef"   ; fg
        nano-color-background "#181818"   ; bg
        nano-color-highlight  "#282828"   ; bg+1
        nano-color-critical   "#f43841"   ; red
        nano-color-salient    "#96a6c8"   ; niagara
        nano-color-strong     "#f4f4ff"   ; fg+1
        nano-color-popout     "#ffdd33"   ; yellow
        nano-color-subtle     "#282828"   ; bg+1 (header line, like its mode-line)
        nano-color-faded      "#95a99f")) ; quartz
(advice-add 'nano-theme-set-dark :after #'my/gruber-darker-palette)

(defun my/apply-syntax-colors ()
  "Apply per-variant colors on top of nano's theme."
  (pcase nano-theme-var
    ("light" (my/set-syntax-faces (my/the-moment-syntax)))
    ("dark"  (my/set-syntax-faces my/gruber-darker-syntax)
             (set-face-attribute 'region nil :background "#484848") ; bg+3
             (set-face-attribute 'cursor nil :background "#ffdd33"))))
(advice-add 'nano-refresh-theme :after #'my/apply-syntax-colors)

;; nano.el already applied its theme: redo it with the palettes above
(when (equal nano-theme-var "dark") (my/gruber-darker-palette))
(nano-refresh-theme)

(provide 'nano-custom)
