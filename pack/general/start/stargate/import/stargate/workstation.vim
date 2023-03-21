vim9script

export const max_col = 5000
export var label_windows: dict<number>
export var winview: dict<any>
export var win: dict<any> = {
    topline: 0,
    botline: 0,
    lines_range: [],
    StargateFocus: 0,
    StargateDesaturate: 0,
    StargateError: 0,
}
var conceal_level: number
var fake_cursor_match_id: number


# Creates plugin highlights
export def CreateHighlights()
    highlight default StargateFocus guifg=#958c6a
    highlight default StargateDesaturate guifg=#49423f
    highlight default StargateError guifg=#d35b4b
    highlight default StargateLabels guifg=#caa247 guibg=#171e2c
    highlight default StargateErrorLabels guifg=#caa247 guibg=#551414
    highlight default StargateMain guifg=#f2119c gui=bold cterm=bold
    highlight default StargateSecondary guifg=#11eb9c gui=bold cterm=bold
    highlight default StargateShip guifg=#111111 guibg=#caa247
    highlight default StargateVIM9000 guifg=#111111 guibg=#b2809f gui=bold cterm=bold
    highlight default StargateMessage guifg=#a5b844
    highlight default StargateErrorMessage guifg=#e36659
    highlight default link StargateVisual Visual
enddef


# Returns first window column number after signcolumn
export def DisplayLeftEdge(): number
    return win_getid()
            ->getwininfo()[0].textoff + 1
enddef


# Returns `true` if 'list' option is set and 'listchars' has 'precedes'
def ListcharsHasPrecedes(): bool
    return &list && match(&listchars, 'precedes') != -1
enddef


# Creates new matchadd highlight and additionally removes any leftover
# highlights from the previous highlighting of this `match_group`
# Useful when adding match highlight with the `timer_start()`
export def AddMatchHighlight(match_group: string, priority: number)
    const id = matchaddpos(match_group, win.lines_range, priority)
    RemoveMatchHighlight(win[match_group])
    win[match_group] = id
enddef

# Silently removes match highlight with `match_id`
export def RemoveMatchHighlight(match_id: number)
    silent! call matchdelete(match_id)
enddef

# Returns first and last visible virtual columns of the buffer in the current window
export def OrbitalArc(): dict<number>
    const edge = DisplayLeftEdge()
    var last_degree = 0
    var first_degree = virtcol('.') - wincol() + edge
    if first_degree > 1 && ListcharsHasPrecedes()
        first_degree += 1
        last_degree -= 1
    endif
    last_degree += first_degree + winwidth(0) - edge
    return { first: first_degree, last: last_degree }
enddef


# Sets some new values for global `win` dictionary
export def UpdateWinBounds()
    win.topline = line('w0')
    win.botline = line('w$')
    win.lines_range = range(win.topline, win.botline)
enddef


# Returns list of all visible lines of the current window buffer from top to bottom.
# Excluding folded lines
export def OrbitsWithoutBlackmatter(near: number, distant: number): list<number>
    var current = near
    var orbits = []
    while current <= distant
        const last_bm_orbit = foldclosedend(current)
        # foldclosedend() returns -1 if not in closed fold
        if last_bm_orbit != -1
            current = last_bm_orbit + 1
        else
            orbits->add(current)
            current += 1
        endif
    endwhile

    return orbits
enddef


# Returns new pattern with all alternative branches for pattern
# found in g:stargate_keymaps or unmodified
def ProcessKeymap(pattern: string): string
    var pat: string
    for char in (split(pattern, '\zs'))
        const rhs = get(g:stargate_keymaps, char, '')
        if empty(rhs)
            pat ..= char
        else
            pat ..= $'\[{char}{rhs}]'
        endif
    endfor

    return pat
enddef


# Retruns true in operator-pending mode
export def InOperatorPendingMode(): bool
    return state()[0] == 'o'
enddef


# Returns modified pattern so it can be processed by searchpos()
export def TransformPattern(pattern: string, is_regex: bool): string
    if is_regex
        return pattern
    elseif pattern == ' '
        return '\S\zs\s'
    endif

    var pat = pattern
    const prefix = '\V' .. (g:stargate_ignorecase ? '\c' : '\C')
    if !empty(g:stargate_keymaps)
        pat = ProcessKeymap(pat)
    endif

    return prefix .. pat
enddef


# GetLabels(['a', 'b'], 5)  ->
# {labels: [['a', 'b'], ['aa', 'ab'], ['ba', 'bb'], ['aaa', 'aab']],
# start_row: 1, start_col: 1, end_row: 3, end_col: 1, len: 2}
export def LabelLists(chars: list<string>, length: number): dict<any>
    const chars_len = len(chars)
    const one_less = chars_len - 1
    var total_len = length
    var labels = [copy(chars)]

    var index = 0
    var i1 = index / chars_len
    var i2 = index % chars_len
    while total_len > chars_len
        const char = labels[i1][i2]
        labels->add(MapnewConcat(chars, char))
        total_len -= one_less
        index += 1
        i1 = index / chars_len
        i2 = index % chars_len
    endwhile

    const labels_len = len(labels)
    const end_row = labels_len - 1
    const end_col = chars_len - (labels_len * chars_len - length - index + 1)

    return {
        labels: labels,
        len: chars_len,
        start_row: i1,
        start_col: i2,
        end_row: end_row,
        end_col: end_col
    }
enddef


# Returns new list with each string element in it prefixed with `char`
# MapnewConcat(['x', 'y', 'z'], 'a') -> ['ax', 'ay', 'az']
def MapnewConcat(strings: list<string>, char: string): list<string>
    var result = []
    for str in strings
        result->add(char .. str)
    endfor
    return result
enddef


# Returns result and error state, but do not break out
# from invoking of getchar() immediately. Replaces all NaN results with -1
export def SafeGetChar(): list<any>
    var nr: number
    var err = false
    try
        nr = getchar()
        if type(nr) != v:t_number
            nr = -1
        endif
    catch
        err = true
    endtry
    return [nr, err]
enddef


export def CreateLabelWindows()
    label_windows = {}
    const labels = LabelLists(g:stargate_chars, g:stargate_limit).labels->flattennew(1)
    for ds in labels
        label_windows[ds] = popup_create(ds, { line: 0, col: 0, hidden: true, wrap: false })
    endfor
enddef


export var HideCursor: func()
export var ShowCursor: func()
# Hiding the cursor when awaiting for char of getchar() function
# done differently in gui and terminal
if has('gui_running')
    var cursor_state: list<dict<any>>
    HideCursor = () => {
        cursor_state = hlget('Cursor')
        hlset([{name: 'Cursor', cleared: true}])
    }
    ShowCursor = () => {
        hlset(cursor_state)
    }
else
    var cursor_state: string
    HideCursor = () => {
        cursor_state = &t_ve
        &t_ve = ''
    }
    ShowCursor = () => {
        &t_ve = cursor_state
    }
endif


export def SetScreen()
    conceal_level = &conceallevel
    &conceallevel = 0
    HideCursor()

    fake_cursor_match_id = matchaddpos('StargateShip', [[line('.'), col('.')]], 1010)
    AddMatchHighlight('StargateFocus', 1000)
enddef


export def ClearScreen()
    RemoveMatchHighlight(win['StargateFocus'])
    RemoveMatchHighlight(fake_cursor_match_id)
    ShowCursor()
    &conceallevel = conceal_level
enddef

# vim: sw=4
