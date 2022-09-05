noremap <M-q>f <Cmd>call stargate#OKvim(1)<CR>
noremap <M-q>F <Cmd>call stargate#OKvim(1)<CR>
noremap <M-q>j <Cmd>call stargate#OKvim("\\_^")<CR>
noremap <M-q>k <Cmd>call stargate#OKvim("\\_^")<CR>

" work around https://github.com/vim/vim/issues/11061#issuecomment-1236850153
onoremap ñf <Cmd>call stargate#OKvim(1)<CR>
onoremap ñF <Cmd>call stargate#OKvim(1)<CR>
onoremap ñj <Cmd>call stargate#OKvim("\\_^")<CR>
onoremap ñk <Cmd>call stargate#OKvim("\\_^")<CR>

let g:stargate_ignorecase = v:false
