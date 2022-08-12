
" ============================================================
if !exists('g:ZFVimIM_autoAddWordLen')
    let g:ZFVimIM_autoAddWordLen=3*4
endif
" function(userWord)
" userWord: see ZFVimIM_complete
" return: 1 if need add word
if !exists('g:ZFVimIM_autoAddWordChecker')
    let g:ZFVimIM_autoAddWordChecker=[]
endif

if !exists('g:ZFVimIM_symbolMap')
    let g:ZFVimIM_symbolMap = {}
endif

" ============================================================
augroup ZFVimIME_augroup
    autocmd!

    autocmd User ZFVimIM_event_OnDbInit silent

    autocmd User ZFVimIM_event_OnStart silent

    autocmd User ZFVimIM_event_OnStop silent

    autocmd User ZFVimIM_event_OnEnable silent

    autocmd User ZFVimIM_event_OnDisable silent

    " added word can be checked by g:ZFVimIM_event_OnAddWord : {
    "   'dbId' : 'add to which db',
    "   'key' : 'matched full key',
    "   'word' : 'matched word',
    " }
    autocmd User ZFVimIM_event_OnAddWord silent

    " current db can be accessed by g:ZFVimIM_db[g:ZFVimIM_dbIndex]
    autocmd User ZFVimIM_event_OnDbChange silent

    " called when update by ZFVimIME_keymap_update_i, typically by async update callback
    autocmd User ZFVimIM_event_OnUpdate silent

    " called when omni popup update, you may obtain current state by ZFVimIME_state()
    autocmd User ZFVimIM_event_OnUpdateOmni silent

    " called when choosed omni popup item, use `g:ZFVimIM_choosedWord` to obtain choosed word
    autocmd User ZFVimIM_event_OnCompleteDone silent
augroup END

function! ZFVimIME_init()
    if !exists('s:dbInitFlag')
        let s:dbInitFlag = 1
        doautocmd User ZFVimIM_event_OnDbInit
        doautocmd User ZFVimIM_event_OnDbChange
    endif
endfunction

" ============================================================
if get(g:, 'ZFVimIM_keymap', 1)
    nnoremap <expr><silent> ;; ZFVimIME_keymap_toggle_n()
    inoremap <expr><silent> ;; ZFVimIME_keymap_toggle_i()
    vnoremap <expr><silent> ;; ZFVimIME_keymap_toggle_v()

    nnoremap <expr><silent> ;: ZFVimIME_keymap_next_n()
    inoremap <expr><silent> ;: ZFVimIME_keymap_next_i()
    vnoremap <expr><silent> ;: ZFVimIME_keymap_next_v()

    nnoremap <expr><silent> ;, ZFVimIME_keymap_add_n()
    inoremap <expr><silent> ;, ZFVimIME_keymap_add_i()
    xnoremap <expr><silent> ;, ZFVimIME_keymap_add_v()

    nnoremap <expr><silent> ;. ZFVimIME_keymap_remove_n()
    inoremap <expr><silent> ;. ZFVimIME_keymap_remove_i()
    xnoremap <expr><silent> ;. ZFVimIME_keymap_remove_v()
endif

function! ZFVimIME_keymap_toggle_n()
    call ZFVimIME_toggle()
    call ZFVimIME_redraw()
    return ''
endfunction
function! ZFVimIME_keymap_toggle_i()
    call ZFVimIME_toggle()
    call ZFVimIME_redraw()
    return ''
endfunction
function! ZFVimIME_keymap_toggle_v()
    call ZFVimIME_toggle()
    call ZFVimIME_redraw()
    return ''
endfunction

function! ZFVimIME_keymap_next_n()
    call ZFVimIME_next()
    call ZFVimIME_redraw()
    return ''
endfunction
function! ZFVimIME_keymap_next_i()
    call ZFVimIME_next()
    call ZFVimIME_redraw()
    return ''
endfunction
function! ZFVimIME_keymap_next_v()
    call ZFVimIME_next()
    call ZFVimIME_redraw()
    return ''
endfunction

