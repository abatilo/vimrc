-- Leader key must be set before any plugin loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Decide where the root of a project is
vim.g.rooter_patterns = { ".git" }

-- Build hooks must be registered before vim.pack.add() so they fire on first install.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then
      return
    end
    if name == "nvim-treesitter" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    elseif name == "vim-go" then
      if not ev.data.active then
        vim.cmd.packadd("vim-go")
      end
      vim.cmd("GoInstallBinaries")
    elseif name == "telescope-fzf-native.nvim" then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    end
  end,
})

vim.pack.add({
  -- Color scheme
  "https://github.com/Mofiqul/dracula.nvim",

  -- Shared dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- Text helpers
  "https://github.com/godlygeek/tabular",
  "https://github.com/kylechui/nvim-surround",

  -- Project / stats
  "https://github.com/wakatime/vim-wakatime",
  "https://github.com/notjedi/nvim-rooter.lua",

  -- Languages
  "https://github.com/fatih/vim-go",
  "https://github.com/cuducos/yaml.nvim",

  -- Git
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/ruifm/gitlinker.nvim",

  -- UI polish
  "https://github.com/folke/snacks.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-tree.lua",

  -- Treesitter (pin to master; the `main` branch is a WIP rewrite with a new
  -- `require('nvim-treesitter').setup()` API that this config does not use)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
  "https://github.com/folke/ts-comments.nvim",

  -- Telescope
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.x" },

  -- LSP
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/lukas-reineke/lsp-format.nvim",
  "https://github.com/nvimtools/none-ls.nvim",
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",

  -- Completion
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/vim-vsnip",
  "https://github.com/hrsh7th/cmp-vsnip",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",

  -- GitHub UI
  "https://github.com/pwntester/octo.nvim",
})

vim.cmd.colorscheme("dracula")

require("nvim-rooter").setup()
require("gitsigns").setup()
require("nvim-surround").setup()

require("snacks").setup({
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "c_sharp",
    "comment",
    "cpp",
    "css",
    "csv",
    "diff",
    "dockerfile",
    "editorconfig",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "gosum",
    "gotmpl",
    "gowork",
    "hcl",
    "helm",
    "hjson",
    "html",
    "http",
    "javascript",
    "jq",
    "json",
    "json5",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "nginx",
    "proto",
    "python",
    "regex",
    "requirements",
    "sql",
    "ssh_config",
    "starlark",
    "terraform",
    "tmux",
    "toml",
    "tsv",
    "tsx",
    "typescript",
    "xml",
    "yaml",
  },
  sync_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

require("ts-comments").setup({})

require("gitlinker").setup({
  opts = {
    add_current_line_on_normal_mode = false,
  },
  mappings = "<leader>gy",
})

require("nvim-tree").setup({
  filters = { custom = { "^\\.git" } },
  live_filter = { always_show_folders = false },
})

require("telescope").setup()
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")

local lsp_group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

    local ok, lsp_format = pcall(require, "lsp-format")
    if ok then
      lsp_format.on_attach(client, event.buf)
    end
  end,
})

require("lsp-format").setup()
require("mason").setup()

local function lsp_config(_config)
  return vim.tbl_deep_extend("force", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  }, _config or {})
end

local servers = {
  "bashls",
  "diagnosticls",
  "dockerls",
  "helm_ls",
  "html",
  "jsonls",
  "tailwindcss",
  "terraformls",
  "tflint",
  "ts_ls",
  "yamlls",
}

for _, lsp in pairs(servers) do
  vim.lsp.config(lsp, lsp_config())
end

require("mason-lspconfig").setup({
  ensure_installed = servers,
})

local null_ls = require("null-ls")
local null_ls_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      -- Only format using null-ls instead of built in LSP formatter
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end
null_ls.setup({
  -- Available sources:
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/47c04991af80b6acdf08a5db057908b52f4d0699/doc/BUILTINS.md
  sources = {
    -- General
    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.gitlint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.trail_space,

    -- Go
    null_ls.builtins.diagnostics.golangci_lint,
    null_ls.builtins.diagnostics.staticcheck,
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.goimports,

    -- Python
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
  },
  on_attach = function(client, bufnr)
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = null_ls_augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = null_ls_augroup,
        buffer = bufnr,
        callback = function()
          lsp_formatting(bufnr)
        end,
      })
    end
  end,
})

require("mason-tool-installer").setup({
  auto_update = true,
  ensure_installed = {
    "actionlint",
    "bash-language-server",
    "black",
    "diagnostic-languageserver",
    "dockerfile-language-server",
    "gh-actions-language-server",
    "gitlint",
    "golangci-lint",
    "gopls",
    "hadolint",
    "html-lsp",
    "isort",
    "json-lsp",
    "ruff",
    "shellcheck",
    "shfmt",
    "sql-formatter",
    "staticcheck",
    "tailwindcss-language-server",
    "terraform-ls",
    "tfsec",
    "typescript-language-server",
    "vim-language-server",
    "yaml-language-server",
  },
})

local cmp = require("cmp")
cmp.setup({
  completion = {
    completeopt = "menu,menuone,noinsert",
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "buffer", keyword_length = 4 },
    { name = "path" },
  },
})

require("octo").setup({
  default_to_projects_v2 = true,
})

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

-- Keep searched text highlighted
vim.opt.hlsearch = true
-- Remap for clearing search highlight
vim.keymap.set("n", "<leader><CR>", "<cmd>nohlsearch<CR>")

-- Keep long term undo history
vim.opt.undofile = true

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 50

-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"

-- Move vertically by visual line.
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Alternative to hitting escape
vim.keymap.set("i", "jk", "<ESC>")

-- Center search results
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Folding code
-- https://github.com/nvim-treesitter/nvim-treesitter/tree/5e894bdb85795f1bc1d84701fc58fc954c22edd5#folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 10

vim.keymap.set("n", "<C-N>", "<cmd>NvimTreeFindFileToggle<CR>")
vim.keymap.set("n", "<leader>te", "<cmd>Telescope<CR>")
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<CR>")
vim.keymap.set("n", "<leader>fds", "<cmd>Telescope lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>rg", "<cmd>Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>yv", "<cmd>YAMLView<CR>")
vim.keymap.set("n", "<leader>yt", "<cmd>YAMLTelescope<CR>")
vim.keymap.set("i", "<C-P>", "<cmd>Telescope git_files<CR>")
vim.keymap.set("n", "<C-P>", "<cmd>Telescope git_files<CR>")
