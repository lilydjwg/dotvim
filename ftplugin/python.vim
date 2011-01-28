" Vim script file
" FileType:     python
" Author:       lilydjwg
" Last Change:  2011年1月24日
" eval code {{{1
if !exists('b:python_did_once')
  python3 << EOF
import vim
import sys

def EvaluateCurrentRange():
  '''执行范围内的代码'''
  eval(compile('\n'.join(vim.current.range),'','exec'),globals())

def getpath():
  path = sys.path[:]
  if '' in path:
    i = path.index('')
    paths[i] = '.'
  return path

vim.command('setlocal path=%s' % ','.join(getpath()).replace(' ', r'\ '))
EOF
vmap <buffer> <silent> <Space> :py3 EvaluateCurrentRange()<CR>
let b:python_did_once = 1
endif

" folding {{{1
function! Lilydjwg_python_fold()
  if getline(v:lnum) =~ '\v^\s*(def|class)\s'
    return '>'. (indent(v:lnum)/&sw+1)
  elseif getline(v:lnum) =~ '\v^(def|class|if)\s|^\S[^=]+\=.*[[{(](\#.*)?$'
    return '>1'
  else
    return '='
  endif
endfunction

" settings & mappings {{{1
setlocal et
setlocal tw=78
setlocal foldmethod=expr
setlocal foldexpr=Lilydjwg_python_fold()
setlocal omnifunc=pythoncomplete#Complete
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
