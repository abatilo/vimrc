vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
  use { 'wbthomason/packer.nvim' } -- Packer can manage itself

  -- No .setup() needed
  use { 'dracula/vim', as = 'dracula' } -- Color scheme
  use { 'godlygeek/tabular' }           -- Make it easy to align text by column
  use { 'gpanders/editorconfig.nvim' }  -- .editorconfig file support
  use { 'wakatime/vim-wakatime' }       -- Track stats for wakatime.com

  -- Plugins that require .setup to be called
  use { 'kylechui/nvim-surround' }                                   -- Manipulate around selected text
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }       -- Add language aware parsing
  use { 'ruifm/gitlinker.nvim', requires = 'nvim-lua/plenary.nvim' } -- <leader>gy to put GitHub URL into clipboard
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

require('nvim-surround').setup()

require('nvim-treesitter.configs').setup({
  -- Lazily install treesitter parser when buffers are loaded
  auto_install = true,
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
