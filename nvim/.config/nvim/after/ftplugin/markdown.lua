-- Toggle the task-list checkbox on the current line, from anywhere on it.
-- Only fires on a valid GFM task list item: optional indent, a list marker
-- (-, *, + or "1." / "1)"), then [ ] / [x] / [X] followed by whitespace or
-- end of line. Plain [x] in running text is left alone.
vim.keymap.set("n", "<leader>x", function()
  local line = vim.api.nvim_get_current_line()

  local prefix, box, rest = line:match("^(%s*[-*+]%s+)%[([ xX])%](.*)$")
  if not prefix then
    prefix, box, rest = line:match("^(%s*%d+[.%)]%s+)%[([ xX])%](.*)$")
  end
  if not prefix or (rest ~= "" and not rest:match("^%s")) then
    return
  end

  local toggled = box == " " and "x" or " "
  vim.api.nvim_set_current_line(prefix .. "[" .. toggled .. "]" .. rest)
end, { buffer = true, desc = "Toggle markdown checkbox" })