function! ZFVimIME_keymap_add_n()
    if !ZFVimIME_started()
        call ZFVimIME_start()
    endif
    call feedkeys(":IMAdd\<space>\<c-c>q:kA", 'nt')
    return ''
endfunction
function! ZFVimIME_keymap_add_i()
    if !ZFVimIME_started()
        call ZFVimIME_start()
    endif
    call feedkeys("\<esc>:IMAdd\<space>\<c-c>q:kA", 'nt')
    return ''
endfunction
function! ZFVimIME_keymap_add_v()
    if !ZFVimIME_started()
        call ZFVimIME_start()
    endif
    call feedkeys("\"ty:IMAdd\<space>\<c-r>t\<space>\<c-c>q:kA", 'nt')
    return ''
endfunction

function! ZFVimIME_keymap_remove_n()
    if !ZFVimIME_started()
        call ZFVimIME_start()
    endif
    call feedkeys(":IMRemove\<space>\<c-c>q:kA", 'nt')
    return ''
endfunction
function! ZFVimIME_keymap_remove_i()
    if !ZFVimIME_started()
        call ZFVimIME_start()
    endif
    call feedkeys("\<esc>:IMRemove\<space>\<c-c>q:kA", 'nt')
    return ''
endfunction
function! ZFVimIME_keymap_remove_v()
    if !ZFVimIME_started()
        call ZFVimIME_start()
    endif
    call feedkeys("\"tx:IMRemove\<space>\<c-r>t\<cr>", 'nt')
    return ''
endfunction

if exists('*state')
    function! s:updateChecker()
        return !ZFVimIME_started() || mode() != 'i' || match(state(), 'm') >= 0
    endfunction
else
    function! s:updateChecker()
        return !ZFVimIME_started() || mode() != 'i'
    endfunction
endif
function! ZFVimIME_keymap_update_i()
    if s:updateChecker()
        return ''
    endif
    if pumvisible()
        call feedkeys("\<c-e>", 'nt')
    endif
    call s:resetAfterInsert()
    call feedkeys("\<c-r>=ZFVimIME_callOmni()\<cr>", 'nt')
    doautocmd User ZFVimIM_event_OnUpdate
    return ''
endfunction

if get(g:, 'ZFVimIME_fixCtrlC', 1)
    " <c-c> won't fire InsertLeave, we needs this to reset userWord detection
    inoremap <c-c> <esc>
endif

if !exists('*ZFVimIME_redraw')
    function! ZFVimIME_redraw()
        " redraw to ensure `b:keymap_name` updated
        " but redraw! would cause entire screen forced update
        " typically b:keymap_name used only in statusline, update it instead of redraw!
        if 0
            redraw!
        else
            if 0
                        \ || match(&statusline, '%k') >= 0
                        \ || match(&statusline, 'ZFVimIME_IMEStatusline') >= 0
                let &statusline = &statusline
            endif
            if 0
                        \ || match(&l:statusline, '%k') >= 0
                        \ || match(&l:statusline, 'ZFVimIME_IMEStatusline') >= 0
                let &l:statusline = &l:statusline
            endif
        endif
    endfunction
endif

function! ZFVimIME_started()
    return s:started
endfunction

function! ZFVimIME_enabled()
    return s:enabled
endfunction

function! ZFVimIME_toggle()
    if ZFVimIME_started()
        call ZFVimIME_stop()
    else
        call ZFVimIME_start()
    endif
endfunction

function! ZFVimIME_start()
    if s:started
        return
    endif
    let s:started = 1
    doautocmd User ZFVimIM_event_OnStart
    call s:IME_enableStateUpdate()
endfunction

function! ZFVimIME_stop()
    if !s:started
        return
    endif
    let s:started = 0
    call s:IME_enableStateUpdate()
    doautocmd User ZFVimIM_event_OnStop
endfunction

function! ZFVimIME_next()
    if !ZFVimIME_started()
        return ZFVimIME_start()
    endif
    call ZFVimIME_switchToIndex(g:ZFVimIM_dbIndex + 1)
endfunction

