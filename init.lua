-- =========================================================
-- ONE-FILE NEOVIM CONFIG USING lazy.nvim (drop-in init.lua)
-- =========================================================

-- ---------- Basics ----------
vim.g.mapleader = " " -- you are already using <Space> a lot, so make it leader

vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.number = true

-- Disable netrw (so nvim-tree can take over)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ---------- lazy.nvim bootstrap ----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ---------- Plugin setup ----------
require("lazy").setup({
  -- Auto-detect indentation settings
  { "tpope/vim-sleuth", event = "VeryLazy" },

  -- Minimal file manager
  { "elihunter173/dirbuf.nvim", cmd = { "Dirbuf" } },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "InsertLeave", "TextChanged", "TextChangedI" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" }, -- pip install ruff
        javascript = { "eslint_d" }, -- npm install -g eslint_d
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        lua = { "luacheck" }, -- install via OS package manager
      }

      local g = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "TextChanged", "TextChangedI" }, {
        group = g,
        callback = function()
          vim.defer_fn(function()
            lint.try_lint()
          end, 100)
        end,
      })
    end,
  },

  -- Formatting (conform)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          javascript = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          lua = { "stylua" },
          python = { "black" },
          sh = { "shfmt" },
        },
        format_on_save = function(bufnr)
          local max_size = 200 * 1024 -- 200KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > max_size then
            return
          end
          return { timeout_ms = 500, lsp_fallback = true }
        end,
      })

      -- FIX: use <leader>f (Shift+f is inconsistent)
      vim.keymap.set("n", "<leader>f", function()
        conform.format({ async = true, lsp_fallback = true })
      end, { desc = "Format file" })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "bash", "json", "html", "css" },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
      })
    end,
  },

  -- Autopairs
  {
    "altermo/ultimate-autopair.nvim",
    branch = "v0.6",
    event = "InsertEnter",
    config = function()
      require("ultimate-autopair").setup({})
    end,
  },

  -- Git UI (gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = { delay = 500 },
      })

      -- Gitsigns keymaps
      vim.keymap.set("n", "]h", ":Gitsigns next_hunk<CR>", { silent = true })
      vim.keymap.set("n", "[h", ":Gitsigns prev_hunk<CR>", { silent = true })
      vim.keymap.set("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", { silent = true })
      vim.keymap.set("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", { silent = true })
      vim.keymap.set("n", "<leader>hb", ":Gitsigns blame_line<CR>", { silent = true })
    end,
  },

  -- Smooth scroll
  { "karb94/neoscroll.nvim", event = "VeryLazy", config = true },

  -- Indent guides (new module name is ibl)
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "BufReadPost", opts = {} },

  -- Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = { width = 30, side = "left" },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
        git = { enable = true },
      })
    end,
  },

  -- Startup dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- UI: statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- UI: buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          show_buffer_close_icons = false,
          show_close_icon = false,
          always_show_bufferline = true,
        },
      })
    end,
  },

  -- Completion: nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- LSP support
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },

  -- Mason
  { "williamboman/mason.nvim", cmd = "Mason", config = true },

  { "williamboman/mason-lspconfig.nvim", event = { "BufReadPre", "BufNewFile" } },

  -- Themes
  { "navarasu/onedark.nvim", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "morhetz/gruvbox", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },

  -- FZF (adds :Files, :Buffers, :GFiles?, :GBranches, :Commits, etc.)
  
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  { "junegunn/fzf.vim" },


  -- Optional (recommended) full Git UI in vim
  { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gblame" } },
})

-- =========================================================
-- Diagnostics UI (same as your config)
-- =========================================================
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})

-- =========================================================
-- LSP config (Neovim 0.11+ style) + CMP capabilities
-- =========================================================
do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  -- Apply capabilities to ALL servers
  vim.lsp.config("*", { capabilities = capabilities })

  -- Mason LSP config: ensure pyright
  local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
  if ok_mason_lsp then
    mason_lspconfig.setup({ ensure_installed = { "pyright" } })
  end

  -- Enable pyright
  pcall(vim.lsp.enable, "pyright")
end

-- =========================================================
-- Keymaps (cleaned + no duplicates)
-- =========================================================

-- Quick access to edit this config file
vim.keymap.set("n", "<leader>v", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end)

-- Quick reload of this config file
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
end)

-- Nvim-tree
vim.keymap.set("n", "<Space>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<Space>fe", ":NvimTreeFindFile<CR>", { silent = true })

-- Bufferline: jump to buffers 1..9
for i = 1, 9 do
  vim.keymap.set("n", "<Space>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", { silent = true })
end

-- Bufferline: next/prev buffer
vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })

-- Theme switching (same idea as yours)
vim.keymap.set("n", "<leader>t1", ":colorscheme onedark<CR>", { silent = true })
vim.keymap.set("n", "<leader>t2", ":colorscheme tokyonight-night<CR>", { silent = true })
vim.keymap.set("n", "<leader>t3", ":colorscheme catppuccin<CR>", { silent = true })
vim.keymap.set("n", "<leader>t4", ":colorscheme kanagawa<CR>", { silent = true })
vim.keymap.set("n", "<leader>t5", ":colorscheme rose-pine<CR>", { silent = true })

-- FZF keymaps
vim.keymap.set("n", "<leader>ff", ":Files<CR>", { silent = true })
vim.keymap.set("n", "<leader>fb", ":Buffers<CR>", { silent = true })
vim.keymap.set("n", "<leader>fl", ":Lines<CR>", { silent = true })
vim.keymap.set("n", "<leader>fg", ":GFiles?<CR>", { silent = true })
vim.keymap.set("n", "<leader>gb", ":GBranches<CR>", { silent = true })
vim.keymap.set("n", "<leader>gc", ":Commits<CR>", { silent = true })
vim.keymap.set("n", "<leader>gC", ":BCommits<CR>", { silent = true })

-- Fugitive (if installed)
vim.keymap.set("n", "<leader>gs", ":Git<CR>", { silent = true })
vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { silent = true })
vim.keymap.set("n", "<leader>gB", ":Gblame<CR>", { silent = true })

-- =========================================================
-- Universal file runner (F5) - FIXED for spaces/paths
-- =========================================================
local function run_file()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  local ft = vim.bo.filetype
  local cmd
  if ft == "python" then
    cmd = "python " .. vim.fn.fnameescape(file)
  elseif ft == "javascript" then
    cmd = "node " .. vim.fn.fnameescape(file)
  elseif ft == "sh" or ft == "bash" then
    cmd = "bash " .. vim.fn.fnameescape(file)
  elseif ft == "lua" then
    cmd = "lua " .. vim.fn.fnameescape(file)
  else
    vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  vim.cmd("split | terminal " .. cmd)
end

vim.keymap.set("n", "<F5>", run_file, { desc = "Run current file" })

