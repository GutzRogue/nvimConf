return {
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_signature").setup({
        hint_enable = false,  -- no inline hints, just popup
        floating_window = true,
        toggle_key = "<C-k>", -- show/hide signature
      })
    end,
  },
}

