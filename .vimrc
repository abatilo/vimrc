call plug#begin('~/.local/share/nvim/plugged')

Plug 'airblade/vim-gitgutter'                               " Show diff icons in gutter
Plug 'airblade/vim-rooter'                                  " Set project root based on git directory
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}          " Integrate fzf to search through coc options
Plug 'dense-analysis/ale'                                   " Highlight linting errors
Plug 'dracula/vim', { 'as': 'dracula' }                     " colorscheme
Plug 'editorconfig/editorconfig-vim'                        " Set project specific formatting requirements
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }          " golang niceties
Plug 'godlygeek/tabular'                                    " Make it easy to align columns
Plug 'hashivim/vim-terraform'                               " Auto format terraform
Plug 'junegunn/fzf'                                         " Setup fzf
Plug 'junegunn/fzf.vim'                                     " Setup vim specific features with fzf
Plug 'lukas-reineke/indent-blankline.nvim'                  " Add indent guides
Plug 'neoclide/coc.nvim', {'branch': 'release'}             " Add completion
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Add syntax tree parsing
Plug 'preservim/nerdtree'                                   " Project tree view
Plug 'tpope/vim-commentary'                                 " Add bindings for commenting files
Plug 'tpope/vim-fugitive'                                   " Integrate git into vim
Plug 'tpope/vim-rhubarb'                                    " Jump to selected lines in GitHub
Plug 'tpope/vim-surround'                                   " Manipulate surrounding text like wrapping or deleting quotes
Plug 'vim-airline/vim-airline'                              " Nice to look at status line
Plug 'wakatime/vim-wakatime'                                " Track my time

" Initialize plugin system
call plug#end()

lua << EOF
-- Configure treesitter to do parse tree based syntax highlighting and
-- indentation
local ts = require 'nvim-treesitter.configs'
ts.setup {
	ensure_installed = 'maintained',
	highlight = { enable = true },
	indent = { enabled = true }
}
-- Needed until this gets fixed. Otherwise blank lines will mysteriously also
-- be highlighted
-- https://github.com/lukas-reineke/indent-blankline.nvim/issues/93
vim.wo.colorcolumn = "99999"
vim.g.indent_blankline_use_treesitter = true
EOF

let g:python_host_prog = '~/.asdf/installs/python/2.7.16/bin/python'
let g:python3_host_prog = '~/.asdf/installs/python/3.8.5/bin/python'

let mapleader = "\<Space>"

colorscheme dracula

" Let us backspace on indents
" http://vim.wikia.com/wiki/Backspace_and_delete_problems#Backspace_key_won.27t_move_from_current_line
set backspace=indent,eol,start

" Line numbers
set number
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

" Use fzf instead of ctrlp
" fzf only searches from your current directory, so let's make it start from
" the root of the project
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
command! ProjectFiles execute 'Files' s:find_git_root()
nnoremap <silent> <C-p> :<C-u>ProjectFiles<CR>

" Quickly fuzzy search through the outline of the current file with coc
nnoremap <silent> <C-l> :<C-u>CocFzfList outline<CR>

" Easier than reaching for escape
inoremap jk <Esc>

" Simulate true colors
set termguicolors

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
      \"coc-diagnostic",
      \"coc-docker",
      \"coc-json",
      \"coc-prettier",
      \"coc-pyright",
      \"coc-tailwindcss",
      \"coc-tsserver",
      \"coc-yaml",
      \]

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=100

" Exit insert mode while in the terminal
tnoremap <Esc><Esc> <C-\><C-n>

" Center the search results when jumping between results
nnoremap n nzz
nnoremap N Nzz

" Highlight trailing whitespace like an error
match errorMsg /\s\+$/
