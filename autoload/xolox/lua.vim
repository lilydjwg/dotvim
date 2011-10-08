" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 26, 2011
" URL: http://peterodding.com/code/vim/lua-ftplugin

let g:xolox#lua#version = '0.6.23'
let s:miscdir = expand('<sfile>:p:h:h:h') . '/misc/lua-ftplugin'
let s:omnicomplete_script = s:miscdir . '/omnicomplete.lua'
let s:globals_script = s:miscdir . '/globals.lua'

function! xolox#lua#includeexpr(fname) " {{{1
  " Search module path for matching Lua scripts.
  let module = substitute(a:fname, '\.', '/', 'g')
  for template in xolox#lua#getsearchpath('$LUA_PATH', 'package.path')
    let expanded = substitute(template, '?', module, 'g')
    call xolox#misc#msg#debug("lua.vim %s: Expanded %s -> %s", g:xolox#lua#version, template, expanded)
    if filereadable(expanded)
      call xolox#misc#msg#debug("lua.vim %s: Matched existing file %s", g:xolox#lua#version, expanded)
      return expanded
    endif
  endfor
  " Default to given name.
  return a:fname
endfunction

function! xolox#lua#getsearchpath(envvar, luavar) " {{{1
  let path = ''
  if has('lua')
    " Try to get the search path using the Lua Interface for Vim.
    try
      redir => path
      execute 'silent lua print(' . a:luavar . ')'
      redir END
      call xolox#misc#msg#debug("lua.vim %s: Got %s from Lua Interface for Vim", g:xolox#lua#version, a:luavar)
    catch
      redir END
    endtry
  endif
  if empty(path)
    let path = eval(a:envvar)
    if !empty(path)
      call xolox#misc#msg#debug("lua.vim %s: Got %s from %s", g:xolox#lua#version, a:luavar, a:envvar)
    else
      let path = system('lua -e "io.write(' . a:luavar . ')"')
      if v:shell_error
        call xolox#misc#msg#warn("lua.vim %s: Failed to get %s from external Lua interpreter: %s", g:xolox#lua#version, a:luavar, path)
      else
        call xolox#misc#msg#debug("lua.vim %s: Got %s from external Lua interpreter", g:xolox#lua#version, a:luavar)
      endif
    endif
  endif
  return split(xolox#misc#str#trim(path), ';')
endfunction

function! xolox#lua#autocheck() " {{{1
  if &filetype == 'lua'
    if xolox#misc#option#get('lua_check_syntax', 1)
      call xolox#lua#checksyntax()
    endif
    if xolox#misc#option#get('lua_check_globals', 0) && empty(getqflist())
      call xolox#lua#checkglobals(0)
    endif
  endif
endfunction

function! xolox#lua#checksyntax() " {{{1
  let compiler_name = xolox#misc#option#get('lua_compiler_name', 'luac')
  let compiler_args = xolox#misc#option#get('lua_compiler_args', '-p')
  let error_format = xolox#misc#option#get('lua_error_format', 'luac: %f:%l: %m')
  if !executable(compiler_name)
    let message = "lua.vim %s: The configured Lua compiler"
    let message .= " doesn't seem to be available! I'm disabling"
    let message .= " automatic syntax checking for Lua scripts."
    let g:lua_check_syntax = 0
    call xolox#misc#msg#warn(message, g:xolox#lua#version)
  else
    let mp_save = &makeprg
    let efm_save = &errorformat
    try
      let &makeprg = compiler_name
      let &errorformat = error_format
      let winnr = winnr()
      let filename = expand('%:t')
      execute 'silent make!' compiler_args shellescape(expand('%'))
      cwindow
      if winnr() != winnr
        let message = ['Syntax errors reported by', compiler_name, compiler_args, filename]
        let w:quickfix_title = join(message)
      endif
      execute winnr . 'wincmd w'
      call s:highlighterrors()
    finally
      let &makeprg = mp_save
      let &errorformat = efm_save
    endtry
  endif
endfunction

function! s:highlighterrors()
  let hlgroup = 'luaCompilerError'
  if !hlexists(hlgroup)
    execute 'highlight def link' hlgroup 'Error'
  else
    call clearmatches()
  endif
  let pattern = '^\%%%il.*\n\?'
  for entry in getqflist()
    call matchadd(hlgroup, '\%' . min([entry.lnum, line('$')]) . 'l')
    call xolox#misc#msg#warn("lua.vim %s: Syntax error on line %i: %s", g:xolox#lua#version, entry.lnum, entry.text)
  endfor
endfunction

function! xolox#lua#checkglobals(verbose) " {{{1
  let output = xolox#lua#dofile(s:globals_script, [expand('%'), a:verbose])
  let qflist = eval('[' . substitute(output, '\n', ',', 'g') . ']')
  call setqflist(qflist, 'r')
  cwindow
endfunction

function! xolox#lua#help() " {{{1
  " Get the expression under the cursor.
  let cword = ''
  try
    let isk_save = &isk
    set iskeyword+=.,:
    let cword = expand('<cword>')
  finally
    let &isk = isk_save
  endtry
  if cword != ''
    try
      call s:lookupmethod(cword, 'lrv-string.', '\v<(byte|char|dump|g?find|format|len|lower|g?match|rep|reverse|g?sub|upper)>')
      call s:lookupmethod(cword, 'lrv-file:', '\v<(close|flush|lines|read|seek|setvbuf|write)>')
      call s:lookupmethod(cword, '', '\v:\w+>')
      call s:lookuptopic('lrv-' . cword)
      call s:lookuptopic(cword)
      call s:lookuptopic('luarefvim.txt')
      help
    catch /^done$/
      return
    endtry
  endif
  help
endfunction

function! s:lookupmethod(cword, prefix, pattern)
  let method = matchstr(a:cword, a:pattern)
  if method != ''
    let identifier = a:prefix . method
    call xolox#misc#msg#debug("lua.vim %s: Translating '%s' -> '%s'", g:xolox#lua#version, a:cword, identifier)
    call s:lookuptopic(identifier)
  endif
endfunction

function! s:lookuptopic(topic)
  try
    " Lookup the given topic in Vim's help files.
    execute 'help' escape(a:topic, ' []*?')
    " Abuse exceptions for non local jumping.
    throw 'done'
  catch /^Vim\%((\a\+)\)\=:E149/
    " Ignore E149: Sorry, no help for <keyword>.
    return
  endtry
endfunction

function! xolox#lua#jumpblock(forward) " {{{1
  let start = '\<\%(for\|function\|if\|repeat\|while\)\>'
  let middle = '\<\%(elseif\|else\)\>'
  let end = '\<\%(end\|until\)\>'
  let flags = a:forward ? '' : 'b'
  return searchpair(start, middle, end, flags, '!xolox#lua#tokeniscode()')
endfunction

function! s:getfunscope()
  let firstpos = [0, 1, 1, 0]
  let lastpos = getpos('$')
  while search('\<function\>', 'bW')
    if xolox#lua#tokeniscode()
      let firstpos = getpos('.')
      break
    endif
  endwhile
  if xolox#lua#jumpblock(1)
    let lastpos = getpos('.')
  endif
  return [firstpos, lastpos]
endfunction

function! xolox#lua#jumpthisfunc(forward) " {{{1
  let cpos = [line('.'), col('.')]
  let fpos = [1, 1]
  let lpos = [line('$'), 1]
  while search('\<function\>', a:forward ? 'W' : 'bW')
    if xolox#lua#tokeniscode()
      break
    endif
  endwhile
  let cursorline = line('.')
  let [firstpos, lastpos] = s:getfunscope()
  if cursorline == (a:forward ? lastpos : firstpos)[1]
    " make the mapping repeatable (line wise at least)
    execute a:forward ? (lastpos[1] + 1) : (firstpos[1] - 1)
    let [firstpos, lastpos] = s:getfunscope()
  endif
  call setpos('.', a:forward ? lastpos : firstpos)
endfunction

function! xolox#lua#jumpotherfunc(forward) " {{{1
  let view = winsaveview()
  " jump to the start/end of the function
  call xolox#lua#jumpthisfunc(a:forward)
  " search for the previous/next function
  while search('\<function\>', a:forward ? 'W' : 'bW')
    " ignore strings and comments containing 'function'
    if xolox#lua#tokeniscode()
      return 1
    endif
  endwhile
  call winrestview(view)
endfunction

function! xolox#lua#tokeniscode() " {{{1
  return s:getsynid(0) !~? 'string\|comment'
endfunction

function! s:getsynid(transparent)
  let id = synID(line('.'), col('.'), 1)
  if a:transparent
    let id = synIDtrans(id)
  endif
  return synIDattr(id, 'name')
endfunction

if exists('loaded_matchit')

  function! xolox#lua#matchit() " {{{1
    let cword = expand('<cword>')
    if cword == 'end'
      let s = ['function', 'if', 'for', 'while']
      let e = ['end']
      unlet! b:match_skip
    elseif cword =~ '^\(function\|return\|yield\)$'
      let s = ['function']
      let m = ['return', 'yield']
      let e = ['end']
      let b:match_skip = "xolox#lua#matchit_ignore('^luaCond$')"
      let b:match_skip .= " || (expand('<cword>') == 'end' && xolox#lua#matchit_ignore('^luaStatement$'))"
    elseif cword =~ '^\(for\|in\|while\|do\|repeat\|until\|break\)$'
      let s = ['for', 'repeat', 'while']
      let m = ['break']
      let e = ['end', 'until']
      let b:match_skip = "xolox#lua#matchit_ignore('^\\(luaCond\\|luaFunction\\)$')"
    elseif cword =~ '\(if\|then\|elseif\|else\)$'
      let s = ['if']
      let m = ['elseif', 'else']
      let e = ['end']
      let b:match_skip = "xolox#lua#matchit_ignore('^\\(luaFunction\\|luaStatement\\)$')"
    else
      let s = ['for', 'function', 'if', 'repeat', 'while']
      let m = ['break', 'elseif', 'else', 'return']
      let e = ['eend', 'until']
      unlet! b:match_skip
    endif
    let p = '\<\(' . join(s, '\|') . '\)\>'
    if exists('m')
      let p .=  ':\<\(' . join(m, '\|') . '\)\>'
    endif
    return p . ':\<\(' . join(e, '\|') . '\)\>'
  endfunction

  function! xolox#lua#matchit_ignore(ignored) " {{{1
    let word = expand('<cword>')
    let type = s:getsynid(0)
    return type =~? a:ignored || type =~? 'string\|comment'
  endfunction

endif

function! xolox#lua#completefunc(init, base) " {{{1
  if a:init
    return s:getcompletionprefix()
  endif
  let items = []
  if xolox#misc#option#get('lua_complete_keywords', 1)
    call extend(items, g:xolox#lua_data#keywords)
  endif
  if xolox#misc#option#get('lua_complete_globals', 1)
    call extend(items, g:xolox#lua_data#globals)
  endif
  if xolox#misc#option#get('lua_complete_library', 1)
    call extend(items, g:xolox#lua_data#library)
  endif
  let pattern = '^' . xolox#misc#escape#pattern(a:base)
  call filter(items, 'v:val.word =~ pattern')
  return s:addsignatures(items)
endfunction

function! s:getcompletionprefix()
  return match(strpart(getline('.'), 0, col('.') - 1), '\w\+\.\?\w*$')
endfunction

function! s:addsignatures(entries)
  for entry in a:entries
    let signature = xolox#lua#getsignature(entry.word)
    if !empty(signature) && signature != entry.word
      let entry.menu = signature
    endif
  endfor
  return a:entries
endfunction

function! xolox#lua#getsignature(identifier) " {{{1
  let identifier = substitute(a:identifier, '()$', '', '')
  let signature = get(g:xolox#lua_data#signatures, identifier, '')
  if empty(signature)
    let signature = get(g:xolox#lua_data#signatures, 'string.' . identifier, '')
  endif
  if empty(signature)
    let signature = get(g:xolox#lua_data#signatures, 'file:' . identifier, '')
  endif
  return signature
endfunction

function! xolox#lua#omnifunc(init, base) " {{{1
  if a:init
    return s:getcompletionprefix()
  elseif !xolox#misc#option#get('lua_complete_omni', 0)
    throw printf("lua.vim %s: omni completion needs to be explicitly enabled, see the readme!", g:xolox#lua#version)
  endif
  if !exists('s:omnifunc_modules')
    let s:omnifunc_modules = xolox#lua#getomnimodules()
  endif
  if !exists('s:omnifunc_variables')
    let s:omnifunc_variables = xolox#lua#getomnivariables(s:omnifunc_modules)
    call s:addsignatures(s:omnifunc_variables)
  endif
  " FIXME When you type "require'" without a space in between
  " the getline('.') call below returns an empty string?!
  let pattern = '^' . xolox#misc#escape#pattern(a:base)
  if getline('.') =~ 'require[^''"]*[''"]'
    return filter(copy(s:omnifunc_modules), 'v:val =~ pattern')
  elseif a:base == ''
    return s:omnifunc_variables
  else
    return filter(copy(s:omnifunc_variables), 'v:val.word =~ pattern')
  endif
endfunction

function! xolox#lua#getomnimodules() " {{{1
  let starttime = xolox#misc#timer#start()
  let modulemap = {}
  let luapath = xolox#lua#getsearchpath('$LUA_PATH', 'package.path')
  let luacpath = xolox#lua#getsearchpath('$LUA_CPATH', 'package.cpath')
  for searchpath in [luapath, luacpath]
    call s:expandsearchpath(searchpath, modulemap)
  endfor
  let modules = keys(modulemap)
  call sort(modules)
  let msg = "lua.vim %s: Collected %i module names for omni completion in %s"
  call xolox#misc#timer#stop(msg, g:xolox#lua#version, len(modules), starttime)
  return modules
endfunction

function! s:expandsearchpath(searchpath, modules)
  " Collect the names of all installed modules by traversing the search paths.
  for template in a:searchpath
    let components = split(template, '?')
    if len(components) != 2
      let msg = "lua.vim %s: Failed to parse search path entry: %s"
      call xolox#misc#msg#debug(msg, g:xolox#lua#version, template)
      continue
    endif
    let [prefix, suffix] = components
    " XXX Never recursively search current working directory because
    " it might be arbitrarily deep, e.g. when working directory is /
    if prefix =~ '^.[\\/]$'
      let msg = "lua.vim %s: Refusing to expand dangerous search path entry: %s"
      call xolox#misc#msg#debug(msg, g:xolox#lua#version, template)
      continue
    endif
    let pattern = substitute(template, '?', '**/*', 'g')
    call xolox#misc#msg#debug("lua.vim %s: Transformed %s -> %s", g:xolox#lua#version, template, pattern)
    let msg = "lua.vim %s: Failed to convert pathname to module name, %s doesn't match! (%s: '%s', pathname: '%s')"
    for pathname in split(glob(pattern), "\n")
      if pathname[0 : len(prefix)-1] != prefix
        " Validate prefix of resulting pathname.
        call xolox#misc#msg#warn(msg, g:xolox#lua#version, 'prefix', 'prefix', prefix, pathname)
      elseif pathname[-len(suffix) : -1] != suffix
        " Validate suffix of resulting pathname.
        call xolox#misc#msg#warn(msg, g:xolox#lua#version, 'suffix', 'suffix', suffix, pathname)
      elseif pathname !~ 'test'
        let relative = pathname[len(prefix) : -len(suffix)-1]
        let modulename = substitute(relative, '[\\/]\+', '.', 'g')
        let a:modules[modulename] = 1
        call xolox#misc#msg#debug("lua.vim %s: Transformed '%s' -> '%s'", g:xolox#lua#version, pathname, modulename)
      endif
    endfor
  endfor
endfunction

function! xolox#lua#getomnivariables(modules) " {{{1
  let starttime = xolox#misc#timer#start()
  let output = xolox#lua#dofile(s:omnicomplete_script, a:modules)
  let variables = eval('[' . substitute(output, '\_s\+', ',', 'g') . ']')
  call sort(variables, 1)
  let msg = "lua.vim %s: Collected %i variables for omni completion in %s"
  call xolox#misc#timer#stop(msg, g:xolox#lua#version, len(variables), starttime)
  return variables
endfunction

function! xolox#lua#completedynamic(type) " {{{1
  if xolox#misc#option#get('lua_complete_dynamic', 1)
    if (a:type == "'" || a:type == '"') && xolox#misc#option#get('lua_complete_omni', 0)
      if strpart(getline('.'), 0, col('.') - 1) =~ 'require[^''"]*$'
        return a:type . "\<C-x>\<C-o>"
      endif
    elseif a:type == '.' && s:getsynid(1) !~? 'string\|comment\|keyword'
      let column = col('.') - 1
      " Gotcha: even though '.' is remapped it counts as a column?
      if column && getline('.')[column - 1] =~ '\w'
        " This results in "Pattern not found" when no completion candidates
        " are available, which is kind of annoying. But I don't know of an
        " alternative to :silent that can be used inside of <expr>
        " mappings?!
        if xolox#misc#option#get('lua_complete_omni', 0)
          return a:type . "\<C-x>\<C-o>"
        else
          return a:type . "\<C-x>\<C-u>"
        endif
      endif
    endif
  endif
  return a:type
endfunction

function! xolox#lua#tweakoptions() " {{{1
  if &filetype == 'lua'
    let s:completeopt_save = &cot
    set completeopt+=longest
  elseif exists('s:completeopt_save')
    let &completeopt = s:completeopt_save
  endif
endfunction

function! xolox#lua#dofile(pathname, arguments) " {{{1
  if has('lua')
    " Use the Lua Interface for Vim.
    redir => output
    lua arg = vim.eval('a:arguments')
    execute 'silent luafile' fnameescape(a:pathname)
    redir END
  else
    " Use the command line Lua interpreter.
    let output = xolox#misc#str#trim(system(join(['lua', a:pathname] + a:arguments)))
    if v:shell_error
      let msg = "lua.vim %s: Failed to retrieve omni completion candidates (output: '%s')"
      call xolox#misc#msg#warn(msg, g:xolox#lua#version, output)
    endif
  endif
  return xolox#misc#str#trim(output)
endfunction

" vim: ts=2 sw=2 et
