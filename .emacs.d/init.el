;;; UI -------------------------------------------------------------------------

(load-theme 'leuven t)
(add-to-list 'default-frame-alist '(undecorated . nil))
(setq frame-title-format '("%b — Emacs"))
(setq-default frame-resize-pixelwise t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)
(global-visual-line-mode t)
(set-frame-font "IosevkaTerm Nerd Font Mono 14" nil)


;;; Packages -------------------------------------------------------------------

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))


;;; Evil (vim keybindings) -----------------------------------------------------

;; These must be set before (require 'evil)
(setq evil-undo-system     'undo-redo
      evil-want-C-u-scroll t
      evil-want-C-a-scroll t
      evil-want-C-w-delete t)

(unless (package-installed-p 'evil)
  (package-install 'evil))
(require 'evil)
(evil-mode 1)

(with-eval-after-load 'evil
  (define-key evil-insert-state-map (kbd "ESC") #'evil-force-normal-state))


;;; Shell PATH (needed for Magit and external tools) ---------------------------

(require 'exec-path-from-shell)


;;; Org — core settings --------------------------------------------------------

(require 'org)
(require 'ox-latex)
(require 'ox-md)

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-startup-indented            t
      org-startup-with-inline-images  t
      org-startup-with-latex-preview  nil
      org-image-actual-width          '(800))


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

(setq org-agenda-files '("~/org-space/" "\\.org$"))

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

(add-to-list 'load-path "~/repos/img2orgtable-emacs")
(require 'img2orgtable)
(setq img2orgtable--screenshot-cmd "grim -g \"$(slurp)\" -t png %s")

(add-hook 'org-babel-after-execute-hook #'org-display-inline-images)


;;; LaTeX — export classes -----------------------------------------------------

(add-to-list 'org-latex-classes
             '("article"
               "\\documentclass[11pt]{article}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\usepackage{graphicx}
\\usepackage{tikz}
\\usepackage{hyperref}
\\usepackage{float}
\\usepackage{booktabs}
\\usepackage{color}
\\usepackage{geometry}
\\geometry{margin=1in}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")))

(add-to-list 'org-latex-classes
             '("cv"
               "\\documentclass[8pt,letterpaper]{article}
% tighter side margins
\\usepackage[ignoreheadfoot,margin=1.5cm,footskip=0.8cm]{geometry}

\\usepackage{titlesec}
\\usepackage[dvipsnames]{xcolor}
\\definecolor{primaryColor}{RGB}{0,0,0}
\\usepackage{enumitem}
\\usepackage[unicode,colorlinks=true,urlcolor=primaryColor]{hyperref}
\\usepackage{changepage}
\\usepackage{paracol}
\\usepackage{needspace}
\\usepackage[T1]{fontenc}
\\usepackage[utf8]{inputenc}
\\usepackage{lmodern}

\\raggedright
\\pagestyle{empty}
\\setcounter{secnumdepth}{0}
\\setlength{\\parindent}{0pt}
\\setlength{\\topskip}{0pt}
\\setlength{\\columnsep}{0.15cm}

% compact section headings
\\titleformat{\\section}{\\needspace{0\\baselineskip}\\bfseries\\large}{}{0pt}{}[\\vspace{1pt}\\titlerule]
\\titlespacing*{\\section}{-1pt}{0.25cm}{0.15cm}

% global compact lists
\\setlist[itemize]{topsep=0.15ex,itemsep=0.15ex,parsep=0pt,partopsep=0pt,leftmargin=1.2em}
\\setlist[enumerate]{topsep=0.15ex,itemsep=0.15ex,parsep=0pt,partopsep=0pt,leftmargin=1.5em}

\\renewcommand\\labelitemi{$\\vcenter{\\hbox{\\small$\\bullet$}}$}

% specific CV list envs, even tighter
\\newenvironment{highlights}{%
  \\begin{itemize}[topsep=0.1ex,parsep=0pt,partopsep=0pt,itemsep=0pt,leftmargin=0.8em]%
}{%
  \\end{itemize}%
}

\\newenvironment{highlightsforbulletentries}{%
  \\begin{itemize}[topsep=0.1ex,parsep=0pt,partopsep=0pt,itemsep=0pt,leftmargin=0.8em]%
}{%
  \\end{itemize}%
}

\\newenvironment{onecolentry}{%
  \\begin{adjustwidth}{0cm}{0cm}%
}{%
  \\end{adjustwidth}%
}

\\newenvironment{twocolentry}[2][]{%
  \\onecolentry
  \\def\\secondColumn{#2}%
  \\setcolumnwidth{\\fill,4.2cm}%
  \\begin{paracol}{2}%
}{%
  \\switchcolumn \\raggedleft \\secondColumn%
  \\end{paracol}%
  \\endonecolentry
}

\\newenvironment{threecolentry}[3][]{%
  \\onecolentry
  \\def\\thirdColumn{#3}%
  \\setcolumnwidth{,\\fill,4.2cm}%
  \\begin{paracol}{3}%
  {\\raggedright #2}\\switchcolumn%
}{%
  \\switchcolumn \\raggedleft \\thirdColumn%
  \\end{paracol}%
  \\endonecolentry
}

% Big, tight CV title using only \\@title (no author/date)
\\makeatletter
\\renewcommand\\maketitle{%
  \\begin{center}
    \\vspace*{-0.4cm}%
    {\\bfseries\\LARGE \\@title\\par}%
    \\vspace{0.15cm}%
  \\end{center}
}
\\makeatother
"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(add-to-list 'org-latex-classes
             '("apa6"
               "\\documentclass[a4paper,man]{apa6}
\\usepackage[nodoi]{apacite}
\\usepackage[T1]{fontenc}
\\usepackage{fancyhdr}
\\usepackage{lastpage}
\\pagestyle{fancy}
\\fancyfoot[C]{%
  Page \\thepage\\ of \\pageref*{LastPage}%
}
\\usepackage{graphicx}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


;;; LaTeX — PDF export ---------------------------------------------------------

(setq org-latex-compiler  "pdflatex"
      org-latex-pdf-process '("pdflatex -interaction nonstopmode -output-directory %o %f"
                               "pdflatex -interaction nonstopmode -output-directory %o %f"))


;;; LaTeX — inline preview via dvisvgm -----------------------------------------

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
    (setq org-preview-latex-default-process
          (if (executable-find "dvisvgm") 'dvisvgm 'imagemagick))))


;;; HTML — MathJax scaling -----------------------------------------------------

(with-eval-after-load 'ox-html
  (setq org-html-mathjax-options
        (cons '(scale . "200")
              (assq-delete-all 'scale org-html-mathjax-options))))


;;; pdf-tools ------------------------------------------------------------------

(use-package pdf-tools
  :ensure t
  :config (pdf-tools-install))


;;; Emacs Custom (do not edit manually) ----------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("019184a760d9747744783826fcdb1572f9efefc5c19ed43b6243e66638fb9960"
     default))
 '(org-agenda-files
   '("~/org-space/Uni/final/diplom-project-overview.org"
     "/home/art/org-space/Personal/daily.org"
     "/home/art/org-space/Uni/DADT/DADT.org"
     "/home/art/org-space/Uni/AWD/AWD.org"
     "/home/art/org-space/Uni/3D/3D.org"))
 '(package-selected-packages
   '(## compat copilot copilot-chat dash dotnet ein eink-theme evil helm
	helm-bibtex html2org latex-table-wizard lsp-mode magit
	markdown-mode markdown-preview-mode org-fragtog org-modern
	org-noter org-ref org-roam org-roam-bibtex ox-latex-subfigure
	pdf-tools)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
