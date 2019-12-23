call plug#begin('~/.local/share/nvim/plugged')

Plug 'AlessandroYorba/Alduin'
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
Plug 'leafgarland/typescript-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
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

let mapleader = "\<Space>"

set background=dark
" colorscheme base16-grayscale-dark
colorscheme alduin
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
set listchars=tab:\ \ ,extends:›,precedes:‹,nbsp:·,trail:·

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
set backupdir=/tmp
set directory=/tmp

set foldmethod=indent
" Open all methods by default
set foldlevelstart=10

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

" Disable some vim-go defaults and let coc.nvim do it
let g:go_def_mapping_enabled = 0
let g:go_fmt_autosave = 0

" Check for comments
let g:go_metalinter_autosave=1

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Declare the coc extensiosn to be installed and managed
let g:coc_global_extensions = ["coc-go", "coc-tsserver", "coc-json", "coc-eslint", "coc-prettier", "coc-highlight"]

" Declare some coc bindings
nmap <leader>n  <Plug>(coc-diagnostic-next)
nmap <leader>p  <Plug>(coc-diagnostic-prev)
nmap <leader>ca  <Plug>(coc-codeaction)
nmap <leader>f  <Plug>(coc-fix-current)

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" autocmd section

augroup General
  autocmd!
  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END

" Auto format and auto import golang code
augroup Go
  autocmd!
  autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')
  autocmd BufWritePre *.go :call CocAction('format')
augroup END

" Auto file format for typescript and react files
augroup TypeScript
  autocmd!
  autocmd BufWritePre *.{ts,tsx} :CocCommand prettier.formatFile
augroup END
