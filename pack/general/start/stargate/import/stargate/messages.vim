vim9script

import './workstation.vim' as ws


def Message(text: string, color: string)
    redraw
    exe 'echohl StargateVIM9000'
    echo ' VIM9000 '
    exe $'echohl {color}'
    echon $' {text} '
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
        ws.RemoveMatchHighlight(ws.win['StargateError'])
        # redraw required, because while getchar() is active
        # the screen is not redrawn normally
        redraw
    enddef

    ws.AddMatchHighlight('StargateError', 1002)
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
