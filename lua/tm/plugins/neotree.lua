local function toggle_neotree()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd("Neotree close")
  else
    vim.cmd("Neotree focus")
  end
end

local M = {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  keys = {
    { "<C-e>", toggle_neotree, desc = "Toggle Neotree" },
    { "<leader>fe", "<cmd>Neotree focus<cr>", desc = "Focus Neotree" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
}

function M.config()
  require("neo-tree").setup({
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = {
        enabled = true,
      },
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
      },
    },
    window = {
      position = "right",
      width = 35,
    },
  })
end

return M
