#!/usr/bin/env lua

local http = require 'socket.http'
local webpage = http.request 'http://www.lua.org/manual/5.1/manual.html'
local matches = {}
for anchor, signature in webpage:gmatch '<h3>%s*<a%s+name="pdf%-(.-)">%s*<code>%s*(.-)%s*</code>%s*</a>%s*</h3>' do
  if anchor ~= signature then
    signature = signature:gsub('&middot;', '.')
    signature = signature:gsub('%s+%(', '(')
    table.insert(matches, string.format("'%s': '%s'", anchor, signature))
  end
end
local newline = '\n    \\ '
print(string.format('let g:xolox#lua_data#signatures = {%s%s }', newline, table.concat(matches, ',' .. newline)))
