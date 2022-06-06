local M = {}

M.config = function()
  local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
  parser_configs.swift = {
    filetype = "swift",
  }
end

return M
