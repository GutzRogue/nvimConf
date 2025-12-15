return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- delay before popup (ms)
      delay = 200,

      -- show on leader and common prefixes
      triggers = {
        { "<leader>", mode = { "n", "v" } },
        { "g", mode = "n" },
        { "]", mode = "n" },
        { "[", mode = "n" },
      },

      win = {
        border = "rounded",
      },

      layout = {
        align = "center",
      },
    },
  },
}

