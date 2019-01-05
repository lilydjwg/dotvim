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
" Last Change:	2018/11/18
" Version:		8.1
" Author:		Rick Howe <rdcxy754@ybb.ne.jp>
" Copyright:	(c) 2014-2018 by Rick Howe

let s:save_cpo = &cpoptions
set cpo&vim

" Vim feature, function, event and patch number which this plugin depends on
" patch-8.0.736:  OptionSet event triggered with diff option
" patch-8.0.1038: strikethrough attribute available
" patch-8.0.1160: gettabvar() fixed not to return empty
" patch-8.0.1204: QuitPre fixed to represent affected buffer in <abuf>
" patch-8.0.1290: changenr() fixed to return correct value
let s:VF = {
	\'DiffUpdated': exists('##DiffUpdated'),
	\'GUIColors': has('gui_running') ||
									\has('termguicolors') && &termguicolors,
	\'DiffOptionSet': has('patch-8.0.736'),
	\'StrikeAttr': has('patch-8.0.1038') &&
					\(has('gui_running') || !empty(&t_Ts) && !empty(&t_Te)),
	\'GettabvarFixed': has('patch-8.0.1160'),
	\'QuitPreAbufFixed': has('patch-8.0.1204'),
	\'ChangenrFixed': has('patch-8.0.1290')}

" set highlight groups used for diffchar
function! s:DefineDiffCharHL()
	let s:DCharHL = {'A': 'DiffAdd', 'C': 'DiffChange', 'D': 'DiffDelete',
					\'T': 'DiffText', 'oC': 'DiffChange', 'oT': 'DiffText',
											\'n': 'LineNr', 'c': 'VertSplit'}
	for hl in split(&highlight, ',')
		" get a hl name from highlight option
		if index(keys(s:DCharHL), hl[0]) != -1 && hl[1] == ':'
			let s:DCharHL[hl[0]] = hl[2:]
		endif
	endfor
	if s:VF.GUIColors | let s:DCharHL.c = 'Cursor' | endif
	let s:DiffCTHL = {s:DCharHL.C: {}, s:DCharHL.T: {}}
	for [fh, th, hn, at] in
					\ [['C', 'E', 'dcDiffErase', ['bold', 'underline']]] +
				\(s:VF.StrikeAttr ?
					\[['D', 'D', 'dcDiffDelete', ['strikethrough']]] : []) +
			\[['C', 'C', 'dcDiffChange', []], ['T', 'T', 'dcDiffText', []]]
		let hd = hlID(s:DCharHL[fh])
		let ha = []
		for hm in ['term', 'cterm', 'gui']
			let ha += map(['fg', 'bg', 'sp'],
							\'hm . v:val . "=" . synIDattr(hd, v:val, hm)')
			let ha += [hm . '=' . join(filter(['bold', 'italic', 'reverse',
						\'inverse', 'standout', 'underline', 'undercurl'] +
								\(s:VF.StrikeAttr ? ['strikethrough'] : []),
								\'synIDattr(hd, v:val, hm) == 1') + at, ',')]
		endfor
		silent execute 'highlight clear ' . hn
		let hx = join(filter(ha, 'v:val !~ "=\\(-1\\)\\=$"'))
		if !empty(hx)
			silent execute 'highlight ' . hn . ' ' . hx
		endif
		if th == 'C' || th == 'T'
			" 0: original, 1: for single color, 2: for multi color
			let hy = join(filter(ha, 'v:val =~ "bg="'))		" bg only
			let s:DiffCTHL[s:DCharHL[th]] =
									\{0: hx, 1: hy, 2: (th == 'T') ? '' : hy}
		endif
		let s:DCharHL[th] = hn
	endfor
	call s:ChangeDiffCTHL(exists('t:DChar.ovd'))
endfunction

