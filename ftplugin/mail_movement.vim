" mail_movement.vim: Movement over email quotes with ]] etc. 
"
" DEPENDENCIES:
"   - CountJump/Region.vim, CountJump/TextObjects.vim autoload scripts. 
"
" Copyright: (C) 2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"   1.52.007	20-Dec-2010	Adapted to CountJump#Region#JumpToNextRegion()
"				again returning jump position in version 1.40. 
"   1.51.006	19-Dec-2010	ENH: ][ mapping in operator-pending and visual
"				mode now also operates over / select the last
"				line of the quote. This is what the user
"				expects. 
"				Adapted to changed interface of
"				CountJump#Region#JumpToNextRegion(): Additional
"				a:isToEndOfLine argument, and does not return
"				position any more.  
"				Adapted to changed interface of
"				CountJump#JumpFunc(): Need to ring the bell
"				myself, no need for returning position any more. 
"   1.51.005	18-Dec-2010	Renamed CountJump#Region#Jump() to
"				CountJump#JumpFunc(). 
"   1.51.004	18-Dec-2010	Adapted to extended interface of
"				CountJump#Region#SearchForNextRegion() in
"				CountJump 1.30. 
"   1.50.003	08-Aug-2010	ENH: Added support for MS Outlook-style quoting
"				with email separator and mail headers. Whether
"				regions of prefixed lines or lines preceded by
"				separator + headers are used is determined by
"				context. 
"   1.00.002	03-Aug-2010	Published. 
"	001	19-Jul-2010	file creation from diff_movement.vim

" Avoid installing when in unsupported Vim version. 
if v:version < 700
    finish
endif 

let s:save_cpo = &cpo
set cpo&vim

" Force loading of autoload script, because creation of Funcref doesn't do this. 
silent! call CountJump#Region#DoesNotExist()

" List of patterns for email separator lines. These are anchored at the
" beginning of the line (implicit /^/, do not add) and must include the end of
" the separator line by concluding the pattern with /\n/. 
if ! exists('g:mail_SeparatorPatterns')
    let g:mail_SeparatorPatterns = [ '-\+Original Message-\+\n', '_\+\n' ]
endif
function! s:GetMailSeparatorPattern()
    return '\%(' . join(g:mail_SeparatorPatterns, '\|') . '\)'
endfunction

