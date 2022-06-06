local M = {}

M.config = function()
  local arch_config = {
    {"projekt0n/github-nvim-theme"},
    { "wakatime/vim-wakatime", event = "BufReadPost" },
    {
      "pwntester/octo.nvim",
      requires = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "kyazdani42/nvim-web-devicons",
      },
      config = function()
        require("user.octo").setup()
      end,
    },
    {
       'gelguy/wilder.nvim', 
      config = function()
        local wilder = require("wilder")
        wilder.setup({modes= {":", "/", "?"}
        })
      end
    },
  }
  table.insert(lvim.plugins, arch_config)
end

return M
