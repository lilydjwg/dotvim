vim9script

export const max_col = 5000
const in_gvim = has('gui_running')


# Returns first window column number after signcolumn
export def DisplayLeftEdge(): number
    return win_getid()
            ->getwininfo()[0].textoff + 1
enddef


# Returns `true` if 'list' option is set and 'listchars' has 'precedes'
def ListcharsHasPrecedes(): bool
    return &list && match(&listchars, 'precedes') != -1
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


# Returns top and bottom visible lines numbers of the current window
export def ReachableOrbits(): list<number>
    return [line('w0'), line('w$')]
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
            pat ..= '\[' .. char .. rhs .. ']'
        endif
    endfor

    return pat
enddef


# Retruns true in operator-pending mode
export def InOperatorPendingMode(): bool
    return state()[0] == 'o'
enddef

# Returns modified pattern so it can be processed by searchpos()
export def TransformPattern(pattern: string): string
    if !g:stargate_mode
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


export def CreatePopups()
    var popups = {}
    const labels = LabelLists(g:stargate_chars, g:stargate_limit).labels->flattennew(1)
    for ds in labels
        popups[ds] = popup_create(ds, { line: 0, col: 0, hidden: true, wrap: false })
    endfor
    g:stargate_popups = popups
enddef


export def HideCursor()
    if in_gvim
        g:stargate_cursor = hlget('Cursor')
        hlset([{name: 'Cursor', cleared: true}])
    else
        g:stargate_cursor = &t_ve
        &t_ve = ''
    endif
enddef


export def ShowCursor()
    if in_gvim
        hlset(g:stargate_cursor)
    else
        &t_ve = g:stargate_cursor
    endif
enddef


export def SetScreen()
    g:stargate_conceallevel = &conceallevel
    &conceallevel = 0
    HideCursor()
    prop_add(line('.'), col('.'), { type: 'sg_ship' })
    prop_add(g:stargate_near, 1, { end_lnum: g:stargate_distant, end_col: max_col, type: 'sg_focus' })
enddef


export def ClearScreen()
    prop_remove({ type: 'sg_focus' }, g:stargate_near, g:stargate_distant)
    prop_remove({ type: 'sg_ship' }, g:stargate_near, g:stargate_distant)
    ShowCursor()
    &conceallevel = g:stargate_conceallevel
enddef

# vim: sw=4
