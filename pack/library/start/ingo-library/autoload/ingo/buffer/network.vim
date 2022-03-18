" ingo/buffer/network.vim: Functions for loading buffers from the network.
"
" DEPENDENCIES:
"
" Copyright: (C) 2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#buffer#network#Read( bufferName, networkLocation ) abort
"******************************************************************************
"* PURPOSE:
"   Load a:networkLocation into a split scratch buffer named a:bufferName.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   - Creates scratch buffer and opens it in a split window.
"   - Emits a custom NetworkLocationRead User event if successful.
"* INPUTS:
"   a:bufferName    The name for the scratch buffer. If this already exists (but
"                   isn't a scratch buffer), a different one will be generated.
"   a:networkLocation   Network location in a format suitable for |:Nread|.
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    if ! ingo#buffer#scratch#Create('', a:bufferName, 0, '1Nread ' . a:networkLocation, 'new')
	call ingo#err#Set('Failed to open scratch buffer for ' . a:bufferName)
	return 0
    endif

    call ingo#event#TriggerCustom('NetworkLocationRead')
    return 1
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