function! s:function(name)
    return function(substitute(a:name, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunction$'),''))
endfunction 
function! s:MakeQuotePattern( quotePrefix, isInner )
    let l:quoteLevel = strlen(substitute(a:quotePrefix, '[^>]', '', 'g'))
    return '^\%( *>\)\{' . l:quoteLevel . '\}' . (a:isInner ? '\%( *$\| *[^ >]\)' : '')
endfunction

"			A quoted email is determined either by: 
"			- lines prefixed with ">" (one, or multiple for nested
"			  quotes) 
"			- an optional email separator (e.g.
"			"-----Original Message-----") and the standard "From: <Name>"
"			mail header, optionally followed by other header lines. 

"			Move around email quotes of either: 
"			- a certain nesting level, as determined by the current
"			  line; if the cursor is not on a quoted line, any
"			  nesting level will be used. 
"			- the range of lines from the "From: <Name>" mail header
"			  up to the line preceding the next email separator or
"			  next mail header. 
"]]			Go to [count] next start of an email quote. 
"][			Go to [count] next end of an email quote. 
"[[			Go to [count] previous start of an email quote. 
"[]			Go to [count] previous end of an email quote. 
function! s:GetCurrentQuoteNestingPattern()
    let l:quotePrefix = matchstr(getline('.'), '^[ >]*>')
    return (empty(l:quotePrefix) ? '^ *\%(> *\)\+' : s:MakeQuotePattern(l:quotePrefix, 0))
endfunction
function! s:GetDifference( pos )
    let l:difference = (a:pos[0] == 0 ? 0x7FFFFFFF : (a:pos[0] - line('.')))
    return (l:difference < 0 ? -1 * l:difference : l:difference)
endfunction
function! s:JumpToQuotedRegionOrSeparator( count, pattern, step, isAcrossRegion, isToEnd, ... )
    let l:isToEndOfLine = (a:0 ? a:1 : 0)
    " Jump to the next <count>'th quoted region or email separator line,
    " whichever is closer to the current position. "Closer" here exactly means
    " whichever type lies closer to the current position. This should only
    " matter if separated emails contain quotes; we then want a 2]] jump to the
    " beginning of the second separated email, not to the second quotes
    " contained in the first mail. 
    "	X We're here. 
    " 	-- message 1 --
    " 	blah
    " 	> quote 1
    " 	> quote 2
    " 	blah
    " 	-- message 2 --
    " 	2]] should jump here. 
    " This is implemented by searching for the next region / separator (without
    " moving the cursor), and then choosing the one that exists and is closer to
    " the current position. 
    let l:nextRegionPos = CountJump#Region#SearchForNextRegion(1, a:pattern, 1, a:step, a:isAcrossRegion)

    let l:separatorPattern = (a:isToEnd ?
    \	'^' . s:GetMailSeparatorPattern() . '\@!.*\n' . s:GetMailSeparatorPattern() . '\?From:\s\|\%$' :
    \	'^From:\s'
    \)
    let l:separatorSearchOptions = (a:step == -1 ? 'b' : '') . 'W'
    let l:nextSeparatorPos = searchpos(l:separatorPattern, l:separatorSearchOptions . 'n')

    let l:nextRegionDifference = s:GetDifference(l:nextRegionPos)
    let l:nextSeparatorDifference = s:GetDifference(l:nextSeparatorPos)

    if l:nextRegionDifference < l:nextSeparatorDifference && l:nextRegionPos != [0, 0]
	call CountJump#Region#JumpToNextRegion(a:count, a:pattern, 1, a:step, a:isAcrossRegion, l:isToEndOfLine)
    elseif l:nextSeparatorPos != [0, 0]
	call CountJump#CountSearch(a:count, [l:separatorPattern, l:separatorSearchOptions])
	if l:isToEndOfLine
	    normal! $
	endif
    else
	" Ring the bell to indicate that no further match exists. 
	"
	" As long as this mapping does not exist, it causes a beep in both
	" normal and visual mode. This is easier than the customary "normal!
	" \<Esc>", which only works in normal mode. 
	execute "normal \<Plug>RingTheBell"
    endif
endfunction
function! s:JumpToBeginForward( mode )
    call CountJump#JumpFunc(a:mode, s:function('s:JumpToQuotedRegionOrSeparator'), s:GetCurrentQuoteNestingPattern(), 1, 0, 0)
endfunction
function! s:JumpToBeginBackward( mode )
    call CountJump#JumpFunc(a:mode, s:function('s:JumpToQuotedRegionOrSeparator'), s:GetCurrentQuoteNestingPattern(), -1, 1, 0)
endfunction
function! s:JumpToEndForward( mode )
    let l:useToEndOfLine = (a:mode !=# 'n')
    call CountJump#JumpFunc(a:mode, s:function('s:JumpToQuotedRegionOrSeparator'), s:GetCurrentQuoteNestingPattern(), 1, 1, 1, l:useToEndOfLine)
endfunction
function! s:JumpToEndBackward( mode )
    call CountJump#JumpFunc(a:mode, s:function('s:JumpToQuotedRegionOrSeparator'), s:GetCurrentQuoteNestingPattern(), -1, 0, 1)
endfunction
call CountJump#Motion#MakeBracketMotionWithJumpFunctions('<buffer>', '', '', 
\   s:function('s:JumpToBeginForward'),
\   s:function('s:JumpToBeginBackward'),
\   '',
\   s:function('s:JumpToEndBackward'),
\   0
\)
call CountJump#Motion#MakeBracketMotionWithJumpFunctions('<buffer>', '', '', 
\   '',
\   '',
\   s:function('s:JumpToEndForward'),
\   '',
\   1
\)


"			Move to nested email quote (i.e. of a higher nesting
"			level as the current line; if the cursor is not on a
"			quoted line, any nesting level will be used). 
"]+			Go to [count] next start of a nested email quote. 
"[+			Go to [count] previous start of a nested email quote. 
function! s:GetNestedQuotePattern()
    let l:quotePrefix = matchstr(getline('.'), '^[ >]*>')
    return (empty(l:quotePrefix) ? '^ *\%(> *\)\+' : s:MakeQuotePattern(l:quotePrefix, 0) . ' *>')
endfunction
function! s:JumpToNestedForward( mode )
    call CountJump#JumpFunc(a:mode, function('CountJump#Region#JumpToNextRegion'), s:GetNestedQuotePattern(), 1, 1, 0, 0)
endfunction
function! s:JumpToNestedBackward( mode )
    call CountJump#JumpFunc(a:mode, function('CountJump#Region#JumpToNextRegion'), s:GetNestedQuotePattern(), 1, -1, 1, 0)
endfunction
call CountJump#Motion#MakeBracketMotionWithJumpFunctions('<buffer>', '+', '', 
\   s:function('s:JumpToNestedForward'),
\   s:function('s:JumpToNestedBackward'),
\   0,
\   0,
\   0
\)


"aq			"a quote" text object, select [count] email quotes, i.e. 
"			- contiguous lines having at least the same as the
"			  current line's nesting level
"			- one email message including the preceding mail headers
"			  and optional email separator
"iq			"inner quote" text object, select [count] regions with
"			either: 
"			- the same nesting level
"			- the contents of an email message without the preceding
"			  mail headers
function! s:JumpToQuoteBegin( count, isInner )
    let s:quotePrefix = matchstr(getline('.'), '^[ >]*>')
    if empty(s:quotePrefix)
	if a:isInner
	    let l:separatorPattern = '^' . s:GetMailSeparatorPattern() . '\?From:.*\n\%([A-Za-z0-9_-]\+:.*\n\)*'
	    let l:matchPos = CountJump#CountSearch(a:count, [l:separatorPattern, 'bcW'])
	    if l:matchPos != [0, 0]
		call CountJump#CountSearch(1, [l:separatorPattern, 'ceW'])
		normal! j
	    endif
	    return l:matchPos
	else
	    let l:separatorPattern = '\%(^' . s:GetMailSeparatorPattern() . '\@!.*\n\zs\|\%^\)' . s:GetMailSeparatorPattern() . '\?From:\s'
	    return CountJump#CountSearch(a:count, [l:separatorPattern, 'bcW'])
	endif
    endif

    return CountJump#Region#JumpToRegionEnd(a:count, s:MakeQuotePattern(s:quotePrefix, a:isInner), 1, -1, 0)
endfunction
function! s:JumpToQuoteEnd( count, isInner )
    if empty(s:quotePrefix)
	let l:separatorPattern = '^' . s:GetMailSeparatorPattern() . '\@!.*\n' . s:GetMailSeparatorPattern() . '\?From:\s\|\%$'
	return CountJump#CountSearch(a:count, [l:separatorPattern, 'W'])
    else
	return CountJump#Region#JumpToRegionEnd(a:count, s:MakeQuotePattern(s:quotePrefix, a:isInner), 1, 1, 0)
    endif
endfunction
call CountJump#TextObject#MakeWithJumpFunctions('<buffer>', 'q', 'aI', 'V',
\   s:function('s:JumpToQuoteBegin'),
\   s:function('s:JumpToQuoteEnd'),
\)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
