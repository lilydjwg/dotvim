" ingo/plugin/cmdcomplete/dirforaction.vim: Define custom command to complete files from a specified directory.
"
" DESCRIPTION:
"   In GVIM, one can define a menu item which uses browse() in combination with
"   an Ex command to open a file browser dialog in a particular directory, lets
"   the user select a file, and then uses that file for a predefined Ex command.
"   This script provides a function to define similar custom commands for use
"   without a GUI file selector, relying instead on custom command completion.
"
" EXAMPLE:
"   Define a command :BrowseTemp that edits a text file from the system TEMP
"   directory. >
"	call ingo#plugin#cmdcomplete#dirforaction#setup(
"	\   '',
"	\   'BrowseTemp',
"	\   'edit',
"	\   (exists('$TEMP') ? $TEMP : '/tmp'),
"	\   '*.txt',
"	\   '',
"	\   ''
"	\)
"   You can then use the new command with file completion:
"	:BrowseTemp f<Tab> -> :BrowseTemp foo.txt
"
" Copyright: (C) 2009-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:RemoveDirspec( filespec, dirspecs )
    for l:dirspec in a:dirspecs
	if strpart(a:filespec, 0, strlen(l:dirspec)) ==# l:dirspec
	    return strpart(a:filespec, strlen(l:dirspec))
	endif
    endfor
    return a:filespec
