vim9script

import './workstation.vim' as ws


def Message(text: string, color: string)
    redraw
    execute 'echohl StargateVIM9000'
    echo ' VIM9000 '
    execute 'echohl ' .. color
    echon ' ' .. text .. ' '
    echohl None
enddef


export def ErrorMessage(text: string)
    Message(text, 'StargateErrorMessage')
enddef


export def StandardMessage(text: string)
    Message(text, 'StargateMessage')
enddef


export def Error(message: string)
    def RemoveError(t: number)
        prop_remove({ type: 'sg_error' }, g:stargate_near, g:stargate_distant + 1)
        redraw
    enddef

    prop_add(g:stargate_near, 1, {
        end_lnum: g:stargate_distant,
        end_col: ws.max_col,
        type: 'sg_error'
    })
    ErrorMessage(message)
    timer_start(150, RemoveError)
enddef


export def Warning(message: string)
    redraw
    echohl WarningMsg
    echom message
    echohl None
enddef


export def BlankMessage()
    redraw
    echo ''
enddef

# vim: sw=4
