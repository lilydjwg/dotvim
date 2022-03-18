" ingo/query/get.vim: Functions for querying simple data types from the user.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#query#get#Number( maxNum, ... )
"******************************************************************************
"* PURPOSE:
"   Query a number from the user. In contrast to |getchar()|, this allows for
"   multiple digits. In contrast to |input()|, the entry need not necessarily be
"   concluded with <Enter>, saving one keystroke.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   :echo's the typed number.
"* INPUTS:
"   a:maxNum    Maximum number to be input.
"   a:defaultNum    Number when the query is acknowledged with <Enter> without
"		    entering any digit. Default is -1.
"* RETURN VALUES:
"   Either the entered number, a:defaultNum when only <Enter> is pressed, or -1
"   when an invalid (i.e. non-digit) number was entered.
"******************************************************************************
    let l:nr = 0
    let l:leadingZeroCnt = 0
    while 1
	let l:char = ingo#compat#getcharstr()

	if l:char ==# "\<CR>"
	    return (l:nr == 0 ? (a:0 ? a:1 : -1) : l:nr)
	elseif l:char !~# ingo#regexp#Anchored('\d')
	    return -1
	endif
	echon l:char

	if l:char ==# '0' && l:nr == 0
	    let l:leadingZeroCnt += 1
	    if l:leadingZeroCnt >= len(a:maxNum)
		return 0
	    endif
	else
	    let l:nr = 10 * l:nr + str2nr(l:char)
	    if a:maxNum < 10 * l:nr || l:leadingZeroCnt + len(l:nr) >= len(a:maxNum)
		return l:nr
	    endif
	endif
    endwhile
endfunction

if ! exists('g:IngoLibrary_DigraphTriggerKey')
    let g:IngoLibrary_DigraphTriggerKey = "\<C-k>"
endif
function! ingo#query#get#CharOrDigraph( ... )
"******************************************************************************
"* PURPOSE:
"   A drop-in replacement for getcharstr() that also handles digraphs; i.e. a
"   combination of CTRL-K + char1 + char2. Only supports real two-char digraphs,
"   not the CTRL-K + {special-key} form.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr  Same as for |getcharstr()|.
"* RETURN VALUES:
"   Same as for |getcharstr()|.
"******************************************************************************
    let l:char = call('ingo#compat#getcharstr', a:000)
    if empty(l:char) || empty(g:IngoLibrary_DigraphTriggerKey) || l:char !=# g:IngoLibrary_DigraphTriggerKey
	return l:char
    endif

    let l:firstDigraphChar = call('ingo#compat#getcharstr', a:000)
    if empty(l:firstDigraphChar)
	return l:char
    endif

    let l:secondDigraphChar = call('ingo#compat#getcharstr', a:000)
    if empty(l:secondDigraphChar)
	return l:char . l:firstDigraphChar
    endif

    return ingo#digraph#Get(l:firstDigraphChar, l:secondDigraphChar)
endfunction

