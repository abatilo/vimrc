set nocompatible
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'flazz/vim-colorschemes'
Plugin 'airblade/vim-gitgutter'
Plugin 'ajh17/VimCompletesMe'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'gfontenot/vim-xcode'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/DoxygenToolkit.vim'
Plugin 'godlygeek/tabular'

" All of your Plugins must be added before the following line
call vundle#end()            " required

" Rename
" http://stackoverflow.com/questions/597687/changing-variable-names-in-vim

" Replaces all in current enclosing scope, only use this when the variable is defined in the same scope
nnoremap r [{V%::s/<C-R>///g<Left><Left>
" Jumps to definition of the variable and performs replace. Must be used on a usage of the variable, not on the definition
nnoremap gr gd[{V%::s/<C-R>///g<Left><Left>

let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path_mode = 0

let g:xcode_project_file = "/Users/aaronbatilo/Desktop/JoshServer/Josh 2.0.xcodeproj"
let g:xcode_default_scheme = 'Josh\ 2.0'

" create ctags easily
command! MakeTags !ctags -R .

" save session
nnoremap <leader>s :mksession!<CR>

" Make it easy to move lines up and down 
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Easier than reaching for escape
inoremap jk <Esc>
au! FileType python setl nosmartindent

" Store file history
set autoread
set undofile
set undodir=~/.vim/undo

syntax enable

set autoindent
set smartindent
set lazyredraw
set showmatch

set incsearch
set hlsearch

nnoremap <leader><space> :nohlsearch<CR>
set foldmethod=indent
set foldlevelstart=1
set foldnestmax=20

" move vertically by visual line
nnoremap j gj
nnoremap k gk

set tabstop=2
set shiftwidth=2
set expandtab
set backspace=indent,eol,start

set number
set cursorline

set splitbelow
set splitright

set colorcolumn=100

if executable("ag")
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
