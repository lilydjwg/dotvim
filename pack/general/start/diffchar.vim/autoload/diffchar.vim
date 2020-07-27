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
" Last Change:	2020/05/01
" Version:		8.7
" Author:		Rick Howe <rdcxy754@ybb.ne.jp>
" Copyright:	(c) 2014-2020 by Rick Howe

let s:save_cpo = &cpoptions
set cpo&vim

" Vim feature, function, event and patch number which this plugin depends on
" patch-8.0.736:  OptionSet event triggered with diff option
" patch-8.0.1038: strikethrough attribute available
" patch-8.0.1160: gettabvar() fixed not to return empty
" patch-8.0.1290: changenr() fixed to return correct value
" patch-8.1.1084: window ID argument available in all match functions
" patch-8.1.1832: win_execute() fixed to work in other tabpage
let s:VF = {
	\'DiffUpdated': exists('##DiffUpdated'),
	\'GUIColors': has('gui_running') ||
									\has('termguicolors') && &termguicolors,
	\'DiffExecutable': executable('diff'),
	\'PopupWindow': has('popupwin'),
	\'FloatingWindow': exists('*nvim_create_buf'),
	\'GetMousePos': exists('*getmousepos'),
	\'WinExecute': exists('*win_execute'),
	\'DiffOptionSet': has('patch-8.0.736'),
	\'StrikeAttr': has('patch-8.0.1038') &&
					\(has('gui_running') || !empty(&t_Ts) && !empty(&t_Te)),
	\'GettabvarFixed': has('patch-8.0.1160'),
	\'ChangenrFixed': has('patch-8.0.1290'),
	\'WinIDinMatch': has('patch-8.1.1084'),
	\'WinExecFixed': has('patch-8.1.1832'),
	\'ValidDiffHLID': has('nvim') ? -1 : 1}

function! s:SetDiffCharHL() abort
	" check vim original Diff highlights and set attributes for changes
	let s:DiffHL = {}
	for hl in ['DiffAdd', 'DiffChange', 'DiffDelete', 'DiffText']
		let id = hlID(hl)
		let at = {}
		for hm in ['term', 'cterm', 'gui']
			for hc in ['fg', 'bg', 'sp']
				let at[hm . hc] = synIDattr(id, hc, hm)
			endfor
			let at[hm] = join(filter(['bold', 'italic', 'reverse', 'inverse',
									\'standout', 'underline', 'undercurl'] +
								\(s:VF.StrikeAttr ? ['strikethrough'] : []),
									\'synIDattr(id, v:val, hm) == 1'), ',')
		endfor
		let dh = {}
		let dh.id = id
		" 0: original, 1: for single color, 2: for multi color
		let dh.0 = filter(at, '!empty(v:val)')
		let dh.1 = (hl == 'DiffChange' || hl == 'DiffText') ?
									\filter(copy(at), 'v:key =~ "bg$"') : dh.0
		let dh.2 = (hl == 'DiffChange') ? dh.1 :
											\(hl == 'DiffText') ? {} : dh.0
		let s:DiffHL[hl] = dh
	endfor
	" adjust id to be equal to diff_hlID() in nvim
	if s:VF.ValidDiffHLID == -1
		let s:VF.ValidDiffHLID = s:CheckDiffHLID()
	endif
	if s:VF.ValidDiffHLID == 0
		for hl in keys(s:DiffHL) | let s:DiffHL[hl].id -= 1 | endfor
	endif
	" set DiffChar specific highlights
	let s:DCharHL = {'A': 'DiffAdd', 'D': 'DiffDelete', 'n': 'LineNr',
							\'c': (s:VF.GUIColors ? 'Cursor' : 'VertSplit')}
	for [fh, tn, th, ta] in [['DiffChange', 'C', 'dcDiffChange', ''],
										\['DiffText', 'T', 'dcDiffText', ''],
					\['DiffChange', 'E', 'dcDiffErase', 'bold,underline']] +
			\(s:VF.StrikeAttr ?
				\[['DiffDelete', 'D', 'dcDiffDelete', 'strikethrough']] : [])
		let fa = copy(s:DiffHL[fh].0)
		if !empty(ta)
			for hm in ['term', 'cterm', 'gui']
				let fa[hm] = has_key(fa, hm) ? fa[hm] . ',' . ta : ta
			endfor
		endif
		call execute('highlight clear ' . th)
		call execute('highlight ' . th . ' ' .
						\join(map(items(fa), 'v:val[0] . "=" . v:val[1]')))
		let s:DCharHL[tn] = th
	endfor
	" change diff highlights according to current DChar
	call s:ToggleDiffHL(exists('t:DChar'))
endfunction

