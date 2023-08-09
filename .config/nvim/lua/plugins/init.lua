-- Install plugins using Packer

require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'p00f/clangd_extensions.nvim'
  require('plugins.lsp')

  -- Completion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'L3MON4D3/LuaSnip'
  require('plugins.completion')

  -- Color schemes
  use {'dracula/vim', as = 'dracula'}

  -- File explorer - nvim-tree: a file explorer tree for neovim written in lua 
  use {
    'kyazdani42/nvim-tree.lua',
    -- requires = {
    --   'kyazdani42/nvim-web-devicons', -- optional, for file icon
    -- },
    config = function() require'nvim-tree'.setup {} end
}
end)