function! ingo#query#get#Char( ... )
"******************************************************************************
"* PURPOSE:
"   Query a character from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.isBeepOnInvalid   Flag whether to beep on invalid pattern (but not
"				when aborting with <Esc>). Default on.
"   a:options.validExpr         Unanchored pattern for valid characters.
"                               Aborting with <Esc> is always possible, but if
"                               you add \e, it will be returned as ^[.
"   a:options.invalidExpr       Unanchored pattern for invalid characters.
"                               Takes precedence over a:options.validExpr.
"   a:options.isAllowDigraphs   Flag (default true) whether digraphs (CTRL-K +
"                               char1 + char2) can be entered as well.
"* RETURN VALUES:
"   Either the valid character, or an empty string when aborted or invalid
"   character.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isBeepOnInvalid = get(l:options, 'isBeepOnInvalid', 1)
    let l:validExpr = get(l:options, 'validExpr', '')
    let l:invalidExpr = get(l:options, 'invalidExpr', '')
    let l:GetChar = (get(l:options, 'isAllowDigraphs', 1) ? function('ingo#query#get#CharOrDigraph') : function('ingo#compat#getcharstr'))

    let l:char = call(l:GetChar, [])
    if l:char ==# "\<Esc>" && (empty(l:validExpr) || l:char !~ ingo#regexp#Anchored(l:validExpr))
	return ''
    elseif (! empty(l:validExpr) && l:char !~ ingo#regexp#Anchored(l:validExpr)) ||
    \   (! empty(l:invalidExpr) && l:char =~ ingo#regexp#Anchored(l:invalidExpr))
	if l:isBeepOnInvalid
	    execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	endif
	return ''
    endif

    return l:char
endfunction
function! ingo#query#get#ValidChar( ... )
"******************************************************************************
"* PURPOSE:
"   Query a character from the user until a valid one has been pressed (or
"   aborted with <Esc>).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.isBeepOnInvalid   Flag whether to beep on invalid pattern (but not
"				when aborting with <Esc>). Default on.
"   a:options.validExpr         Unanchored pattern for valid characters.
"                               Aborting with <Esc> is always possible, but if
"                               you add \e, it will be returned as ^[.
"   a:options.invalidExpr       Unanchored pattern for invalid characters. Takes
"                               precedence over a:options.validExpr.
"   a:options.isAllowDigraphs   Flag (default true) whether digraphs (CTRL-K +
"                               char1 + char2) can be entered as well.
"* RETURN VALUES:
"   Either the valid character, or an empty string when aborted.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isBeepOnInvalid = get(l:options, 'isBeepOnInvalid', 1)
    let l:validExpr = get(l:options, 'validExpr', '')
    let l:invalidExpr = get(l:options, 'invalidExpr', '')
    let l:GetChar = (get(l:options, 'isAllowDigraphs', 1) ? function('ingo#query#get#CharOrDigraph') : function('ingo#compat#getcharstr'))

    while 1
	let l:char = call(l:GetChar, [])

	if l:char ==# "\<Esc>" && (empty(l:validExpr) || l:char !~ ingo#regexp#Anchored(l:validExpr))
	    return ''
	elseif (! empty(l:validExpr) && l:char !~ ingo#regexp#Anchored(l:validExpr)) ||
	\   (! empty(l:invalidExpr) && l:char =~ ingo#regexp#Anchored(l:invalidExpr))
	    if l:isBeepOnInvalid
		execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
	    endif
	else
	    break
	endif
    endwhile

    return l:char
endfunction

function! ingo#query#get#Register( ... )
"******************************************************************************
"* PURPOSE:
"   Query a register from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.errorRegister Optional register name to be returned when aborted
"                           or invalid register. Defaults to the empty string.
"                           Use '\' to yield an empty string (from getreg())
"                           when passing the function's results directly to
"                           getreg().
"   a:options.additionalValidExpr   Unanchored pattern for additional valid
"                                   characters.
"   a:options.invalidRegisterExpr   Optional pattern for invalid registers.
"* RETURN VALUES:
"   Either the register, an additional allowed character, or an
"   a:options.errorRegister when aborted or invalid register.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:errorRegister = get(l:options, 'errorRegister', '')
    let l:additionalValidExpr = get(l:options, 'additionalValidExpr', '')
    try
	let l:register = ingo#query#get#Char({
	\   'validExpr': ingo#register#All() . (empty(l:additionalValidExpr) ? '' : '\|' . l:additionalValidExpr),
	\   'invalidExpr': get(l:options, 'invalidRegisterExpr', ''),
	\   'isAllowDigraphs': 0,
	\})
	return (empty(l:register) ? l:errorRegister : l:register)
    catch /^Vim\%((\a\+)\)\=:E523:/ " E523: Not allowed here
	return l:errorRegister
    endtry
endfunction
function! ingo#query#get#WritableRegister( ... )
"******************************************************************************
"* PURPOSE:
"   Query a register that can be written to from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.errorRegister Optional register name to be returned when aborted
"                           or invalid register. Defaults to the empty string.
"                           Use '\' to yield an empty string (from getreg())
"                           when passing the function's results directly to
"                           getreg().
"   a:options.additionalValidExpr   Unanchored pattern for additional valid
"                                   characters.
"   a:options.invalidRegisterExpr   Optional pattern for invalid registers.
"* RETURN VALUES:
"   Either the writable, an additional allowed character, or an
"   a:options.errorRegister when aborted or invalid register.
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:errorRegister = get(l:options, 'errorRegister', '')
    let l:additionalValidExpr = get(l:options, 'additionalValidExpr', '')
    try
	let l:register = ingo#query#get#Char({
	\   'validExpr': ingo#register#Writable() . (empty(l:additionalValidExpr) ? '' : '\|' . l:additionalValidExpr),
	\   'invalidExpr': get(l:options, 'invalidRegisterExpr', ''),
	\   'isAllowDigraphs': 0,
	\})
	return (empty(l:register) ? l:errorRegister : l:register)
    catch /^Vim\%((\a\+)\)\=:E523:/ " E523: Not allowed here
	return l:errorRegister
    endtry
endfunction

function! ingo#query#get#Mark( ... )
"******************************************************************************
"* PURPOSE:
"   Query a mark from the user.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:invalidMarkExpr   Optional pattern for invalid marks. Or pass 1 when you
"			want to use the mark for setting, and filter out all
"			read-only marks.
"* RETURN VALUES:
"   Either the mark, or empty string when aborted or invalid register.
"******************************************************************************
    try
	return ingo#query#get#Char({
	\   'validExpr': '[a-zA-Z0-9''`"[\]<>^.(){}]',
	\   'invalidExpr': (a:0 ? (a:1 is# 1 ? '[0-9^.(){}]' : a:1) : ''),
	\   'isAllowDigraphs': 0,
	\})
    catch /^Vim\%((\a\+)\)\=:E523:/ " E523: Not allowed here
	return ''
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
