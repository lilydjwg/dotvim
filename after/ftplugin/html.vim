" Vim script file
" FileType:     HTML
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
if exists('b:match_words')
  let b:match_words .= ',{:},\[:\],(:)'
endif
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
