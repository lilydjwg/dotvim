" ingo/buffer/generate.vim: Functions for creating buffers.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/escape/file.vim autoload script
"   - ingo/fs/path.vim autoload script
"
" Copyright: (C) 2009-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#buffer#generate#NextBracketedFilename( filespec, template )
"******************************************************************************
"* PURPOSE:
"   Based on the current format of a:filespec, return a successor according to
"   a:template. The sequence is:
"	1. name [template]
"	2. name [template1]
"	3. name [template2]
"	4. ...
"   The "name" part may be omitted.
"   This does not check for actual occurrences in loaded buffers, etc.; it just
"   performs text manipulation!
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filename on which to base the result.
"   a:template  Identifier to be used inside the bracketed counted addendum.
"* RETURN VALUES:
"   filename
"******************************************************************************
    let l:templateExpr = '\V\C'. escape(a:template, '\') . '\m'
    if a:filespec !~# '\%(^\| \)\[' . l:templateExpr . ' \?\d*\]$'
	return a:filespec . (empty(a:filespec) ? '' : ' ') . '['. a:template . ']'
    elseif a:filespec !~# '\%(^\| \)\[' . l:templateExpr . ' \?\d\+\]$'
	return substitute(a:filespec, '\]$', '1]', '')
    else
	let l:number = matchstr(a:filespec, '\%(^\| \)\[' . l:templateExpr . ' \?\zs\d\+\ze\]$')
	return substitute(a:filespec, '\d\+\]$', (l:number + 1) . ']', '')
    endif
endfunction
function! s:Bufnr( dirspec, filename, isFile )
    if empty(a:dirspec) && ! a:isFile
	" This buffer does not behave like a file and is not tethered to a
	" particular directory; there should be only one buffer with this name
	" in the Vim session.
	" Do a partial search for the buffer name matching any file name in any
	" directory.
	return bufnr(ingo#escape#file#bufnameescape(a:filename, 1, 0))
    else
	return bufnr(
	\   ingo#escape#file#bufnameescape(
	\	fnamemodify(
	\	    ingo#fs#path#Combine(a:dirspec, a:filename),
	\	    '%:p'
	\	)
	\   )
	\)
    endif
endfunction
function! ingo#buffer#generate#GetUnusedBracketedFilename( dirspec, baseFilename, isFile, template )
"******************************************************************************
"* PURPOSE:
"   Determine the next available bracketed filename that does not exist as a Vim
"   buffer yet.
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:dirspec   Working directory for the buffer. Pass empty string to maintain
"		the current CWD as-is.
"   a:baseFilename  Filename to base the bracketed filename on; can be empty if
"		    you don't want any prefix before the brackets.
"   a:isFile    Flag whether the buffer should behave like a file (i.e. adapt to
"		changes in the global CWD), or not. If false and a:dirspec is
"		empty, there will be only one buffer with the same filename,
"		regardless of the buffer's directory path.
"   a:template  Identifier to be used inside the bracketed counted addendum.
"* RETURN VALUES:
"   filename
"******************************************************************************
    let l:bracketedFilename = a:baseFilename
    while 1
	let l:bracketedFilename = ingo#buffer#generate#NextBracketedFilename(l:bracketedFilename, a:template)
	if s:Bufnr(a:dirspec, l:bracketedFilename, a:isFile) == -1
	    return l:bracketedFilename
	endif
    endwhile
endfunction
function! s:ChangeDir( dirspec )
    if empty( a:dirspec )
	return
    endif
    execute 'lchdir' ingo#compat#fnameescape(a:dirspec)
endfunction
function! ingo#buffer#generate#BufType( isFile )
    return (a:isFile ? 'nowrite' : 'nofile')
endfunction
function! ingo#buffer#generate#Create( dirspec, filename, isFile, ContentsCommand, windowOpenCommand, NextFilenameFuncref )
"*******************************************************************************
"* PURPOSE:
"   Create (or re-use an existing) buffer (i.e. doesn't correspond to a file on
"   disk, but can be saved as such).
"   To keep the buffer (and create a new buffer on the next invocation), rename
"   the current buffer via ':file <newname>', or make it a normal buffer via
"   ':setl buftype='.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates or opens buffer and loads it in a window (as specified by
"   a:windowOpenCommand) and activates that window.
"* INPUTS:
"   a:dirspec	        Local working directory for the buffer (important for :!
"			commands). Pass empty string to maintain the current CWD
"			as-is. Pass '.' to maintain the CWD but also fix it via
"			:lcd. (Attention: ':set autochdir' will reset any CWD
"			once the current window is left!)
"			Pass the getcwd() output if maintaining the current CWD
"			is important for a:ContentsCommand.
"   a:filename	        The name for the buffer, so it can be saved via either
"			:w! or :w <newname>.
"   a:isFile	        Flag whether the buffer should behave like a file (i.e.
"			adapt to changes in the global CWD), or not. If false
"			and a:dirspec is empty, there will be only one buffer
"			with the same a:filename, regardless of the buffer's
"			directory path.
"   a:ContentsCommand	Ex command(s) to populate the buffer, e.g.
"			":1read myfile". Use ":1read" so that the first empty
"			line will be kept (it is deleted automatically), and
"			there will be no trailing empty line.
"			Pass empty string if you want to populate the buffer
"			yourself.
"			Pass a Funcref to build the buffer contents with it.
"			Pass a List of lines to set the buffer contents directly
"			to the lines.
"   a:windowOpenCommand	Ex command to open the window, e.g. ":vnew" or
"			":topleft new".
"   a:NextFilenameFuncref   Funcref that is invoked (with a:filename) to
"			    generate file names for the generated buffer should
"			    the desired one (a:filename) already exist but not
"			    be a generated buffer.
"* RETURN VALUES:
"   Indicator whether the buffer has been opened:
"   0	Failed to open buffer.
"   1	Already in buffer window.
"   2	Jumped to open buffer window.
"   3	Loaded existing buffer in new window.
"   4	Created buffer in new window.
"   Note: To handle errors caused by a:ContentsCommand, you need to put this
"   method call into a try..catch block and :bwipe the buffer when an exception
"   is thrown.
"*******************************************************************************
    let l:currentWinNr = winnr()
    let l:status = 0

    let l:bufnr = s:Bufnr(a:dirspec, a:filename, a:isFile)
    let l:winnr = bufwinnr(l:bufnr)
"****D echomsg '**** bufnr=' . l:bufnr 'winnr=' . l:winnr
    if l:winnr == -1
	if l:bufnr == -1
	    execute a:windowOpenCommand
	    " Note: The directory must already be changed here so that the :file
	    " command can set the correct buffer filespec.
	    call s:ChangeDir(a:dirspec)
	    execute 'silent keepalt file' ingo#compat#fnameescape(a:filename)
	    let l:status = 4
	elseif getbufvar(l:bufnr, '&buftype') ==# ingo#buffer#generate#BufType(a:isFile)
	    execute a:windowOpenCommand
	    execute l:bufnr . 'buffer'
	    let l:status = 3
	else
	    " A buffer with the filespec is already loaded, but it contains an
	    " existing file, not a generated file. As we don't want to jump to
	    " this existing file, try again with the next filename.
	    return ingo#buffer#generate#Create(a:dirspec, call(a:NextFilenameFuncref, [a:filename]), a:isFile, a:ContentsCommand, a:windowOpenCommand, a:NextFilenameFuncref)
	endif
    else
	if getbufvar(l:bufnr, '&buftype') !=# ingo#buffer#generate#BufType(a:isFile)
	    " A window with the filespec is already visible, but its buffer
	    " contains an existing file, not a generated file. As we don't want
	    " to jump to this existing file, try again with the next filename.
	    return ingo#buffer#generate#Create(a:dirspec, call(a:NextFilenameFuncref, [a:filename]), a:isFile, a:ContentsCommand, a:windowOpenCommand, a:NextFilenameFuncref)
	elseif l:winnr == l:currentWinNr
	    let l:status = 1
	else
	    execute l:winnr . 'wincmd w'
	    let l:status = 2
	endif
    endif

    call s:ChangeDir(a:dirspec)
    setlocal noreadonly
    silent %delete _
    " Note: ':silent' to suppress the "--No lines in buffer--" message.

    if ! empty(a:ContentsCommand)
	if type(a:ContentsCommand) == type([])
	    call setline(1, a:ContentsCommand)
	    call cursor(1, 1)
	    call ingo#change#Set([1, 1], [line('$'), 1])
	elseif type(a:ContentsCommand) == type(function('tr'))
	    call call(a:ContentsCommand, [])
	else
	    execute a:ContentsCommand
	    " ^ Keeps the existing line at the top of the buffer, if :1{cmd} is used.
	    " v Deletes it.
	    if empty(getline(1))
		let l:save_cursor = getpos('.')
		    silent 1delete _    " Note: ':silent' to suppress deletion message if ':set report=0'.
		call cursor(l:save_cursor[1] - 1, l:save_cursor[2])
	    endif
	endif

    endif

    return l:status
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
