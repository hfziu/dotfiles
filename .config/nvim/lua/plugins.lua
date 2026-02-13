-- lua/plugins.lua
-- Plugin configuration using lazy.nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
  -- Oil.nvim for buffer-based file navigation
  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  -- Neo-tree for sidebar file explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      's1n7ax/nvim-window-picker',
    },
    config = function()
      require('neo-tree').setup({
        open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' },
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
          },
          window = {
            position = 'right',
            width = 30,
            mappings = {
              ["<cr>"] = "open_with_window_picker",
            },
          },
        },
      })
      -- Toggle file explorer
      vim.keymap.set('n', '<leader>e', '<CMD>Neotree toggle<CR>', { desc = 'Toggle file explorer' })
      -- Focus file explorer
      vim.keymap.set('n', '<leader>E', '<CMD>Neotree focus<CR>', { desc = 'Focus file explorer' })
    end,
  },

  -- GitHub Copilot
  'github/copilot.vim',

  -- Catppuccin theme (light variant)
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        flavour = 'frappe',
      })
      vim.cmd.colorscheme('catppuccin-frappe')
    end,
  },
}

-- Setup lazy.nvim
require('lazy').setup(plugins)
