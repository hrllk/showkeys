local M = {}

local defaults = {
  maxkeys = 3,
  show_count = false,
  separator = " ",
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
}

local state = {
  running = false,
  opts = vim.deepcopy(defaults),
  history = {},
  buf = nil,
  win = nil,
  timer = nil,
  ns = vim.api.nvim_create_namespace("showkeys"),
}

local function normalize_key(key)
  if not key or key == "" then
    return nil
  end

  local control_map = {
    ["\t"] = "TAB",
    ["\n"] = "C-j",
    ["\v"] = "C-k",
    ["\r"] = "CR",
    ["\27"] = "ESC",
    ["\127"] = "BS",
  }

  if control_map[key] then
    return control_map[key]
  end

  if key == " " then
    return "SPC"
  end

  local label = vim.fn.keytrans(key)
  if label == "" then
    return nil
  end

  local display_map = {
    ["<Tab>"] = "TAB",
    ["<NL>"] = "C-j",
    ["<C-J>"] = "C-j",
    ["<C-K>"] = "C-k",
    ["^J"] = "C-j",
    ["^K"] = "C-k",
    ["<CR>"] = "CR",
    ["<Esc>"] = "ESC",
    ["<Space>"] = "SPC",
  }

  if display_map[label] then
    return display_map[label]
  end

  if label == "Space" or label == "<Space>" then
    return "SPC"
  end

  return label
end

local function trim_history()
  while #state.history > state.opts.maxkeys do
    table.remove(state.history, 1)
  end
end

local function current_lines()
  local line = table.concat(state.history, state.opts.separator)
  if state.opts.show_count then
    if line ~= "" then
      line = string.format("%s (%d)", line, #state.history)
    else
      line = string.format("(%d)", #state.history)
    end
  end

  return { line }
end

local function close_window()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end

  state.win = nil
  state.buf = nil
end

local function reset_timer()
  if not state.opts.timeout_ms or state.opts.timeout_ms <= 0 then
    return
  end

  if not state.timer then
    state.timer = (vim.uv or vim.loop).new_timer()
  end

  state.timer:stop()
  state.timer:start(state.opts.timeout_ms, 0, function()
    vim.schedule(function()
      if not state.running then
        return
      end

      close_window()
      state.history = {}
    end)
  end)
end

local function win_width(lines)
  local width = 1
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  return width + 2
end

local function ensure_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  vim.bo[state.buf].modifiable = true
  vim.bo[state.buf].filetype = "showkeys"
  return state.buf
end

local function ensure_win(lines)
  local buf = ensure_buf()
  local width = math.max(1, win_width(lines))
  local height = math.max(1, #lines)

  local winopts = vim.tbl_extend("force", {}, state.opts.winopts)
  winopts.width = width
  winopts.height = height
  winopts.row = math.max(0, vim.o.lines - height - 2)
  winopts.col = math.max(0, vim.o.columns - width - 1)

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_config(state.win, winopts)
    vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder", { win = state.win })
    vim.api.nvim_set_option_value("wrap", false, { win = state.win })
    vim.api.nvim_set_option_value("number", false, { win = state.win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = state.win })
    return state.win, buf
  end

  state.win = vim.api.nvim_open_win(buf, false, winopts)
  vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder", { win = state.win })
  vim.api.nvim_set_option_value("wrap", false, { win = state.win })
  vim.api.nvim_set_option_value("number", false, { win = state.win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = state.win })

  return state.win, buf
end

local function render()
  if not state.running then
    return
  end

  local lines = current_lines()
  if #lines == 0 then
    lines = { "" }
  end

  local _, buf = ensure_win(lines)
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  reset_timer()
end

local function on_key(key)
  if not state.running then
    return
  end

  local label = normalize_key(key)
  if not label then
    return
  end

  table.insert(state.history, label)
  trim_history()
  vim.schedule(render)
end

function M.setup(opts)
  state.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

function M.start()
  if state.running then
    return
  end

  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  state.running = true
  state.history = {}
  vim.on_key(on_key, state.ns)
  render()
end

function M.stop()
  if not state.running then
    return
  end

  state.running = false
  vim.on_key(nil, state.ns)
  if state.timer then
    state.timer:stop()
  end

  if state.timer then
    state.timer:close()
    state.timer = nil
  end

  close_window()
  state.history = {}
end

function M.toggle()
  if state.running then
    M.stop()
  else
    M.start()
  end
end

return M
