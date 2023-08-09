local M = {}

function M.config()
    -- Setup nvim-cmp.
    local cmp = require'cmp'
    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
            -- luasnip
            require('luasnip').lsp_expand(args.body)
            end,
        },
        mapping = {
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable,
            ['<C-e>'] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
            }),
            -- Accept currently selected item...
            -- Set `select` to `false` to only confirm explicitly selected items:
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            -- { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        }, {{ name = 'buffer' }})
    })

    -- You can also set special config for specific filetypes:
--    cmp.setup.filetype('gitcommit', {
--        sources = cmp.config.sources({
--            { name = 'cmp_git' },
--        }, {
--            { name = 'buffer' },
--        })
--    })

    -- nvim-cmp for commands
    cmp.setup.cmdline('/', {
        sources = {
            { name = 'buffer' }
        }
    })
    cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

end

return M
