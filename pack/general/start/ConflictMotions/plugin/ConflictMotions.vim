" ConflictMotions.vim: Motions to and inside SCM conflict markers.
"
" DEPENDENCIES:
"   - CountJump.vim plugin
"   - repeat.vim (vimscript #2136) plugin (optional)
"   - visualrepeat.vim (vimscript #3848) plugin (optional)
"
" Copyright: (C) 2012-2020 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ConflictMotions') || (v:version < 700)
    finish
endif
let g:loaded_ConflictMotions = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:ConflictMotions_ConflictBeginMapping')
    let g:ConflictMotions_ConflictBeginMapping = 'x'
endif
if ! exists('g:ConflictMotions_ConflictEndMapping')
    let g:ConflictMotions_ConflictEndMapping = 'X'
endif
if ! exists('g:ConflictMotions_MarkerMapping')
    let g:ConflictMotions_MarkerMapping = '='
endif

if ! exists('g:ConflictMotions_ConflictMapping')
    let g:ConflictMotions_ConflictMapping = 'x'
endif
if ! exists('g:ConflictMotions_SectionMapping')
    let g:ConflictMotions_SectionMapping = '='
endif

if ! exists('g:ConflictMotions_TakeMappingPrefix')
    let g:ConflictMotions_TakeMappingPrefix = '<Leader>x'
endif
if ! exists('g:ConflictMotions_TakeMappings')
    let g:ConflictMotions_TakeMappings = [['d', 'None'], ['.', 'This'], ['<lt>', 'Ours'], ['<Bar>', 'Base'], ['>', 'Theirs']]
endif



"- commands --------------------------------------------------------------------

command! -bar -nargs=* -range=-1 -complete=customlist,ConflictMotions#Complete ConflictTake if ! ConflictMotions#Take(<count> != -1, <line1>, <line2>, <q-args>) | echoerr ingo#err#Get() | endif



"- mappings --------------------------------------------------------------------

call CountJump#Motion#MakeBracketMotion('', g:ConflictMotions_ConflictBeginMapping, g:ConflictMotions_ConflictEndMapping, '^<\{7}<\@!', '^>\{7}>\@!', 0)
call CountJump#Motion#MakeBracketMotion('', g:ConflictMotions_MarkerMapping, '', '^\([<=>|]\)\{7}\1\@!', '', 0)

call CountJump#TextObject#MakeWithCountSearch('', g:ConflictMotions_ConflictMapping, 'a', 'V', '^<\{7}<\@!', '^>\{7}>\@!')
call CountJump#TextObject#MakeWithCountSearch('', g:ConflictMotions_SectionMapping, 'i', 'V', '^\([<=|]\)\{7}\1\@!', '^\([=>|]\)\{7}\1\@!')
call CountJump#TextObject#MakeWithCountSearch('', g:ConflictMotions_SectionMapping, 'a', 'V', '^\([<=|]\)\{7}\1\@!', '\ze\n\([=|]\)\{7}\1\@!\|^>\{7}>\@!')


noremap <silent> <Plug>(ConflictMotionsTakeNone)
\ :ConflictTake mapping none<Bar>
\execute 'silent! call repeat#set("\<lt>Plug>(ConflictMotionsTakeNone)", -1)'<Bar>
\execute 'silent! call visualrepeat#set("\<lt>Plug>(ConflictMotionsTakeNone)", -1)'<CR>
noremap <silent> <Plug>(ConflictMotionsTakeOurs)
\ :ConflictTake mapping ours<Bar>
\execute 'silent! call repeat#set("\<lt>Plug>(ConflictMotionsTakeOurs)", -1)'<Bar>
\execute 'silent! call visualrepeat#set("\<lt>Plug>(ConflictMotionsTakeOurs)", -1)'<CR>
noremap <silent> <Plug>(ConflictMotionsTakeBase)
\ :ConflictTake mapping base<Bar>
\execute 'silent! call repeat#set("\<lt>Plug>(ConflictMotionsTakeBase)", -1)'<Bar>
\execute 'silent! call visualrepeat#set("\<lt>Plug>(ConflictMotionsTakeBase)", -1)'<CR>
noremap <silent> <Plug>(ConflictMotionsTakeTheirs)
\ :ConflictTake mapping theirs<Bar>
\execute 'silent! call repeat#set("\<lt>Plug>(ConflictMotionsTakeTheirs)", -1)'<Bar>
\execute 'silent! call visualrepeat#set("\<lt>Plug>(ConflictMotionsTakeTheirs)", -1)'<CR>

nnoremap <silent> <Plug>(ConflictMotionsTakeThis)
\ :ConflictTake mapping this<Bar>
\execute 'silent! call repeat#set("\<lt>Plug>(ConflictMotionsTakeThis)", -1)'<Bar>
\execute 'silent! call visualrepeat#set("\<lt>Plug>(ConflictMotionsTakeThis)", -1)'<CR>
" The "this" section conflicts with a visual selection, as the cursor cannot be
" positioned inside it (only on the borders). Therefore, disable repeat across
" modes.
vnoremap <silent> <Plug>(ConflictMotionsTakeThis)        :<C-u>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<CR>gv

noremap <silent> <Plug>(ConflictMotionsTakeSelection)
\ :ConflictTake mapping<Bar>
\execute 'silent! call repeat#set("\<lt>Plug>(ConflictMotionsTakeSelection)", -1)'<Bar>
\execute 'silent! call visualrepeat#set("\<lt>Plug>(ConflictMotionsTakeSelection)", -1)'<CR>
" Repeat taking the selected lines as taking the current section in normal mode.


if ! empty(g:ConflictMotions_TakeMappingPrefix)
    for [s:key, s:target] in g:ConflictMotions_TakeMappings
	for s:mode in ['n', 'x']
	    if s:target ==# 'This' && s:mode ==# 'x'
		" Special case: Use separate mapping targets for normal and
		" visual mode, so that we get different repeat behavior across
		" modes.
		let s:target = 'Selection'
	    endif

	    execute printf('%smap %s%s <Plug>(ConflictMotionsTake%s)', s:mode, g:ConflictMotions_TakeMappingPrefix, s:key, s:target)
	endfor
    endfor
    unlet s:key
    unlet s:target
    unlet s:mode
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
