return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end

      configs.setup({
        ensure_installed = { "lua" ,"vim","alpha" ,"vimdoc", "python", "javascript", "tsx", "bash", "json", "html", "css" },
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true,
      })
    end,
  },
}

