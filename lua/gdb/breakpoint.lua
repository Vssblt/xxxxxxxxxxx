local breakpoint = {}

function breakpoint:define_enabled(buf_name, lnum)
  vim.fn.sign_define('vgdb_enabled_' .. buf_name .. ':' .. lnum, { text = '🔴' })
end

function breakpoint:define_disabled(buf_name, lnum)
  vim.fn.sign_define('vgdb_disabled_' .. buf_name .. ':' .. lnum, { text = '🚫' })
end

function breakpoint:place(buf_name, lnum)
  buf_name = buf_name and buf_name or vim.fn.bufname()
  if buf_name == '' then
    return nil
  end
  lnum = lnum and lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'vgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'vgdb_enabled_' .. buf_name .. ':' .. lnum and sign.group == 'vgdb' then
        return
      end
    end
    ::continue::
  end
  breakpoint.define_enabled(breakpoint, buf_name, lnum)
  vim.fn.sign_place(0, 'vgdb', 'vgdb_enabled_' .. buf_name .. ':' .. lnum, buf_name, {lnum = lnum})
end

function breakpoint:unplace(buf_name, lnum)
  buf_name = buf_name and buf_name or vim.fn.bufname()
  if buf_name == '' then
    return nil
  end
  lnum = lnum and lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'vgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'vgdb_enabled_' .. buf_name .. ':' .. lnum and sign.group == 'vgdb' then
        vim.fn.sign_unplace('vgdb', {buffer = buf_name, id = sign.id} )
        return true
      end
      if sign.name == 'vgdb_disabled_' .. buf_name .. ':' .. lnum and sign.group == 'vgdb' then
        vim.fn.sign_unplace('vgdb', {buffer = buf_name, id = sign.id} )
        return true
      end
    end
    ::continue::
  end
  return false
end

function breakpoint:enable(buf_name, lnum)
  buf_name = buf_name and buf_name or vim.fn.bufname()
  if buf_name == '' then
    return nil
  end
  lnum = lnum and lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'vgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'vgdb_disabled_' .. buf_name .. ':' .. lnum and sign.group == 'vgdb' then
        vim.fn.sign_unplace('vgdb', {buffer = buf_name, id = sign.id} )
        breakpoint.define_enabled(breakpoint, buf_name, lnum)
        vim.fn.sign_place(0, 'vgdb', 'vgdb_enabled_' .. buf_name .. ':' .. lnum, buf_name, {lnum = lnum})
        return true
      end
    end
    ::continue::
  end
  return false
end

function breakpoint:disable(buf_name, lnum)
  buf_name = buf_name and buf_name or vim.fn.bufname()
  if buf_name == '' then
    return nil
  end
  lnum = lnum and lnum or vim.fn.line('.')
  local items = vim.fn.sign_getplaced(buf_name, {group = 'vgdb'})
  for _, placed_list in pairs(items) do
    if vim.fn.bufnr(buf_name) ~= placed_list.bufnr then
      goto continue
    end
    for _, sign in pairs(placed_list.signs) do
      if sign.name == 'vgdb_enabled_' .. buf_name .. ':' .. lnum and sign.group == 'vgdb' then
        vim.fn.sign_unplace('vgdb', {buffer = buf_name, id = sign.id} )
        breakpoint.define_disabled(breakpoint, buf_name, lnum)
        vim.fn.sign_place(0, 'vgdb', 'vgdb_disabled_' .. buf_name .. ':' .. lnum, buf_name, {lnum = lnum})
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

return breakpoint
