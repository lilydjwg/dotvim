" ingo/compat.vim: Functions for backwards compatibility with old Vim versions.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/option.vim autoload script
"   - ingo/os.vim autoload script
"   - ingo/strdisplaywidth.vim autoload script
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:compatFor = (exists('g:IngoLibrary_CompatFor') ? ingo#collections#ToDict(split(g:IngoLibrary_CompatFor, ',')) : {})

if exists('*shiftwidth') && ! has_key(s:compatFor, 'shiftwidth')
    function! ingo#compat#shiftwidth()
	return shiftwidth()
    endfunction
else
    function! ingo#compat#shiftwidth()
	return &shiftwidth
    endfunction
endif

if exists('*strdisplaywidth') && ! has_key(s:compatFor, 'strdisplaywidth')
    function! ingo#compat#strdisplaywidth( expr, ... )
	return call('strdisplaywidth', [a:expr] + a:000)
    endfunction
else
    function! ingo#compat#strdisplaywidth( expr, ... )
	let l:expr = (a:0 ? repeat(' ', a:1) . a:expr : a:expr)
	let i = 1
	while 1
	    if ! ingo#strdisplaywidth#HasMoreThan(l:expr, i)
		return i - (a:0 ? a:1 : 0)
	    endif
	    let i += 1
	endwhile
    endfunction
endif

if exists('*strchars') && ! has_key(s:compatFor, 'strchars')
    if v:version == 704 && has('patch755') || v:version > 704
	function! ingo#compat#strchars( ... )
	    return call('strchars', a:000)
	endfunction
    else
	function! ingo#compat#strchars( expr, ... )
	    return (a:0 && a:1 ? strlen(substitute(a:expr, ".", "x", "g")) : strchars(a:expr))
	endfunction
    endif
else
    function! ingo#compat#strchars( expr, ... )
	return len(split(a:expr, '\zs'))
    endfunction
endif

if exists('*strgetchar') && ! has_key(s:compatFor, 'strgetchar')
    function! ingo#compat#strgetchar( expr, index )
	return strgetchar(a:expr, a:index)
    endfunction
else
    function! ingo#compat#strgetchar( expr, index )
	return char2nr(matchstr(a:expr, '.\{' . a:index . '}\zs.'))
    endfunction
endif

if exists('*strcharpart') && ! has_key(s:compatFor, 'strcharpart')
    function! ingo#compat#strcharpart( ... )
	return call('strcharpart', a:000)
    endfunction
else
    function! ingo#compat#strcharpart( src, start, ... )
	let [l:start, l:len] = [a:start, a:0 ? a:1 : 0]
	if l:start < 0
	    let l:len += l:start
	    let l:start = 0
	endif

	return matchstr(a:src, '.\{' . l:start . '}\zs.' . (a:0 ? '\{,' . max([0, l:len]) . '}' : '*'))
    endfunction
endif

if exists('*abs') && ! has_key(s:compatFor, 'abs')
    function! ingo#compat#abs( expr )
	return abs(a:expr)
    endfunction
else
    function! ingo#compat#abs( expr )
	return (a:expr < 0 ? -1 : 1) * a:expr
    endfunction
endif

if exists('*uniq') && ! has_key(s:compatFor, 'uniq')
    function! ingo#compat#uniq( list )
	return uniq(a:list)
    endfunction
else
    function! ingo#compat#uniq( list )
	return ingo#collections#UniqueSorted(a:list)
    endfunction
endif

if exists('*getcurpos') && ! has_key(s:compatFor, 'getcurpos')
    function! ingo#compat#getcurpos()
	return getcurpos()
    endfunction
else
    function! ingo#compat#getcurpos()
	return getpos('.')
    endfunction
endif

if exists('*systemlist') && ! has_key(s:compatFor, 'systemlist')
    function! ingo#compat#systemlist( ... )
	return call('systemlist', a:000)
    endfunction
else
    function! ingo#compat#systemlist( ... )
	return split(call('system', a:000), '\n')
    endfunction
endif

if exists('*haslocaldir') && ! has_key(s:compatFor, 'haslocaldir')
    function! ingo#compat#haslocaldir()
	return haslocaldir()
    endfunction
else
    function! ingo#compat#haslocaldir()
	return 0
    endfunction
endif

if exists('*execute') && ! has_key(s:compatFor, 'execute')
    function! ingo#compat#execute( ... )
	return call('execute', a:000)
    endfunction
else
    function! ingo#compat#execute( command, ... )
	let l:prefix = (a:0 ? a:1 : 'silent')
	let l:output = ''
	try
	    redir => l:output
		for l:command in ingo#list#Make(a:command)
		    execute l:prefix l:command
		endfor
	    redir END
	    redraw	" This is necessary because of the :redir done earlier.
	finally
	    redir END
	endtry

	return l:output
    endfunction
endif

if exists('*trim') && ! has_key(s:compatFor, 'trim')
    function! ingo#compat#trim( ... )
	return call('trim', a:000)
    endfunction
else
    function! ingo#compat#trim( text, ... )
	let l:mask = (a:0 ? a:1 : "\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\x0c\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f \xa0")
	let l:text = a:text

	while ! empty(a:text)
	    let [l:head, l:rest] = matchlist(l:text, '^\(.\)\(.*\)$')[1:2]
	    if stridx(l:mask, l:head) == -1
		break
	    endif

	    let l:text = l:rest
	endwhile

	while ! empty(a:text)
	    let [l:rest, l:tail] = matchlist(l:text, '^\(.*\)\(.\)$')[1:2]
	    if stridx(l:mask, l:tail) == -1
		break
	    endif

	    let l:text = l:rest
	endwhile

	return l:text
    endfunction
endif

function! ingo#compat#fnameescape( filespec )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in Ex commands.
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"* RETURN VALUES:
"   Escaped filespec to be passed as a {file} argument to an Ex command.
"*******************************************************************************
    if exists('*fnameescape') && ! has_key(s:compatFor, 'fnameescape')
	if ingo#os#IsWindows()
	    let l:filespec = a:filespec

	    " XXX: fnameescape() on Windows mistakenly escapes the "!"
	    " character, which makes Vim treat the "foo!bar" filespec as if a
	    " file "!bar" existed in an intermediate directory "foo". Cp.
	    " http://article.gmane.org/gmane.editors.vim.devel/22421
	    let l:filespec = substitute(fnameescape(l:filespec), '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\!', '!', 'g')

	    " XXX: fnameescape() on Windows does not escape the "[" character
	    " (like on Linux), but Windows understands this wildcard and expands
	    " it to an existing file. As escaping with \ does not work (it is
	    " treated like a path separator), turn this into the neutral [[],
	    " but only if the file actually exists.
	    if a:filespec =~# '\[[^/\\]\+\]' && filereadable(fnamemodify(a:filespec, ':p')) " Need to expand to absolute path (but not use expand() because of the glob!) because filereadable() does not understand stuff like "~/...".
		let l:filespec = substitute(l:filespec, '\[', '[[]', 'g')
	    endif

	    return l:filespec
	else
	    return fnameescape(a:filespec)
	endif
    else
	" Note: On Windows, backslash path separators and some other Unix
	" shell-specific characters mustn't be escaped.
	return escape(a:filespec, " \t\n*?`%#'\"|<" . (ingo#os#IsWinOrDos() ? '' : '![{$\'))
    endif
endfunction

function! ingo#compat#shellescape( filespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in shell commands.
"   The filespec will be quoted properly.
"   When the {special} argument is present and it's a non-zero Number, then
"   special items such as "!", "%", "#" and "<cword>" will be preceded by a
"   backslash.  This backslash will be removed again by the |:!| command.
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    normal filespec
"   a:special	    Flag whether special items will be escaped, too.
"
"* RETURN VALUES:
"   Escaped filespec to be used in a :! command or inside a system() call.
"*******************************************************************************
    let l:isSpecial = (a:0 ? a:1 : 0)
    let l:specialShellescapeCharacters = "\n%#'!"
    if exists('*shellescape') && ! has_key(s:compatFor, 'shellescape')
	if a:0
	    if v:version < 702
		" The shellescape({string}) function exists since Vim 7.0.111,
		" but shellescape({string}, {special}) was only introduced with
		" Vim 7.2. Emulate the two-argument function by (crudely)
		" escaping special characters for the :! command.
		return shellescape((l:isSpecial ? escape(a:filespec, l:specialShellescapeCharacters) : a:filespec))
	    else
		return shellescape(a:filespec, l:isSpecial)
	    endif
	else
	    return shellescape(a:filespec)
	endif
    else
	let l:escapedFilespec = (l:isSpecial ? escape(a:filespec, l:specialShellescapeCharacters) : a:filespec)

	if ingo#os#IsWinOrDos()
	    return '"' . l:escapedFilespec . '"'
	else
	    return "'" . l:escapedFilespec . "'"
	endif
    endif
endfunction

if v:version == 704 && has('patch279') || v:version > 704
    " This one has both {nosuf} and {list}.
    function! ingo#compat#glob( ... )
	return call('glob', a:000)
    endfunction
    function! ingo#compat#globpath( ... )
	return call('globpath', a:000)
    endfunction
elseif v:version == 703 && has('patch465') || v:version > 703
    " This one has glob() with both {nosuf} and {list}.
    function! ingo#compat#glob( ... )
	return call('glob', a:000)
    endfunction
    function! ingo#compat#globpath( ... )
	let l:list = (a:0 > 3 && a:4)
	let l:result = call('globpath', a:000[0:2])
	return (l:list ? split(l:result, '\n') : l:result)
    endfunction
elseif v:version == 702 && has('patch051') || v:version > 702
    " This one has {nosuf}.
    function! ingo#compat#glob( ... )
	let l:list = (a:0 > 2 && a:3)
	let l:result = call('glob', a:000[0:1])
	return (l:list ? split(l:result, '\n') : l:result)
    endfunction
    function! ingo#compat#globpath( ... )
	let l:list = (a:0 > 3 && a:4)
	let l:result = call('globpath', a:000[0:2])
	return (l:list ? split(l:result, '\n') : l:result)
    endfunction
else
    " This one has neither {nosuf} nor {list}.
    function! ingo#compat#glob( ... )
	let l:nosuf = (a:0 > 1 && a:2)
	let l:list = (a:0 > 2 && a:3)

	if l:nosuf
	    let l:save_wildignore = &wildignore
	    set wildignore=
	endif
	try
	    let l:result = call('glob', [a:1])
	    return (l:list ? split(l:result, '\n') : l:result)
	finally
	    if exists('l:save_wildignore')
		let &wildignore = l:save_wildignore
	    endif
	endtry
    endfunction
    function! ingo#compat#globpath( ... )
	let l:nosuf = (a:0 > 2 && a:3)
	let l:list = (a:0 > 3 && a:4)

	if l:nosuf
	    let l:save_wildignore = &wildignore
	    set wildignore=
	endif
	try
	    let l:result = call('globpath', a:000[0:1])
	    return (l:list ? split(l:result, '\n') : l:result)
	finally
	    if exists('l:save_wildignore')
		let &wildignore = l:save_wildignore
	    endif
	endtry
    endfunction
endif

if (v:version == 703 && has('patch32') || v:version > 703) && ! has_key(s:compatFor, 'maparg')
    function! ingo#compat#maparg( name, ... )
	let l:args = [a:name, '', 0, 1]
	if a:0 > 0
	    let l:args[1] = a:1
	endif
	if a:0 > 1
	    let l:args[2] = a:2
	endif
	let l:mapInfo = call('maparg', l:args)

	if type(l:mapInfo) != type({}) || ! has_key(l:mapInfo, 'rhs')
	    " Avoid "E121: Undefined variable: rhs" / "E716: Key not present in
	    " Dictionary: rhs" in case empty / non-existing a:name is passed.
	    return ''
	endif

	" Contrary to the old maparg(), <SID> doesn't get automatically
	" translated into <SNR>NNN_ here.
	return substitute(l:mapInfo.rhs, '\c<SID>', '<SNR>' . l:mapInfo.sid . '_', 'g')
    endfunction
else
    function! ingo#compat#maparg( name, ... )
	let l:rhs = call('maparg', [a:name] + a:000)
	let l:rhs = substitute(l:rhs, '\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\zs<\|<\%([^<]\+>\)\@!', '<lt>', 'g')    " Escape stand-alone < (when not part of a key-notation), or when escaped \<, but not proper key-notation like <C-CR>.
	let l:rhs = substitute(l:rhs, '|', '<Bar>', 'g')    " '|' must be escaped, or the map command will end prematurely.
	return l:rhs
    endfunction
endif

if (v:version == 703 && has('patch590') || v:version > 703) && ! has_key(s:compatFor, 'setpos')
    function! ingo#compat#setpos( expr, list )
	return setpos(a:expr, a:list)
    endfunction
else
    function! s:IsOnOrAfter( pos1, pos2 )
	return (a:pos2[1] > a:pos1[1] || a:pos2[1] == a:pos1[1] && a:pos2[2] >= a:pos1[2])
    endfunction
    function! ingo#compat#setpos( expr, list )
	" Vim versions before 7.3.590 cannot set the selection directly.
	let l:save_cursor = getpos('.')
	if a:expr ==# "'<"
	    let l:status = setpos('.', a:list)
	    if l:status != 0 | return l:status | endif
	    if s:IsOnOrAfter(a:list, getpos("'>"))
		execute "normal! vg`>\<Esc>"
	    else
		" We cannot maintain the position of the end of the selection,
		" as it is _before_ the new start, and would therefore make Vim
		" swap the two mark positions.
		execute "normal! v\<Esc>"
	    endif
	    call setpos('.', l:save_cursor)
	    return 0
	elseif a:expr ==# "'>"
	    if &selection ==# 'exclusive' && ! ingo#option#ContainsOneOf(&virtualedit, ['all', 'onemore'])
		" We may have to select the last character in a line.
		let l:save_virtualedit = &virtualedit
		set virtualedit=onemore
	    endif
	    try
		let l:status = setpos('.', a:list)
		if l:status != 0 | return l:status | endif
		if s:IsOnOrAfter(getpos("'<"), a:list)
		    execute "normal! vg`<o\<Esc>"
		else
		    " We cannot maintain the position of the start of the selection,
		    " as it is _after_ the new end, and would therefore make Vim
		    " swap the two mark positions.
		    execute "normal! v\<Esc>"
		endif
		call setpos('.', l:save_cursor)
		return 0
	    finally
		if exists('l:save_virtualedit')
		    let &virtualedit = l:save_virtualedit
		endif
	    endtry
	else
	    return setpos(a:expr, a:list)
	endif
    endfunction
endif

if exists('*sha256') && ! has_key(s:compatFor, 'sha256')
    function! ingo#compat#sha256( string )
	return sha256(a:string)
    endfunction
elseif executable('sha256sum')
    let s:printStringCommandTemplate = (ingo#os#IsWinOrDos() ? 'echo.%s' : 'printf %%s %s')
    function! ingo#compat#sha256( string )
	return get(split(system(printf(s:printStringCommandTemplate . "|sha256sum", ingo#compat#shellescape(a:string)))), 0, '')
    endfunction
else
    function! ingo#compat#sha256( string )
	throw 'ingo#compat#sha256: Not implemented here'
    endfunction
endif

if exists('*synstack') && ! has_key(s:compatFor, 'synstack')
    if v:version < 702 || v:version == 702 && ! has('patch14')
	" 7.2.014: synstack() doesn't work in an empty line
	function! ingo#compat#synstack( lnum, col )
	    let l:s =  synstack(a:lnum, a:col)
	    return (empty(l:s) ? [] : l:s)
	endfunction
    else
	function! ingo#compat#synstack( lnum, col )
	    return synstack(a:lnum, a:col)
	endfunction
    endif
else
    " As the synstack() function is not available, we can only try to get the
    " actual syntax ID and the one of the syntax item that determines the
    " effective color.
    function! ingo#compat#synstack( lnum, col )
	return [synID(a:lnum, a:col, 1), synID(a:lnum, a:col, 0)]
    endfunction
endif

" Patch 7.4.1707: Allow using an empty dictionary key
if (v:version == 704 && has('patch1707') || v:version > 704) && ! has_key(s:compatFor, 'DictKey')
    function! ingo#compat#DictKey( key )
	return a:key
    endfunction
    function! ingo#compat#FromKey( key )
	return a:key
    endfunction
else
    function! ingo#compat#DictKey( key )
	return (empty(a:key) ? "\<Nul>" : a:key)
    endfunction
    function! ingo#compat#FromKey( key )
	return (a:key ==# "\<Nul>" ? '' : a:key)
    endfunction
endif

if exists('*matchstrpos') && ! has_key(s:compatFor, 'matchstrpos')
    function! ingo#compat#matchstrpos( ... )
	return call('matchstrpos', a:000)
    endfunction
else
    function! ingo#compat#matchstrpos( ... )
	let l:start = call('match', a:000)

	if type(a:1) == type([])
	    let l:index = l:start
	    if l:index < 0
		return ['', -1, -1, -1]
	    endif

	    let l:matchArgs = [a:1[l:index], a:2] " {start} and {count} address the List, not the element; omit it here.
	    let l:str = call('matchstr', l:matchArgs)
	    let l:start = call('match', l:matchArgs)
	    let l:end = call('matchend', l:matchArgs)

	    return [l:str, l:index, l:start, l:end]
	else
	    let l:str = call('matchstr', a:000)
	    let l:end = call('matchend', a:000)
	    return [l:str, l:start, l:end]
	endif
    endfunction
endif

if exists('*getenv') && ! has_key(s:compatFor, 'getenv')
    function! ingo#compat#getenv( name )
	let l:val = getenv(a:name)

	if l:val is# v:null
	    " XXX: getenv() returns v:null even though the environment variable is defined.
	    return (exists('$' . a:name) ? '' : l:val)
	else
	    return l:val
	endif
    endfunction
else
    function! ingo#compat#getenv( name )
	let l:ev = '$' . a:name
	return (exists(l:ev) ? eval(l:ev) : [])
    endfunction
endif
if exists('*setenv') && ! has_key(s:compatFor, 'setenv')
    function! ingo#compat#setenv( name, val )
	return setenv(a:name, (type(a:val) == type([]) ? v:null : a:val))
    endfunction
else
    function! ingo#compat#setenv( name, val )
	let l:ev = '$' . a:name
	if type(a:val) == type([])
	    execute 'unlet!' l:ev
	else
	    execute 'let' l:ev '= a:val'
	endif
    endfunction
endif

if exists('*getcharstr') && ! has_key(s:compatFor, 'getcharstr')
    function! ingo#compat#getcharstr( ... ) abort
	return call('getcharstr', a:000)
    endfunction
else
    function! ingo#compat#getcharstr( ... ) abort
	let l:char = call('getchar', a:000)
	if type(l:char) == type(0)
	    let l:char = nr2char(l:char)
	endif
	return l:char
    endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
