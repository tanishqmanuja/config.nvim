local M = {
  "nvimtools/none-ls.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "jay-babu/mason-null-ls.nvim",
  },
}

local DEFAULT_TOOLS = {
  -- FORMATTERS
  "prettier", -- js
  "stylua", -- lua
  "isort", -- python
  "black", -- python

  -- LINTERS
  "pylint", -- python
  "eslint_d", -- js
}

function M.config()
  local null_ls = require("null-ls")
  local null_ls_utils = require("null-ls.utils")

  local mason_null_ls = require("mason-null-ls")

  mason_null_ls.setup({
    ensure_installed = DEFAULT_TOOLS,
    automatic_installation = false,
    handlers = {
      mason_null_ls.default_setup,
    },
  })

  -- for conciseness
  local formatting = null_ls.builtins.formatting -- to setup formatters
  local diagnostics = null_ls.builtins.diagnostics -- to setup linters

  -- to setup format on save
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  -- configure null_ls
  null_ls.setup({
    -- add package.json as identifier for root (for typescript monorepos)
    root_dir = null_ls_utils.root_pattern(".null-ls-root", "Makefile", ".git", "package.json"),
    -- setup formatters & linters
    sources = {
      --  to disable file types use
      --  "formatting.prettier.with({disabled_filetypes: {}})" (see null-ls docs)
      formatting.prettier.with({
        extra_filetypes = { "svelte" },
      }), -- js/ts formatter
      -- formatting.stylua, -- lua formatter
      -- formatting.isort, -- python imports sorter
      -- formatting.black, -- python formatter
      -- diagnostics.pylint, -- python linter
      diagnostics.eslint_d.with({ -- js/ts linter
        condition = function(utils)
          return utils.root_has_file({ ".eslintrc.js", ".eslintrc.cjs" }) -- only enable if root has .eslintrc.js or .eslintrc.cjs
        end,
      }),
    },
    -- configure format on save
    on_attach = function(current_client, bufnr)
      if current_client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              filter = function(client)
                --  only use null-ls for formatting instead of lsp server
                return client.name == "null-ls"
              end,
              bufnr = bufnr,
              timeout_ms = 5000,
            })
          end,
        })
      end
    end,
  })
end

return M