function! ZFVimIME_switchToIndex(dbIndex)
    if empty(g:ZFVimIM_db)
        let g:ZFVimIM_dbIndex = 0
        return
    endif
    let len = len(g:ZFVimIM_db)
    let dbIndex = (a:dbIndex % len)

    if !g:ZFVimIM_db[dbIndex]['switchable']
        " loop until found a switchable
        let dbIndexStart = dbIndex
        let dbIndex = ((dbIndex + 1) % len)
        while dbIndex != dbIndexStart && !g:ZFVimIM_db[dbIndex]['switchable']
            let dbIndex = ((dbIndex + 1) % len)
        endwhile
    endif

    if dbIndex == g:ZFVimIM_dbIndex || !g:ZFVimIM_db[dbIndex]['switchable']
        return
    endif
    let g:ZFVimIM_dbIndex = dbIndex
    let b:keymap_name = ZFVimIME_IMEName()
    doautocmd User ZFVimIM_event_OnDbChange
endfunction

function! ZFVimIME_state()
    return {
                \   'key' : s:keyboard,
                \   'list' : s:match_list,
                \   'page' : s:page,
                \   'startColumn' : s:start_column,
                \   'seamlessPos' : s:seamless_positions,
                \   'userWord' : s:userWord,
                \ }
endfunction

function! ZFVimIME_omnifunc(start, keyboard)
    return s:omnifunc(a:start, a:keyboard)
endfunction


" ============================================================
function! ZFVimIME_esc(...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, '<esc>'))
        return ''
    endif
    let range = col('.') - s:start_column
    let key = "\<c-e>" . repeat("\<bs>", range)
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction

function! ZFVimIME_label(n, ...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, a:n))
        return ''
    endif
    let curPage = s:curPage()
    let n = a:n < 1 ? 9 : a:n - 1
    if n >= len(curPage)
        return ''
    endif
    let key = repeat("\<down>", n) . "\<c-y>\<c-r>=ZFVimIME_callOmni()\<cr>"

    let s:confirmFlag = 1
    if !s:completeItemAvailable
        call s:didChoose(curPage[n])
    endif
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction

function! ZFVimIME_pageUp(key, ...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, a:key))
        return ''
    endif
    let key = "\<c-e>\<c-r>=ZFVimIME_callOmni()\<cr>"
    let s:pageup_pagedown = -1
    call feedkeys(key, 'nt')
    return ''
endfunction
function! ZFVimIME_pageDown(key, ...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, a:key))
        return ''
    endif
    let key = "\<c-e>\<c-r>=ZFVimIME_callOmni()\<cr>"
    let s:pageup_pagedown = 1
    call feedkeys(key, 'nt')
    return ''
endfunction

" note, this func must invoked as `<c-r>=`
" to ensure `<c-y>` actually transformed popup word
function! ZFVimIME_choose_fix(offset)
    let words = split(strpart(getline('.'), (s:start_column - 1), col('.') - s:start_column), '\ze')
    return repeat("\<bs>", len(words) - a:offset)
endfunction
function! ZFVimIME_chooseL(key, ...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, a:key))
        return ''
    endif
    let key = "\<c-y>\<c-r>=ZFVimIME_choose_fix(1)\<cr>"
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction
function! ZFVimIME_chooseR(key, ...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, a:key))
        return ''
    endif
    let key = "\<c-y>\<left>\<c-r>=ZFVimIME_choose_fix(0)\<cr>\<right>"
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction

function! ZFVimIME_space(...)
    if mode() != 'i' || !pumvisible()
        call s:symbolForward(get(a:, 1, '<space>'))
        return ''
    endif
    let s:confirmFlag = 1
    let key = "\<c-y>\<c-r>=ZFVimIME_callOmni()\<cr>"
    if !s:completeItemAvailable
        " treat as selected first item
        " would break if use <down> and <space> to choose
        " but there seems no other way to detect the choosed index
        call s:didChoose(s:match_list[s:page * &pumheight])
    endif
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction

