set langmenu=en_US
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

set autoread
set clipboard=unnamed
set ignorecase
set encoding=utf8
set tabstop=4
set shiftwidth=4
set expandtab
set showmode
set incsearch

" Keymappings
let mapleader=" "
noremap <leader>y "*y
noremap <leader>p "*p

vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

nnoremap <silent><leader>1 :source ~/.vimrc \| :PlugInstall<CR>
nnoremap <silent><leader>l :Buffers<cr>
nnoremap <silent><leader>fj :Files<CR>
nnoremap <silent><leader>fj :Files<CR>

set number
set cursorline
set termguicolors

set scrolloff=7

syntax on

" Set syntax highlighting for .bashrc files
autocmd BufRead,BufNewFile *.bashrc set filetype=sh

" Define colors to match the scheme in the first image
hi  Comment       guifg=#8a8980                 
hi  Identifier    guifg=#77713f
hi  String        guifg=#526e47                 
hi  Function      guifg=#4d699b                 
hi  Keyword       guifg=#624c83                 
hi  Type          guifg=#597b75                 
hi  Special       guifg=#223249                 
hi  Operator      guifg=#836f4a                 
hi  Statement     guifg=#624c83                 
hi  shStatement   guifg=#624c83                 
hi  PreProc       guifg=#c84053                 
hi  Constant      guifg=#2d4f67                 
hi  CursorLineNr  cterm=bold     guifg=#de9800  
hi  CursorLine    guibg=#c7d7e0                 
hi  clear         LineNr                        
hi  MatchParen    guifg=#2d4f67  guibg=#dcd7ba  
hi  Title        cterm=bold     gui=bold       guifg=#4d699b

call plug#begin()

Plug 'junegunn/fzf', { 'do': { -> fzf#install() }, 'options':  '--reverse  --expect=ctrl-v,ctrl-x,ctrl-t',}
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()
