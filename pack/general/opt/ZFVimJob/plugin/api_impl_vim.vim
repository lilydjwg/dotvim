if !exists('*job_start') || !has('channel') || !has('patch-7.4.1590') || !has('timers')
    finish
endif
if !empty(get(g:, 'ZFJobImpl', {}))
    finish
endif

function! s:jobStart(jobStatus, onOutput, onExit)
    let a:jobStatus['jobImplData']['impl_vim'] = {
                \   'onOutput' : a:onOutput,
                \   'onExit' : a:onExit,
                \   'queuedTimerId' : -1,
                \   'queuedOutput' : [],
                \   'queuedExitCode' : '',
                \   'queuedExitFlag' : 0,
                \ }

    " use `mode=raw` seems to solve:
    "   https://github.com/vim/vim/issues/1320
    " also, search `queuedXxx` in this file,
    " which use timer to queue and delay output and exit callback,
    " to solve the above issue
    let jobImplOption = {
                \   'out_cb' : function('s:vim_out_cb', [a:jobStatus]),
                \   'err_cb' : function('s:vim_err_cb', [a:jobStatus]),
                \   'exit_cb' : function('s:vim_exit_cb', [a:jobStatus]),
                \   'mode' : 'raw',
                \ }
    if !empty(get(a:jobStatus['jobOption'], 'jobCwd', ''))
        let jobImplOption['cwd'] = a:jobStatus['jobOption']['jobCwd']
    endif

    if v:version <= 800
        " for some weird vim version,
        " `python "a.py"` would fail because of double quotes
        " causing `no such file "a.py"`
        let jobCmd = ZFJobCmdToList(a:jobStatus['jobOption']['jobCmd'])
    else
        let jobCmd = a:jobStatus['jobOption']['jobCmd']
    endif

    try
        let jobImplId = job_start(jobCmd, jobImplOption)
    catch
        let jobImplId = {}
    endtry
    if empty(jobImplId) || job_status(jobImplId) != 'run'
        return 0
    endif
    let a:jobStatus['jobImplData']['impl_vim']['jobImplId'] = jobImplId

    let jobImplChannel = job_getchannel(jobImplId)
    if empty(jobImplChannel) || string(jobImplChannel) == 'channel fail'
        call job_stop(jobImplId)
        return 0
    endif
    let a:jobStatus['jobImplData']['impl_vim']['jobImplChannel'] = jobImplChannel

    return 1
endfunction

function! s:jobStop(jobStatus)
    if a:jobStatus['jobImplData']['impl_vim']['queuedTimerId'] != -1
        call timer_stop(a:jobStatus['jobImplData']['impl_vim']['queuedTimerId'])
        let a:jobStatus['jobImplData']['impl_vim']['queuedTimerId'] = -1
    endif
    if !empty(get(a:jobStatus['jobImplData']['impl_vim'], 'jobImplChannel', ''))
        if ch_status(a:jobStatus['jobImplData']['impl_vim']['jobImplChannel']) == 'open'
            try
                silent! call ch_close(a:jobStatus['jobImplData']['impl_vim']['jobImplChannel'])
            endtry
        endif
    endif
    if !empty(get(a:jobStatus['jobImplData']['impl_vim'], 'jobImplId', ''))
        call job_stop(a:jobStatus['jobImplData']['impl_vim']['jobImplId'])
    endif
    return 1
endfunction

function! s:jobSend(jobStatus, text)
    if !empty(get(a:jobStatus['jobImplData']['impl_vim'], 'jobImplChannel', ''))
        call ch_sendraw(a:jobStatus['jobImplData']['impl_vim']['jobImplChannel'], a:text)
    endif
    return 1
endfunction

function! s:vim_out_cb(jobStatus, jobImplChannel, msg, ...)
    if a:jobStatus['jobId'] < 0
        return
    endif
    call add(a:jobStatus['jobImplData']['impl_vim']['queuedOutput'], [a:msg, 'stdout'])
    call s:queuedRun(a:jobStatus)
endfunction
function! s:vim_err_cb(jobStatus, jobImplChannel, msg, ...)
    if a:jobStatus['jobId'] < 0
        return
    endif
    call add(a:jobStatus['jobImplData']['impl_vim']['queuedOutput'], [a:msg, 'stderr'])
    call s:queuedRun(a:jobStatus)
endfunction
function! s:vim_exit_cb(jobStatus, jobImplId, exitCode, ...)
    if a:jobStatus['jobId'] < 0
        return
    endif
    let a:jobStatus['jobImplData']['impl_vim']['queuedExitCode'] = '' . a:exitCode
    let a:jobStatus['jobImplData']['impl_vim']['queuedExitFlag'] = 1
    call s:queuedRun(a:jobStatus)
endfunction
function! s:queuedRun(jobStatus)
    if a:jobStatus['jobImplData']['impl_vim']['queuedTimerId'] != -1
        return
    endif
    let a:jobStatus['jobImplData']['impl_vim']['queuedTimerId'] = timer_start(0, function('s:queuedRunCallback', [a:jobStatus]))
endfunction
function! s:queuedRunCallback(jobStatus, ...)
    let jobImplState = a:jobStatus['jobImplData']['impl_vim']
    let jobImplState['queuedTimerId'] = -1
    while !empty(jobImplState['queuedOutput'])
        let queuedOutput = jobImplState['queuedOutput']
        let jobImplState['queuedOutput'] = []
        for item in queuedOutput
            call ZFJobFuncCall(jobImplState['onOutput'], [split(item[0], "\n"), item[1]])
        endfor
    endwhile
    if jobImplState['queuedExitFlag'] == 0
        return
    elseif jobImplState['queuedExitFlag'] == 1
        " wait again to wait for unfinished out_cb
        let jobImplState['queuedExitFlag'] = 2
        call s:queuedRun(a:jobStatus)
        return
    else
        " job really finished
    endif

    if !empty(get(jobImplState, 'jobImplChannel', ''))
        if ch_status(jobImplState['jobImplChannel']) == 'open'
            try
                silent! call ch_close(jobImplState['jobImplChannel'])
            endtry
        endif
    endif
    call ZFJobFuncCall(jobImplState['onExit'], [jobImplState['queuedExitCode']])
endfunction

let g:ZFJobImpl = {
            \   'jobStart' : function('s:jobStart'),
            \   'jobStop' : function('s:jobStop'),
            \   'jobSend' : function('s:jobSend'),
            \ }

