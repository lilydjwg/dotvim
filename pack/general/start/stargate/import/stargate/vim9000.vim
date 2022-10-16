vim9script

import './stargates.vim' as sg
import './galaxies.vim'
import './messages.vim' as msg
import './workstation.vim' as ws

var in_visual_mode: bool
var is_hlsearch: bool
var stargate_visual: list<dict<any>>
var stargate_showmode: bool
const match_paren_enabled = exists(':DoMatchParen') == 2 ? true : false


# `mode` can be positive number or string
# when it is number search for that much consequitive input chars
# when `mode` is string it is regex to search for
export def OkVIM(mode: any)
    try
        Greetings()
        var destinations: dict<any>
        if type(mode) == v:t_number
            g:stargate_mode = true
            destinations = ChooseDestinations(mode)
        else
            g:stargate_mode = false
            destinations = sg.GetDestinations(mode)
        endif
        if !empty(destinations)
            normal! m'
            if len(destinations) == 1
                msg.BlankMessage()
                cursor(destinations.jump.orbit, destinations.jump.degree)
            else
                UseStargate(destinations)
            endif
        endif
    catch
        winrestview(g:stargate_winview)
        if v:exception =~ "^\s*stargate:"
            msg.Warning(v:exception)
        else
            redraw
            execute 'echoerr "' .. v:exception .. '"'
        endif
    finally
        Goodbye()
    endtry
enddef


def HideLabels(stargates: dict<any>)
    for v in values(stargates)
        popup_hide(v.id)
    endfor
enddef


def Saturate()
    prop_remove({ type: 'sg_error' }, g:stargate_near, g:stargate_distant)
    prop_remove({ type: 'sg_desaturate' }, g:stargate_near, g:stargate_distant)
enddef


def HideStarsHints()
    for v in values(g:stargate_popups)
        popup_hide(v)
    endfor
enddef

def Greetings()
    g:stargate_winview = winsaveview()

    in_visual_mode = mode() != 'n'
    if in_visual_mode
        stargate_showmode = &showmode
        &showmode = 0
        stargate_visual = hlget('Visual')
        hlset([{name: 'Visual', cleared: true, linksto: 'StargateVisual'}])
    endif

    [g:stargate_near, g:stargate_distant] = ws.ReachableOrbits()

    is_hlsearch = v:hlsearch
    if is_hlsearch
        &hlsearch = 0
    endif

    if match_paren_enabled
        silent! call matchdelete(3)
    endif

    ws.SetScreen()
    msg.StandardMessage(g:stargate_name .. ', choose a destination.')
enddef


def Goodbye()
    HideStarsHints()
    Saturate()
    ws.ClearScreen()

    # rehighlight matched paren
    doautocmd CursorMoved

    if is_hlsearch
        &hlsearch = 1
    endif

    if in_visual_mode
        &showmode = stargate_showmode
        hlset(stargate_visual)
    endif
enddef


def ShowFiltered(stargates: dict<any>)
    for [label, stargate] in items(stargates)
        const id = g:stargate_popups[label]
        const scr_pos = screenpos(0, stargate.orbit, stargate.degree)
        popup_move(id, { line: scr_pos.row, col: scr_pos.col })
        popup_setoptions(id, { highlight: stargate.color, zindex: stargate.zindex })
        popup_show(id)
        stargates[label].id = id
    endfor
enddef


def UseStargate(destinations: dict<any>)
    var stargates = copy(destinations)
    msg.StandardMessage('Select a stargate for a jump.')
    while true
        var filtered = {}
        const [nr: number, err: bool] = ws.SafeGetChar()

        if err || nr == 27  # 27 is <Esc>
            msg.BlankMessage()
            return
        endif

        const char = nr2char(nr)
        for [label, stargate] in items(stargates)
            if match(label, char) == 0
                const new_label = strcharpart(label, 1)
                filtered[new_label] = stargate
            endif
        endfor

        if empty(filtered)
            msg.Error('Wrong stargate, ' .. g:stargate_name .. '. Choose another one.')
        elseif len(filtered) == 1
            msg.BlankMessage()
            cursor(filtered[''].orbit, filtered[''].degree)
            return
        else
            HideLabels(stargates)
            ShowFiltered(filtered)
            stargates = copy(filtered)
            msg.StandardMessage('Select a stargate for a jump.')
        endif
    endwhile
enddef


def ChooseDestinations(mode: number): dict<any>
    var to_galaxy = false
    var destinations = {}
    while true
        var nrs = []
        for _ in range(mode)
            const [nr: number, err: bool] = ws.SafeGetChar()

            if err || nr == 27  # 27 is <Esc>
                msg.BlankMessage()
                return {}
            endif

            if nr == 23  # 23 is <C-w>
                to_galaxy = true
                break
            endif

            nrs->add(nr)
        endfor

        if to_galaxy
            to_galaxy = false
            if in_visual_mode || ws.InOperatorPendingMode()
                msg.Error('It is impossible to do now, ' .. g:stargate_name .. '.')
            elseif !galaxies.ChangeGalaxy(false)
                return {}
            endif
            g:stargate_winview = winsaveview()

            # if current window after the jump is in terminal or insert modes - quit stargate
            if match(mode(), '[ti]') == 0
                throw "stargate: can't work in terminal or insert mode."
            endif
            continue
        endif

        destinations = sg.GetDestinations(nrs
                                            ->mapnew((_, v) => nr2char(v))
                                            ->join(''))
        if empty(destinations)
            msg.Error("We can't reach there, " .. g:stargate_name .. '.')
            continue
        endif
        break
    endwhile

    return destinations
enddef

# vim: sw=4
