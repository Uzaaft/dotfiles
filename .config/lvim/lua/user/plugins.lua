local M = {}

M.config = function()
	lvim.plugins = {
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			ft = { "html", "javascript", "javascriptreact", "typescriptreact", "typescript", "svelte", "vue" },
			config = function()
				require("nvim-ts-autotag").setup()
			end,
		},
		{
			"simrat39/symbols-outline.nvim",
			cmd = "SymbolsOutline",
			config = function()
				require("symbols-outline").setup()
				vim.g.symbols_outline = {}
			end,
		},
		{ "wakatime/vim-wakatime" },
		{
			"simrat39/rust-tools.nvim",
			config = function()
				require("user.rust_tools").config()
			end,
			ft = { "rust", "rs" },
		},
		{
			"f-person/git-blame.nvim",
			event = "BufRead",
			config = function()
				vim.cmd("highlight default link gitblame SpecialComment")
				vim.g.gitblame_enabled = 0
			end,
		},
		{
			"lukas-reineke/indent-blankline.nvim",
			setup = function()
				vim.g.indentLine_enabled = 1
				vim.g.indent_blankline_char = "▏"
				vim.g.indent_blankline_filetype_exclude = { "help", "terminal", "dashboard" }
				vim.g.indent_blankline_buftype_exclude = { "terminal" }
				vim.g.indent_blankline_show_trailing_blankline_indent = false
				vim.g.indent_blankline_show_first_indent_level = false
			end,
		},
		{
			"phaazon/hop.nvim",
			event = "BufRead",
			config = function()
				require("hop").setup()
				vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
				vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
			end,
		},
		{
			"karb94/neoscroll.nvim",
			event = "WinScrolled",
			config = function()
				require("neoscroll").setup({
					-- All these keys will be mapped to their corresponding default scrolling animation
					mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
					hide_cursor = true, -- Hide cursor while scrolling
					stop_eof = true, -- Stop at <EOF> when scrolling downwards
					use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
					respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
					cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
					easing_function = nil, -- Default easing function
					pre_hook = nil, -- Function to run before the scrolling animation starts
					post_hook = nil, -- Function to run after the scrolling animation ends
				})
			end,
		},
		{ "npxbr/glow.nvim", run = "GlowInstall" },
		{
			"yardnsm/vim-import-cost",
			run = "npm install",
		},
		{ "vuki656/package-info.nvim" },
    {"jose-elias-alvarez/nvim-lsp-ts-utils", 
      config = function()
        require("user.nvim_lsp_ts_utils").config()
      end
  }
	}
end
return M
