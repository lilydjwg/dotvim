" mangl.vim : a vim syntax highlighting file for man pages on GL
"   Author: Charles E. Campbell, Jr.
"   Date:   Nov 23, 2010
"   Version: 1a	NOT RELEASED
" ---------------------------------------------------------------------
syn clear
let b:current_syntax = "mangl"

syn keyword manglGLType		GLbyte GLenum GLshort GLint GLdouble GLubyte GLuint GLfloat GLushort
syn keyword manglCType		const void char short int long double unsigned
syn match	manglCType		'\s\*\s'
syn match	manglGLKeyword	'\<[A-Z_]\{2,}\>'
syn keyword	manglNormal		GL

syn match	manglTitle		'^\s*\%(Name\|C Specification\|Parameters\|Description\|Notes\|Associated Gets\|See Also\|Copyright\|Errors\|References\)\s*$'
syn match	manglNmbr		'\<\d\+\%(\.\d*\)\=\>'
syn match	manglDelim		'[()]'

hi def link manglGLType		Type
hi def link manglCType		Type
hi def link manglTitle		Title
hi def link manglNmbr		Number
hi def link manglDelim		Delimiter
hi def link manglGLKeyword	Keyword

" cleanup
if !exists("g:mangl_nocleanup")
 setlocal mod ma noro
 %s/ ? /   /ge
 %s/\[\d\+]//ge
 %s/\(\d\+\)\s\+\*\s\+/\1*/ge
 %s@\<N\> \(\d\)@N/\1@ge
 setlocal nomod noma ro
endif
