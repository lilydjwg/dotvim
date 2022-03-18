" ingo/ftplugin/converter/builder.vim: Build a file converter via an Ex command.
"
" DEPENDENCIES:
"   - :KeepView command (from anwolib.vim) (optional)
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#ftplugin#converter#builder#FilterBuffer( commandDefinition, commandArguments, range, isBang )
    if has_key(a:commandDefinition, 'commandline')
	let l:commandLine = ingo#actions#ValueOrFunc(a:commandDefinition.commandline, {'definition': a:commandDefinition, 'range': a:range, 'isBang': a:isBang, 'arguments': a:commandArguments})
	if has_key(a:commandDefinition, 'command')
	    let l:command = ingo#format#Format(l:commandLine, ingo#compat#shellescape(a:commandDefinition.command), a:commandArguments)
	else
	    let l:command = ingo#format#Format(l:commandLine, a:commandArguments)
	endif
    elseif has_key(a:commandDefinition, 'command')
	let l:command = a:commandDefinition.command
    else
	throw 'converter: Neither command nor commandline defined for ' . get(a:commandDefinition, 'name', string(a:commandDefinition))
    endif

    call ingo#ftplugin#converter#PreAction(a:commandDefinition)
	silent! execute a:range . l:command
	if l:command =~# '^!' && v:shell_error != 0
	    throw 'converter: Conversion failed: shell returned ' . v:shell_error
	endif
    call ingo#ftplugin#converter#PostAction(a:commandDefinition)
endfunction

function! ingo#ftplugin#converter#builder#Filter( commandDefinitionsVariable, range, isBang, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that filters the current buffer by filtering its contents
"   through an command.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current buffer.
"* INPUTS:
"   a:commandDefinitionsVariable    Name of a List of Definitions objects:
"	command:    Command to execute.
"	commandline:printf() (or ingo#format#Format()) template for inserting
"		    command and command arguments to build the Ex command-line
"		    to execute. a:range is prepended to this. To filter through
"		    an external command, start the commandline with "!".
"		    Or a Funcref that gets passed the invocation context (and
"		    Dictionary with these keys: definition, range, isBang,
"		    arguments) and should return the (dynamically generated)
"		    commandline.
"	arguments:  List of possible command-line arguments supported by
"                   command, used as completion candidates.
"	filetype:   Optional value to :setlocal filetype to.
"	extension:  Optional file extension (for
"		    ingo#ftplugin#converter#external#ExtractText())
"	preAction:  Optional Ex command or Funcref that is invoked before the
"                   external command.
"	postAction: Optional Ex command or Funcref that is invoked after
"                   successful execution of the external command.
"   a:range         Range of lines to be filtered.
"   a:isBang        Flag whether [!] has been supplied.
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:commandDefinitionsVariable.command, all passed by the user
"                   to the built command.
"   a:preCommand    Optional Ex command to be executed before anything else.
"                   a:commandDefinitionsVariable.preAction can configure
"                   different pre commands for each definition, whereas this one
"                   applies to all definitions.
"* USAGE:
"   command! -bang -bar -range=% -nargs=? FooPrettyPrint call setline(1, getline(1)) |
"   \   if ! ingo#ftplugin#converter#builder#Filter('g:Foo_PrettyPrinters',
"   \       '<line1>,<line2>', <bang>0, <q-args>) | echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    try
	let [l:commandDefinition, l:commandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:commandDefinitionsVariable, a:arguments)

	if a:0
	    execute a:1
	endif

	call ingo#ftplugin#converter#builder#FilterBuffer(l:commandDefinition, l:commandArguments, a:range, a:isBang)

	let l:targetFiletype = get(l:commandDefinition, 'filetype', '')
	if ! empty(l:targetFiletype)
	    let &l:filetype = l:targetFiletype
	endif

	return 1
    catch /^converter:/
	call ingo#err#SetCustomException('converter')
	return 0
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! ingo#ftplugin#converter#builder#DifferentFiletype( targetFiletype, commandDefinitionsVariable, range, isBang, arguments, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that converts the current buffer's contents to a different
"   a:targetFiletype by filtering its contents through an Ex command.
"   Like ingo#ftplugin#converter#builder#Filter(), but additionally sets
"   a:targetFiletype on a successful execution.
"* INPUTS:
"   a:targetFiletype    Target 'filetype' that the buffer is set to if the
"                       filtering has been successful. This overrides
"                       a:commandDefinitionsVariable.filetype (which is not
"                       supposed to be used here).
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    let l:success = call('ingo#ftplugin#converter#builder#Filter', [a:commandDefinitionsVariable, a:range, a:isBang, a:arguments] + a:000)
    if l:success
	let &l:filetype = a:targetFiletype
    endif
    return l:success
