return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    opts = {},
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
      { "<leader>fl", "<cmd>FzfLua lines<cr>", desc = "Lines" },
    },
  },
}

