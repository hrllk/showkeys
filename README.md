# showkeys.nvim

Tiny Neovim plugin that shows the most recent keys in a small floating window.

## Demo

GIF will be added here.

## Features

- Real-time key display
- Minimal API: `:ShowkeysStart`, `:ShowkeysStop`, `:ShowkeysToggle`
- Startup-safe by default
- Designed to be easy to embed in a `lazy.nvim` config

## Install

### `lazy.nvim`

```lua
{
  "yourname/showkeys.nvim",
  cmd = { "ShowkeysStart", "ShowkeysStop", "ShowkeysToggle" },
  opts = {
    auto_start = false,
    maxkeys = 3,
    show_count = false,
    separator = " → ",
    timeout_ms = 1200,
  },
}
```

If your lazy setup does not auto-call `setup()`, add:

```lua
config = function(_, opts)
  require("showkeys").setup(opts)
end,
```

### Optional startup auto-toggle

```lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(function()
      pcall(vim.cmd, "silent! ShowkeysToggle")
    end)
  end,
})
```

## API

```lua
require("showkeys").setup({
  auto_start = false,
  maxkeys = 3,
  show_count = false,
  separator = " → ",
  timeout_ms = 1200,
  winopts = {
    focusable = false,
    relative = "editor",
    style = "minimal",
    border = "none",
    height = 1,
    row = 1,
    col = 0,
    zindex = 200,
  },
})

require("showkeys").start()
require("showkeys").stop()
require("showkeys").toggle()
```
