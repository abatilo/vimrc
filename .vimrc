filetype off
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'AlessandroYorba/Alduin'
Plugin 'Yggdroot/indentLine'
Plugin 'airblade/vim-gitgutter'
Plugin 'airblade/vim-rooter'
Plugin 'ajh17/VimCompletesMe'
Plugin 'artur-shaik/vim-javacomplete2'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'godlygeek/tabular'
Plugin 'scrooloose/nerdtree'
Plugin 'tfnico/vim-gradle'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'wakatime/vim-wakatime'

" All of your Plugins must be added before the following line
call vundle#end()            " required

set autoindent
filetype plugin indent on

colorscheme alduin
if !has('g:syntax_on')|syntax enable|endif

" Set a line for 80 columns
set colorcolumn=80

" https://www.reddit.com/r/vim/wiki/tabstop
" 2. Set 'tabstop' and 'shiftwidth' to whatever you prefer and use
"    'expandtab'.  This way you will always insert spaces.  The
"    formatting will never be messed up when 'tabstop' is changed.
set tabstop=2
set shiftwidth=2
set expandtab

" Let us backspace on indents
" http://vim.wikia.com/wiki/Backspace_and_delete_problems#Backspace_key_won.27t_move_from_current_line
set backspace=indent,eol,start

" Line numbers
set number

" Set where splits will appear to
set splitbelow
set splitright

" Display whitespace characters
set list
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·

" Store file history
set undofile
set undodir=~/.vim/undo

" Highlight the matching character pair
set showmatch

" Highlight the current line
set cursorline

" Highlight while I type a search
set incsearch

" Keep searched text highligted
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

set foldmethod=indent
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max

" Make it easy to move lines up and down
nnoremap <C-j> :m .+1<CR>
nnoremap <C-k> :m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>
inoremap <C-k> <Esc>:m .-2<CR>
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" Open NERDTree
noremap <C-n> :NERDTreeToggle<CR>

" Use ripgrep
if executable("rg")
    set grepprg=rg\ --color=never
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
endif

" Indent line setting
let g:indentLine_char = '|'

" http://vim.wikia.com/wiki/Remove_unwanted_spaces
command! FixTrail %s/\s\+$//e

" create ctags easily
command! MakeTags !ctags -R -f ~/.tags .
set tags=~/.tags

" Saves session and closes all buffers
nnoremap <leader>s :mksession! ~/.vim/session.vim<CR>:xa<CR>

" Let enter accept the highlighted selection in the autocomplete popup
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Easier than reaching for escape
inoremap jk <Esc>

" https://sunaku.github.io/vim-256color-bce.html
if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

" JavaComplete2
augroup JavaComplete2
  autocmd!
  autocmd FileType java setlocal omnifunc=javacomplete#Complete
augroup END
function OptimizeImports() abort
  JCimportsAddMissing
  JCimportsRemoveUnused
endfunction
noremap <C-o> :call OptimizeImports()<CR>
noremap <C-i> :JCgenerateAbstractMethods<CR>
let g:JavaComplete_GradleExecutable = 'gradlew'

" Set compiler to gradlew
augroup GradlewCompiler
  autocmd!
  autocmd FileType java compiler gradlew
augroup END
