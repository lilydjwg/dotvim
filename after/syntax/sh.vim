" Vim syntax file
" FileType:     shell script
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年2月10日

" ---------------------------------------------------------------------
"  Don't mark as Error:
syn region shCommandSub matchgroup=shCmdSubRegion start="\$(" end=")" contains=@shCommandSubList

" 允许 sh 中出现原本在 bash 中这样的 ${0%\/*}
syn region shDeref	matchgroup=PreProc start="\${!" end="\*\=}"	contains=@shDerefList,shDerefOp
syn match  shDerefOp	contained	"#\{1,2}"	nextgroup=@shDerefPatternList
syn match  shDerefOp	contained	"%\{1,2}"	nextgroup=@shDerefPatternList
syn match  shDerefPattern	contained	"[^{}]\+"	contains=shDeref,shDerefSimple,shDerefPattern,shDerefString,shCommandSub,shDerefEscape nextgroup=shDerefPattern
syn region shDerefPattern	contained	start="{" end="}"	contains=shDeref,shDerefSimple,shDerefString,shCommandSub nextgroup=shDerefPattern
syn match  shDerefEscape	contained	'\%(\\\\\)*\\.'
syn region shDerefOp	contained	start=":[$[:alnum:]_]"me=e-1 end=":"me=e-1 end="}"me=e-1 contains=@shCommandSubList nextgroup=shDerefPOL
syn match  shDerefPOL	contained	":[^}]\+"	contains=@shCommandSubList
syn match  shDerefPPS	contained	'/\{1,2}'	nextgroup=shDerefPPSleft
syn region shDerefPPSleft	contained	start='.'	skip=@\%(\\\)\/@ matchgroup=shDerefOp end='/' end='\ze}' nextgroup=shDerefPPSright contains=@shCommandSubList
syn region shDerefPPSright	contained	start='.'	end='\ze}'	contains=@shCommandSubList
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
