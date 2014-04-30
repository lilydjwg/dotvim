" SameSyntaxMotion.vim: Motions to the borders of the same syntax highlighting.
"
" DEPENDENCIES:
"   - SameSyntaxMotion.vim autoload script
"   - CountJump.vim, CountJump/Motion.vim autoload scripts, version 1.80 or
"     higher
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.004	17-Sep-2012	Define an inner text object, too.
"	003	14-Sep-2012	Rename config variables.
"				Implement text object.
"	002	13-Sep-2012	Implement the full set of the four begin/end
"				forward/backward mappings.
"				Implement skipping over unhighlighted
"				whitespace when its surrounded by the same
"				syntax area on both sides.
"	001	12-Sep-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_SameSyntaxMotion') || (v:version < 702) || ! exists('*synstack')
    finish
endif
let g:loaded_SameSyntaxMotion = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:SameSyntaxMotion_BeginMapping')
    let g:SameSyntaxMotion_BeginMapping = 'y'
endif
if ! exists('g:SameSyntaxMotion_EndMapping')
    let g:SameSyntaxMotion_EndMapping = 'Y'
endif
if ! exists('g:SameSyntaxMotion_TextObjectMapping')
    let g:SameSyntaxMotion_TextObjectMapping = 'y'
endif



"- mappings --------------------------------------------------------------------

call CountJump#Motion#MakeBracketMotionWithJumpFunctions('', g:SameSyntaxMotion_BeginMapping, g:SameSyntaxMotion_EndMapping,
\   function('SameSyntaxMotion#BeginForward'),
\   function('SameSyntaxMotion#BeginBackward'),
\   function('SameSyntaxMotion#EndForward'),
\   function('SameSyntaxMotion#EndBackward'),
\   1)
call CountJump#TextObject#MakeWithJumpFunctions('', g:SameSyntaxMotion_TextObjectMapping, 'aI', 'v',
\   function('SameSyntaxMotion#TextObjectBegin'),
\   function('SameSyntaxMotion#TextObjectEnd')
\)

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
