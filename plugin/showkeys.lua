if vim.g.loaded_showkeys then
  return
end

vim.g.loaded_showkeys = 1

local showkeys = require("showkeys")
local group = vim.api.nvim_create_augroup("ShowkeysPlugin", { clear = true })

vim.api.nvim_create_user_command("ShowkeysStart", function()
  showkeys.start()
end, {})

vim.api.nvim_create_user_command("ShowkeysStop", function()
  showkeys.stop()
end, {})

vim.api.nvim_create_user_command("ShowkeysToggle", function()
  showkeys.toggle()
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    if showkeys.should_auto_start() then
      showkeys.start()
    end
  end,
})
