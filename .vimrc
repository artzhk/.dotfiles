set langmenu=en_US
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

let $FZF_DEFAULT_COMMAND=$FZF_DEFAULT_COMMAND
let $FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS . '--reverse --bind "alt-a:select-all,alt-d:deselect-all" --tiebreak=end,pathname,chunk'

"" termguicolors fix
"let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set autoread
set hidden
set cursorline
set clipboard=unnamedplus
set ignorecase
set encoding=utf8
set shiftwidth=8 tabstop=8 softtabstop=0 noexpandtab smartindent
set showmode
set laststatus=2
set statusline=%<%F\ %h%w%m%r%=%-14.(%l,%c%V%)\ %P
set colorcolumn=120
set textwidth=120
set number
"set termguicolors
set scrolloff=8
set nowrap

" ripgrep to qflist instead of fancy stupid plugins
set grepprg=rg\ --vimgrep
set grepformat^=%f:%l:%c:%m

syntax on

set smartcase
set incsearch

" Inbuild Keymappings
let mapleader=" "

" qflist
" Rg search no brackets to qflist
" usage :Rgq <pattern> <folder>
" is that way more better than any telescope bloated shit...?
command! -nargs=* Rgq execute 'grep! ' . join([<f-args>])
" https://stackoverflow.com/questions/70569858/neovim-e81-using-sid-not-in-a-script-context
func <SID>prompt_rg()
	let pattern = input("Pattern: ")
	if pattern == ''
		return
	endif
	let folder = input("Folder: ", getcwd())
	if folder == ''
		let folder = getcwd()
	endif
	execute 'Rgq ' . pattern . ' ' . folder
endfunc
nnoremap <silent><C-b> :cp<CR>
nnoremap <silent><C-s> :cn<CR>
nnoremap <silent><leader>lq :copen<CR>
nnoremap <silent><leader>rg :call <SID>prompt_rg()<CR>

" qflist wrap
augroup quickfix
	autocmd!
	autocmd FileType qf setlocal wrap
augroup END

" fzf
"" fzf on current dir
nnoremap <silent><leader>cd <cmd>execute 'Files ' . fnameescape(expand('%:p:h'))<CR>

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

nnoremap <silent><leader>nr :set rnu!<CR>

" Man pages
"" how to open the buf to be readonly?
command -nargs=* Man new | 0read !man <args> | col -b
nnoremap <silent><leader>h :Man <C-R><C-W><CR>

" TODO: Better marks list
" command Mlist marks | grep -P "^[A-Z]"
" nnoremap <silent><leader>ml :Man <C-R><C-W><CR>

function s:copy_filepath()
	let file = expand('%:p')
	let @" = file
	let @+ = file
	echo 'Copied filepath: ' . file
endfunction

function s:copy_filename()
	let file = expand('%:t')
	" write to the tmp/buffer.txt file
	" write to the register
	let @" = file
	let @+ = file
	echo 'Copied filename: ' . file
endfunction

" Yank to system external buffer
command -nargs=* Cp call s:copy_filepath()
command -nargs=* Cf call s:copy_filename()
nnoremap <silent><leader>CF :Cf<CR>
nnoremap <silent><leader>CP :Cp<CR>

" No yanking options
vnoremap <silent><leader>p "_dP
nnoremap <silent><leader>p V"_dP
nnoremap <silent><leader>d "_d

" Plugin remaps
nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR>
nnoremap <silent><leader>du :Files<CR>
nnoremap <silent><leader>b :Buffers<CR>

"" FZF config
function! s:build_quickfix_list(lines)
	call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
	copen
	cc
endfunction
let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['hidden,down,70%', 'ctrl-/']
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 1, 'xoffset': 1, 'border': 'sharp' } }
let g:fzf_action = {
			\ 'ctrl-s': function('s:build_quickfix_list'),
			\}
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files', {'window': { 'width': 0.3, 'height': 1, 'xoffset': 2 }})

"" Undotree
nnoremap <silent><leader>u :UndotreeToggle<CR>

"" Autoformat
nnoremap <leader>f :Autoformat<CR>

"" Copilot
imap <silent><script><expr> <C-E> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" Vim Go
let g:go_def_mode="gopls"
let g:go_info_mode="gopls"
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_fmt_fail_silently = 1
let g:go_list_type = "quickfix"
set completeopt-=preview
command GLB GoBuild

" LSP setup
source ~/.dotfiles/vim/lsp.vim

function! s:on_lsp_buffer_enabled() abort
	setlocal omnifunc=lsp#complete
	setlocal signcolumn=yes
	if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
	nmap <buffer> gd <plug>(lsp-definition)
	nmap <buffer> gs <plug>(lsp-document-symbol-search)
	nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
	nmap <buffer> gr <plug>(lsp-references)
	nmap <buffer> gi <plug>(lsp-implementation)
	nmap <buffer> gt <plug>(lsp-type-definition)
	nnoremap <buffer><leader>va <plug>(lsp-code-action)
	nnoremap <buffer><leader>vq :LspCodeAction quickfix<CR>
	nmap <buffer> <leader>rn <plug>(lsp-rename)
	nmap <buffer> [e <plug>(lsp-previous-diagnostic)
	nmap <buffer> ]e <plug>(lsp-next-diagnostic)
	nmap <buffer> K <plug>(lsp-hover)
	nmap <buffer> dq <plug>(lsp-document-diagnostics)
	nnoremap <buffer> <expr><c-j> lsp#scroll(+4)
	nnoremap <buffer> <expr><c-k> lsp#scroll(-4)

	let g:lsp_format_sync_timeout = 50
	let g:lsp_diagnostics_virtual_text_align = "right"
	let g:lsp_preview_doubletap = [function('lsp#ui#vim#output#focuspreview')]
	let g:lsp_preview_float = 0

	" Put diagnostics in the quickfix list
	let g:lsp_diagnostics_quickfix = 1

	autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
	au!
	" call s:on_lsp_buffer_enabled only for languages that has the server registered.
	autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Automatic Plug install
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
	silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() }, 'options':  '',}
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'mbbill/undotree'
Plug 'prabirshrestha/vim-lsp'
Plug 'vim-autoformat/vim-autoformat'
Plug 'github/copilot.vim'

call plug#end()

" Additional per mashine customizations
source ~/.profile.vim
