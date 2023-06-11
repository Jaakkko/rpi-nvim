local sections = {
  ['mappings'] = function()
    -- <leader>t for telescope commands
    -- <leader>s for treesitter commands
    vim.g.mapleader = '¨'
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

    -- follow link
    vim.keymap.set('n', '<leader>l', '<c-]>', { desc = 'Follow link' })

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

    vim.opt.ignorecase = true
    vim.opt.wildignorecase = true
    vim.opt.nu = true
    vim.opt.rnu = true

    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.softtabstop = 2
    vim.opt.expandtab = true
    vim.opt.smartindent = true

    vim.opt.wrap = false

    vim.opt.updatetime = 100
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = os.getenv 'HOME' .. '/.vim/undodir'
    vim.opt.undofile = true

    vim.opt.hlsearch = false
    vim.opt.incsearch = true

    vim.opt.termguicolors = true

    vim.opt.scrolloff = 1
    vim.opt.signcolumn = 'yes'

    vim.opt.imcmdline = true
    vim.opt.iminsert = 1
    vim.opt.timeout = true
    vim.opt.timeoutlen = 200

    vim.opt.guifont = 'JetBrainsMonoNL Nerd Font Propo:h12'
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
    use {
      'wbthomason/packer.nvim',
      config = function()
        require('colorizer').setup()
      end,
    }
    use 'norcalli/nvim-colorizer.lua'
    use 'nvim-tree/nvim-web-devicons'
    use {
      'lewis6991/gitsigns.nvim',
      config = function()
        require('gitsigns').setup {
          on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', '<C-j>', function()
              if vim.wo.diff then
                return '<C-j>'
              end
              vim.schedule(function()
                gs.next_hunk()
              end)
              return '<Ignore>'
            end, { expr = true })

            map('n', '<C-k>', function()
              if vim.wo.diff then
                return '<C-k>'
              end
              vim.schedule(function()
                gs.prev_hunk()
              end)
              return '<Ignore>'
            end, { expr = true })

            local stage_hunk_visual = function()
              gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end
            local reset_hunk_visual = function()
              gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end
            local blame_line = function()
              gs.blame_line { full = true }
            end
            local diff_against_last_commit = function()
              gs.diffthis '~'
            end

            -- Actions
            map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
            map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
            map('v', '<leader>gs', stage_hunk_visual, { desc = 'Stage hunk' })
            map('v', '<leader>gr', reset_hunk_visual, { desc = 'Reset hunk' })
            map('n', '<leader>gS', gs.stage_buffer, { desc = 'Stage buffer' })
            map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
            map('n', '<leader>gR', gs.reset_buffer, { desc = 'Reset buffer' })
            map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
            map('n', '<leader>gb', blame_line, { desc = 'Blame line' })
            map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'Toggle blame' })
            map('n', '<leader>gd', gs.diffthis, { desc = 'Diff' })
            map('n', '<leader>gD', diff_against_last_commit, { desc = 'Diff' })
            map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'Toggle deleted' })

            -- Text object
            -- map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end,
        }
      end,
    }
    use {
      'rebelot/kanagawa.nvim',
      config = function()
        vim.cmd 'colorscheme kanagawa-dragon'
      end,
    }
    use {
      'folke/which-key.nvim',
      config = function()
        local wk = require 'which-key'
        wk.setup {
          plugins = {
            presets = {
              operators = false,
            },
          },
          triggers_nowait = {
            -- marks
            '`',
            '\'',
            'g`',
            'g\'',
            -- spelling
            'z=',
          },
        }
        wk.register({
          t = { name = 'Telescope' },
          s = {
            name = 'Treesitter',
            d = 'Goto definition',
            D = 'List definitions',
            O = 'List definitions TOC',
            r = 'Rename',
          },
          g = {
            name = 'Gitsigns',
          },
        }, {
          prefix = '<leader>',
          mode = 'n',
        })
      end,
    }
    use {
      'akinsho/toggleterm.nvim',
      tag = '*',
      config = function()
        require('toggleterm').setup()
        vim.keymap.set({ 'n', 't' }, '<leader>a', vim.cmd.ToggleTerm)
      end,
    }
    use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
        local ts_update = require('nvim-treesitter.install').update { with_sync = true }
        ts_update()
      end,
      config = function()
        -- bracket matching??? gF ~/leetcode/valid_parenthesis/src/main.rs:33
        require('nvim-treesitter.configs').setup {
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = 'gnn', -- set to `false` to disable one of the mappings
              none_incremental = 'grn',
              scope_incremental = 'grc',
              node_decremental = 'grm',
            },
          },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        }
      end,
    }
    use 'nvim-treesitter/playground'
    use 'nvim-treesitter/nvim-treesitter-context'
    use {
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
      requires = 'nvim-treesitter/nvim-treesitter',
      config = function()
        require('nvim-treesitter.configs').setup {
          textobjects = {
            move = {
              enable = true,
              set_jumps = true,
              goto_next_start = { ['Ä'] = '@object_property' },
              goto_previous_start = { ['Ö'] = '@object_property' },
            },
            select = {
              enable = true,
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['aj'] = '@parameter.outer',
                ['ij'] = '@parameter.inner',
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
      config = function()
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>th', builtin.command_history, { desc = 'Command history' })
        vim.keymap.set('n', '<leader>tb', builtin.buffers, { desc = 'Buffers' })
        vim.keymap.set('n', '<leader>tfs', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy find current file' })
        vim.keymap.set('n', '<leader>tps', builtin.live_grep, { desc = 'Fuzzy find current working directory' })
        vim.keymap.set('n', '<C-p>', function()
          builtin.git_files { show_untracked = true }
        end, { desc = 'Find file' })
      end,
    }
    use {
      'nvim-treesitter/nvim-treesitter-refactor',
      after = 'nvim-treesitter',
      config = function()
        require('nvim-treesitter.configs').setup {
          refactor = {
            navigation = {
              enable = true,
              -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
              keymaps = {
                goto_definition = '<leader>sd',
                list_definitions = '<leader>sD',
                list_definitions_toc = '<leader>sO',
                goto_next_usage = '<A-ä>',
                goto_previous_usage = '<A-ö>',
              },
            },
            highlight_definitions = {
              enable = true,
              -- Set to false if you have an `updatetime` of ~100.
              clear_on_cursor_move = false,
            },
            smart_rename = {
              enable = true,
              -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
              keymaps = {
                smart_rename = '<leader>sr',
              },
            },
          },
        }
      end,
    }
    use {
      'jose-elias-alvarez/null-ls.nvim',
      config = function()
        local null_ls = require 'null-ls'
        null_ls.setup {
          sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.code_actions.gitsigns,
          },
        }
      end,
    }
    use {
      'windwp/nvim-autopairs',
      after = 'nvim-treesitter',
      config = function()
        require('nvim-autopairs').setup {
          enable_afterquote = false,
          check_ts = true,
          ts_config = {
            rust = { 'char_literal' },
          },
        }
      end,
    }
    use_rocks 'jsregexp'
    use {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/nvim-cmp',
      'simrat39/rust-tools.nvim',
    }
  end,
  ['cmp'] = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    luasnip.setup {
      region_check_events = 'CursorHold,InsertLeave',
      -- those are for removing deleted snippets, also a common problem
      delete_check_events = 'TextChanged,InsertEnter',
      enable_autosnippets = true,
    }

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
  end,
  ['lsp'] = function()
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require 'lspconfig'
    local lsp_attach = function(_, bufnr)
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.format, bufopts)
    end
    require('mason').setup()
    require('mason-lspconfig').setup {
      ensure_installed = {
        'lua_ls',
        'rust_analyzer',
      },
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
              vim.keymap.set('n', '<leader>la', rt.code_action_group.code_action_group, { buffer = bufnr })
              return lsp_attach(client, bufnr)
            end,
            capabilities = lsp_capabilities,
          },
        }
      end,
    }
  end,
}

for section, fn in pairs(sections) do
  if section ~= 'plugins' then
    fn()
  else
    require('packer').startup(fn)
  end
end
