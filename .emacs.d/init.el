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
(require 'copilot)
(global-set-key (kbd "C-c C-p") 'copilot-accept-completion)

;; Magit melpa
(require 'exec-path-from-shell)
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")

(setq evil-want-C-u-scroll t)
(setq evil-want-C-a-scroll t)
;;(setq evil-mode t)
(setq evil-undo-system 'undo-redo)

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

(setq org-agenda-files (directory-files-recursively "~/org-space/" "\\.org$"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("019184a760d9747744783826fcdb1572f9efefc5c19ed43b6243e66638fb9960"
     default))
 '(package-selected-packages
   '(## compat copilot dash ein eink-theme evil helm helm-bibtex html2org
	latex-table-wizard lsp-mode magit markdown-mode
	markdown-preview-mode org-fragtog org-modern org-noter org-ref
	org-roam org-roam-bibtex pdf-tools)))

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
  (let* ((dir "./Cache/")
	  (_ (make-directory dir t))
	  (filename (concat dir (format-time-string "%Y%m%d_%H%M%S_")
			    (make-temp-name "") ".png")))
  ;;(call-process "wl-paste" nil filename nil "-t" "image/png")
(call-process-shell-command
 (format "wl-paste -t image/png > %s" (shell-quote-argument filename)))
  (insert (concat "[[" filename "]]"))
  (org-display-inline-images)))

;; Latex preview configs
(setq org-preview-latex-process-alist
      '((dvipng :programs ("latex" "dvipng")
                :description "dvi > png"
                :message "you need to install latex and dvipng."
                :image-input-type "dvi"
                :image-output-type "png"
                :image-size-adjust (2.0 . 2.0) ;; scale value
                :latex-compiler ("latex -interaction nonstopmode -output-directory %o %f")
                :image-converter ("dvipng -D 300 -T tight -o %O %f"))))

;; Org-mode and basic LaTeX/PDF support
(require 'org)
(require 'ox-latex)
(setq org-startup-with-latex-preview t) ;; auto preview LaTeX

;; Org Export to PDF using pdflatex (or xelatex if you prefer)
(setq org-latex-compiler "pdflatex") ;; or xelatex
(setq org-latex-pdf-process '("pdflatex -interaction nonstopmode -output-directory %o %f"
			      "pdflatex -interaction nonstopmode -output-directory %o %f"))

;; Enable image display in org-mode
(setq org-startup-with-inline-images t)
(setq org-image-actual-width '(300)) ;; limit image width

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

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))


(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
