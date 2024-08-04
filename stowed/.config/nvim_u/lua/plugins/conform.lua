---@type LazySpec
return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  version = vim.fn.has "nvim-0.10" ~= 1 and "7",
  cmd = "ConformInfo",
  ---@param opts conform.setupOpts
  opts = function(_, opts)
    opts.default_format_opts = { lsp_format = "fallback" }

    opts.format_on_save = function(bufnr)
      if vim.g.autoformat == nil then vim.g.autoformat = true end
      local autoformat = vim.b[bufnr].autoformat
      if autoformat == nil then autoformat = vim.g.autoformat end
      if autoformat then return { timeout_ms = 2000 } end
    end

    opts.formatters_by_ft = {
      lua = { "stylua" },
    }

    -- prettier filetypes
    vim.tbl_map(function(ft) opts.formatters_by_ft[ft] = { "prettier" } end, {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
      "css",
      "scss",
      "less",
      "html",
      "json",
      "jsonc",
      "yaml",
      "yaml.ansible",
      "yaml.cfn",
      "markdown",
      "markdown.mdx",
      "graphql",
      "handlebars",
    })

    opts.formatters = {
      prettier = {
        options = {
          ft_parsers = {
            markdown = "markdown",
          },
        },
      },
    }
  end,
  keys = {
    {
      "<leader>lf",
      function() vim.cmd.Format() end,
      desc = "Format buffer",
    },
    {
      "<leader>lI",
      function() vim.cmd.ConformInfo() end,
      desc = "Conform information",
    },
    {
      "<leader>uf",
      function()
        if vim.b.autoformat == nil then
          if vim.g.autoformat == nil then vim.g.autoformat = true end
          vim.b.autoformat = vim.g.autoformat
        end
        vim.b.autoformat = not vim.b.autoformat
        require("astrocore").notify(string.format("Buffer autoformatting %s", vim.b.autoformat and "on" or "off"))
      end,
      desc = "Toggle autoformatting (buffer)",
    },
    {
      "<leader>uF",
      function()
        if vim.g.autoformat == nil then vim.g.autoformat = true end
        vim.g.autoformat = not vim.g.autoformat
        vim.b.autoformat = nil
        require("astrocore").notify(string.format("Global autoformatting %s", vim.g.autoformat and "on" or "off"))
      end,
      desc = "Toggle autoformatting (global)",
    },
  },
}
