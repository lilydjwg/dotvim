" Vim script file
" FileType:     python
" Author:       lilydjwg

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

" modeline {{{1
" vim:set fdm=marker:
