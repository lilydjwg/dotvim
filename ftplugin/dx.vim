" Vim script file
" FileType:     DX （短信）
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009年7月23日
"
if exists("b:loaded_mine_dx")
  finish
endif
let b:loaded_mine_dx = 1

inoremap <buffer> <CR> <C-R>=Lilydjwg_dx_header()<CR>
inoremap <buffer> <S-CR> <ESC>o                       

function! Lilydjwg_dx_header()
  let l = getline('.')
  let l = substitute(l, '\v^(Re.\s+|.+\d{2}-\d{2} )\S.*', '\1', '')
  call append(line('.')-1, l)
  call setpos('.', [0, line('.')-1, strlen(l)+1, 0])
  return ''
endfunction
