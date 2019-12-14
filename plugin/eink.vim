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

function! s:AutoEink()
  if exists('*getwinpos')
    let x = getwinpos(1000)[0]
  else
    let x = getwinposx()
  endif

  if x == -1 || x == 0
    " not available or wrong, try using the mouse position
    " vte 0.58.3 always replies (0, 0), see
    " https://gitlab.gnome.org/GNOME/vte/issues/128
    let x = system("python -c 'from X import Display; print(Display().getpos()[0])' 2>/dev/null || true")
  endif

  if x >= 1920
    call s:Eink('')
  endif
endfunction
autocmd VimEnter * call s:AutoEink()
