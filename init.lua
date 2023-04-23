local sections = {
  ['mappings'] = function()
    vim.g.mapleader = '§'
    vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

    vim.keymap.set('', '$', '<End>')
    vim.keymap.set('', '0', '<Home>')
    vim.keymap.set('', 'ä', '$', { remap = true })
    vim.keymap.set('', 'ö', '0', { remap = true })

    -- remap <ESC> to å
    -- x, s instead of v to make å work
    vim.keymap.set({ 'c', 'x', 's', 't', 'l' }, '<ESC>', '<NOP>')
    vim.keymap.set({ 'c', 'x', 's', 't', 'l' }, 'å', '<ESC>')

    --
    vim.keymap.set('n', '<A-l>', vim.cmd.tabnext)
    vim.keymap.set('n', '<A-h>', vim.cmd.tabprevious)

    -- l for r,f and t commands
    -- c for cmd-line
    vim.keymap.set({ 'c', 't', 'l' }, 'ö', '{', { remap = true })
    vim.keymap.set({ 'c', 't', 'l' }, 'ä', '}', { remap = true })
    vim.keymap.set({ 'c', 't', 'l' }, 'Ö', '[', { remap = true })
    vim.keymap.set({ 'c', 't', 'l' }, 'Ä', ']', { remap = true })

    vim.keymap.set('n', '<leader>l', '<c-]>')

    vim.keymap.set('n', '<leader>sh', '<cmd>set hlsearch!<cr>')
    vim.keymap.set('n', '<leader>sc', '<cmd>noh<cr>')

    -- v causes problems with snippets
    vim.keymap.set('x', 'J', ':m \'>+1<CR>gv=gv')
    vim.keymap.set('x', 'K', ':m \'<-2<CR>gv=gv')

    vim.keymap.set('n', '<C-d>', '<C-d>zz')
    vim.keymap.set('n', '<C-u>', '<C-u>zz')
    vim.keymap.set('n', 'n', 'nzzzv')
    vim.keymap.set('n', 'N', 'Nzzzv')

    vim.keymap.set('n', '<F12>', vim.cmd.SearchSession)
  end,
  ['settings'] = function()
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_cursor_animation_length = 0

    vim.opt.background = 'dark'

    vim.opt.wildignorecase = true
    vim.opt.nu = true
    vim.opt.rnu = true

    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.softtabstop = 2
    vim.opt.expandtab = true

    vim.opt.smartindent = true

    vim.opt.wrap = false

    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = os.getenv 'HOME' .. '/.vim/undodir'
    vim.opt.undofile = true

    vim.opt.hlsearch = false
    vim.opt.incsearch = true

    vim.opt.termguicolors = true

    vim.opt.scrolloff = 8
    vim.opt.signcolumn = 'yes'

    vim.opt.imcmdline = true
    vim.opt.iminsert = 1
    vim.opt.hlsearch = false
    vim.opt.timeout = false
    vim.opt.guifont = 'JetBrainsMonoNL NF:h12'
    vim.opt.mouse = 'vni'

    vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
    vim.opt.sessionoptions = {
      'blank',
      'buffers',
      'curdir',
      'folds',
      'help',
      'tabpages',
      'winsize',
      'winpos',
      'terminal',
      'localoptions',
    }

    vim.opt.laststatus = 3

    vim.opt.autoread = true
  end,
  ['plugins'] = function(use)
    use 'wbthomason/packer.nvim'
    use {
      'rebelot/kanagawa.nvim',
      config = function()
        vim.cmd 'colorscheme kanagawa-dragon'
      end,
    }
    use {
      'akinsho/toggleterm.nvim',
      tag = '*',
      config = function()
        local open = { vim.cmd.write, vim.cmd.ToggleTerm }
        local close = { vim.cmd.ToggleTerm }
        local mode = open
        require('toggleterm').setup {
          on_open = function()
            mode = close
          end,
          on_close = function()
            mode = open
          end,
        }
        vim.keymap.set({ 'n', 't' }, '<leader>t', function()
          for _, fn in ipairs(mode) do
            fn()
          end
        end)
      end,
    }
    use {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
    }
    use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
        local ts_update = require('nvim-treesitter.install').update { with_sync = true }
        ts_update()
      end,
      config = function()
        require('nvim-treesitter.configs').setup {
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = 'gnn', -- set to `false` to disable one of the mappings
              node_incremental = 'grn',
              scope_incremental = 'grc',
              node_decremental = 'grm',
            },
          },
        }
      end,
    }
    use {
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        require('nvim-treesitter.configs').setup {
          refactor = {
            navigation = {
              enable = true,
              -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
              keymaps = {
                goto_definition = 'gnd',
                list_definitions = 'gnD',
                list_definitions_toc = 'gO',
                goto_next_usage = '<a-*>',
                goto_previous_usage = '<a-#>',
              },
            },
          },
        }
      end,
    }
    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
      requires = 'nvim-treesitter/nvim-treesitter',
      config = function()
        require('nvim-treesitter.configs').setup {
          textobjects = {
            select = {
              enable = true,
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                -- You can optionally set descriptions to the mappings (used in the desc parameter of
                -- nvim_buf_set_keymap) which plugins like which-key display
                ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
                -- You can also use captures from other query groups like `locals.scm`
                -- ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
              },
              include_surrounding_whitespace = true,
            },
          },
        }
      end,
    }
    use 'nvim-lua/plenary.nvim'
    use {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.1',
      requires = { { 'nvim-lua/plenary.nvim' } },
    }
    use 'jose-elias-alvarez/null-ls.nvim'
    use_rocks 'jsregexp'
    use 'L3MON4D3/LuaSnip'
    use 'rafamadriz/friendly-snippets'
    use 'saadparwaiz1/cmp_luasnip'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/nvim-cmp'
    use 'windwp/nvim-autopairs'
    use 'simrat39/rust-tools.nvim'
  end,
}

