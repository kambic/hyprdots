Here’s a curated list of **Neovim (nvim) tips & tricks** focusing on **quickfix lists, registers, macros, marks, and other power-user features**. Everything works in Neovim ≥0.9 (most in vanilla Vim too). I’ll group them logically with short explanations and exact commands.

---

## 1. Quickfix List (`:c` commands) – Compile, Grep, LSP Diagnostics

| Task | Command | Tip |
|------|---------|-----|
| Open quickfix window | `:copen` | Height: `:copen 10` |
| Close it | `:cclose` | |
| Next error | `:cnext` / `<C-n>` (in qf) | |
| Previous error | `:cprev` / `<C-p>` | |
| Jump & return | `<CR>` in qf → `Ctrl-o` back | |
| Populate with grep | `:vim[grep] pattern %:h/**/*.lua` | Add `j` to skip prompts: `:vimgrep /pat/ %` |
| Grep + quickfix (ripgrep) | `:grep "foo"` (if `grepprg=rg --vimgrep`) | Set in init: `vim.o.grepprg = "rg --vimgrep --smart-case"` |
| LSP diagnostics → quickfix | `:lua vim.diagnostic.setqflist()` | Filter: `:lua vim.diagnostic.setqflist({severity = vim.diagnostic.severity.ERROR})` |
| Location list (buffer-local) | `:lopen`, `:lnext`, `:lprev` | Same but per window |
| Run make/async | `:make!` → auto-populates qf | Use `:cdo` to execute on each entry |

**Pro combo**  

```vim
:cexpr [] | cdo s/foo/bar/gc | update | cclose
```

Clear → search → substitute with confirm → write → close.

---

## 2. Registers (`"`) – Copy/Paste on Steroids

| Register | Meaning | Example |
|----------|---------|---------|
| `""` | Unnamed (default) | `yy` → `p` |
| `0` | Last yank (never delete) | `"0p` pastes last yanked text even after delete |
| `1-9` | Delete history (1 = most recent small delete) | `"3p` pastes 3rd-last small delete |
| `a-z` | Named (persistent if uppercase) | `"ayy` yank to a; `"Ayy` append to a |
| `+` / `*` | System clipboard | `"+yy`, `"+p` |
| `_` | Black hole (discard) | `"_dd` delete without yanking |
| `=` | Expression register | `"=5*12<CR>p` → inserts 60 |
| `%` | Current filename | `Ctrl-r %` in insert mode |
| `#` | Alternate filename | |

**List all registers**  

```vim
:reg[isters] a0"%
```

**Paste register in command line**  
`Ctrl-r "` → pastes unnamed register.

**Macro as register**  
Record macro to `q`: `qa ... q`, replay `"ap`.

---

## 3. Macros – Automate Anything

```vim
qa          " start recording to register a
...         " your edits
q           " stop
@a          " replay once
@@          " replay last macro
5@a         " replay 5 times
:10,20norm! @a   " run on lines 10–20
```

**Edit macro**  

```vim
:let @a = 'iif err != nil {<CR>return err<CR>}<Esc>'
```

**Visual block macro**  
`Ctrl-v` select → `I...` → `<Esc>` → macro applies to all lines.

---

## 4. Marks – Jump Anywhere Fast

| Mark | Scope | Example |
|------|-------|---------|
| `ma` | Local, persistent | Set anywhere, `'a` jumps |
| `` `a `` | Exact column | `` 'a `` jumps to line start |
| `` `` `` | Last jump position | `` Ctrl-o `` / `` Ctrl-i `` |
| `''` | Last edit position in buffer | |
| `<` / `>` | Visual selection start/end | `gv` reselects |
| `.` | Last change position | |
| `^` | Last insert stop | |

**List marks**  

```vim
:marks aA
```

**Global marks** `A-Z` → across files.

---

## 5. Command-Line Magic

| Trick | Command |
|-------|---------|
| History navigation | `q:` (command), `q/` (search) |
| Edit command in buffer | `Ctrl-f` from `:` |
| Repeat last `:` command | `@:` |
| Run shell | `:!)ls` or `:!git pull` |
| Filter lines through shell | `:%!jq .` (pretty JSON) |
| Read shell output | `:r !date` |
| Suspend nvim | `Ctrl-z` → `fg` |

---

## 6. Text Objects & Motions (with `vim-sneak`, `targets.vim`, etc.)

| Object | Meaning |
|--------|---------|
| `ci(` | Change inside parentheses |
| `da"` | Delete a quoted string |
| `yiw` | Yank inner word |
| `gUaw` | Uppercase a word |
| `>i{` | Indent inside `{}` |

Install `nvim-treesitter-textobjects` for **function**, **class**, **parameter** objects.

---

## 7. Window & Tab Tricks

| Action | Command |
|--------|---------|
| Split & keep focus | `:vsplit` / `:split` |
| Equal size | `Ctrl-w =` |
| Swap windows | `Ctrl-w x` |
| Resize | `Ctrl-w 10>` / `Ctrl-w 10+` |
| Tab → window | `:tab split` |
| Close all other tabs | `:tabonly` |

---

## 8. Search & Replace Mastery

```vim
:%s/foo/bar/gc          " confirm each
:%s/\v(foo|bar)/baz/g   " very magic
:%s#old#new#g           " # as delimiter (avoid /)
&cgn                    " change next match & dot-repeat
```

**Global command**  

```vim
:g/error/norm! A;   // append ; to every line with "error"
```

---

## 9. Dot Command (`.`) Power

- `.` repeats **last change**.
- Combine with **text objects**: `ciwfoo<Esc>` → move elsewhere → `.` repeats.
- Use `&` to repeat last `:s`.

---

## 10. Bonus Lua Snippets (Neovim-only)

```lua
-- init.lua
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist, {desc = "Diagnostics → qf"})

-- Reload config
vim.api.nvim_create_user_command('Reload', 'source $MYVIMRC', {})

-- Toggle relative numbers
vim.keymap.set('n', '<leader>n', function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end)
```

---

## Recommended Minimal `init.vim` Snippet

```vim
set hidden
set ignorecase smartcase
set grepprg=rg\ --vimgrep
set clipboard=unnamedplus

nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
nnoremap <leader>ff :copen<CR>
nnoremap <leader>fn :cnext<CR>
nnoremap <leader>fp :cprev<CR>

" Quick substitute in file
nnoremap <leader>s :%s/\<<C-r><C-w>\>/
```

---

**Pro Tip**: Use `:h index` → search `quickfix`, `registers`, `marks` for full docs.

Enjoy your Neovim superpowers! 🚀
