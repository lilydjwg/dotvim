" ingo/buffer/scratch.vim: Functions for creating scratch buffers.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/escape/file.vim autoload script
"   - ingo/fs/path.vim autoload script
"
" Copyright: (C) 2009-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.012.021	08-Aug-2013	Move escapings.vim into ingo-library.
"   1.010.020	08-Jul-2013	Move into ingo-library.
"	019	11-Jun-2013	Move ingobuffer#ExecuteIn...() and
"				ingobuffer#CallIn...() to ingo/buffer/temp.vim
"				and ingo/buffer/visible.vim.
"	018	01-Jun-2013	Move ingofile.vim into ingo-library.
"	017	19-Feb-2013	Factor out ingobuffer#SetScratchBuffer().
"	016	18-Feb-2013	Add ingobuffer#GetUnusedBracketedFilename().
"	015	18-May-2012	Move ingobuffer#CombineToFilespec() and
"				ingobuffer#MakeTempfile() to ingofile.vim
"				autoload script.
"	014	26-Mar-2012	Add ingobuffer#IsEmptyBuffer(), copied from
"				ingotemplates.vim.
"	013	26-Oct-2011	Also switch algorithm for
"				ingobuffer#ExecuteInVisibleBuffer(), because
"				:hide may destroy the current buffer when
"				'bufhidden' is set. (This happened in the blame
"				buffer of vcscommand.vim).
"	012	03-Oct-2011	Switch algorithm for
"				ingobuffer#ExecuteInTempBuffer() from switching
"				buffers to new split buffer, since the former
"				had a noticable delay when in a long Vimscript
"				file, due to re-sync of syntax highlighting.
"	011	01-Oct-2011	Factor out more generic
"				ingobuffer#NextBracketedFilename().
"	010	27-Sep-2011	Add ingobuffer#ExecuteInTempBuffer(), and
"				ingobuffer#CallInTempBuffer().
"				Also implement ingobuffer#CallInVisibleBuffer()
"				in the same style.
"	009	09-Jul-2011	Have somehow written ingobuffer#MakeTempfile()
"				without knowledge of the built-in tempname().
"				Now use that as the primary source of a temp
"				directory, and only use the other locations as
"				(probably unnecessary) fallbacks.
"	008	12-Apr-2011	Add ingobuffer#ExecuteInVisibleBuffer() for
"				:AutoSave command.
"	007	31-Mar-2011	ingobuffer#MakeScratchBuffer() only deletes the
"				first line in the scratch buffer if it is
"				actually empty.
"				FIX: Need to check the buftype also when a
"				window is visible that shows a buffer with the
"				scratch filename. Otherwise, a buffer containing
"				a normal file may be re-used as a scratch
"				buffer.
"				Also allow scratch buffer names like
"				"[Messages]", not just "Messages [Scratch]" in
"				ingobuffer#NextScratchFilename().
"				Minor: 'buftype' can only contain one particular
"				word, change regexp-match to exact match.
"	006	17-Jan-2011	Added $TMPDIR to ingobuffer#MakeTempfile().
"	005	02-Mar-2010	ENH: ingobuffer#CombineToFilespec() allows
"				multiple filenames and passing in a single list
"				of filespec fragments. Improved detection of
"				desired path separator and falling back to
"				system default based on 'shellslash' setting.
"	004	15-Oct-2009	ENH: ingobuffer#MakeScratchBuffer() now allows
"				to omit (via empty string) the a:scratchCommand
"				Ex command, and will then keep the scratch
"				buffer writable.
"	003	04-Sep-2009	ENH: If a:scratchIsFile is false and
"				a:scratchDirspec is empty, there will be only
"				one scratch buffer with the same
"				a:scratchFilename, regardless of the scratch
"				buffer's directory path. This also fixes Vim
"				errors on the :file command when s:Bufnr() has
"				determined that there is no existing buffer,
"				when in fact there is.
"				Replaced ':normal ...dd' with :delete, and not
"				clobbering the unnamed register any more.
"	002	01-Sep-2009	Added ingobuffer#MakeTempfile().
"	001	05-Jan-2009	file creation

function! ingo#buffer#scratch#NextBracketedFilename( filespec, template )
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
function! ingo#buffer#scratch#NextFilename( filespec )
    return ingo#buffer#scratch#NextBracketedFilename(a:filespec, 'Scratch')
