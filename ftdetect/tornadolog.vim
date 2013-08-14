" Vim syntax file
" FileType:     tornadolog
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------

function! s:DetectTornadoLog()
  if getline(1) =~ '^\[[DIWE] '
    set filetype=tornadolog
  endif
endfunction

autocmd BufRead,StdinReadPost * call s:DetectTornadoLog()
