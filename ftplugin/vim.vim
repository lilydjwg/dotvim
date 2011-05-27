" Vim script file
" FileType:     Vim script
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年2月8日

" ---------------------------------------------------------------------
"  Settings And Mappings:
setlocal isk-=-
setlocal keywordprg=:help
imap <silent> <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^\s*"\s*$')<CR>
call CountJump#TextObject#MakeWithCountSearch('<buffer>', 'f', 'ai', 'V', '^\s*function\>', '^\s*endfunc')
call CountJump#TextObject#MakeWithCountSearch('<buffer>', 'l', 'ai', 'V', '^\s*while\>', '^\s*endw')
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
