-- LazyVim's markdown extra strips render-markdown's heading icons
-- (heading.icons = {}), leaving raw ### markers. Restore the plugin's
-- default per-level nerd-font icons.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
    },
  },
}
