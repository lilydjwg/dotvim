" ConflictMotions.vim: Motions to and inside SCM conflict markers.
"
" DEPENDENCIES:
"   - CountJump/Motion.vim autoload script
"   - CountJump/TextObject.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   2.00.005	18-Jan-2013	FIX: Don't create the default mapping for
"				<Plug>(ConflictMotionsTakeSelection) in select
"				mode; it should insert a literal <Leader> there.
"   2.00.004	30-Oct-2012	Add the :ConflictTake command to resolve a
"				conflict by picking a section(s).
"   1.10.003	20-Aug-2012	The [z / ]z mappings disable the built-in
"				mappings for moving over the current open fold.
"				Change default to [= / ]= / i= / a=.
"   1.00.002	28-Mar-2012	Make mappings configurable.
"				Change ix text object to iz.
"	001	12-Mar-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_ConflictMotions') || (v:version < 700)
    finish
endif
let g:loaded_ConflictMotions = 1

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

command! -bar -nargs=* -range=1 -complete=customlist,ConflictMotions#Complete ConflictTake call ConflictMotions#Take(<line1>, <line2>, <q-args>)


"- mappings --------------------------------------------------------------------

call CountJump#Motion#MakeBracketMotion('', g:ConflictMotions_ConflictBeginMapping, g:ConflictMotions_ConflictEndMapping, '^<\{7}<\@!', '^>\{7}>\@!', 0)
call CountJump#Motion#MakeBracketMotion('', g:ConflictMotions_MarkerMapping, '', '^\([<=>|]\)\{7}\1\@!', '', 0)

call CountJump#TextObject#MakeWithCountSearch('', g:ConflictMotions_ConflictMapping, 'a', 'V', '^<\{7}<\@!', '^>\{7}>\@!')
call CountJump#TextObject#MakeWithCountSearch('', g:ConflictMotions_SectionMapping, 'i', 'V', '^\([<=|]\)\{7}\1\@!', '^\([=>|]\)\{7}\1\@!')
call CountJump#TextObject#MakeWithCountSearch('', g:ConflictMotions_SectionMapping, 'a', 'V', '^\([<=|]\)\{7}\1\@!', '\ze\n\([=|]\)\{7}\1\@!\|^>\{7}>\@!')


nnoremap <Plug>(ConflictMotionsTakeNone)        :ConflictTake none<CR>
nnoremap <Plug>(ConflictMotionsTakeThis)        :ConflictTake this<CR>
nnoremap <Plug>(ConflictMotionsTakeOurs)        :ConflictTake ours<CR>
nnoremap <Plug>(ConflictMotionsTakeBase)        :ConflictTake base<CR>
nnoremap <Plug>(ConflictMotionsTakeTheirs)      :ConflictTake theirs<CR>
vnoremap <Plug>(ConflictMotionsTakeSelection)   :ConflictTake<CR>

if ! empty(g:ConflictMotions_TakeMappingPrefix)
    for [s:key, s:target] in g:ConflictMotions_TakeMappings
	execute printf('nmap %s%s <Plug>(ConflictMotionsTake%s)', g:ConflictMotions_TakeMappingPrefix, s:key, s:target)
    endfor
    unlet s:key
    unlet s:target

    execute printf('xmap %s%s <Plug>(ConflictMotionsTake%s)', g:ConflictMotions_TakeMappingPrefix, '.', 'Selection')
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
