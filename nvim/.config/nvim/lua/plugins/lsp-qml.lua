return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        qmlls = {
          -- Your Qt6 language server is named qmlls6, not the default "qmlls".
          -- -E makes it read QML_IMPORT_PATH so it can find extra modules
          -- (useful later for Quickshell types, etc.).
          cmd = { "qmlls6", "-E" },
        },
      },
    },
  },
}