for section, fn in pairs(sections) do
  if section ~= 'plugins' then
    fn()
  else
    require('packer').startup(fn)
  end
end

local cmp = require 'cmp'
local luasnip = require 'luasnip'
luasnip.setup {
  region_check_events = 'CursorHold,InsertLeave',
  -- those are for removing deleted snippets, also a common problem
  delete_check_events = 'TextChanged,InsertEnter',
  enable_autosnippets = true,
}

-- autopairs
require('nvim-autopairs').setup()
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function(fallback)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.menu = ({
        copilot = '[Copilot]',
        luasnip = 'LuaSnip',
        nvim_lua = '[NVim Lua]',
        nvim_lsp = '[LSP]',
        buffer = '[Buffer]',
        path = '[Path]',
      })[entry.source.name]
      return vim_item
    end,
  },
  sources = cmp.config.sources {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  experimental = {
    ghost_text = true,
  },
}

local null_ls = require 'null-ls'
null_ls.setup {
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.code_actions.gitsigns,
  },
}
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require 'lspconfig'
local lsp_attach = function(_, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format { async = true }
  end, bufopts)
end

require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = { 'lua_ls', 'rust_analyzer' },
}
require('mason-lspconfig').setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
    }
  end,
  ['lua_ls'] = function()
    lspconfig.lua_ls.setup {
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
          completion = {
            callSnippet = 'Both',
          },
        },
      },
    }
  end,
  ['rust_analyzer'] = function()
    local rt = require 'rust-tools'
    rt.setup {
      server = {
        on_attach = function(client, bufnr)
          vim.keymap.set('n', '<C-space>', rt.hover_actions.hover_actions, { buffer = bufnr })
          vim.keymap.set('n', '<leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
          return lsp_attach(client, bufnr)
        end,
        capabilities = lsp_capabilities,
      },
    }
  end,
}
