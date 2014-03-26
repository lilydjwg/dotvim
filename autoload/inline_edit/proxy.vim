function! inline_edit#proxy#New(controller, start_line, end_line, filetype, indent)
  let proxy = {
        \ 'controller':      a:controller,
        \ 'original_buffer': expand('%:p'),
        \ 'proxy_buffer':    -1,
        \ 'filetype':        a:filetype,
        \ 'start':           a:start_line,
        \ 'end':             a:end_line,
        \ 'indent':          (&et ? a:indent : a:indent / &ts),
        \
        \ 'UpdateOriginalBuffer': function('inline_edit#proxy#UpdateOriginalBuffer')
        \ }

  let [lines, position] = s:LoadOriginalBufferContents(proxy)
  call s:CreateProxyBuffer(proxy, lines)
  call s:UpdateProxyBuffer(proxy)
  call s:SetStatusline(proxy)
  call s:PositionCursor(proxy, position)

  " On writing proxy buffer, update original one
  if g:inline_edit_proxy_type == 'scratch'
    autocmd BufWriteCmd <buffer> silent call b:proxy.UpdateOriginalBuffer()
  elseif g:inline_edit_proxy_type == 'tempfile'
    autocmd BufWritePost <buffer> silent call b:proxy.UpdateOriginalBuffer()
  endif

  return proxy
endfunction

" This function updates the original buffer with the contents of the proxy
" one. Care is taken to synchronize all of the other proxy buffers that may be
" open.
function! inline_edit#proxy#UpdateOriginalBuffer() dict
  " Prepare lines for moving around
  if getbufvar(self.original_buffer, '&expandtab')
    let leading_whitespace = repeat(' ', self.indent)
  else
    let leading_whitespace = repeat("\t", self.indent)
  endif

  let new_lines = []
  for line in getbufline('%', 0, '$')
    if line =~ '^$'
      " blank line, no need for whitespace
    else
      let line = leading_whitespace.line
    endif
    call add(new_lines, line)
  endfor

  call inline_edit#PushCursor() " in proxy buffer

  " Switch to the original buffer, delete the relevant lines, add the new
  " ones, switch back to the diff buffer.
  let saved_bufhidden = &bufhidden
  let &bufhidden = 'hide'

  setlocal nomodified
  let original_bufnr = bufnr(self.original_buffer)
  if original_bufnr < 0 " no buffer found
    call inline_edit#PopCursor()
    return
  endif
  exe 'buffer ' . original_bufnr

  call inline_edit#PushCursor()
  call cursor(self.start, 1)
  if self.end - self.start >= 0
    exe self.start . ',' . self.end . 'delete _'
  endif
  call append(self.start - 1, new_lines)
  if g:inline_edit_autowrite
    write
  endif
  call inline_edit#PopCursor()
  exe 'buffer ' . self.proxy_buffer

  let &bufhidden = saved_bufhidden

  " Keep the difference in lines to know how to update the other proxies if
  " necessary.
  let line_count     = self.end - self.start + 1
  let new_line_count = len(new_lines)

  let self.end = self.start + new_line_count - 1
  call s:UpdateProxyBuffer(self)

  call inline_edit#PopCursor() " in proxy buffer

  call self.controller.SyncProxies(self, new_line_count - line_count)
endfunction

" Called once upon setup. Returns the lines from the original buffer and the
" position of the cursor in that buffer.
function! s:LoadOriginalBufferContents(proxy)
  let proxy    = a:proxy
  let position = getpos('.')
  let lines    = []

  for line in getbufline(proxy.original_buffer, proxy.start, proxy.end)
    call add(lines, substitute(line, '^\s\{'.proxy.indent.'}', '', ''))
  endfor

  return [lines, position]
endfunction

" Called once upon setup. Creates the actual buffer and writes the given lines
" to it.
function! s:CreateProxyBuffer(proxy, lines)
  let proxy = a:proxy
  let lines = a:lines

  " avoid warnings
  let saved_readonly = &readonly
  let &readonly = 0

  if g:inline_edit_proxy_type == 'scratch'
    exe 'silent new'
    setlocal buftype=acwrite
    setlocal bufhidden=wipe
    call append(0, lines)
    $delete _
    set nomodified

    let short_filename = fnamemodify(a:proxy.original_buffer, ':~:.')
    let filename = printf('[%s:%d-%d]', short_filename, proxy.start, proxy.end)
    silent exec 'keepalt file ' . escape(filename, '[')
  elseif g:inline_edit_proxy_type == 'tempfile'
    exe 'silent split ' . tempname()
    call append(0, lines)
    $delete _
    write
  endif

  let &readonly = saved_readonly

  set foldlevel=99
  let proxy.proxy_buffer = bufnr('%')
endfunction

" Called once upon setup and then after every write. After the actual updating
" logic is finished, this sets up some needed buffer properties.
function! s:UpdateProxyBuffer(proxy)
  let b:proxy = a:proxy

  if a:proxy.filetype == ''
    " attempt autodetection
    filetype detect
    let a:proxy.filetype = &filetype
  endif

  let &filetype = a:proxy.filetype
endfunction

" Called once upon setup. Manipulates the statusline to show information for
" the proxy. Does nothing if the proxy type is not "tempfile"
function! s:SetStatusline(proxy)
  if g:inline_edit_proxy_type != 'tempfile'
    return
  endif

  let short_filename = fnamemodify(a:proxy.original_buffer, ':~:.')
  let statusline = printf('[%s:%%{b:proxy.start}-%%{b:proxy.end}]', short_filename)
  if &statusline =~ '%[fF]'
    let statusline = substitute(&statusline, '%[fF]', statusline, '')
  endif
  exe "setlocal statusline=" . escape(statusline, ' |')
endfunction

" Called once upon setup. Positions the cursor where it was in the original
" buffer, relative to the extracted contents.
function! s:PositionCursor(proxy, position)
  let proxy       = a:proxy
  let position    = a:position
  let position[0] = bufnr(proxy.proxy_buffer)
  let position[1] = position[1] - proxy.start + 1

  call setpos('.', position)
endfunction
