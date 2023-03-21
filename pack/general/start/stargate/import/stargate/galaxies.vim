vim9script

import './messages.vim' as msg
import './workstation.vim' as ws

const labels = [' ', 'f', 'j', 'd', 'l', 's', 'h', 'g', 'a', 'i', 'e', 'o', 'c', 'u']
const galaxy_labels = expand('<sfile>:p:h:h:h') .. '/galaxy_labels'


# Swap current window info into 0 index of `wininfo` parameter
def CurrentGalaxyToFirst(wininfo: list<dict<any>>)
    const cur_winnr = winnr()
    for i in range(len(wininfo))
        if wininfo[i].winnr == cur_winnr
            wininfo->insert(wininfo->remove(i))
        endif
    endfor
enddef


# Create popup in the center of the window from `wininfo` parameter
def GalaxyLabel(buf_nr: number, line_nr: number, wininfo: dict<any>): number
    const width = 7
    const height = 4
    const row = wininfo.winrow + wininfo.height / 2 - height / 2
    const column = wininfo.wincol + wininfo.width / 2 - width / 2
    return popup_create( buf_nr, {
        line: row,
        col: column,
        flip: false,
        minheight: height,
        maxheight: height,
        minwidth: width,
        maxwidth: width,
        firstline: line_nr,
        wrap: false,
        drag: false,
        resize: false,
        highlight: 'StargateLabels',
        scrollbar: false,
        zindex: 10000,
        moved: 'any'
    })
enddef


# Creates popups with labels for all windows in the current tabpage
def DisplayGalaxiesLabels(buf_nr: number, wininfo: list<dict<any>>): dict<any>
    var galaxies = {}
    for i in range(len(wininfo))
        const id = GalaxyLabel(buf_nr, i * 4 + 1, wininfo[i])
        galaxies[labels[i]] = { popupid: id, winid: wininfo[i].winid }
    endfor
    return galaxies
enddef


def LabelsError(gal: dict<any>)
    const galaxies = values(gal)
    def Recolor(highlight: string)
        for galaxy in galaxies
            popup_setoptions(galaxy.popupid, { highlight: highlight })
        endfor
        msg.ErrorMessage($"Our ship can't reach that galaxy, {g:stargate_name}")
    enddef

    timer_start(5, (t) => Recolor('StargateErrorLabels'))
    timer_start(150, (t) => Recolor('StargateLabels'))
enddef


# Switch to the labeled window and return 1, on error or <Esc> returns 0
def InputLoop(galaxies: dict<dict<number>>, independent: bool): number
    while true
        const [nr: number, err: bool] = ws.SafeGetChar()

        if err || nr == 27
            return 0
        endif

        const char = nr2char(nr)
        const destination = copy(galaxies)->filter((k, _) => k == char)
        if empty(destination)
            LabelsError(galaxies)
            continue
        endif

        if !independent
            ws.ClearScreen()
        endif
        win_gotoid(destination[char].winid)
        if !independent
            ws.UpdateWinBounds()
            ws.SetScreen()
        endif
        break
    endwhile
    return 1
enddef


export def ChangeGalaxy(independent: bool): number
    if !filereadable(galaxy_labels)
        msg.ErrorMessage("Internal error, can't display galaxies.")
        return 0
    endif

    const tabnr = tabpagenr()
    var galaxies_info = getwininfo()->filter((_, v) => v.tabnr == tabnr)
    if len(galaxies_info) == 1
        # when starts with stargate#Galaxy() call we need to set g variables
        # to highlight that range on error
        if independent
            ws.UpdateWinBounds()
        endif
        msg.Error($"{g:stargate_name}, your species can't outsmart me.")
        return 1
    endif

    const buf_nr = bufadd('galaxy_labels')
    setbufvar(buf_nr, '&buftype', 'popup')
    bufload(buf_nr)
    readfile(galaxy_labels)->setbufline(buf_nr, 1)
    CurrentGalaxyToFirst(galaxies_info)
    const galaxies = DisplayGalaxiesLabels(buf_nr, galaxies_info)
    var result: number

    if independent
        ws.HideCursor()
    endif

    msg.StandardMessage($'Choose a galaxy for the hyperjump, {g:stargate_name}.')
    result = InputLoop(galaxies, independent)
    for galaxy in values(galaxies)
        popup_close(galaxy.popupid)
    endfor

    if independent
        ws.ShowCursor()
    endif

    if !independent && result
        msg.StandardMessage('Now choose a destination.')
    else
        msg.BlankMessage()
    endif

    return result
enddef

defcompile

# vim: sw=4
