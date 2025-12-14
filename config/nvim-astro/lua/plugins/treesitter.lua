-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "bash",
      "c",
      "css",
      "csv",
      "diff",
      "dockerfile",
      "git_config",
      "gitcommit",
      "gitignore",
      "go",
      "gpg",
      "html",
      "ini",
      "javascript",
      "json",
      "kotlin",
      "markdown",
      "markdown_inline",
      "php",
      "phpdoc",
      "python",
      "rust",
      "scss",
      "sql",
      "toml",
      "tsx",
      "typescript",
      "vue",
      "xml",
      "yaml",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "vim",
      "vimdoc",

      -- add more arguments for adding more treesitter parsers
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
