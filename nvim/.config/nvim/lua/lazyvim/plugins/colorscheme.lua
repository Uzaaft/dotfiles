return {

  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local tokyonight = require("tokyonight")
      tokyonight.setup({ style = "moon" })
      tokyonight.load()
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    cond = function()
      local _time = os.date("*t")
      return (_time.hour >= 17 and _time.hour < 21)
    end,
    config = function()
      local catppuccin = require("catppuccin")
      local mocha = require("catppuccin.themes")
      catppuccin.load(mocha)
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    cond = function()
      local _time = os.date("*t")
      return ((_time.hour >= 21 and _time.hour < 24) or (_time.hour >= 0 and _time.hour < 1))
    end,
    config = function()
      local kanagwa = require("kanagawa")
      kanagwa.load()
    end,
  },
}
