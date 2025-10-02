" diffchar.vim: Highlight the exact differences, based on characters and words
"
"  ____   _  ____  ____  _____  _   _  _____  ____   
" |    | | ||    ||    ||     || | | ||  _  ||  _ |  
" |  _  || ||  __||  __||     || | | || | | || | ||  
" | | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
" | |_| || ||  __||  __||  |   |     ||     ||  __  |
" |     || || |   | |   |  |__ |  _  ||  _  || |  | |
" |____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
"
" Last Change: 2025/10/01
" Version:     10.0 (on or after vim 9.0 and nvim 0.7.0)
" Author:      Rick Howe (Takumi Ohtani) <rdcxy754@ybb.ne.jp>
" Copyright:   (c) 2014-2025 Rick Howe
" License:     MIT

if exists('g:loaded_diffchar') || !has('diff') ||
                                      \(v:version < 900 && !has('nvim-0.7.0'))
let g:loaded_diffchar = 0
  finish
endif
let g:loaded_diffchar = 10.0

let s:save_cpo = &cpoptions
set cpo&vim

" Keymaps
for [key, plg, cmd] in [
  \['[b', '<Plug>JumpDiffCharPrevStart',
                                      \':<C-U>call diffchar#JumpDiffChar(0)'],
  \[']b', '<Plug>JumpDiffCharNextStart',
                                      \':<C-U>call diffchar#JumpDiffChar(1)'],
  \['[e', '<Plug>JumpDiffCharPrevEnd',
                                      \':<C-U>call diffchar#JumpDiffChar(2)'],
  \[']e', '<Plug>JumpDiffCharNextEnd',
                                      \':<C-U>call diffchar#JumpDiffChar(3)'],
  \['<Leader>g', '<Plug>GetDiffCharPair',
                                  \':<C-U>call diffchar#CopyDiffCharPair(0)'],
  \['<Leader>p', '<Plug>PutDiffCharPair',
                                  \':<C-U>call diffchar#CopyDiffCharPair(1)']]
  if !hasmapto(plg, 'n') && maparg(key, 'n') =~ '^$\|_defaults.lua'
    if get(g:, 'DiffCharDoMapping', 1)
      call execute('nmap <silent> ' . key . ' ' . plg)
    endif
  endif
  call execute('nnoremap <silent> ' . plg . ' ' . cmd . '<CR>')
endfor

" Event groups
let g:DiffCharInitEvent = ['augroup diffchar', 'autocmd!',
                \'autocmd OptionSet diff call diffchar#ToggleDiffModeSync()',
                                                              \'augroup END']
call execute(g:DiffCharInitEvent)
call execute('autocmd diffchar VimEnter * ++once
                    \ if &diff | call diffchar#ToggleDiffModeSync(1) | endif')

" remove 'inline' from &diffopt if set only by default not to disable plugin
let inl = 'inline'
if &diffopt =~ inl
  let dip = split(&diffopt, ',')
  set diffopt&
  let def = split(&diffopt, ',')
  if match(filter(copy(dip), 'index(def, v:val) == -1'), inl) == -1
    call filter(dip, 'v:val !~ inl')
  endif
  let &diffopt = join(dip, ',')
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=0 sts=-1 et
