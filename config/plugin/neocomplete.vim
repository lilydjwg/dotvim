let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#enable_prefetch = 0
" disable text mode completely
call neocomplete#util#disable_default_dictionary('g:neocomplete#text_mode_filetypes')
let g:neocomplete#same_filetypes = {}
let g:neocomplete#same_filetypes._ = '_'

if !has('+reltime')
  let g:neocomplete#skip_auto_completion_time = ''
endif
