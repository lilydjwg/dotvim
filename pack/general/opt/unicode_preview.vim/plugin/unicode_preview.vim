if exists('g:loaded_unicode_preview')
	finish
endif
let g:loaded_unicode_preview = 1

command! UnicodePreviewShow     call unicode_preview#show()
command! UnicodePreviewHide     call unicode_preview#hide()
command! UnicodePreviewRefresh  call unicode_preview#refresh()
command! UnicodePreviewToggle   call unicode_preview#toggle()
command! UnicodePreviewEcho     call unicode_preview#echo_cursor()
command! UnicodePreviewEchoLine call unicode_preview#echo_line()

augroup UnicodePreview
	autocmd!
	autocmd BufEnter * call s:maybe_auto_enable()
	autocmd WinScrolled * if get(b:, 'unicode_preview_enabled', 0) | call unicode_preview#refresh() | endif
	autocmd TextChanged,TextChangedI * if get(b:, 'unicode_preview_enabled', 0) | call unicode_preview#refresh() | endif
augroup END

function! s:maybe_auto_enable() abort
	if !exists('b:unicode_preview_enabled')
		if get(g:, 'unicode_preview_auto_enable', 1)
			call unicode_preview#show()
		else
			let b:unicode_preview_enabled = 0
		endif
	endif
endfunction
