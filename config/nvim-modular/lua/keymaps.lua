-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
local map = vim.keymap.set

-- Save current file
map('n', '<C-s>', ':w<cr>', { desc = 'Save file', remap = true })

-- ESC pressing jk
-- map("i", "jk", "<ESC>", { desc = "jk to esc", noremap = true })

-- Quit Neovim
-- map("n", "<leader>q", ":q<cr>", { desc = "Quit Neovim", remap = true })

-- Increment/decrement
map('n', '+', '<C-a>', { desc = 'Increment numbers', noremap = true })
map('n', '-', '<C-x>', { desc = 'Decrement numbers', noremap = true })

-- Select all
map('n', '<C-a>', 'gg<S-v>G', { desc = 'Select all', noremap = true })

-- Indenting
map('v', '<', '<gv', { desc = 'Indenting', silent = true, noremap = true })
map('v', '>', '>gv', { desc = 'Indenting', silent = true, noremap = true })

-- New tab
map('n', 'te', ':tabedit')

-- Split window
map('n', '<leader>sh', ':split<Return><C-w>w', { desc = 'splits horizontal', noremap = true })
map('n', '<leader>sv', ':vsplit<Return><C-w>w', { desc = 'Split vertical', noremap = true })

-- Navigate vim panes better
map('n', '<C-k>', '<C-w>k', { desc = 'Navigate up' })
map('n', '<C-j>', '<C-w>j', { desc = 'Navigate down' })
map('n', '<C-h>', '<C-w>h', { desc = 'Navigate left' })
map('n', '<C-l>', '<C-w>l', { desc = 'Navigate right' })

-- Resize window
map('n', '<C-Up>', ':resize -3<CR>')
map('n', '<C-Down>', ':resize +3<CR>')
map('n', '<C-Left>', ':vertical resize -3<CR>')
map('n', '<C-Right>', ':vertical resize +3<CR>')

-- Barbar
map('n', '<Tab>', ':BufferNext<CR>', { desc = 'Move to next tab', noremap = true })
map('n', '<S-Tab>', ':BufferPrevious<CR>', { desc = 'Move to previous tab', noremap = true })
map('n', '<leader>x', ':BufferClose<CR>', { desc = 'Buffer close', noremap = true })
map('n', '<A-p>', ':BufferPin<CR>', { desc = 'Pin buffer', noremap = true })
-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
