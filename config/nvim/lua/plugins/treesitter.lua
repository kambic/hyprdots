return {
  "nvim-treesitter/nvim-treesitter",
  cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
  opts_extend = { "ensure_installed" },
  opts = {
    -- LazyVim config for treesitter
    indent = { enable = true }, ---@type lazyvim.TSFeat
    highlight = { enable = true }, ---@type lazyvim.TSFeat
    folds = { enable = true }, ---@type lazyvim.TSFeat
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      -- "jsdoc",
      -- "json",
      -- "jsonc",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      -- "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      -- "xml",
      -- "yaml",
    },
  },
}
