import 'stargate/workstation.vim' as ws

let s:assert = themis#helper('assert')

let workstation = themis#suite('import/workstation.vim')


func workstation.before_each()
  new
endfunc

func workstation.after_each()
  close!
endfunc

func workstation.DisplayLeftEdge()
  let ws.winview = winsaveview()

  call s:assert.equals(s:ws.DisplayLeftEdge(), 1,
        \ 'without sign and linenr columns')

  set signcolumn=yes
  call s:assert.equals(s:ws.DisplayLeftEdge(), 3,
        \ 'with sign column')

  set nu rnu
  call s:assert.equals(s:ws.DisplayLeftEdge(), 7,
        \ 'with sign and linnr columns')

  set signcolumn=no
  call s:assert.equals(s:ws.DisplayLeftEdge(), 5,
        \ 'with linnr column')
endfunc


func workstation.UpdateWinBounds()
  call setline(1, repeat(['line'], 20))
  normal 10ggzt
  call s:ws.UpdateWinBounds()
  call s:assert.equals(s:ws.win.topline, line('w0'),
        \ 'first visible line number ')
  call setline(1, repeat(['line'], 20))
  normal 10ggzt
  call s:assert.equals(s:ws.win.botline, line('w$'),
        \ 'last visible line number ')
endfunc


func workstation.OrbitalArc()
  let win_width = winwidth(0)

  call s:assert.equals(s:ws.OrbitalArc().first, 1,
        \ 'first virtual column for empty buffer')
  call s:assert.equals(s:ws.OrbitalArc().last, winwidth(0),
        \ 'last visible virtual column for empty buffer')

  call setline(1, repeat('word ', 200))
  exe 'normal ' .. win_width .. 'l'
  let ws.winview = winsaveview()
  call s:assert.equals(s:ws.OrbitalArc().first, win_width + 1,
        \ 'first virtual column for shifted text')
  call s:assert.equals(s:ws.OrbitalArc().last, 2 * win_width,
        \ 'last virtual column for shifted text')

  set list
  set listchars+=precedes:0
  call s:assert.equals(s:ws.OrbitalArc().first, win_width + 2,
        \ 'first virtual column for shifted text with `precedes`')
  call s:assert.equals(s:ws.OrbitalArc().last, 2 * win_width,
        \ 'last virtual column for shifted text with `precedes`')
endfunc
