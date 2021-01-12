call plug#begin('~/.local/share/nvim/plugged')

Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'bronson/vim-trailing-whitespace'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'danilamihailov/beacon.nvim'
Plug 'dense-analysis/ale'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'editorconfig/editorconfig-vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'godlygeek/tabular'
Plug 'hashivim/vim-terraform'
Plug 'ianks/vim-tsx'
Plug 'leafgarland/typescript-vim'
Plug 'neoclide/coc-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
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

let g:python_host_prog = '~/.asdf/installs/python/2.7.16/bin/python'
let g:python3_host_prog = '~/.asdf/installs/python/3.8.5/bin/python'

let mapleader = "\<Space>"

colorscheme dracula

if !has('g:syntax_on')|syntax enable|endif

" Let us backspace on indents
" http://vim.wikia.com/wiki/Backspace_and_delete_problems#Backspace_key_won.27t_move_from_current_line
set backspace=indent,eol,start

" Line numbers
set relativenumber

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

" So that editorconfig plays nicely with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" vim-go
let g:go_fmt_command = "goimports"
let g:go_rename_command = "gopls"
let g:go_auto_type_info = 1
let g:go_addtags_transform = "camelcase"

" vim-terraform
let g:terraform_fmt_on_save=1

" Declare the coc extensiosn to be installed and managed
let g:coc_global_extensions = [
      \"coc-go",
      \"coc-json",
      \"coc-prettier",
      \"coc-snippets",
      \"coc-tailwindcss",
      \"coc-tsserver",
      \"coc-yaml",
      \"coc-pyright",
      \]

" coc-snippets
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Disable some vim-go defaults and let coc.nvim do it
let g:go_def_mapping_enabled = 0

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)

" Declare some coc bindings
nmap <leader>n  <Plug>(coc-diagnostic-next)
nmap <leader>p  <Plug>(coc-diagnostic-prev)
nmap <leader>ca  <Plug>(coc-codeaction)
nmap <leader>f  <Plug>(coc-fix-current)

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=100

tnoremap <Esc><Esc> <C-\><C-n>
nnoremap n nzz
nnoremap N Nzz
