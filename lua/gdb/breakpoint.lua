local breakpoint = {}

function breakpoint:init()
  vim.highlight.create('debugPointer', { ctermbg = 'darkblue', guibg = 'darkblue' })
  vim.fn.sign_define('lgdb_debug_pointer', {linehl = 'debugPointer', text = '➡' })
end

function breakpoint:define_enabled(buf_name, lnum)
  vim.fn.sign_define('lgdb_enabled_' .. buf_name .. ':' .. lnum, { text = '🔴' })
end

function breakpoint:define_disabled(buf_name, lnum)
  vim.fn.sign_define('lgdb_disabled_' .. buf_name .. ':' .. lnum, { text = '🚫' })
end

function breakpoint:place(buf_name, lnum)
  buf_name = buf_name or vim.fn.expand('%:p')
  if buf_name == '' then
    return nil
  end
  lnum = lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'lgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'lgdb_enabled_' .. buf_name .. ':' .. lnum and sign.group == 'lgdb' then
        return
      end
    end
    ::continue::
  end
  breakpoint.define_enabled(breakpoint, buf_name, lnum)
  vim.fn.sign_place(0, 'lgdb', 'lgdb_enabled_' .. buf_name .. ':' .. lnum, buf_name, {lnum = lnum})
end

function breakpoint:unplace(buf_name, lnum)
  buf_name = buf_name or vim.fn.expand('%:p')
  if buf_name == '' then
    return nil
  end
  lnum = lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'lgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'lgdb_enabled_' .. buf_name .. ':' .. lnum and sign.group == 'lgdb' then
        vim.fn.sign_unplace('lgdb', {buffer = buf_name, id = sign.id} )
        return true
      end
      if sign.name == 'lgdb_disabled_' .. buf_name .. ':' .. lnum and sign.group == 'lgdb' then
        vim.fn.sign_unplace('lgdb', {buffer = buf_name, id = sign.id} )
        return true
      end
    end
    ::continue::
  end
  return false
end

function breakpoint:enable(buf_name, lnum)
  buf_name = buf_name or vim.fn.expand('%:p')
  if buf_name == '' then
    return nil
  end
  lnum = lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'lgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'lgdb_disabled_' .. buf_name .. ':' .. lnum and sign.group == 'lgdb' then
        vim.fn.sign_unplace('lgdb', {buffer = buf_name, id = sign.id} )
        breakpoint.define_enabled(breakpoint, buf_name, lnum)
        vim.fn.sign_place(0, 'lgdb', 'lgdb_enabled_' .. buf_name .. ':' .. lnum, buf_name, {lnum = lnum})
        return true
      end
    end
    ::continue::
  end
  return false
end

function breakpoint:disable(buf_name, lnum)
  buf_name = buf_name or vim.fn.expand('%:p')
  if buf_name == '' then
    return nil
  end
  lnum = lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'lgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'lgdb_enabled_' .. buf_name .. ':' .. lnum and sign.group == 'lgdb' then
        vim.fn.sign_unplace('lgdb', {buffer = buf_name, id = sign.id} )
        breakpoint.define_disabled(breakpoint, buf_name, lnum)
        vim.fn.sign_place(0, 'lgdb', 'lgdb_disabled_' .. buf_name .. ':' .. lnum, buf_name, {lnum = lnum})
        return true
      end
    end
    ::continue::
  end
  return false
end

function breakpoint:toggle(buf_name, lnum)
  local res = breakpoint.unplace(breakpoint, buf_name, lnum)
  if res == false then
    breakpoint.place(breakpoint, buf_name, lnum)
  end
end

function breakpoint:debug_pointer(file_name, lnum)
  if file_name == nil or lnum == nil then return end
  breakpoint:remove_debug_pointer()
  vim.cmd('edit ' .. file_name)
  breakpoint.pointer_id = vim.fn.sign_place(0, 'lgdb', 'lgdb_debug_pointer', file_name, {lnum = lnum})
  breakpoint.pointer = file_name
  vim.cmd(tostring(lnum))
  vim.cmd('normal zz')
end

function breakpoint:remove_debug_pointer()
  if breakpoint.pointer and breakpoint.pointer_id then
    vim.fn.sign_unplace('lgdb', {buffer = breakpoint.pointer, id = breakpoint.pointer_id } )
    breakpoint.pointer_id = nil
    breakpoint.pointer = nil
  end
end


return breakpoint
