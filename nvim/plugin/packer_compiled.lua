-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/bandit/.cache/nvim/packer_hererocks/2.1.1727870382/share/lua/5.1/?.lua;/home/bandit/.cache/nvim/packer_hererocks/2.1.1727870382/share/lua/5.1/?/init.lua;/home/bandit/.cache/nvim/packer_hererocks/2.1.1727870382/lib/luarocks/rocks-5.1/?.lua;/home/bandit/.cache/nvim/packer_hererocks/2.1.1727870382/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/bandit/.cache/nvim/packer_hererocks/2.1.1727870382/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  LuaSnip = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["codeium.vim"] = {
    config = { "\27LJ\2\n$\0\0\2\1\1\0\3-\0\0\0009\0\0\0D\0\1\0\0À\19codeium#Accept#\0\0\2\1\1\0\3-\0\0\0009\0\0\0D\0\1\0\0À\18codeium#Clear\17\0\0\1\1\0\0\2-\0\0\0L\0\2\0\0À2\0\0\3\1\1\0\4-\0\0\0009\0\0\0)\2ÿÿD\0\2\0\0À\29codeium#CycleCompletionsë\1\1\0\a\0\17\0$6\0\0\0009\0\1\0006\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\5\0003\5\6\0005\6\a\0B\1\5\0016\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\b\0003\5\t\0005\6\n\0B\1\5\0016\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\v\0003\5\f\0005\6\r\0B\1\5\0016\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\14\0003\5\15\0005\6\16\0B\1\5\0012\0\0€K\0\1\0\1\0\1\texpr\2\0\n<M-,>\1\0\1\texpr\2\0\n<M-.>\1\0\1\texpr\2\0\n<M-x>\1\0\1\texpr\2\0\n<M-a>\6i\bset\vkeymap\afn\bvim\0" },
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/codeium.vim",
    url = "https://github.com/Exafunction/codeium.vim"
  },
  ["color-picker.nvim"] = {
    config = { "\27LJ\2\nž\2\0\0\a\0\r\0\0226\0\0\0'\2\1\0B\0\2\0029\1\2\0B\1\1\0016\1\3\0009\1\4\0019\1\5\1'\3\6\0'\4\a\0'\5\b\0005\6\t\0B\1\5\0016\1\3\0009\1\4\0019\1\5\1'\3\n\0'\4\a\0'\5\v\0005\6\f\0B\1\5\1K\0\1\0\1\0\3\fnoremap\2\tdesc Pick a color in insert mode\vsilent\2\29<cmd>PickColorInsert<CR>\6i\1\0\3\fnoremap\2\tdesc\17Pick a color\vsilent\2\23<cmd>PickColor<CR>\14<Leader>c\6n\bset\vkeymap\bvim\nsetup\17color-picker\frequire\0" },
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/color-picker.nvim",
    url = "https://github.com/ziontee113/color-picker.nvim"
  },
  ["filetype.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/filetype.nvim",
    url = "https://github.com/nathom/filetype.nvim"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  gruvbox = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "https://github.com/morhetz/gruvbox"
  },
  ["indent-blankline.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  nvim = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim",
    url = "https://github.com/catppuccin/nvim"
  },
  ["nvim-autopairs"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-surround"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-surround",
    url = "https://github.com/kylechui/nvim-surround"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-glsl"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/vim-glsl",
    url = "https://github.com/tikhomirov/vim-glsl"
  },
  ["vim-hexokinase"] = {
    loaded = true,
    path = "/home/bandit/.local/share/nvim/site/pack/packer/start/vim-hexokinase",
    url = "https://github.com/RRethy/vim-hexokinase"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: color-picker.nvim
time([[Config for color-picker.nvim]], true)
try_loadstring("\27LJ\2\nž\2\0\0\a\0\r\0\0226\0\0\0'\2\1\0B\0\2\0029\1\2\0B\1\1\0016\1\3\0009\1\4\0019\1\5\1'\3\6\0'\4\a\0'\5\b\0005\6\t\0B\1\5\0016\1\3\0009\1\4\0019\1\5\1'\3\n\0'\4\a\0'\5\v\0005\6\f\0B\1\5\1K\0\1\0\1\0\3\fnoremap\2\tdesc Pick a color in insert mode\vsilent\2\29<cmd>PickColorInsert<CR>\6i\1\0\3\fnoremap\2\tdesc\17Pick a color\vsilent\2\23<cmd>PickColor<CR>\14<Leader>c\6n\bset\vkeymap\bvim\nsetup\17color-picker\frequire\0", "config", "color-picker.nvim")
time([[Config for color-picker.nvim]], false)
-- Config for: codeium.vim
time([[Config for codeium.vim]], true)
try_loadstring("\27LJ\2\n$\0\0\2\1\1\0\3-\0\0\0009\0\0\0D\0\1\0\0À\19codeium#Accept#\0\0\2\1\1\0\3-\0\0\0009\0\0\0D\0\1\0\0À\18codeium#Clear\17\0\0\1\1\0\0\2-\0\0\0L\0\2\0\0À2\0\0\3\1\1\0\4-\0\0\0009\0\0\0)\2ÿÿD\0\2\0\0À\29codeium#CycleCompletionsë\1\1\0\a\0\17\0$6\0\0\0009\0\1\0006\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\5\0003\5\6\0005\6\a\0B\1\5\0016\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\b\0003\5\t\0005\6\n\0B\1\5\0016\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\v\0003\5\f\0005\6\r\0B\1\5\0016\1\0\0009\1\2\0019\1\3\1'\3\4\0'\4\14\0003\5\15\0005\6\16\0B\1\5\0012\0\0€K\0\1\0\1\0\1\texpr\2\0\n<M-,>\1\0\1\texpr\2\0\n<M-.>\1\0\1\texpr\2\0\n<M-x>\1\0\1\texpr\2\0\n<M-a>\6i\bset\vkeymap\afn\bvim\0", "config", "codeium.vim")
time([[Config for codeium.vim]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
