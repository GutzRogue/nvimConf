" ==========================================
" PLUGIN MANAGEMENT (vim-plug)
" ==========================================
call plug#begin(stdpath('data') . '/plugged')

" Auto-detect indentation settings
Plug 'tpope/vim-sleuth'

" Minimal file manager
Plug 'elihunter173/dirbuf.nvim'

" Linting
Plug 'mfussenegger/nvim-lint'

" Formatting (Prettier, Black, Stylua via conform)
Plug 'stevearc/conform.nvim'

" Treesitter for better syntax highlighting, indentation, etc.
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" Autopairs
Plug 'altermo/ultimate-autopair.nvim', { 'branch': 'v0.6' }

Plug 'hrsh7th/nvim-cmp'          " main completion plugin
Plug 'hrsh7th/cmp-buffer'        " words from current buffer
Plug 'hrsh7th/cmp-path'          " filesystem paths
Plug 'hrsh7th/cmp-nvim-lsp'      " LSP source (will be useful later)

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'
" Initialize plugin system
call plug#end()

set completeopt=menu,menuone,noselect  " Makes the auto complete nice 

" ==========================================
" LINTING CONFIG (nvim-lint)
" ==========================================
lua << EOF
local lint = require("lint")

lint.linters_by_ft = {
  python = { "ruff" },            -- pip install ruff
  javascript = { "eslint_d" },    -- npm install -g eslint_d
  typescript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  lua = { "luacheck" },           -- install via your OS package manager
}

local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "TextChanged", "TextChangedI" }, {
  group = lint_augroup,
  callback = function()
    -- small delay so it doesn’t spam too hard
    vim.defer_fn(function()
      lint.try_lint()
    end, 100)
  end,
})
EOF

" ==========================================
" FORMATTING CONFIG (conform.nvim)
" ==========================================
lua << EOF
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
  -- Try LSP formatting if no formatter is configured
  format_on_save = function(bufnr)
    -- Disable auto-format for very large files
    local max_size = 200 * 1024 -- 200 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
    if ok and stats and stats.size > max_size then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

-- Keymap: <leader>f to format current buffer
vim.keymap.set("n", "<S-f>", function()
  conform.format({ async = true, lsp_fallback = true })
end, { desc = "Format file" })
EOF

" ==========================================
" TREESITTER CONFIG
" ==========================================
lua << EOF
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "python",
    "javascript",
    "typescript",
    "bash",
    "json",
    "html",
    "css",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})
EOF

" ==========================================
" AUTOPAIRS CONFIG (ultimate-autopair.nvim)
" ==========================================
lua << EOF
require("ultimate-autopair").setup({
  -- you can tweak later; defaults are fine for now
})
EOF

" ==========================================
" AUTOCOMPLETE CONFIG (nvim-cmp)
" ==========================================
lua << EOF
local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
  return
end

local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_luasnip then
  require("luasnip.loaders.from_vscode").lazy_load()
end

cmp.setup({
  snippet = {
    expand = function(args)
      if ok_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),                      -- open completion menu
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),      -- confirm selection
    ["<C-e>"]     = cmp.mapping.abort(),                         -- close menu

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif ok_luasnip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif ok_luasnip and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp" },  -- will kick in once we add LSP
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})
EOF

" ==========================================
" FORMATTING ERRORS
" ==========================================

lua << EOF
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
EOF

set number

" ==========================================
" KEY MAPPINGS
" ==========================================

" Quick access to edit this config file
nnoremap <leader>v :e $MYVIMRC<CR>

" Quick reload of this config file
nnoremap <leader>r :source $MYVIMRC<CR>

" ==========================================
" UNIVERSAL FILE RUNNER (F5)
" ==========================================
function! RunFile()
    let l:filetype = &filetype
    
    if l:filetype == 'python'
        execute 'split term://python %'
    elseif l:filetype == 'javascript'
        execute 'split term://node %'
    elseif l:filetype == 'sh' || l:filetype == 'bash'
        execute 'split term://bash %'
    elseif l:filetype == 'lua'
        execute 'split term://lua %'
    else
        echo "No runner configured for filetype: " . l:filetype
        echo "Press any key to continue..."
        call getchar()
    endif
endfunction

" F5 to run the current file
nnoremap <F5> :call RunFile()<CR>

