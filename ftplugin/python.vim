" Vim script file
" FileType:     python
" Author:       lilydjwg
" eval code {{{1
if !exists('b:python_did_once')
  let pyfile = fnameescape(globpath(&runtimepath, 'ftplugin/python.py'))
  if has("python3")
    exe 'py3file ' . pyfile
    vmap <buffer> <silent> <Space> :py3 EvaluateCurrentRange()<CR>
  endif
  let b:python_did_once = 1
endif

" settings & mappings {{{1
setlocal et
setlocal tw=78
" 包含文件太多太费时了
setlocal complete-=i
imap <silent> <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^\s*#\s*$')<CR>

" makeprg {{{1
setlocal makeprg=python3\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m,
      \%m(%f\\,\ line\ %l)

" FIXME 如果是 grep 命令呢？
au QuickFixCmdPre <buffer> lcd %:p:h
au QuickFixCmdPost <buffer> lcd -

" modeline {{{1
" vim:set fdm=marker:
