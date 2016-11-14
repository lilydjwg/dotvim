" Vim syntax file
" FileType:     systemd edits
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
syn match sdFilename contained nextgroup=sdErr /\%(%h\)\?\/\S*/
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
