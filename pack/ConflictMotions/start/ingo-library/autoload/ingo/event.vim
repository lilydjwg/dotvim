" ingo/event.vim: Functions for triggering events.
"
" DEPENDENCIES:
"
" Copyright: (C) 2015-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if v:version == 703 && has('patch438') || v:version > 703
function! ingo#event#Trigger( arguments )
    execute 'doautocmd <nomodeline>' a:arguments
endfunction
function! ingo#event#TriggerEverywhere( arguments )
    execute 'doautoall <nomodeline>' a:arguments
endfunction
else
function! ingo#event#Trigger( arguments )
    let l:save_modeline = &l:modeline
    setlocal nomodeline
    try
	execute 'doautocmd             ' a:arguments
    finally
	let &l:modeline = l:save_modeline
    endtry
endfunction
function! ingo#event#TriggerEverywhere( arguments )
    let l:save_modeline = &l:modeline
    setlocal nomodeline
    try
	execute 'doautoall             ' a:arguments
    finally
	let &l:modeline = l:save_modeline
    endtry
endfunction
endif

function! ingo#event#TriggerCustom( eventName )
    silent call ingo#event#Trigger('User ' . a:eventName)
endfunction
function! ingo#event#TriggerEverywhereCustom( eventName )
    silent call ingo#event#TriggerEverywhere('User ' . a:eventName)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
