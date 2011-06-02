" Vim script file
" FileType:     C
" Author:       lilydjwg

if &ft != 'c' && expand('%:e') != 'h'  " 这不要让 C++ 文件执行
  finish
endif

command! -buffer CPP update|exe '!gcc -g -Wall "%:p" -o "%:p:r" 2> ' . &errorfile | cfile
call CountJump#TextObject#MakeWithCountSearch('<buffer>', 'C', 'ai', 'v', '/\*\s*', '\s*\*/')
