" ingo/compat/commands.vim: Command emulations for backwards compatibility with Vim versions that don't have these commands.
"
" DEPENDENCIES:
"
" Copyright: (C) 2017-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:compatFor = (exists('g:IngoLibrary_CompatFor') ? ingo#collections#ToDict(split(g:IngoLibrary_CompatFor, ',')) : {})

"******************************************************************************
"* PURPOSE:
"   Return ':keeppatterns' if supported or an emulation of it.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Creates internal command if emulation is needed.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   Command. To use, turn >
"	command! -range Foo keeppatterns <line1>,<line2>substitute/\<...\>/FOO/g
"   <into >
"	command! -range Foo execute ingo#compat#commands#keeppatterns() '<line1>,<line2>substitute/\<...\>/FOO/g'
"******************************************************************************
if exists(':keeppatterns') == 2 && ! has_key(s:compatFor, 'keeppatterns')
    function! ingo#compat#commands#keeppatterns()
	return 'keeppatterns'
    endfunction
else
    if exists('ZzzzKeepPatterns') != 2
	command! -nargs=* ZzzzKeepPatterns let g:ingo#compat#commands#histnr = histnr('search') | execute <q-args> | if g:ingo#compat#commands#histnr != histnr('search') | call histdel('search', -1) | let @/ = histget('search', -1) | nohlsearch | endif
    endif
    function! ingo#compat#commands#keeppatterns()
	return 'ZzzzKeepPatterns'
    endfunction
endif


function! ingo#compat#commands#NormalWithCount( ... )
"******************************************************************************
"* PURPOSE:
"   Execute the normal mode commands that may include a count as soon as
"   possible. Uses :normal if it supports count or no count is given; prior to
"   Vim 7.3.100, a bug prevented this, and feedkeys() has to be used. Note that
"   this means that the keys will only be interpreted _after_ the function ends,
"   and that other :normal commands will come first!
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Executes a:count . a:string.
"* INPUTS:
"   a:prefix    Optional: Any characters to be executed before a:count. (With
"               :normal, the sequence has to be a single call.)
"   a:count     Optional count for a:string. If omitted, no count is used.
"   a:string    Characters to be executed in normal mode.
"   a:isNoRemap Flag whether mappings are ignored for a:string characters.
"* RETURN VALUES:
"   1 if the execution could be done immediately, 0 if it will happen after the
"   current command sequence has finished.
"******************************************************************************
    let l:prefix = ''
    let l:count = ''
    if a:0 == 4
	let [l:prefix, l:count, l:string, l:isNoRemap] = a:000
    elseif a:0 == 3
	let [l:count, l:string, l:isNoRemap] = a:000
    elseif a:0 == 2
	let [l:string, l:isNoRemap] = a:000
    else
	throw 'ASSERT: Need 2..4 arguments instead of ' . a:0
    endif

    if ! l:count || v:version > 703 || (v:version == 703 && has('patch100'))
	execute 'normal' . (l:isNoRemap ? '!' : '') l:prefix . (l:count ? l:count : '') . l:string
	return 1
    else
	call feedkeys(l:prefix . (l:count ? l:count : '') . l:string, (l:isNoRemap ? 'n' : ''))
	return 0
    endif
endfunction

if v:version == 704 && has('patch601') || v:version > 704
" For these Vim versions, repeat.vim uses feedkeys(), which is asynchronous, so
" the actual sequence would only be executed after the caller finished. With
" this function, callers can force synchronous execution of the typeahead now to
" be able to work on the effects of command repetition.
function! ingo#compat#commands#ForceSynchronousFeedkeys()
    call feedkeys('', 'x')
endfunction
else
function! ingo#compat#commands#ForceSynchronousFeedkeys()
    return
endfunction
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
