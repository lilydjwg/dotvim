" ingo/plugin/rendered/Confirmeach.vim: Filter items by confirming each, as with :s///c.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#plugin#rendered#Confirmeach#Filter( items )
    let l:confirmedItems = []
    let l:idx = 0
    while l:idx < len(a:items)
	let l:match = a:items[l:idx]

	echo l:match . "\t"
	echohl Question
	    echon ' Use (y/n/a/q/l; <Esc> to abort)?'
	echohl None

	let l:choice = ingo#query#get#Char({
	\   'isBeepOnInvalid': 0, 'validExpr': "[ynl\<Esc>aq]",
	\   'isAllowDigraphs': 0,
	\})
	if l:choice ==# "\<Esc>"
	    return a:items
	elseif l:choice ==# 'q'
	    break
	elseif l:choice ==# 'y'
	    call add(l:confirmedItems, l:match)
	elseif l:choice ==# 'l'
	    call add(l:confirmedItems, l:match)
	    break
	elseif l:choice ==# 'a'
	    let l:confirmedItems += a:items[l:idx : -1]
	    break
	endif

	let l:idx += 1
    endwhile

    return l:confirmedItems
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
