#!/usr/bin/env lua

-- Parse output of "luac -l" for GETGLOBAL/SETGLOBAL instructions.
local command = string.format('luac -p -l "%s"', arg[1])
local verbose = tonumber(arg[2]) ~= 0
local compiler = io.popen(command)
local matches = {}
for line in compiler:lines() do
  local inst = line:match '%]%s+([GS]ETGLOBAL)'
  if inst then
    local lnum = tonumber(line:match '%[(%d+)%]') or 0
    local varname = line:match '(%S+)$' or ''
    if lnum > 0 and varname ~= '' then
      matches[#matches + 1] = {inst=inst, lnum=lnum, varname=varname}
    end
  end
end

-- Sort matched globals by ascending line numbers.
table.sort(matches, function(a, b) return a.lnum < b.lnum end)

-- Pass results to vim.
local template = "{'filename': '%s', 'lnum': %i, 'text': '%s %s global %s', 'type': '%s'}"
for _, match in ipairs(matches) do
  local read = match.inst == 'GETGLOBAL'
  local operation = read and 'Read of' or 'Write to'
  local status, type = 'known', 'I'
  if not _G[match.varname] then
    status = 'unknown'
    type = read and 'E' or 'W'
  end
  if type == 'E' or type == 'W' or verbose then
    print(template:format(arg[1], match.lnum, operation, status, match.varname, type))
  end
end
