let s:virtual_prop_type = 'unicode_preview_virtual'

function! unicode_preview#show() abort
	let b:unicode_preview_enabled = 1
	unlet! b:unicode_preview_last_range
	call unicode_preview#refresh()
endfunction

function! unicode_preview#hide() abort
	call s:clear_virtual()
	let b:unicode_preview_enabled = 0
	unlet! b:unicode_preview_last_range
endfunction

function! unicode_preview#toggle() abort
	if get(b:, 'unicode_preview_enabled', 0)
		call unicode_preview#hide()
	else
		call unicode_preview#show()
	endif
endfunction

function! unicode_preview#refresh() abort
	if !get(b:, 'unicode_preview_enabled', 0)
		return
	endif

	let [start, end] = s:get_scan_range()
	let tick = get(b:, 'changedtick', -1)

	if exists('b:unicode_preview_last_range')
		let last = b:unicode_preview_last_range
		if last[0] == start && last[1] == end && last[2] == tick
			return
		endif
	endif

	let items = s:scan_unicode(start, end)
	call s:clear_virtual()
	call s:apply_virtual(items)

	let b:unicode_preview_last_range = [start, end, tick]
endfunction

function! unicode_preview#echo_cursor() abort
	let lnum = line('.')
	let coln = col('.')
	let items = s:scan_unicode(lnum, lnum)

	if empty(items)
		echo 'No unicode literal found on current line'
		return
	endif

	let found = s:find_item_at_or_after_cursor(items, coln)

	if empty(found)
		echo 'No unicode literal found near cursor'
		return
	endif

	echo s:format_item(found)
endfunction

function! unicode_preview#echo_line() abort
	let lnum = line('.')
	let items = s:scan_unicode(lnum, lnum)

	if empty(items)
		echo 'No unicode literal found on current line'
		return
	endif

	for item in items
		echom s:format_item(item)
	endfor
endfunction

function! s:get_scan_range() abort
	if get(g:, 'unicode_preview_visible_only', 1)
		let start = max([1, line('w0') - get(g:, 'unicode_preview_context', 20)])
		let end = min([line('$'), line('w$') + get(g:, 'unicode_preview_context', 20)])
	else
		let start = 1
		let end = line('$')
	endif

	return [start, end]
endfunction

function! s:clear_virtual() abort
	if exists('b:unicode_preview_virtual_added')
		silent! call prop_remove({'type': s:virtual_prop_type}, 1, line('$'))
		unlet! b:unicode_preview_virtual_added
	endif
endfunction

function! s:ensure_prop_type() abort
	if empty(prop_type_get(s:virtual_prop_type, {'bufnr': bufnr('%')}))
		call prop_type_add(s:virtual_prop_type, {
			\ 'bufnr': bufnr('%'),
			\ 'highlight': 'UnicodePreviewVirtual',
			\ 'combine': v:true,
			\ })
	endif

	let b:unicode_preview_virtual_added = 1
endfunction

function! s:apply_virtual(items) abort
	highlight default link UnicodePreviewVirtual Comment
	call s:ensure_prop_type()

	let byline = {}

	for item in a:items
		if !has_key(byline, item.lnum)
			let byline[item.lnum] = []
		endif
		call add(byline[item.lnum], item.char)
	endfor

	let prefix = get(g:, 'unicode_preview_prefix', '  => ')
	let sep = get(g:, 'unicode_preview_separator', ' ')

	for lnum in sort(keys(byline), 'n')
		let text = prefix . join(byline[str2nr(lnum)], sep)
		call prop_add(str2nr(lnum), 0, {
			\ 'type': s:virtual_prop_type,
			\ 'text': text,
			\ 'text_align': 'after',
			\ })
	endfor
endfunction

function! s:scan_unicode(start, end) abort
	let out = []

	for lnum in range(a:start, a:end)
		let text = getline(lnum)

		call extend(out, s:scan_line_u4(text, lnum))
		call extend(out, s:scan_line_u8(text, lnum))
		call extend(out, s:scan_line_uplus(text, lnum))
	endfor

	return out
endfunction

function! s:scan_line_u4(text, lnum) abort
	let out = []
	let pos = 0

	while 1
		let m = matchstrpos(a:text, '\\u\x\{4}', pos)
		if empty(m) || m[1] < 0
			break
		endif

		let matched = m[0]
		let hex = matched[2:]
		let ch = s:hex_to_char(hex)

		if !empty(ch)
			call add(out, {
				\ 'lnum': a:lnum,
				\ 'col': m[1] + 1,
				\ 'len': strlen(matched),
				\ 'char': ch,
				\ 'hex': 'U+' . toupper(hex),
				\ 'literal': matched,
				\ })
		endif

		let pos = m[2]
	endwhile

	return out
endfunction

function! s:scan_line_u8(text, lnum) abort
	let out = []
	let pos = 0

	while 1
		let m = matchstrpos(a:text, '\\U\x\{8}', pos)
		if empty(m) || m[1] < 0
			break
		endif

		let matched = m[0]
		let hex = matched[2:]
		let ch = s:hex_to_char(hex)

		if !empty(ch)
			let hexnorm = toupper(substitute(hex, '^0\+', '', ''))
			if empty(hexnorm)
				let hexnorm = '0'
			endif

			call add(out, {
				\ 'lnum': a:lnum,
				\ 'col': m[1] + 1,
				\ 'len': strlen(matched),
				\ 'char': ch,
				\ 'hex': 'U+' . hexnorm,
				\ 'literal': matched,
				\ })
		endif

		let pos = m[2]
	endwhile

	return out
endfunction

function! s:scan_line_uplus(text, lnum) abort
	let out = []
	let pos = 0

	while 1
		let m = matchstrpos(a:text, 'U+\x\{4,6}', pos)
		if empty(m) || m[1] < 0
			break
		endif

		let matched = m[0]
		let hex = matched[2:]
		let nr = str2nr(hex, 16)

		if nr >= 0 && nr <= 0x10FFFF
			let ch = s:codepoint_to_char(nr)
			if !empty(ch)
				call add(out, {
					\ 'lnum': a:lnum,
					\ 'col': m[1] + 1,
					\ 'len': strlen(matched),
					\ 'char': ch,
					\ 'hex': 'U+' . toupper(hex),
					\ 'literal': matched,
					\ })
			endif
		endif

		let pos = m[2]
	endwhile

	return out
endfunction

function! s:find_item_at_or_after_cursor(items, coln) abort
	let current = {}
	let nextone = {}

	for item in a:items
		let startc = item.col
		let endc = item.col + item.len - 1

		if a:coln >= startc && a:coln <= endc
			return item
		endif

		if startc > a:coln
			if empty(nextone) || startc < nextone.col
				let nextone = item
			endif
		endif

		if endc < a:coln
			let current = item
		endif
	endfor

	if !empty(nextone)
		return nextone
	endif

	return current
endfunction

function! s:format_item(item) abort
	return a:item.literal . ' => ' . a:item.char . ' (' . a:item.hex . ')'
endfunction

function! s:hex_to_char(hex) abort
	let nr = str2nr(a:hex, 16)
	return s:codepoint_to_char(nr)
endfunction

function! s:codepoint_to_char(nr) abort
	if a:nr < 0 || a:nr > 0x10FFFF
		return ''
	endif

	if a:nr >= 0xD800 && a:nr <= 0xDFFF
		return ''
	endif

	try
		return nr2char(a:nr, 1)
	catch
		return ''
	endtry
endfunction
