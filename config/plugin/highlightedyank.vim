if exists("*win_getid")
  let g:highlightedyank_highlight_duration = 300
  if !has("nvim")
    map y <Plug>(highlightedyank)
  endif
endif