endfunction
function! s:Bufnr( dirspec, filename, isFile )
    if empty(a:dirspec) && ! a:isFile
	" This scratch buffer does not behave like a file and is not tethered to
	" a particular directory; there should be only one scratch buffer with
	" this name in the Vim session.
	" Do a partial search for the buffer name matching any file name in any
	" directory.
	return bufnr('/'. ingo#escape#file#bufnameescape(a:filename, 0) . '$')
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
function! ingo#buffer#scratch#GetUnusedBracketedFilename( dirspec, baseFilename, isFile, template )
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
	let l:bracketedFilename = ingo#buffer#scratch#NextBracketedFilename(l:bracketedFilename, a:template)
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
function! s:BufType( scratchIsFile )
    return (a:scratchIsFile ? 'nowrite' : 'nofile')
endfunction
function! ingo#buffer#scratch#Create( scratchDirspec, scratchFilename, scratchIsFile, scratchCommand, windowOpenCommand )
"*******************************************************************************
"* PURPOSE:
"   Create (or re-use an existing) scratch buffer (i.e. doesn't correspond to a
"   file on disk, but can be saved as such).
"   To keep the scratch buffer (and create a new scratch buffer on the next
"   invocation), rename the current scratch buffer via ':file <newname>', or
"   make it a normal buffer via ':setl buftype='.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates or opens scratch buffer and loads it in a window (as specified by
"   a:windowOpenCommand) and activates that window.
"* INPUTS:
"   a:scratchDirspec	Local working directory for the scratch buffer
"			(important for :! scratch commands). Pass empty string
"			to maintain the current CWD as-is. Pass '.' to maintain
"			the CWD but also fix it via :lcd.
"			(Attention: ':set autochdir' will reset any CWD once the
"			current window is left!) Pass the getcwd() output if
"			maintaining the current CWD is important for
"			a:scratchCommand.
"   a:scratchFilename	The name for the scratch buffer, so it can be saved via
"			either :w! or :w <newname>.
"   a:scratchIsFile	Flag whether the scratch buffer should behave like a
"			file (i.e. adapt to changes in the global CWD), or not.
"			If false and a:scratchDirspec is empty, there will be
"			only one scratch buffer with the same a:scratchFilename,
"			regardless of the scratch buffer's directory path.
"   a:scratchCommand	Ex command(s) to populate the scratch buffer, e.g.
"			":1read myfile". Use :1read so that the first empty line
"			will be kept (it is deleted automatically), and there
"			will be no trailing empty line.
"			Pass empty string if you want to populate the scratch
"			buffer yourself.
"   a:windowOpenCommand	Ex command to open the scratch window, e.g. :vnew or
"			:topleft new.
"* RETURN VALUES:
"   Indicator whether the scratch buffer has been opened:
"   0	Failed to open scratch buffer.
"   1	Already in scratch buffer window.
"   2	Jumped to open scratch buffer window.
"   3	Loaded existing scratch buffer in new window.
"   4	Created scratch buffer in new window.
"   Note: To handle errors caused by a:scratchCommand, you need to put this
"   method call into a try..catch block and :close the scratch buffer when an
"   exception is thrown
"*******************************************************************************
    let l:currentWinNr = winnr()
    let l:status = 0

    let l:scratchBufnr = s:Bufnr(a:scratchDirspec, a:scratchFilename, a:scratchIsFile)
    let l:scratchWinnr = bufwinnr(l:scratchBufnr)
"****D echomsg '**** bufnr=' . l:scratchBufnr 'winnr=' . l:scratchWinnr
    if l:scratchWinnr == -1
	if l:scratchBufnr == -1
	    execute a:windowOpenCommand
	    " Note: The directory must already be changed here so that the :file
	    " command can set the correct buffer filespec.
	    call s:ChangeDir(a:scratchDirspec)
	    execute 'silent keepalt file' ingo#compat#fnameescape(a:scratchFilename)
	    let l:status = 4
	elseif getbufvar(l:scratchBufnr, '&buftype') ==# s:BufType(a:scratchIsFile)
	    execute a:windowOpenCommand
	    execute l:scratchBufnr . 'buffer'
	    let l:status = 3
	else
	    " A buffer with the scratch filespec is already loaded, but it
	    " contains an existing file, not a scratch file. As we don't want to
	    " jump to this existing file, try again with the next scratch
	    " filename.
	    return ingo#buffer#scratch#Create(a:scratchDirspec, ingo#buffer#scratch#NextFilename(a:scratchFilename), a:scratchIsFile, a:scratchCommand, a:windowOpenCommand)
	endif
    else
	if getbufvar(l:scratchBufnr, '&buftype') !=# s:BufType(a:scratchIsFile)
	    " A window with the scratch filespec is already visible, but its
	    " buffer contains an existing file, not a scratch file. As we don't
	    " want to jump to this existing file, try again with the next
	    " scratch filename.
	    return ingo#buffer#scratch#Create(a:scratchDirspec, ingo#buffer#scratch#NextFilename(a:scratchFilename), a:scratchIsFile, a:scratchCommand, a:windowOpenCommand)
	elseif l:scratchWinnr == l:currentWinNr
	    let l:status = 1
	else
	    execute l:scratchWinnr . 'wincmd w'
	    let l:status = 2
	endif
    endif

    call s:ChangeDir(a:scratchDirspec)
    setlocal noreadonly
    silent %delete _
    " Note: ':silent' to suppress the "--No lines in buffer--" message.

    if ! empty(a:scratchCommand)
	execute a:scratchCommand
	" ^ Keeps the existing line at the top of the buffer, if :1{cmd} is used.
	" v Deletes it.
	if empty(getline(1)) | silent 1delete _ | endif
	" Note: ':silent' to suppress deletion message if ':set report=0'.

	setlocal readonly
    endif

    call ingo#buffer#scratch#SetLocal(a:scratchIsFile)
    return l:status
endfunction
function! ingo#buffer#scratch#SetLocal( isFile )
    execute 'setlocal buftype=' . s:BufType(a:isFile)
    setlocal bufhidden=wipe nobuflisted noswapfile
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
