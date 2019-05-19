call plug#begin('~/.local/share/nvim/plugged')

Plug 'AlessandroYorba/Alduin'
Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'bronson/vim-trailing-whitespace'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/AutoComplPop'
Plug 'wakatime/vim-wakatime'

if has('unix')
  if !has('macunix')
    Plug 'KabbAmine/zeavim.vim'
  else
    Plug 'rizzatti/dash.vim'
    nnoremap <leader>z :Dash<CR>
  endif
endif

" Initialize plugin system
call plug#end()

set background=dark
colorscheme alduin
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
  autocmd BufReadPost * :%s/\s\+$//e
  autocmd BufReadPost * :%s/$//e
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

" If no smart import is available, use a brute force search
noremap <C-l> :read !~/.vim/ripport <cword><CR>

" Use tab and shift-tab to scroll up and down in auto complete window
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Auto selects matching options
set completeopt+=longest
set completeopt+=noinsert

" Settings for files written for Conga
augroup CongaCodeStyle
  autocmd!
  autocmd BufRead */machinelearning/*.java set tabstop=4 shiftwidth=4 colorcolumn=160
  autocmd BufRead */machinelearning/*.scala set tabstop=4 shiftwidth=4 colorcolumn=160
  autocmd BufRead */machinelearning/*.py set tabstop=4 shiftwidth=4 colorcolumn=120
  autocmd BufRead */machinelearning/*.cs set tabstop=4 shiftwidth=4
  autocmd BufRead *.cs set tabstop=4 shiftwidth=4
  autocmd BufRead *.ts set tabstop=2 shiftwidth=2
  autocmd BufRead *.tsx set tabstop=2 shiftwidth=2
augroup END

augroup SudokuRace
  autocmd!
  autocmd BufRead */sudoku-race/*.py let g:ale_python_flake8_options = "--import-order-style pep8"
augroup END