endfunction
function! s:ResolveDirspecs( dirspecs, ... )
    let l:dirspecs = (type(a:dirspecs) == type(function('tr')) ? call(a:dirspecs, []) : a:dirspecs)
    if a:0 && type(l:dirspecs) == type([])
	if len(l:dirspecs) > 1
	    " Iterate over all dirspecs to find the first containing a:filespec.
	    for l:dirspec in l:dirspecs
		if ! empty(ingo#compat#glob(ingo#fs#path#Combine(l:dirspec, a:1), 0, 1))
		    return l:dirspec
		endif
	    endfor
	endif
	return l:dirspecs[0]    " This is also the fallback if a:filespec wasn't found in any of a:dirspecs.
    else
	return l:dirspecs
    endif
endfunction
function! s:ResolveDirspecsToList( dirspecs ) abort
    try
	return ingo#list#Make(s:ResolveDirspecs(a:dirspecs))
    catch /^Vim\%((\a\+)\)\=:E/
	throw ingo#msg#MsgFromVimException()   " Don't swallow Vimscript errors.
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#msg#VimExceptionMsg()        " Errors from :echoerr.
    catch
	call ingo#msg#ErrorMsg(v:exception)
	sleep 1 " Otherwise, the error isn't visible from inside the command-line completion function.
	return []
    endtry
endfunction
function! s:CompleteFiles( isReturnRawFilespecs, dirspecs, browsefilter, wildignore, isIncludeSubdirs, isAllowOtherDirs, CompleteFunctionHook, argLead )
    let l:dirspecs = s:ResolveDirspecsToList(a:dirspecs)
    let l:browsefilter = (empty(a:browsefilter) ? ['*'] : ingo#list#Make(a:browsefilter))
    let l:save_wildignore = &wildignore
    if type(a:wildignore) == type('')
	let &wildignore = a:wildignore
    endif
    try
	let l:filespecs = []
	let l:resolvedDirspecs = []
	let l:sourceCnt = 0
	let l:hasAbsoluteArgLead = (! empty(a:argLead) && ingo#fs#path#IsAbsolute(a:argLead))
	let l:isUpwards = 0

	if l:hasAbsoluteArgLead
	    if a:isAllowOtherDirs
		" As we have an absolute arglead, we do not need (in fact: must
		" not use) the provided a:dirspecs. If we replace those with a
		" single empty one, the logic below will do exactly what we
		" need, as it concatenates dirspec and arglead.
		let l:dirspecs = ['']
	    else
		return []
	    endif
	elseif ! empty(a:argLead)
	    let l:isUpwards = ingo#fs#path#IsUpwards(a:argLead)
	    if l:isUpwards
		if a:isAllowOtherDirs
		    " The upwards arglead will combine just fine with the a:dirspecs
		    " (which have a trailing path separator).
		else
		    return []
		endif
	    elseif ingo#fs#path#IsPath(a:argLead) && ! a:isIncludeSubdirs
		return []
	    endif
	endif

	for l:dirspec in l:dirspecs
	    if a:isIncludeSubdirs || l:hasAbsoluteArgLead || l:isUpwards
		" If the l:dirspec itself contains wildcards, there may be multiple
		" matches.
		let l:resolvedDirspecs += ingo#compat#glob(l:dirspec, 0, 1)

		" If there is a browsefilter, we need to add all directories
		" separately, as most of them probably have been filtered away by
		" the (file-based) a:browsefilter.
		if ! empty(a:browsefilter)
		    let l:dirspecWildcard = l:dirspec . a:argLead . '*' . ingo#fs#path#Separator()
		    let l:filespecs += ingo#compat#glob(l:dirspecWildcard, 0, 1)
		    let l:sourceCnt += 1
		endif
	    endif

	    for l:filter in l:browsefilter
		let l:filespecWildcard = l:dirspec . a:argLead . l:filter
		let l:filespecs += ingo#compat#glob(l:filespecWildcard, 0, 1)
		let l:sourceCnt += 1
	    endfor
	endfor

	if a:isIncludeSubdirs || l:hasAbsoluteArgLead || l:isUpwards
	    if empty(a:browsefilter)
		" glob() doesn't add a trailing path separator on directories
		" unless the glob pattern has one at the end. Append the path
		" separator here to be consistent with the alternative block
		" above, the built-in completion, and because it makes sense to
		" show the path separator, because then autocompletion of the
		" directory contents can quickly be continued.
		call map(l:filespecs, 'isdirectory(v:val) ? v:val . ingo#fs#path#Separator() : v:val')
	    endif

	    if ! empty(a:CompleteFunctionHook)
		let l:filespecs = call(a:CompleteFunctionHook, [l:filespecs])
	    endif

	    if ! a:isReturnRawFilespecs
		call map(l:filespecs, 'ingo#compat#fnameescape(s:RemoveDirspec(v:val, l:resolvedDirspecs))')
	    endif
	else
	    call filter(l:filespecs, '! isdirectory(v:val)')

	    if ! empty(a:CompleteFunctionHook)
		let l:filespecs = call(a:CompleteFunctionHook, [l:filespecs])
	    endif

	    if ! a:isReturnRawFilespecs
		call map(l:filespecs, 'ingo#compat#fnameescape(fnamemodify(v:val, ":t"))')
	    endif
	endif

	if a:argLead =~# '^\.\{1,2}$' && ! a:isAllowOtherDirs
	    " The globbing would include "../", but this isn't allowed here.
	    " Remove it.
	    call filter(l:filespecs, '! ingo#fs#path#IsUpwards(v:val)')
	endif

	if l:sourceCnt > 1
	    call s:BuildSuffixesExpr()
	    return ingo#compat#uniq(sort(l:filespecs, 's:SuffixesSort')) " Maintain lower priority of 'suffixes' while sorting.
	else
	    return l:filespecs
	endif
    finally
	let &wildignore = l:save_wildignore
    endtry
endfunction
function! s:CompleteDirectories( isReturnRawFilespecs, dirspecs, browsefilter, wildignore, isIncludeSubdirs, isAllowOtherDirs, CompleteFunctionHook, argLead )
    if ! a:isIncludeSubdirs && ! a:isAllowOtherDirs
	return []   " No completion possible; only files from a:dirspec itself.
    endif

    let l:filespecs = s:CompleteFiles(1, a:dirspecs, a:browsefilter, a:wildignore, a:isIncludeSubdirs, a:isAllowOtherDirs, a:CompleteFunctionHook, a:argLead)
    call filter(l:filespecs, 'isdirectory(v:val)')

    if ! a:isReturnRawFilespecs
	let l:dirspecs = s:ResolveDirspecsToList(a:dirspecs)
	let l:resolvedDirspecs = ingo#collections#Flatten1(map(copy(l:dirspecs), 'ingo#compat#glob(v:val, 0, 1)'))
	call map(l:filespecs, 'ingo#compat#fnameescape(s:RemoveDirspec(v:val, l:resolvedDirspecs))')
    endif
    return l:filespecs
endfunction
function! s:BuildSuffixesExpr()
    let s:suffixesExpr =
    \   '\V\%(' .
    \   join(
    \       map(
    \           split(&suffixes,  '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\%(, *\|\ze\.\)'),
    \           'ingo#escape#Unescape(v:val, ".,")'
    \       ),
    \       '\|'
    \   ) .
    \   '\)\$'
endfunction
function! s:IsSuffix( caseSigil, filespec )
    execute 'return (a:filespec =~' . a:caseSigil . ' s:suffixesExpr)'
endfunction
function! s:SuffixesSort( f1, f2 )
    let l:caseSigil = (ingo#os#IsWinOrDos() ? '?' : '#')    " On Windows, the entire globbing is (usually) case-insensitive.

    execute 'let l:isEqual = a:f1 ==' . l:caseSigil . ' a:f2'
    if l:isEqual
	return 0
    endif

    let l:isSuffix1 = s:IsSuffix(l:caseSigil, a:f1)
    let l:isSuffix2 = s:IsSuffix(l:caseSigil, a:f2)

    if l:isSuffix1 == l:isSuffix2
	execute 'return (a:f1 >' . l:caseSigil . ' a:f2 ? 1 : -1)'
    else
	return (l:isSuffix1 ? 1 : -1)
    endif
endfunction

function! s:Command( isBang, mods, Action, PostAction, isAllowOtherDirs, DefaultFilename, FilenameProcessingFunction, FilespecProcessingFunction, dirspecs, filename )
    try
"****Dechomsg '****' a:isBang a:mods string(a:Action) string(a:PostAction) a:isAllowOtherDirs string(a:DefaultFilename) string(a:FilenameProcessingFunction) string(a:FilespecProcessingFunction) string(a:dirspecs) string(a:filename)

	" Detach any file options or commands for assembling the filespec.
	let [l:fileOptionsAndCommands, l:filename] = ingo#cmdargs#file#FilterEscapedFileOptionsAndCommands(a:filename)
"****D echomsg '****' string(l:filename) string(l:fileOptionsAndCommands)
	" Set up a context object so that Funcrefs can have access to the
	" information whether <bang> was given.
	let g:IngoLibrary_CmdCompleteDirForAction_Context = { 'bang': a:isBang, 'mods': a:mods }

	" l:filename comes from the custom command, and must be taken as is (the
	" custom completion will have already escaped the completion).
	" All other filespec fragments still need escaping.

	if empty(l:filename)
	    if type(a:DefaultFilename) == 2
		let l:unescapedFilename = call(a:DefaultFilename, [s:ResolveDirspecs(a:dirspecs)])
	    elseif a:DefaultFilename ==# '%'
		let l:unescapedFilename = expand('%:t')
	    else
		let l:unescapedFilename = a:DefaultFilename
	    endif
	    let l:filename = ingo#compat#fnameescape(l:unescapedFilename)
	else
	    let l:unescapedFilename = ingo#escape#file#fnameunescape(l:filename)
	endif

	let l:isAbsoluteFilename = ingo#fs#path#IsAbsolute(l:unescapedFilename)
	if (l:isAbsoluteFilename || ingo#fs#path#IsUpwards(l:filename)) && ! a:isAllowOtherDirs
	    " The passed (must be typed, as the completion wouldn't offer these)
	    " filename refers to files outside a:dirspecs, but this is not
	    " allowed by the client.
	    call ingo#err#Set(printf('Locations outside the base director%s are not allowed', len(a:dirspecs) == 1 ? 'y' : 'ies'))
	    return 0
	endif

	let l:dirspec = (l:isAbsoluteFilename ? '' : s:ResolveDirspecs(a:dirspecs, l:unescapedFilename))

	if ! empty(a:FilenameProcessingFunction)
	    let l:processedFilename = call(a:FilenameProcessingFunction, [l:filename, l:fileOptionsAndCommands])
	    if empty(l:processedFilename) || empty(l:processedFilename[0])
		return 1
	    else
		let [l:filename, l:fileOptionsAndCommands] = l:processedFilename
	    endif
	endif
	if ! empty(a:FilespecProcessingFunction)
	    let l:processedFilespec = call(a:FilespecProcessingFunction, [l:dirspec, l:filename, l:fileOptionsAndCommands])
	    if empty(l:processedFilespec) || empty(join(l:processedFilespec[0:1], ''))
		return 1
	    else
		let [l:dirspec, l:filename, l:fileOptionsAndCommands] = l:processedFilespec
	    endif
	endif

	let l:expandExpr = '\%(^\|\s\zs\|"\)%\%(:\S\+\)\?\%("\|\ze\s\|$\)'
	if type(a:Action) == 2
	    call call(a:Action, [ingo#compat#fnameescape(l:dirspec), l:filename, l:fileOptionsAndCommands])
	elseif a:Action =~# l:expandExpr
	    " Similar to 'makeprg', the location of the inserted filespec can be
	    " controlled via "%".
	    let l:escapedFilespec = ingo#compat#fnameescape(l:dirspec) . l:filename
	    let l:unescapedFilespec = l:dirspec . ingo#escape#file#fnameunescape(l:filename)
	    let l:action = substitute(a:Action, l:expandExpr, '\=s:Expand(submatch(0), l:fileOptionsAndCommands, l:escapedFilespec, l:unescapedFilespec)', 'g')
	    execute l:action
	else
	    execute a:Action l:fileOptionsAndCommands . ingo#compat#fnameescape(l:dirspec) . l:filename
	endif

	if ! empty(a:PostAction)
	    if type(a:PostAction) == 2
		call call(a:PostAction, [])
	    else
		execute a:PostAction
	    endif
	endif
	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    catch
	call ingo#err#Set(v:exception)
	return 0
    finally
	unlet! g:IngoLibrary_CmdCompleteDirForAction_Context
    endtry
endfunction
function! s:Expand( expr, fileOptionsAndCommands, escapedFilespec, unescapedFilespec )
    if a:expr ==# '%:+'
	return a:fileOptionsAndCommands
    elseif a:expr ==# '"%"'
	return string(a:unescapedFilespec)
    elseif a:expr =~# '^"%:.*"$'
	return string(fnamemodify(a:unescapedFilespec, a:expr[2:-2]))
    elseif a:expr ==# '%'
	return a:escapedFilespec
    elseif a:expr =~# '^%:.*$'
	return fnamemodify(a:escapedFilespec, a:expr[1:])
    else
	return a:expr
    endif
endfunction

let s:count = 0
function! ingo#plugin#cmdcomplete#dirforaction#setup( command, dirspecs, parameters )
"*******************************************************************************
"* PURPOSE:
"   Define a custom a:command that takes an (potentially optional) single file
"   argument and executes the a:parameters.action command or Funcref with it.
"   The command will have a custom completion that completes files from
"   a:dirspecs, with a:parameters.browsefilter applied and
"   a:parameters.wildignore extensions filtered out. The custom completion will
"   return the list of file (/ directory / subdir path) names found. Those
"   should be interpreted relative to (and thus do not include) a:dirspecs.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Defines custom a:command that takes one filename argument, which will have
"   filename completion from a:dirspecs. Unless a:parameters.defaultFilename is
"   provided, the filename argument is mandatory.
"* INPUTS:
"   a:command   Name of the custom command to be defined.
"   a:dirspecs	Directory/ies (including trailing path separator!) from which
"		files will be completed. If empty, any filespec will be
"		accepted; this automatically sets a:parameters.isIncludeSubdirs
"		and a:parameters.isAllowOtherDirs.
"		Or Funcref to a function that takes no arguments and returns the
"		dirspec(s).
"
"   a:parameters.commandAttributes
"	    Optional :command {attr}, e.g. <buffer>, -bang, -range.
"	    Funcrefs can access the <bang> via
"	    g:IngoLibrary_CmdCompleteDirForAction_Context.bang.
"   a:parameters.action
"	    Ex command (e.g. 'edit', '<line1>read') to be invoked with the
"	    completed filespec. Default is the :drop / :Drop command.
"	    Or Funcref to a function that takes the dirspec, filename (both
"	    already escaped for use in an Ex command), and potential
"	    fileOptionsAndCommands (e.g. ++enc=latin1 +set\ ft=c) and performs
"	    the action itself. Throw an error message if needed.
"   a:parameters.postAction
"	    Ex command to be invoked after the file has been opened via
"	    a:parameters.action. Default empty.
"	    Or Funcref to a function that takes no arguments and performs the
"	    post actions itself. Throw an error message if needed.
"   a:parameters.browsefilter
"	    File wildcard (e.g. '*.txt') used for filtering the files in
"	    a:dirspecs. Multiple can be specified as a List. Default is empty
"	    string to include all (non-hidden) files. Does not apply to
"	    subdirectory names (but applies to the files inside the
"	    subdirectories).
"   a:parameters.wildignore
"	    Comma-separated list of file extensions to be ignored. This is
"	    similar to a:parameters.browsefilter, but with inverted semantics,
"	    only file extensions, and multiple possible values. Use empty string
"	    to disable and pass 0 (the default) to keep the current global
"	    'wildignore' setting.
"   a:parameters.isIncludeSubdirs
"	    Flag whether subdirectories will be included in the completion
"	    matches. By default, only files in a:dirspecs itself will be offered.
"   a:parameters.isAllowOtherDirs
"	    Flag whether directories outside of a:dirspecs (using ../ or an
"	    absolute path) can be passed (and are offered by the completion),
"	    too. Disallowed by default.
"   a:parameters.defaultFilename
"	    If specified, the command will not require the filename argument,
"	    and default to this filename if none is specified.
"	    The special value "%" will be replaced with the current buffer's
"	    filename.
"	    Or Funcref to a function that takes the [List of] dirspec[s] and
"	    returns the filename. Throw an error message if needed.
"	    This can resolve to an empty string; however, then your
"	    a:parameters.action has to cope with that (e.g. by putting up a
"	    browse dialog).
"   a:parameters.overrideCompleteFunction
"	    If not empty, will be used as the :command -complete=customlist,...
"	    completion function name. This hook can be used to manipulate the
"	    completion list. This overriding completion function probably will
"	    still invoke the generated custom completion function, which is
"	    therefore returned from this setup function.
"   a:parameters.completeFunctionHook
"           Funcref that gets a List of all (still unshortened) filespecs
"           generated by the default completion and can filter or augment it.
"   a:parameters.FilenameProcessingFunction
"	    If not empty, will be passed the completed (or default) filespec and
"	    potential fileOptionsAndCommands, and expects a similar List of
"	    [filespec, fileOptionsAndCommands] in return. (Or an empty List,
"	    which will abort the command.)
"   a:parameters.FilespecProcessingFunction
"	    If not empty, will be passed the (not escaped) dirspec, the
"	    completed (or default) filespec, and the potential
"	    fileOptionsAndCommands, and expects a similar List of [dirspec,
"	    filespec, fileOptionsAndCommands] in return. (Or an empty List,
"	    which will abort the command.)
"
"* RETURN VALUES:
"   Name of the generated custom completion function.
"*******************************************************************************
    let l:commandAttributes = get(a:parameters, 'commandAttributes', '')
    let l:Action = get(a:parameters, 'action', ((exists(':Drop') == 2) ? 'Drop' : 'drop'))
    let l:PostAction = get(a:parameters, 'postAction', '')
    let l:browsefilter = get(a:parameters, 'browsefilter', '')
    let l:wildignore = get(a:parameters, 'wildignore', 0)
    let l:isNoDirspec = empty(a:dirspecs)
    let l:isIncludeSubdirs = get(a:parameters, 'isIncludeSubdirs', l:isNoDirspec)
    let l:isAllowOtherDirs = get(a:parameters, 'isAllowOtherDirs', l:isNoDirspec)
    let l:DefaultFilename = get(a:parameters, 'defaultFilename', '')
    let l:FilenameProcessingFunction = get(a:parameters, 'FilenameProcessingFunction', '')
    let l:FilespecProcessingFunction = get(a:parameters, 'FilespecProcessingFunction', '')

    let s:count += 1
    let l:generatedCompleteFunctionName = 'IngoLibrary_CmdCompleteDirForAction' . s:count
    let l:completeFunctionName = get(a:parameters, 'overrideCompleteFunction', l:generatedCompleteFunctionName)
    let l:CompleteFunctionHook = get(a:parameters, 'completeFunctionHook', '')
    let l:completeStrategy = (type(l:Action) == type('') && l:Action ==# 'chdir' ? 's:CompleteDirectories' : 's:CompleteFiles')
    execute
    \	printf("function! %s(ArgLead, CmdLine, CursorPos)\n", l:generatedCompleteFunctionName) .
    \	printf("    return %s(0, %s, %s, %s, %d, %d, %s, a:ArgLead)\n",
    \       l:completeStrategy,
    \	    string(a:dirspecs), string(l:browsefilter), string(l:wildignore), l:isIncludeSubdirs, l:isAllowOtherDirs, string(l:CompleteFunctionHook)
    \	) .    'endfunction'

    execute printf('command! -bar -nargs=%s -complete=customlist,%s %s %s if ! <SID>Command(<bang>0, ingo#compat#command#Mods(''<mods>''), %s, %s, %d, %s, %s, %s, %s, <q-args>) | echoerr ingo#err#Get() | endif',
    \	(has_key(a:parameters, 'defaultFilename') ? '?' : '1'),
    \   l:completeFunctionName,
    \   l:commandAttributes,
    \   a:command,
    \   (l:commandAttributes =~# '-range=-1' && l:Action =~# '^<line[12]>,\@!' ?
    \       '(<count> == -1 ? <line1> : <line2>) . ' . string(l:Action[7:]) :
    \	    string(l:Action)
    \   ),
    \   string(l:PostAction),
    \   l:isAllowOtherDirs,
    \   string(l:DefaultFilename),
    \	string(l:FilenameProcessingFunction),
    \	string(l:FilespecProcessingFunction),
    \   string(a:dirspecs),
    \)

    return l:generatedCompleteFunctionName
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
