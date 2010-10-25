" Vim script file
" FileType:     ConteXt
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年6月5日

" ---------------------------------------------------------------------
runtime ftplugin/texcommon.vim

nmap <buffer> <C-CR> :call Lilydjwg_tex_pdf('texexec')<CR>
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
