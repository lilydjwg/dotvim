" Vim script file
" FileType:     C (and C++)
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
"  Settings:
"  TODO: match while/for and break/continue
let b:match_words .= ',\%(#\s*\)\@<!\<if\>:\%(#\s*\)\@<!\<else\>'
      \ . ',\<switch\>:\<case\>:\<default\>'
      \ . ',^\s*#\s*if\%(n\?def\)\?\>:^\s*#\s*else\>:^\s*#\s*endif\>'
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
