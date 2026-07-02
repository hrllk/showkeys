# showkeys.nvim

Tiny Neovim plugin that shows the most recent keys in a small floating window.

## Demo
<img width="1524" height="1848" alt="Screen Recording 2026-07-03 at 12 05 14 AM" src="https://github.com/user-attachments/assets/8c688440-b967-48b6-9d55-3714c031bc18" />

## Features

- Real-time key display
- Minimal API: `:ShowkeysStart`, `:ShowkeysStop`, `:ShowkeysToggle`
- Startup-safe by default
- Designed to be easy to embed in a `lazy.nvim` config

## Install

### `lazy.nvim`

```lua
{
  "hrllk/showkeys",
  name = "showkeys.nvim",
  lazy = false,
  cmd = { "ShowkeysStart", "ShowkeysStop", "ShowkeysToggle" },
  config = function(_, opts)
    require("showkeys").setup(opts)
  end,
  opts = {
    auto_start = true,
    startup_user_events = { "ToggleMyPrompt" },
    maxkeys = 3,
    show_count = false,
    separator = " → ",
    timeout_ms = 1200,
  },
}
```

For command-only lazy loading, disable startup hooks:

```lua
{
  "hrllk/showkeys",
  name = "showkeys.nvim",
  cmd = { "ShowkeysStart", "ShowkeysStop", "ShowkeysToggle" },
  opts = {
    auto_start = false,
    startup_user_events = {},
  },
}
```

### Optional startup hooks

```lua
opts = {
  auto_start = true,
  startup_user_events = { "ToggleMyPrompt" },
}
```

## API

```lua
require("showkeys").setup({
  auto_start = true,
  startup_user_events = { "ToggleMyPrompt" },
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
