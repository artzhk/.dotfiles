;;; palettes.el --- shared color names for my themes -*- lexical-binding: t; -*-
;; Both palettes use gruber-darker's names. "+N" means further from bg,
;; so in the light theme bg+N gets darker.

(defconst my/palette-gruber-darker
  '((fg . "#e4e4ef") (fg+1 . "#f4f4ff") (fg+2 . "#f5f5f5")
    (bg-1 . "#101010") (bg . "#181818") (bg+1 . "#282828") (bg+2 . "#453d41")
    (bg+3 . "#484848") (bg+4 . "#52494e")
    (red-1 . "#c73c3f") (red . "#f43841") (red+1 . "#ff4f58")
    (green . "#73c936") (yellow . "#ffdd33") (brown . "#cc8c3c")
    (quartz . "#95a99f") (niagara-2 . "#303540") (niagara-1 . "#565f73")
    (niagara . "#96a6c8") (wisteria . "#9e95c7")
    (cyan . "#96a6c8"))                 ; not in gruber, aliased to niagara
  "Copy of the colors in gruber-darker-theme.el.")

(defconst my/palette-the-moment
  '((fg . "#2B3A2D") (fg+1 . "#1B2A1C") (fg+2 . "#141F16")
    (bg-1 . "#F7F8F9") (bg . "#FFFFFF") (bg+1 . "#ECEFF1") (bg+2 . "#C9CFD3")
    (bg+3 . "#A9B2B9") (bg+4 . "#4A5560")
    (red-1 . "#6B5644") (red . "#A0524A") (red+1 . "#B5625A")
    (green . "#5F7F3A") (yellow . "#8F8568") (brown . "#8B7355")
    (quartz . "#868C82") (niagara-2 . "#8A96A0") (niagara-1 . "#4A5560")
    (niagara . "#4A7FA6") (wisteria . "#4A6FA0")
    (cyan . "#5A8FA6"))
  "The Moment colors, light and storm-sky derived.")

(defconst my/palettes
  `((gruber-darker . ,my/palette-gruber-darker)
    (the-moment    . ,my/palette-the-moment)))

(defun my/color (name)
  "Return color NAME from the palette of the first enabled theme that has one."
  (alist-get name (seq-some (lambda (theme) (alist-get theme my/palettes))
                            custom-enabled-themes)))

(provide 'palettes)
;;; palettes.el ends here
