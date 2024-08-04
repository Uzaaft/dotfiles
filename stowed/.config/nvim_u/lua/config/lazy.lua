-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup {
  defaults = { lazy = true },
  ui = { border = "rounded", backdrop = 100 },
  change_detection = { notify = false },
  rocks = {
    -- Fuck luarocks
    enabled = false,
  },
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "default" } },
  checker = { enabled = true },
  diff = { cmd = "terminal_git" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}
