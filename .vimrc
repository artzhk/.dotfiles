set langmenu=en_US
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" termguicolors fix
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set autoread
set clipboard=unnamed
set ignorecase
set encoding=utf8
set tabstop=8
set shiftwidth=8
set expandtab
set smartcase
set showmode

set incsearch

" Inbuild Keymappings
let mapleader=" "

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

nnoremap <silent><leader>nr :set rnu!<CR>

" External buffer, might be overengeneered...
nnoremap <silent><leader>y :w! /tmp/buffer.txt<CR> ""y
vnoremap <silent><leader>y :w! /tmp/buffer.txt<CR> ""y
nmap <silent><leader>p !!cat /tmp/buffer.txt<CR>
vnoremap <silent><leader>p !cat /tmp/buffer.txt<CR>

set number
set termguicolors
set scrolloff=8
set background=dark
syntax on

" Define colors to match the scheme in the first image
au  ColorScheme  *  hi  clear         Visual
" au  ColorScheme  *  hi  Normal        guibg=NONE                   ctermbg=NONE
au  ColorScheme  *  hi  Visual        guibg=#58a6ff                guifg=#ffffff  cterm=NONE     gui=NONE
au  ColorScheme  *  hi  MatchParen     term=bold  guifg=#ffffff guibg=NONE
au  ColorScheme  *  hi  link          NormalFloat                  NormalNC
au  ColorScheme  *  hi  CursorLineNr  guifg=#58a6ff                guibg=#ffffff
" au  ColorScheme  *  hi  clear         SignColumn
" au  ColorScheme  *  hi  clear         FloatBorder
" au  ColorScheme  *  hi  clear         NormalFloat
" au  ColorScheme  *  hi  clear         FloatTitle
" au  ColorScheme  *  hi  clear         FloatFooter
" au  ColorScheme  *  hi  clear         Folded
" au  ColorScheme  *  hi  clear         FoldColumn
" au  ColorScheme  *  hi  clear         TabLineFill
" au  ColorScheme  *  hi  clear         ColorColumn
" au  ColorScheme  *  hi  clear         QuickFixLine
" au  ColorScheme  *  hi  clear         Folded
" au  ColorScheme  *  hi  clear         FoldColumn
" au  ColorScheme  *  hi  clear         TabLineFill
" au  ColorScheme  *  hi  clear         MsgSeparator
au  ColorScheme  *  hi  clear         TreesitterContextLineNumber
au  ColorScheme  *  hi  IncSearch     gui=NONE                     cterm=NONE     guibg=#d7474b  guifg=#ffffff

colorscheme murphy

" Plugin remaps
nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR> nnoremap <silent><leader>l :Buffers<cr>
nnoremap <silent><leader>du :Files<CR>
nnoremap <silent><leader>u :UndotreeToggle<CR>

"" LSP 
if executable('pylsp')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
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
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() }, 'options':  '--reverse  --expect=ctrl-v,ctrl-x,ctrl-t',}
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'mbbill/undotree'
Plug 'prabirshrestha/vim-lsp'

call plug#end()
