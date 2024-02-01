local M = {
  "williamboman/mason.nvim",
  lazy = false,
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
}

local DEFAULT_SERVERS = {
  "cssls",
  "emmet_ls",
  "html",
  "jsonls",
  "lua_ls",
  "pyright",
  "tailwindcss",
  "tsserver",
}

local DEFAULT_FORMATTERS = {
  "shfmt",
  "stylua",
  "black",
  "isort",
  "prettier",
}

local DEFAULT_LINTERS = {
  "eslint_d",
  "pylint",
}

M.keys = {
  { "<leader>pm", "<cmd>silent! Mason<cr>", desc = "Mason" },
}

function M.config()
  require("mason").setup({
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })

  require("mason-tool-installer").setup({
    ensure_installed = vim.tbl_flatten({ DEFAULT_SERVERS, DEFAULT_FORMATTERS, DEFAULT_LINTERS }),
  })
end

return M