" Vim syntax file
" FileType:     muttrc
" Author:       lilydjwg <lilydjwg@gmail.com>

syn match muttrcAliasKey	contained /\s*[^- \t]\S*/ skipwhite nextgroup=muttrcAliasEmail,muttrcAliasEncEmail,muttrcAliasNameNoParens,muttrcAliasENNL

syn keyword muttrcColor	contained lightblack lightblue lightcyan lightdefault lightgreen lightmagenta lightred lightwhite lightyellow
syn match   muttrcColor	contained "\<\%(light\)\=color\d\{1,3}\>"
