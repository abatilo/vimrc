local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key, must be done before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  checker = { enabled = true },
  spec = {
    { -- Color scheme
      -- https://github.com/pwntester/octo.nvim/issues/1056#issuecomment-2802949386
      -- https://lazy.folke.io/spec/lazy_loading#-colorschemes
      'Mofiqul/dracula.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd([[colorscheme dracula]])
      end,
    },
    { -- Make it easy to align text by column
      'godlygeek/tabular',
    },
    { -- Track stats for wakatime.com
      'wakatime/vim-wakatime',
    },
    { -- Set project root
      'notjedi/nvim-rooter.lua',
      config = function()
        require('nvim-rooter').setup()
      end
    },
    { -- Go support
      'fatih/vim-go',
      build=":GoInstallBinaries",
    },
    { -- Git gutter helper
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup()
      end
    },
    { -- Manipulate around selected text
      'kylechui/nvim-surround',
      config = function()
        require('nvim-surround').setup()
      end
    },
    { -- Indent markers
      'folke/snacks.nvim',
      opts = {
        indent = {
          enabled = true,
          animate = { enabled = false },
        }
      },
    },
    { -- Make YAML easier
      'cuducos/yaml.nvim',
      ft = { "yaml" },
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim",
      },
    },
    { -- Add language aware parsing
      'nvim-treesitter/nvim-treesitter',
      build=':TSUpdate',
      config = function()
        require('nvim-treesitter.configs').setup(
          {
            ensure_installed = {
              "bash",
              "bicep",
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
              "rust",
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
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            }
          }
        )
      end
    },
    { -- <leader>gy to put GitHub URL into clipboard
      'ruifm/gitlinker.nvim',
      event='VeryLazy',
      dependencies={'nvim-lua/plenary.nvim'},
      config = function()
        require('gitlinker').setup({
          opts = {
            -- Make default mapping link to whole file, not just the current line
            add_current_line_on_normal_mode = false
          },
          mappings = "<leader>gy"
        })
      end
    },
    { -- Status line
      'nvim-lualine/lualine.nvim',
      dependencies={'nvim-tree/nvim-web-devicons'},
    },
    { -- Tree file viewer
      'nvim-tree/nvim-tree.lua',
      event='VeryLazy',
      dependencies={'nvim-tree/nvim-web-devicons'},
      config = function()
        require('nvim-tree').setup({
          filters = {
            custom = {"^\\.git"}
          },
          live_filter = {
            always_show_folders = false
          }
        })
      end
    },
    { -- Telescope sorting and matching with fzf
      'nvim-telescope/telescope-fzf-native.nvim',
      event='VeryLazy',
      build='make'
    },
    { -- Replace native vim select UI with telescope's
      'nvim-telescope/telescope-ui-select.nvim'
    },
    { -- Fuzzy finder
      'nvim-telescope/telescope.nvim',
      event='VeryLazy',
      branch='0.1.x',
      dependencies={'nvim-lua/plenary.nvim'},
      config = function()
        require('telescope').setup()
        require('telescope').load_extension('fzf')
        require("telescope").load_extension("ui-select")
      end
    },
    { -- Add some missing commentstrings
      "folke/ts-comments.nvim",
      event = "VeryLazy",
      opts = {},
    },
    { -- Configure LSP
      'neovim/nvim-lspconfig'
    },
    { -- Auto format code
      'lukas-reineke/lsp-format.nvim',
      config = function()
        require('lsp-format').setup()
      end
    },
    { -- Null language server for additional LSP config
      'nvimtools/none-ls.nvim',
      event='VeryLazy',
      config = function()
        local lsp_formatting = function(bufnr)
          vim.lsp.buf.format({
            filter = function(client)
              -- Only format using null-ls instead of built in LSP formatter
              return client.name == "null-ls"
            end,
            bufnr = bufnr,
          })
        end
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        require("null-ls").setup({
          -- Available sources:
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/47c04991af80b6acdf08a5db057908b52f4d0699/doc/BUILTINS.md
          sources = {
            -- General
            require("null-ls").builtins.diagnostics.actionlint,
            require("null-ls").builtins.diagnostics.gitlint,
            require("null-ls").builtins.diagnostics.hadolint,
            require("null-ls").builtins.diagnostics.trail_space,

            -- Go
            require("null-ls").builtins.diagnostics.golangci_lint,
            require("null-ls").builtins.diagnostics.staticcheck,
            require("null-ls").builtins.formatting.gofmt,
            require("null-ls").builtins.formatting.goimports,

            -- Python
            require("null-ls").builtins.formatting.black,
            require("null-ls").builtins.formatting.isort,
          },
          -- you can reuse a shared lspconfig on_attach callback here
          on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
              vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                  lsp_formatting(bufnr)
                end,
              })
            end
          end,
        })
      end
    },
    { -- Install LSP servers
      'williamboman/mason.nvim',
      event='VeryLazy',
      config = function()
        require("mason").setup()
      end
    },
    { -- For mason + lspconfig
      'williamboman/mason-lspconfig.nvim',
      event='VeryLazy',
      config = function()
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
          buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
          buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
          buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
          buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

          require('lsp-format').on_attach(client)
        end

        local function config(_config)
          return vim.tbl_deep_extend("force", {
            capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
            on_attach = on_attach,
          }, _config or {})
        end

        local servers = {
          "bashls",
          "diagnosticls",
          "dockerls",
          "gopls",
          "helm_ls",
          "html",
          "jsonls",
          "rust_analyzer",
          "tailwindcss",
          "terraformls",
          "tflint",
          "ts_ls",
          "ty",
          "yamlls",
        }

        for _, lsp in pairs(servers) do
          require('lspconfig')[lsp].setup(config())
        end

        require("mason-lspconfig").setup {
          ensure_installed = servers,
        }
      end
    },
    { -- Completion
      'hrsh7th/nvim-cmp',
      config = function()
        local cmp = require('cmp')
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
      end
    },
    { -- Snippet engine
      'hrsh7th/vim-vsnip',
    },
    { -- Snippet completion
      'hrsh7th/cmp-vsnip',
    },
    { -- Completion lsp source
      'hrsh7th/cmp-nvim-lsp',
    },
    { -- Completion buffer source
      'hrsh7th/cmp-buffer',
    },
    { -- Completion path source
      'hrsh7th/cmp-path',
    },
    { -- For declaratively installing mason tools
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      config = function()
        local mason_tools = {
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
          "ty",
          "typescript-language-server",
          "vim-language-server",
          "yaml-language-server",
        }

        require("mason-tool-installer").setup {
          auto_update = true,
          ensure_installed = mason_tools,
        }
      end
    },
    { -- GitHub UI within neovim
      'pwntester/octo.nvim',
      dependencies={
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'nvim-tree/nvim-web-devicons',
      },
      config = function()
        require('octo').setup({
          default_to_projects_v2 = true
        })
      end
    },
  }
})

-- Decide where the root of a project is
vim.g.rooter_patterns = {'.git'}

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
vim.keymap.set('n', '<leader><CR>', '<cmd>nohlsearch<CR>')

-- Keep long term undo history
vim.opt.undofile = true

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 50

-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"

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

vim.keymap.set('n', '<C-N>', '<cmd>NvimTreeFindFileToggle<CR>')
vim.keymap.set('n', '<leader>te', '<cmd>Telescope<CR>')
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files hidden=true<CR>')
vim.keymap.set('n', '<leader>fds', '<cmd>Telescope lsp_document_symbols<CR>')
vim.keymap.set('n', '<leader>rg', '<cmd>Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>yv', '<cmd>YAMLView<CR>')
vim.keymap.set('n', '<leader>yt', '<cmd>YAMLTelescope<CR>')
vim.keymap.set('i', '<C-P>', '<cmd>Telescope git_files<CR>')
vim.keymap.set('n', '<C-P>', '<cmd>Telescope git_files<CR>')
