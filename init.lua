-- Modeline
-- vim: ts=2 sts=2 sw=2 et nowrap

-- ====================== Basic Setup ======================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ====================== Options ======================
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = true
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '>>', trail = '·', nbsp = '␣' }
vim.opt.scrolloff = 10

-- Suppress LSP log level to remove deprecation warnings
vim.lsp.set_log_level("error")

-- ====================== Basic Keymaps ======================
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- ====================== Install Lazy.nvim ======================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ====================== Plugin Configuration ======================
require('lazy').setup({
  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/nvim-cmp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'ts_ls',  -- Updated from tsserver
          'eslint',
          'cssls',
          'html',
          'jsonls',
          'gopls',
          'lua_ls',
        },
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      -- Setup language servers
      local servers = {
        ts_ls = {},  -- Updated from tsserver
        eslint = {},
        cssls = {},
        html = {},
        jsonls = {},
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              usePlaceholders = true,
              completeUnimported = true,
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- Setup nvim-cmp
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Essential plugins
  { 'tpope/vim-sleuth' },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Which-key
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup({
        plugins = {
          spelling = true,
          presets = {
            operators = false,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
      })
    end,
  },

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'javascript',
          'typescript',
          'tsx',
          'html',
          'css',
          'json',
          'lua',
          'markdown',
          'markdown_inline',
          'go',
          'rust',
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- MERN Stack Specific Plugins
  {
    'prettier/vim-prettier',
    build = 'yarn install --frozen-lockfile --production',
    ft = {
      'javascript',
      'typescript',
      'css',
      'less',
      'scss',
      'json',
      'graphql',
      'markdown',
      'vue',
      'yaml',
      'html',
      'jsx',
      'tsx',
    },
  },

  -- JavaScript/TypeScript support
  {
    'jose-elias-alvarez/typescript.nvim',
    ft = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
    },
  },

  -- Enhanced JavaScript and JSX syntax
  {
    'yuezk/vim-js',
    ft = { 'javascript', 'javascriptreact' },
  },

  {
    'maxmellon/vim-jsx-pretty',
    ft = { 'javascriptreact', 'typescriptreact' },
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({})
    end,
  },

  -- Color scheme
  {
    'gruvbox-community/gruvbox',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('gruvbox')
      vim.o.background = 'dark'
    end,
  },
})

-- ====================== Custom Commands ======================
vim.api.nvim_create_user_command('A', function()
  local file = vim.fn.expand('%')
  if file:match('%.go$') then
    vim.cmd('split | terminal go run ' .. file)
  else
    vim.notify('Not a Go file!', vim.log.levels.ERROR)
  end
end, { desc = 'Run current Go file with :A' })

-- Node.js specific commands
vim.api.nvim_create_user_command('NodeRun', function()
  vim.cmd('split | terminal node ' .. vim.fn.expand('%'))
end, { desc = 'Run current Node.js file' })

vim.api.nvim_create_user_command('NpmStart', function()
  vim.cmd('split | terminal npm start')
end, { desc = 'Run npm start' })

vim.api.nvim_create_user_command('NpmDev', function()
  vim.cmd('split | terminal npm run dev')
end, { desc = 'Run npm run dev' })

-- ====================== Custom Keymaps ======================
-- File navigation
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'Help tags' })

-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format code' })

-- TypeScript specific keymaps
vim.keymap.set('n', '<leader>ji', '<cmd>TypescriptAddMissingImports<CR>', { desc = 'Add missing imports' })
vim.keymap.set('n', '<leader>jo', '<cmd>TypescriptOrganizeImports<CR>', { desc = 'Organize imports' })
vim.keymap.set('n', '<leader>jf', '<cmd>TypescriptFixAll<CR>', { desc = 'Fix all' })

-- ====================== Autocommands ======================
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("TS_add_missing_imports", { clear = true }),
  desc = "TS_add_missing_imports",
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function()
    vim.cmd([[TSToolsAddMissingImports]])
    vim.cmd("write")
  end,
})
