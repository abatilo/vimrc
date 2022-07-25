vim.cmd [[packadd packer.nvim]]

require('packer').startup(function()
  use { 'dracula/vim', as = 'dracula' }                        -- Color scheme
  use { 'godlygeek/tabular' }                                  -- Make it easy to align text by column
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- Add language aware parsing
  use { 'wbthomason/packer.nvim' }                             -- Packer can manage itself
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
