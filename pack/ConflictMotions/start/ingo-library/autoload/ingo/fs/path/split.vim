" ingo/fs/path/split.vim: Functions for splitting a file system path.
"
" DEPENDENCIES:
"   - ingo/fs/path.vim autoload script
"   - ingo/str.vim autoload script
"
" Copyright: (C) 2014-2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#fs#path#split#PathAndName( filespec, ... )
"******************************************************************************
"* PURPOSE:
"   Split a:filespec into the (absolute, relative, or ".') path and the file
"   name itself.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec                      Absolute / relative filespec.
"   a:isPathWithTrailingSeparator   Optional flag whether the returned file path
"				    ends with a trailing path separator. Default
"				    true.
"* RETURN VALUES:
"   [filepath, filename]
"******************************************************************************
    let l:isPathWithTrailingSeparator = (a:0 ? a:1 : 1)
    let [l:dirspec, l:filename] = [fnamemodify(a:filespec, ':h'), fnamemodify(a:filespec, ':t')]

    if l:isPathWithTrailingSeparator
	let l:dirspec = ingo#fs#path#Combine(l:dirspec, '')
    endif

    return [l:dirspec, l:filename]
endfunction

function! ingo#fs#path#split#AtBasePath( filespec, basePath, ... )
"******************************************************************************
"* PURPOSE:
"   Split off a:basePath from a:filespec. The check will be done on normalized
"   paths.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec.
"   a:basePath  Filespec to the base directory that contains a:filespec.
"   a:onBasePathNotExisting Optional value to be returned when a:filespec does
"                           not start with a:basePath; default empty List.
"* RETURN VALUES:
"   Remainder of a:filespec, after removing a:basePath, or empty List if
"   a:filespec did not start with a:basePath.
"******************************************************************************
    let l:filespec = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:filespec, '/'), '')
    let l:basePath = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:basePath, '/'), '')
    return (ingo#str#StartsWith(l:filespec, l:basePath, ingo#fs#path#IsCaseInsensitive(l:filespec)) ?
    \   strpart(a:filespec, len(l:basePath)) :
    \   (a:0 ? a:1 : [])
    \)
endfunction

function! ingo#fs#path#split#Contains( filespec, fragment )
"******************************************************************************
"* PURPOSE:
"   Test whether a:filespec contains a:fragment anywhere. To match entire
"   (anchored) path fragments, pass a fragment surrounded by forward slashes
"   (e.g. "/foo/"); you can always use forward slashes, as these will be
"   internally normalized.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec to be examined.
"   a:fragment  Path fragment that may be contained inside a:filespec.
"* RETURN VALUES:
"   1 if contained, 0 if not.
"******************************************************************************
    let l:filespec = ingo#fs#path#Combine(ingo#fs#path#Normalize(a:filespec, '/'), '')
    let l:fragment = ingo#fs#path#Normalize(a:fragment, '/')
    return ingo#str#Contains(l:filespec, l:fragment, ingo#fs#path#IsCaseInsensitive(l:filespec))
endfunction

function! ingo#fs#path#split#StartsWith( filespec, basePath )
"******************************************************************************
"* PURPOSE:
"   Test whether a:filespec starts with a:basePath, matching entire path
"   fragments. You can always use forward slashes, as these will be internally
"   normalized.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec to be examined.
"   a:basePath  Filespec to the base directory that is checked against.
"* RETURN VALUES:
"   1 if it starts with it, 0 if not.
"******************************************************************************
    let l:basePath = ingo#fs#path#split#AtBasePath(a:filespec, a:basePath)
    return (type(l:basePath) != type([]))
endfunction

function! ingo#fs#path#split#EndsWith( filespec, fragment )
"******************************************************************************
"* PURPOSE:
"   Test whether a:filespec ends with a:fragment. To match entire (anchored)
"   path fragments, pass a fragment surrounded by forward slashes (e.g.
"   "/foo/"); you can always use forward slashes, as these will be internally
"   normalized.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec to be examined.
"   a:fragment  Path fragment that may be contained inside a:filespec.
"* RETURN VALUES:
"   1 if it ends with it, 0 if not.
"******************************************************************************
    let l:filespec = ingo#fs#path#Normalize(a:filespec, '/')
    let l:fragment = ingo#fs#path#Normalize(a:fragment, '/')
    return ingo#str#EndsWith(l:filespec, l:fragment, ingo#fs#path#IsCaseInsensitive(l:filespec))
