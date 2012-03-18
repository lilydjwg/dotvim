" Vim script file
" FileType:     mutt mail
" Author:       lilydjwg <lilydjwg@gmail.com>

" ---------------------------------------------------------------------
if &cp || expand('%:p') !~ '^/tmp/mutt' || !exists('g:MuttVim_configfile')
  finish
endif
let s:keepcpo = &cpo
set cpo&vim

if !filereadable(g:MuttVim_configfile)
  echohl WarningMsg
  echo "Config file" g:MuttVim_configfile "not readable!"
  echohl None
elseif has('python3')
  if !exists("g:loaded_muttvim")
    let g:loaded_muttvim = 1
    let pyfile = expand('<sfile>:r') . '.py'
    exe 'py3file' pyfile
  endif
  py3 procMuttMail()
endif

0
/^$
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo=s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
