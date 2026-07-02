-- Move the diagnostics/quickfix keys from <leader>x to <leader>X so that
-- lowercase <leader>x is free for the markdown checkbox toggle
-- (after/ftplugin/markdown.lua). The two core LazyVim maps (xl, xq) are
-- moved in lua/config/keymaps.lua.
return {
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xx", false },
      { "<leader>xX", false },
      { "<leader>xL", false },
      { "<leader>xQ", false },
      { "<leader>Xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>XX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>XL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>XQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },
  {
    "folke/todo-comments.nvim",
    keys = {
      { "<leader>xt", false },
      { "<leader>xT", false },
      { "<leader>Xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      { "<leader>XT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      local function rename(entries)
        for _, e in ipairs(entries) do
          if type(e) == "table" then
            if e[1] == "<leader>x" and e.group then
              e[1] = "<leader>X"
            end
            rename(e)
          end
        end
      end
      rename(opts.spec or {})
    end,
  },
}
