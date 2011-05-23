" Vim script file
" FileType:     CSS
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2010年5月23日
"
" 伪类后不必有空格
syn match cssPseudoClass ":[^{]\+" contains=cssPseudoClassId,cssUnicodeEscape  
syn match cssPseudoClass "::[^{]\+" contains=cssPseudoClassId,cssUnicodeEscape  
syn match cssPseudoClassId contained /\v-moz-selection|selection/
