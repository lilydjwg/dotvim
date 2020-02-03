" ingo/fs/path.vim: Functions for manipulating a file system path.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/escape/file.vim autoload script
"   - ingo/os.vim autoload script
"   - ingo/fs/path/split.vim autoload script
"
" Copyright: (C) 2012-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#fs#path#Separator()
    return (exists('+shellslash') && ! &shellslash ? '\' : '/')
endfunction

function! ingo#fs#path#Normalize( filespec, ... )
"******************************************************************************
"* PURPOSE:
"   Change all path separators in a:filespec to the passed or the typical format
"   for the current platform.
"   On Windows and Cygwin, also converts between the different D:\ and
"   /cygdrive/d/ notations.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec      Filespec, potentially with mixed / and \ path separators.
"   a:pathSeparator Optional path separator to be used. With the special value
"		    of ":/", normalizes to "/", but keeps a "C:/" drive letter
"		    prefix instead of translating to "/cygdrive/c/".
"* RETURN VALUES:
"   a:filespec with uniform path separators, according to the platform.
"******************************************************************************
    let l:pathSeparator = (a:0 ? (a:1 ==# ':/' ? '/' : a:1) : ingo#fs#path#Separator())
    let l:badSeparator = (l:pathSeparator ==# '/' ? '\' : '/')
    let l:result = tr(a:filespec, l:badSeparator, l:pathSeparator)

    if ingo#os#IsWinOrDos()
	let l:result = substitute(l:result, '^[/\\]cygdrive[/\\]\(\a\)\ze[/\\]', '\u\1:', '')
    elseif ingo#os#IsCygwin() && l:pathSeparator ==# '/' && ! (a:0 && a:1 ==# ':/')
	let l:result = substitute(l:result, '^\(\a\):', '/cygdrive/\l\1', '')
    endif

    return l:result
endfunction
function! ingo#fs#path#Canonicalize( filespec, ... )
"******************************************************************************
"* PURPOSE:
"   Convert a:filespec into a unique, canonical form that other instances can be
"   compared against for equality. Expands to an absolute filespec and may
"   change case. Removes ../ etc. Only resolves shortcuts / symbolic links on
"   demand, as it depends on the use case whether these should be identical or
"   not.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec      Filespec, potentially relative or with mixed / and \ path
"                   separators.
"   a:isResolveLinks    Flag whether to resolve shortcuts / symbolic links, too;
"                       off by default.
"* RETURN VALUES:
"   Absolute a:filespec with uniform path separators and case, according to the
"   platform.
"******************************************************************************
    let l:absoluteFilespec = fnamemodify(a:filespec, ':p')  " Expand to absolute filespec before resolving; as this handles ~/, too.
    let l:simplifiedFilespec = (a:0 && a:1 ? resolve(l:absoluteFilespec) : simplify(l:absoluteFilespec))
    let l:result = ingo#fs#path#Normalize(l:simplifiedFilespec)
    if ingo#fs#path#IsCaseInsensitive(l:result)
	let l:result = tolower(l:result)
    endif
    return l:result
endfunction

function! ingo#fs#path#Combine( first, ... )
"******************************************************************************
"* PURPOSE:
"   Concatenate the passed filespec fragments into a filespec, ensuring that all
"   fragments are combined with proper path separators.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   Either pass a dirspec and one or many filenames:
"	a:dirspec, a:filename [, a:filename2, ...]
"   Or a single list containing all filespec fragments.
"	[a:dirspec, a:filename, ...]
"* RETURN VALUES:
"   Combined filespec.
"******************************************************************************
    if type(a:first) == type([])
	let l:dirspec = a:first[0]
	let l:filenames = a:first[1:]
    else
	let l:dirspec = a:first
	let l:filenames = a:000
    endif

    " Use path separator as exemplified by the passed dirspec.
    if l:dirspec =~# '\' && l:dirspec !~# '/'
	let l:pathSeparator = '\'
    elseif l:dirspec =~# '/'
	let l:pathSeparator = '/'
    else
	" The dirspec doesn't contain a path separator, fall back to the
	" system's default.
	let l:pathSeparator = ingo#fs#path#Separator()
    endif

    let l:filespec = l:dirspec
    for l:filename in l:filenames
	let l:filename = substitute(l:filename, '^[/\\]', '', '')
	let l:filespec .= (l:filespec =~# '^$\|[/\\]$' ? '' : l:pathSeparator) . l:filename
    endfor

    return l:filespec
endfunction

function! ingo#fs#path#IsUncPathRoot( filespec )
    let l:ps = escape(ingo#fs#path#Separator(), '\')
    let l:uncPathPattern = printf('^%s%s[^%s]\+%s[^%s]\+$', l:ps, l:ps, l:ps, l:ps, l:ps)
    return (a:filespec =~# l:uncPathPattern)
endfunction
function! ingo#fs#path#GetRootDir( filespec )
"******************************************************************************
"* PURPOSE:
"   Determine the root directory of a:filespec.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Full path (use |::p| modifier if necessary).
"* RETURN VALUES:
"   Root drive / UNC path / "/".
"******************************************************************************
    if ! ingo#os#IsWinOrDos()
	return '/'
    endif

    let l:dir = a:filespec
    while fnamemodify(l:dir, ':h') !=# l:dir && ! ingo#fs#path#IsUncPathRoot(l:dir)
	let l:dir = fnamemodify(l:dir, ':h')
    endwhile

    if empty(l:dir)
	throw 'GetRootDir: Could not determine root dir!'
    endif

    return l:dir
endfunction

function! ingo#fs#path#IsAbsolute( filespec )
"******************************************************************************
"* PURPOSE:
"   Test whether a:filespec is an absolute filespec; i.e. starts with a root
"   drive / UNC path / "/".
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Relative / absolute filespec. Does not need to exist.
"* RETURN VALUES:
"   1 if it is absolute, else 0.
"******************************************************************************
    let l:rootDir = ingo#fs#path#GetRootDir(fnamemodify(a:filespec, ':p'))
    return (type(ingo#fs#path#split#AtBasePath(a:filespec, l:rootDir)) != type([]))
endfunction

function! ingo#fs#path#IsUpwards( filespec )
"******************************************************************************
"* PURPOSE:
"   Test whether a:filespec navigates to a parent directory through ".." path
"   elements.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Relative / absolute filespec. Does not need to exist.
"* RETURN VALUES:
"   1 if it navigates to a parent. 0 if it is absolute, or relative within the
"   current context.
"******************************************************************************
    return (ingo#fs#path#Normalize(simplify(a:filespec), '/') =~# '^\.\./')
endfunction

function! ingo#fs#path#IsCaseInsensitive( ... )
    return ingo#os#IsWinOrDos() " Note: Check based on path not yet implemented.
endfunction

function! ingo#fs#path#Equals( p1, p2 )
    if ingo#fs#path#IsCaseInsensitive(a:p1) || ingo#fs#path#IsCaseInsensitive(a:p2)
	return a:p1 ==? a:p2 || ingo#fs#path#Normalize(fnamemodify(a:p1, ':p')) ==? ingo#fs#path#Normalize(fnamemodify(a:p2, ':p'))
    else
	return a:p1 ==# a:p2 || ingo#fs#path#Normalize(fnamemodify(resolve(a:p1), ':p')) ==# ingo#fs#path#Normalize(fnamemodify(resolve(a:p2), ':p'))
    endif
endfunction

function! ingo#fs#path#Exists( filespec )
"******************************************************************************
"* PURPOSE:
"   Test whether the passed a:filespec exists (as a file or directory). This is
"   like the combination of filereadable() and isdirectory(), but without the
"   requirement that the file must be readable.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec      Filespec or dirspec.
"* RETURN VALUES:
"   0 if there's no such file or directory, 1 if it exists.
"******************************************************************************
    " I suppose these are faster than the glob(), and this avoids any escaping
    " issues, too, so it is more robust.
    if filereadable(a:filespec) || isdirectory(a:filespec)
	return 1
    endif

    let l:filespec = ingo#escape#file#wildcardescape(a:filespec)
    return ! empty(ingo#compat#glob(l:filespec, 1))
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
