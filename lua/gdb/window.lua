local window = {}

function window:horizontal_layout(height, pos, pos_type, win_configs)
  local win_cmd
  if pos_type == "relative" then
    win_cmd = (pos == "top" and "lefta" or "bel") .. " split"
  else
    win_cmd = (pos == "top" and "topleft" or "botright") .. " split"
  end
  local win_id = window.create_window(window, win_cmd, win_configs)
  vim.api.nvim_win_set_height(win_id, height)
  return win_id
end

function window:vertical_layout(width, pos, pos_type, win_configs)
  local win_cmd
  if pos_type == "relative" then
    win_cmd = (pos == "left" and "lefta" or "bel") .. " vsplit"
  else
    win_cmd = (pos == "left" and "topleft" or "botright") .. " vsplit"
  end
  local win_id = window.create_window(window, win_cmd, win_configs)
  vim.api.nvim_win_set_width(win_id, width)
  return win_id
end

function window:create_window(win_cmd, win_conf)
  win_conf = win_conf or {}
  vim.cmd(win_cmd)
  local win_id = vim.api.nvim_get_current_win()
  for key, val in pairs(win_conf) do
    vim.api.nvim_win_set_option(win_id, key, val)
  end
  return win_id
end

function window:open_terminal(opts)
  opts = opts or {
      gdb = "/usr/bin/gdb",
      gdb_args = '-quiet -iex "set pagination off" -iex "set mi-async on" -ex "echo startupdone\n"',
      app_path = "",
      pos = "bottom",
      pos_type = "relative"
  }

  local gdb = opts.gdb or "/usr/bin/gdb"
  local gdb_args = opts.gdb_args or ""
  local app_path = opts.app_path or ""
  local pos = opts.pos or "bottom"
  local pos_type = opts.pos_type or "absolute"

  local size = opts.size or 20
  local gdb_win_id
  if pos == "bottom" or pos == "top" then
    gdb_win_id = window.horizontal_layout(window, size, pos, pos_type, {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = true,
    wrap = false,
    signcolumn = "auto"
  })
  else
    gdb_win_id = window.vertical_layout(window, size, pos, pos_type, {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = true,
    wrap = false,
    signcolumn = "auto"
  })
  end
  window.gdb_bufnr = vim.api.nvim_create_buf(false, true)
  window.stdout_bufnr = window.stdout_bufnr == nil and vim.api.nvim_create_buf(false, true) or window.stdout_bufnr
  window.mi_bufnr = window.mi_bufnr == nil and vim.api.nvim_create_buf(false, true) or window.mi_bufnr
  vim.api.nvim_set_current_buf(window.gdb_bufnr)
  local stdout_chan_id = vim.fn.jobstart({"cat", "-"}, {
    pty = true,
    on_stdout = function (_, msg, _)
      io.write(window.stdout_bufnr .. '\n')
      io.write(vim.api.nvim_buf_line_count(window.stdout_bufnr) .. '\n')
      for _, line in pairs(msg) do
        vim.fn.appendbufline(window.stdout_bufnr, vim.api.nvim_buf_line_count(window.stdout_bufnr), line)
      end
    end,
    on_stderr = function (_, _, _)
    end,
    on_exit = function (_, _, _)
      window.stdout_pty = nil
      vim.cmd('bwipeout! ' .. window.stdout_bufnr)
    end
  })
  window.stdout_pty = vim.api.nvim_get_chan_info(stdout_chan_id).pty
  local mi_chan_id = vim.fn.jobstart({"cat", "-"}, {
    pty = true,
    on_stdout = function (_, msg, _)
      io.write("mi_pty\n")
      for _, line in pairs(msg) do
        vim.fn.appendbufline(window.stdout_bufnr, vim.api.nvim_buf_line_count(window.stdout_bufnr), line)
      end
    end,
    on_stderr = function (_, _, _)
    end,
    on_exit = function (_, _, _)
      window.mi_pty = nil
      vim.cmd('bwipeout! ' .. window.mi_bufnr)
    end
  })
  window.mi_pty = vim.api.nvim_get_chan_info(mi_chan_id).pty

  local cmd = gdb .. " " .. gdb_args .. " -tty " .. window.stdout_pty .. " " .. app_path

  window.term_chan_id = window.term_chan_id == nil and vim.fn.termopen(cmd, {
    on_exit = function (_, _, _)
      window.term_chan_id = nil
      vim.cmd('bwipeout! ' .. window.gdb_bufnr)
    end
  }) or window.term_chan_id
  vim.api.nvim_chan_send(window.term_chan_id, "server new-ui mi " .. window.mi_pty .. " \n")
  vim.api.nvim_buf_set_option(window.gdb_bufnr, "filetype", "gdb-terminal")
  return gdb_win_id
end

function window:open(opts)
  opts = opts or { pos = "bottom", size = 20, pos_type = "relative", filetype = "" }
  if opts.bufnr == nil then
    return nil, nil
  end
  local filetype = opts.filetype or ""
  local size = opts.size or 20
  local pos_type = opts.pos_type or "absolute"
  local win_id
  local pos = opts.pos or "bottom"
  if pos == "bottom" or pos == "top" then
    win_id = window.horizontal_layout(window, size, pos, pos_type, {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = true,
    wrap = false,
    signcolumn = "auto"
  })
  else
    win_id = window.vertical_layout(window, size, pos, pos_type, {
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
  return win_id
end

return window
