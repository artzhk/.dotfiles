;; -*- lexical-binding: t; -*-
;; That seems to do stuff...
;; keeps indenting
(dolist (hook '(csharp-mode-hook csharp-ts-mode-hook))
  (add-hook hook (lambda () (setq-local indent-tabs-mode nil tab-width 4)))
  (add-hook hook #'eglot-ensure))

;;; LSP ------------------------------------------------------------------------
;; Two servers, picked per connection by `dotnet-lsp-server':
;;  - csharp-ls (default): dotnet tool install --global csharp-ls
;;  - Roslyn, the same server VS Code and nvim's roslyn.nvim use, via the
;;    official `roslyn-language-server` wrapper (dotnet tool install --global
;;    roslyn-language-server --prerelease). Diagnostics are pull-only, so it
;;    needs eglot >= 1.20 (see lsp.el).
;; `C-c L' switches between them and restarts the server.
(require 'eglot)

(defcustom dotnet-lsp-server 'csharp-ls
  "Language server used for C# buffers."
  :type '(choice (const csharp-ls) (const roslyn))
  :group 'eglot)

(defclass eglot-roslyn (eglot-lsp-server) ()
  :documentation "Roslyn (roslyn-language-server) connection.")

(defun dotnet--solution-file ()
  "Return the absolute path of the .slnx/.sln for the current project, or nil."
  (let* ((root (or (when-let* ((proj (project-current))) (project-root proj))
                   default-directory))
         (find (lambda (dir)
                 (car (directory-files dir t "\\.slnx?\\'"))))
         (dir (or (and (funcall find root) root)
                  (locate-dominating-file default-directory find))))
    (and dir (funcall find (expand-file-name dir)))))

(defun dotnet--eglot-contact (_interactive)
  "Eglot contact for C# buffers, according to `dotnet-lsp-server'."
  (let ((sln (dotnet--solution-file)))
    (pcase dotnet-lsp-server
      ('roslyn
       `(eglot-roslyn "roslyn-language-server" "--stdio" "--logLevel" "Warning"
                      ;; With a solution, it's opened explicitly in
                      ;; `dotnet--roslyn-open-solution'
                      ,@(unless sln '("--autoLoadProjects"))))
      (_
       `("csharp-ls" ,@(when sln (list "--solution" sln)))))))

(add-to-list 'eglot-server-programs
             '((csharp-mode csharp-ts-mode) . dotnet--eglot-contact))

(defun dotnet-switch-lsp ()
  "Toggle `dotnet-lsp-server' between csharp-ls and Roslyn, then restart eglot."
  (interactive)
  (setq dotnet-lsp-server (if (eq dotnet-lsp-server 'roslyn) 'csharp-ls 'roslyn))
  (when-let* ((server (eglot-current-server)))
    (eglot-shutdown server))
  (eglot-ensure)
  (message "C# LSP: %s" dotnet-lsp-server))

(with-eval-after-load 'csharp-mode
  (keymap-set csharp-mode-map "C-c L" #'dotnet-switch-lsp))
(with-eval-after-load 'csharp-ts-mode
  (keymap-set csharp-ts-mode-map "C-c L" #'dotnet-switch-lsp))

;;; Roslyn ---------------------------------------------------------------------
(defun dotnet--roslyn-open-solution (server)
  "Tell a Roslyn SERVER which solution to load."
  (when (cl-typep server 'eglot-roslyn)
    (let ((default-directory (project-root (eglot--project server))))
      (when-let* ((sln (dotnet--solution-file)))
        (message "Roslyn: opening %s" (file-name-nondirectory sln))
        (jsonrpc-notify server :solution/open
                        (list :solution (eglot-path-to-uri sln)))))))
(add-hook 'eglot-connect-hook #'dotnet--roslyn-open-solution)

(cl-defmethod eglot-handle-notification
  ((_server eglot-roslyn) (_method (eql workspace/projectInitializationComplete))
   &key &allow-other-keys)
  (message "Roslyn: projects loaded"))

(cl-defmethod eglot-handle-notification
  ((_server eglot-roslyn) (_method (eql window/_roslyn_showToast))
   &key message &allow-other-keys)
  (message "Roslyn: %s" message))

(defun dotnet--roslyn-restore (server &optional paths)
  "Ask Roslyn SERVER to restore PATHS (a vector of project files; nil = all)."
  (message "Roslyn: restoring %s..."
           (if paths (format "%d project(s)" (length paths)) "solution"))
  (jsonrpc-async-request
   server :workspace/_roslyn_restore
   (list :projectFilePaths (or paths []))
   :success-fn (lambda (_) (message "Roslyn: restore finished"))
   :error-fn (lambda (err) (message "Roslyn: restore failed: %s"
                                    (plist-get err :message)))))

(cl-defmethod eglot-handle-request
  ((server eglot-roslyn) (_method (eql workspace/_roslyn_projectNeedsRestore))
   &key projectFilePaths &allow-other-keys)
  (when (y-or-n-p (format "Roslyn: restore %d project(s)? "
                          (length projectFilePaths)))
    (dotnet--roslyn-restore server projectFilePaths))
  nil)

(defun dotnet-roslyn-restore ()
  "Restore all projects of the current Roslyn workspace."
  (interactive)
  (let ((server (eglot-current-server)))
    (unless (cl-typep server 'eglot-roslyn)
      (user-error "Not connected to Roslyn (see `dotnet-switch-lsp')"))
    (dotnet--roslyn-restore server)))

;; Section names are hardcoded server-side in Roslyn itself, so they're
;; identical to nvim's lspconfig.lua settings for the same server.
(setq-default
 eglot-workspace-configuration
 (append
  eglot-workspace-configuration
  '(:csharp|inlay_hints
    (:csharp_enable_inlay_hints_for_implicit_object_creation t
     :csharp_enable_inlay_hints_for_implicit_variable_types t
     :csharp_enable_inlay_hints_for_lambda_parameter_types t
     :csharp_enable_inlay_hints_for_types t
     :dotnet_enable_inlay_hints_for_indexer_parameters t
     :dotnet_enable_inlay_hints_for_literal_parameters t
     :dotnet_enable_inlay_hints_for_object_creation_parameters t
     :dotnet_enable_inlay_hints_for_other_parameters t
     :dotnet_enable_inlay_hints_for_parameters t
     :dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix t
     :dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name t
     :dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent t)
    :csharp|code_lens
    (:dotnet_enable_references_code_lens t
     :dotnet_enable_tests_code_lens t)
    :csharp|completion
    (:dotnet_show_completion_items_from_unimported_namespaces t
     :dotnet_show_name_completion_suggestions t)
    :csharp|background_analysis
    (:background_analysis_dotnet_compiler_diagnostics_scope "fullSolution")
    :csharp|symbol_search
    (:dotnet_search_reference_assemblies t))))

;; Roslyn reports "Fix all" and grouped/nested code actions
;; https://github.com/neovim/nvim-lspconfig/blob/master/lsp/roslyn_ls.lua
(defun dotnet--roslyn-apply-action (server action)
  "Apply resolved roslyn ACTION's :edit, then recurse into its :command."
  (let ((edit (plist-get action :edit))
        (command (plist-get action :command)))
    (when edit (eglot--apply-workspace-edit server edit this-command))
    (when command (eglot-execute server command))))

(defun dotnet--roslyn-fix-all (server command)
  "Handle the roslyn.client.fixAllCodeAction client command."
  (let* ((arg (aref (plist-get command :arguments) 0))
         (scope (completing-read "Fix All scope: "
                                 (append (plist-get arg :FixAllFlavors) nil)
                                 nil t)))
    (dotnet--roslyn-apply-action
     server
     (eglot--request server :codeAction/resolveFixAll
                     (list :title (plist-get command :title)
                           :data arg
                           :scope scope)))))

(defun dotnet--roslyn-nested-action (server action)
  "Recursively resolve/select/apply a roslyn.client.nestedCodeAction tree."
  (cond
   ((vectorp action)
    (dotnet--roslyn-nested-select server (append action nil)))
   ((and (plist-get action :data)
         (not (plist-get action :edit))
         (not (plist-get action :command)))
    (dotnet--roslyn-nested-action
     server (eglot--request server :codeAction/resolve action)))
   (t
    (let ((nested (append (plist-get action :NestedCodeActions) nil)))
      (if nested
          (dotnet--roslyn-nested-select server nested)
        (dotnet--roslyn-apply-action server action))))))

(defun dotnet--roslyn-nested-select (server actions)
  "Recurse directly if ACTIONS has one entry, else prompt for one."
  (if (null (cdr actions))
      (dotnet--roslyn-nested-action server (car actions))
    (let* ((titled (mapcar (lambda (a)
                             (cons (or (plist-get a :title)
                                       (plist-get (plist-get a :command) :title)
                                       "Unnamed action")
                                   a))
                           actions))
           (choice (completing-read "Select code action: " titled nil t)))
      (dotnet--roslyn-nested-action server (cdr (assoc choice titled))))))

(cl-defmethod eglot-execute :around ((server eglot-roslyn) action)
  (pcase (plist-get action :command)
    ("roslyn.client.fixAllCodeAction" (dotnet--roslyn-fix-all server action))
    ("roslyn.client.nestedCodeAction"
     (dotnet--roslyn-nested-action server (aref (plist-get action :arguments) 0)))
    (_ (cl-call-next-method))))

;;; Debugging ------------------------------------------------------------------
(when (executable-find "netcoredbg")
  (use-package dape :ensure t)
  (with-eval-after-load 'dape
    ;; PBD.Core.Web — dotnet run --project ./src/PBD.Core.Web/... -lp https -c Development
    ;; Paths are relative to the project root (via dape-cwd), so this works from
    ;; the main checkout or any worktree copy, not just one hardcoded location.
    (unless (assq 'pbd-web dape-configs)
      (push
       `(pbd-web
         modes (csharp-mode csharp-ts-mode)
         ensure dape-ensure-command
         command "netcoredbg"
         command-args ["--interpreter=vscode"]
         :request "launch"
         :cwd (expand-file-name "src/PBD.Core.Web" (dape-cwd))
         :program (car (file-expand-wildcards
                        (expand-file-name "src/PBD.Core.Web/bin/Development/*/PBD.Core.Web.dll"
                                          (dape-cwd))))
         :env (:ASPNETCORE_ENVIRONMENT "Development"
               :ASPNETCORE_URLS "https://pbd-core-web.dev.localhost:44337;http://localhost:51100")
         :stopAtEntry nil)
       dape-configs))

    ;; Generic launch config for any project — prompts for the built dll,
    ;; mirroring nvim's ~/.config/nvim/lua/lazy-setup/configs/dap/cs_dap.lua.
    (unless (assq 'dotnet-launch dape-configs)
      (push
       `(dotnet-launch
         modes (csharp-mode csharp-ts-mode)
         ensure dape-ensure-command
         command "netcoredbg"
         command-args ["--interpreter=vscode"]
         :request "launch"
         :program (read-file-name "Path to dll: " (expand-file-name "bin/Debug/" (dape-cwd)))
         :cwd (dape-cwd)
         :stopAtEntry nil)
       dape-configs))))
