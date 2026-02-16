-- init.lua
-- Main Neovim configuration entry point

-- Leader keys (set before plugins)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Core options
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Plugin manager + plugin specs
require('config.lazy')
