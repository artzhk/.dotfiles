

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
