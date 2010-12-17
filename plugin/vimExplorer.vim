"==================================================
" File:         VimExplorer.vim
" Brief:        VE - the File Manager within Vim!
" Authors:      Ming Bai <mbbill AT gmail DOT com>
" Last Change:  2010-11-23
" Version:      0.98
" Licence:      LGPL
"
" Usage:        :h VimExplorer
"
"==================================================


" Vim version 7.x is needed.
if v:version < 700
     echohl ErrorMsg | echomsg "VimExplorer needs vim version >= 7.0!" | echohl None
     finish
endif

" See if we are already loaded, thanks to Dennis Hostetler.
if exists("loaded_vimExplorer")
    finish
else
    let loaded_vimExplorer = 1
endif
"

command! -nargs=? -complete=file VE    call vimExplorer#VENew('<args>')

" vim: set et ff=unix fdm=marker sts=4 sw=4 tw=78:
