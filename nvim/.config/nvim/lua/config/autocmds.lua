-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Use 2-space indentation for HTML files (override the global 4-space default)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Auto-format hyprland keybinds.conf on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/hyprland/keybinds.conf",
  callback = function()
    local filepath = vim.fn.expand("%:p")
    local script = vim.fn.expand("~") .. "/.config/hypr/hyprland/scripts/fmt_keybinds.py"
    vim.fn.system(
      "python3 " .. script .. " " .. filepath .. " > /tmp/.keybinds_fmt.conf && mv /tmp/.keybinds_fmt.conf " .. filepath
    )
    vim.cmd("silent! edit!")
  end,
})
