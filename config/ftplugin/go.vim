if exists("g:packadded_vim_go")
  finish
endif

" I handled it myself
let g:go_fmt_autosave = 0

packadd vim-go
let g:packadded_vim_go = 1
