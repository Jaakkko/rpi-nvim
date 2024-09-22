local sections = {
  ['mappings'] = function()
    -- <leader>t for telescope commands
    -- <leader>s for treesitter commands
    vim.g.mapleader = '-'
    vim.g.maplocalleader = '¨'
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
    vim.keymap.set({ 's', 'c', 't', 'l' }, 'ö', '{', { remap = true })
    vim.keymap.set({ 's', 'c', 't', 'l' }, 'ä', '}', { remap = true })
    vim.keymap.set({ 's', 'c', 't', 'l' }, 'Ö', '[', { remap = true })
    vim.keymap.set({ 's', 'c', 't', 'l' }, 'Ä', ']', { remap = true })

    -- follow link
    vim.keymap.set('n', '<leader>l', '<c-]>', { desc = 'Follow link' })

    -- close buffer
    vim.keymap.set('n', '<leader>x', vim.cmd.bd, { desc = 'Close buffer' })
    vim.keymap.set('n', '<leader>X', ':%bd<cr>', { desc = 'Close all buffers' })

    -- v causes problems with snippets
    vim.keymap.set('x', 'J', ':m \'>+1<CR>gv=gv')
    vim.keymap.set('x', 'K', ':m \'<-2<CR>gv=gv')

    vim.keymap.set('n', '<C-d>', '<C-d>zz')
    vim.keymap.set('n', '<C-u>', '<C-u>zz')
    vim.keymap.set('n', 'n', 'nzzzv')
    vim.keymap.set('n', 'N', 'Nzzzv')
  end,
  ['settings'] = function()
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_cursor_animation_length = 0

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

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

    vim.opt.hlsearch = true
    vim.opt.incsearch = true

    vim.opt.termguicolors = true

    vim.opt.scrolloff = 1
    vim.opt.signcolumn = 'yes'

    -- vim.opt.imcmdline = true
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

    vim.cmd 'TSContextDisable'
  end,
  ['autocommands'] = function()
    vim.api.nvim_create_autocmd('DirChanged', {
      pattern = 'global',
      callback = function(args)
        require('nvim-tree.api').tree.change_root(args.file)
        require('lualine').refresh()
      end,
    })
    vim.api.nvim_create_autocmd('FocusLost', {
      pattern = { '*.c', '*.cpp', '*.h' },
      callback = function()
        vim.cmd 'wa!'
      end,
    })
  end,
  ['lsp'] = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.supports_method 'textDocument/formatting' then
          local bufopts = { buffer = args.buf, noremap = true, silent = true }
          vim.keymap.set({ 'n', 'v' }, '<leader>f', vim.lsp.buf.format, bufopts)
          -- Format the current buffer on save
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format { bufnr = args.buf, id = client.id }
            end,
          })
        end
      end,
    })
  end,
}

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup {
  spec = {
    {
      'nvimtools/none-ls.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local null_ls = require 'null-ls'
        null_ls.setup {
          sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.clang_format,
          },
        }
      end,
    },
    {
      'williamboman/mason.nvim',
      config = function()
        require('mason').setup()
      end,
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require('lualine').setup()
      end,
    },
    { 'numToStr/Comment.nvim' },
    { 'nvim-treesitter/nvim-treesitter-context' },
    {
      'nvim-treesitter/nvim-treesitter',
      config = function()
        require('nvim-treesitter.configs').setup {
          ensure_installed = { 'c', 'lua' },
          highlight = {
            enable = true,
          },
        }
      end,
    },
  },
  install = {},
  checker = { enabled = false },
}

for section, fn in pairs(sections) do
  fn()
end
