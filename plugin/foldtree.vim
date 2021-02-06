" A fold plugin for tree and pactree

function! s:tree_depth(lnum)
  return getline(a:lnum)->matchstr('^[│├└  ]\+')->strchars()
endfunction
function! FoldTree(lnum)
  let cur = s:tree_depth(a:lnum)
  let next = s:tree_depth(a:lnum + 1)
  if cur == next
    return '='
  elseif cur < next
    return 'a1'
  else
    let indent = getline(a:lnum)->matchstr('[├└][─  ]\+')->strchars()
    return 's' . ((cur - next) / indent)
  endif
endfunction
function! FoldText()
  let text = getline(v:foldstart)
  return text . ' [' . (v:foldend - v:foldstart) . ' nodes]'
endfunction

command FoldTree setlocal foldenable foldmethod=expr foldexpr=FoldTree(v:lnum) foldtext=FoldText()
