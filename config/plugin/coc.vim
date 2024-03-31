inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" disable coc by default
" autocmd BufAdd *.rs let b:coc_enabled = 0

autocmd FileType * if &ft != 'rust' | let b:coc_suggest_disable = 1 | endif
" only BufEnter can access current buffer; BufNew etc would update the wrong buffer
autocmd BufEnter * if &ft != 'rust' && !exists('b:coc_suggest_disable') | let b:coc_suggest_disable = 1 | endif

hi CocHighlightText term=reverse cterm=underline ctermfg=46 ctermbg=16 gui=underline guifg=#33ff1c guibg=#000000
hi CocHighlightRead term=reverse cterm=underline ctermfg=46 ctermbg=16 gui=underline guifg=#cbff1c guibg=#000000
hi CocHighlightWrite term=reverse cterm=underline ctermfg=46 ctermbg=16 gui=underline guifg=#1e90ff guibg=#000000