function! s:InitializeDiffChar()
	" select current and next diff mode windows whose buffer is different
	let cwin = win_getid()
	if !getwinvar(cwin, '&diff')
		call s:EchoWarning('Current window is not diff mode!')
		return -1
	endif
	let nwin = filter(map(
					\range(winnr() + 1, winnr('$')) + range(1, winnr() - 1),
														\'win_getid(v:val)'),
				\'winbufnr(v:val) != bufnr("%") && getwinvar(v:val, "&diff")')
	if empty(nwin)
		call s:EchoWarning('Need more diff mode buffers in this tab page!')
		return -1
	endif
	" check if both or either of selected windows have already been DChar
	" highlighted in other tab pages
	let dwin = win_findbuf(winbufnr(cwin)) + win_findbuf(winbufnr(nwin[0]))
	for tp in filter(range(1, tabpagenr('$')), 'tabpagenr() != v:val')
		let td = s:Gettabvar(tp, 'DChar')
		if !empty(td)
			for dw in values(td.wid)
				if index(dwin, dw) != -1
					call s:EchoWarning('Both or either selected buffer already
									\ highlighted in tab page ' . tp . '!')
					return -1
				endif
			endfor
		endif
	endfor
	" define diffchar highlights
	call s:DefineDiffCharHL()
	" define a DiffChar dictionary on this tab page
	let t:DChar = {}
	let t:DChar.wid = {'1': cwin, '2': nwin[0]}
	" set a diff mode synchronization flag
	let t:DChar.dsy = get(t:, 'DiffModeSync', g:DiffModeSync)
	" set a number of maximum lines to be automatically detected
	let t:DChar.mxl = t:DChar.dsy ?
								\get(t:, 'DiffMaxLines', g:DiffMaxLines) : 0
	if 0 < t:DChar.mxl
		let t:DChar.mxw = {}
		for k in [1, 2]
			noautocmd call win_gotoid(t:DChar.wid[k])
			let t:DChar.mxw[k] = [line('w0'), line('w$'), s:Changenr()]
		endfor
		noautocmd call win_gotoid(cwin)
	endif
	let t:DChar.dml = s:SetDiffModeLines()
	if index(values(t:DChar.dml), []) != -1
		unlet t:DChar
		return -1
	endif
	" set a record of change number and # of lines for update
	if t:DChar.dsy
		let t:DChar.pcn = {}
		for k in [1, 2]
			noautocmd call win_gotoid(t:DChar.wid[k])
			let t:DChar.pcn[k] = [s:Changenr(), line('$')]
		endfor
	endif
	" set a difference unit pair view while moving cursor
	let t:DChar.dpv = get(t:, 'DiffPairVisible', g:DiffPairVisible)
	if t:DChar.dpv
		let t:DChar.cpi = {}	" pair cursor position and mid
		let t:DChar.clc = {}	" previous cursor line/col
		for k in [1, 2]
			noautocmd call win_gotoid(t:DChar.wid[k])
			let t:DChar.clc[k] = [line('.'), col('.'), b:changedtick]
		endfor
	endif
	noautocmd call win_gotoid(cwin)
	" set line and its highlight id record
	let t:DChar.mid = {'1': {}, '2': {}}
	" set highlighted lines and columns record
	let t:DChar.hlc = {'1': {}, '2': {}}
	" set a checksum record for each highlighted line
	let t:DChar.cks = {'1': {}, '2': {}}
	" set ignorecase and ignorespace flags
	let do = split(&diffopt, ',')
	let t:DChar.igc = (index(do, 'icase') != -1)
	let t:DChar.igs = (index(do, 'iwhiteall') != -1) ? 1 :
									\(index(do, 'iwhite') != -1) ? 2 :
									\(index(do, 'iwhiteeol') != -1) ? 3 : 0
	" set a difference unit type on this tab page and set a split pattern
	let du = get(t:, 'DiffUnit', g:DiffUnit)
	if du == 'Char'				" any single character
		let t:DChar.upa = '\zs'
	elseif du == 'Word2'		" non-space and space words
		let t:DChar.upa = '\%(\s\+\|\S\+\)\zs'
	elseif du == 'Word3'		" \< or \> boundaries
		let t:DChar.upa = '\<\|\>'
	elseif du =~ '^CSV(.\+)$'	" split characters
		let s = escape(du[4 : -2], '^-]')
		let t:DChar.upa = '\%([^'. s . ']\+\|[' . s . ']\)\zs'
	elseif du =~ '^SRE(.\+)$'	" split regular expression
		let t:DChar.upa = du[4 : -2]
	else
		" \w\+ word and any \W character
		let t:DChar.upa = '\%(\w\+\|\W\)\zs'
		if du != 'Word1'
			call s:EchoWarning('Not a valid difference unit type.
													\ Use "Word1" instead.')
		endif
	endif
	" set a time length (ms) to apply this plugin's builtin function first
	let t:DChar.dst = get(t:, 'DiffSplitTime', g:DiffSplitTime)
	" set a difference matching colors on this tab page
	let t:DChar.hgp = [s:DCharHL.T]
	let dc = get(t:, 'DiffColors', g:DiffColors)
	if 1 <= dc && dc <= 3
		let t:DChar.hgp += ['SpecialKey', 'Search', 'CursorLineNr',
						\'Visual', 'WarningMsg', 'StatusLineNC', 'MoreMsg',
						\'ErrorMsg', 'LineNr', 'Conceal', 'NonText',
						\'ColorColumn', 'ModeMsg', 'PmenuSel', 'Title']
									\[: ((dc == 1) ? 2 : (dc == 2) ? 6 : -1)]
	elseif dc == 100
		let hl = {}
		let id = 1
		while 1
			let nm = synIDattr(id, 'name')
			if empty(nm) | break | endif
			if index(values(s:DCharHL), nm) == -1 && id == synIDtrans(id) &&
				\!empty(filter(['fg', 'bg', 'sp', 'bold', 'italic', 'reverse',
							\'inverse', 'standout', 'underline', 'undercurl',
						\'strikethrough'], '!empty(synIDattr(id, v:val))'))
				let hl[reltimestr(reltime())[-2 :] . id] = nm
			endif
			let id += 1
		endwhile
		let t:DChar.hgp += values(hl)
	endif
endfunction

function! diffchar#ToggleDiffChar(lines)
	if exists('t:DChar')
		for k in [1, 2, 0]
			if k == 0 | return | endif
			if t:DChar.wid[k] == win_getid() | break | endif
		endfor
		for hl in keys(t:DChar.hlc[k])
			if index(a:lines, eval(hl)) != -1
				call diffchar#ResetDiffChar(a:lines)
				return
			endif
		endfor
	endif
	call diffchar#ShowDiffChar(a:lines)
endfunction

function! diffchar#ShowDiffChar(...)
	if a:0 && empty(a:1) | return | endif
	if !exists('t:DChar') && s:InitializeDiffChar() == -1 | return | endif
	let init = (index(values(t:DChar.hlc), {}) != -1)
	let cwin = win_getid()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.wid[k] == cwin | break | endif
	endfor
	let [d1, d2] = (a:0 && (a:1[0] != 1 || a:1[-1] != line('$'))) ?
							\s:GetDiffModeLines(k, a:1) :
								\[copy(t:DChar.dml[1]), copy(t:DChar.dml[2])]
	for k in [1, 2]
		call filter(d{k}, '!has_key(t:DChar.hlc[k], v:val)')
		let bn = winbufnr(t:DChar.wid[k])
		let u{k} = filter(map(copy(d{k}),
						\'get(getbufline(bn, v:val), 0, -1)'), 'v:val != -1')
		let n{k} = len(u{k})
		if n{k} < len(d{k}) | unlet d{k}[n{k} :] | endif
	endfor
	if n1 == n2 | let ln = n1
	elseif n1 < n2 | unlet d2[n1 :] | let ln = n1
	else | unlet d1[n2 :] | let ln = n2
	endif
	let save_igc = &ignorecase
	let &ignorecase = t:DChar.igc
	let uu = []
	for n in range(ln)
		if t:DChar.igs
			for k in [1, 2]
				let s{k} = split(substitute(u{k}[n], '\s\+$', '', ''),
																\t:DChar.upa)
				if t:DChar.igs == 1				" iwhieall
					call filter(s{k}, 'v:val !~ "^\\s\\+$"')
				elseif t:DChar.igs == 2			" iwhite
					let s = len(s{k}) - 1
					while 0 < s
						if s{k}[s - 1] . s{k}[s] =~ '^\s\+$'
							let s{k}[s - 1] .= s{k}[s]
							unlet s{k}[s]
						endif
						let s -= 1
					endwhile
				endif
			endfor
		else
			for k in [1, 2]
				let s{k} = split(u{k}[n], t:DChar.upa)
			endfor
		endif
		if s1 == s2
			for k in [1, 2]
				let d{k}[n] = -1
				let u{k}[n] = -1
			endfor
		else
			let uu += [[s1, s2]]
		endif
	endfor
	for k in [1, 2]
		call filter(d{k}, 'v:val != -1')
		call filter(u{k}, 'v:val != -1')
	endfor
	if empty(uu)
		if init | unlet t:DChar | endif
		let &ignorecase = save_igc
		return
	endif
	let [lc1, lc2] = [[], []]
	let ln = 0
	for fn in ['ApplyBuiltinFunction', 'ApplyDiffCommand']
		" apply the builtin function first, if timeout, the diff command next
		for es in s:{fn}(uu[ln :])
			let [c1, c2] = s:GetDiffUnitPos(es, uu[ln])
			if t:DChar.igs == 1
				" adjust unit position with actual white spaces on iwhiteall
				for k in [1, 2]
					if u{k}[ln] =~ '\s\+'
						let ap = filter(range(1, len(u{k}[ln])),
											\'u{k}[ln][v:val - 1] !~ "\\s"')
						call map(c{k}, '[v:val[0],
								\[ap[v:val[1][0] - 1], ap[v:val[1][1] - 1]]]')
					endif
				endfor
			endif
			let [lc1, lc2] += [[[d1[ln], c1]], [[d2[ln], c2]]]
			let ln += 1
		endfor
	endfor
	let &ignorecase = save_igc
	for k in [1, 2]
		noautocmd call win_gotoid(t:DChar.wid[k])
		call s:HighlightDiffChar(k, filter(lc{k}, '!empty(v:val)'))
		for ix in range(len(d{k}))
			let t:DChar.cks[k][d{k}[ix]] = s:ChecksumStr(u{k}[ix])
		endfor
		if !init
			" delete diff HL on diffchar highlighted lines when not first
			call s:DeleteDiffHL(d{k})
		endif
	endfor
	noautocmd call win_gotoid(cwin)
	if index(values(t:DChar.hlc), {}) == -1
		if t:DChar.dpv
			call s:ShowDiffCharPair((t:DChar.wid[1] == cwin) ? 1 : 2)
		endif
		if init			" set event when DChar HL is newly defined
			call s:ToggleDiffCharEvent(1)
			call s:ToggleDiffHL(1)
		endif
	else
		unlet t:DChar
	endif
endfunction

function! s:ApplyBuiltinFunction(uu)
	let st = executable('diff') ? reltime() : []
	let es = []
	for [u1, u2] in a:uu
		if !empty(st) && t:DChar.dst <= eval(reltimestr(reltime(st))) * 1000
			break						" if timeout, break here
		endif
		if t:DChar.igs == 2				" iwhite
			for k in [1, 2]
				let u{k} = map(copy(u{k}),
									\'(v:val =~ "^\\s\\+$") ? " " : v:val')
			endfor
		endif
		let es += [s:TraceDiffChar(u1, u2)]
	endfor
	return es
endfunction

function! s:ApplyDiffCommand(uu)
	let ln = len(a:uu)
	if ln == 0 | return [] | endif
	" prepare 2 input files for diff
	for [k, u] in [[1, 0], [2, 1]]
		" add '<number>:' at the beginning of each unit
		let g{k} = ['']			" add a dummy to avoid 1st null unit error
		let p{k} = []			" a unit range of each line
		let s = 1
		for n in range(ln)
			let g = map(copy(a:uu[n][u]), 'n . ":" . v:val')
			let g{k} += g
			let e = s + len(g) - 1
			let p{k} += [[s, e]]
			let s = e + 1
		endfor
		let f{k} = tempname()
		call writefile(g{k}, f{k})
	endfor
	" initialize a list of edit symbols [=_+-#|] for each unit
	for [k, q] in [[1, '='], [2, '_']]
		let g{k} = repeat([q], len(g{k}))
	endfor
	" call diff and assign edit symbols [=+-#] to each unit
	let opt = '-a --binary '
	if t:DChar.igc | let opt .= '-i ' | endif
	if t:DChar.igs == 1 | let opt .= '-w '
	elseif t:DChar.igs == 2 | let opt .= '-b '
	elseif t:DChar.igs == 3 | let opt .= '-Z '
	endif
	let save_stmp = &shelltemp
	let &shelltemp = 0
	let dout = system('diff ' . opt . f1 . ' ' . f2)
	let &shelltemp = save_stmp
	for [l1, op, l2] in map(filter(split(dout, '\n'), 'v:val[0] !~ "[<>-]"'),
							\'split(substitute(v:val, "[acd]", " & ", ""))')
		for [k, r, c] in [[1, 'a', '-'], [2, 'd', '+']]
			let [s, e] = (l{k} =~ ',') ? split(l{k}, ',') : [l{k}, l{k}]
			let [s, e] -= [1, 1]
			if op == r
				let g{k}[s] .= '#'			" append add/del mark
			else
				let g{k}[s : e] = repeat([c], e - s + 1)
			endif
		endfor
	endfor
	" separate lines and divide units
	for [k, q] in [[1, '='], [2, '_']]
		call map(map(p{k}, '"|" . join(g{k}[v:val[0] : v:val[1]], "") . "|"'),
				\'split(v:val, "\\%(" . q . "\\+\\|[^" . q . "]\\+\\)\\zs")')
		call delete(f{k})
	endfor
	" get a list of edit script
	let es = []
	for n in range(ln)
		let es += [substitute(join(map(p1[n], 'v:val . p2[n][v:key]'), ''),
														\'[^=+-]', '', 'g')]
	endfor
	return es
endfunction

function! s:GetDiffUnitPos(es, uu)
	let [u1, u2] = a:uu
	if empty(u1)
		return [[['d', [0, 0]]], [['a', [1, len(join(u2, ''))]]]]
	elseif empty(u2)
		return [[['a', [1, len(join(u1, ''))]]], [['d', [0, 0]]]]
	endif
	let [c1, c2] = [[], []]
	let [l1, l2, p1, p2] = [1, 1, 0, 0]
	for ed in split(a:es, '\%(=\+\|[+-]\+\)\zs')
		let qn = len(ed)
		if ed[0] == '='		" one or more '='
			for k in [1, 2]
				let [l{k}, p{k}] +=
							\[len(join(u{k}[p{k} : p{k} + qn - 1], '')), qn]
			endfor
		else				" one or more '[+-]'
			let q1 = len(substitute(ed, '+', '', 'g'))
			let q2 = qn - q1
			for k in [1, 2]
				if 0 < q{k}
					let r = len(join(u{k}[p{k} : p{k} + q{k} - 1], ''))
					let h{k} = [l{k}, l{k} + r - 1]
					let [l{k}, p{k}] += [r, q{k}]
				else
					let h{k} = [
						\l{k} - (0 < p{k} ?
								\len(matchstr(u{k}[p{k} - 1], '.$')) : 0),
						\l{k} + (p{k} < len(u{k}) ?
								\len(matchstr(u{k}[p{k}], '^.')) - 1 : -1)]
				endif
			endfor
			let [r1, r2] = (q1 == 0) ? ['d', 'a'] :
										\(q2 == 0) ? ['a', 'd'] : ['c', 'c']
			let [c1, c2] += [[[r1, h1]], [[r2, h2]]]
		endif
	endfor
	return [c1, c2]
endfunction

function! s:TraceDiffChar(u1, u2)
	" An O(NP) Sequence Comparison Algorithm
	let [n1, n2] = [len(a:u1), len(a:u2)]
	if n1 == 0 && n2 == 0 | return ''
	elseif n1 == 0 | return repeat('+', n2)
	elseif n2 == 0 | return repeat('-', n1)
	endif
	" reverse to be M >= N
	let [M, N, u1, u2, e1, e2] = (n1 >= n2) ?
			\[n1, n2, a:u1, a:u2, '+', '-'] : [n2, n1, a:u2, a:u1, '-', '+']
	let D = M - N
	let fp = repeat([-1], M + N + 1)
	let etree = []		" [next edit, previous p, previous k]
	let p = -1
	while fp[D] != M
		let p += 1
		let epk = repeat([[]], p * 2 + D + 1)
		for k in range(-p, D - 1, 1) + range(D + p, D, -1)
			let [x, epk[k]] = (fp[k - 1] < fp[k + 1]) ?
							\[fp[k + 1], [e1, (k < D) ? p - 1 : p, k + 1]] :
							\[fp[k - 1] + 1, [e2, (k > D) ? p - 1 : p, k - 1]]
			let y = x - k
			while x < M && y < N && u1[x] == u2[y]
				let epk[k][0] .= '='
				let [x, y] += [1, 1]
			endwhile
			let fp[k] = x
		endfor
		let etree += [epk]
	endwhile
	" create a shortest edit script (SES) from last p and k
	let ses = ''
	while 1
		let ses = etree[p][k][0] . ses
		if p == 0 && k == 0 | return ses[1 :] | endif
		let [p, k] = etree[p][k][1 : 2]
	endwhile
endfunction

function! diffchar#ResetDiffChar(...)
	if !exists('t:DChar') || a:0 && empty(a:1) | return | endif
	let cwin = win_getid()
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.wid[k] == cwin | break | endif
	endfor
	let [d1, d2] = s:GetDiffModeLines(k,
						\(a:0 && (a:1[0] != 1 || a:1[-1] != line('$'))) ?
							\a:1 : map(keys(t:DChar.hlc[k]), 'eval(v:val)'))
	for k in [1, 2]
		call filter(d{k}, 'has_key(t:DChar.hlc[k], v:val)')
		if empty(d{k}) | return | endif
	endfor
	for k in [1, 2]
		noautocmd call win_gotoid(t:DChar.wid[k])
		call s:ClearDiffChar(k, d{k})
		for l in d{k}
			unlet t:DChar.cks[k][l]
		endfor
		if !empty(t:DChar.mid[k])
			" add diff HL on diffchar cleared lines when not last
			call s:AddDiffHL(d{k})
		endif
	endfor
	noautocmd call win_gotoid(cwin)
	if t:DChar.dpv | call s:ClearDiffCharPair() | endif
	if index(values(t:DChar.hlc), {}) != -1
		" if no highlight remains, clear event and DChar
		call s:ToggleDiffCharEvent(0)
		call s:ToggleDiffHL(0)
		unlet t:DChar
	endif
endfunction

function! s:ToggleDiffCharEvent(on)
	" set or reset events for DChar buffer and tab page
	let ac = []
	for k in [1, 2]
		let bn = winbufnr(t:DChar.wid[k])
		if bn == -1 | continue | endif
		let bl = '<buffer=' . bn . '>'
		let ac += [['BufWinLeave', bl, 's:BufWinLeaveDiffChar(' . k . ')']]
		let ac += [['QuitPre', bl, 's:QuitPreDiffChar(' . k . ')']]
		if t:DChar.dsy
			let ac += [['TextChanged', bl, 's:UpdateDiffChar(' . k . ', 0)']]
			let ac += [['InsertLeave', bl, 's:UpdateDiffChar(' . k . ', 1)']]
			if s:VF.DiffUpdated
				let ac += [['DiffUpdated', bl,
										\'s:UpdateDiffChar(' . k . ', 2)']]
			endif
			if 0 < t:DChar.mxl
				let ac += [['CursorMoved', bl,
										\'s:AdjustDiffCharLines(' . k . ')']]
			endif
		endif
		if t:DChar.dpv
			let ac += [['CursorMoved', bl, 's:ShowDiffCharPair(' . k . ')']]
		endif
	endfor
	let td = filter(map(range(1, tabpagenr() - 1) +
									\range(tabpagenr() + 1, tabpagenr('$')),
							\'s:Gettabvar(v:val, "DChar")'), '!empty(v:val)')
	if empty(td)
		let ac += [['WinEnter', '*', 's:SweepInvalidDiffChar()']]
		let ac += [['TabEnter', '*', 's:AdjustGlobalOption()']]
		let ac += [['ColorScheme', '*', 's:DefineDiffCharHL()']]
	endif
	if !s:VF.DiffUpdated && !s:VF.DiffOptionSet
		if t:DChar.dsy
			if empty(filter(td, 'exists("v:val.dml") && v:val.dsy'))
				" save command to recover later in SwitchDiffChar()
				let s:save_ch = a:on ? 's:ResetDiffModeSync()' : ''
				let ac += [['CursorHold', '*', s:save_ch]]
			endif
			call s:ChangeUTOption(a:on)
		endif
	endif
	for [ev, pt, cd] in ac
		if a:on
			execute 'autocmd diffchar ' . ev . ' ' . pt . ' call ' . cd
		else
			execute 'autocmd! diffchar ' . ev . ' ' . pt
		endif
	endfor
endfunction

function! s:SetDiffModeLines()
	let ct = [s:hlID_CT(s:DCharHL.oC), s:hlID_CT(s:DCharHL.oT)]
	let dml = {'1': [], '2': []}
	let cwin = win_getid()
	" if mxl disable or less lines than mxl, select all lines
	if t:DChar.mxl == 0 || line('$') <= t:DChar.mxl
		for k in [1, 2]
			noautocmd call win_gotoid(t:DChar.wid[k])
			let dml[k] = filter(range(1, line('$')),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
		endfor
		noautocmd call win_gotoid(cwin)
		if 0 < t:DChar.mxl
			let t:DChar.mxl = 0
			unlet t:DChar.mxw
		endif
		return dml
	endif
	let [ck, nk] = (t:DChar.wid[1] == cwin) ? [1, 2] : [2, 1]
	let nwin = t:DChar.wid[nk]
	let cs = 1 + ((&diffopt =~ 'context:') ?
		\eval(substitute(&diffopt, '^.*context:\(\d\+\).*$', '\1', '')) : 6)
	" first in cwin, find dml from current visible and above/below lines
	let [la, lb] = [line('w0'), line('w$')]
	let [wa, wb] = [foldclosedend(la), foldclosed(lb)]
	let [fa, fb] = [wa != -1, wb != -1]
	let wa = fa ? wa + cs : la
	let wb = fb ? wb - cs : lb
	if wa <= wb
		let dml[ck] = filter(range(wa, wb),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
	else
		let dml[ck] = []
		if fa | let wa = foldclosed(la) - cs + 1 | endif
		if fb | let wb = foldclosedend(lb) + cs - 1 | endif
	endif
	let rc = max([t:DChar.mxl, winheight(0)]) - len(dml[ck])
	let [al, bl] = [wa - 1, wb + 1]
	while 0 < rc && (1 <= al || bl <= line('$'))
		let hc = (rc + 1) / 2
		let [ar, br] = [al, line('$') - bl + 1]
		let ab = [hc <= ar, hc <= br]
		let [ac, bc] = (ab == [1, 1]) ? [hc, hc] : (ab == [0, 1]) ?
					\[ar, rc - ar] : (ab == [1, 0]) ? [rc - br, br] : [ar, br]
		if 0 < ac
			let fl = foldclosed(al)
			if fl != -1 | let al = fl - cs | endif
			let dl = filter(range(al - ac + 1, al),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
			let al -= ac
			if !empty(dl)
				let dml[ck] = dl + dml[ck]
				let rc -= len(dl)
			endif
		endif
		if 0 < bc
			let fl = foldclosedend(bl)
			if fl != -1 | let bl = fl + cs | endif
			let dl = filter(range(bl, bl + bc - 1),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
			let bl += bc
			if !empty(dl)
				let dml[ck] += dl
				let rc -= len(dl)
			endif
		endif
	endwhile
	if empty(dml[ck]) | return dml | endif
	" next in nwin, find corresponding dml with cwin's ones
	let ok = 0
	if exists('t:DChar.dml')
		" try to make use of old dml
		let [na, nb] = [dml[ck][0], dml[ck][-1]]
		let [oa, ob] = [t:DChar.dml[ck][0], t:DChar.dml[ck][-1]]
		if na <= ob && nb >= oa
			" find where the new dml exist in old dml
			let cl = index(t:DChar.dml[ck], na)
			if cl != -1
				let [al, ac] = [0, 0]
				let [bl, bc] = [t:DChar.dml[nk][cl], len(dml[ck])]
			else
				let cl = index(t:DChar.dml[ck], nb)
				if cl != -1
					let [al, ac] = [t:DChar.dml[nk][cl], len(dml[ck])]
					let [bl, bc] = [0, 0]
				else
					let [al, ac] =
								\[t:DChar.dml[nk][0] - 1, index(dml[ck], oa)]
					let [bl, bc] = [al + 1, len(dml[ck]) - ac]
				endif
			endif
			let ok = 1
		endif
	endif
	if !ok
		" find how far the dml is from first or last line in cwin
		let [sd, sl] = (dml[ck][0] < line('$') - dml[ck][-1]) ?
									\[0, range(1, dml[ck][0] - 1)] :
									\[1, range(dml[ck][-1] + 1, line('$'))]
		let sc = len(filter(sl, 'index(ct, diff_hlID(v:val, 1)) != -1'))
		" skip from first or last line and find a corresponding line in nwin
		noautocmd call win_gotoid(nwin)
		if sd
			let nl = line('$')
			while 0 < sc && 1 <= nl
				let fl = foldclosed(nl)
				if fl != -1 | let nl = fl - cs | endif
				let dl = filter(range(nl - sc + 1, nl),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
				let nl -= sc
				let sc -= len(dl)
			endwhile
			let [al, ac, bl, bc] = [nl, len(dml[ck]), 0, 0]
		else
			let nl = 1
			while 0 < sc && nl <= line('$')
				let fl = foldclosedend(nl)
				if fl != -1 | let nl = fl + cs | endif
				let dl = filter(range(nl, nl + sc - 1),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
				let nl += sc
				let sc -= len(dl)
			endwhile
			let [al, ac, bl, bc] = [0, 0, nl, len(dml[ck])]
		endif
	endif
	" then find dml in nwin
	noautocmd call win_gotoid(nwin)
	let dml[nk] = []
	while 0 < ac && 1 <= al
		let fl = foldclosed(al)
		if fl != -1 | let al = fl - cs | endif
		let dl = filter(range(al - ac + 1, al),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
		let al -= ac
		if !empty(dl)
			let dml[nk] = dl + dml[nk]
			let ac -= len(dl)
		endif
	endwhile
	while 0 < bc && bl <= line('$')
		let fl = foldclosedend(bl)
		if fl != -1 | let bl = fl + cs | endif
		let dl = filter(range(bl, bl + bc - 1),
									\'index(ct, diff_hlID(v:val, 1)) != -1')
		let bl += bc
		if !empty(dl)
			let dml[nk] += dl
			let bc -= len(dl)
		endif
	endwhile
	noautocmd call win_gotoid(cwin)
	return dml
endfunction

function! s:GetDiffModeLines(key, lines)
	let ix = filter(range(len(t:DChar.dml[a:key])),
						\'index(a:lines, t:DChar.dml[a:key][v:val]) != -1')
	return [map(copy(ix), 't:DChar.dml[1][v:val]'),
									\map(copy(ix), 't:DChar.dml[2][v:val]')]
endfunction

function! s:AdjustDiffCharLines(key)
	if !exists('t:DChar') || t:DChar.wid[a:key] != win_getid()
		return
	endif
	let wc = [line('w0'), line('w$'), s:Changenr()]
	let cm = t:DChar.mxw[a:key][: 1] != wc[: 1] &&
											\t:DChar.mxw[a:key][2] == wc[2]
	let t:DChar.mxw[a:key] = wc
	if cm && (wc[0] < t:DChar.dml[a:key][0] || t:DChar.dml[a:key][-1] < wc[1])
		let dml = s:SetDiffModeLines()
		if t:DChar.dml == dml | return | endif
		" delete old diff mode lines and Diff HL except new ones
		let ohl = filter(map(keys(t:DChar.hlc[a:key]), 'eval(v:val)'),
											\'index(dml[a:key], v:val) == -1')
		let [t:DChar.hlc[1][0], t:DChar.hlc[2][0]] = [[], []]
		if !empty(ohl) | call diffchar#ResetDiffChar(ohl) | endif
		for k in [1, 2]
			noautocmd call win_gotoid(t:DChar.wid[k])
			call s:DeleteDiffHL(filter(t:DChar.dml[k],
											\'index(dml[k], v:val) == -1'))
		endfor
		noautocmd call win_gotoid(t:DChar.wid[a:key])
		" add new diff mode lines except old ones
		let t:DChar.dml = dml
		if !empty(dml[a:key]) | call diffchar#ShowDiffChar(dml[a:key]) | endif
		unlet t:DChar.hlc[1][0] | unlet t:DChar.hlc[2][0]
		if index(values(t:DChar.hlc), {}) != -1
			call s:ToggleDiffCharEvent(0)
			call s:ToggleDiffHL(0)
			unlet t:DChar
		endif
	endif
endfunction

function! s:HighlightDiffChar(key, lec)
	for [l, ec] in a:lec
		if has_key(t:DChar.mid[a:key], l) | continue | endif
		let t:DChar.hlc[a:key][l] = ec
		" collect all the column positions per highlight group
		let hc = {}
		let cn = 0
		for [e, c] in ec
			if e == 'c'
				let h = t:DChar.hgp[cn % len(t:DChar.hgp)]
				let cn += 1
			elseif e == 'a'
				let h = s:DCharHL.A
			elseif e == 'd'
				if c == [0, 0] | continue | endif
				let h = s:DCharHL.E
			endif
			let hc[h] = get(hc, h, []) + [c]
		endfor
		let pr = -(l * 10)
		let t:DChar.mid[a:key][l] = [matchaddpos(s:DCharHL.C, [[l]], pr - 1)]
		for [h, c] in items(hc)
			call map(c, '[l, v:val[0], v:val[1] - v:val[0] + 1]')
			let t:DChar.mid[a:key][l] += map(range(0, len(c) - 1, 8),
								\'matchaddpos(h, c[v:val : v:val + 7], pr)')
		endfor
	endfor
endfunction

function! s:ClearDiffChar(key, lines)
	for l in reverse(copy(a:lines))
		silent! call map(t:DChar.mid[a:key][l], 'matchdelete(v:val)')
		unlet t:DChar.mid[a:key][l]
		unlet t:DChar.hlc[a:key][l]
	endfor
endfunction

function! s:ShiftDiffChar(key, lines, shift)
	let lid = []
	let hlc = {}
	let cks = {}
	for l in filter(copy(a:lines), 'has_key(t:DChar.mid[a:key], v:val)')
		let lid += [[l, t:DChar.mid[a:key][l]]]
		let hlc[l + a:shift] = t:DChar.hlc[a:key][l]
		let cks[l + a:shift] = t:DChar.cks[a:key][l]
		unlet t:DChar.mid[a:key][l]
		unlet t:DChar.hlc[a:key][l]
		unlet t:DChar.cks[a:key][l]
	endfor
	call extend(t:DChar.mid[a:key], s:ShiftMatchaddLines(lid, a:shift))
	call extend(t:DChar.hlc[a:key], hlc)
	call extend(t:DChar.cks[a:key], cks)
endfunction

function! s:UpdateDiffChar(key, event)
	" a:event : 0 = TextChanged, 1 = InsertLeave, 2 = DiffUpdated
	if mode() != 'n' || !exists('t:DChar') ||
			\!empty(filter(values(t:DChar.wid), '!getwinvar(v:val, "&diff")'))
		return
	endif
	if s:VF.DiffUpdated && a:event != 2
		let t:DChar.pdu = 1			" actual DiffUpdated comes next
		return
	endif
	let cwin = win_getid()
	noautocmd call win_gotoid(t:DChar.wid[a:key])
	let [pcn, pln] = t:DChar.pcn[a:key]
	let [ccn, cln] = [s:Changenr(), line('$')]
	if pcn == ccn && a:event == 2
		" in case of text notchanged (diffupdate and diffopt changes)
		let [t:DChar.hlc[1][0], t:DChar.hlc[2][0]] = [[], []]
		call diffchar#ResetDiffChar()
		let t:DChar.dml = s:SetDiffModeLines()
		if index(values(t:DChar.dml), []) == -1
			let do = split(&diffopt, ',')
			let t:DChar.igc = (index(do, 'icase') != -1)
			let t:DChar.igs = (index(do, 'iwhiteall') != -1) ? 1 :
									\(index(do, 'iwhite') != -1) ? 2 :
									\(index(do, 'iwhiteeol') != -1) ? 3 : 0
			call diffchar#ShowDiffChar()
		endif
		unlet t:DChar.hlc[1][0] | unlet t:DChar.hlc[2][0]
		if index(values(t:DChar.hlc), {}) != -1
			call s:ToggleDiffCharEvent(0)
			call s:ToggleDiffHL(0)
			unlet t:DChar
		endif
	elseif pcn != ccn && (a:event != 2 || exists('t:DChar.pdu'))
		if exists('t:DChar.pdu') | unlet t:DChar.pdu | endif
		let t:DChar.pcn[a:key] = [ccn, cln]
		" compare between previous and current DChar and diff mode lines
		" using checksum and find ones to be deleted, added, and shifted
		let phl = map(sort(map(keys(t:DChar.hlc[a:key]),
									\'printf("%8d", v:val)')), 'eval(v:val)')
		let lnd = cln - pln
		let pdm = t:DChar.dml
		let cdm = s:SetDiffModeLines()
		let bkey = (a:key == 1) ? 2 : 1
		let [pma, cma] = [pdm[a:key], cdm[a:key]]
		let [pmb, cmb] = [pdm[bkey], cdm[bkey]]
		let m = min([len(pma), len(cma)])
		if pma == cma
			let ddl = []
			for s in range(m)
				if pmb[s] != cmb[s] || get(t:DChar.cks[a:key], pma[s]) !=
											\s:ChecksumStr(getline(cma[s]))
					let ddl += [pma[s]]
				endif
			endfor
			let adl = ddl
			let sdl = []
		else
			let s = 0
			while s < m && pma[s] == cma[s] && pmb[s] == cmb[s] &&
									\get(t:DChar.cks[a:key], pma[s]) ==
											\s:ChecksumStr(getline(cma[s]))
				let s += 1
			endwhile
			let e = -1
			let m -= s
			while e >= -m && pma[e] + lnd == cma[e] && pmb[e] == cmb[e] &&
									\get(t:DChar.cks[a:key], pma[e]) ==
											\s:ChecksumStr(getline(cma[e]))
				let e -= 1
			endwhile
			let ddl = pma[s : e]
			let adl = cma[s : e]
			let sdl = (lnd != 0 && e < -1) ? pma[e + 1 :] : []
		endif
		if t:DChar.dpv | call s:ClearDiffCharPair() | endif
		" delete and add the selected DChar lines
		let [t:DChar.hlc[1][0], t:DChar.hlc[2][0]] = [[], []]	" a dummy
		if !empty(ddl) | call diffchar#ResetDiffChar(ddl) | endif
		let t:DChar.dml = cdm
		if !empty(adl) | call diffchar#ShowDiffChar(adl) | endif
		unlet t:DChar.hlc[1][0] | unlet t:DChar.hlc[2][0]
		if index(values(t:DChar.hlc), {}) != -1
			" no DChar lines remains, completely reset DChar
			call s:ToggleDiffCharEvent(0)
			call s:ToggleDiffHL(0)
			unlet t:DChar
		else
			" shift the selected DChar lines
			if !empty(sdl) | call s:ShiftDiffChar(a:key, sdl, lnd) | endif
			" refresh or rewrite/shift Diff HL of diff mode lines
			if pdm[a:key] != t:DChar.dml[a:key]
				call s:ToggleDiffHL(-1)
			else
				if ddl != adl
					if !empty(ddl) | call s:DeleteDiffHL(ddl) | endif
					if !empty(adl) | call s:AddDiffHL(adl) | endif
				endif
				if !empty(sdl) | call s:ShiftDiffHL(sdl, lnd) | endif
			endif
		endif
	endif
	noautocmd call win_gotoid(cwin)
endfunction

function! diffchar#JumpDiffChar(dir, pos)
	" a:dir : 0 = backward, 1 = forward
	" a:pos : 0 = start, 1 = end
	if !exists('t:DChar') | return | endif
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.wid[k] == win_getid() | break | endif
	endfor
	let [ln, co] = [line('.'), col('.')]
	if co == col('$')		" empty line
		if !a:dir | let co = 0 | endif
	else
		if a:pos
			let co += len(matchstr(getline(ln)[co - 1 :], '^.')) - 1
		endif
	endif
	if has_key(t:DChar.hlc[k], ln) &&
							\(a:dir ? co < t:DChar.hlc[k][ln][-1][1][a:pos] :
										\co > t:DChar.hlc[k][ln][0][1][a:pos])
		" found in the current line
		let hc = filter(map(copy(t:DChar.hlc[k][ln]), 'v:val[1][a:pos]'),
										\a:dir ? 'co < v:val' : 'co > v:val')
		let co = hc[a:dir ? 0 : -1]
	else
		" try to find in the prev/next highlighted line
		let hl = filter(map(keys(t:DChar.hlc[k]), 'eval(v:val)'),
										\a:dir ? 'ln < v:val' : 'ln > v:val')
		if !empty(hl)
			let ln = a:dir ? min(hl) : max(hl)
			let co = t:DChar.hlc[k][ln][a:dir ? 0 : -1][1][a:pos]
		else
			if t:DChar.mxl == 0 | return | endif
			" try to find in upper/lower lines than hlc when mxl is enable
			let ct = [s:hlID_CT(s:DCharHL.oC), s:hlID_CT(s:DCharHL.oT)]
			let co = 0
			for ln in a:dir ? range(ln + 1, line('$')) : range(ln - 1, 1, -1)
				if index(ct, diff_hlID(ln, 1)) != -1
					noautocmd call cursor(ln, 1)
					call s:AdjustDiffCharLines(k)
					let co = has_key(t:DChar.hlc[k], ln) ?
							\t:DChar.hlc[k][ln][a:dir ? 0 : -1][1][a:pos] :
											\a:dir ? 1 : col([ln, '$']) - 1
					break
				endif
			endfor
			if co == 0 | return | endif
		endif
	endif
	call cursor(ln, co)
	" set a dummy cursor position to adjust the start/end
	if t:DChar.dpv
		call s:ClearDiffCharPair()
		if [a:dir, a:pos] == [1, 0]				" forward/start : rightmost
			let t:DChar.clc[k][0 : 1] = [ln, col('$')]
		elseif [a:dir, a:pos] == [0, 1]			" backward/end : leftmost
			let t:DChar.clc[k][0 : 1] = [ln, 0]
		endif
	endif
endfunction

function! s:ShowDiffCharPair(key)
	if mode() != 'n' || !exists('t:DChar') | return | endif
	if t:DChar.wid[a:key] != win_getid() | return | endif
	let [ln, co] = [line('.'), col('.')]
	if co == col('$') | let co = 0 | endif
	let [lx, cx, bx] = t:DChar.clc[a:key]
	let t:DChar.clc[a:key] = [ln, co, b:changedtick]
	" if triggered by TextChanged, do nothing
	if b:changedtick != bx | return | endif
	if !empty(t:DChar.cpi)
		" pair highlight exists
		let [lp, cn] = t:DChar.cpi.P
		let cp = t:DChar.hlc[a:key][lp][cn][1]
		" inside the highlight, do nothing
		if ln == lp && cp[0] <= co && co <= cp[1] | return | endif
		call s:ClearDiffCharPair()	" outside, clear it
	endif
	if has_key(t:DChar.hlc[a:key], ln)
		let hc = filter(map(copy(t:DChar.hlc[a:key][ln]),
			\'[v:key, v:val[1]]'), 'v:val[1][0] <= co && co <= v:val[1][1]')
		if !empty(hc)
			" inside 1 valid diff unit or 2 contineous 'd'
			let ix = (len(hc) == 1) ? 0 : (ln == lx) ? co < cx : ln < lx
			call s:HighlightDiffCharPair(a:key, ln, hc[ix][0])
		endif
	endif
endfunction

function! s:HighlightDiffCharPair(key, line, col)
	let bkey = (a:key == 1) ? 2 : 1
	let bline = t:DChar.dml[bkey][index(t:DChar.dml[a:key], a:line)]
	let aw = t:DChar.wid[a:key]
	let bw = t:DChar.wid[bkey]
	" set a pair cursor position (line, colnum) and match id
	let t:DChar.cpi.P = [a:line, a:col]
	let t:DChar.cpi.M = [bkey]
	" show a cursor-like highlight at the corresponding position
	let bc = t:DChar.hlc[bkey][bline][a:col][1]
	if bc != [0, 0]
		let [pos, len] = [bc[0], bc[1] - bc[0] + 1]
		noautocmd call win_gotoid(bw)
		let t:DChar.cpi.M +=
						\[matchaddpos(s:DCharHL.c, [[bline, pos, len]], -1)]
		noautocmd call win_gotoid(aw)
	else
		let t:DChar.cpi.M += [-1]	" no cursor hl on empty line
	endif
	execute 'autocmd! diffchar WinLeave <buffer=' . winbufnr(aw) .
											\'> call s:ClearDiffCharPair()'
	if t:DChar.dpv != 2 | return | endif
	" echo the corresponding unit with its color
	let at = getbufline(winbufnr(aw), a:line)[0]
	let bt = getbufline(winbufnr(bw), bline)[0]
	let [ae, ac] = t:DChar.hlc[a:key][a:line][a:col]
	let gt = []
	if ae == 'c'
		let gt += [t:DChar.hgp[
			\(count(map(t:DChar.hlc[a:key][a:line][: a:col], 'v:val[0]'),
					\'c') - 1) % len(t:DChar.hgp)], bt[bc[0] - 1 : bc[1] - 1]]
	elseif ae == 'a'
		if 1 < ac[0]
			let gt += [s:DCharHL.C, matchstr(at[: ac[0] - 2], '.$')]
		endif
		let gt += [s:DCharHL.D, repeat(s:VF.StrikeAttr ? ' ' :
			\(&fillchars =~ 'diff') ? matchstr(&fillchars, 'diff:\zs.') : '-',
										\strwidth(at[ac[0] - 1 : ac[1] - 1]))]
		if ac[1] < len(at)
			let gt += [s:DCharHL.C, matchstr(at[ac[1] :], '^.')]
		endif
	elseif ae == 'd'
		let ds = split(at[ac[0] - 1 : ac[1] - 1], '\zs')
		if 1 < bc[0]
			let gt += [s:DCharHL.E, ds[0]]
		endif
		let gt += [s:DCharHL.A, bt[bc[0] - 1 : bc[1] - 1]]
		if bc[1] < len(bt)
			let gt += [s:DCharHL.E, ds[-1]]
		endif
	endif
	execute join(map(gt, '(v:key % 2 == 0) ? "echohl " . v:val :
				\"echon ''" . substitute(v:val, "''", "''''", "g") . "''"') +
													\['echohl None'], '|')
endfunction

function! s:ClearDiffCharPair()
	if !exists('t:DChar') | return | endif
	if !empty(t:DChar.cpi)
		let [wid, mid] = t:DChar.cpi.M
		if mid != -1
			let cwin = win_getid()
			noautocmd call win_gotoid(t:DChar.wid[wid])
			silent! call matchdelete(mid)
			noautocmd call win_gotoid(cwin)
		endif
		execute 'autocmd! diffchar WinLeave <buffer=' .
							\winbufnr(t:DChar.wid[(wid == 1) ? 2 : 1]) . '>'
		let t:DChar.cpi = {}
	endif
	if t:DChar.dpv == 2 | echon '' | endif
endfunction

function! diffchar#CopyDiffCharPair(dir)
	" a:dir : 0 = get, 1 = put
	if !exists('t:DChar') | return | endif
	for ak in [1, 2, 0]
		if ak == 0 | return | endif
		if t:DChar.wid[ak] == win_getid() | break | endif
	endfor
	let bk = (ak == 1) ? 2 : 1
	let aw = win_getid()
	let bw = t:DChar.wid[bk]
	let un = -1
	if t:DChar.dpv
		if !empty(t:DChar.cpi) | let [al, un] = t:DChar.cpi.P | endif
	else
		let [al, co] = [line('.'), col('.')]
		if co == col('$') | let co = 0 | endif
		if has_key(t:DChar.hlc[ak], al)
			let hc = filter(map(copy(t:DChar.hlc[ak][al]),
								\'[v:key, v:val[1]]'),
									\'v:val[1][0] <= co && co <= v:val[1][1]')
			if !empty(hc) | let un = hc[0][0] | endif
		endif
	endif
	if un == -1
		call s:EchoWarning('Cursor is not on a difference unit!')
		return
	endif
	let bl = t:DChar.dml[bk][index(t:DChar.dml[ak], al)]
	let [ae, ac] = t:DChar.hlc[ak][al][un]
	let [be, bc] = t:DChar.hlc[bk][bl][un]
	let at = getbufline(winbufnr(aw), al)[0]
	let bt = getbufline(winbufnr(bw), bl)[0]
	let [x, y] = a:dir ? ['b', 'a'] : ['a', 'b']	" put : get
	let s1 = (1 < {x}c[0]) ? {x}t[: {x}c[0] - 2] : ''
	let s2 = ({x}e != 'a') ? {y}t[{y}c[0] - 1 : {y}c[1] - 1] : ''
	if {x}e == 'd' && {x}c != [0, 0]
		let ds = split({x}t[{x}c[0] - 1 : {x}c[1] - 1], '\zs')
		let s2 = ((1 < {y}c[0]) ? ds[0] : '') . s2 .
										\(({y}c[1] < len({y}t)) ? ds[-1] : '')
	endif
	let s3 = ({x}c[1] < len({x}t)) ? {x}t[{x}c[1] :] : ''
	let ss = s1 . s2 . s3
	if a:dir		" put
		noautocmd call win_gotoid(bw)
		noautocmd call setline(bl, ss)
		call s:UpdateDiffChar(bk, 0)	" because TextChanged is not triggered
		noautocmd call win_gotoid(aw)
	else			" get
		call setline(al, ss)		" TextChanged is triggered
	endif
endfunction

function! diffchar#EchoDiffChar(lines, short)
	if !exists('t:DChar') | return | endif
	for ak in [1, 2, 0]
		if ak == 0 | return | endif
		if t:DChar.wid[ak] == win_getid() | break | endif
	endfor
	let bk = (ak == 1) ? 2 : 1
	let nw = max([&numberwidth - 1, len(string(line('$')))])
	let ec = []
	for al in a:lines
		let gt = []
		if &number || &relativenumber
			let gt += [s:DCharHL.n, printf('%'. nw . 'd ',
							\(&relativenumber ? abs(al - line('.')) : al))]
		endif
		let at = getbufline(winbufnr(t:DChar.wid[ak]), al)[0]
		if !has_key(t:DChar.hlc[ak], al)
			if a:short | continue | endif
			let gt += ['', empty(at) ? "\n" : at]
		else
			let bl = t:DChar.dml[bk][index(t:DChar.dml[ak], al)]
			let bt = getbufline(winbufnr(t:DChar.wid[bk]), bl)[0]
			let hl = repeat('C', len(at))
			let tx = at
			for an in range(len(t:DChar.hlc[ak][al]) - 1, 0, -1)
				let [ae, ac] = t:DChar.hlc[ak][al][an]
				" enclose highlight and text in '[+' and '+]'
				" if strike not available
				if ae == 'c' || ae == 'a'
					let it = at[ac[0] - 1 : ac[1] - 1]
					if !s:VF.StrikeAttr | let it = '[+' . it . '+]' | endif
					let ih = repeat((ae == 'a') ? 'A' : 'T', len(it))
					let hl = ((1 < ac[0]) ? hl[: ac[0] - 2] : '') . ih .
																\hl[ac[1] :]
					let tx = ((1 < ac[0]) ? tx[: ac[0] - 2] : '') . it .
																\tx[ac[1] :]
				endif
				" enclose corresponding changed/deleted units in '[-' and '-]'
				" if strike not available,
				" and insert them to highlight and text
				if ae == 'c' || ae == 'd'
					let bc = t:DChar.hlc[bk][bl][an][1]
					let it = bt[bc[0] - 1 : bc[1] - 1]
					if !s:VF.StrikeAttr | let it = '[-' . it . '-]' | endif
					let ih = repeat('D', len(it))
					if ae == 'c'
						let hl = ((1 < ac[0]) ? hl[: ac[0] - 2] : '') . ih .
															\hl[ac[0] - 1 :]
						let tx = ((1 < ac[0]) ? tx[: ac[0] - 2] : '') . it .
															\tx[ac[0] - 1 :]
					else
						if ac[0] == 1 && bc[0] == 1
							let hl = ih . hl
							let tx = it . tx
						else
							let ix = ac[0] +
									\len(matchstr(at[ac[0] - 1 :], '^.')) - 2
							let hl = hl[: ix] . ih . hl[ix + 1 :]
							let tx = tx[: ix] . it . tx[ix + 1 :]
						endif
					endif
				endif
			endfor
			let sm = a:short && &columns <= strdisplaywidth(tx)
			let ix = 0
			let tn = 0
			for h in split(hl, '\%(\(.\)\1*\)\zs')
				if h[0] == 'T'
					let g = t:DChar.hgp[tn % len(t:DChar.hgp)]
					let tn += 1
				else
					let g = s:DCharHL[h[0]]
				endif
				let t = tx[ix : ix + len(h) - 1]
				if sm && h[0] == 'C'
					let s = split(t, '\zs')
					if ix == 0 && 1 < len(s) &&
									\3 < strdisplaywidth(join(s[: -2], ''))
						let t = '...' . s[-1]
					elseif ix + len(h) == len(tx) && 1 < len(s) &&
									\3 < strdisplaywidth(join(s[1 :], ''))
						let t = s[0] . '...'
					elseif 2 < len(s) &&
									\3 < strdisplaywidth(join(s[1 : -2], ''))
						let t = s[0] . '...' . s[-1]
					endif
				endif
				let gt += [g, t]
				let ix += len(h)
			endfor
		endif
		let ec += ['echo '''''] +
			\map(gt, '(v:key % 2 == 0) ? "echohl " . v:val :
				\"echon ''" . substitute(v:val, "''", "''''", "g") . "''"') +
															\['echohl None']
	endfor
	execute join(ec, '|')
endfunction

function! diffchar#DiffCharExpr()
	if readfile(v:fname_in, '', 1) == ['line1'] &&
									\readfile(v:fname_new, '', 1) == ['line2']
		" return here for the 1st diff trial call
		call writefile(['1c1'], v:fname_out)
		return
	endif
	for fn in ['BuiltinFunctionExpr', 'DiffCommandExpr']
		let dfcmd = s:{fn}(v:fname_in, v:fname_new)
		if !empty(dfcmd) | break | endif
	endfor
	call writefile(dfcmd, v:fname_out)
endfunction

function! s:BuiltinFunctionExpr(f1, f2)
	let [f1, f2] = [readfile(a:f1), readfile(a:f2)]
	if executable('diff') &&
				\len(f1) + len(f2) > get(t:, 'DiffSplitTime', g:DiffSplitTime)
		return []
	endif
	let do = split(&diffopt, ',')
	let save_igc = &ignorecase
	let &ignorecase = (index(do, 'icase') != -1)
	if index(do, 'iwhiteall') != -1
		for k in [1, 2]
			call map(f{k}, 'substitute(v:val, "\\s\\+", "", "g")')
		endfor
	elseif index(do, 'iwhite') != -1
		for k in [1, 2]
			call map(f{k}, 'substitute(v:val, "\\s\\+", " ", "g")')
			call map(f{k}, 'substitute(v:val, "\\s\\+$", "", "")')
		endfor
	elseif index(do, 'iwhiteeol') != -1
		for k in [1, 2]
			call map(f{k}, 'substitute(v:val, "\\s\\+$", "", "")')
		endfor
	endif
	let dfcmd = []
	let [l1, l2] = [1, 1]
	for ed in split(s:TraceDiffChar(f1, f2), '\%(=\+\|[+-]\+\)\zs')
		let qn = len(ed)
		if ed[0] == '='		" one or more '='
			let [l1, l2] += [qn, qn]
		else				" one or more '[+-]'
			let q1 = len(substitute(ed, '+', '', 'g'))
			let q2 = qn - q1
			let dfcmd += [((1 < q1) ? l1 . ',' : '') . (l1 + q1 - 1) .
								\((q1 == 0) ? 'a' : (q2 == 0) ? 'd' : 'c') .
								\((1 < q2) ? l2 . ',' : '') . (l2 + q2 - 1)]
			let [l1, l2] += [q1, q2]
		endif
	endfor
	let &ignorecase = save_igc
	return dfcmd
endfunction

function! s:DiffCommandExpr(f1, f2)
	let opt = '-a --binary '
	let do = split(&diffopt, ',')
	if index(do, 'icase') != -1 | let opt .= '-i ' | endif
	if index(do, 'iwhiteall') != -1 | let opt .= '-w '
	elseif index(do, 'iwhite') != -1 | let opt .= '-b '
	elseif index(do, 'iwhiteeol') != -1 | let opt .= '-Z '
	endif
	let save_stmp = &shelltemp
	let &shelltemp = 0
	let dout = system('diff ' . opt . a:f1 . ' ' . a:f2)
	let &shelltemp = save_stmp
	return filter(split(dout, '\n'), 'v:val[0] =~ "\\d"')
endfunction

if s:VF.DiffOptionSet
	function! diffchar#ToggleDiffModeSync(event)
		" a:event : 0 = OptionSet diff, 1 = VimEnter
		if a:event || v:option_old != v:option_new
			call s:SwitchDiffChar()
		endif
	endfunction
else
	function! diffchar#SetDiffModeSync()
		" DiffModeSync is triggered ON by FilterWritePost
		if !get(t:, 'DiffModeSync', g:DiffModeSync) | return | endif
		if !exists('s:dmbuf')
			" as a diff session, when FilterWritePos comes, current buf and
			" other 1 or more buf should be diff mode
			let s:dmbuf = map(filter(gettabinfo(tabpagenr())[0].windows,
							\'getwinvar(v:val, "&diff")'), 'winbufnr(v:val)')
			if index(s:dmbuf, bufnr('%')) == -1 ||
												\min(s:dmbuf) == max(s:dmbuf)
				" not a diff session, then clear
				unlet s:dmbuf
				return
			endif
			" wait for the contineous 1 or more FilterWitePost (diff) or
			" 1 ShellFilterPost (non diff)
			autocmd! diffchar ShellFilterPost * call s:ClearDiffModeSync()
			" prepare to complete sync just in case for accidents
			let s:id = timer_start(0, function('s:CompleteDiffModeSync'))
		endif
		" check if all the FilterWritePost has come
		if empty(filter(s:dmbuf, 'v:val != bufnr("%")'))
			call s:CompleteDiffModeSync(0)
		endif
	endfunction

	function! s:CompleteDiffModeSync(id)
		if exists('s:id')
			if a:id == 0 | call timer_stop(s:id) | endif
			unlet s:id
		else
			if exists('s:save_ch') && !empty(s:save_ch)
				execute 'autocmd! diffchar CursorHold * call ' . s:save_ch
				call s:ChangeUTOption(1)
			else
				execute 'autocmd! diffchar CursorHold *'
				call s:ChangeUTOption(0)
			endif
			silent call feedkeys("g\<Esc>", 'n')
		endif
		call s:ClearDiffModeSync()
		call timer_start(0, function('s:SwitchDiffChar'))
	endfunction

	function! s:ClearDiffModeSync()
		unlet s:dmbuf
		autocmd! diffchar ShellFilterPost *
	endfunction

	function! s:ResetDiffModeSync()
		" DiffModeSync is triggered OFF by OptionSet(diff) or CursorHold
		if exists('t:DChar') && t:DChar.dsy &&
			\!empty(filter(values(t:DChar.wid), '!getwinvar(v:val, "&diff")'))
			" if either or both of DChar win is now non-diff mode,
			" reset it and show with current diff mode wins
			call eval(s:VF.DiffOptionSet ?
							\timer_start(0, function('s:SwitchDiffChar')) :
														\s:SwitchDiffChar())
		endif
	endfunction
endif

function! s:SwitchDiffChar(...)
	" a:0 > 0 : via timer on DiffModeSync (a:1 : timer id)
	let cwin = win_getid()
	let dwin = []
	if exists('t:DChar')
		let dwin = (t:DChar.wid[1] == cwin) ? [t:DChar.wid[2]] :
							\(t:DChar.wid[2] == cwin) ? [t:DChar.wid[1]] : []
		if empty(dwin)
			" current win is not DChar wins, but diff mode changed,
			" refresh Diff HL on all wins
			call s:ToggleDiffHL(-1)
		else
			call diffchar#ResetDiffChar()
		endif
	endif
	if !exists('t:DChar') && get(t:, 'DiffModeSync', g:DiffModeSync)
		let dwin += filter(map(
						\range(winnr(), winnr('$')) + range(1, winnr() - 1),
							\'win_getid(v:val)'), 'getwinvar(v:val, "&diff")')
		let dbuf = map(copy(dwin), 'winbufnr(v:val)')
		if min(dbuf) != max(dbuf)			" 2 or more diff mode wins exist
			noautocmd call win_gotoid(dwin[0])
			call diffchar#ShowDiffChar()
			noautocmd call win_gotoid(cwin)
		endif
	endif
endfunction

function! s:BufWinLeaveDiffChar(key)
	" when BufWinLeave comes via quit, close, hide, tabclose, tabonly
	" commands, find a tab page where the 'quit' buffer of the DChar window
	" exists, and then switch DChar on that tab page
	for tp in filter(range(tabpagenr('$'), 1, -1),
									\'!empty(s:Gettabvar(v:val, "DChar"))')
		let awin = map(filter(map(tabpagebuflist(tp),
										\'[win_getid(v:key + 1, tp), v:val]'),
						\'v:val[1] == eval(expand("<abuf>"))'), 'v:val[0]')
		if !empty(awin)
			let ctab = tabpagenr()
			execute 'noautocmd ' . tp . 'tabnext'
			if t:DChar.dsy
				call map(copy(awin), 'setwinvar(v:val, "&diff", 0)')
			endif
			let cwin = win_getid()
			let dwin = t:DChar.wid
			noautocmd call win_gotoid(dwin[(index(awin, dwin[a:key]) != -1) ?
											\a:key : (a:key == 1) ? 2 : 1])
			call s:SwitchDiffChar()
			noautocmd call win_gotoid(cwin)
			call s:SweepInvalidDiffChar()
			execute 'noautocmd ' . ctab . 'tabnext'
		endif
	endfor
	call s:AdjustGlobalOption()
endfunction

function! s:QuitPreDiffChar(key)
	" when QuitPre comes, find all split windows where the 'quit' buffer
	" of the DChar window exists, and then switch DChar
	if !exists('t:DChar') | return | endif
	if 1 < len(filter(tabpagebuflist(), s:VF.QuitPreAbufFixed ?
				\'v:val == eval(expand("<abuf>"))' : 'v:val == bufnr("%") &&
							\v:val == winbufnr(t:DChar.wid[a:key])'))
		" try to check a 'quit' command and find a window to be quited
		let qwin = winnr()
		let qcmd = substitute(histget(':'), '\s\+\|q\%[uit].*$', '', 'g')
		if qcmd =~ '^[.$]$\|^\%([+-]\|\d\)\d*$'
			let d = matchstr(qcmd, '\d\+$')
			let n = empty(d) ? 1 : eval(d)
			let qwin =
				\(qcmd[0] == '+') ? qwin + n : (qcmd[0] == '-') ? qwin - n :
				\(qcmd[0] == '.') ? qwin : (qcmd[0] == '$') ? winnr('$') : n
			let qwin = (qwin < 1) ? 1 : (winnr('$') < qwin) ?
															\winnr('$') : qwin
		endif
		let qwin = win_getid(qwin)
		if qwin == t:DChar.wid[a:key]
			" the quit window is actually a target DChar window
			let cwin = win_getid()
			noautocmd call win_gotoid(qwin)
			if t:DChar.dsy
				noautocmd let &diff = 0
			endif
			call s:SwitchDiffChar()
			noautocmd call win_gotoid(cwin)
		endif
	endif
	call s:SweepInvalidDiffChar()
endfunction

function! s:SweepInvalidDiffChar()
	" close and hide commands on a split window does not trigger an event,
	" see WinEnter to check if both or either of DChar win was disappeared
	if exists('t:DChar')
		let lw = filter(values(t:DChar.wid), 'win_id2win(v:val) != 0')
		if len(lw) == 1
			" either of DChar wins has gone, sweep remaining win and set again
			let cwin = win_getid()
			noautocmd call win_gotoid(lw[0])
			call s:SwitchDiffChar()
			noautocmd call win_gotoid(cwin)
		elseif len(lw) == 0
			" both of DChar wins have gone, clear event, HL and DChar
			call s:ToggleDiffCharEvent(0)
			call s:ToggleDiffHL(0)
			unlet t:DChar
		endif
	endif
	" find all buffer belonging to valid DChar in all tab page
	let db = []
	for tp in filter(range(1, tabpagenr('$')),
									\'!empty(s:Gettabvar(v:val, "DChar"))')
		let db += map(filter(map(tabpagebuflist(tp),
										\'[win_getid(v:key + 1, tp), v:val]'),
			\'index(values(s:Gettabvar(tp, "DChar").wid), v:val[0]) != -1'),
																\'v:val[1]')
	endfor
	if empty(db)
		" sweep all event and initialize because no valid DChar exists
		autocmd! diffchar
		if s:VF.DiffOptionSet
			autocmd diffchar OptionSet diff
										\ call diffchar#ToggleDiffModeSync(0)
		else
			autocmd diffchar FilterWritePost * call diffchar#SetDiffModeSync()
		endif
	else
		" sweep remaining buffer specific event not belonging to any DChar
		for bn in filter(range(1, bufnr('$')), 'index(db, v:val) == -1')
			execute 'autocmd! diffchar * <buffer=' . bn . '>'
		endfor
	endif
endfunction

function! s:ChecksumStr(str)
	return eval('0x' . sha256(a:str)[-4 :])
endfunction

function! s:EchoWarning(msg)
	echohl WarningMsg
	echo a:msg
	echohl None
endfunction

function! s:ShiftMatchaddLines(lid, shift)
	let lid = {}
	let gm = getmatches()
	for [l, id] in a:lid
		let mx = filter(copy(gm), 'index(id, v:val.id) != -1')
		call map(copy(mx), 'matchdelete(v:val.id)')
		let lid[l + a:shift] = map(reverse(mx), 'matchaddpos(v:val.group,
				\map(filter(items(v:val), "v:val[0] =~ ''^pos\\d\\+$''"),
								\"[v:val[1][0] + a:shift] + v:val[1][1 :]"),
											\v:val.priority - a:shift * 10)')
	endfor
	return lid
endfunction

if s:VF.GettabvarFixed
	let s:Gettabvar = function('gettabvar')
else
	function! s:Gettabvar(tp, var)
		call gettabvar(a:tp, a:var)			" call twice as a workaround
		return gettabvar(a:tp, a:var)
	endfunction
endif

if s:VF.ChangenrFixed
	let s:Changenr = function('changenr')
else
	function! s:Changenr()
		let ute = undotree().entries
		for n in range(len(ute))
			if has_key(ute[n], 'curhead')
				" if curhead exists, undotree().seq_cur should be this but not
				" then changenr() returns a wrong number
				return (0 < n) ? ute[n - 1].seq : 0
			endif
		endfor
		return changenr()
	endfunction
endif

function! s:AdjustGlobalOption()
	if !s:VF.DiffUpdated && !s:VF.DiffOptionSet
		call s:ChangeUTOption(exists('t:DChar') && t:DChar.dsy)
	endif
	call s:ChangeDiffCTHL(exists('t:DChar.ovd'))
endfunction

if !s:VF.DiffUpdated && !s:VF.DiffOptionSet
	function! s:ChangeUTOption(on)
		if a:on
			if !exists('s:save_ut') | let s:save_ut = &updatetime | endif
			let &updatetime = 500
		elseif exists('s:save_ut')
			let &updatetime = s:save_ut
			unlet s:save_ut
		endif
	endfunction
endif

function! s:ChangeDiffCTHL(on)
	for [hn, hl] in items(s:DiffCTHL)
		silent execute 'highlight clear ' . hn
		silent execute 'highlight ' . hn . ' ' .
							\hl[!a:on ? 0 : (len(t:DChar.hgp) == 1) ? 1 : 2]
	endfor
endfunction

function! s:ToggleDiffHL(on)
	if a:on == -1
		call s:RestoreDiffHL()
		call s:OverwriteDiffHL()
	else
		call eval(a:on ? s:OverwriteDiffHL() : s:RestoreDiffHL())
		call s:ChangeDiffCTHL(a:on)
	endif
endfunction

function! s:OverwriteDiffHL()
	" overwrite all DiffChange/DiffText area in all diff mode windows
	if exists('t:DChar.ovd') | return | endif
	let cwin = win_getid()
	for w in filter(gettabinfo(tabpagenr())[0].windows,
												\'getwinvar(v:val, "&diff")')
		noautocmd call win_gotoid(w)
		let w:DCharDHL = {}
		for k in [1, 2, 0]
			if k == 0
				call s:AddDiffHL(range(1, line('$')))
			elseif t:DChar.wid[k] == win_getid()
				let xl = map(keys(t:DChar.mid[k]), 'eval(v:val)')
				call s:AddDiffHL(filter(copy(t:DChar.dml[k]),
												\'index(xl, v:val) == -1'))
				break
			endif
		endfor
	endfor
	noautocmd call win_gotoid(cwin)
	let t:DChar.ovd = 1
endfunction

function! s:RestoreDiffHL()
	" delete all the overwritten DiffChange/DiffText area
	if !exists('t:DChar.ovd') | return | endif
	let cwin = win_getid()
	for w in filter(gettabinfo(tabpagenr())[0].windows,
							\'type(getwinvar(v:val, "DCharDHL")) == type({})')
		noautocmd call win_gotoid(w)
		call s:DeleteDiffHL(range(1, line('$')))
		unlet w:DCharDHL
	endfor
	noautocmd call win_gotoid(cwin)
	unlet t:DChar.ovd
endfunction

function! s:AddDiffHL(lines)
	let [dc, dt] = [s:hlID_CT(s:DCharHL.oC), s:hlID_CT(s:DCharHL.oT)]
	for l in filter(copy(a:lines),
								\'index([dc, dt], diff_hlID(v:val, 1)) != -1')
		let pr = -(l * 10)
		let w:DCharDHL[l] = [matchaddpos(s:DCharHL.C, [[l]], pr - 3)]
		let c = filter(range(1, col([l, '$']) - 1),
												\'diff_hlID(l, v:val) == dt')
		if !empty(c)
			let w:DCharDHL[l] +=
					\[matchaddpos(s:DCharHL.T, [[l, c[0], len(c)]], pr - 2)]
		endif
	endfor
endfunction

function! s:DeleteDiffHL(lines)
	for l in filter(map(keys(w:DCharDHL), 'eval(v:val)'),
											\'index(a:lines, v:val) != -1')
		silent! call map(w:DCharDHL[l], 'matchdelete(v:val)')
		unlet w:DCharDHL[l]
	endfor
endfunction

function! s:ShiftDiffHL(lines, shift)
	let lid = []
	for l in filter(map(keys(w:DCharDHL), 'eval(v:val)'),
											\'index(a:lines, v:val) != -1')
		let lid += [[l, w:DCharDHL[l]]]
		unlet w:DCharDHL[l]
	endfor
	call extend(w:DCharDHL, s:ShiftMatchaddLines(lid, a:shift))
endfunction

if has('nvim')
	function! s:hlID_CT(hl)
		return hlID(a:hl) - s:DistDiffHLID()
	endfunction

	function! s:DistDiffHLID()
		" check how diff_hlID() is distant from hlID()
		" in nvim 2.1 diff_hlID() returns (hlID() - 1)
		if !has_key(s:VF, 'DistDiffHLID')
			" find a line with C and T highlights and also
			" record lines with a single highlight
			let hl = ''
			let hs = {}
			let cwin = win_getid()
			let k = 1
			while k <= 2 && empty(hl)
				noautocmd call win_gotoid(t:DChar.wid[k])
				for l in range(1, line('$'))
					let id = diff_hlID(l, 1)
					if id == 0 | continue | endif
					let dh = filter(map(range(1, col([l, '$']) - 1),
									\'diff_hlID(l, v:val)'), 'v:val != id')
					if !empty(dh)
						" found a 2 highlights line : CTC, CT, or TC
						let id = min([id, dh[0]])
						let hl = s:DCharHL.oC
						break
					else
						" record a single highlight lines : A, C, or T
						if !has_key(hs, id) | let hs[id] = {} | endif
						if !has_key(hs[id], k) | let hs[id][k] = [] | endif
						let hs[id][k] += [l]
					endif
				endfor
				let k += 1
			endwhile
			noautocmd call win_gotoid(cwin)
			if empty(hl)
				" check a record of a single highlight lines
				if len(hs) == 2					" A and T
					let id = min(keys(hs))
					let hl = s:DCharHL.A
				elseif len(hs) == 1				" A or T
					let [ix, hx] = items(hs)[0]
					let id = eval(ix)
					let hl =
						\(len(hx) == 2 && values(hx)[0] == values(hx)[1]) ?
												\s:DCharHL.oT : s:DCharHL.A
				else
					return 0					" cannot decide
				endif
			endif
			let s:VF.DistDiffHLID = hlID(hl) - id		" get the distance
		endif
		return s:VF.DistDiffHLID
	endfunction
else
	let s:hlID_CT = function('hlID')
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=4 sw=4
