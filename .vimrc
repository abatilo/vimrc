call plug#begin('~/.local/share/nvim/plugged')

Plug 'Yggdroot/indentLine'                                    " Add indent guides
Plug 'airblade/vim-gitgutter'                                 " Show diff icons in gutter
Plug 'airblade/vim-rooter'                                    " Set project root based on git directory
Plug 'dracula/vim', { 'as': 'dracula' }                       " colorscheme
Plug 'editorconfig/editorconfig-vim'                          " Set project specific formatting requirements
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }            " golang niceties
Plug 'glacambre/firenvim', {'do':{ _ -> firenvim#install(0)}} " Replace textarea in chrome with embedded neovim
Plug 'godlygeek/tabular'                                      " Make it easy to align columns
Plug 'hrsh7th/cmp-buffer'                                     " Buffer based completion source
Plug 'hrsh7th/cmp-calc'                                       " Replace math expressions with evaluated value
Plug 'hrsh7th/cmp-nvim-lsp'                                   " Use the LSP client as a completion source
Plug 'hrsh7th/cmp-path'                                       " Get file from filesystem
Plug 'hrsh7th/cmp-vsnip'                                      " Integrate with vsnip
Plug 'hrsh7th/nvim-cmp'                                       " Auto complete plugin
Plug 'hrsh7th/vim-vsnip'                                      " Snippet engine for auto complete
Plug 'junegunn/fzf'                                           " Setup fzf
Plug 'junegunn/fzf.vim'                                       " Setup vim specific features with fzf
Plug 'kabouzeid/nvim-lspinstall'                              " Make it easy to install lsp servers
Plug 'neovim/nvim-lspconfig'                                  " Make built in lsp client configurable
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}   " Add syntax tree parsing
Plug 'preservim/nerdtree'                                     " Project tree view
Plug 'rafamadriz/friendly-snippets'                           " Cross language collection of snippets
Plug 'tpope/vim-commentary'                                   " Add bindings for commenting files
Plug 'tpope/vim-fugitive'                                     " Integrate git into vim
Plug 'tpope/vim-rhubarb'                                      " Jump to selected lines in GitHub
Plug 'tpope/vim-surround'                                     " Manipulate surrounding text like wrapping or deleting quotes
Plug 'vim-airline/vim-airline'                                " Nice to look at status line
Plug 'wakatime/vim-wakatime'                                  " Track my time

" Initialize plugin system
call plug#end()

let g:python_host_prog = '~/.asdf/installs/python/2.7.16/bin/python'
let g:python3_host_prog = '~/.asdf/installs/python/3.8.5/bin/python'

let mapleader = "\<Space>"

colorscheme dracula

" Let us backspace on indents
" http://vim.wikia.com/wiki/Backspace_and_delete_problems#Backspace_key_won.27t_move_from_current_line
set backspace=indent,eol,start

" Custom indentLine character
let g:indentLine_char = '|'

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

" Let treesitter handle folding
" https://github.com/nvim-treesitter/nvim-treesitter/tree/460a26ef3218057a544b3fd6697e979e6bad648d#available-modules
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=10

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

" Easier than reaching for escape
inoremap jk <Esc>

" Simulate true colors
set termguicolors

" So that editorconfig plays nicely with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" vim-go
let g:go_fmt_command = "goimports"
let g:go_addtags_transform = "camelcase"

" Controls how quickly things like gitgutter updates happen
set updatetime=100

" Exit insert mode while in the terminal
tnoremap <Esc><Esc> <C-\><C-n>

" Center the search results when jumping between results
nnoremap n nzz
nnoremap N Nzz

" Highlight trailing whitespace like an error
match errorMsg /\s\+$/

" Improve completion menu experience with nvim-cmp
set completeopt=menu,menuone,noselect

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

"""
" Below is configuration in Lua for Neovim 0.5 and above features
"""

lua << EOF
-- Configure treesitter to do parse tree based syntax highlighting and
-- indentation
local ts = require 'nvim-treesitter.configs'
ts.setup {
  -- Install all maintained language parsers
	ensure_installed = 'maintained',
	highlight = {
    enable = true
  },
	indent = {
    enable = true
  },
}

-- keymaps
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

    vim.api.nvim_exec([[
augroup autoFormat
  autocmd! * <buffer>
  autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()
augroup END
    ]], false)

  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
    augroup lsp_document_highlight
      autocmd! * <buffer>
      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]], false)
  end
end

-- config that activates keymaps and enables snippet support
local function make_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  return {
    -- enable snippet support
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = on_attach,
  }
end

-- Define a function to register each language's language server with neovim's
-- language server client.
-- Based on:
-- https://github.com/kabouzeid/nvim-lspinstall/wiki/Home/16cd58d4e8488359780897a97db3e3d0667f12a7
local function setup_servers()
  require'lspinstall'.setup()

  -- get all installed servers
  local servers = require'lspinstall'.installed_servers()
  -- ... and add manually installed servers
  -- These will have to be installed one at a time whenever you setup a new computer via:
  -- :LspInstall $name
  table.insert(servers, "bash")
  table.insert(servers, "diagnosticls")
  table.insert(servers, "dockerfile")
  table.insert(servers, "go")
  table.insert(servers, "json")
  table.insert(servers, "python")
  table.insert(servers, "tailwindcss")
  table.insert(servers, "terraform")
  table.insert(servers, "typescript")
  table.insert(servers, "vim")
  table.insert(servers, "yaml")

  for _, server in pairs(servers) do
    local config = make_config()
    require'lspconfig'[server].setup(config)
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'buffer' },
    { name = 'calc' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'vsnip' },
  }
})

EOF