function! ZFVimIME_enter(...)
    if mode() != 'i'
        call s:symbolForward(get(a:, 1, '<cr>'))
        return ''
    endif
    if pumvisible()
        let key = "\<c-e>"
    else
        if s:enter_to_confirm
            let s:enter_to_confirm = 0
            let key = ''
        else
            let key = "\<cr>"
        endif
    endif
    let s:seamless_positions = getpos('.')
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction

function! ZFVimIME_backspace(...)
    if mode() != 'i'
        call s:symbolForward(get(a:, 1, '<bs>'))
        return ''
    endif
    if pumvisible()
        let key = "\<c-e>\<bs>\<c-r>=ZFVimIME_callOmni()\<cr>"
    else
        let key = "\<bs>"
    endif
    if !empty(s:seamless_positions)
        let line = getline('.')
        if !empty(line)
            let bsLen = len(substitute(line, '^.*\(.\)$', '\1', ''))
        else
            let bsLen = 1
        endif
        let pos = getpos('.')[2]
        if pos > bsLen
            let pos -= bsLen
        endif
        if pos < s:seamless_positions[2]
            let s:seamless_positions[2] = pos
        endif
    endif
    call s:resetAfterInsert()
    call feedkeys(key, 'nt')
    return ''
endfunction

function! ZFVimIME_input(key, ...)
    if mode() != 'i'
        call s:symbolForward(get(a:, 1, a:key))
        return ''
    endif
    return a:key . "\<c-r>=ZFVimIME_callOmni()\<cr>"
endfunction

let s:symbolState = {}
function! s:symbol(key)
    if mode() != 'i'
        return a:key
    endif
    let T_symbol = get(g:ZFVimIM_symbolMap, a:key, [])
    if type(T_symbol) == type(function('type'))
        return T_symbol(a:key)
    elseif empty(T_symbol)
        return a:key
    elseif len(T_symbol) == 1
        if T_symbol[0] == ''
            return a:key
        else
            return T_symbol[0]
        endif
    endif
    let s:symbolState[a:key] = (get(s:symbolState, a:key, -1) + 1) % len(T_symbol)
    return T_symbol[s:symbolState[a:key]]
endfunction

function! s:symbolForward(key)
    let key = s:symbol(a:key)
    " (<[a-z]+>)
    execute 'call feedkeys("' . substitute(key, '\(<[a-z]\+>\)', '\\\1', 'g') . '", "nt")'
endfunction

function! ZFVimIME_symbol(key, ...)
    call s:symbolForward(get(a:, 1, a:key))
    return ''
endfunction

function! ZFVimIME_callOmni()
    let s:keyboard = (s:pageup_pagedown == 0) ? '' : s:keyboard
    let key = s:hasLeftChar() ? "\<c-x>\<c-o>\<c-r>=ZFVimIME_fixOmni()\<cr>" : ''
    execute 'return "' . key . '"'
endfunction

function! ZFVimIME_fixOmni()
    let key = pumvisible() ? "\<c-p>\<down>" : ''
    execute 'return "' . key . '"'
endfunction

augroup ZFVimIME_impl_toggle_augroup
    autocmd!
    autocmd User ZFVimIM_event_OnStart call s:IMEEventStart()
    autocmd User ZFVimIM_event_OnStop call s:IMEEventStop()
augroup END
function! s:IMEEventStart()
    augroup ZFVimIME_impl_augroup
        autocmd!
        autocmd InsertEnter * call s:OnInsertEnter()
        autocmd InsertLeave * call s:OnInsertLeave()
        autocmd CursorMovedI * call s:OnCursorMovedI()
        if exists('##CompleteDone')
            autocmd CompleteDone * call s:OnCompleteDone()
        endif
    augroup END
endfunction
function! s:IMEEventStop()
    augroup ZFVimIME_impl_augroup
        autocmd!
    augroup END
endfunction

function! s:init()
    let s:started = 0
    let s:enabled = 0
    let s:seamless_positions = []
    let s:start_column = 1
    let s:all_keys = '^[0-9a-z]$'
    let s:input_keys = '^[a-z]$'
endfunction

