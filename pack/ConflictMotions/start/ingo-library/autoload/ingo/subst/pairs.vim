" ingo/subst/pairs.vim: Function to substitute wildcard=replacement pairs.
"
" DEPENDENCIES:
"   - ingo/fs/path.vim autoload script
"   - ingo/regexp/fromwildcard.vim autoload script
"
" Copyright: (C) 2014-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.025.004	18-May-2015	ingo#subst#pairs#Substitute() and
"				ingo#subst#pairs#Split(): Only canonicalize path
"				separators in {replacement} on demand, via
"				additional a:isCanonicalizeReplacement argument.
"				Some clients may not need iterative replacement,
"				and treat the wildcard as a convenient
"				regexp-shorthand, not overly filesystem-related.
"   1.025.003	01-May-2015	ingo#subst#pairs#Substitute(): Canonicalize path
"				separators in {replacement}, too. This is
"				important to match further pairs, too, as the
"				pattern is always in canonical form, so the
"				replacement has to be, too.
"				ENH: Allow passing to
"				ingo#subst#pairs#Substitute() [wildcard,
"				replacement] Lists instead of
"				{wildcard}={replacement} Strings, too.
"   1.016.002	17-Jan-2014	Change s:pairPattern so that the first, not the
"				last = is used as the pair delimiter.
"   1.016.001	16-Jan-2014	file creation from
"				autoload/EditSimilar/Substitute.vim

let s:pairPattern = '\(^[^=]\+\)=\(.*$\)'
function! s:SplitPair( pair, isCanonicalizeReplacement )
    if type(a:pair) == type([])
	let [l:from, l:to] = a:pair
    else
	if a:pair !~# s:pairPattern
	    throw 'Substitute: Not a substitution: ' . a:pair
	endif
	let [l:from, l:to] = matchlist(a:pair, s:pairPattern)[1:2]
    endif
    return [ingo#regexp#fromwildcard#Convert(l:from), (a:isCanonicalizeReplacement ? ingo#fs#path#Normalize(l:to) : l:to)]
endfunction
function! ingo#subst#pairs#Split( pairs, ... )
    let l:isCanonicalizeReplacement = (a:0 ? a:1 : 0)
    return map(a:pairs, 's:SplitPair(v:val, l:isCanonicalizeReplacement)')
endfunction
function! ingo#subst#pairs#Substitute( text, pairs, ... )
"******************************************************************************
"* PURPOSE:
"   Apply {wildcard}={replacement} pairs (modeled after the Korn shell's "cd
"   {old} {new}" command).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text  Text to be substituted.
"   a:pairs List of {wildcard}={replacement} Strings that should be applied to
"	    a:text. Or List of [wildcard, replacement] List elements.
"   a:isCanonicalizeReplacement Optional flag whether path separators in
"				{replacement} should be canonicalized. This is
"				important when doing further substitutions on
"				the result, but may be unwanted when wildcards
"				are treated as a convenient regexp-shorthand.
"				Default is false, no canonicalization.
"* RETURN VALUES:
"   List of [replacement, failedPairs], where failedPairs is a subset of
"   a:pairs.
"******************************************************************************
    let l:isCanonicalizeReplacement = (a:0 ? a:1 : 0)
    let l:replacement = a:text
    let l:failedPairs = []

    for l:pair in a:pairs
	let [l:from, l:to] = s:SplitPair(l:pair, l:isCanonicalizeReplacement)
	let l:beforeReplacement = l:replacement
	let l:replacement = substitute(l:replacement, l:from, escape(l:to, '\&~'), 'g')
	if l:replacement ==# l:beforeReplacement
	    call add(l:failedPairs, l:pair)
	endif
"***D echo '****' (l:beforeReplacement =~ ingo#regexp#fromwildcard#Convert(l:from) ? '' : 'no ') . 'match for pair' ingo#regexp#fromwildcard#Convert(l:from)
"***D echo '**** replacing' l:beforeReplacement "\n          with" l:replacement
    endfor

    return [l:replacement, l:failedPairs]
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
