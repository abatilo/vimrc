set nocompatible
filetype off
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'airblade/vim-gitgutter'
Plugin 'ajh17/VimCompletesMe'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'gfontenot/vim-xcode'
Plugin 'godlygeek/tabular'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 't1mxg0d/vim-lucario'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-scripts/DoxygenToolkit.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on 

let g:xcode_project_file = "/Users/aaronbatilo/Desktop/JoshServer/Josh 2.0.xcodeproj"
let g:xcode_default_scheme = 'Josh\ 2.0'

" create ctags easily
command! MakeTags !ctags -R .

" save session
nnoremap <leader>s :mksession!<CR>

" Make it easy to move lines up and down 
nnoremap <C-j> :m .+1<CR>
nnoremap <C-k> :m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>
inoremap <C-k> <Esc>:m .-2<CR>
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Easier than reaching for escape
inoremap jk <Esc>

" Store file history
set autoread
set undofile
set undodir=~/.vim/undo

syntax enable

set autoindent
set smartindent
set breakindent
set lazyredraw
set showmatch

set incsearch
set hlsearch

nnoremap <leader><space> :nohlsearch<CR>
set foldmethod=indent

" move vertically by visual line
nnoremap j gj
nnoremap k gk

set tabstop=2
set shiftwidth=2
set expandtab
set backspace=indent,eol,start

set number
set relativenumber
set cursorline

set splitbelow
set splitright

set colorcolumn=100

if executable("ag")
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

set background=dark
set termguicolors
