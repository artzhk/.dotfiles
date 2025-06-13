"" LSP
" TODO: Put the lsps in the separate file
if executable('sql-language-server')
	au User lsp_setup call lsp#register_server({
				\ 'name': 'sql-language-server',
				\ 'cmd': {server_info->['sql-language-server', 'up', '--method', 'stdio']},
				\ 'allowlist': ['sql'],
				\ })
endif


if executable('~/lib/clang/bin/clangd')
	au User lsp_setup call lsp#register_server({
				\ 'name': 'clang',
				\ 'cmd': {server_info->['~/lib/clang/bin/clangd', '--background-index', '--clang-tidy', 'stdio']},
				\ 'allowlist': ['h', 'c', 'hpp', 'cpp'],
				\ })
endif

if executable('typescript-language-server')
	" npm i -g typescript-language-server

	au User lsp_setup call lsp#register_server({
				\ 'name': 'vscode-eslint-language-server',
				\ 'cmd': {server_info->['vscode-eslint-language-server', '--stdio']},
				\ 'allowlist': ['ts', 'js', 'javascriptreact', 'typescriptreact', 'typescript', 'javascript', 'jsx', 'tsx'],
				\ })
	au User lsp_setup call lsp#register_server({
				\ 'name': 'typescript-language-server',
				\ 'cmd': {server_info->['typescript-language-server', '--stdio']},
				\ 'allowlist': ['ts', 'js', 'javascriptreact', 'typescriptreact', 'typescript', 'javascript', 'jsx', 'tsx'],
				\ })

	let g:lsp_diagnostics_highlights_delay = 50
	let g:lsp_preview_doubletap = [function('lsp#ui#vim#output#focuspreview')]
endif

if executable('pylsp')
	" pip install python-lsp-server
	au User lsp_setup call lsp#register_server({
				\ 'name': 'pylsp',
				\ 'cmd': {server_info->['pylsp']},
				\ 'allowlist': ['python', 'py'],
				\ })
endif


