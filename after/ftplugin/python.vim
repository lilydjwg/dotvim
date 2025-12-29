" Vim script file
" FileType:     Python
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
"  Don't use python3complete#Complete, which imports modules and can have side
"  effects, e.g. importing GTK 4.
setlocal omnifunc=syntaxcomplete#Complete

" it must be 8
setlocal tabstop=8
" ---------------------------------------------------------------------
" load python code, set 'sw' etc {{{1
" Vim 7.4 from some patch level unconditionally set 'sw' and 'sts' to 4
function! Python_setsw(chan, out)
  if a:out == 'DETACH'
    " 7.4.1689 does this
    return
  endif
  let &l:sw = a:out
  let &l:sts = a:out
  " refresh folds
  normal! zX
endfunction
function! Python_err(chan, out)
  echoerr a:out
endfunction

let pyfile = fnameescape(globpath(&runtimepath, 'after/ftplugin/python.py'))
if has("python3")
  exe 'py3file ' . pyfile
endif
if exists('*job_start')
  let pyfile = fnameescape(globpath(&runtimepath, 'after/ftplugin/python_getsw.py'))
  call job_start([pyfile, expand('%')], {"out_cb": "Python_setsw", "err_cb": "Python_err"})
endif
" ---------------------------------------------------------------------
