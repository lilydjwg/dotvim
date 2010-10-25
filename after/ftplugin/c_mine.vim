" Vim script file
" FileType:     C (and C++)
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年3月30日

" ---------------------------------------------------------------------
"  Settings:
let b:match_words .= ',\<if\>:\<else\>,\<switch\>:\<case\>:\<default\>'
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
