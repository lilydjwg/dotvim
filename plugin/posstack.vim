" posstack.vim	mannually maintained jump position stack
" Author:       lilydjwg <lilydjwg@gmail.com>
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_posstack")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_posstack = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
let g:stack = []
let g:stack_top = -1
function s:push()
  let pos = getpos('.')
  let line = getline('.')
  let pos[0] = bufnr('%')
  let g:stack_top += 1
  if len(g:stack) > g:stack_top
    call remove(g:stack, g:stack_top, -1)
  endif
  call add(g:stack, [pos, line])
endfunction
function s:pop()
  if g:stack_top < 0
    echohl ErrorMsg
    echo "posstack: jump stack empty"
    echohl None
    return
  endif
  let pos = g:stack[g:stack_top][0]
  exec "buffer" pos[0]
  call setpos('.', pos)
  let g:stack_top -= 1
endfunction
function s:pslist()
  if len(g:stack) == 0
    echohl WarningMsg | echo "Nothing in pos stack yet." | echohl None
    return
  endif

  echohl PreProc | echo "Current pos stack:"
  echohl Title | echo "#\t line\tbuf\n" | echohl None
  let i = 1
  for posinfo in g:stack
    let pos = posinfo[0]
    if i == g:stack_top + 1
      echohl CursorLine
    endif
    echon i . ".\t"
    echon printf('%4d', pos[1]) . "\t"
    echon fnamemodify(bufname(pos[0]), ':~:.') . "\n"
    if i == g:stack_top + 1
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

  let g:stack_top = res - 1
  let pos = g:stack[g:stack_top][0]
  exec "buffer" pos[0]
  call setpos('.', pos)
endfunction
" ---------------------------------------------------------------------
" Commands And Mappings:
command Push call <SID>push()
command Pop call <SID>pop()
command PSList call <SID>pslist()
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
