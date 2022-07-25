call plug#begin('~/.local/share/nvim/plugged')

Plug 'Yggdroot/indentLine'                                  " Add indent guides
Plug 'airblade/vim-gitgutter'                               " Show diff icons in gutter
Plug 'airblade/vim-rooter'                                  " Set project root based on git directory
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }          " golang niceties
Plug 'hrsh7th/cmp-buffer'                                   " Buffer based completion source
Plug 'hrsh7th/cmp-calc'                                     " Replace math expressions with evaluated value
Plug 'hrsh7th/cmp-nvim-lsp'                                 " Use the LSP client as a completion source
Plug 'hrsh7th/cmp-path'                                     " Get file from filesystem
Plug 'hrsh7th/cmp-vsnip'                                    " Integrate with vsnip
Plug 'hrsh7th/nvim-cmp'                                     " Auto complete plugin
Plug 'hrsh7th/vim-vsnip'                                    " Snippet engine for auto complete
Plug 'junegunn/fzf'                                         " Setup fzf
Plug 'junegunn/fzf.vim'                                     " Setup vim specific features with fzf
Plug 'neovim/nvim-lspconfig'                                " Make built in lsp client configurable
Plug 'preservim/nerdtree'                                   " Project tree view
Plug 'rafamadriz/friendly-snippets'                         " Cross language collection of snippets
Plug 'tpope/vim-commentary'                                 " Add bindings for commenting files
Plug 'vim-airline/vim-airline'                              " Nice to look at status line
Plug 'williamboman/mason.nvim'                              " Install LSP servers
Plug 'williamboman/mason-lspconfig.nvim'                    " For mason + lspconfig
Plug 'lukas-reineke/lsp-format.nvim'                        " Format code on save

Plug 'github/copilot.vim'

" Initialize plugin system
call plug#end()

let g:python_host_prog = '~/.asdf/installs/python/2.7.16/bin/python'
let g:python3_host_prog = '~/.asdf/installs/python/3.8.5/bin/python'

" Let us backspace on indents
" http://vim.wikia.com/wiki/Backspace_and_delete_problems#Backspace_key_won.27t_move_from_current_line
set backspace=indent,eol,start

" Custom indentLine character
let g:indentLine_char = '|'

" Display whitespace characters
set list
set listchars=tab:\ \ ,extends:›,precedes:‹,nbsp:·,trail:·

" Store temporary files in a central spot
set backup
set backupdir=/tmp
set directory=/tmp

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

" So that editorconfig plays nicely with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" vim-go
let g:go_fmt_command = "goimports"
let g:go_addtags_transform = "camelcase"

" Controls how quickly things like gitgutter updates happen
set updatetime=100

" Exit insert mode while in the terminal
tnoremap <Esc><Esc> <C-\><C-n>

" Highlight trailing whitespace like an error
match errorMsg /\s\+$/

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
	ensure_installed = 'all',
	highlight = {
    enable = true
  },
	indent = {
    enable = true
  },
}

-- Configure formatter on lsp
require("lsp-format").setup {}

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

  require("lsp-format").on_attach(client)
end

local servers = {
  "bashls",
  "diagnosticls",
  "dockerls",
  "golangci_lint_ls",
  "gopls",
  "jsonls",
  "pyright",
  "tailwindcss",
  "terraformls",
  "tflint",
  "tsserver",
  "vimls",
  "yamlls",
}
require("mason").setup {}
require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_installation = true
}

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
  },
  sources = {
    { name = 'vsnip' },
    { name = 'nvim_lsp' },
    { name = 'buffer', keyword_length = 4 },
    { name = 'path' },
    { name = 'calc' },
  },
  experimental = {
    native_menu = false,
  },
})

-- Setup lspconfig.
local lspconfig = require("lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

EOF
