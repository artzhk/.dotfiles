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
     dape-configs)))
