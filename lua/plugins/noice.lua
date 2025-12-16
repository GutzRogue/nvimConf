return {
  -- notifications (toast UI)
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      stages = "fade_in_slide_out",
      timeout = 2500,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
    },
  },

  -- modern cmdline/messages/LSP UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      vim.notify = require("notify")
      require("noice").setup({
        lsp = {
          hover = { enabled = true },
          signature = { enabled = false},
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })

      -- quick access
      vim.keymap.set("n", "<leader>nn", "<cmd>Noice dismiss<cr>", { desc = "Dismiss notifications" })
      vim.keymap.set("n", "<leader>nl", "<cmd>Noice last<cr>", { desc = "Last notification" })
      vim.keymap.set("n", "<leader>nh", "<cmd>Noice history<cr>", { desc = "Noice history" })
    end,
  },
}

