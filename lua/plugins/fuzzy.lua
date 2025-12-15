return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    opts = {
      git = {
        branches = {
          -- Windows-safe: no fancy formatting, no color
          cmd = "git branch -a --no-color",
        },
      },
    },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
      { "<leader>fl", "<cmd>FzfLua lines<cr>", desc = "Lines" },

      -- ✅ Git branches (should no longer show 0/0)
      { "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
    },
  },
}

