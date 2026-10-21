;;; the-moment-theme.el --- light theme, storm-sky derived -*- lexical-binding: t; -*-
(deftheme the-moment "The Moment")
(unless (featurep 'palettes)
  (load (expand-file-name "palettes.el"
                          (file-name-directory (or load-file-name buffer-file-name)))
        nil t))
(let-alist my/palette-the-moment
  (custom-theme-set-faces
   'the-moment
   `(default ((t (:foreground ,.fg :background ,.bg))))
   `(cursor ((t (:background ,.fg))))
   `(fringe ((t (:background ,.bg+2))))
   `(region ((t (:background ,.bg+1))))   ; nano light: Blue Grey / L50
   `(mode-line ((t (:foreground ,.bg :background ,.bg+4))))
   `(mode-line-inactive ((t (:foreground ,.bg+4 :background ,.bg+2))))
   `(font-lock-comment-face ((t (:foreground ,.quartz :italic t))))
   `(font-lock-string-face ((t (:foreground ,.green))))
   `(font-lock-function-name-face ((t (:foreground ,.niagara))))
   `(font-lock-keyword-face ((t (:foreground ,.wisteria))))
   `(font-lock-constant-face ((t (:foreground ,.brown))))
   `(font-lock-type-face ((t (:foreground ,.yellow))))
   `(font-lock-variable-name-face ((t (:foreground ,.fg))))
   `(font-lock-builtin-face ((t (:foreground ,.cyan))))
   `(font-lock-warning-face ((t (:foreground ,.red-1 :bold t))))))
(provide-theme 'the-moment)
;;; the-moment.el ends here
