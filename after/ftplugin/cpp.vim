" Vim script file
" FileType:     C++
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年3月11日
" ---------------------------------------------------------------------
"  Settings:
let b:match_words .= ',\<try\>:\<catch\>'
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
