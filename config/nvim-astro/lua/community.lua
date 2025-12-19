-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.vue" },
  { import = "astrocommunity.pack.ansible" },
  -- { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.hyprlang" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.color.transparent-nvim" },
  -- { import = "astrocommunity.utility.transparent-nvim" },

  -- import/override with your plugins folder
}
