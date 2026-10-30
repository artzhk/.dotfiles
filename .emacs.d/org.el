(use-package org
  :config (global-set-key (kbd "C-c o l") #'org-store-link)
  (global-set-key (kbd "C-c o a") #'org-agenda)
  (global-set-key (kbd "C-c o c") #'org-capture)
  (setq org-startup-indented           t
        org-startup-with-inline-images t
        org-startup-with-latex-preview nil
        org-image-actual-width         '(800))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN_PROGRESS(i!)" "|" "DONE(d!)")
          (sequence "IDEA(e)" "|" "DROPPED(x@)")
          ;; Follow-ups from notes: things to learn, not things to do.
          (sequence "EXPLORE(p)" "EXPLORING(o!)" "|" "EXPLORED(v!)" "PARKED(z@)")
          (sequence "ISSUE(I)" "DIGGING(g!)" "FIXED(f!)"
                    "|" "VERIFIED(V!)" "WORKAROUND(W@)" "WONTFIX(N@)")))

  (setq org-todo-keyword-faces
        '(("TODO"        . org-warning)
          ("NEXT"        . (:foreground "cyan"   :weight bold))
          ("IN_PROGRESS" . (:foreground "orange" :weight bold))
          ("IDEA"        . (:foreground "grey"   :slant italic))
          ("DROPPED"     . (:foreground "grey"   :strike-through t))
          ("EXPLORE"     . (:foreground "medium purple" :weight bold))
          ("EXPLORING"   . (:foreground "orchid" :weight bold))
          ("EXPLORED"    . (:foreground "grey"))
          ("PARKED"      . (:foreground "grey"   :slant italic))))

  ;; Stable links: C-c o l on a heading stores an id: link (creating :ID: if needed),
  ;; so notes can move between directories without breaking links.
  (require 'org-id)
  (setq org-id-link-to-org-use-id 'create-if-interactive)

  ;; Tag hierarchy: searching a group tag also matches its members
  ;; (e.g. "math" matches headings tagged :linear:).
  (setq org-tag-persistent-alist
        '((:startgrouptag) ("math")     (:grouptags) ("linear") ("probability") ("complexity") (:endgrouptag)
          (:startgrouptag) ("security") (:grouptags) ("crypto") (:endgrouptag)
          (:startgrouptag) ("ai")       (:grouptags) ("ml") ("nlp") (:endgrouptag)
          (:startgrouptag) ("kind")     (:grouptags) ("concept") ("definition") ("law") ("theorem")
          ("principle") ("algorithm") (:endgrouptag)
          (:startgrouptag) ("uni")      (:grouptags) ("gp") ("pwd") ("mlann") ("nlp") ("pcaiot")
          ("dadt") ("awd") ("3d") ("ads2") ("final") (:endgrouptag)))

  ;; Capture an explore item from anywhere; ORIGIN links back to where it came from.
  (setq org-capture-templates
        '(("x" "Explore item" entry
           (file+headline "~/Programming/org-space/Personal/explore.org" "Inbox")
           "* EXPLORE %?\n:PROPERTIES:\n:ORIGIN:   %a\n:CREATED:  %U\n:END:\n")
          ("b" "Issue / bug" entry (file+headline "~/Programming/org-space/SWE/issues.org" "Open")
           "* ISSUE %^{Title} %^g
:PROPERTIES:
:ID:       %(org-id-new)
:CREATED:  %U
:ORIGIN:   %a
:SYSTEM:   %^{System/component}
:VERSION:  %^{Version/commit}
:SEVERITY: %^{Severity|Minor|Major|Critical|Blocking|Inconsequential}
:END:
** Failure (symptom, verbatim)
#+begin_example
%i
#+end_example
** Environment
** Reproduction (minimal, deterministic)
** Attempts
** Fault (root cause)
** Corrective action
** Verification
** Lessons -> card / EXPLORE
" :clock-in t :clock-keep t :empty-lines 1)
          ("a" "Attempt (on clocked issue)" entry (clock)
           "*** %U %^{Hypothesis}
- Action   :: %?
- Expected ::
- Observed ::
- Verdict  :: %^{Verdict|refuted|confirmed|inconclusive}":clock-in t :clock-keep t :empty-lines 1)))

  ;; Refile inbox items into a note's "Explore" heading: C-c C-w, then type "file/heading".
  (setq org-refile-targets                     '((org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path            'file
        org-outline-path-complete-in-steps     nil
        org-refile-allow-creating-parent-nodes 'confirm)

  ;; Agenda file list lives in agenda-files (one path or directory per line),
  ;; like project.el's projects file. C-c [ / C-c ] add/remove the current file.
  (setq org-agenda-files (expand-file-name "agenda-files" my/config-dir))
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
           ((org-agenda-prefix-format "  %-12:c")))
          ("x" "Explore"
           ((todo "EXPLORING" ((org-agenda-overriding-header "Exploring now")))
            (todo "EXPLORE"   ((org-agenda-overriding-header "To explore (priority, then topic)")
                               (org-agenda-sorting-strategy '(priority-down category-up)))))
           ((org-agenda-prefix-format "  %-10:c %b")))
          ("K" "Knowledge cards" tags "+kind-TODO=\"EXPLORE\"-TODO=\"EXPLORING\""
           ((org-agenda-prefix-format   "  %-10:c ")
            (org-agenda-sorting-strategy '(category-up alpha-up))))
          ("u" "Uni (virtual folder)" tags "+uni+LEVEL=1"
           ((org-agenda-prefix-format "  %-10:c ")))
          ("U" "Active coursework" tags-todo "+uni+active"
           ((org-agenda-prefix-format "  %-10:c %b")))
          ("b" "Open issues" todo "ISSUE|DIGGING|FIXED"
           ((org-agenda-sorting-strategy '(priority-down category-up))))))
  :hook (org-babel-after-execute-hook . org-display-inline-images)
  :ensure t)
