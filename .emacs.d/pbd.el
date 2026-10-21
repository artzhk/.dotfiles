;;; pbd.el --- multi-compile targets for the PBD repo -*- lexical-binding: t; -*-

;; Projects are discovered from src/ and tests/ at run time, so nothing here
;; needs updating when projects are added or removed.
;;
;; multi-compile evaluates expression templates with `default-directory'
;; already bound to the target's dir (the repo root), so the pickers below
;; can use relative globs.

;; | Operator | Meaning | Example |
;; | = | Exact match | FullyQualifiedName=MyTest |
;; | != | Not equal | FullyQualifiedName!=MyTest |
;; | ~ | Contains | FullyQualifiedName~SomeService |
;; | !~ | Does not contain | FullyQualifiedName!~SomeService |
;; | & | AND | Name~Service&Name~Create |
;; | OR | Name~Create|Name~Update |

(use-package multi-compile
  :ensure t
  :preface
  (defun pbd-root ()
    "Repo root (per worktree), or nil outside the PBD repo."
    (locate-dominating-file default-directory "SLNX"))

  (defun pbd--front-root()
    (expand-file-name "EXAMPLE" (pbd-root)))

  
  (defun pbd--pick (prompt glob)
    (completing-read prompt (file-expand-wildcards glob) nil t))

  (defun pbd--test-filter ()
    "Empty input runs every test in the project."
    (let ((f (string-trim (read-string "filter (Class/Method, empty = all): "))))
      (if (string-empty-p f) ""
        ;; xunit v3 on MTP: matches the fully qualified method name, so a
        ;; class or namespace fragment works too.  Not `shell-quote-argument':
        ;; multi-compile inserts with non-literal `replace-match', so the
        ;; backslashes it produces would error.
        (format "--filter \"FullyQualifiedName~%s\"" f))))

  (defconst pbd--run-flags "-p:WarningLevel=0"
    "Common MSBuild flags for PBD commands.")
  (defun pbd--cmd (name cmd)
    (list name (concat cmd " %pbd-flags") '(pbd-root)))

  :config
  (defconst pbd--run-flags "-p:WarningLevel=0"
    "Common MSBuild flags for PBD commands.")
  (dolist (tpl '(("%pbd-src"    . (pbd--pick "src project: " "src/*/*.csproj"))
                 ("%pbd-test"   . (pbd--pick "test project: " "tests/*/*.Tests.csproj"))
                 ("%pbd-filter" . (pbd--test-filter))
                 ("%pbd-flags" . pbd--run-flags)))
    (add-to-list 'multi-compile-template tpl))

  (setq multi-compile-alist
               `(((pbd-root)
                 . (,(pbd--cmd "test"           "dotnet test --project %pbd-test %pbd-filter")
                    ,(pbd--cmd "test solution"  "dotnet test")
                    ,(pbd--cmd "build"          "dotnet build %pbd-src")
                    ,(pbd--cmd "build solution" "dotnet build")
                    ,(pbd--cmd "run"            "dotnet run --project %pbd-src")))
                ((pbd--front-root)
                 . (,(list "front-build" "bun run build" '(pbd--front-root)))))))


(global-set-key (kbd "C-c c m") #'multi-compile-run)

;;; pbd.el ends here
