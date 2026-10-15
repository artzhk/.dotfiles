;; -*- lexical-binding: t; -*-
(require 'ox-html)

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

(with-eval-after-load 'ox-html
  (setq org-html-mathjax-options
        (cons '(scale . "200")
              (assq-delete-all 'scale org-html-mathjax-options))))


(when (executable-find "epdfinfo")
  (unless (package-installed-p 'pdf-tools)
    (package-install 'pdf-tools))
  (add-hook 'after-init-hook (lambda () (pdf-tools-install t))))

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
      org-latex-pdf-process '("pdflatex -interaction nonstopmode -output-directory %o %f"))

(provide 'latex)
