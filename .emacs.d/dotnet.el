;; That seems to do stuff...
;; keeps indenting
(dolist (hook '(csharp-mode-hook csharp-ts-mode-hook))
  (add-hook hook (lambda () (setq-local indent-tabs-mode nil tab-width 4))))

;; LSP — Roslyn, the same server VS Code and nvim's roslyn.nvim use, via the
;; official `roslyn-language-server` wrapper (dotnet tool install --global
;; roslyn-language-server --prerelease). Unlike the raw
;; Microsoft.CodeAnalysis.LanguageServer.dll, this wrapper speaks plain LSP
;; (initialize/didOpen + --autoLoadProjects), so eglot can drive it directly
;; with no custom "solution/open" handshake.
(when (executable-find "roslyn-language-server")
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((csharp-mode csharp-ts-mode)
                   "roslyn-language-server" "--stdio" "--autoLoadProjects"
                   "--logLevel" "Warning"))
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
        (when edit (eglot--apply-workspace-edit edit this-command))
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

    (cl-defmethod eglot-execute :around (server action)
      (pcase (plist-get action :command)
        ("roslyn.client.fixAllCodeAction" (dotnet--roslyn-fix-all server action))
        ("roslyn.client.nestedCodeAction"
         (dotnet--roslyn-nested-action server (aref (plist-get action :arguments) 0)))
        (_ (cl-call-next-method))))))

(when (executable-find "netcoredbg")
  (ensure-package 'dape)
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
     dape-configs)))
