return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<Leader>f<CR>",
      function() require("telescope.builtin").resume() end,
      desc = "Resume previous search",
    },
    {
      "<Leader>f'",
      function() require("telescope.builtin").marks() end,
      desc = "Find marks",
    },
    {
      "<Leader>f/",
      function() require("telescope.builtin").current_buffer_fuzzy_find() end,
      desc = "Find words in current buffer",
    },
    {
      "<Leader>fa",
      function()
        require("telescope.builtin").find_files {
          prompt_title = "Config Files",
          cwd = vim.fn.stdpath "config",
          follow = true,
        }
      end,
      desc = "Find config files",
    },
    {
      "<Leader>fb",
      function() require("telescope.builtin").buffers() end,
      desc = "Find buffers",
    },
    {
      "<Leader>fc",
      function() require("telescope.builtin").grep_string() end,
      desc = "Find word under cursor",
    },
    {
      "<Leader>fC",
      function() require("telescope.builtin").commands() end,
      desc = "Find commands",
    },
    {
      "<Leader>ff",
      function() require("telescope.builtin").find_files() end,
      desc = "Find files",
    },
    {
      "<Leader>fF",
      function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
      desc = "Find all files",
    },
    {
      "<Leader>fg",
      function() require("telescope.builtin").git_files() end,
      desc = "Find git files",
    },
    {
      "<Leader>fh",
      function() require("telescope.builtin").help_tags() end,
      desc = "Find help",
    },
    {
      "<Leader>fk",
      function() require("telescope.builtin").keymaps() end,
      desc = "Find keymaps",
    },
    {
      "<Leader>fm",
      function() require("telescope.builtin").man_pages() end,
      desc = "Find man",
    },
    {
      "<Leader>fo",
      function() require("telescope.builtin").oldfiles() end,
      desc = "Find history",
    },
    {
      "<Leader>fr",
      function() require("telescope.builtin").registers() end,
      desc = "Find registers",
    },
    {
      "<Leader>ft",
      function() require("telescope.builtin").colorscheme { enable_preview = true, ignore_builtins = true } end,
      desc = "Find themes",
    },
    {
      "<Leader>lD",
      function() require("telescope.builtin").diagnostics() end,
      desc = "Search diagnostics",
    },
    {
      "<Leader>ls",
      function()
        if is_available "aerial.nvim" then
          require("telescope").extensions.aerial.aerial()
        else
          require("telescope.builtin").lsp_document_symbols()
        end
      end,
      desc = "Search symbols",
    },

    {
      "<Leader>g",
      function() require("telescope.builtin").git_status { use_file_path = true } end,
      desc = "Git status",
    },
    {
      "<Leader>gb",
      function() require("telescope.builtin").git_branches { use_file_path = true } end,
      desc = "Git branches",
    },
    {
      "<Leader>gc",
      function() require("telescope.builtin").git_commits { use_file_path = true } end,
      desc = "Git commits (repository)",
    },
    {
      "<Leader>gC",
      function() require("telescope.builtin").git_bcommits { use_file_path = true } end,
      desc = "Git commits (current file)",
    },
  },
  specs = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      lazy = true,
      enabled = vim.fn.executable "make" == 1 or vim.fn.executable "cmake" == 1,
      build = vim.fn.executable "make" == 1 and "make"
        or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
  },
  cmd = "Telescope",
  opts = function()
    local actions = require "telescope.actions"
    local function open_selected(prompt_bufnr)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      local selected = picker:get_multi_selection()
      if vim.tbl_isempty(selected) then
        actions.select_default(prompt_bufnr)
      else
        actions.close(prompt_bufnr)
        for _, file in pairs(selected) do
          if file.path then vim.cmd("edit" .. (file.lnum and " +" .. file.lnum or "") .. " " .. file.path) end
        end
      end
    end
    local function open_all(prompt_bufnr)
      actions.select_all(prompt_bufnr)
      open_selected(prompt_bufnr)
    end
    return {
      defaults = {
        file_ignore_patterns = { "^%.git[/\\]", "[/\\]%.git[/\\]" },
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-J>"] = actions.move_selection_next,
            ["<C-K>"] = actions.move_selection_previous,
            ["<CR>"] = open_selected,
            ["<M-CR>"] = open_all,
          },
          n = {
            q = actions.close,
            ["<CR>"] = open_selected,
            ["<M-CR>"] = open_all,
          },
        },
      },
    }
  end,
}
