" make unordered list inherit stars
setlocal comments=b:*,b:-,b:+,n:> commentstring=>\ %s
setlocal formatoptions+=ro

" make multiline list items autoindent
setlocal autoindent

let g:markdown_folding = 1
