" pushpop.vim	mannually maintained jump position stack
" Author:       lilydjwg <lilydjwg@gmail.com>
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_pushpop")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_pushpop = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
let g:stack = []
let g:stack_top = 0
function s:push()
  let pos = getpos('.')
  let line = getline('.')
  let pos[0] = bufnr('%')
  if len(g:stack) > g:stack_top
    call remove(g:stack, g:stack_top, -1)
  endif
  call add(g:stack, [pos, line])
  let g:stack_top += 1
endfunction
function s:pop()
  if g:stack_top == 0
    echohl ErrorMsg
    echo "pushpop: jump stack empty"
    echohl None
    return
  endif
  let g:stack_top -= 1
  let pos = g:stack[g:stack_top][0]
  exec "buffer" pos[0]
  call setpos('.', pos)
endfunction
function s:pplist()
  if len(g:stack) == 0
    echohl WarningMsg | echo "Nothing in poppush stack yet." | echohl None
    return
  endif

  echohl PreProc | echo "Current poppush stack:"
  echohl Title | echo "#\t line\tbuf\n" | echohl None
  let i = 1
  for posinfo in g:stack
    let pos = posinfo[0]
    if i == g:stack_top
      echohl CursorLine
    endif
    echon i . ".\t"
    echon printf('%4d', pos[1]) . "\t"
    echon fnamemodify(bufname(pos[0]), ':~:.') . "\n"
    if i == g:stack_top
      echohl None
    endif
    echohl Comment
    echo printf("                %.*s\n", &columns, posinfo[1])
    echohl None
    let i = i + 1
  endfor
  let res = input('Type number and <Enter> (empty cancels): ') + 0
  if res < 1 || res > len(g:stack)
    return
  endif

  let g:stack_top = res
  let pos = g:stack[g:stack_top-1][0]
  exec "buffer" pos[0]
  call setpos('.', pos)
endfunction
" ---------------------------------------------------------------------
" Commands And Mappings:
command Push call <SID>push()
command Pop call <SID>pop()
command PPList call <SID>pplist()
nnoremap <Plug>Push :Push<CR>
nnoremap <Plug>Pop :Pop<CR>
if !hasmapto('<Plug>Push', 'n')
  nmap <M-,> <Plug>Push
endif
if !hasmapto('<Plug>Pop', 'n')
  nmap <M-.> <Plug>Pop
endif
" ---------------------------------------------------------------------
" Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
