"" LSP
" TODO: Put the lsps in the separate file
if executable('sql-language-server')
	au User lsp_setup call lsp#register_server({
				\ 'name': 'sql-language-server',
				\ 'cmd': {server_info->['sql-language-server', 'up', '--method', 'stdio']},
				\ 'allowlist': ['sql'],
				\ })
endif


" make + qfilst
if executable('clangd')
	au User lsp_setup call lsp#register_server({
				\ 'name': 'clang',
				\ 'cmd': {server_info->['clangd', '--background-index', '--clang-tidy']},
				\ 'allowlist': ['h', 'c', 'hpp', 'cpp'],
				\ })
endif

if executable('typescript-language-server')

	" npm i -g typescript-language-server
	au User lsp_setup call lsp#register_server({
				\ 'name': 'typescript-language-server',
				\ 'cmd': {server_info->['typescript-language-server', '--stdio']},
				\ 'allowlist': ['ts', 'js', 'javascriptreact', 'typescriptreact', 'typescript', 'javascript', 'jsx', 'tsx'],
				\ })

	" npm i -g vscode-eslint-language-server
"	au User lsp_setup call lsp#register_server({
"				\ 'name': 'vscode-eslint-language-server',
"				\ 'cmd': {server_info->['vscode-eslint-language-server']},
"				\ 'allowlist': ['ts', 'js', 'javascriptreact', 'typescriptreact', 'typescript', 'javascript', 'jsx', 'tsx'],
"				\ })

endif

if executable('pylsp')
	" pip install python-lsp-server
	au User lsp_setup call lsp#register_server({
				\ 'name': 'pylsp',
				\ 'cmd': {server_info->['pylsp']},
				\ 'allowlist': ['python', 'py'],
				\ })
endif

