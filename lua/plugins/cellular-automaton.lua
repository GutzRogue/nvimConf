return {
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    config = function()
      vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<cr>", { desc = "Make it rain" })
      vim.keymap.set("n", "<leader>mg", "<cmd>CellularAutomaton game_of_life<cr>", { desc = "Game of life" })
    end,
  },
}

