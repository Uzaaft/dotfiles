function setup()
	lvim.lang.javascript.formatters = {
		{
			exe = "prettier", -- can be prettierd eslint, or eslint_d as well
			args = {},
		},
	}
	lvim.lang.javascriptreact.formatters = {
		{
			exe = "prettier", -- can be prettierd eslint, or eslint_d as well
			args = {},
		},
	}
	lvim.lang.typescript.formatters = {
		{
			exe = "prettier", -- can be prettierd, eslint or eslint_d as well
			args = {},
		},
	}
	lvim.lang.typescriptreact.formatters = {
		exe = "prettier", -- can be prettierd, eslint or eslint_d as well
		args = {},
	}
end
