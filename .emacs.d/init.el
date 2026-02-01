;;(load-theme 'tango-dark t)
(load-theme 'tango t)
;; ~/.emacs.d/init.el or early in config
(add-to-list 'default-frame-alist '(undecorated . nil))   ;; ensure WM draws borders/buttons
(setq frame-title-format '("%b — Emacs"))                ;; show buffer name in title
(setq-default frame-resize-pixelwise t)                  ;; avoids odd sizing with CSD
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)


(add-to-list 'load-path "~/repos/img2orgtable-emacs")
(require 'img2orgtable)
(setq img2orgtable--screenshot-cmd "flameshot gui -r > %s")

;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
;;(package-initialize)
;;(package-refresh-contents)

;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Evil
;; Vim mode
(setq evil-mode t)
(setq evil-undo-system 'undo-redo)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-a-scroll t)
(setq evil-want-C-w-delete t)
(require 'evil)

;; Copilot suggestion
;;(require 'copilot-chat)
;;(global-set-key (kbd "C-c C-p") 'copilot-accept-completion)

;; Magit melpa
(require 'exec-path-from-shell)

(global-visual-line-mode)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(set-frame-font "IosevkaTerm Nerd Font Mono 14" nil )

;; ORG settings
(setq org-todo-keywords-faces
      '(("TODO" . org-warning) 
	("IN_PROGRESS" . "yellow")
	("CANCELED" . (:foreground "blue" :weight bold))
	("DONE" . (:foreground "green" :weight bold))))
(setq org-todo-keywords
      '((sequence "TODO(t)" "IN_PROGRESS(i!)" "|" "DONE(d!)" "CANCELED(c@)")))
(setq org-startup-indented t) 

(defun org-space--ensure-symlink (file-path)
  "if path is outside ~/org-space/, creaet it as a symlink to ~/org-space/."
  (let ((home-path (expand-file-name "~/"))
	(org-space-path (expand-file-name "~/org-space/")))
    ;; Skip if already in ~/org-space/
    (unless (string-prefix-p org-space-path (file-truename file-path))
      (let* ((relative-path (file-relative-name file-path home-path))
	     (target-path (expand-file-name relative-path org-space-path)))
	;;Create parent dirs in ~/org-space/
	(make-directory (file-name-directory target-path) t)
	;; If the target exists, symlink to it
	(if (file-exists-p target-path)	
    (massage "Warning: Target exists in ~/org-space/: %s" target-path)
	  ;; Otherwise, write a dummy file to the target (so we can symlink)
	  (write-region "" nil target-path))
	;; Replace the original path with a symlink to ~/org-space/
	(delete-file file-path)
	(make-symbolic-link target-path file-path t)))))

;; Hook to trigger when a new file is created
(defun org-space-maybe-mirror-new-file ()
  (when (and (derived-mode-p 'org-mode)
	     (not (file-exists-p (buffer-file-name))))
    (org-space--ensure-symlink (buffer-file-name))))

(add-hook 'find-file-hook #'org-space-maybe-mirror-new-file)

;;(setq org-agenda-files (directory-files-recursively "~/org-space/" "\\.org$"))

;; Merges files in dir to export
(defun merge-org-to-mobile-export (dir)
  (interactive "DDirectory: ")
  (let* ((export-dir "~/org-space/exports/")
	 (files (directory-files dir t "\\.org$" ))
	 (folder-name (file-name-nondirectory (directory-file-name dir)))
	 (output (expand-file-name (concat folder-name ".org") export-dir)))
    (make-directory (file-name-directory export-dir) t)
    (with-temp-file output
      (dolist (file files)
	(insert-file-contents file)
	(insert (format "#+TITLE: From %s\n\n" (file-name-nondirectory file)))
	(insert "\n\n")))
    (message "Stuff merged %d files into %s" (length files) output)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("019184a760d9747744783826fcdb1572f9efefc5c19ed43b6243e66638fb9960"
     default))
 '(org-agenda-files
   '("~/org-space/vaults/main/Uni/PCaIOT/PCaIOT.org"
     "/home/art/org-space/vaults/main/Uni/NLP/NLP.org"
     "/home/art/org-space/vaults/main/Uni/MLaNN/MLaNN.org"))
 '(package-selected-packages
   '(## compat copilot copilot-chat dash ein eink-theme evil helm
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

;; Screenshots pasting
;; https://stackoverflow.com/questions/17435995/paste-an-image-on-clipboard-to-emacs-org-mode-file-without-saving-it
(defun paste-screenshot ()
  "Take a screenshot into a time stamped unique-named file in the
same directory as the org-buffer and insert a link to this file."
  (interactive)
  (if (eq system-type 'darwin)
    (let* ((base-dir (or (and buffer-file-name
			(file-name-directory buffer-file-name))
		    default-directory))
	(dir (expand-file-name "Cache" base-dir))
	(_ (make-directory dir t))
	(filename (expand-file-name
		(format "%s_%s.png"
			(format-time-string "%Y%m%d_%H%M%S")
			(substring (md5 (format "%s%s" (user-uid) (float-time))) 0 6))
		dir))
	;; Use the built-in macOS screenshot tool
	(status (call-process "screencapture" nil nil nil "-i" filename)))
	(if (and (numberp status) (zerop status)
	    (file-exists-p filename)
	    (> (nth 7 (file-attributes filename)) 0))
	(progn
	    (insert (concat "[[./" (file-relative-name filename base-dir) "]]"))
	    (when (derived-mode-p 'org-mode)
	    (org-display-inline-images)))
	(when (file-exists-p filename) (delete-file filename))
	(user-error "Screenshot canceled or failed; nothing inserted"))))
  (unless (eq system-type 'darwin)
    (let* ((dir "./Cache/")
	    (_ (make-directory dir t))
	    (filename (concat dir (format-time-string "%Y%m%d_%H%M%S_")
				(make-temp-name "") ".png")))
      ;; check if the wayland executable exist or x11 screen shot utility
    (call-process-shell-command
    (format "flameshot gui -r > %s" (shell-quote-argument filename)))
    (insert (concat "[[" filename "]]"))
  (org-display-inline-images))))


;; Org-mode and basic LaTeX/PDF support
(require 'org)
(require 'ox-latex)
(setq org-startup-with-latex-preview nil) ;; auto preview LaTeX

;; Optional: LaTeX class customization for styling
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

(add-to-list 'org-latex-classes '("apa6"
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


(assoc "apa6" org-latex-classes)
(assoc "article" org-latex-classes)
(assoc "cv" org-latex-classes)

(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 2.0))

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))

(let* ((dvisvgm-conf '(dvisvgm
            :programs ("latex" "dvisvgm")
            :description "dvi → svg"
            :message "Install TeX (latex) and dvisvgm."
            :image-input-type "dvi"
            :image-output-type "svg"
            :image-size-adjust (1.5 . 1.5)
            :latex-compiler ("latex -interaction=nonstopmode -output-directory %o %f")
            :image-converter ("dvisvgm --no-fonts --exact-bbox -o %O %f"))))
(with-eval-after-load 'org
    ;; Ensure dvisvgm entry exists (merge, don't clobber others)
    (setq org-preview-latex-process-alist
          (let ((alist org-preview-latex-process-alist))
            (if (assoc 'dvisvgm alist) alist (cons dvisvgm-conf alist))))
    ;; Prefer dvisvgm, fallback to imagemagick if dvisvgm missing
    (setq org-preview-latex-default-process
          (if (executable-find "dvisvgm") 'dvisvgm 'imagemagick)))
;; Nuke stale buffer-local defaults that still point to dvipng
(add-hook 'org-mode-hook
          (defun my/org-force-dvisvgm ()
	    (let ((alist org-preview-latex-process-alist))
	    (let ((process org-preview-latex-default-process))
            (when (eq process 'dvipng)
              (setq-local org-preview-latex-default-process 'dvisvgm))
            (unless (assoc 'dvisvgm alist)
              (setq-local org-preview-latex-process-alist
                          (cons dvisvgm-conf alist))))))))

;; Org Export to PDF using pdflatex (or xelatex if you prefer)
(setq org-latex-compiler "pdflatex") ;; or xelatex
(setq org-latex-pdf-process '("pdflatex -interaction nonstopmode -output-directory %o %f"
			      "pdflatex -interaction nonstopmode -output-directory %o %f"))

(with-eval-after-load 'ox-html
  (setq org-html-mathjax-options
        (cons '(scale . "200")
              (assq-delete-all 'scale org-html-mathjax-options))))

;; Enable image display in org-mode
(setq org-startup-with-inline-images t)
(setq org-image-actual-width '(800)) ;; limit image width

;; Allow pasting images (if you already have a script)
;; Just make sure org-download is installed if needed:
;; (use-package org-download :ensure t)

;; Optional: auto refresh inline images after paste
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
