return {
  "machakann/vim-sandwich",
  keys = {
    {
      "sa",
      "<Plug>(sandwich-add)",
      mode = { "n", "x", "o" },
    },
    { "sd", "<Plug>(sandwich-delete)", mode = { "n" } },
    { "sr", "<Plug>(sandwich-replace)", mode = { "n" } },
  },
}
