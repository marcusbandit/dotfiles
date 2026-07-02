-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- <leader>x (toggle markdown checkbox) lives in after/ftplugin/markdown.lua

-- Move LazyVim's diagnostics/quickfix prefix from <leader>x to <leader>X,
-- freeing lowercase x for the checkbox toggle. The Trouble, todo-comments
-- and which-key parts of the move live in lua/plugins/diagnostics-keys.lua.
vim.keymap.del("n", "<leader>xl")
vim.keymap.del("n", "<leader>xq")

vim.keymap.set("n", "<leader>Xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

vim.keymap.set("n", "<leader>Xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })
