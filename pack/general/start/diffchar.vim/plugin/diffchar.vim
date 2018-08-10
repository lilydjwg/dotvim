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
" Last Change:	2018/07/22
" Version:		7.6
" Author:		Rick Howe <rdcxy754@ybb.ne.jp>

if exists('g:loaded_diffchar') || !has('diff')
	finish
endif
let g:loaded_diffchar = 7.6

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
	\['<F7>', '<Plug>ToggleDiffCharAllLines', ':%TDChar'],
	\['<F8>', '<Plug>ToggleDiffCharCurrentLine', ':TDChar'],
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
	" let g:DiffPairVisible = 0	" nothing visible
endif

" Set a difference unit updating while editing
if !exists('g:DiffUpdate')
	let g:DiffUpdate = 1		" enable
	" let g:DiffUpdate = 0		" disable
endif

" Set a time length (ms) to apply this plugin's internal algorithm first
if !exists('g:DiffSplitTime')
	let g:DiffSplitTime = 100	" when timeout, split to diff command
	" let g:DiffSplitTime = 0	" always apply diff command only
endif

" Set a diff mode synchronization to show/reset exact differences
if !exists('g:DiffModeSync')
	let g:DiffModeSync = 1		" enable
	" let g:DiffModeSync = 0	" disable
endif

" Set this plugin's DiffCharExpr() to the diffexpr option if empty
if !exists('g:DiffExpr')
	let g:DiffExpr = 1			" enable
	" let g:DiffExpr = 0		" disable
endif
if g:DiffExpr && empty(&diffexpr)
	let &diffexpr = 'diffchar#DiffCharExpr()'
endif

" Set an event group of this plugin
augroup diffchar
	autocmd!
	autocmd! FilterWritePost * call diffchar#SetDiffModeSync()
augroup END

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=4 sw=4
