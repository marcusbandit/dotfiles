" Set space as the leader key
let mapleader = " "

" Initialize packer for managing plugins
lua << EOF
  require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'              -- Packer itself
    use 'kyazdani42/nvim-tree.lua'            -- File tree view
    use 'nvim-treesitter/nvim-treesitter'     -- Syntax highlighting
    use 'neovim/nvim-lspconfig'               -- LSP configuration
    use 'hrsh7th/nvim-cmp'                    -- Autocompletion
    use 'hrsh7th/cmp-nvim-lsp'                -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-buffer'                  -- Buffer completions
    use 'nvim-lua/plenary.nvim'               -- Lua functions for plugins
    use 'nvim-telescope/telescope.nvim'       -- Fuzzy finder
    use 'onsails/lspkind.nvim'                -- Pictograms for autocomplete
    use { "catppuccin/nvim", as = "catppuccin" } -- Catppuccin theme
    use 'Exafunction/codeium.vim'             -- Codeium AI autocompletion
    use 'jose-elias-alvarez/null-ls.nvim'  -- Null-ls for formatters and linters
    use { '3rd/image.nvim', config = function() require'image'.setup{} end }
    use {
  'norcalli/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup({'*'}, {
      RGB = true,     -- #RGB hex codes
      RRGGBB = true,  -- #RRGGBB hex codes
      names = true,   -- "Name" codes like Blue
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      rgb_fn = true,  -- CSS rgb() and rgba() functions
      hsl_fn = true,  -- CSS hsl() and hsla() functions
      css = true,     -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = true,  -- Enable all CSS *functions*: rgb_fn, hsl_fn
      mode = 'background' -- Set the display mode (foreground, background)
    })
  end
}
    use {
  'j-hui/fidget.nvim', config = function()
    require('fidget').setup({
      text = {
        spinner = "dots",       -- Choose animation style (like dots, line, or circles)
        done = "✔️"              -- Symbol for completed tasks
      },
      align = {
        bottom = true,          -- Position at the bottom
        right = true            -- Position on the right
      },
      timer = {
        fidget_decay = 2000,    -- Delay before fading out completed tasks
      },
      fmt = {
        fidget = function(name) -- Customize the display text
          return "LSP: " .. name
        end,
      }
    })
  end
}

  end)
EOF

" Set general options
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set mouse=a             " Enable mouse
syntax on               " Syntax highlighting

" Theme setup
lua << EOF
  require('catppuccin').setup{}
  vim.cmd("colorscheme catppuccin")
EOF

" File tree setup (NvimTree)
nnoremap <leader>e :NvimTreeToggle<CR>
lua << EOF
  require'nvim-tree'.setup {
    view = { 
	width = 30, 
	side = 'left' 
    },
    filters = { dotfiles = false },
    update_focused_file = { enable = true }
  }
EOF

" LSP setup for autocompletion and language servers
lua << EOF
  local lspconfig = require'lspconfig'
  local cmp = require'cmp'
  local lspkind = require('lspkind')

  -- Configure LSP servers for popular languages
  local servers = { 'pyright', 'ts_ls', 'gopls', 'rust_analyzer', 'clangd', 'lua_ls' }
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup{}
  end

  -- Autocomplete settings
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)  -- For vsnip users
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    },
    formatting = {
      format = lspkind.cmp_format({ with_text = true, maxwidth = 50 })
    }
  })
EOF

" Telescope setup for file searching
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>fg :Telescope live_grep<CR>
nnoremap <leader>fb :Telescope buffers<CR>
nnoremap <leader>fh :Telescope help_tags<CR>

" Treesitter setup for syntax highlighting in all languages
lua << EOF
  require'nvim-treesitter.configs'.setup {
    ensure_installed = "all", -- Install all available parsers
    highlight = { enable = true },
    indent = { enable = true },
  }
EOF

" Codeium AI Autocomplete Setup
lua << EOF
  vim.g.codeium_enabled = true  -- Enable Codeium by default
  vim.api.nvim_set_keymap('i', '<C-g>', 'codeium#Accept()', { expr = true, noremap = true })
EOF


lua << EOF
  local null_ls = require("null-ls")

  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.prettier,    -- Prettier for JS, HTML, CSS, etc.
      null_ls.builtins.formatting.black,       -- Black for Python
      null_ls.builtins.formatting.shfmt,       -- shfmt for Shell scripts
      null_ls.builtins.formatting.stylua,      -- Stylua for Lua
    },
    on_attach = function(client, bufnr)
      if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", { noremap = true, silent = true })
      end
    end,
  })
EOF
call plug#begin('~/.local/share/nvim/plugged')
Plug 'chrisbra/csv.vim'
call plug#end()


set clipboard+=unnamedplus
let g:clipboard = {
       \ 'name': 'wl-clipboard',
       \ 'copy': {
       \   '+': 'wl-copy',
       \   '*': 'wl-copy',
       \ },
       \ 'paste': {
       \   '+': 'wl-paste --no-newline',
       \   '*': 'wl-paste --no-newline',
       \ },
       \ }

