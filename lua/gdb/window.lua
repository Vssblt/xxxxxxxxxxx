local window = {}

function window.horizontal_layout(height, pos, pos_type, win_configs)
  local win_cmd
  local size = ""
  if height ~= 0 then
    size = tostring(height)
  end
  if pos_type == "relative" then
    win_cmd = (pos == "top" and "lefta" or "bel") .. " " .. size .. "split"
  else
    win_cmd = (pos == "top" and "topleft" or "botright") .. " " .. size .. "split"
  end
  local win_id = window.create_window(win_cmd, win_configs)
  return win_id
end

function window.vertical_layout(width, pos, pos_type, win_configs)
  local win_cmd
  local size = ""
  if width ~= 0 then
    size = tostring(width)
  end
  if pos_type == "relative" then
    win_cmd = (pos == "left" and "lefta" or "bel") .. " " .. size .. "vsplit"
  else
    win_cmd = (pos == "left" and "topleft" or "botright") .. " " .. size .. "vsplit"
  end
  local win_id = window.create_window(win_cmd, win_configs)
  return win_id
end

function window.create_window(win_cmd, win_conf)
  win_conf = win_conf or {}
  vim.cmd(win_cmd)
  local win_id = vim.api.nvim_get_current_win()
  for key, val in pairs(win_conf) do
    vim.api.nvim_win_set_option(win_id, key, val)
  end
  return win_id
end

function window.open(opts)
  opts = opts or { pos = "bottom", size = 20, pos_type = "relative", filetype = "" }
  if opts.bufnr == nil then
    opts.bufnr = vim.api.nvim_create_buf(false, true)
  end
  local filetype = opts.filetype or ""
  local size = opts.size == nil and 20 or opts.size
  local pos_type = opts.pos_type or "absolute"
  local win_id
  local pos = opts.pos or "bottom"
  if pos == "bottom" or pos == "top" then
    win_id = window.horizontal_layout(size, pos, pos_type, {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = false,
    wrap = false,
    signcolumn = "auto"
  })
  else
    win_id = window.vertical_layout(size, pos, pos_type, {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = true,
    wrap = false,
    signcolumn = "auto"
  })
  end
  vim.api.nvim_set_current_buf(opts.bufnr)
  vim.api.nvim_buf_set_option(opts.bufnr, "filetype", filetype)
  return opts.bufnr, win_id
end

return window
