local w = require('gdb.window');
--local inspect = require('inspect')
local i = {}
local buf = {}
local win = {}
local job = {}
GdbConfig = {
    project = {
      gdb = "/usr/bin/gdb",
      app = "",
      args = "",
    },
    layout = {
      {
        position = "bottom",
        window = {
            "console",
            "gdb"
        },
        size = 18
      },
      {
        position = "right",
        window = {
            "scope",
            "breakpoints",
            "stack",
        },
        size = 50
      },
    },
    log = "true",
    log_path = "/tmp/light-gdb.log",
  }


  --{ {
    --layout = "console",
    --position = "bottom",
    --size = 18,
    --window = { "gdb" }
  --}, {
    --layout = "scope",
    --position = "right",
    --size = 50,
    --window = { "breakpoints", "stack" }
  --} }


function i.open_console(position, pos_type, size)
  local winid = nil
  buf.console, winid = w.open({
    pos = position,
    size = size,
    bufnr = buf.console,
    pos_type = pos_type
  })
  return buf.console, winid
end

function i.open_scope(position, pos_type, size)
  local winid = nil
  buf.scope, winid = w.open({
    pos = position,
    size = size,
    bufnr = buf.scope,
    pos_type = pos_type
  })
  return buf.scope, winid
end

function i.open_gdb(position, pos_type, size)
  local winid = nil
  buf.gdb, winid = w.open({
    pos = position,
    size = size,
    bufnr = buf.gdb,
    pos_type = pos_type
  })
  return buf.gdb, winid
end

function i.open_breakpoints(position, pos_type, size)
  local winid = nil
  buf.breakpoints, winid = w.open({
    pos = position,
    size = size,
    bufnr = buf.breakpoints,
    pos_type = pos_type
  })
  return buf.breakpoints, winid
end

function i.open_stack(position, pos_type, size)
  local winid = nil
  buf.stack,winid = w.open({
    pos = position,
    size = size,
    bufnr = buf.stack,
    pos_type = pos_type
  })
  return buf.stack, winid
end

function i.setup(obj)
  obj = obj or GdbConfig
  require'gdb.log'.init()

  -- restructuring
  local layout_tree = {}
  for index, item in pairs(obj.layout) do
    table.insert(layout_tree, {})
    layout_tree[index].layout = item.window[1]
    layout_tree[index].window = {}
    layout_tree[index].size = item.size
    layout_tree[index].position = item.position
    for index_2, name in pairs(item.window) do
      if index_2 == 1 then
        goto C
      end
      table.insert(layout_tree[index].window, name)
      ::C::
    end
  end

  local win_list = {}
  for _, item in pairs(layout_tree) do
    if item.layout == "console" then
      table.insert(win_list, select(2, i.open_console(item.position, "absolute", item.size)))
    elseif item.layout == "gdb" then
      table.insert(win_list, select(2, i.open_gdb(item.position, "absolute", item.size)))
    elseif item.layout == "scope" then
      table.insert(win_list, select(2, i.open_scope(item.position, "absolute", item.size)))
    elseif item.layout == "breakpoints" then
      table.insert(win_list, select(2, i.open_breakpoints(item.position, "absolute", item.size)))
    elseif item.layout == "stack" then
      table.insert(win_list, select(2, i.open_stack(item.position, "absolute", item.size)))
    end
  end

  for k1, item in pairs(layout_tree) do
    local win_id = win_list[k1]
    vim.api.nvim_set_current_win(win_id)
    local position = (item.position == "bottom" or item.position == "top" ) and "right" or "top"
    for _, v in pairs(item.window) do
      w.open({pos = position, size = 0, pos_type = "relative"})
    end
  end
    --vim.api.nvim_set_current_buf(window.gdb_bufnr)


  --for _, item in pairs(obj.layout) do
    --local pos_type = "absolute"
    --local position = item.position
    --local size = item.size
    --for key, win_type in pairs(item.window) do
      --if key == 1 then
        --goto continue
      --end
      --if item.window[0] == "console" then

      --end
      --if win_type == "console" then
        --buf.console, win.console = w.open({
          --pos = position,
          --size = size,
          --bufnr = buf.console,
          --pos_type = pos_type
        --})
      --elseif win_type == "gdb" then
        --buf.gdb, win.gdb = w.open({
          --pos = position,
          --size = size,
          --bufnr = buf.gdb,
          --pos_type = pos_type
        --})
      --elseif win_type == "scope" then
        --buf.scope, win.scope = w.open({
          --pos = position,
          --size = size,
          --bufnr = buf.scope,
          --pos_type = pos_type
        --})
      --elseif win_type == "breakpoints" then
        --buf.breakpoints, win.breakpoints = w.open({
          --pos = position,
          --size = size,
          --bufnr = buf.breakpoints,
          --pos_type = pos_type
        --})
      --elseif win_type == "stack" then
        --buf.stack, win.stack = w.open({
          --pos = position,
          --size = size,
          --bufnr = buf.stack,
          --pos_type = pos_type
        --})
      --end
      --position = (item.position == "bottom" or item.position == "top" ) and "right" or "top"
      --pos_type = "relative"
      --size = 0
      --::continue::
    --end
  --end

  -- require('gdb.window').open_terminal(nil, { gdb_args = "-quiet -iex 'set pagination off' -iex 'set mi-async on' -ex 'echo startupdone\n'",app_path = vim.g.cpp_executable_program, pos = "bottom", size = 24})
  --
  -- {
  --   gdb_args = "-quiet -iex 'set pagination off' -iex 'set mi-async on' -ex 'echo startupdone\n'",
  --   app_path = vim.g.cpp_executable_program,
  --   pos = "bottom", size = 24
  -- }
