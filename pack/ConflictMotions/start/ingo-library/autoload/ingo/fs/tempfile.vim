" ingo/fs/tempfile.vim: Functions for creating temporary files.
"
" DEPENDENCIES:
"   - ingo/fs/path.vim autoload script
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2012-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.024.003	22-Apr-2015	Add optional a:templateForNewBuffer argument to
"				ingo#fs#tempfile#Make() and ensure (by default)
"				that the temp file isn't yet loaded in a Vim
"				buffer (which would generate "E139: file is
"				loaded in another buffer" on the usual :write,
"				:saveas commands).
"   1.013.002	13-Sep-2013	Use operating system detection functions from
"				ingo/os.vim.
"   1.007.001	01-Jun-2013	file creation from ingofile.vim

function! ingo#fs#tempfile#Make( filename, ... )
"******************************************************************************
"* PURPOSE:
"   Generate a filespec in a temporary location. Unlike the built-in
"   |tempname()| function, this allows specification of the file name (which can
"   be beneficial if you want to open the temp file in a Vim buffer for the user
"   to use). Otherwise, prefer tempname().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filename	filename of the temp file. If empty, the function will just
"		return the name of a writable temp directory, with trailing path
"		separator.
"   a:templateForNewBuffer  When the temp filespec is already loaded in a
"			    buffer, a counter is appended according to the
"			    passed printf()-specification (default: "-%d"). If
"			    empty, will not generate a unique filespec and
"			    instead return an empty string in case the filespec
"			    is already loaded.
"* RETURN VALUES:
"   Temp filespec.
"******************************************************************************
    let l:tempdirs = [fnamemodify(tempname(), ':t')]	" The built-in function should know best about a good temp dir.
    let l:tempdirs += [$TEMP, $TMP] " Also check common environment variables.

    " And finally try operating system-specific places.
    if ingo#os#IsWinOrDos()
	let l:tempdirs += [$HOMEDRIVE . $HOMEPATH, $WINDIR . '\Temp', 'C:\temp']
    else
	let l:tempdirs += [$TMPDIR, $HOME . '/tmp', '/tmp']
    endif

    for l:tempdir in l:tempdirs
	if filewritable(l:tempdir) == 2
	    let l:filespec = ingo#fs#path#Combine(l:tempdir, a:filename)
	    if empty(a:filename)
		return l:filespec   " Just return the temp dirspec (with appended path separator).
	    elseif bufnr(ingo#escape#file#bufnameescape(l:filespec)) == -1
		return l:filespec   " Not loaded in buffer yet.
	    elseif a:0 && empty(a:1)
		return ''   " Signal that it's already loaded.
	    else
		let l:cnt = 1
		while 1
		    let l:appendedFilespec = l:filespec . printf((a:0 ? a:1 : '-%d'), l:cnt)
		    if bufnr(ingo#escape#file#bufnameescape(l:appendedFilespec)) == -1
			return l:appendedFilespec   " Found a unique one.
		    endif
		    let l:cnt += 1  " Keep trying.
		endwhile
	    endif
	endif
    endfor
    throw 'MakeTempfile: No writable temp directory found!'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
