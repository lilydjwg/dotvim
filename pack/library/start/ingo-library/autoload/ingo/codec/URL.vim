" ingo/codec/URL.vim: URL encoding / decoding.
"
" DEPENDENCIES:
"   - ingo/collections/fromsplit.vim autoload script
"
" Copyright: (C) 2012-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Source:
"   Encoding / decoding algorithms taken from unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.028.004	10-Oct-2016	ingo#codec#URL#Decode(): Also convert the
"				character set to UTF-8 to properly handle
"				non-ASCII characters. For example, %C3%9C should
"				decode to "Ü", not to "É".
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

function! ingo#codec#URL#DecodeAndConvertCharset( urlEscapedText )
    let l:decodedText = substitute(a:urlEscapedText, '%\(\x\x\)', '\=nr2char(''0x'' . submatch(1))', 'g')
    "let l:convertedText = subs#Charset#LatinToUtf8(l:decodedText)
    let l:convertedText = iconv(l:decodedText, 'utf-8', 'latin1')
    return l:convertedText
endfunction
function! ingo#codec#URL#Decode( text )
    let l:text = substitute(substitute(substitute(a:text, '%0[Aa]\n$', '%0A', ''), '%0[Aa]', '\n', 'g'), '+', ' ', 'g')
    return join(ingo#collections#fromsplit#MapSeparators(l:text, '\%(%\x\x\)\+', 'ingo#codec#URL#DecodeAndConvertCharset(v:val)'), '')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
