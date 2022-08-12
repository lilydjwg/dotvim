
function! ZFJobOutput_logwin_fallbackCheck()
    if !ZFJobTimerAvailable()
        return 'statusline'
    else
        return ''
    endif
endfunction

function! ZFLogWinImpl_outputInfoWrap(outputInfo, logId)
    return ZFStatuslineLogValue(ZFJobFuncCall(a:outputInfo, [ZFLogWinJobStatusGet(a:logId)]))
endfunction

function! ZFLogWinImpl_outputInfoTimer(outputStatus, jobStatus, ...)
    call ZFLogWinRedrawStatusline(a:outputStatus['outputId'])
    call s:outputInfoIntervalUpdate(a:outputStatus, a:jobStatus)
endfunction
function! s:outputInfoIntervalUpdate(outputStatus, jobStatus)
    if get(a:outputStatus['outputImplData'], 'outputInfoTaskId', -1) != -1
        call ZFJobTimerStop(a:outputStatus['outputImplData']['outputInfoTaskId'])
        let a:outputStatus['outputImplData']['outputInfoTaskId'] = -1
    endif
    if get(a:jobStatus['jobOption']['outputTo'], 'outputInfoInterval', 0) > 0 && ZFJobTimerAvailable()
        let a:outputStatus['outputImplData']['outputInfoTaskId']
                    \ = ZFJobTimerStart(a:jobStatus['jobOption']['outputTo']['outputInfoInterval'], ZFJobFunc(function('ZFLogWinImpl_outputInfoTimer'), [a:outputStatus, a:jobStatus]))
    endif
endfunction

function! ZFJobOutput_logwin_init(outputStatus, jobStatus)
    let config = get(a:jobStatus['jobOption']['outputTo'], 'logwin', {})
    if empty(get(config, 'statusline', '')) && !empty(get(a:jobStatus['jobOption']['outputTo'], 'outputInfo', ''))
        let T_outputInfo = a:jobStatus['jobOption']['outputTo']['outputInfo']
        if type(T_outputInfo) == type('')
            let config = copy(config)
            let config['statusline'] = T_outputInfo
        elseif ZFJobFuncCallable(T_outputInfo)
            let config = copy(config)
            let config['statusline'] = ZFJobFunc(function('ZFLogWinImpl_outputInfoWrap'), [T_outputInfo])
            call s:outputInfoIntervalUpdate(a:outputStatus, a:jobStatus)
        endif
    endif
    call ZFLogWinConfig(a:outputStatus['outputId'], config)
endfunction

function! ZFJobOutput_logwin_cleanup(outputStatus, jobStatus)
    if get(a:outputStatus['outputImplData'], 'outputInfoTaskId', -1) != -1
        call ZFJobTimerStop(a:outputStatus['outputImplData']['outputInfoTaskId'])
        unlet a:outputStatus['outputImplData']['outputInfoTaskId']
    endif
    if !get(get(a:outputStatus['outputTo'], 'logwin', {}), 'logwinNoCloseWhenFocused', 1) || !ZFLogWinIsFocused(a:outputStatus['outputId'])
        if get(get(a:outputStatus['outputTo'], 'logwin', {}), 'logwinAutoClosePreferHide', 0)
            call ZFLogWinHide(a:outputStatus['outputId'])
        else
            call ZFLogWinClose(a:outputStatus['outputId'])
        endif
        call ZFLogWinJobStatusSet(a:outputStatus['outputId'], {})
    endif
endfunction

function! ZFJobOutput_logwin_attach(outputStatus, jobStatus)
    call ZFLogWinJobStatusSet(a:outputStatus['outputId'], a:jobStatus)
endfunction

function! ZFJobOutput_logwin_detach(outputStatus, jobStatus)
    call ZFLogWinRedrawStatusline(a:outputStatus['outputId'])
endfunction

function! ZFJobOutput_logwin_output(outputStatus, jobStatus, textList, type)
    call ZFLogWinAdd(a:outputStatus['outputId'], a:textList)
    call s:outputInfoIntervalUpdate(a:outputStatus, a:jobStatus)
endfunction

if !exists('g:ZFJobOutputImpl')
    let g:ZFJobOutputImpl = {}
endif
let g:ZFJobOutputImpl['logwin'] = {
            \   'fallbackCheck' : function('ZFJobOutput_logwin_fallbackCheck'),
            \   'init' : function('ZFJobOutput_logwin_init'),
            \   'cleanup' : function('ZFJobOutput_logwin_cleanup'),
            \   'attach' : function('ZFJobOutput_logwin_attach'),
            \   'detach' : function('ZFJobOutput_logwin_detach'),
            \   'output' : function('ZFJobOutput_logwin_output'),
            \ }

