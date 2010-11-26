" Vim script file
" FileType:     C
" Author:       lilydjwg
" Last Change:  2010-11-26

if &ft != 'c' && expand('%:e') != 'h'  " 这不要让 C++ 文件执行
  finish
endif

" 改注释为 /* ... */ （为了某些 C 语言）
command! -buffer TCC %s/\/\/\s*\(.*\)/\/\* \1 \*\//g
command! -buffer TCPP %s=\v/\*\s*(.*)\s*\*/=// \1=g
command! -buffer CPP update|exe '!gcc -g -Wall "%:p" -o "%:p:r" 2> ' . &errorfile | cfile
