vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
  use { 'wbthomason/packer.nvim' } -- Packer can manage itself

  -- No .setup() needed
  use { 'dracula/vim', as = 'dracula' } -- Color scheme
  use { 'godlygeek/tabular' }           -- Make it easy to align text by column
  use { 'gpanders/editorconfig.nvim' }  -- .editorconfig file support
  use { 'wakatime/vim-wakatime' }       -- Track stats for wakatime.com

  -- Plugins that require .setup to be called
  use { 'numToStr/Comment.nvim' }                                                                -- Comment helper
  use { 'lewis6991/gitsigns.nvim', }                                                             -- Git gutter helper
  use { 'kylechui/nvim-surround' }                                                               -- Manipulate around selected text
  use { 'lukas-reineke/indent-blankline.nvim' }                                                  -- Indent markers
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }                                   -- Add language aware parsing
  use { 'ruifm/gitlinker.nvim', requires = 'nvim-lua/plenary.nvim' }                             -- <leader>gy to put GitHub URL into clipboard
  use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true } } -- Status line
  use { 'kyazdani42/nvim-tree.lua', requires = { 'kyazdani42/nvim-web-devicons' } }              -- Tree file viewer

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }                               -- Telescope sorting and matching with fzf
  use { 'ahmedkhalf/project.nvim' }                                                              -- Set project root
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.x', requires = {{'nvim-lua/plenary.nvim'}} } -- Fuzzy finder

  use { 'neovim/nvim-lspconfig' }         -- Configure LSP
  use { 'lukas-reineke/lsp-format.nvim' } -- Auto format code

  use { 'williamboman/mason.nvim' }           -- Install LSP servers
  use { 'williamboman/mason-lspconfig.nvim' } -- For mason + lspconfig

  use { 'hrsh7th/nvim-cmp' }     -- Completion
  use { 'hrsh7th/vim-vsnip' }    -- Snippet engine
  use { 'hrsh7th/cmp-vsnip' }    -- Snippet completion
  use { 'hrsh7th/cmp-nvim-lsp' } -- Completion lsp source
  use { 'hrsh7th/cmp-buffer' }   -- Completion buffer source
  use { 'hrsh7th/cmp-path' }     -- Completion path source

  use { 'github/copilot.vim' } -- GitHub Copilot completion
end)

-- Set colorscheme
vim.cmd("colorscheme dracula")

-- Set leader key
vim.g.mapleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Set where splits will appear to
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Highlight the matching character pair
vim.opt.showmatch = true

-- Highlight the current line
vim.opt.cursorline = true

-- Highlight while I type a search
vim.opt.incsearch = true

-- Ignore casing in searches
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Simulate 24-bit colors for dracula scheme
vim.opt.termguicolors = true

-- Keep searched text highlighted
vim.opt.hlsearch = true
-- Remap for clearing search highlight
vim.keymap.set('n', '<leader><CR>', '<cmd>nohlsearch<CR>')

-- Keep long term undo history
vim.opt.undofile = true

-- Give more space for displaying messages.
vim.opt.cmdheight = 2

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 50

-- Move vertically by visual line.
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Alternative to hitting escape
vim.keymap.set('i', 'jk', '<ESC>')

-- Center search results
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Folding code
-- https://github.com/nvim-treesitter/nvim-treesitter/tree/5e894bdb85795f1bc1d84701fc58fc954c22edd5#folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 10

-- Plugin configuration

require('Comment').setup()
require('gitsigns').setup()
require('nvim-surround').setup()
require('indent_blankline').setup({
  show_current_context = true,
  show_current_context_start = true,
})

require('nvim-treesitter.configs').setup({
  ensure_installed = 'all',
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  }
})

require('gitlinker').setup({
  opts = {
    -- Make default mapping link to whole file, not just the current line
    add_current_line_on_normal_mode = false
  },
  mappings = "<leader>gy"
})

require('lualine').setup()
vim.keymap.set('n', '<C-N>', '<cmd>NvimTreeToggle<CR>')
require('nvim-tree').setup()
require('project_nvim').setup()

vim.keymap.set('n', '<leader>te', '<cmd>Telescope<CR>')
vim.keymap.set('i', '<C-P>', '<cmd>Telescope git_files<CR>')
vim.keymap.set('n', '<C-P>', '<cmd>Telescope git_files<CR>')
require('telescope').setup()
require('telescope').load_extension('fzf')

require('lsp-format').setup()

-- keymaps
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

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

  require('lsp-format').on_attach(client)
end

local function config(_config)
	return vim.tbl_deep_extend("force", {
		capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
		on_attach = on_attach,
	}, _config or {})
end

local servers = {
  "bashls",
  "diagnosticls",
  "dockerls",
  "gopls",
  "html",
  "jsonls",
  "pyright",
  "tailwindcss",
  "terraformls",
  "tsserver",
  "yamlls",
}
require("mason").setup {}
require("mason-lspconfig").setup {
  ensure_installed = servers,
}

for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup(config())
end

-- Setup nvim-cmp.
local cmp = require'cmp'
cmp.setup({
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i','c'}),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i','c'}),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer', keyword_length = 4 },
    { name = 'path' },
  },
})