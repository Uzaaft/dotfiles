local M = {}

M.config = function()
	local status_ok, rust_tools = pcall(require, "rust-tools")
	if not status_ok then
		return
	end

	local opts = {
		tools = { -- rust-tools options
			autoSetHints = true,

			hover_with_actions = true,

			runnables = {
				use_telescope = true,
			},

			inlay_hints = {
				show_parameter_hints = true,

				-- prefix for parameter hints
				-- default: "<-"
				parameter_hints_prefix = "<-",

				-- prefix for all the other hints (type, chaining)
				-- default: "=>"
				other_hints_prefix = "=>",

				-- whether to align to the lenght of the longest line in the file
				max_len_align = false,

				-- padding from the left if max_len_align is true
				max_len_align_padding = 1,

				-- whether to align to the extreme right or not
				right_align = false,

				-- padding from the right if right_align is true
				right_align_padding = 7,
			},

			hover_actions = {
				border = {
					{ "╭", "FloatBorder" },
					{ "─", "FloatBorder" },
					{ "╮", "FloatBorder" },
					{ "│", "FloatBorder" },
					{ "╯", "FloatBorder" },
					{ "─", "FloatBorder" },
					{ "╰", "FloatBorder" },
					{ "│", "FloatBorder" },
				},
			},
		},
	}
	require("rust-tools").setup(opts)
end
return M
