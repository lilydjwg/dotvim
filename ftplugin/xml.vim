" Vim script file
" FileType:     XML
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年5月10日

" ---------------------------------------------------------------------
" Format Setting:
exe 'setlocal equalprg=tidy\ -qi\ -xml\ -utf8\ -w\ 0\ -f\ '.&errorfile
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
