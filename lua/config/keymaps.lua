-- lua/config/keymaps.lua

local map = vim.keymap.set

local opts = { silent = true }

-- Quick access to edit/reload config
map("n", "<leader>v", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit init.lua" })

map("n", "<leader>r", function()
  vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Reload init.lua" })

-- Nvim-tree
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer (toggle)", silent = true })
map("n", "<leader>fe", "<cmd>NvimTreeFindFile<cr>", { desc = "Explorer (find file)", silent = true })

-- Bufferline: jump to buffers 1..9
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", { desc = "Go to buffer " .. i, silent = true })
end

-- Bufferline: next/prev buffer
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer", silent = true })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer", silent = true })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer", silent = true })

-- Theme switching
map("n", "<leader>tt", "<cmd>colorscheme tokyonight<cr>", { desc = "Theme: tokyonight", silent = true })
map("n", "<leader>tc", "<cmd>colorscheme catppuccin<cr>", { desc = "Theme: catppuccin", silent = true })

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)", silent = true })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)", silent = true })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)", silent = true })
map("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP Definitions / references / ... (Trouble)", silent = true })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)", silent = true })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)", silent = true })

-- Diagnostics: show error under cursor
map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Diagnostics (line)", silent = true })

-- Fuzzy finder (fzf-lua)
map("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files", silent = true })
map("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers", silent = true })
map("n", "<leader>fl", "<cmd>FzfLua lines<cr>", { desc = "Search lines", silent = true })
map("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Git files", silent = true })
map("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Symbols (file)" })
map("n", "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", { desc = "Symbols (project)" })
map("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep project" })
map("n", "<leader>sl", "<cmd>FzfLua blines<cr>", { desc = "Search lines (file)" })


-- Auto complete

map("n", "<leader>k", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- Git pickers (fzf-lua)
map("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Git commits", silent = true })
map("n", "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", { desc = "Buffer commits", silent = true })

-- Fugitive
map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status", silent = true })
map("n", "<leader>gd", "<cmd>Gdiffsplit<cr>", { desc = "Git diff split", silent = true })
map("n", "<leader>gB", "<cmd>Gblame<cr>", { desc = "Git blame", silent = true })

-- Format
map("n", "<leader>F", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format file" })


map("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

map("n", "<F5>", function()
  require("utils.runfile").run_file()
end, { desc = "Run current file" })


