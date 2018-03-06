function! s:Eink(bang)
  if a:bang == '!'
    exe 'colorscheme' s:c_old
    let &guicursor = s:gc_old
    set cursorline
    if &t_RC != ''
      call writefile([&t_RC], "/dev/tty", "b")
    endif
  else
    if g:colors_name != 'eink'
      let s:c_old = g:colors_name
      let s:gc_old = &guicursor
    endif
    colorscheme eink
    set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor-blinkon0,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175
    " disable cursor blinking (e.g. in xterm)
    if &t_RC != ''
      call writefile(["\033[?12l"], "/dev/tty", "b")
    endif
    set t_RC=
    set nocursorline
  endif
endfunction
command! -bang Eink call s:Eink('<bang>')

function! s:AutoEink(t)
  if exists('*getwinpos')
    let x = getwinpos(1000)[0]
  else
    let x = getwinposx()
  endif

  if x >= 1920
    call s:Eink('')
  endif
endfunction
if exists('*timer_start')
  autocmd VimEnter * call timer_start(100, function('s:AutoEink'))
endif
