let b:beancount_root = expand('~/private/账本/main.beancount')

function s:TryAlign()
  if getline('.') =~ '^  '
    AlignCommodity
  endif
endfunction
autocmd InsertLeave <buffer> call <SID>TryAlign()
