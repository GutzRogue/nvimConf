return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "ibhagwan/fzf-lua",
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "",
        "          Welcome back 👋",
        "",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find files", "<cmd>FzfLua files<cr>"),
        dashboard.button("g", "󰊢  Live grep", "<cmd>FzfLua live_grep<cr>"),
        dashboard.button("b", "  Buffers", "<cmd>FzfLua buffers<cr>"),
        dashboard.button("r", "  Recent files", "<cmd>FzfLua oldfiles<cr>"),
        dashboard.button("s", "  Search history", "<cmd>FzfLua search_history<cr>"),
        dashboard.button("c", "  Config", "<cmd>e $MYVIMRC<cr>"),
        dashboard.button("n", "  New file", "<cmd>ene<bar>startinsert<cr>"),
        dashboard.button("q", "󰩈  Quit", "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = "⚡ Ready."

      dashboard.config.opts.noautocmd = true
      alpha.setup(dashboard.config)
    end,
  },
}

