" escalt.vim    控制台下用 <Esc>，GUI 下用 Alt
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年3月7日
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_escalt")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_escalt = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function Escalt_console()
  nmap <unique> <silent> <Esc>L :LUWalk<CR>
  nmap <silent> <Esc>f :echo expand('%:p')<CR>
  nmap <unique> <silent> <Esc>s <Plug>ShowScratchBuffer
  nmap <Esc>b <Leader>lb
  nmap <Esc>l :LustyFilesystemExplorerFromHere<CR>
  nmap <Esc>m :MRU 
  nmap <Esc>j gj
  nmap <Esc>k gk
  inoremap <silent> <Esc>y <C-R><C-R>=LookFurther(1)<CR>
  inoremap <Esc>j <C-N>
  inoremap <Esc>c <C-R>=Lilydjwg_colorpicker()<CR>
  vmap <Esc>j gj
  vmap <Esc>k gk
endfunction
function Escalt_unconsole()
  try
    nunmap <Esc>L
    nunmap <Esc>f
    nunmap <Esc>s
    nunmap <Esc>b
    nunmap <Esc>l
    nunmap <Esc>m
    nunmap <Esc>j
    nunmap <Esc>k
    iunmap <Esc>j
    iunmap <Esc>y
    iunmap <Esc>c
    vunmap <Esc>j
    vunmap <Esc>k
  catch /E31/ " 没有这个映射
  endtry
endfunction
function Escalt_gui()
  nmap <unique> <silent> <M-L> <Plug>LookupFile
  nmap <silent> <M-f> :echo expand('%:p')<CR>
  " 打开草稿
  nmap <unique> <silent> <M-s> <Plug>ShowScratchBuffer
  " lusty-explorer [[[4
  "   <M-b>不能用 :BufferExplorer，因为它已经被 bufexplorer 用了
  nmap <M-b> <Leader>lb
  nmap <M-l> :LustyFilesystemExplorerFromHere<CR>
  nmap <M-m> :MRU 
  nmap <M-j> gj
  nmap <M-k> gk
  inoremap <M-j> <C-N>
  inoremap <silent> <M-y> <C-R><C-R>=LookFurther(1)<CR>
  inoremap <M-c> <C-R>=Lilydjwg_colorpicker()<CR>
  vmap <M-j> gj
  vmap <M-k> gk
endfunction
" ---------------------------------------------------------------------
" Autocmds:
autocmd GUIEnter * call Escalt_unconsole() | call Escalt_gui()
" ---------------------------------------------------------------------
" Call Functions:
if !has("gui_running")
  call Escalt_console()
endif
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
