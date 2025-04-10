;; (load-theme 'tango-dark t)
(load-theme 'modus-operandi t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)

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

