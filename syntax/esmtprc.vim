" Vim syntax file
" FileType:     esmtp configuration file
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年4月16日

" ---------------------------------------------------------------------
" 高亮 # 注释
syn match	esmtprcComment	"^#.*"
syn match	esmtprcComment	"\s#.*"ms=s+1
hi def link esmtprcComment	Comment
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