function! ZFVimIME_IMEName()
    if ZFVimIME_started() && g:ZFVimIM_dbIndex < len(g:ZFVimIM_db)
        return g:ZFVimIM_db[g:ZFVimIM_dbIndex]['name']
    else
        return ''
    endif
endfunction

function! ZFVimIME_IMEStatusline()
    let name = ZFVimIME_IMEName()
    if empty(name)
        return ''
    else
        return get(g:, 'ZFVimIME_IMEStatus_tagL', ' <') . name . get(g:, 'ZFVimIME_IMEStatus_tagR', '> ')
    endif
endfunction

function! s:fixIMState()
    if mode() == 'i'
        " :h i_CTRL-^
        call feedkeys(nr2char(30), 'nt')
        if &iminsert != ZFVimIME_started()
            call feedkeys(nr2char(30), 'nt')
        endif
    endif
endfunction

function! s:IME_start()
    let &iminsert = 1
    let cloudInitMode = get(g:, 'ZFVimIM_cloudInitMode', '')
    let g:ZFVimIM_cloudInitMode = 'preferSync'
    call ZFVimIME_init()
    let g:ZFVimIM_cloudInitMode = cloudInitMode

    call s:vimrcSave()
    call s:vimrcSetup()
    call s:setupKeymap()
    let b:keymap_name = ZFVimIME_IMEName()

    let s:seamless_positions = getpos('.')
    call s:fixIMState()

    let s:enabled = 1
    let b:ZFVimIME_enabled = 1
    doautocmd User ZFVimIM_event_OnEnable
endfunction

function! s:IME_stop()
    let &iminsert = 0
    lmapclear
    call s:vimrcRestore()
    call s:resetState()
    call s:fixIMState()

    let s:enabled = 0
    if exists('b:ZFVimIME_enabled')
        unlet b:ZFVimIME_enabled
    endif
    doautocmd User ZFVimIM_event_OnDisable
endfunction

function! s:IME_enableStateUpdate(...)
    if get(g:, 'ZFVimIME_enableOnInsertOnly', 1)
        let desired = get(a:, 1, -1)
        if desired == 0
            let enabled = 0
        elseif desired == 1
            let enabled = s:started
        else
            let enabled = (s:started && match(mode(), 'i') >= 0)
        endif
    else
        let enabled = s:started
    endif
    if enabled != s:enabled
        if enabled
            call s:IME_start()
        else
            call s:IME_stop()
        endif
    endif
endfunction

augroup ZFVimIME_impl_enabledStateUpdate_augroup
    autocmd!
    autocmd InsertEnter * call s:IME_enableStateUpdate(1)
    autocmd InsertLeave * call s:IME_enableStateUpdate(0)
augroup END

function! s:IME_syncBuffer_delay(...)
    if !get(g:, 'ZFVimIME_syncBuffer', 1)
        return
    endif
    if get(b:, 'ZFVimIME_enabled', 0) != s:enabled
                \ || &iminsert != s:enabled
        if s:enabled
            call s:IME_stop()
            call s:IME_start()
        else
            call s:IME_start()
            call s:IME_stop()
        endif
    endif
    let b:keymap_name = ZFVimIME_IMEName()
    call ZFVimIME_redraw()
endfunction
function! s:IME_syncBuffer(...)
    if !get(g:, 'ZFVimIME_syncBuffer', 1)
        return
    endif
    if get(b:, 'ZFVimIME_enabled', 0) != s:enabled
                \ || &iminsert != s:enabled
        if has('timers')
            call timer_start(get(a:, 1, 0), function('s:IME_syncBuffer_delay'))
        else
            call s:IME_syncBuffer_delay()
        endif
    endif
endfunction
augroup ZFVimIME_impl_syncBuffer_augroup
    autocmd!
    " sometimes `iminsert` would be changed by vim, reason unknown
    " try to check later to ensure state valid
    if has('timers')
        if exists('##OptionSet')
            autocmd BufEnter,CmdwinEnter * call s:IME_syncBuffer()
            autocmd OptionSet iminsert call s:IME_syncBuffer()
        else
            autocmd BufEnter,CmdwinEnter * call s:IME_syncBuffer()
                        \| call s:IME_syncBuffer(200)
        endif
    else
        autocmd BufEnter,CmdwinEnter * call s:IME_syncBuffer()
    endif
