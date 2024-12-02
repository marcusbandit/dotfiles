-- Bootstrap Packer
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Use Packer
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer manages itself

    -- Neovim essentials
    use 'nvim-lua/plenary.nvim' -- Dependency for many plugins
    use 'nvim-lua/popup.nvim' -- Popup API for Neovim

    -- File explorer
    use 'nvim-tree/nvim-tree.lua' -- Modern file explorer
    use 'kyazdani42/nvim-web-devicons' -- Fancy icons

    -- Status line
    use 'nvim-lualine/lualine.nvim' -- Beautiful and customizable status line

    -- Fuzzy Finder
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.2' } -- Fuzzy file search

    -- Syntax Highlighting
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- Modern syntax highlighting

    -- Git Integration
    use 'tpope/vim-fugitive' -- Git commands in Neovim
    use 'lewis6991/gitsigns.nvim' -- Git diff signs in the gutter

    -- Autocomplete
    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP completion
    use 'saadparwaiz1/cmp_luasnip' -- Snippets completion

    -- Snippets
    use 'L3MON4D3/LuaSnip' -- Snippet engine

    -- Language Server Protocol (LSP)
    use 'neovim/nvim-lspconfig' -- LSP configurations
    use 'williamboman/mason.nvim' -- LSP/DAP/Linters installer
    use 'williamboman/mason-lspconfig.nvim' -- Easy Mason + LSP integration

    -- Colorschemes
    use 'catppuccin/nvim' -- Catppuccin themes
    use 'morhetz/gruvbox' -- Gruvbox theme

    -- Auto-closing brackets and quotes
    use 'windwp/nvim-autopairs'

    -- Commenting
    use 'numToStr/Comment.nvim'

    -- Surround manipulation
    use 'kylechui/nvim-surround'

    -- Indentation guides
    use 'lukas-reineke/indent-blankline.nvim'

    -- Markdown Preview
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && npm install' }

    -- Better Filetype Checker
    use 'nathom/filetype.nvim'

    -- Shader handler
    use 'tikhomirov/vim-glsl'

    -- HEX tools
    use {
        'RRethy/vim-hexokinase',
        run = 'make hexokinase',
    }
    use 'norcalli/nvim-colorizer.lua'

    -- Color picker
    use {
        'ziontee113/color-picker.nvim',
        config = function()
            local picker = require("color-picker")

            -- Enable Color Picker
            picker.setup()

            -- Set Better Keybinds
            vim.keymap.set("n", "<Leader>c", "<cmd>PickColor<CR>", { noremap = true, silent = true, desc = "Pick a color" })
            vim.keymap.set("i", "<Leader>c", "<cmd>PickColorInsert<CR>", { noremap = true, silent = true, desc = "Pick a color in insert mode" })
        end,
    }


    -- Codeium
    use {
        'Exafunction/codeium.vim',
        config = function()
            local fn = vim.fn
            vim.keymap.set('i', '<M-a>', function() return fn['codeium#Accept']() end, { expr = true }) -- Accept suggestion
            vim.keymap.set('i', '<M-x>', function() return fn['codeium#Clear']() end, { expr = true }) -- Refuse/clear suggestion
            vim.keymap.set('i', '<M-.>', function() return fn end, { expr = true }) -- Forward
            vim.keymap.set('i', '<M-,>', function() return fn['codeium#CycleCompletions'](-1) end, { expr = true }) -- Backward
        end
    }


    -- Packer end
    if packer_bootstrap then
        require('packer').sync()
    end
end)


-- Set leader key to Space
--vim.g.mapleader = " "

-- Colorscheme with transparent background
vim.cmd("colorscheme catppuccin") -- Use your preferred colorscheme
vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- Transparent background
vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE") -- Optional: non-current windows
-- Syntax enabled
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

vim.g.Hexokinase_highlighters = { 'backgroundfull' }

-- Auto-detect specific files and set filetypes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    -- Patterns to match specific file types
    pattern = { "*.conf", ".bashrc" }, -- Match all .conf files and the .bashrc file
    callback = function(args)
        -- Check the file path to determine the appropriate filetype
        if args.file:match("%.conf$") then
            vim.bo.filetype = "conf" -- Set filetype to 'conf' for configuration files
        elseif args.file:match("%.bashrc$") then
            vim.bo.filetype = "sh" -- Set filetype to 'sh' (bash scripting) for .bashrc
        end
    end,
})




require('colorizer').setup({
    '*'; -- Enable for all file types
    css = {
        rgb_fn = true; -- Enable rgb(), rgba(), hsl(), hsla() functions
        mode = 'background'; -- Display the color in the background
    },
})




-- nvim-tree setup
local function on_attach(bufnr)
    local api = require('nvim-tree.api')
    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', 'i', api.tree.toggle_hidden_filter, opts('Toggle Hidden'))
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open with Enter')) -- Add Enter key functionality

    -- Keybindings
    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))  -- Create file
    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))  -- Delete file
    vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))  -- Rename file
    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))        -- Cut file
    vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy')) -- Copy file
end

-- Keymap for file tree
vim.keymap.set('n', '<Space>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Space>n', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })

require('nvim-tree').setup({
    on_attach = on_attach,
    renderer = {
        highlight_git = true,
        icons = {
            show = {
                file = true,
                folder = true,
                git = true,
            },
        },
    },
})





local parser_config = require("nvim-treesitter.parsers").get_parser_configs()


-- Map Tab to toggle between tree and text area
vim.keymap.set('n', '<Tab>', '<C-w>w', { noremap = true, silent = true })

-- Set global indentation preferences
vim.opt.expandtab = true     -- Use spaces instead of tabs
vim.opt.shiftwidth = 4       -- Number of spaces for each indentation step
vim.opt.tabstop = 4          -- Number of spaces a tab counts for
vim.opt.softtabstop = 4      -- Number of spaces inserted when Tab is pressed

-- Set line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Set clipboard to system clipboard
vim.opt.clipboard = "unnamedplus"

-- Set cursorline
vim.opt.cursorline = true

-- Set termguicolors
vim.opt.termguicolors = true


