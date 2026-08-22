-- Make find files / grep work under ~/.config: include hidden files and
-- follow symlinks (e.g. ~/.config/quickshell -> ~/dotfiles/qs/...).
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true, follow = true },
          grep = { hidden = true, follow = true },
          grep_word = { hidden = true, follow = true },
          smart = { hidden = true, follow = true },
        },
      },
    },
  },
}
