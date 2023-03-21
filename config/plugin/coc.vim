inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" disable coc by default
" autocmd BufAdd *.rs let b:coc_enabled = 0

autocmd FileType * if &ft != 'rust' | let b:coc_suggest_disable = 1 | endif
" only BufEnter can access current buffer; BufNew etc would update the wrong buffer
autocmd BufEnter * if &ft != 'rust' && !exists('b:coc_suggest_disable ') | let b:coc_suggest_disable = 1 | endif
