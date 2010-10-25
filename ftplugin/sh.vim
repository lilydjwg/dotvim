" Vim script file
" FileType:     shell script
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年2月3日

" ---------------------------------------------------------------------
" F5相关
" 保存并执行脚本
nmap <buffer> <silent> <S-F5> :update<CR>:!%:p<CR>
" 这个就只保存好了
nmap <buffer> <silent> <C-F5> :update<CR>
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
