return {
  -- Mason core
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  -- Mason -> lspconfig bridge (installs servers)
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = { "pyright", "ts_ls", "eslint" }, -- lspconfig server names
      automatic_installation = true,
    },
  },

  -- installs external tools (formatters/linters/etc.)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "prettierd",
        "eslint_d",
        "stylua",
        "black",
        "shfmt",

        -- mason package names
        "typescript-language-server",
        "eslint-lsp",
      },
      run_on_start = true,
    },
  },

  -- nvim-lspconfig is still needed to provide server definitions,
  -- but we do NOT use require("lspconfig") anymore.
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Neovim 0.11+ API
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("ts_ls", { capabilities = capabilities })
      vim.lsp.config("eslint", { capabilities = capabilities })

      vim.lsp.enable({ "pyright", "ts_ls", "eslint" })
    end,
  },
}

