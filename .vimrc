call plug#begin('~/.local/share/nvim/plugged')

Plug 'AlessandroYorba/Alduin'
Plug 'RRethy/vim-illuminate'
Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'bronson/vim-trailing-whitespace'
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dense-analysis/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
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

let g:python_host_prog = '~/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '~/.pyenv/versions/neovim3/bin/python'

set background=dark
colorscheme base16-grayscale-dark
" Underline instead of block the matching paren
let g:alduin_Shout_Aura_Whisper = 1

if !has('g:syntax_on')|syntax enable|endif

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
nnoremap <leader><CR> :nohlsearch<CR>

" Ignore casing in searches
set ignorecase smartcase

" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

set foldmethod=indent
" Open all methods by default
set foldlevelstart=10

let g:mucomplete#enable_auto_at_startup = 1

" Auto selects matching options
set completeopt=menuone,preview,noinsert

" Let enter accept the highlighted selection in the autocomplete popup
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Move vertically by visual line
nnoremap j gj
nnoremap k gk

" Open NERDTree
noremap <C-n> :NERDTreeToggle<CR>

" Use ripgrep
if executable("rg")
    set grepprg=rg\ --color=never\ --smart-case\ --vimgrep
    let g:ctrlp_user_command = 'rg %s --files --no-ignore --hidden --smart-case --follow --glob "!{.git,node_modules}/*" --color=never 2> /dev/null'
endif

" Indent line setting
let g:indentLine_char = '|'

" Create ctags easily
command! MakeTags !ctags -R -f ~/.tags $PWD
noremap <leader>t :!ctags -R -f ~/.tags $PWD<CR>
set tags=~/.tags

" Easier than reaching for escape
inoremap jk <Esc>

" https://github.com/jwilm/alacritty/issues/109
if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" If no smart import is available, use a brute force search
noremap <C-l> :read !~/.vim/ripport <cword><CR>

" So that editorconfig plays nicely with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" Do both formatting and handling imports
let g:go_fmt_command = "goimports"

" Run all static analysis on save
let g:go_metalinter_autosave = 1
