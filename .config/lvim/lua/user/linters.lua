local M = {}

M.config = function()
	lvim.lang.javascript.linters = { { exe = "eslint" } }
	lvim.lang.javascriptreact.linters = lvim.lang.javascript.linters
	lvim.lang.typescript.linters = lvim.lang.javascript.linter
	lvim.lang.typescriptreact.linters = lvim.lang.javascript.linter
end
return M
