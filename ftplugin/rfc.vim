" Vim script file
" FileType:     RFC
" Author:       lilydjwg <lilydjwg@gmail.com>
" Version:	1.0

function! s:get_pattern_at_cursor(pat)
  " This is a function copied from another script.
  " Sorry that I don't remember which one.
  let col = col('.') - 1
  let line = getline('.')
  let ebeg = -1
  let cont = match(line, a:pat, 0)
  while (ebeg >= 0 || (0 <= cont) && (cont <= col))
    let contn = matchend(line, a:pat, cont)
    if (cont <= col) && (col < contn)
      let ebeg = match(line, a:pat, cont)
      let elen = contn - ebeg
      break
    else
      let cont = match(line, a:pat, contn)
    endif
  endwh
  if ebeg >= 0
    return strpart(line, ebeg, elen)
  else
    return ""
  endif
endfunction
function! s:rfcTag()
  " Jump from Contents or [xx] to body or References
  let syn = synIDattr(synID(line("."), col("."), 1), "name")
  if syn == 'rfcContents' || syn == 'rfcDots'
    let l = getline('.')
    let lm = matchstr(l, '\v%(^\s+)@<=%(Appendix\s+)=[A-Z0-9.]+\s')
    if lm == ""
      " Other special contents
      let lm = matchstr(l, '\vFull Copyright Statement')
    end
    let l = '^\c\V' . lm
    let b:backpos = line('.')
    call search(l, 'Ws')
  elseif syn == 'rfcReference'
    let l = s:get_pattern_at_cursor('\[\w\+\]')
    if l == ''
      " Not found.
      echohl Error
      echomsg 'Cursor is not on References!'
      echohl None
      return
    endif
    if b:refpos[0] == 0 " Not found.
      echohl Error
      echomsg 'References not found!'
      echohl None
      return
    endif
    normal m'
    let b:backpos = line('.')
    call cursor(b:refpos[0], 0)
    try
      exec '/^\s\+\V'. l.'\s\+\a\+/'
    catch /^Vim\%((\a\+)\)\=:E385/
      " Not found.
      exe "normal \<C-O>"
      echohl WarningMsg
      echomsg 'The reference not found!'
      echohl None
    endtry
  else
    echohl Error
    echomsg 'Cursor is not on Contents or References!'
    echohl None
  endif
endfunction

function! s:rfcJumpBack()
  if exists('b:backpos')
    exec b:backpos
    unlet b:backpos
  else
    echohl ErrorMsg
    echo "Can't jump back any more."
    echohl None
  endif
endfunction

" References jump will need it
let b:refpos = searchpos('^\v\d+\.?\s+References\s*$', 'wn')

nnoremap <buffer> <silent> <C-]> :call <SID>rfcTag()<CR>
nnoremap <buffer> <silent> <C-t> :call <SID>rfcJumpBack()<CR>
