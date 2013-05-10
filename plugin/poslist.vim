" poslist.vim	mannually maintained position list
" Author:       lilydjwg <lilydjwg@gmail.com>
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_poslist")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_poslist = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
let g:poslist = []
let g:poslist_pos = 0
function s:record()
  let pos = getpos('.')
  let line = getline('.')
  let pos[0] = bufnr('%')
  if len(g:poslist) > g:poslist_pos
    call remove(g:poslist, g:poslist_pos, -1)
  endif
  let g:poslist_pos += 1
  call add(g:poslist, [pos, line])
endfunction
function s:back_pos()
  if g:poslist_pos <= 0
    echohl ErrorMsg
    echo "poslist: bottom already"
    echohl None
    return []
  endif
  let g:poslist_pos -= 1
  return g:poslist[g:poslist_pos][0]
endfunction
function s:backward()
  let pos = s:back_pos()
  if pos == []
    return
  end

  " same pos: the user has set a pos and wants to go back then back here
  let curpos = getpos('.')
  let curpos[0] = bufnr('%')
  if curpos == pos
    let pos = s:back_pos()
    if pos == []
      return
    end
  endif

  exec "buffer" pos[0]
  call setpos('.', pos)
endfunction
function s:forward()
  if g:poslist_pos + 1 >= len(g:poslist)
    echohl ErrorMsg
    echo "poslist: top already"
    echohl None
    return
  endif
  let g:poslist_pos += 1
  let pos = g:poslist[g:poslist_pos][0]
  exec "buffer" pos[0]
  call setpos('.', pos)
endfunction
function s:pslist()
  if len(g:poslist) == 0
    echohl WarningMsg | echo "Nothing in pos list yet." | echohl None
    return
  endif

  echohl PreProc | echo "Current Pos List:"
  echohl Title | echo "#\t line\tbuf\n" | echohl None
  let i = 1
  for posinfo in g:poslist
    let pos = posinfo[0]
    if i == g:poslist_pos + 1
      echohl CursorLine
    endif
    echon i . ".\t"
    echon printf('%4d', pos[1]) . "\t"
    echon fnamemodify(bufname(pos[0]), ':~:.') . "\n"
    if i == g:poslist_pos + 1
      echohl None
    endif
    echohl Comment
    echo printf("                %.*s\n", &columns, posinfo[1])
    echohl None
    let i = i + 1
  endfor
  let res = input('Type number and <Enter> (empty cancels): ') + 0
  if res < 1 || res > len(g:poslist)
    return
  endif

  let g:poslist_pos = res - 1
  let pos = g:poslist[g:poslist_pos][0]
  exec "buffer" pos[0]
  call setpos('.', pos)
endfunction
function s:clear()
  let g:poslist = []
  let g:poslist_pos = 0
endfunction
" ---------------------------------------------------------------------
" Commands And Mappings:
command PLRecord call <SID>record()
command PLBackward call <SID>backward()
command PLForward call <SID>forward()
command PLList call <SID>pslist()
command PLClear call <SID>clear()
nnoremap <Plug>PLRecord :PLRecord<CR>
nnoremap <Plug>PLBackward :PLBackward<CR>
nnoremap <Plug>PLForward :PLForward<CR>
if !hasmapto('<Plug>PLRecord', 'n')
  nmap <M-,> <Plug>PLRecord
endif
if !hasmapto('<Plug>PLBackward', 'n')
  nmap <M-.> <Plug>PLBackward
endif
if !hasmapto('<Plug>PLForward', 'n')
  nmap <M-/> <Plug>PLForward
endif
" ---------------------------------------------------------------------
" Restoration And Modelines:
let &cpo = s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