augroup END

function! s:vimrcSave()
    let s:saved_omnifunc    = &omnifunc
    let s:saved_completeopt = &completeopt
    let s:saved_shortmess   = &shortmess
    let s:saved_pumheight   = &pumheight
endfunction

function! s:vimrcSetup()
    set omnifunc=ZFVimIME_omnifunc
    set completeopt=menuone
    try
        " some old vim does not have `c`
        silent! set shortmess+=c
    endtry
    set pumheight=10
endfunction

function! s:vimrcRestore()
    let &omnifunc    = s:saved_omnifunc
    let &completeopt = s:saved_completeopt
    let &shortmess   = s:saved_shortmess
    let &pumheight   = s:saved_pumheight
endfunction

function! s:setupKeymap()
    let mapped = {}

    for c in split('abcdefghijklmnopqrstuvwxyz', '\zs')
        let mapped[c] = 1
        execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_input("' . substitute(c, '"', '\\"', 'g') . '")'
    endfor

    for c in get(g:, 'ZFVimIM_key_pageUp', ['-'])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_pageUp("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor
    for c in get(g:, 'ZFVimIM_key_pageDown', ['='])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_pageDown("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor

    for c in get(g:, 'ZFVimIM_key_chooseL', ['['])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_chooseL("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor
    for c in get(g:, 'ZFVimIM_key_chooseR', [']'])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_chooseR("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor

    for n in range(10)
        let mapped['' . n] = 1
        execute 'lnoremap <buffer><expr> ' . n . ' ZFVimIME_label(' . n . ')'
    endfor

    for c in get(g:, 'ZFVimIM_key_backspace', ['<bs>'])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_backspace("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor

    for c in get(g:, 'ZFVimIM_key_esc', ['<esc>'])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_esc("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor

    for c in get(g:, 'ZFVimIM_key_enter', ['<cr>'])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_enter("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor

    for c in get(g:, 'ZFVimIM_key_space', ['<space>'])
        if c !~ s:all_keys
            let mapped[c] = 1
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_space("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor

    let candidates = get(g:, 'ZFVimIM_key_candidates', [])
    let iCandidate = 0
    while iCandidate < len(candidates)
        if type(candidates[iCandidate]) == type([])
            let cs = candidates[iCandidate]
        else
            let cs = [candidates[iCandidate]]
        endif
        for c in cs
            if c !~ s:all_keys
                let mapped[c] = 1
                execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_label(' . (iCandidate + 2) . ', "' . substitute(c, '"', '\\"', 'g') . '")'
            endif
        endfor
        let iCandidate += 1
    endwhile

    for c in keys(g:ZFVimIM_symbolMap)
        if !exists("mapped[c]")
            execute 'lnoremap <buffer><expr> ' . c . ' ZFVimIME_symbol("' . substitute(c, '"', '\\"', 'g') . '")'
        endif
    endfor
endfunction

function! s:resetState()
    call s:resetAfterInsert()
    let s:keyboard = ''
    let s:userWord = []
    let s:confirmFlag = 0
    let s:hasInput = 0
endfunction

function! s:resetAfterInsert()
    let s:match_list = []
    let s:page = 0
    let s:pageup_pagedown = 0
    let s:enter_to_confirm = 0
endfunction

function! s:curPage()
    if !empty(s:match_list) && &pumheight > 0
        if s:completeItemAvailable && get(g:, 'ZFVimIM_freeScroll', 0)
            execute 'let results = s:match_list[' . (s:page * &pumheight) . ':-1]'
            return results
        else
            execute 'let results = s:match_list[' . (s:page * &pumheight) . ':' . ((s:page+1) * &pumheight - 1) . ']'
            return results
        endif
    else
        return []
    endif
endfunction

function! s:getSeamless(cursor_positions)
    if empty(s:seamless_positions)
                \|| s:seamless_positions[0] != a:cursor_positions[0]
                \|| s:seamless_positions[1] != a:cursor_positions[1]
                \|| s:seamless_positions[3] != a:cursor_positions[3]
        return -1
    endif
    let current_line = getline(a:cursor_positions[1])
    let seamless_column = s:seamless_positions[2]
    let len = a:cursor_positions[2] - seamless_column
    let snip = strpart(current_line, seamless_column - 1, len)
    if len(snip) < 0
        let s:seamless_positions = []
        return -1
    endif
    for c in split(snip, '\zs')
        if c !~ s:input_keys
            return -1
        endif
    endfor
    return seamless_column
endfunction

function! s:hasLeftChar()
    let before = getline('.')[col('.')-2]
    if before =~ '\s' || empty(before)
        return 0
    elseif before =~# s:input_keys
        return 1
    endif
endfunction

function! s:omnifunc(start, keyboard)
    let s:enter_to_confirm = 1
    let s:hasInput = 1
    if a:start
        let cursor_positions = getpos('.')
        let start_column = cursor_positions[2]
        let current_line = getline(cursor_positions[1])
        let seamless_column = s:getSeamless(cursor_positions)
        if seamless_column <= 0
            let seamless_column = 1
        endif
        if start_column <= seamless_column
            return -3
        endif
        while start_column > seamless_column && current_line[(start_column-1) - 1] =~# s:input_keys
            let start_column -= 1
        endwhile
        let len = cursor_positions[2] - start_column
        if len <= 0
            return -3
        endif
        let keyboard = strpart(current_line, (start_column - 1), len)
        let s:keyboard = keyboard
        let s:start_column = start_column
        return start_column - 1
    else
        if s:pageup_pagedown != 0 && !empty(s:match_list) && &pumheight > 0
            let length = len(s:match_list)
            let pageCount = (length-1) / &pumheight + 1
            let s:page += s:pageup_pagedown
            if s:page >= pageCount
                let s:page = pageCount - 1
            endif
            if s:page < 0
                let s:page = 0
            endif
        else
            let s:match_list = ZFVimIM_complete(s:keyboard)
            let s:page = 0
        endif
        let ret = s:popupMenuList(s:curPage())
        doautocmd User ZFVimIM_event_OnUpdateOmni
        return ret
    endif
endfunction

function! s:popupMenuList(complete)
    if empty(a:complete) || type(a:complete) != type([])
        return []
    endif
    let label = 1
    let popup_list = []
    for item in a:complete
        " :h complete-items
        let complete_items = {}
        if get(g:, 'ZFVimIM_freeScroll', 0)
            let labelstring = printf('%2d', label == 10 ? 0 : label)
        else
            if label >= 1 && label <= 9
                let labelstring = label
            elseif label == 10
                let labelstring = '0'
            else
                let labelstring = '?'
            endif
        endif
        let left = strpart(s:keyboard, item['len'])
        let complete_items['abbr'] = labelstring . ' ' . item['word'] . ' ' . left
        let complete_items['menu'] = ''
        if get(g:, 'ZFVimIM_showKeyHint', 1)
            if item['type'] == 'sentence' && !empty(get(item, 'sentenceList'))
                let menu = ''
                for word in item['sentenceList']
                    if !empty(menu)
                        let menu .= ' '
                    endif
                    let menu .= word['key']
                endfor
                let complete_items['menu'] .= ' '
                let complete_items['menu'] .= menu
            else
                let complete_items['menu'] .= ' '
                let complete_items['menu'] .= item['key']
            endif
        endif

        let db = ZFVimIM_dbForId(item['dbId'])
        if type(get(db, 'menuLabel', 0)) == type(0)
            if get(g:, 'ZFVimIM_showCrossDbHint', 1)
                        \ && item['dbId'] != g:ZFVimIM_db[g:ZFVimIM_dbIndex]['dbId']
                let complete_items['menu'] .= '  <' . db['name'] . '>'
            endif
        else
            if type(db['menuLabel']) == type('')
                let complete_items['menu'] .= db['menuLabel']
            elseif ZFVimIM_funcCallable(db['menuLabel'])
                let complete_items['menu'] .= ZFVimIM_funcCallable(db['menuLabel'], [item])
            endif
        endif

        if get(g:, 'ZFVimIME_DEBUG', 0)
            let complete_items['menu'] .= printf('  (%s) <%s> %s', item['type'], db['name'], strpart(item['key'], 0, item['len']))
        endif

        let complete_items['dup'] = 1
        let complete_items['word'] = item['word'] . left
        if s:completeItemAvailable
            let complete_items['info'] = json_encode(item)
        endif
        call add(popup_list, complete_items)
        let label += 1
    endfor

    let &completeopt = 'menuone'
    let &pumheight = 10
    return popup_list
endfunction

function! s:OnInsertEnter()
    let s:seamless_positions = getpos('.')
    let s:enter_to_confirm = 0
endfunction
function! s:OnInsertLeave()
    call s:resetState()
endfunction
function! s:OnCursorMovedI()
    if s:hasInput
        let s:hasInput = 0
    else
        let s:seamless_positions = getpos('.')
        let s:enter_to_confirm = 0
    endif
endfunction


function! s:addWord(dbId, key, word)
    let dbIndex = ZFVimIM_dbIndexForId(a:dbId)
    if dbIndex < 0
        return
    endif
    call ZFVimIM_wordAdd(g:ZFVimIM_db[dbIndex], a:word, a:key)

    let g:ZFVimIM_event_OnAddWord = {
                \   'dbId' : a:dbId,
                \   'key' : a:key,
                \   'word' : a:word,
                \ }
    doautocmd User ZFVimIM_event_OnAddWord
endfunction

let s:completeItemAvailable = (exists('v:completed_item') && exists('*json_encode'))
let s:confirmFlag = 0
function! s:OnCompleteDone()
    if !s:confirmFlag
        return
    endif
    let s:confirmFlag = 0
    if !s:completeItemAvailable
        return
    endif
    try
        let item = json_decode(v:completed_item['info'])
    catch
        let item = ''
    endtry
    if empty(item)
        let s:userWord = []
        return
    endif
    call s:didChoose(item)
endfunction

let s:userWord=[]
function! s:didChoose(item)
    let g:ZFVimIM_choosedWord = a:item
    doautocmd User ZFVimIM_event_OnCompleteDone
    unlet g:ZFVimIM_choosedWord

    let s:seamless_positions[2] = s:start_column + len(a:item['word'])

    if a:item['type'] == 'sentence'
        for word in get(a:item, 'sentenceList', [])
            call s:addWord(a:item['dbId'], word['key'], word['word'])
        endfor
        let s:userWord = []
        return
    endif

    call add(s:userWord, a:item)

    if a:item['len'] == len(s:keyboard)
        call s:addWordFromUserWord()
        let s:userWord = []
    endif
endfunction
function! s:addWordFromUserWord()
    if !empty(s:userWord)
        let sentenceKey = ''
        let sentenceWord = ''
        let hasOtherDb = 0
        let dbIdPrev = ''
        for word in s:userWord
            call s:addWord(word['dbId'], word['key'], word['word'])

            if !hasOtherDb
                let hasOtherDb = (dbIdPrev != '' && dbIdPrev != word['dbId'])
                let dbIdPrev = word['dbId']
            endif
            let sentenceKey .= word['key']
            let sentenceWord .= word['word']
        endfor

        let needAdd = 0
        if !empty(g:ZFVimIM_autoAddWordChecker)
            let needAdd = 1
            for Checker in g:ZFVimIM_autoAddWordChecker
                if ZFVimIM_funcCallable(Checker)
                    let needAdd = ZFVimIM_funcCall(Checker, [s:userWord])
                    if !needAdd
                        break
                    endif
                endif
            endfor
        else
            if !hasOtherDb
                        \ && len(s:userWord) > 1
                        \ && len(sentenceWord) <= g:ZFVimIM_autoAddWordLen
                let needAdd = 1
            endif
        endif
        if needAdd
            call s:addWord(s:userWord[0]['dbId'], sentenceKey, sentenceWord)
        endif
    endif
endfunction

call s:init()
call s:resetState()

