" create ctags easily
command! MakeTags !ctags -R .

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

set nocompatible
syntax enable

set autoindent
set smartindent
set lazyredraw
set showmatch

set incsearch
set hlsearch

nnoremap <leader><space> :nohlsearch<CR>
set foldlevelstart=10
set foldnestmax=10

" move vertically by visual line
nnoremap j gj
nnoremap k gk

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set backspace=indent,eol,start

set number
set cursorline

set splitbelow
set splitright

set background=dark
colorscheme alduin

set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=lightgrey

if executable("ag")
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