function! s:InitializeDiffChar() abort
	" select current and next diff mode windows whose buffer is different
	" do no initiate if more than 2 diff mode windows exist in a tab page and
	" if a selected buffer already DChar highlighted in other tab pages
	let cwid = win_getid()
	let cbnr = winbufnr(cwid)
	let nwid = filter(map(range(winnr() + 1, winnr('$')) +
								\range(1, winnr() - 1), 'win_getid(v:val)'),
					\'getwinvar(v:val, "&diff") && winbufnr(v:val) != cbnr')
	let nbnr = map(copy(nwid), 'winbufnr(v:val)')
	if !getwinvar(cwid, '&diff') || empty(nwid) || min(nbnr) != max(nbnr)
		return -1
	endif
	for tn in filter(range(1, tabpagenr('$')), 'tabpagenr() != v:val')
		let dc = s:Gettabvar(tn, 'DChar')
		if !empty(dc)
			for bn in values(dc.bnr)
				if index([cbnr, nbnr[0]], bn) != -1
					call s:EchoWarning('Both or either selected buffer already
									\ highlighted in tab page ' . tn . '!')
					return -1
				endif
			endfor
		endif
	endfor
	" set diffchar highlights
	call s:SetDiffCharHL()
	" define a DiffChar dictionary on this tab page
	let t:DChar = {}
	" windowID and bufnr
	let t:DChar.wid = {'1': cwid, '2': nwid[0]}
	let t:DChar.bnr = {'1': cbnr, '2': nbnr[0]}
	" diff mode synchronization flag
	let t:DChar.dsy = get(g:, 'DiffModeSync', 1)
	" a multiple of the current visible page to locally detect diff lines
	let t:DChar.dfp = get(g:, 'DiffFocalPages', 3)
	" top/bottom/last lines, cursor line/column, changenr on each window
	let t:DChar.lcc = s:GetLineColCnr(1)
	" a list of diff focus lines
	let t:DChar.dfl = s:FocusDiffLines(1, 1)
	" a type of diff pair visible
	let pv = get(t:, 'DiffPairVisible', g:DiffPairVisible)
	if pv == 3 && !(s:VF.PopupWindow || s:VF.FloatingWindow) ||
						\pv == 4 && !(s:VF.PopupWindow && s:VF.GetMousePos)
		let pv = 1
	endif
	let t:DChar.dpv = {'pv': pv}
	if 0 < pv
		let t:DChar.dpv.ch = {}
		if pv == 3 || pv == 4
			let t:DChar.dpv.pw = s:VF.PopupWindow ? 0 :
							\s:VF.FloatingWindow ? {'fb': -1, 'fw': -1} : -1
		endif
	endif
	" a list of highlight IDs per line
	let t:DChar.mid = {'1': {}, '2': {}}
	" a list of added/deleted/changed columns per line
	let t:DChar.hlc = {'1': {}, '2': {}}
	" checksum per line
	let t:DChar.cks = {'1': {}, '2': {}}
	" ignorecase and ignorespace flags
	let do = split(&diffopt, ',')
	let t:DChar.igc = (index(do, 'icase') != -1)
	let t:DChar.igs = (index(do, 'iwhiteall') != -1) ? 1 :
									\(index(do, 'iwhite') != -1) ? 2 :
									\(index(do, 'iwhiteeol') != -1) ? 3 : 0
	" a pattern to split difference units
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
	" a list of difference matching colors
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

function! diffchar#ToggleDiffChar(lines) abort
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

function! diffchar#ShowDiffChar(...) abort
	let init = !exists('t:DChar')
	if init && s:InitializeDiffChar() == -1 | return | endif
	for ak in [1, 2, 0]
		if ak == 0 | return | endif
		if t:DChar.wid[ak] == win_getid() | break | endif
	endfor
	let dl = []
	for n in filter(map(copy(t:DChar.dfl[ak]),
			\'(a:0 && index(a:1, v:val) == -1) ? -1 : v:key'), 'v:val != -1')
		let [l1, l2] = [t:DChar.dfl[1][n], t:DChar.dfl[2][n]]
		if !has_key(t:DChar.hlc[1], l1) && !has_key(t:DChar.hlc[2], l2)
			let dl += [[{l1: getbufline(t:DChar.bnr[1], l1)[0]},
									\{l2: getbufline(t:DChar.bnr[2], l2)[0]}]]
		endif
	endfor
	if !init && empty(dl) | return | endif
	let save_igc = &ignorecase | let &ignorecase = t:DChar.igc
	let uu = []
	for n in range(len(dl))
		let [d1, d2] = dl[n]
		for k in [1, 2]
			let t = values(d{k})[0]
			if t:DChar.igs
				let u{k} = split(substitute(t, '\s\+$', '', ''), t:DChar.upa)
				if t:DChar.igs == 1				" iwhiteall
					call filter(u{k}, 'v:val !~ "^\\s\\+$"')
				elseif t:DChar.igs == 2			" iwhite
					let s = len(u{k}) - 1
					while 0 < s
						if u{k}[s - 1] . u{k}[s] =~ '^\s\+$'
							let u{k}[s - 1] .= u{k}[s]
							unlet u{k}[s]
						endif
						let s -= 1
					endwhile
				endif
			else
				let u{k} = split(t, t:DChar.upa)
			endif
		endfor
		if u1 == u2 | let dl[n] = []
		else | let uu += [[u1, u2]]
		endif
	endfor
	call filter(dl, '!empty(v:val)')
	let es = []
	if s:VF.DiffExecutable
		let [mu, mt, st] = [get(g:, 'DiffIntMaxUnits', 2000),
								\get(g:, 'DiffIntMaxTime', 1.0), reltime()]
	endif
	for n in range(len(uu))
		let [u1, u2] = uu[n]
		if s:VF.DiffExecutable &&
				\(mu < len(u1) + len(u2) || mt < reltimefloat(reltime(st)))
			" the next line includes 2000+ units OR already spent 1.0+s
			let es += s:ExecDiffCommand(uu[n :])
			break
		endif
		if t:DChar.igs == 2				" iwhite
			for k in [1, 2]
				let u{k} = map(copy(u{k}),
									\'(v:val =~ "^\\s\\+$") ? " " : v:val')
			endfor
		endif
		let es += [s:TraceDiffChar(u1, u2)]
	endfor
	let lc = {'1': {}, '2': {}}
	for n in range(len(dl))
		let [d1, d2] = dl[n]
		let [c1, c2] = s:GetDiffUnitPos(es[n], uu[n])
		for k in [1, 2]
			let [l, t] = items(d{k})[0]
			if t:DChar.igs == 1				" iwhiteall
				if t =~ '\s\+'
					let ap = filter(range(1, len(t)), 't[v:val - 1] !~ "\\s"')
					call map(c{k}, '[v:val[0],
								\[ap[v:val[1][0] - 1], ap[v:val[1][1] - 1]]]')
				endif
			endif
			let lc[k][l] = c{k}
			let t:DChar.cks[k][l] = s:ChecksumStr(t)
		endfor
	endfor
	let &ignorecase = save_igc
	call s:HighlightDiffChar(ak, lc)
	if !t:DChar.dsy && index(values(t:DChar.hlc), {}) != -1
		unlet t:DChar
	else
		if init			" set event when DChar HL is newly defined
			call s:ToggleDiffCharEvent(1)
			call s:ToggleDiffHL(1)
			call s:ToggleDiffCharPair(1)
		endif
		if 0 < t:DChar.dpv.pv | call s:ShowDiffCharPair(ak) | endif
	endif
endfunction

function! s:ExecDiffCommand(uu) abort
	" prepare 2 input files for diff
	for [k, u] in [[1, 0], [2, 1]]
		" insert '|<number>:' before each line and
		" add '=<number>:' at the beginning of each unit
		let u{k} = ['']			" a dummy to avoid 1st null unit error
		for n in range(len(a:uu))
			let u{k} += ['|' . n . ':'] +
							\map(copy(a:uu[n][u]), '"=" . n . ":" . v:val')
		endfor
		let f{k} = tempname()
		call writefile(u{k}, f{k})
	endfor
	" call diff in unified format and assign edit symbols [=+-] to each unit
	let opt = '-a --binary -d -U ' . (len(u1) + len(u2)) . ' '
	if t:DChar.igc | let opt .= '-i ' | endif
	if t:DChar.igs == 1 | let opt .= '-w '
	elseif t:DChar.igs == 2 | let opt .= '-b '
	elseif t:DChar.igs == 3 | let opt .= '-Z '
	endif
	let save_stmp = &shelltemp
	let &shelltemp = 0
	let dout = systemlist('diff ' . opt . f1 . ' ' . f2)
	let &shelltemp = save_stmp
	for k in [1, 2] | call delete(f{k}) | endfor
	return split(join(map(filter(dout, 'v:val =~ "^[ +-][|=]"'),
						\'(v:val[0] != " ") ? v:val[0] : v:val[1]'), ''), '|')
endfunction

function! s:GetDiffUnitPos(es, uu) abort
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

function! s:TraceDiffChar(u1, u2) abort
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

function! diffchar#ResetDiffChar(...) abort
	if !exists('t:DChar') | return | endif
	let last = (a:0 && type(a:1) == type(0)) ? a:1 : 0
	for k in [1, 2, 0]
		if k == 0 | return | endif
		if t:DChar.wid[k] == win_getid() | break | endif
	endfor
	let dl = {'1': [], '2': []}
	for n in filter(map(copy(t:DChar.dfl[k]),
				\'(a:0 && type(a:1) == type([]) &&
					\index(a:1, v:val) == -1) ? -1 : v:key'), 'v:val != -1')
		let [l1, l2] = [t:DChar.dfl[1][n], t:DChar.dfl[2][n]]
		if has_key(t:DChar.hlc[1], l1) || has_key(t:DChar.hlc[2], l2)
			let [dl[1], dl[2]] += [[l1], [l2]]
			unlet t:DChar.cks[1][l1] | unlet t:DChar.cks[2][l2]
		endif
	endfor
	if !last && empty(dl[k])| return | endif
	call s:ClearDiffChar(k, dl)
	if 0 < t:DChar.dpv.pv | call s:ClearDiffCharPair(k) | endif
	if last || !t:DChar.dsy && index(values(t:DChar.hlc), {}) != -1
		call s:ToggleDiffCharEvent(0)
		call s:ToggleDiffHL(0)
		call s:ToggleDiffCharPair(0)
		unlet t:DChar
	endif
endfunction

function! s:ToggleDiffCharEvent(on) abort
	let ac = []
	for k in [1, 2]
		let bl = '<buffer=' . t:DChar.bnr[k] . '>'
		let ac += [['BufWinLeave', bl,
							\'s:BufWinLeaveDiffChar(' . t:DChar.wid[k] . ')']]
		let ac += [['WinLeave', bl, 's:WinLeaveDiffChar(' . k . ')']]
		if t:DChar.dsy
			let ac += [['TextChanged', bl, 's:UpdateDiffChar(' . k . ', 0)']]
			let ac += [['InsertLeave', bl, 's:UpdateDiffChar(' . k . ', 0)']]
			if s:VF.DiffUpdated
				let ac += [['DiffUpdated', bl,
										\'s:UpdateDiffChar(' . k . ', 1)']]
			endif
			if t:DChar.dfp != 0
				let ac += [['CursorMoved', bl,
											\'s:ScrollDiffChar(' . k . ')']]
			endif
		endif
		if 0 < t:DChar.dpv.pv
			let ac += [['CursorMoved', bl, 's:ShowDiffCharPair(' . k . ')']]
		endif
	endfor
	let td = filter(map(filter(range(1, tabpagenr('$')),
													\'tabpagenr() != v:val'),
							\'s:Gettabvar(v:val, "DChar")'), '!empty(v:val)')
	if empty(td)
		let ac += [['TabEnter', '*', 's:AdjustGlobalOption()']]
		let ac += [['ColorScheme', '*', 's:SetDiffCharHL()']]
		if !s:VF.DiffUpdated && s:VF.DiffOptionSet
			let ac += [['OptionSet', 'diffopt', 's:FollowDiffOption()']]
		endif
	endif
	if !s:VF.DiffUpdated && !s:VF.DiffOptionSet
		if t:DChar.dsy
			if empty(filter(td, 'exists("v:val.dfl") && v:val.dsy'))
				" save command to recover later in SwitchDiffChar()
				let s:save_ch = a:on ? 's:ResetDiffModeSync()' : ''
				let ac += [['CursorHold', '*', s:save_ch]]
			endif
			call s:ChangeUTOpt(a:on)
		endif
	endif
	call execute(map(ac, '"autocmd" . (a:on ? "" : "!") . " diffchar " .
			\v:val[0] . " " . v:val[1] . (a:on ? " call " . v:val[2] : "")'))
endfunction

function! s:FocusDiffLines(key, init) abort
	" a:init : initialize dfl (do not use previous dfl)
	let dfl = {}
	let ks = (a:key == 1) ? [2, 1] : [1, 2]
	" check all diff lines
	if t:DChar.dfp == 0
		if a:init
			for k in ks
				call s:WinGotoID(t:DChar.wid[k])
				call s:WinExecute('let dfl[k] =
									\s:GetDiffLines(1, t:DChar.lcc[k].ll)')
			endfor
			return dfl
		else
			return t:DChar.dfl
		endif
	endif
	" check visible diff lines and merge with previous dfl
	" 1. get dfl in current visible lines and return if no new in both wins
	for k in ks
		call s:WinGotoID(t:DChar.wid[k])
		call s:WinExecute('let dfl[k] =
					\s:GetDiffLines(t:DChar.lcc[k].tl, t:DChar.lcc[k].bl)')
	endfor
	if !a:init
		let nd = 0
		for k in ks
			if !empty(dfl[k])
				let [ti, bi] = [index(t:DChar.dfl[k], dfl[k][0]),
										\index(t:DChar.dfl[k], dfl[k][-1])]
				let nd += (ti == -1) || (bi == -1) ||
										\(t:DChar.dfl[k][ti : bi] != dfl[k])
			endif
		endfor
		if nd == 0 | return t:DChar.dfl | endif
		let lh = {}
		for k in ks
			let lh[k] = empty(dfl[k]) ? {'l': 0, 'h': 0} :
				\{'l': len(filter(copy(t:DChar.dfl[k]), 'v:val < dfl[k][0]')),
				\'h': len(filter(copy(t:DChar.dfl[k]), 'dfl[k][-1] < v:val'))}
		endfor
	endif
	" 2. get dfl in upper/lower lines and return if not found in both wins
	for k in ks
		let [fl, tl, bl, ll] =
				\[1, t:DChar.lcc[k].tl, t:DChar.lcc[k].bl, t:DChar.lcc[k].ll]
		if !a:init && 0 < t:DChar.dfp
			if 0 < lh[k].l | let fl = t:DChar.dfl[k][lh[k].l - 1] + 1 | endif
			if 0 < lh[k].h | let ll = t:DChar.dfl[k][-lh[k].h] - 1 | endif
		endif
		let [tz, bz] = [tl, bl]
		let rc = min([(tl - fl) + (ll - bl),
									\(abs(t:DChar.dfp) - 1) * (bl - tl + 1)])
		if 0 < rc
			let hc = (rc + 1) / 2
			let [tr, br] = [tl - fl, ll - bl]
			let tb = [hc <= tr, rc - hc <= br]
			let [tc, bc] = (tb == [1, 1]) ? [hc, rc - hc] : (tb == [0, 1]) ?
					\[tr, rc - tr] : (tb == [1, 0]) ? [rc - br, br] : [tr, br]
			let [tz, bz] += [-tc, bc]
		endif
		call s:WinGotoID(t:DChar.wid[k])
		call s:WinExecute('let dfl[k] = s:GetDiffLines(tz, tl - 1) + dfl[k] +
												\s:GetDiffLines(bl + 1, bz)')
	endfor
	if empty(dfl[1]) && empty(dfl[2]) | return dfl | endif
	if index(values(dfl), []) != -1
		" 3. if no dfl found in either, set a reference line and search dfl
		let [ek, fk] = empty(dfl[1]) ? [1, 2] : [2, 1]
		let rl = {}
		let [rl[ek], rl[fk]] = [{'l': 1, 'h': t:DChar.lcc[ek].ll},
										\{'l': 1, 'h': t:DChar.lcc[fk].ll}]
		if !a:init
			if 0 < lh[fk].l
				let [rl[ek].l, rl[fk].l] = [t:DChar.dfl[ek][lh[fk].l - 1],
											\t:DChar.dfl[fk][lh[fk].l - 1]]
			endif
			if 0 < lh[fk].h
				let [rl[ek].h, rl[fk].h] = [t:DChar.dfl[ek][-lh[fk].h],
												\t:DChar.dfl[fk][-lh[fk].h]]
			endif
		endif
		let sd = dfl[fk][0] - rl[fk].l < rl[fk].h - dfl[fk][-1]
		call s:WinGotoID(t:DChar.wid[fk])
		call s:WinExecute('let dc = len(sd ?
								\s:GetDiffLines(rl[fk].l, dfl[fk][0] - 1) :
								\s:GetDiffLines(dfl[fk][-1] + 1, rl[fk].h))')
		let fc = len(dfl[fk])
		call s:WinGotoID(t:DChar.wid[ek])
		call s:WinExecute('let dfl[ek] =
				\s:SearchDiffLines(sd, sd ? rl[ek].l : rl[ek].h, dc + fc)')
		let dfl[ek] = sd ? dfl[ek][-fc :] : dfl[ek][: fc - 1]
		call s:WinGotoID(t:DChar.wid[ks[1]])
	else
		" 4. set reference lines using the closest line of previous dfl
		let rl = [[1, 1], [t:DChar.lcc[1].ll, t:DChar.lcc[2].ll]]
		if !a:init && index(values(t:DChar.dfl), []) == -1
			let rx = []
			for k in ks
				let rx += ((0 < lh[k].l) ? [lh[k].l - 1] : [0]) +
										\((0 < lh[k].h) ? [-lh[k].h] : [-1])
			endfor
			let rl += map(rx,
							\'[t:DChar.dfl[1][v:val], t:DChar.dfl[2][v:val]]')
		endif
		" 5. select a reference line which is closest to new dfl
		let ds = map(copy(rl), 'abs(v:val[0] - (dfl[1][0] + dfl[1][-1]) / 2) +
							\abs(v:val[1] - (dfl[2][0] + dfl[2][-1]) / 2)')
		let ci = index(ds, min(ds))
		let cl = {'1': rl[ci][0], '2': rl[ci][1]}
		" 6. get # of dfl (+/-) between reference and top/bottom lines
		let tb = {}
		for k in ks
			let [tl, bl, xl] = [dfl[k][0], dfl[k][-1], cl[k]]
			let td = (tl <= xl) ? [tl, xl, 1] : [xl, tl, -1]
			let bd = (bl <= xl) ? [bl, xl, 1] : [xl, bl, -1]
			call s:WinGotoID(t:DChar.wid[k])
			call s:WinExecute('let tb[k] =
						\[(len(s:GetDiffLines(td[0], td[1])) - 1) * td[2],
						\(len(s:GetDiffLines(bd[0], bd[1])) - 1) * bd[2]]')
		endfor
		" 7. search and adjust dfl above/below the top/bottom in each window
		let dx = {'1': [0, 0, len(dfl[2])], '2': [0, 0, len(dfl[1])]}
		let [tx, bx] = [tb[1][0] - tb[2][0], tb[1][1] - tb[2][1]]
		let k = (tx < 0) ? 1 : (tx > 0) ? 2 : 0
		if k != 0 | let dx[k][0] = abs(tx) | endif
		let k = (bx < 0) ? 2 : (bx > 0) ? 1 : 0
		if k != 0 | let dx[k][1] = abs(bx) | endif
		for k in ks
			call s:WinGotoID(t:DChar.wid[k])
			call s:WinExecute('let [td, bd] =
							\[s:SearchDiffLines(0, dfl[k][0] - 1, dx[k][0]),
							\s:SearchDiffLines(1, dfl[k][-1] + 1, dx[k][1])]')
			let [tx, bx] =
						\[min([dx[k][2], len(td)]), min([dx[k][2], len(bd)])]
			let dfl[k] = td[: tx - 1] + dfl[k] + bd[-bx :]
		endfor
	endif
	" 8. merge with previous dfl when 0 < dfp
	if !a:init && index(values(t:DChar.dfl), []) == -1 && 0 < t:DChar.dfp
		for k in ks
			call filter(dfl[k], 'index(t:DChar.dfl[k], v:val) == -1')
			let dfl[k] = empty(dfl[k]) ? t:DChar.dfl[k] :
				\(t:DChar.dfl[k][-1] < dfl[k][0]) ? t:DChar.dfl[k] + dfl[k] :
				\(dfl[k][-1] < t:DChar.dfl[k][0]) ? dfl[k] + t:DChar.dfl[k] :
				\filter(copy(t:DChar.dfl[k]), 'v:val < dfl[k][0]') + dfl[k] +
						\filter(copy(t:DChar.dfl[k]), 'dfl[k][-1] < v:val')
		endfor
	endif
	return dfl
endfunction

function! s:SearchDiffLines(sd, sl, sc) abort
	" a:sd = direction (1:down, 0:up), a:sl = start line, a:sc = count
	let dl = []
	if 0 < a:sc
		let sl = a:sl
		if a:sd
			while sl <= line('$')
				let fl = foldclosedend(sl)
				if fl != -1 | let sl = fl + 1 | endif
				let dl += s:GetDiffLines(sl, min([sl + a:sc - 1, line('$')]))
				if a:sc <= len(dl) | let dl = dl[: a:sc - 1] | break | endif
				let sl += a:sc
			endwhile
		else
			while 1 <= sl
				let fl = foldclosed(sl)
				if fl != -1 | let sl = fl - 1 | endif
				let dl = s:GetDiffLines(max([sl - a:sc + 1, 1]), sl) + dl
				if a:sc <= len(dl) | let dl = dl[-a:sc :] | break | endif
				let sl -= a:sc
			endwhile
		endif
	endif
	return dl
endfunction

function! s:GetDiffLines(sl, el) abort
	return (a:sl > a:el) ? [] :
				\filter(filter(range(a:sl, a:el), 'foldlevel(v:val) == 0'),
					\'index([s:DiffHL.DiffChange.id, s:DiffHL.DiffText.id],
												\diff_hlID(v:val, 1)) != -1')
endfunction

function! s:GetLineColCnr(key) abort
	let lcc = {}
	for k in (a:key == 1) ? [2, 1] : [1, 2]
		call s:WinGotoID(t:DChar.wid[k])
		call s:WinExecute('let lcc[k] =
			\{"tl": line("w0"), "bl": line("w$"), "ll": line("$"),
			\"cl": line("."), "cc": col("."), "cn": s:Changenr(), "ig": 0}')
		call s:WinExecute('let [tl, bl] =
						\[foldclosedend(lcc[k].tl), foldclosed(lcc[k].bl)]')
		if tl != -1 | let lcc[k].tl = tl | endif
		if bl != -1 | let lcc[k].bl = bl | endif
	endfor
	return lcc
endfunction

function! s:ScrollDiffChar(key) abort
	if !exists('t:DChar') || t:DChar.wid[a:key] != win_getid()
		return
	endif
	let lcc = s:GetLineColCnr(a:key)
	let scl = 0
	for k in [1, 2]
		" check if a scroll happens in either window with no change on both
		let scl += (t:DChar.lcc[k].cn != lcc[k].cn) ? -1 :
								\([t:DChar.lcc[k].tl, t:DChar.lcc[k].bl] !=
											\[lcc[k].tl, lcc[k].bl]) ? 1 : 0
		let [t:DChar.lcc[k].tl, t:DChar.lcc[k].bl] = [lcc[k].tl, lcc[k].bl]
	endfor
	if 0 < scl
		let dfl = s:FocusDiffLines(a:key, 0)
		if t:DChar.dfl != dfl
			" reset/show DChar lines on dfl changes
			if t:DChar.dfp < 0
				let ddl = filter(copy(t:DChar.dfl[a:key]),
											\'index(dfl[a:key], v:val) == -1')
				if !empty(ddl) | call diffchar#ResetDiffChar(ddl) | endif
			endif
			let adl = filter(copy(dfl[a:key]),
									\'index(t:DChar.dfl[a:key], v:val) == -1')
			let t:DChar.dfl = dfl
			if !empty(adl) | call diffchar#ShowDiffChar(adl) | endif
		endif
	endif
endfunction

function! s:HighlightDiffChar(key, lec) abort
	for k in (a:key == 1) ? [2, 1] : [1, 2]
		if !s:VF.WinIDinMatch | call s:WinGotoID(t:DChar.wid[k]) | endif
		for [l, ec] in items(a:lec[k])
			if has_key(t:DChar.mid[k], l) | continue | endif
			let t:DChar.hlc[k][l] = ec
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
			let t:DChar.mid[k][l] = [s:Matchaddpos(t:DChar.wid[k],
												\s:DCharHL.C, [[l]], pr - 1)]
			for [h, c] in items(hc)
				call map(c, '[l, v:val[0], v:val[1] - v:val[0] + 1]')
				let t:DChar.mid[k][l] += map(range(0, len(c) - 1, 8),
											\'s:Matchaddpos(t:DChar.wid[k], h,
												\c[v:val : v:val + 7], pr)')
			endfor
		endfor
	endfor
endfunction

function! s:ClearDiffChar(key, lines) abort
	for k in (a:key == 1) ? [2, 1] : [1, 2]
		if !s:VF.WinIDinMatch | call s:WinGotoID(t:DChar.wid[k]) | endif
		for l in a:lines[k]
			silent! call map(t:DChar.mid[k][l],
									\'s:Matchdelete(t:DChar.wid[k], v:val)')
			unlet t:DChar.mid[k][l]
			unlet t:DChar.hlc[k][l]
		endfor
	endfor
endfunction

function! s:ShiftDiffChar(key, lines, shift) abort
	let [lid, hlc, cks] = [[], {}, {}]
	for l in filter(copy(a:lines), 'has_key(t:DChar.mid[a:key], v:val)')
		let lid += [[l, t:DChar.mid[a:key][l]]]
		let hlc[l + a:shift] = t:DChar.hlc[a:key][l]
		let cks[l + a:shift] = t:DChar.cks[a:key][l]
		unlet t:DChar.mid[a:key][l]
		unlet t:DChar.hlc[a:key][l]
		unlet t:DChar.cks[a:key][l]
	endfor
	call extend(t:DChar.mid[a:key],
					\s:ShiftMatchaddLines(t:DChar.wid[a:key], lid, a:shift))
	call extend(t:DChar.hlc[a:key], hlc)
	call extend(t:DChar.cks[a:key], cks)
endfunction

function! s:ShiftMatchaddLines(wid, lid, shift) abort
	let lid = {}
	let gm = s:Getmatches(a:wid)
	for [l, id] in a:lid
		let mx = filter(copy(gm), 'index(id, v:val.id) != -1')
		call map(copy(mx), 's:Matchdelete(a:wid, v:val.id)')
		let lid[l + a:shift] = map(reverse(mx),
				\'s:Matchaddpos(a:wid, v:val.group,
					\map(filter(items(v:val), "v:val[0] =~ ''^pos\\d\\+$''"),
								\"[v:val[1][0] + a:shift] + v:val[1][1 :]"),
											\v:val.priority - a:shift * 10)')
	endfor
	return lid
endfunction

function! s:UpdateDiffChar(key, event) abort
	" a:event : 0 = TextChanged/InsertLeave, 1 = DiffUpdated
	if mode(1) != 'n' || !exists('t:DChar') ||
			\!empty(filter(values(t:DChar.wid), '!getwinvar(v:val, "&diff")'))
		return
	endif
	if !s:VF.DiffUpdated | call s:RedrawDiffChar(a:key, 1) | return | endif
	" try to redraw updated DChar lines at the last DiffUpdated which comes
	" just after TextChanged or InsertLeave if text changed
	if a:event == 1
		if t:DChar.lcc[a:key].ig == 0
			if t:DChar.lcc[a:key].cn == s:Changenr()
				call s:RedrawDiffChar(a:key, 0)
			else
				" in case of e:, DiffUpdated happens 3 times,
				" first, all dfl not diff highlighed but no line diff folded,
				" then wait for the next two events
				if &foldmethod == 'diff' && !empty(t:DChar.dfl[a:key]) &&
					\empty(filter(copy(t:DChar.dfl[a:key]),
											\'diff_hlID(v:val, 1) != 0')) &&
					\empty(filter(range(t:DChar.dfl[a:key][0],
							\t:DChar.dfl[a:key][-1]), '0 < foldlevel(v:val)'))
					let t:DChar.lcc[a:key].ig += 1
				endif
			endif
		elseif t:DChar.lcc[a:key].ig == 1	" wait for another one
			let t:DChar.lcc[a:key].ig += 1
		elseif t:DChar.lcc[a:key].ig == 2	" the last one came then redraw
			let t:DChar.lcc[a:key].ig = 0
			call s:RedrawDiffChar(a:key, 1)
		endif
	else
		if &diffopt =~ 'internal' && empty(&diffexpr)
			if t:DChar.lcc[a:key].cn != s:Changenr()
				let t:DChar.lcc[a:key].ig = 2	" wait for the next/last one
			endif
		else
			call s:RedrawDiffChar(a:key, 1)		" DiffUpdated not happen next
		endif
	endif
endfunction

function! s:RedrawDiffChar(key, txtcg) abort
	" a:txtcg : 0 = for text unchanged, 1 = for text changed
	let ll = t:DChar.lcc[a:key].ll
	let t:DChar.lcc = s:GetLineColCnr(a:key)
	let cfl = s:FocusDiffLines(a:key, 1)
	if a:txtcg
		" compare between previous and current DChar and diff lines
		" using checksum and find ones to be deleted, added, and shifted
		let lnd = t:DChar.lcc[a:key].ll - ll
		let bk = (a:key == 1) ? 2 : 1
		let [pfa, pfb] = [t:DChar.dfl[a:key], t:DChar.dfl[bk]]
		let [cfa, cfb] = [cfl[a:key], cfl[bk]]
		let m = min([len(pfa), len(cfa)])
		if pfa == cfa
			let ddl = []
			for s in range(m)
				if pfb[s] != cfb[s] || get(t:DChar.cks[a:key], pfa[s]) !=
											\s:ChecksumStr(getline(cfa[s]))
					let ddl += [pfa[s]]
				endif
			endfor
			let adl = ddl
			let sdl = []
		else
			let s = 0
			while s < m && pfa[s] == cfa[s] && pfb[s] == cfb[s] &&
										\get(t:DChar.cks[a:key], pfa[s]) ==
											\s:ChecksumStr(getline(cfa[s]))
				let s += 1
			endwhile
			let e = -1
			let m -= s
			while e >= -m && pfa[e] + lnd == cfa[e] && pfb[e] == cfb[e] &&
										\get(t:DChar.cks[a:key], pfa[e]) ==
											\s:ChecksumStr(getline(cfa[e]))
				let e -= 1
			endwhile
			let ddl = pfa[s : e]
			let adl = cfa[s : e]
			let sdl = (lnd != 0 && e < -1) ? pfa[e + 1 :] : []
		endif
		" redraw updated DChar lines
		if 0 < t:DChar.dpv.pv | call s:ClearDiffCharPair(a:key) | endif
		if !empty(ddl) | call diffchar#ResetDiffChar(ddl) | endif
		let t:DChar.dfl = cfl
		if !empty(sdl) | call s:ShiftDiffChar(a:key, sdl, lnd) | endif
		if !empty(adl) | call diffchar#ShowDiffChar(adl) | endif
	else
		" reset dfl and redraw all DChar lines on text unchanged
		" (diffupdate and diffopt changes)
		let do = split(&diffopt, ',')
		let igc = (index(do, 'icase') != -1)
		let igs = (index(do, 'iwhiteall') != -1) ? 1 :
									\(index(do, 'iwhite') != -1) ? 2 :
									\(index(do, 'iwhiteeol') != -1) ? 3 : 0
		if [t:DChar.dfl, t:DChar.igc, t:DChar.igs] != [cfl, igc, igs]
			call diffchar#ResetDiffChar()
			let [t:DChar.dfl, t:DChar.igc, t:DChar.igs] = [cfl, igc, igs]
			call diffchar#ShowDiffChar()
		endif
	endif
endfunction

function! diffchar#JumpDiffChar(dir, pos) abort
	" a:dir : 0 = backward, 1 = forward / a:pos : 0 = start, 1 = end
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
		" found in current line
		let hc = filter(map(copy(t:DChar.hlc[k][ln]), 'v:val[1][a:pos]'),
										\a:dir ? 'co < v:val' : 'co > v:val')
		let co = hc[a:dir ? 0 : -1]
	else
		if t:DChar.dfp == 0
			" try to find the next highlighted line
			let hl = filter(map(keys(t:DChar.hlc[k]), 'eval(v:val)'),
										\a:dir ? 'ln < v:val' : 'ln > v:val')
			if empty(hl) | return | endif
			let ln = a:dir ? min(hl) : max(hl)
		else
			" try to find the next diff line and then apply hlc or scroll
			let cp = [line('.'), col('.')]
			while 1
				let dl = s:SearchDiffLines(a:dir, a:dir ? ln + 1 : ln - 1, 1)
				if empty(dl) | noautocmd call cursor(cp) | return | endif
				let ln = dl[0]
				if has_key(t:DChar.hlc[k], ln) | break | endif
				noautocmd call cursor(ln, 0)
				call s:ScrollDiffChar(k)
				if has_key(t:DChar.hlc[k], ln) | break | endif
			endwhile
		endif
		let co = t:DChar.hlc[k][ln][a:dir ? 0 : -1][1][a:pos]
	endif
	" set a dummy cursor position to adjust the start/end
	if 0 < t:DChar.dpv.pv
		call s:ClearDiffCharPair(k)
		if [a:dir, a:pos] == [1, 0]				" forward/start : rightmost
			let [t:DChar.lcc[k].cl, t:DChar.lcc[k].cc] = [ln, col('$')]
		elseif [a:dir, a:pos] == [0, 1]			" backward/end : leftmost
			let [t:DChar.lcc[k].cl, t:DChar.lcc[k].cc] = [ln, 0]
		endif
	endif
	call cursor(ln, co)
endfunction

function! s:ShowDiffCharPair(key) abort
	if mode(1) != 'n' || !exists('t:DChar') ||
											\t:DChar.wid[a:key] != win_getid()
		return
	endif
	let [pl, pc, pn] = [t:DChar.lcc[a:key].cl, t:DChar.lcc[a:key].cc,
													\t:DChar.lcc[a:key].cn]
	let [cl, cc] = [line('.'), col('.')]
	if cc == col('$') | let cc = 0 | endif
	let [t:DChar.lcc[a:key].cl, t:DChar.lcc[a:key].cc] = [cl, cc]
	if pn != s:Changenr() | return | endif		" do nothing on TextChanged
	if !empty(t:DChar.dpv.ch)
		" pair highlight exists
		let [hl, hi] = t:DChar.dpv.ch.lc
		let hc = t:DChar.hlc[a:key][hl][hi][1]
		" inside the highlight, do nothing
		if cl == hl && hc[0] <= cc && cc <= hc[1] | return | endif
		call s:ClearDiffCharPair(a:key)	" outside, clear it
	endif
	if has_key(t:DChar.hlc[a:key], cl)
		let hu = filter(map(copy(t:DChar.hlc[a:key][cl]),
			\'[v:key, v:val[1]]'), 'v:val[1][0] <= cc && cc <= v:val[1][1]')
		if !empty(hu)
			" for 2 contineous 'd', check if cursor moved forward or backward
			let ix = (len(hu) == 1) ? 0 : (cl == pl) ? cc < pc : cl < pl
			call s:HighlightDiffCharPair(a:key, cl, hu[ix][0])
		endif
	endif
endfunction

function! s:HighlightDiffCharPair(key, line, col) abort
	let [ak, bk] = (a:key == 1) ? [1, 2] : [2, 1]
	let [al, bl] = [a:line, t:DChar.dfl[bk][index(t:DChar.dfl[ak], a:line)]]
	" set a pair cursor position (line, colnum) and match id
	let t:DChar.dpv.ch.lc = [al, a:col]
	let t:DChar.dpv.ch.bk = bk
	" show a cursor-like highlight at the corresponding position
	let bc = t:DChar.hlc[bk][bl][a:col][1]
	if bc != [0, 0]
		let [pos, len] = [bc[0], bc[1] - bc[0] + 1]
		if !s:VF.WinIDinMatch | call s:WinGotoID(t:DChar.wid[bk]) | endif
		let t:DChar.dpv.ch.id = s:Matchaddpos(t:DChar.wid[bk], s:DCharHL.c,
														\[[bl, pos, len]], -1)
		if !s:VF.WinIDinMatch | call s:WinGotoID(t:DChar.wid[ak]) | endif
	else
		let t:DChar.dpv.ch.id = -1	" no cursor hl on empty line
	endif
	call execute('augroup diffchar2')
	call execute('autocmd!')
	call execute('autocmd WinLeave <buffer=' . t:DChar.bnr[ak] .
									\'> call s:ClearDiffCharPair(' . ak . ')')
	call execute('augroup END')
	if t:DChar.dpv.pv < 2 | return | endif
	" show the corresponding unit in echo or popup-window
	let at = getbufline(t:DChar.bnr[ak], al)[0]
	let bt = getbufline(t:DChar.bnr[bk], bl)[0]
	let [ae, ac] = t:DChar.hlc[ak][al][a:col]
	if ae == 'c'
		let hl = t:DChar.hgp[(count(map(t:DChar.hlc[ak][al][: a:col],
								\'v:val[0]'), 'c') - 1) % len(t:DChar.hgp)]
		let [tb, tx, te] = ['', bt[bc[0] - 1 : bc[1] - 1], '']
	elseif ae == 'd'
		let hl = s:DCharHL.A
		let [tb, tx, te] = [(1 < bc[0]) ? '<' : '',
					\bt[bc[0] - 1 : bc[1] - 1], (bc[1] < len(bt)) ? '>' : '']
	elseif ae == 'a'
		let hl = s:DCharHL.D
		let [tb, tx, te] = [(1 < ac[0]) ? '>' : '',
					\repeat((t:DChar.dpv.pv == 2 && s:VF.StrikeAttr) ? ' ' :
			\(&fillchars =~ 'diff') ? matchstr(&fillchars, 'diff:\zs.') : '-',
										\strwidth(at[ac[0] - 1 : ac[1] - 1])),
												\(ac[1] < len(at)) ? '<' : '']
	endif
	if t:DChar.dpv.pv == 2
		call execute(['echon tb', 'echohl ' . hl, 'echon tx', 'echohl None',
															\'echon te'], '')
	elseif t:DChar.dpv.pv == 3 || t:DChar.dpv.pv == 4
		if s:VF.PopupWindow
			call popup_move(t:DChar.dpv.pw, (t:DChar.dpv.pv == 3) ?
									\{'line': 'cursor+1', 'col': 'cursor'} :
											\{'line': getmousepos().screenrow,
											\'col': getmousepos().screencol})
			call popup_settext(t:DChar.dpv.pw, tb . tx . te)
			call popup_show(t:DChar.dpv.pw)
		elseif s:VF.FloatingWindow
			call nvim_win_set_config(t:DChar.dpv.pw.fw, {'relative': 'cursor',
				\'row': 1, 'col': 0, 'width': strdisplaywidth(tb . tx . te)})
			call setbufline(t:DChar.dpv.pw.fb, 1, tb . tx . te)
			call setwinvar(t:DChar.dpv.pw.fw, '&winblend', 0)
		endif
	endif
endfunction

function! s:ClearDiffCharPair(key) abort
	if !empty(t:DChar.dpv.ch)
		let [bk, id] = [t:DChar.dpv.ch.bk, t:DChar.dpv.ch.id]
		if id != -1
			if !s:VF.WinIDinMatch | call s:WinGotoID(t:DChar.wid[bk]) | endif
			silent! call s:Matchdelete(t:DChar.wid[bk], id)
			if !s:VF.WinIDinMatch
				call s:WinGotoID(t:DChar.wid[a:key])
			endif
		endif
		call execute('augroup diffchar2')
		call execute('autocmd!')
		call execute('augroup END')
		call execute('augroup! diffchar2')
		let t:DChar.dpv.ch = {}
	endif
	if t:DChar.dpv.pv == 2 | call execute('echo', '')
	elseif t:DChar.dpv.pv == 3 || t:DChar.dpv.pv == 4
		if s:VF.PopupWindow | call popup_hide(t:DChar.dpv.pw)
		elseif s:VF.FloatingWindow
			call nvim_win_set_config(t:DChar.dpv.pw.fw,
						\{'relative': 'win', 'row': 0, 'col': 0, 'width': 1})
			call setbufline(t:DChar.dpv.pw.fb, 1, '')
			call setwinvar(t:DChar.dpv.pw.fw, '&winblend', 100)
		endif
	endif
endfunction

function! s:ToggleDiffCharPair(on) abort
	if t:DChar.dpv.pv == 3 || t:DChar.dpv.pv == 4
		if s:VF.PopupWindow
			let t:DChar.dpv.pw = a:on ?
				\popup_create('', {'hidden': 1, 'scrollbar': 0, 'wrap': 0,
												\'highlight': s:DCharHL.c}) :
				\popup_close(t:DChar.dpv.pw)
		elseif s:VF.FloatingWindow
			if a:on
				let t:DChar.dpv.pw.fb = nvim_create_buf(0, 1)
				let t:DChar.dpv.pw.fw = nvim_open_win(t:DChar.dpv.pw.fb, 0,
						\{'relative': 'win', 'row': 0, 'col': 0, 'height': 1,
							\'width': 1, 'focusable': 0, 'style': 'minimal'})
				call setbufline(t:DChar.dpv.pw.fb, 1, '')
				call setwinvar(t:DChar.dpv.pw.fw, '&winblend', 100)
				call setwinvar(t:DChar.dpv.pw.fw, '&winhighlight',
													\'Normal:' . s:DCharHL.c)
			else
				call nvim_win_close(t:DChar.dpv.pw.fw, 1)
				let t:DChar.dpv.pw = {'fb': -1, 'fw': -1}
			endif
		endif
	endif
endfunction

function! diffchar#CopyDiffCharPair(dir) abort
	" a:dir : 0 = get, 1 = put
	if !exists('t:DChar') | return | endif
	for ak in [1, 2, 0]
		if ak == 0 | return | endif
		if t:DChar.wid[ak] == win_getid() | break | endif
	endfor
	let bk = (ak == 1) ? 2 : 1
	let un = -1
	if 0 < t:DChar.dpv.pv
		if !empty(t:DChar.dpv.ch) | let [al, un] = t:DChar.dpv.ch.lc | endif
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
	let bl = t:DChar.dfl[bk][index(t:DChar.dfl[ak], al)]
	let [ae, ac] = t:DChar.hlc[ak][al][un]
	let [be, bc] = t:DChar.hlc[bk][bl][un]
	let at = getbufline(t:DChar.bnr[ak], al)[0]
	let bt = getbufline(t:DChar.bnr[bk], bl)[0]
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
		call s:WinGotoID(t:DChar.wid[bk])
		call s:WinExecute('noautocmd call setline(bl, ss)')
		call s:WinExecute('call s:RedrawDiffChar(bk, 1)')
		call s:WinGotoID(t:DChar.wid[ak])
	else			" get
		call setline(al, ss)
	endif
endfunction

function! diffchar#EchoDiffChar(lines, short) abort
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
			let gt += [[s:DCharHL.n, printf('%'. nw . 'd ',
							\(&relativenumber ? abs(al - line('.')) : al))]]
		endif
		let at = getbufline(t:DChar.bnr[ak], al)[0]
		if !has_key(t:DChar.hlc[ak], al)
			if a:short | continue | endif
			let gt += [['', empty(at) ? "\n" : at]]
		else
			let bl = t:DChar.dfl[bk][index(t:DChar.dfl[ak], al)]
			let bt = getbufline(t:DChar.bnr[bk], bl)[0]
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
				let gt += [[g, t]]
				let ix += len(h)
			endfor
		endif
		let ec += ['echo ""']
		for [g, t] in gt
			let ec += ['echohl ' . g, 'echon "' . escape(t, '"') . '"']
		endfor
		let ec += ['echohl None']
	endfor
	call execute(ec, '')
endfunction

function! diffchar#DiffCharExpr() abort
	let [f1, f2] = [readfile(v:fname_in), readfile(v:fname_new)]
	call writefile(([f1, f2] == [['line1'], ['line2']]) ? ['1c1'] :
						\(s:VF.DiffExecutable && len(f1) + len(f2) > 100) ?
									\s:ExtDiffExpr(v:fname_in, v:fname_new) :
										\s:IntDiffExpr(f1, f2), v:fname_out)
endfunction

function! s:IntDiffExpr(f1, f2) abort
	let [f1, f2] = [a:f1, a:f2]
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

function! s:ExtDiffExpr(f1, f2) abort
	let opt = '-a --binary '
	let do = split(&diffopt, ',')
	if index(do, 'icase') != -1 | let opt .= '-i ' | endif
	if index(do, 'iwhiteall') != -1 | let opt .= '-w '
	elseif index(do, 'iwhite') != -1 | let opt .= '-b '
	elseif index(do, 'iwhiteeol') != -1 | let opt .= '-Z '
	endif
	let save_stmp = &shelltemp
	let &shelltemp = 0
	let dout = systemlist('diff ' . opt . a:f1 . ' ' . a:f2)
	let &shelltemp = save_stmp
	return filter(dout, 'v:val[0] =~ "\\d"')
endfunction

if s:VF.DiffOptionSet
	function! diffchar#ToggleDiffModeSync(event) abort
		" a:event : 0 = OptionSet diff, 1 = VimEnter
		if get(g:, 'DiffModeSync', 1) &&
									\(a:event || v:option_old != v:option_new)
			call s:SwitchDiffChar(a:event || v:option_new)
		endif
	endfunction
else
	function! diffchar#SetDiffModeSync() abort
		" DiffModeSync is triggered ON by FilterWritePost
		if !get(g:, 'DiffModeSync', 1) | return | endif
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
			call execute('autocmd! diffchar ShellFilterPost *
												\ call s:ClearDiffModeSync()')
			" prepare to complete sync just in case for accidents
			let s:id = timer_start(0, function('s:CompleteDiffModeSync'))
		endif
		" check if all the FilterWritePost has come
		if empty(filter(s:dmbuf, 'v:val != bufnr("%")'))
			call s:CompleteDiffModeSync(0)
		endif
	endfunction

	function! s:CompleteDiffModeSync(id) abort
		if exists('s:id')
			if a:id == 0 | call timer_stop(s:id) | endif
			unlet s:id
		else
			if exists('s:save_ch') && !empty(s:save_ch)
				call execute('autocmd! diffchar CursorHold * call ' .
																\s:save_ch)
				call s:ChangeUTOpt(1)
			else
				call execute('autocmd! diffchar CursorHold *')
				call s:ChangeUTOpt(0)
			endif
			silent call feedkeys("g\<Esc>", 'n')
		endif
		call s:ClearDiffModeSync()
		call timer_start(0, function('s:SwitchDiffChar'))
	endfunction

	function! s:ClearDiffModeSync() abort
		unlet s:dmbuf
		call execute('autocmd! diffchar ShellFilterPost *')
	endfunction

	function! s:ResetDiffModeSync() abort
		" DiffModeSync is triggered OFF by CursorHold
		if exists('t:DChar') && t:DChar.dsy &&
			\!empty(filter(values(t:DChar.wid), '!getwinvar(v:val, "&diff")'))
			" if either or both of DChar win is now non-diff mode,
			" reset it and show with current diff mode wins
			call s:SwitchDiffChar(0)
		endif
	endfunction
endif

function! s:SwitchDiffChar(on) abort
	let cwid = win_getid()
	let aw = cwid
	if exists('t:DChar') &&
				\(a:on && index(values(t:DChar.bnr), winbufnr(cwid)) == -1 ||
							\!a:on && index(values(t:DChar.wid), cwid) != -1)
		" diff mode ON on non-DChar buf || OFF on DChar win, try reset
		for k in [1, 2]
			if getwinvar(t:DChar.wid[k], '&diff')
				let aw = t:DChar.wid[k]
				call s:WinGotoID(aw)
				call s:WinExecute('call diffchar#ResetDiffChar(1)')
				call s:WinGotoID(cwid)
				break
			endif
		endfor
	endif
	if !exists('t:DChar') && get(g:, 'DiffModeSync', 1)
		let aw = win_id2win(aw)
		let dw = filter(map(range(aw, winnr('$')) + range(1, aw - 1),
							\'win_getid(v:val)'), 'getwinvar(v:val, "&diff")')
		if 1 < len(dw)
			" 2 or more diff mode wins exists, try show
			call s:WinGotoID(dw[0])
			call s:WinExecute('call diffchar#ShowDiffChar()')
			call s:WinGotoID(cwid)
		endif
	endif
endfunction

function! s:WinLeaveDiffChar(key, ...) abort
	" just in case when a splitted DChar win is closed, BufWinLeave not happen
	if !exists('t:DChar') | return | endif
	if a:0 == 0
		if len(filter(gettabinfo(tabpagenr())[0].windows,
							\'getwinvar(v:val, "&diff") &&
								\winbufnr(v:val) == t:DChar.bnr[a:key]')) > 1
			" WinLeave always happens too early, do it later
			call timer_start(0, function('s:WinLeaveDiffChar', [a:key]))
		endif
	else
		if index(gettabinfo(tabpagenr())[0].windows, t:DChar.wid[a:key]) == -1
			let cwid = win_getid()
			let aw = t:DChar.wid[(a:key == 1) ? 2 : 1]
			call s:WinGotoID(aw)
			call s:WinExecute('call diffchar#ResetDiffChar(1)')
			if get(g:, 'DiffModeSync', 1)
				let aw = win_id2win(aw)
				let dw = filter(map(range(aw, winnr('$')) + range(1, aw - 1),
							\'win_getid(v:val)'), 'getwinvar(v:val, "&diff")')
				if 1 < len(dw)
					call s:WinGotoID(dw[0])
					call s:WinExecute('call diffchar#ShowDiffChar()')
				endif
			endif
			call s:WinGotoID(cwid)
		endif
	endif
endfunction

function! s:BufWinLeaveDiffChar(wid) abort
	" BufWinLeave possibly happens in another tabpage (eg: tabonly)
	let dc = s:Gettabvar(win_id2tabwin(a:wid)[0], 'DChar')
	if !empty(dc)
		let cwid = win_getid()
		if s:VF.WinExecute && !s:VF.WinExecFixed &&
							\win_id2tabwin(a:wid)[0] != win_id2tabwin(cwid)[0]
			let s:VF.WinExecute = 0
			let dc = {}
		endif
		call s:WinGotoID(a:wid)
		call s:WinExecute('call diffchar#ResetDiffChar(1)')
		call s:WinGotoID(cwid)
		if empty(dc) | let s:VF.WinExecute = 1 | endif
	endif
	call s:AdjustGlobalOption()
endfunction

function! s:ChecksumStr(str) abort
	return eval('0x' . sha256(a:str)[-4 :])
endfunction

function! s:EchoWarning(msg) abort
	call execute(['echohl WarningMsg', 'echo a:msg', 'echohl None'], '')
endfunction

if s:VF.GettabvarFixed
	let s:Gettabvar = function('gettabvar')
else
	function! s:Gettabvar(tp, var) abort
		call gettabvar(a:tp, a:var)			" call twice as a workaround
		return gettabvar(a:tp, a:var)
	endfunction
endif

if s:VF.ChangenrFixed
	let s:Changenr = function('changenr')
else
	function! s:Changenr() abort
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

if s:VF.WinExecute
	function! s:WinGotoID(wid) abort
		let s:WinExecute = function('win_execute', [a:wid])
	endfunction
else
	function! s:WinGotoID(wid) abort
		noautocmd call win_gotoid(a:wid)
	endfunction
	let s:WinExecute = function('execute')
endif

if s:VF.WinIDinMatch
	function! s:Matchaddpos(wid, grp, pos, pri) abort
		return matchaddpos(a:grp, a:pos, a:pri, -1, {'window': a:wid})
	endfunction

	function! s:Matchdelete(wid, id) abort
		return matchdelete(a:id, a:wid)
	endfunction

	function! s:Getmatches(wid) abort
		return getmatches(a:wid)
	endfunction
else
	function! s:Matchaddpos(wid, grp, pos, pri) abort
		return matchaddpos(a:grp, a:pos, a:pri)
	endfunction

	function! s:Matchdelete(wid, id) abort
		return matchdelete(a:id)
	endfunction

	function! s:Getmatches(wid) abort
		return getmatches()
	endfunction
endif

function! s:AdjustGlobalOption() abort
	if !s:VF.DiffUpdated && !s:VF.DiffOptionSet
		call s:ChangeUTOpt(exists('t:DChar') && t:DChar.dsy)
	endif
	call s:ToggleDiffHL(exists('t:DChar'))
endfunction

if !s:VF.DiffUpdated
	if s:VF.DiffOptionSet
		function! s:FollowDiffOption() abort
			if v:option_old != v:option_new
				let cwid = win_getid()
				for dc in filter(map(range(1, tabpagenr('$')),
							\'s:Gettabvar(v:val, "DChar")'), '!empty(v:val)')
					call s:WinGotoID(dc.wid[1])
					call s:WinExecute('call s:RedrawDiffChar(1, 0)')
				endfor
				call s:WinGotoID(cwid)
			endif
		endfunction
	else
		function! s:ChangeUTOpt(on) abort
			if a:on && !exists('s:save_ut')
				let s:save_ut = &updatetime
				let &updatetime = 500
			elseif !a:on && exists('s:save_ut')
				let &updatetime = s:save_ut
				unlet s:save_ut
			endif
		endfunction
	endif
endif

function! s:ToggleDiffHL(on) abort
	for [hl, at] in items(s:DiffHL)
		call execute('highlight clear ' . hl)
		" at : 0 = original, 1 = for single color, 2 = for multi color
		call execute('highlight ' . hl . ' ' .
			\join(map(items(at[!a:on ? 0 : (len(t:DChar.hgp) == 1) ? 1 : 2]),
											\'v:val[0] . "=" . v:val[1]')))
	endfor
endfunction

function! s:CheckDiffHLID() abort
	" in nvim 2.1, diff_hlID() returns FoldColumn/DiffAdd/DiffDelete,
	" which is (hlID() - 1), for DiffAdd/DiffChange/DiffText
	let ok = -1
	let cwid = win_getid()
	let w = 1
	while w <= winnr('$') && ok == -1
		if getwinvar(w, '&diff')
			noautocmd call win_gotoid(win_getid(w))
			let l = 1
			while l <= line('$') && ok == -1
				let f = foldclosedend(l)
				if f != -1 | let l = f
				else
					let c = 1
					while c <= col([l, '$']) - 1 && ok == -1
						let i = diff_hlID(l, c)
						if i == 0 | break
						elseif i == s:DiffHL.DiffChange.id ||
									\i == s:DiffHL.DiffText.id | let ok = 1
						elseif i != s:DiffHL.DiffAdd.id | let ok = 0
						endif
						let c += 1
					endwhile
				endif
				let l += 1
			endwhile
		endif
		let w += 1
	endwhile
	noautocmd call win_gotoid(cwid)
	return (ok == 0) ? 0 : 1
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=4 sw=4
