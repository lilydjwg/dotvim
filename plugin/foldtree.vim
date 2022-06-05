" A fold plugin for tree and pactree

function! s:load_folds()
  let lines = getline(1, '$')
  let b:folds = systemlist('vim-foldtree', lines)
endfunction

function! FoldTree(lnum)
  return b:folds[a:lnum-1]
endfunction

function! FoldText()
  let text = getline(v:foldstart)
  return text . ' [' . (v:foldend - v:foldstart) . ' nodes]'
endfunction

function! DoFoldTree()
  call s:load_folds()
  setlocal foldenable foldmethod=expr foldexpr=FoldTree(v:lnum) foldtext=FoldText()
endfunction

command FoldTree call DoFoldTree()
