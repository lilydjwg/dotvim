" Vim script file
" FileType:     ConteXt
" Author:       lilydjwg <lilydjwg@gmail.com>
" ---------------------------------------------------------------------
if $PATH !~ 'context'
  echohl WarningMsg
  echo "没有载入 ConTeXt 初始化脚本！"
  echohl None
endif
runtime ftplugin/texcommon.vim
nmap <buffer> <C-F5> :call texcommon#tex2pdf('context')<CR>
vmap <buffer> mr <ESC>`>a}{}<ESC>`<i\ruby{<ESC>f};
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
