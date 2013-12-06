" Vim script file
" FileType:     Python
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
"  自带的配置会在任何时候都设置为 pythoncomplete#Complete
if has("python3")
  setlocal omnifunc=python3complete#Complete
elseif has("python")
  setlocal omnifunc=pythoncomplete#Complete
else
  setlocal omnifunc=syntaxcomplete#Complete
endif
" ---------------------------------------------------------------------
" load python code, set 'sw' etc {{{1
" Vim 7.4 from some patch level unconditionally set 'sw' and 'sts' to 4
if !exists('b:python_did_once')
  let pyfile = fnameescape(globpath(&runtimepath, 'after/ftplugin/python.py'))
  if has("python3")
    exe 'py3file ' . pyfile
  endif
  let b:python_did_once = 1
endif
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
