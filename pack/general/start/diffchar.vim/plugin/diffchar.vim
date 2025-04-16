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
" Last Change: 2024/02/14
" Version:     9.7 (on or after patch-8.1.1418 and nvim-0.5.0)
" Author:      Rick Howe (Takumi Ohtani) <rdcxy754@ybb.ne.jp>
" Copyright:   (c) 2014-2024 Rick Howe
" License:     MIT

" This 9.x version requires:
" * the OptionSet autocommand event triggered with the diff option
  " patch-8.0.0736 (nvim-0.3.0), patch-8.1.0414 (nvim-0.3.2)
" * window ID argument in matchaddpos()/matchdelete()/getmatches()
  " patch-8.1.0218 (nvim-0.3.5), patch-8.1.1084 (nvim-0.4.4)
" * the DiffUpdated autocommand event
  " patch-8.1.0397 (nvim-0.3.2)
" * the win_execute() function
  " patch-8.1.1418 (nvim-0.5.0)
if exists('g:loaded_diffchar') || !has('diff') || v:version < 800 ||
                                                      \!exists('*win_execute')
  finish
endif
let g:loaded_diffchar = 9.7

let s:save_cpo = &cpoptions
set cpo&vim

" Options
if !exists('g:DiffUnit')  " a type of diff unit
  " let g:DiffUnit = 'Char'   " any single character
  " let g:DiffUnit = 'Word1'  " \w\+ word and any \W single character
  " let g:DiffUnit = 'Word2'  " non-space and space words
  " let g:DiffUnit = 'Word3'  " \< or \> character class boundaries
  " let g:DiffUnit = 'word'   " see word
  " let g:DiffUnit = 'WORD'   " see WORD
  " let g:DiffUnit = '[{del}]'  " a list of unit delimiters (e.g. "[,:\t<>]")
  " let g:DiffUnit = '/{pat}/'  " a pattern to split (e.g. '/.\{4}\zs/')
endif

if !exists('g:DiffColors')  " matching colors for changed units
  " let g:DiffColors = 0  " hl-DiffText only
  " let g:DiffColors = 1  " hl-DiffText + a few (3, 4, ...)
  " let g:DiffColors = 2  " hl-DiffText + several (7, 8, ...)
  " let g:DiffColors = 3  " hl-DiffText + many (11, 12, ...)
  " let g:DiffColors = 100  " all available highlight groups in random order
  " let g:DiffColors = [{hlg}] " a list of your favorite highlight groups
endif

if !exists('g:DiffPairVisible') " a visibility of corresponding diff units
  " let g:DiffPairVisible = 0 " disable
  " let g:DiffPairVisible = 1 " highlight
  " let g:DiffPairVisible = 2 " highlight + echo
  " let g:DiffPairVisible = 3 " highlight + popup/floating at cursor pos
  " let g:DiffPairVisible = 4 " highlight + popup/floating at mouse pos
endif

" Keymaps
for [key, plg, cmd] in [
  \['[b', '<Plug>JumpDiffCharPrevStart',
                                  \':<C-U>call diffchar#JumpDiffChar(0, 0)'],
  \[']b', '<Plug>JumpDiffCharNextStart',
                                  \':<C-U>call diffchar#JumpDiffChar(1, 0)'],
  \['[e', '<Plug>JumpDiffCharPrevEnd',
                                  \':<C-U>call diffchar#JumpDiffChar(0, 1)'],
  \[']e', '<Plug>JumpDiffCharNextEnd',
                                  \':<C-U>call diffchar#JumpDiffChar(1, 1)'],
  \['<Leader>g', '<Plug>GetDiffCharPair',
                                  \':<C-U>call diffchar#CopyDiffCharPair(0)'],
  \['<Leader>p', '<Plug>PutDiffCharPair',
                                  \':<C-U>call diffchar#CopyDiffCharPair(1)']]
  if !hasmapto(plg, 'n') && empty(maparg(key, 'n'))
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

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=2 sw=0 sts=-1 et
