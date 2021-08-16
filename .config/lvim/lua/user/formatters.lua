local M = {}

M.config = function()
	lvim.lang.lua.formatters = { { exe = "stylua" } }
	lvim.lang.javascript.formatters = { { exe = "eslint" }, { exe = "prettier" } }
	lvim.lang.javascriptreact.formatters = lvim.lang.javascript.formatters
	lvim.lang.typescript.formatters = lvim.lang.javascript.formatters
	lvim.lang.typescriptreact.formatters = lvim.lang.javascript.formatters
end
return M