endfunction

function! s:MakeConverter( commandDefinition, commandArguments, isBang ) abort
    return printf('%s call ingo#ftplugin#converter#builder#FilterBuffer(%s, %s, "''[,'']", %d)',
    \   (exists(':KeepView') == 2 ? 'KeepView' : ''),
    \   string(a:commandDefinition), string(a:commandArguments), a:isBang
    \)
endfunction
function! ingo#ftplugin#converter#builder#EditAsFiletype( targetFiletype, forwardCommandDefinitionsVariable, backwardCommandDefinitionsVariable, startLnum, endLnum, isBang, arguments, windowOpenCommand, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Build a command that allows editing the a:startLnum,a:endLnum range in the
"   current buffer in a converted scratch buffer by converting its contents
"   through an command and back.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current buffer.
"* INPUTS:
"   a:targetFiletype    Target 'filetype' that the buffer is set to if the
"                       filtering has been successful. If not empty, overrides
"                       a:forwardCommandDefinitionsVariable.filetype.
"   a:forwardCommandDefinitionsVariable
"		    Name of a List of Definitions objects to convert to the
"		    target filetype; see
"		    ingo#ftplugin#converter#builder#Filter() for details.
"   a:backwardCommandDefinitionsVariable
"		    Name of a List of Definitions objects for converting back to
"		    the original filetype.
"   a:startLnum     First line number in the current buffer to be edited.
"   a:endLnum       Last line number in the current buffer to be edited.
"   a:isBang        Flag whether [!] has been supplied.
"   a:arguments     Converter argument (optional if there's just one configured
"                   converter), followed by optional arguments for
"                   a:commandDefinitionsVariable.command, all passed by the user
"                   to the built command.
"   a:windowOpenCommand	Ex command to open the scratch window, e.g. :vnew or
"			:topleft new.
"   a:options       Optional configuration of
"                   ingo#buffer#scratch#converted#Create(). In addition, these
"                   values can be set:
"   a:options.preCommand
"		    Optional Ex command to be executed before anything else.
"                   a:forwardCommandDefinitionsVariable.preAction can configure
"                   different pre commands for each definition, whereas this one
"                   applies to all definitions.
"* USAGE:
"   command! -bang -bar -range=% -nargs=? FooEditAsBar
"   \   if ! ingo#ftplugin#converter#builder#EditAsFiletype('bar', 'g:Foo_Converters',
"   \       'g:Bar_Converters', <line1>, <line2>, 0, <q-args>, 'new') |
"   \       echoerr ingo#err#Get() | endif
"* RETURN VALUES:
"   1 if successful, 0 if ingo#err#Set().
"******************************************************************************
    let l:options = (a:0 ? a:1 : {})
    if ! &l:modifiable && ! has_key(l:options, 'isAllowUpdate')
	" Disable persistence to original buffer if that one cannot be modified.
	let l:options.isAllowUpdate = 0
    endif
    let l:preCommand = get(l:options, 'preCommand', '')
    let l:originalBufNr = bufnr('')

    try
	let [l:forwardCommandDefinition, l:commandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:forwardCommandDefinitionsVariable, a:arguments)
	let [l:backwardCommandDefinition, l:ignoredDuplicateCommandArguments] = ingo#ftplugin#converter#GetCommandDefinition(a:backwardCommandDefinitionsVariable, a:arguments)

	execute l:preCommand

	let l:targetFiletype = (empty(a:targetFiletype) ?
	\   get(l:forwardCommandDefinition, 'filetype', '') :
	\   a:targetFiletype
	\)
	let l:targetName = (empty(bufname('')) ? 'untitled' : expand('%:r')) . '.' . l:targetFiletype

	if ! ingo#buffer#scratch#converted#Create(
	\   a:startLnum, a:endLnum,
	\   l:targetName,
	\   s:MakeConverter(l:forwardCommandDefinition, l:commandArguments, a:isBang),
	\   s:MakeConverter(l:backwardCommandDefinition, l:commandArguments, a:isBang),
	\   a:windowOpenCommand,
	\   l:options
	\)
	    call ingo#err#Set('Failed to open scratch buffer for ' . l:targetName)
	    return 0
	endif

	if ! empty(l:targetFiletype)
	    let &l:filetype = l:targetFiletype
	endif

	return 1
    catch /^converter:/
	call ingo#err#SetCustomException('converter')
	return 0
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()

	if bufnr('') != l:originalBufNr
	    bwipe!  " A scratch buffer has already been opened; remove it.
	endif

	return 0
    endtry
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
