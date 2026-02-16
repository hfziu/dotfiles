return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      's1n7ax/nvim-window-picker',
    },
    opts = {
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
            ['<cr>'] = 'open_with_window_picker',
          },
        },
      },
    },
    keys = {
      { '<leader>e', '<CMD>Neotree toggle<CR>', desc = 'Toggle file explorer' },
      { '<leader>E', '<CMD>Neotree focus<CR>', desc = 'Focus file explorer' },
    },
  },
}