end

function i.open_terminal(opts)
  opts = opts or {
      gdb = "/usr/bin/gdb",
      gdb_args = '-quiet -iex "set pagination off" -iex "set mi-async on" -ex "echo startupdone\n"',
      app_path = "",
  }

  local gdb = opts.gdb or "/usr/bin/gdb"
  local gdb_args = opts.gdb_args or ""
  local app_path = opts.app_path or ""

  buf.gdb = buf.gdb or vim.api.nvim_create_buf(false, true)
  buf.stdout = buf.stdout or vim.api.nvim_create_buf(false, true)
  buf.mi = buf.mi or vim.api.nvim_create_buf(false, true)

  local stdout_chan_id = vim.fn.jobstart({"cat", "-"}, {
    pty = true,
    on_stdout = function (_, msg, _)
      io.write(buf.stdout .. '\n')
      io.write(vim.api.nvim_buf_line_count(buf.stdout) .. '\n')
      for _, line in pairs(msg) do
        vim.fn.appendbufline(buf.stdout, vim.api.nvim_buf_line_count(buf.stdout), line)
      end
    end,
    on_stderr = function (_, _, _)
    end,
    on_exit = function (_, _, _)
      job.stdout_pty = nil
      vim.cmd('bwipeout! ' .. buf.stdout)
    end
  })
  job.stdout_pty = vim.api.nvim_get_chan_info(stdout_chan_id).pty
  local mi_chan_id = vim.fn.jobstart({"cat", "-"}, {
    pty = true,
    on_stdout = function (_, msg, _)
      io.write("mi_pty\n")
      for _, line in pairs(msg) do
        vim.fn.appendbufline(buf.stdout, vim.api.nvim_buf_line_count(buf.stdout), line)
      end
    end,
    on_stderr = function (_, _, _)
    end,
    on_exit = function (_, _, _)
      job.mi_pty = nil
      vim.cmd('bwipeout! ' .. buf.mi)
    end
  })
  job.mi_pty = vim.api.nvim_get_chan_info(mi_chan_id).pty

  local cmd = gdb .. " " .. gdb_args .. " -tty " .. job.stdout_pty .. " " .. app_path

  job.term_chan_id = vim.api.nvim_open_term(buf.gdb, {
    on_input = function (_, _, _, data)
      vim.api.nvim_chan_send( job.term_job_id, data)
    end,
  })

  job.term_job_id = job.term_job_id or vim.fn.jobstart(cmd, {
    height = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win()),
    width = vim.api.nvim_win_get_width(vim.api.nvim_get_current_win()),
    pty = true,
    on_exit = function (_, _, _)
      job.term_job_id = nil
      vim.cmd('bwipeout! ' .. buf.gdb)
      vim.cmd('bwipeout! ' .. buf.stdout)
      vim.cmd('bwipeout! ' .. buf.mi)
    end,
    on_stdout = function (_, msg)
      vim.api.nvim_chan_send(job.term_chan_id, table.concat(msg, "\n"))
    end
  })
  vim.api.nvim_chan_send(job.term_job_id, "server new-ui mi " .. job.mi_pty .. " \n")
  vim.api.nvim_buf_set_option(buf.gdb, "filetype", "gdb-terminal")
  return buf.gdb
end

return i
