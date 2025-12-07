" ==========================================
" PLUGIN MANAGEMENT (vim-plug)
" ==========================================
call plug#begin(stdpath('data') . '/plugged')

" Disable netrw (so nvim-tree can take over)
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

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

" Git UI
Plug 'lewis6991/gitsigns.nvim'

" Smooth scroll
Plug 'karb94/neoscroll.nvim'

" Indent blanklines
Plug 'lukas-reineke/indent-blankline.nvim'

" Explorer
Plug 'nvim-tree/nvim-tree.lua'

" Startup dashboard
Plug 'nvimdev/dashboard-nvim'

Plug 'hrsh7th/nvim-cmp'          " main completion plugin
Plug 'hrsh7th/cmp-buffer'        " words from current buffer
Plug 'hrsh7th/cmp-path'          " filesystem paths
Plug 'hrsh7th/cmp-nvim-lsp'      " LSP source (will be useful later)

" LSP support
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'          " LSP/DAP/Linters installer
Plug 'williamboman/mason-lspconfig.nvim'


Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

" ================= THEMES =================
Plug 'navarasu/onedark.nvim'                     " OneDark
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }      " Tokyo Night
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }          " Catppuccin
Plug 'morhetz/gruvbox'                                  " Gruvbox
Plug 'sainnhe/everforest'                               " Everforest
Plug 'rebelot/kanagawa.nvim'                            " Kanagawa
Plug 'rose-pine/neovim', { 'as': 'rose-pine' }          " Rose Pine


" UI: statusline
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'


" UI: buffer tabs
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }

" Initialize plugin system
call plug#end()

set completeopt=menu,menuone,noselect  " Makes the auto complete nice 
set number                             " Show numbers

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
     ["<CR>"] = cmp.mapping(function(fallback)
  if cmp.visible() and cmp.get_selected_entry() then
    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
  else
    fallback() -- just insert a normal newline
  end
  end, { "i", "s" }),
     -- confirm selection
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
" STATUSLINE (lualine)
" ==========================================

lua << EOF
require("lualine").setup({
  options = {
    theme = "auto",              -- matches your colorscheme automatically
    icons_enabled = true,
    component_separators = { left = "│", right = "│" },
    section_separators = { left = "", right = "" },
    globalstatus = true,         -- one statusline for the whole screen (if nvim 0.7+)
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1 } }, -- path = 1 = relative path
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
EOF


" ==========================================
" FILE EXPLORER (nvim-tree)
" ==========================================

lua << EOF
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,        -- set to true if you want to hide dotfiles
  },
  git = {
    enable = true,
  },
})
EOF


" ==========================================
" DIAGNOSTICS UI (no deprecated sign_define)
" ==========================================

lua << EOF
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN]  = "W",
      [vim.diagnostic.severity.INFO]  = "I",
      [vim.diagnostic.severity.HINT]  = "H",
    },
  },
})
EOF


" ==========================================
" KEY MAPPINGS
" ==========================================

" Quick access to edit this config file
nnoremap <leader>v :e $MYVIMRC<CR>

" Quick reload of this config file
nnoremap <leader>r :source $MYVIMRC<CR>

" ==========================================
" BUFFERLINE (tabs for buffers)
" ==========================================
lua << EOF
require("bufferline").setup({
  options = {
    mode = "buffers",              -- show buffers (not tabs)
    diagnostics = "nvim_lsp",      -- will show LSP/nvim-lint diagnostics when we add LSP
    separator_style = "slant",     -- "slant", "thin", "padded_slant", etc.
    show_buffer_close_icons = false,
    show_close_icon = false,
    always_show_bufferline = true,
  },
})
EOF

" ==========================================
" GITSIGNS (inline git info)
" ==========================================
lua << EOF
require("gitsigns").setup({
  signs = {
    add          = { text = "+" },
    change       = { text = "~" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },
  current_line_blame = true,          -- show blame text at end of current line
  current_line_blame_opts = {
    delay = 500,
  },
})
EOF

" ==========================================
" LSP CONFIG (Neovim 0.11+ style)
" ==========================================
lua << EOF
-- Mason (installer)
local mason_ok, mason = pcall(require, "mason")
if mason_ok then
  mason.setup()
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if mason_lspconfig_ok then
  mason_lspconfig.setup({
    ensure_installed = { "pyright" },  -- install pyright for Python
  })
end

-- Capabilities for nvim-cmp completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Apply capabilities to ALL LSP servers (including pyright)
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Enable pyright using the new API
vim.lsp.enable("pyright")
EOF

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
" Run current file in a new tab
nnoremap <F5> :call RunFile()<CR>

" Theme switching
nnoremap <leader>t1 :colorscheme onedark<CR>
nnoremap <leader>t2 :colorscheme tokyonight-night<CR>
nnoremap <leader>t3 :colorscheme catppuccin<CR>
nnoremap <leader>t4 :colorscheme kanagawa<CR>
nnoremap <leader>t5 :colorscheme rose-pine<CR>

" Bufferline: jump to buffers 1..9
" Bufferline: jump to buffers 1..9 with Space + number
nnoremap <Space>1 :BufferLineGoToBuffer 1<CR>
nnoremap <Space>2 :BufferLineGoToBuffer 2<CR>
nnoremap <Space>3 :BufferLineGoToBuffer 3<CR>
nnoremap <Space>4 :BufferLineGoToBuffer 4<CR>
nnoremap <Space>5 :BufferLineGoToBuffer 5<CR>
nnoremap <Space>6 :BufferLineGoToBuffer 6<CR>
nnoremap <Space>7 :BufferLineGoToBuffer 7<CR>
nnoremap <Space>8 :BufferLineGoToBuffer 8<CR>
nnoremap <Space>9 :BufferLineGoToBuffer 9<CR>

" Optional: next/prev buffer with Shift+L / Shift+H
nnoremap <S-l> :BufferLineCycleNext<CR>
nnoremap <S-h> :BufferLineCyclePrev<CR>

nnoremap <S-l> :BufferLineCycleNext<CR>
nnoremap <S-h> :BufferLineCyclePrev<CR>

" Gitsigns keymaps
nnoremap ]h :Gitsigns next_hunk<CR>
nnoremap [h :Gitsigns prev_hunk<CR>
nnoremap <leader>hs :Gitsigns stage_hunk<CR>
nnoremap <leader>hr :Gitsigns reset_hunk<CR>
nnoremap <leader>hb :Gitsigns blame_line<CR>

" Toggle file explorer
nnoremap <Space>e :NvimTreeToggle<CR>

" Focus explorer on current file
nnoremap <Space>fe :NvimTreeFindFile<CR>


