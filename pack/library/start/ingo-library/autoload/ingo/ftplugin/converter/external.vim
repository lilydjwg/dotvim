" ingo/ftplugin/converter/external.vim: Build a file converter via an external command.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:ObtainText( commandDefinition, commandArguments, filespec )
    let l:command = call('ingo#format#Format', [a:commandDefinition.commandline] + map([a:commandDefinition.command, a:commandArguments, expand(a:filespec)], 'ingo#compat#shellescape(v:val)'))

    call ingo#ftplugin#converter#PreAction(a:commandDefinition)
	let l:result = ingo#compat#systemlist(l:command)
	if v:shell_error != 0
	    throw 'converter: Conversion failed: shell returned ' . v:shell_error . (empty(l:result) ? '' : ': ' . join(l:result))
	endif
    call ingo#ftplugin#converter#PostAction(a:commandDefinition)

    return l:result
endfunction

function! ingo#ftplugin#converter#external#ToText( externalCommandDefinitionsVariable, arguments, filespec )
"******************************************************************************
"* PURPOSE:
"   Build a command that converts a file via an external command to just text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Takes over the current buffer, replaces its contents, changes its filetype
"   and locks further editing.
"* INPUTS:
"   a:externalCommandDefinitionsVariable    Name of a List of Definitions
"					    objects (cp.
"					    ingo#ftplugin#converter#Builder#Format())
"					    Here, the a:filespec is additionally
"					    inserted (as the third placeholder)
"					    into the commandline attribute.
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:externalCommandDefinitionsVariable.command, all passed by
"                   the user to the built command.
"   a:filespec      Filespec of the source file, usually representing the
"                   current buffer. It's read from the file system instead of
"                   being piped from Vim's buffer because it may be in binary
"                   format.
"* USAGE:
"   command! -bar -nargs=? FooToText call setline(1, getline(1)) |
"   \   if ! ingo#ftplugin#converter#external#ToText('g:foo_converters',
"   \   <q-args>, bufname('')) | echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:externalCommandDefinitionsVariable, a:arguments)
	let l:text = s:ObtainText(l:commandDefinition, l:commandArguments, a:filespec)

	silent %delete _
	setlocal endofline nobinary fileencoding<
	call setline(1, l:text)
	call ingo#change#Set([1, 1], [line('$'), 1])

	let &l:filetype = get(l:commandDefinition, 'filetype', 'text')

	setlocal nomodifiable nomodified
	return 1
    catch /^converter:/
	call ingo#err#SetCustomException('converter')
	return 0
    endtry
endfunction
function! ingo#ftplugin#converter#external#ExtractText( externalCommandDefinitionsVariable, mods, arguments, filespec )
"******************************************************************************
"* PURPOSE:
"   Build a command that converts a file via an external command to another
"   scratch buffer that contains just text.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates a new scratch buffer.
"* INPUTS:
"   a:externalCommandDefinitionsVariable    Name of a List of Definitions
"					    objects (cp.
"					    ingo#ftplugin#converter#external#ToText())
"   a:mods          Any command modifiers supplied to the built command (to open
"                   the scratch buffer in a split and control its location).
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:externalCommandDefinitionsVariable.command, all passed by
"                   the user to the built command.
"   a:filespec      Filespec of the source file, usually representing the
"                   current buffer. It's read from the file system instead of
"                   being piped from Vim's buffer because it may be in binary
"                   format.
"* USAGE:
"   command! -bar -nargs=? FooExtractText
"   \   if ! ingo#ftplugin#converter#external#ExtractText('g:foo_converters',
"   \   ingo#compat#command#Mods('<mods>'), <q-args>, bufname('')) |
"   \   echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:externalCommandDefinitionsVariable, a:arguments)
	let l:text = s:ObtainText(l:commandDefinition, l:commandArguments, a:filespec)

	let l:status = ingo#buffer#scratch#Create('', expand('%:r') . '.' . get(l:commandDefinition, 'extension', 'txt'), 1, l:text, (empty(a:mods) ? 'enew' : a:mods . ' new'))
	if l:status == 0
	    call ingo#err#Set('Failed to open scratch buffer.')
	    return 0
	endif
	return 1
    catch /^converter:/
	call ingo#err#SetCustomException('converter')
	return 0
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