endfunction

function! ingo#fs#path#split#ChangeBasePath( filespec, basePath, newBasePath )
"******************************************************************************
"* PURPOSE:
"   Replace a:basePath in a:filespec with a:newBasePath. This will be done on
"   normalized paths.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec.
"   a:basePath  Filespec to the base directory that contains a:filespec.
"   a:newBasePath Filespec to the new base directory.
"* RETURN VALUES:
"   Changed a:filespec, or empty List if a:filespec did not start with
"   a:basePath.
"******************************************************************************
    let l:remainder = ingo#fs#path#split#AtBasePath(a:filespec, a:basePath)
    if type(l:remainder) == type([])
	return []
    endif
    return ingo#fs#path#Combine(ingo#fs#path#Normalize(a:newBasePath, '/'), l:remainder)
endfunction

if ! exists('g:IngoLibrary_TruncateEllipsis')
    let g:IngoLibrary_TruncateEllipsis = (&encoding ==# 'utf-8' ? "\u2026" : '...')
endif
function! ingo#fs#path#split#TruncateTo( filespec, virtCol, ...)
"******************************************************************************
"* PURPOSE:
"   Truncate a:filespec to a maximum of a:virtCol virtual columns by removing
"   directories from the inside, and replacing those with a "..." indicator.
"* SEE ALSO:
"   - ingo#avoidprompt#TruncateTo() does something similar with hard truncation
"     in the middle of a:text, without regards to (path or other) boundaries.
"* ASSUMPTIONS / PRECONDITIONS:
"   The default ellipsis can be configured by g:IngoLibrary_TruncateEllipsis.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec  Filespec. It is assumed to be in normalized form already.
"   a:virtCol   Maximum virtual columns for a:text.
"   a:pathSeparator Optional path separator to be used. Defaults to the
"                   platform's default one.
"   a:truncationIndicator   Optional text to be appended when truncation
"			    appears. a:text is further reduced to account for
"			    its width. Default is "..." or the single-char UTF-8
"			    variant if the encoding also is UTF-8.
"* RETURN VALUES:
"   Truncated a:filespec.
"******************************************************************************
    let l:sep = (a:0 ? a:1 : ingo#fs#path#Separator())

    if ingo#compat#strdisplaywidth(a:filespec) <= a:virtCol
	return a:filespec " Short circuit.
    endif

    let l:truncationIndicator = (a:0 >= 2 ? a:2 : g:IngoLibrary_TruncateEllipsis)
    let l:fragments = split(a:filespec, '\C\V' . escape(l:sep, '\'), 1)

    let l:i = 0
    let l:result = l:fragments[-1]
    while 2 * l:i <= len(l:fragments)
	let l:joinedFragments = join(l:fragments[0: l:i] + [l:truncationIndicator] + l:fragments[-1 * (l:i + 1) : -1], l:sep)
	if ingo#compat#strdisplaywidth(l:joinedFragments) > a:virtCol
	    break
	endif

	let l:result = l:joinedFragments
	let l:i += 1
    endwhile

    " Try adding one more, with a preference to the deeper subdirectory.
    let l:joinedFragments = join(l:fragments[0: (l:i - 1)] + [l:truncationIndicator] + l:fragments[-1 * (l:i + 1) : -1], l:sep)
    if ingo#compat#strdisplaywidth(l:joinedFragments) <= a:virtCol
	let l:result = l:joinedFragments
    else
	let l:joinedFragments = join(l:fragments[0: l:i] + [l:truncationIndicator] + l:fragments[-1 * l:i : -1], l:sep)
	if ingo#compat#strdisplaywidth(l:joinedFragments) <= a:virtCol
	    let l:result = l:joinedFragments
	endif
    endif

    " Corner case: Also handle truncation in a single large final fragment.
    if l:i == 0
	let l:result = ingo#avoidprompt#TruncateTo(l:result, a:virtCol, 0, l:truncationIndicator)
    endif

    return l:result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
