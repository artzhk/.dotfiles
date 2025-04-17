set langmenu=en_US
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
"source ~/.dotfiles/vim/proper-murphy.vim
source ~/.dotfiles/vim/proper-retrobox.vim

" termguicolors fix
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set autoread
set cursorline
set clipboard=unnamed
set ignorecase
set encoding=utf8
set tabstop=8
set shiftwidth=8
set expandtab
set showmode
set laststatus=2
set statusline=%<%F\ %h%w%m%r%=%-14.(%l,%c%V%)\ %P
set colorcolumn=120

set smartcase
set incsearch

" Inbuild Keymappings
let mapleader=" "

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

nnoremap <silent><leader>nr :set rnu!<CR>
au CursorMoved * exe printf('match PmenuSbar /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" Man pages 
"" how to open the buf to be readonly?
command -nargs=* Man new | 0read !man <args> | col -b
nnoremap <silent><leader>h :Man <C-R><C-W><CR>

" TODO: Better marks list
" command Mlist marks | grep -P "^[A-Z]"
" nnoremap <silent><leader>ml :Man <C-R><C-W><CR>


" External buffer, might be overengeneered...
nnoremap <silent><leader>y :w! /tmp/buffer.txt<CR> ""y
vnoremap <silent><leader>y :w! /tmp/buffer.txt<CR> ""y
nmap <silent><leader>p !!cat /tmp/buffer.txt<CR>
vnoremap <silent><leader>p !cat /tmp/buffer.txt<CR>

set number
set termguicolors
set scrolloff=8
set background=light
syntax on

colorscheme retrobox

" Plugin remaps
nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR> 
nnoremap <silent><leader>f :Files<CR>
nnoremap <silent><leader>b :Buffers<CR>
nnoremap <silent><leader>u :UndotreeToggle<CR>


" Put the lsps in the separate file
if executable('sql-language-server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'sql-language-server',
        \ 'cmd': {server_info->['sql-language-server', 'up', '--method', 'stdio']},
        \ 'allowlist': ['sql'],
        \ })
endif

"" LSP 
if executable('pylsp')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python', 'py'],
        \ })
endif


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
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [e <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]e <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-k> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-j> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
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

Plug 'junegunn/fzf', { 'do': { -> fzf#install() }, 'options':  '--reverse  --expect=ctrl-v,ctrl-x,ctrl-t',}
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'mbbill/undotree'
Plug 'prabirshrestha/vim-lsp'

call plug#end()
