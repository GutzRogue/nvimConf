return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        filesystem_watchers = {
          ignore_dirs = {
            "target",
            "node_modules",
            ".git",
          },
        },
      })
    end,
  },
}

