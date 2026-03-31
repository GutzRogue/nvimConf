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
      ensure_installed = {
        "pyright",
        "ts_ls",
        "eslint",
        "clangd", -- ✅ C/C++
        "jdtls",  -- ✅ Java
        "zls" ,
        "rust_analyzer",
      },
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

        -- ✅ C/C++ tools
        "clang-format",
        "clangd",
        "clang-tidy",

        -- ✅ Java tools
        "jdtls",
        "google-java-format",
        "java-debug-adapter",
        "java-test",

        -- ✅ Rust tools
        "rust-analyzer",
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
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- ------------------------------
      -- ✅ Python / TS / ESLint
      -- ------------------------------
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("ts_ls", { capabilities = capabilities })
      vim.lsp.config("eslint", { capabilities = capabilities })
      vim.lsp.config("zls", { capabilities = capabilities })
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
            },
            procMacro = {
              enable = true,
            },
            files = {
              excludeDirs = { "target", "node_modules", ".git" },
            },
          },
        },
      })
      -- ------------------------------
      -- ✅ C / C++ (clangd)
      -- ------------------------------
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
          "--function-arg-placeholders=true",
          "--fallback-style=llvm",
        },
        init_options = {
          fallbackFlags = { "-std=c++20" },
        },
      })

      -- Enable LSP servers
      vim.lsp.enable({
        "pyright",
        "ts_ls",
        "eslint",
        "clangd",
        "zls",
        "rust_analyzer",
      })
    end,
  },

  -- ✅ REQUIRED for Java (jdtls needs this plugin)
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
  },

    {
    "ziglang/zig.vim",
    ft = { "zig" },
  },
}

