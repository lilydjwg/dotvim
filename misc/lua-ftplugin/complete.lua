#!/usr/bin/env lua

--[[

Author: Peter Odding <peter@peterodding.com>
Last Change: June 14, 2011
URL: http://peterodding.com/code/vim/lua-ftplugin

This Lua script prints a few hundred lines of Vim script to standard output.
These lines are used by my Lua file type plug-in for the Vim text editor to
provide completion of Lua keywords, globals and library identifiers.

]]

local function sorted(input)
  local keys = {}
  for key in pairs(input) do table.insert(keys, key) end
  table.sort(keys)
  local index = 1
  return function()
    local key = keys[index]
    index = index + 1
    return key, input[key]
  end
end

local keywords = {
  ['and'] = true, ['break'] = true, ['do'] = true, ['else'] = true,
  ['elseif'] = true, ['end'] = true, ['false'] = true, ['for'] = true,
  ['function'] = true, ['if'] = true, ['in'] = true, ['local'] = true,
  ['nil'] = true, ['not'] = true, ['or'] = true, ['repeat'] = true,
  ['return'] = true, ['then'] = true, ['true'] = true,
  ['until'] = true, ['while'] = true
}

io.write 'let s:keywords = ['
for keyword in sorted(keywords) do
  io.write(("\n \\ { 'word': %q, 'kind': 'k' },"):format(keyword))
end
io.write ']\n'

local function identifier(value)
  -- TODO This pattern does *not* match identifiers outside of the C locale
  local pattern = '^[A-Za-z_][A-Za-z_0-9]*$'
  return type(value) == 'string' and value:find(pattern) and not keywords[value]
end

local globals = {}
local libraries = {}

for global, value in pairs(_G) do
  if identifier(global) then
    globals[global .. (type(value) == 'function' and '()' or '')] = type(value) == 'function' and 'f' or 'v'
    if type(value) == 'table' and value ~= _G then
      for member, value in pairs(value) do
        if identifier(member) then
          member = global .. '.' .. member
          libraries[member .. (type(value) == 'function' and '()' or '')] = type(value) == 'function' and 'f' or 'm'
        end
      end
    end
  end
end

io.write '\nlet s:globals = ['
for global, kind in sorted(globals) do
  io.write(("\n \\ { 'word': %q, 'kind': '%s' },"):format(global, kind))
end
io.write ']\n\nlet s:library = ['
for member, kind in sorted(libraries) do
  io.write(("\n \\ { 'word': %q, 'kind': '%s' },"):format(member, kind))
end
io.write ']'

-- vim: ts=2 sw=2 et
