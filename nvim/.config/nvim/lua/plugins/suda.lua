return {
  "lambdalisue/vim-suda",
  event = "BufRead",
  init = function()
    -- Auto-use sudo when the file isn't readable/writable by your user,
    -- so a plain :w on a root-owned file just works (no restart).
    vim.g.suda_smart_edit = 1
  end,
}
