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

" Ruby (ruby-lsp via mise)
if executable('mise') && filereadable(expand('~/lib/ruby-lsp/exe/ruby-lsp')) && filereadable(expand('./.ruby-version'))
  au User lsp_setup call lsp#register_server({
        \ 'name': 'ruby-lsp',
        \ 'cmd': {server_info->['mise', 'x', '--', expand('~/lib/ruby-lsp/exe/ruby-lsp')]},
        \ 'allowlist': ['ruby', 'rb'],
        \ })
endif

if executable('typescript-language-server')

	" npm i -g typescript-language-server
	au User lsp_setup call lsp#register_server({
				\ 'name': 'typescript-language-server',
				\ 'cmd': {server_info->['/usr/bin/typescript-language-server', '--stdio']},
				\ 'allowlist': ['ts', 'js', 'javascriptreact', 'typescriptreact', 'typescript', 'javascript', 'jsx', 'tsx'],
				\ })

endif

if executable('pylsp')
	" pip install python-lsp-server
	au User lsp_setup call lsp#register_server({
				\ 'name': 'pylsp',
				\ 'cmd': {server_info->['pylsp']},
				\ 'allowlist': ['python', 'py'],
				\ })
endif

