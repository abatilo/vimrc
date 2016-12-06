inoremap jk <Esc>
au! FileType python setl nosmartindent
au FocusGained,BufEnter * :silent! !
au FocusLost,WinLeave * :silent! w

set autoread
set undofile
set undodir=~/.vim/undo

set nocompatible
syntax on

set autoindent
set smartindent

set tabstop=2
set shiftwidth=2
set expandtab
set backspace=indent,eol,start

set number
set cursorline

set splitbelow
set splitright

set background=dark
colorscheme solarized

set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=lightgrey
