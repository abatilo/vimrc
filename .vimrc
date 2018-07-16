filetype off
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'AlessandroYorba/Alduin'
Plugin 'KabbAmine/zeavim.vim'
Plugin 'Shougo/deoplete.nvim'
Plugin 'SirVer/ultisnips'
Plugin 'Yggdroot/indentLine'
Plugin 'airblade/vim-gitgutter'
Plugin 'airblade/vim-rooter'
Plugin 'artur-shaik/vim-javacomplete2'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'godlygeek/tabular'
Plugin 'honza/vim-snippets'
Plugin 'pbrisbin/vim-colors-off'
Plugin 'scrooloose/nerdtree'
Plugin 'tfnico/vim-gradle'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'w0rp/ale'
Plugin 'wakatime/vim-wakatime'
Plugin 'zchee/deoplete-jedi'

" All of your Plugins must be added before the following line
call vundle#end()            " required

set autoindent
filetype plugin indent on

colorscheme alduin
set background=dark
" colorscheme alduin
" Underline instead of block the matching paren
let g:alduin_Shout_Aura_Whisper = 1

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
" Open all methods by default
set foldlevelstart=10

" Make it easy to move lines up and down
nnoremap <C-j> :m .+1<CR>
nnoremap <C-k> :m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>
inoremap <C-k> <Esc>:m .-2<CR>
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Move vertically by visual line
nnoremap j gj
nnoremap k gk

" Open NERDTree
noremap <C-n> :NERDTreeToggle<CR>

" Use ripgrep
if executable("rg")
    set grepprg=rg\ --color=never\ --vimgrep
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
endif

" Indent line setting
let g:indentLine_char = '|'

" http://vim.wikia.com/wiki/Remove_unwanted_spaces
command! FixTrail %s/\s\+$//e
augroup DeleteTrailingWhitespace
  autocmd!
  " autocmd BufWritePre * :%s/\s\+$//e
augroup END

" Create ctags easily
command! MakeTags !ctags -R -f ~/.tags $PWD
noremap <leader>t :!ctags -R -f ~/.tags $PWD<CR>
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

function! OptimizeImports()
  JCimportsRemoveUnused
  JCimportsAddMissing
  JCimportsSort
endfunction
" Try a smart import
noremap <C-o> :JCimportAddSmart<CR>
" If no smart import is available, use a brute force search
noremap <C-l> :read !~/.vim/ripport <cword><CR>
noremap <leader>e :call OptimizeImports()<CR>

" ALE
let g:ale_linters = {
\  'python': ['flake8'],
\  'git': ['gitlint'],
\  'java': [],
\}

" Integrate into airline
let g:airline#extensions#ale#enabled = 1

" Pop a buffer open with issues
let g:ale_open_list = 1

" UltiSnips configurations
let g:UltiSnipsExpandTrigger="<C-Space>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories = [$HOME.'/.vim/UltiSnips', 'UltiSnips']

let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#omni_patterns = {}
let g:deoplete#sources = {}
let g:deoplete#sources._ = []
let g:deoplete#file#enable_buffer_path = 1

" Use tab and shift-tab to scroll up and down in auto complete window
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Auto selects matching options
set completeopt+=longest
set completeopt+=noinsert

" Make it very easy to urldecode a file
command! FullEncode %!python -c "import sys,urllib as ul; [sys.stdout.write(ul.quote_plus(l)) for l in sys.stdin]"
command! FullDecode %!python -c "import sys,urllib as ul; [sys.stdout.write(ul.unquote_plus(l)) for l in sys.stdin]"

" JavaComplete2
augroup JavaComplete2
  autocmd!
  autocmd FileType java setlocal omnifunc=javacomplete#Complete
augroup END
noremap <C-i> :JCgenerateAbstractMethods<CR>

" Set compiler to gradlew
augroup GradlewCompiler
  autocmd!
  autocmd FileType java compiler gradlew
augroup END

" Settings for files written for Conga
augroup CongaCodeStyle
  autocmd!
  autocmd BufRead */machinelearning/*.java set tabstop=4 shiftwidth=4 colorcolumn=160
  autocmd BufRead */machinelearning/*.scala set tabstop=4 shiftwidth=4 colorcolumn=160
  autocmd BufRead */machinelearning/*.py set tabstop=4 shiftwidth=4 colorcolumn=120
  autocmd BufRead */machinelearning/*.py let g:ale_python_pycodestyle_options = "--max-line-length=120"
augroup END

augroup SudokuRace
  autocmd!
  autocmd BufRead */sudoku-race/*.java let g:ale_linters.java = ['checkstyle']
  autocmd BufRead */sudoku-race/*.java let g:ale_java_checkstyle_options = "-c backend/config/checkstyle/google_checks.xml"
  autocmd BufRead */sudoku-race/*.java set colorcolumn=100
augroup END
