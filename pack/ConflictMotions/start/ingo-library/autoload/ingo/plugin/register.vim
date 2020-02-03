" ingo/plugin/register.vim: Functions that help plugins set register contents.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#plugin#register#Set( contents, regtype )
"******************************************************************************
"* PURPOSE:
"   Set the contents of the specified (v:register) register; if the default
"   register is used, also duplicate the contents to the system clipboard.
"* ASSUMPTIONS / PRECONDITIONS:
"   - Target register is in v:register (as when triggered by a mapping).
"* EFFECTS / POSTCONDITIONS:
"   - Updates register(s).
"* INPUTS:
"   a:contents  Register contents to be written.
"   a:regtype   Mode (char / line / block) as in setreg().
"* RETURN VALUES:
"   None.
"******************************************************************************
    try
	call setreg(v:register, a:contents, a:regtype)

	if v:register ==# ingo#register#Default() && has('clipboard')
	    " Default to both default register _and_ system clipboard, as this
	    " mapping is mostly used to make internal Vim registers (or the
	    " current buffer's filespec) accessible outside of Vim, and it's
	    " cumbersome to prefix the mapping with "+.
	    call setreg('+', a:contents, a:regtype)
	endif
    catch /^Vim\%((\a\+)\)\=:/
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
    endtry
endfunction
let s:lastMoveSource = ''
function! ingo#plugin#register#PutContents( source, contents, regtype, addendum )
"******************************************************************************
"* PURPOSE:
"   Put a:contents and a:addendum (with mode a:regtype) into the specified (via
"   v:register) register; if the default register is used, also duplicate the
"   contents to the system clipboard.
"* ASSUMPTIONS / PRECONDITIONS:
"   - Target register is in v:register (as when triggered by a mapping).
"* EFFECTS / POSTCONDITIONS:
"   - Updates register(s).
"   - Prints (possibly shortened) register contents.
"* INPUTS:
"   a:source    Identifier of the source for a:contents.
"   a:contents  Register contents to be written.
"               When empty, nothing is written and an error is produced.
"               When (numerical) 0, the client already has called ingo#err#Set()
"               with an error message, and the function just returns back 0.
"   a:regtype   Mode (char / line / block) as in setreg().
"   a:addendum  Additional text that is appended to a:contents. If a List, only
"               the first element is appended.
"* RETURN VALUES:
"   0 if no register update happens; ingo#err#Get() has the error message then.
"   1 if successful.
"******************************************************************************
    if type(a:contents) == type(0) && a:contents == 0
	return 0
    elseif empty(a:contents)
	call ingo#err#Set('Nothing yanked')
	return 0
    endif

    let s:lastMoveSource = a:source
    let l:completeContents = a:contents . (empty(a:addendum) ? '' : (type(a:addendum) == type([]) ? a:addendum[0] : a:addendum))
    call ingo#plugin#register#Set(l:completeContents, a:regtype)

    " It's helpful to print the contents, but avoid the hit-enter prompt when
    " the contents are too long or contain newlines.
    call ingo#avoidprompt#EchoAsSingleLine(l:completeContents)
    return 1
endfunction
function! ingo#plugin#register#IsOwnedBySource( source ) abort
"******************************************************************************
"* PURPOSE:
"   Test whether the previous register update was done by a:source. This can be
"   used for appending contents to the register (specified via v:register), in a
"   format that may vary based on the previous source.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:source    Identifier of the source for a:contents.
"* RETURN VALUES:
"   0 if no / a different source was specified on the last call to
"   ingo#plugin#register#PutContents(). Else 1.
"******************************************************************************
    return (s:lastMoveSource ==# a:source)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
