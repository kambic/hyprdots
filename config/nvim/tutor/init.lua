local M = {}

M.open = function(chapter)
  local paths = {
    vim.fn.stdpath("data") .. "/runtime/tutor/tutor" .. chapter,
    "/usr/share/nvim/runtime/tutor/tutor" .. chapter,
  }

  for _, path in ipairs(paths) do
    if vim.fn.filereadable(path) == 1 then
      vim.cmd("edit " .. path)
      return
    end
  end

  print("Tutor chapter " .. chapter .. " not found.")
end

vim.api.nvim_create_user_command("Tutor", function(opts)
  M.open(opts.args)
end, { nargs = 1, complete = "file" })

return M
