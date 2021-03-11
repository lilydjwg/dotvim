function! inline_edit#controller#New()
  let controller = {
        \ 'proxies': [],
        \
        \ 'NewProxy':    function('inline_edit#controller#NewProxy'),
        \ 'SyncProxies': function('inline_edit#controller#SyncProxies'),
        \ 'VisualEdit':  function('inline_edit#controller#VisualEdit'),
        \ 'PatternEdit': function('inline_edit#controller#PatternEdit'),
        \ 'IndentEdit':  function('inline_edit#controller#IndentEdit'),
        \ }

  return controller
endfunction

function! inline_edit#controller#NewProxy(start_line, end_line, filetype, indent) dict
  let proxy = inline_edit#proxy#New(self, a:start_line, a:end_line, a:filetype, a:indent)
  call add(self.proxies, proxy)

  return proxy
endfunction

" If any of the other proxies are located below the given one, we need to
" update their starting and ending lines, since any change would result in a
" line shift.
"
" a:changed_proxy is the proxy that changed
" a:delta is the change in the number of lines.
function! inline_edit#controller#SyncProxies(changed_proxy, delta) dict
  if a:delta == 0
    return
  endif

  for proxy in self.proxies
    if proxy == a:changed_proxy
      continue
    endif

    if a:changed_proxy.end <= proxy.start
      let proxy.start += a:delta
      let proxy.end   += a:delta
    endif
  endfor
endfunction

function! inline_edit#controller#VisualEdit(filetype) dict
  let [start, end] = [line("'<"), line("'>")]
  let indent = indent(end)

  if a:filetype != ''
    let filetype = a:filetype
  else
    let filetype = &filetype
  endif

  call self.NewProxy(start, end, filetype, indent)
endfunction

function! inline_edit#controller#PatternEdit(pattern) dict
  let pattern = extend({
        \ 'sub_filetype':      &filetype,
        \ 'indent_adjustment': 0,
        \ }, a:pattern)

  call inline_edit#PushCursor()

  " find start of area
  if searchpair(pattern.start, '', pattern.end, 'Wb') <= 0
    call inline_edit#PopCursor()
    return 0
  endif
  let start = line('.') + 1

  " find end of area
  if searchpair(pattern.start, '', pattern.end, 'W') <= 0
    call inline_edit#PopCursor()
    return 0
  endif
  let end    = line('.') - 1
  let indent = indent(line('.')) + pattern.indent_adjustment * (&et ? &sw : &ts)

  call inline_edit#PopCursor()

  call self.NewProxy(start, end, pattern.sub_filetype, indent)
  return 1
endfunction

function! inline_edit#controller#IndentEdit(pattern) dict
  let pattern = extend({
        \ 'sub_filetype':      &filetype,
        \ 'indent_adjustment': 0,
        \ }, a:pattern)

  call inline_edit#PushCursor()

  " find start of area
  if search(pattern.start, 'Wb') <= 0
    call inline_edit#PopCursor()
    return 0
  endif
  let start = line('.') + 1

  " find end of area
  let end = s:LowerIndentLimit(start)
  if end - start < 0
    return 0
  endif
  let indent = indent(end) + pattern.indent_adjustment * (&et ? &sw : &ts)

  call inline_edit#PopCursor()

  if line('.') < start || line('.') > end
    " then we're not inside the section
    return 0
  endif

  call self.NewProxy(start, end, pattern.sub_filetype, indent)
  return 1
endfunction

function! s:LowerIndentLimit(lineno)
  let base_indent  = indent(a:lineno)
  let current_line = a:lineno
  let next_line    = nextnonblank(current_line + 1)

  while current_line < line('$') && indent(next_line) >= base_indent
    let current_line = next_line
    let next_line    = nextnonblank(current_line + 1)
  endwhile

  return current_line
endfunction
