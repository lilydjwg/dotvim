" diffchar.vim: Highlight the exact differences, based on characters and words
"
"  ____   _  ____  ____  _____  _   _  _____  ____   
" |    | | ||    ||    ||     || | | ||  _  ||  _ |  
" |  _  || ||  __||  __||     || | | || | | || | ||  
" | | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
" | |_| || ||  __||  __||  |   |     ||     ||  __  |
" |     || || |   | |   |  |__ |  _  ||  _  || |  | |
" |____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
"
" Last Change:	2019/03/22
" Version:		8.5
" Author:		Rick Howe <rdcxy754@ybb.ne.jp>
" Copyright:	(c) 2014-2019 by Rick Howe

if exists('g:loaded_diffchar') || !has('diff') || v:version < 800
	finish
endif
let g:loaded_diffchar = 8.5

let s:save_cpo = &cpoptions
set cpo&vim

" Commands
command! -range -bar SDChar
				\ call diffchar#ShowDiffChar(range(<line1>, <line2>))
command! -range -bar RDChar
				\ call diffchar#ResetDiffChar(range(<line1>, <line2>))
command! -range -bar TDChar
				\ call diffchar#ToggleDiffChar(range(<line1>, <line2>))
command! -range -bang -bar EDChar
				\ call diffchar#EchoDiffChar(range(<line1>, <line2>), <bang>1)

" Configurable Keymaps
for [key, plg, cmd] in [
	\['[b', '<Plug>JumpDiffCharPrevStart',
									\':call diffchar#JumpDiffChar(0, 0)'],
	\[']b', '<Plug>JumpDiffCharNextStart',
									\':call diffchar#JumpDiffChar(1, 0)'],
	\['[e', '<Plug>JumpDiffCharPrevEnd',
									\':call diffchar#JumpDiffChar(0, 1)'],
	\[']e', '<Plug>JumpDiffCharNextEnd',
									\':call diffchar#JumpDiffChar(1, 1)'],
	\['<Leader>g', '<Plug>GetDiffCharPair',
									\':call diffchar#CopyDiffCharPair(0)'],
	\['<Leader>p', '<Plug>PutDiffCharPair',
									\':call diffchar#CopyDiffCharPair(1)']]
	if !hasmapto(plg, 'n') && empty(maparg(key, 'n'))
		execute 'nmap <silent> ' . key . ' ' . plg
	endif
	execute 'nnoremap <silent> ' plg . ' ' . cmd . '<CR>'
endfor

" Set a difference unit type
if !exists('g:DiffUnit')
	let g:DiffUnit = 'Word1'	" \w\+ word and any \W single character
	" let g:DiffUnit = 'Word2'	" non-space and space words
	" let g:DiffUnit = 'Word3'	" \< or \> character class boundaries
	" let g:DiffUnit = 'Char'	" any single character
	" let g:DiffUnit = 'CSV(,)'	" split characters
endif

" Set a difference unit matching colors
if !exists('g:DiffColors')
	let g:DiffColors = 0		" always 1 color
	" let g:DiffColors = 1		" 4 colors in fixed order
	" let g:DiffColors = 2		" 8 colors in fixed order
	" let g:DiffColors = 3		" 16 colors in fixed order
	" let g:DiffColors = 100	" all available colors in dynamic random order
endif

" Make a corresponding unit visible when cursor is moved on a diff unit
if !exists('g:DiffPairVisible')
	let g:DiffPairVisible = 2	" cursor-like highlight + echo
	" let g:DiffPairVisible = 1	" cursor-like highlight
	" let g:DiffPairVisible = 0	" disable
endif

" Set a diff mode synchronization to show/reset/update exact differences
if !exists('g:DiffModeSync')
	let g:DiffModeSync = 1		" enable
	" let g:DiffModeSync = 0	" disable
endif

" Set a number of maximum DiffChange lines to be dynamically detected
if !exists('g:DiffMaxLines')
	let g:DiffMaxLines = -3		" 3 times as many lines as higher window
	" let g:DiffMaxLines = 50	" 50 lines including visible ones
	" let g:DiffMaxLines = 1	" as few as visible lines
	" let g:DiffMaxLines = 0	" disable and statically detect all lines
endif

" Set this plugin's DiffCharExpr() to the diffexpr option if empty
" and when internal diff is not used
if !exists('g:DiffExpr')
	let g:DiffExpr = 1			" enable
	" let g:DiffExpr = 0		" disable
endif
if g:DiffExpr && empty(&diffexpr) && &diffopt !~ 'internal'
	let &diffexpr = 'diffchar#DiffCharExpr()'
endif

" Set an event group of this plugin
augroup diffchar
	autocmd!
	if has('patch-8.0.736')			" OptionSet triggered with diff option
		autocmd OptionSet diff call diffchar#ToggleDiffModeSync(0)
		autocmd VimEnter *
					\ if &diff | call diffchar#ToggleDiffModeSync(1) | endif |
												\ autocmd! diffchar VimEnter
	else
		autocmd FilterWritePost * call diffchar#SetDiffModeSync()
	endif
augroup END

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=4 sw=4
