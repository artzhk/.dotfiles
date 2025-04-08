;; (load-theme 'tango-dark t)
(load-theme 'modus-operandi-tinted t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(display-line-numbers-mode 1)

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-todo-keywords
      '((sequence "TODO" "IN_PROGRESS" "DONE")))
