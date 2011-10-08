if exists('g:loaded_cycle')
  finish
endif
let g:loaded_cycle = 1
let s:save_cpo = &cpoptions
set cpoptions&vim


" Default Options: {{{

function! s:set_default(name, value)
  if !exists(a:name)
    execute "let " . a:name . " = " . string(a:value)
  endif
endfunction

call s:set_default('g:cycle_no_mappings', 0)
call s:set_default('g:cycle_max_conflict', 1)
call s:set_default('g:cycle_auto_visual', 0)
call s:set_default('g:cycle_phased_search', 0)

if !exists('g:cycle_default_groups')
  call cycle#add_groups([
        \   [['true', 'false']],
        \   [['yes', 'no']],
        \   [['on', 'off']],
        \   [['0', '1']],
        \   [['+', '-']],
        \   [['>', '<']],
        \ ])
endif

if exists('g:cycle_default_groups')
  call cycle#add_groups(g:cycle_default_groups)
endif

" }}} Default Options


" Interface: {{{

nnoremap <silent> <Plug>CycleNext :<C-U>call Cycle('w',  1, v:count1)<CR>
nnoremap <silent> <Plug>CyclePrev :<C-U>call Cycle('w', -1, v:count1)<CR>
vnoremap <silent> <Plug>CycleNext :<C-U>call Cycle('v',  1, v:count1)<CR>
vnoremap <silent> <Plug>CyclePrev :<C-U>call Cycle('v', -1, v:count1)<CR>

if !g:cycle_no_mappings
  silent! nmap <silent> <unique> <Leader>a <Plug>CycleNext
  silent! vmap <silent> <unique> <Leader>a <Plug>CycleNext
endif

function! Cycle(class_name, direction, count)
  call cycle#new(a:class_name, a:direction, a:count)
endfunction

augroup cycle
  autocmd!
  autocmd FileType * call cycle#reset_b_groups_by_filetype()
augroup END

" }}} Interface


" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
