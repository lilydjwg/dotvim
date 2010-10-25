" Vim script file
" FileType:     python
" Author:       lilydjwg
" Last Change:  2010-10-22
" eval code {{{1
if !exists('b:python_did_once')
  python << EOF
import vim

def EvaluateCurrentRange():
  '''执行范围内的代码'''
  eval(compile('\n'.join(vim.current.range),'','exec'),globals())
EOF
vmap <buffer> <silent> <Space> :py EvaluateCurrentRange()<CR>
let b:python_did_once = 1
endif

" indent & folding {{{1
" Find out the indent amount
" 从末行找起
let i = line('$')
let ok = 0
while i != 0
  if indent(i) != 0 || getline(i) =~ '^\s*$'
    let i -= 1
  else
    break
  endif
endwhile
while i != line('$')+1
  if indent(i) > 0 && synIDattr(synID(i, 1, 1), "name") !~ 'String'
    " indent() 也可能得到 -1 的，此时 sw 被置为默认的 8
    let &l:sts = indent(i)
    let &l:sw = indent(i)
    let ok = 1
    break
  endif
  let i += 1
endwhile
if !ok
  echo 'indent not recognized.'
  setlocal sw=2
  setlocal sts=2
endif
if &l:sw > 10 " 不可能，应该是多行语句的干扰
  setlocal sw=4
  setlocal sts=4
endif
unlet i ok

function! Lilydjwg_python_fold()
  " 就这样吧

  " 下面这些用于折叠无缩进的代码/注释块
  " if getline(v:lnum) =~ '^\S' && getline(v:lnum+1) =~ '^\S\|^\s*$'
	" \ && (v:lnum == 1 || getline(v:lnum-1) !~ '^\S')
    " return '>1'
  " endif
  " if getline(v:lnum) =~ '^\s*$' && getline(v:lnum-1) =~ '^\S'
	" \ && getline(v:lnum-2) =~ '^\S'
    " return '<1'
  " endif

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

" 高亮缩进 {{{1
for i in range(1, &tw?&tw:40, &sw*2)
  exe 'syntax match pythonIndentA	/\(^\s*\)\@<=\%'.i.'v\s\{'.&sw.'}/'
endfor
for i in range(1+&sw, &tw?&tw:40, &sw*2)
  exe 'syntax match pythonIndentB	/\(^\s*\)\@<=\%'.i.'v\s\{'.&sw.'}/'
endfor

if &background == 'dark'
  hi pythonIndentA	guibg=#553344
  hi pythonIndentB	guibg=#335544
else
  hi pythonIndentA	guibg=#ffcccc
  hi pythonIndentB	guibg=#ccffcc
endif

" modeline {{{1
" vim:set fdm=marker:
