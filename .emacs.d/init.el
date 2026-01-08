;;(load-theme 'tango-dark t)
(load-theme 'adwaita t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)

;; Jypiter support
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Copilot suggestion
(require 'copilot-chat)
(global-set-key (kbd "C-c C-p") 'copilot-accept-completion)

;; Magit melpa
(require 'exec-path-from-shell)

;;(setq evil-mode t)
(setq evil-undo-system 'undo-redo)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-a-scroll t)

;; Vim mode
(require 'evil)
(evil-mode)

(global-visual-line-mode)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(set-frame-font "IosevkaTerm Nerd Font Mono 20" nil )

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
   '("/Users/artem/org-space/.dotfiles/.local/scripts/make_wt.org"
     "/Users/artem/org-space/de/words.org"
     "/Users/artem/org-space/exports/GP.org"
     "/Users/artem/org-space/exports/PWD CM2015.org"
     "/Users/artem/org-space/exports/global-dirs.org"
     "/Users/artem/org-space/exports/heap_vis_tui.org"
     "/Users/artem/org-space/exports/oath-cli.org"
     "/Users/artem/org-space/exports/org-space.org"
     "/Users/artem/org-space/exports/proj.org"
     "/Users/artem/org-space/network/essentials.org"
     "/Users/artem/org-space/repos/PBD_TEST/linux-setup.org"
     "/Users/artem/org-space/repos/PBD_WT/1264-intern.org"
     "/Users/artem/org-space/repos/PBD_WT/1277.org"
     "/Users/artem/org-space/repos/PBD_WT/1352_intern.org"
     "/Users/artem/org-space/repos/PBD_WT/5786.org"
     "/Users/artem/org-space/repos/PBD_WT/5974.org"
     "/Users/artem/org-space/repos/PBD_WT/6009.org"
     "/Users/artem/org-space/repos/PBD_WT/Automatisations.org"
     "/Users/artem/org-space/repos/PBD_WT/CustomConnections.org"
     "/Users/artem/org-space/repos/PBD_WT/GraphStuff.org"
     "/Users/artem/org-space/repos/PBD_WT/customTemplatesCustomisation.org"
     "/Users/artem/org-space/repos/ascii-vis/idea.org"
     "/Users/artem/org-space/repos/drafts/go/todo.org"
     "/Users/artem/org-space/repos/full-width/idea.org"
     "/Users/artem/org-space/repos/global-dirs/idea.org"
     "/Users/artem/org-space/repos/heap_vis_tui/idea.org"
     "/Users/artem/org-space/repos/oath-cli/idea.org"
     "/Users/artem/org-space/repos/packet-tracking/idea.org"
     "/Users/artem/org-space/repos/proj/todo.org"
     "/Users/artem/org-space/vaults/main/Compilers/compilers.org"
     "/Users/artem/org-space/vaults/main/CyberSecurity/Steganography/Steganography.org"
     "/Users/artem/org-space/vaults/main/CyberSecurity/cybersecurity.org"
     "/Users/artem/org-space/vaults/main/Linux/Understanding.org"
     "/Users/artem/org-space/vaults/main/ML/NLP/natural-language-processing.org"
     "/Users/artem/org-space/vaults/main/Math/Linear/Vectors.org"
     "/Users/artem/org-space/vaults/main/Math/Numbers/ImaginaryNumbers.org"
     "/Users/artem/org-space/vaults/main/Math/Trigonometry/FT.org"
     "/Users/artem/org-space/vaults/main/TCPIP/TCPIP.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W3/CollisionDetection.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W3/Forces.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W3/W3-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/CanvasManipulations.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/GradedAssignment-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/MidtermChecklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/Vectors.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W1-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W10-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W11-12-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W13-14-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W15-16-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W17-18-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W19-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W2-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W4-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W5-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W6-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W7-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W8-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/W9-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/GP/midterm-report.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/18-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/Midterm.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/Programming with Data.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W1-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W10-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W11-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W12-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W13-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W14-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W15-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W16-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W17-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W19-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W2-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W3-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W4-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W5-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W6-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W7-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W8-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/W9-Checklist.org"
     "/Users/artem/org-space/vaults/main/Uni/PWD CM2015/midterm-report.org"
     "/Users/artem/org-space/vaults/main/Uni/GP.org"
     "/Users/artem/org-space/cv.org"
     "/Users/artem/org-space/daily.org"
     "/Users/artem/org-space/ideas.org"
     "/Users/artem/org-space/todo.org"))
 '(package-selected-packages
   '(## compat copilot dash ein eink-theme evil helm helm-bibtex html2org
	latex-table-wizard lsp-mode magit markdown-mode
	markdown-preview-mode org-fragtog org-modern org-noter org-ref
	org-roam org-roam-bibtex ox-latex-subfigure pdf-tools)))

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
(setq org-startup-with-latex-preview t) ;; auto preview LaTeX

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

;; Enable image display in org-mode
(setq org-startup-with-inline-images t)
(setq org-image-actual-width '(800)) ;; limit image width

;; Allow pasting images (if you already have a script)
;; Just make sure org-download is installed if needed:
;; (use-package org-download :ensure t)

;; Optional: auto refresh inline images after paste
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)

;; Optional: LaTeX class customization for styling
(setq org-latex-classes
      '(("article"
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
         ("\\subsection{%s}" . "\\subsection*{%s}"))))

(setq org-latex-classes '(("apa6"
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
      ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(assoc "apa6" org-latex-classes)

(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 2.0))

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python3 . t)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
