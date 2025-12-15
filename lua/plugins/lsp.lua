return {
  -- Mason core
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  -- Mason -> lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = { "pyright",  "eslint" },
      automatic_installation = true,
    },
  },

  -- Auto install non-LSP tools (formatters/linters/etc.)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        -- formatters/linters
        "prettierd",
        "eslint_d",
        "stylua",
        "black",
        "shfmt",

        -- IMPORTANT: correct package names for JS LSPs
        "typescript-language-server",
        "eslint-lsp",

        -- compiler toolchain helper
        "clangd",
      },
      run_on_start = true,
    },
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- This guarantees ordering with Mason installs
      local ok_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
      if ok_mason then
        mason_lspconfig.setup_handlers({
          function(server_name)
            lspconfig[server_name].setup({ capabilities = capabilities })
          end,
        })
      else
        -- fallback if mason-lspconfig not available for some reason
        lspconfig.pyright.setup({ capabilities = capabilities })
        lspconfig.tsserver.setup({ capabilities = capabilities })
        lspconfig.eslint.setup({ capabilities = capabilities })
      end
    end,
  },
}

