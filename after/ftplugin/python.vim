" Vim script file
" FileType:     Python
" Author:       lilydjwg <lilydjwg@gmail.com>

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
endfunction
function! Python_err(chan, out)
  echoerr a:out
endfunction

if !exists('b:python_did_once')
  let pyfile = fnameescape(globpath(&runtimepath, 'after/ftplugin/python.py'))
  if has("python3")
    exe 'py3file ' . pyfile
  endif
  if exists('*job_start')
    let pyfile = fnameescape(globpath(&runtimepath, 'after/ftplugin/python_getsw.py'))
    call job_start([pyfile, expand('%')], {"out_cb": "Python_setsw", "err_cb": "Python_err"})
  endif
  let b:python_did_once = 1
endif
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
