-- lua/config/lazy.lua
-- lazy.nvim bootstrap + setup

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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

require('lazy').setup({
  spec = {
    { import = 'plugins' },
  },
  defaults = {
    lazy = true,
  },
  checker = {
    enabled = true,
  },
  ui = {
    border = 'rounded',
  },
})
