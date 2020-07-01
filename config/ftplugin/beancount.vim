let b:beancount_root = expand('~/private/账本/main.beancount')
" Don't use the one comes with vim-beancount; we use includes.
let b:ale_linters = ['beancheck']

function s:TryAlign()
  if getline('.') =~ '^  '
    AlignCommodity
  endif
endfunction
autocmd InsertLeave <buffer> call <SID>TryAlign()
