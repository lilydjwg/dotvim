" ingo/query/motion.vim: Functions for querying a motion over text.
"
" DEPENDENCIES:
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

if ! exists('g:IngoLibrary_QueryMotionIgnoredMotions')
    let g:IngoLibrary_QueryMotionIgnoredMotions = {}
endif
if ! exists('g:IngoLibrary_QueryMotionCustomMotions')
    let g:IngoLibrary_QueryMotionCustomMotions = {}
endif
if ! exists('g:IngoLibrary_QueryMotionCustomMotionModifiers')
    let g:IngoLibrary_QueryMotionCustomMotionModifiers = 'default value'
endif

let s:builtInMotions = ingo#dict#FromKeys(['h', "\<Left>", "\<C-h>", "\<BS>", 'l', "\<Right>", ' ', '0', "\<Home>", '^', '$', "\<End>", 'g_', 'g0', "g\<Home>", 'g^', 'gm', 'gM', 'g$', "g\<End>", '|', ';', ',', 'k', "\<Up>", "\<C-p>", 'j', "\<Down>", "\<C-j>", "\<C-n>", 'gk', "g\<Up>", 'gj', "g\<Down>", '-', '+', "\<C-m>", "\<CR>", '_', 'G', "\<C-End>", "\<C-Home>", 'gg', 'go', "\<S-Right>", 'w', "\<C-Right>", 'W', 'e', 'E', "\<S-Left>", 'b', "\<C-Left>", 'B', 'ge', 'gE', '(', ')', '{', '}', ']]', '][', '[[', '[]', 'aw', 'iw', 'aW', 'iW', 'as', 'is', 'ap', 'ip', 'a]', 'a[', 'i]', 'i[', 'a)', 'a(', 'ab', 'i)', 'i(', 'ib', 'a>', 'a<', 'i>', 'i<', 'at', 'it', 'a}', 'a{', 'aB', 'i}', 'i{', 'iB', 'a"', "a'", 'a`', 'i"', "i'", 'i`', "\<C-o>", "\t", "\<C-i>", 'g;', 'g,', '%', '[(', '[{', '])', ']}', ']m', ']M', '[m', '[M', '[#', ']#', '[*', '[/', ']*', ']/', 'H', 'M', 'L', 'n', 'N', '*', '#', 'g*', 'g#', 'gd', 'gD'], '')
call extend(s:builtInMotions, {'f': '\(.\)', 'F': '\(.\)', 't': '\(.\)' , 'T': '\(.\)', ':': '[^\r]*\(\r\)\?', "'": '\([a-zA-Z0-9''`"[\]<>^.(){}]\)', '`': '\([a-zA-Z0-9''`"[\]<>^.(){}])', "g'": '\([a-zA-Z0-9''`"[\]<>^.(){}]\)', 'g`': '\([a-zA-Z0-9''`"[\]<>^.(){}]\)', '/': '[^\r]*\(\r\)\?', '?': '[^\r]*\(\r\)\?'})
let s:builtInMotionModifiers = ingo#collections#ToDict(['v', 'V', "\<C-v>"])
call extend(s:builtInMotionModifiers, g:IngoLibrary_QueryMotionCustomMotionModifiers, 'force')

function! ingo#query#motion#Get( ... ) abort
"******************************************************************************
"* PURPOSE:
"   Obtain a Vim motion / text object from the user. Includes any counts and
"   registers. Covers both built-in and custom operator-pending mode mappings.
"* LIMITATIONS:
"   - Mappings that consume additional characters (via getchar()) require
"     definition of what their additional keys look like in
"     g:IngoLibrary_QueryMotionCustomMotions.
"   - Unlike the built-in motions, does not handle 'timeoutlen', but will wait
"     indefinitely for additional keys.
"   - :[range] and / ? searches do not show the command-line and have to be
"     typed blindly.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:options.isAllowRegister   Flag that allows capture of "{register} before
"                               or after a count. Off by default, as
"                               operator-pending motions cannot take a register;
"                               it has to be specified before the operation.
"* RETURN VALUES:
"   A motion that can then be appended to an operator command to apply the
"   operator to the text. Or empty String if the motion was aborted (via <Esc>).
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    let l:isAllowRegister = get(l:options, 'isAllowRegister', 0)
    let l:count = ''
    let l:register = ''
    let l:motionModifier = ''
    let l:motion = ''
    let l:appendagePattern = ''
    let l:motionAppendage = ''
    while 1
	let l:key = ingo#compat#getcharstr()
	if l:key ==# "\<Esc>"
	    return ''
	elseif empty(l:motion)
	    if l:isAllowRegister && l:key ==# '"' && empty(l:register)
		let l:register = l:key  " Start of register
		continue
	    elseif l:key =~# '^[1-9]$' && empty(l:count)
		let l:count = l:key " Start of count
		continue
	    elseif len(l:register) == 1
		let l:register .= l:key " Completion of register
		continue
	    elseif l:key =~# '^\d$' && ! empty(l:count)
		let l:count .= l:key    " More count
		continue
	    elseif has_key(s:builtInMotionModifiers, l:key)
		" Forcing a motion (:help forced-motion) to be character- /
		" line- / blockwise. Last one wins here.
		let l:motionModifier = l:key
		continue
	    endif
	endif

	if empty(l:appendagePattern)
	    let l:motion .= l:key

	    if ! empty(maparg(l:motion, 'o')) && ! has_key(g:IngoLibrary_QueryMotionIgnoredMotions, l:motion)
		if has_key(g:IngoLibrary_QueryMotionCustomMotions, l:motion)
		    let l:appendagePattern = g:IngoLibrary_QueryMotionCustomMotions[l:motion]
		    if empty(l:appendagePattern)
			break   " Plain custom motion; we're done.
		    endif
		else
		    break   " A complete custom mapping has been input.
		endif
	    elseif has_key(s:builtInMotions, l:motion) && (empty(mapcheck(l:motion, 'o')) || has_key(g:IngoLibrary_QueryMotionIgnoredMotions, l:motion))
		let l:appendagePattern = s:builtInMotions[l:motion]
		if empty(l:appendagePattern)
		    break   " Plain built-in motion; we're done.
		endif
	    endif
	else
	    let l:motionAppendage .= l:key
	    let l:appendageMatches = matchlist(l:motionAppendage, ingo#regexp#Anchored(l:appendagePattern))
	    if empty(l:appendageMatches)
		return ''   " Invalid appendage.
	    elseif ! empty(l:appendageMatches[1])   " Something is in the first capture group.
		break   " The motion appendage is complete; we're done.
	    endif
	    " This queries more than one key.

	    " Handle <BS> for a minimal command-line experience (as those
	    " motions that take multiple keys are likely : or / or ?).
	    if l:key ==# "\<BS>" && l:motionAppendage =~# "\<BS>"
		let l:motionAppendage = substitute(l:motionAppendage, ".\<BS>$", '', '')
		redraw | echo l:motion . l:motionAppendage
	    else
		" Echo what's getting typed to give better user feedback.
		if l:motionAppendage =~# '^.$'
		    echo l:motion . l:motionAppendage
		else
		    echon l:key
		endif
	    endif
	endif
    endwhile

    return l:count . l:register . l:motionModifier . l:motion . l:motionAppendage
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
