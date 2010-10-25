" Vim script file
" FileType:     C++
" Author:       lilydjwg
" Last Change:  2010年3月11日

command! -buffer CPP update|exe '!g++ -g -Wall "%:p" -o "%:p:r" 2> ' . &errorfile | cfile
