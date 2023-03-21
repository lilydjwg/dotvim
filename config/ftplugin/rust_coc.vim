if !get(g:, 'coc_enabled') || !get(b:, 'coc_enabled', 1)
  finish
endif

" disable omnifunc because coc's is better
let b:disable_omnifunc = 1

NeoCompleteLock

inoremap <buffer> <expr> <M-j> coc#pum#visible() ? coc#pum#next(1) : "\<M-j>"
inoremap <buffer> <expr> <C-j> coc#pum#visible() ? coc#pum#prev(1) : "\<C-j>"
