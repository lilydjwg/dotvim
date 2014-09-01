" ingo/codec/URL.vim: URL encoding / decoding.
"
" DEPENDENCIES:
"
" Copyright: (C) 2012-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Source:
"   Encoding / decoding algorithms taken from unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.019.003	20-May-2014	Move into ingo library, because this is now used
"				by multiple plugins.
"	002	09-May-2012	Add subs#URL#FilespecEncode() that does not
"				encoding the path separator "/". This is useful
"				for encoding normal filespecs.
"	001	30-Mar-2012	file creation

function! s:Encode( chars, text )
    return substitute(a:text, a:chars, '\="%" . printf("%02X", char2nr(submatch(0)))', 'g')
endfunction
function! ingo#codec#URL#Encode( text )
    return s:Encode('[^A-Za-z0-9_.~-]', a:text)
endfunction
function! ingo#codec#URL#FilespecEncode( text )
    return s:Encode('[^A-Za-z0-9_./~-]', substitute(a:text, '\\', '/', 'g'))
endfunction

function! ingo#codec#URL#Decode( text )
    let l:text = substitute(substitute(substitute(a:text, '%0[Aa]\n$', '%0A', ''), '%0[Aa]', '\n', 'g'), '+', ' ', 'g')
    return substitute(l:text, '%\(\x\x\)', '\=nr2char("0x" . submatch(1))', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
