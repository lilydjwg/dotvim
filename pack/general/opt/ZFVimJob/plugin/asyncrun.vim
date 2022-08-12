
function! ZF_AsyncRunOutputInfo(jobStatus)
    let statusline = ZFJobRunningToken(a:jobStatus, ':')
    let taskName = get(get(a:jobStatus, 'jobImplData', {}), 'ZFAsyncRun_taskName', s:taskNameDefault)
    if taskName == s:taskNameDefault
        let statusline .= 'ZFAsyncRun ' . ZFGroupJobInfo(a:jobStatus)
    else
        let statusline .= '[' . taskName . '] ' . ZFGroupJobInfo(a:jobStatus)
    endif
    return statusline
endfunction

function! ZF_AsyncRunMakeDefaultKeymap_input(input, cr)
    let taskName = b:ZFAsyncRun_taskName
    let ret = ":\<c-u>call ZFAsyncRunSend(\"\\n\", '" . taskName . "')" . repeat("\<left>", len(taskName) + 8)
    if !empty(a:input)
        let ret .= a:input
    endif
    if a:cr
        let ret .= "\<cr>"
    endif
    return ret
endfunction
function! ZF_AsyncRunMakeDefaultKeymap_stop()
    let taskName = b:ZFAsyncRun_taskName
    return ":\<c-u>call ZFAsyncRunStop('" . taskName . "')\<cr>"
endfunction
function! ZF_AsyncRunMakeDefaultKeymap()
    nnoremap <buffer><expr> i ZF_AsyncRunMakeDefaultKeymap_input('', 0)
    nnoremap <buffer><expr> I ZF_AsyncRunMakeDefaultKeymap_input('', 0)
    nnoremap <buffer><expr> o ZF_AsyncRunMakeDefaultKeymap_input('', 0)
    nnoremap <buffer><expr> O ZF_AsyncRunMakeDefaultKeymap_input('', 0)
    nnoremap <buffer><expr> a ZF_AsyncRunMakeDefaultKeymap_input('', 0)
    nnoremap <buffer><expr> A ZF_AsyncRunMakeDefaultKeymap_input('', 0)
    nnoremap <buffer><expr> <cr> ZF_AsyncRunMakeDefaultKeymap_input('', 1)
    nnoremap <buffer><expr> <c-c> ZF_AsyncRunMakeDefaultKeymap_stop()
endfunction

" ============================================================
" see ZFJobOutput
if !exists('g:ZFAsyncRun_outputTo')
    let g:ZFAsyncRun_outputTo = {
                \   'outputType' : 'logwin',
                \   'outputInfo' : function('ZF_AsyncRunOutputInfo'),
                \   'outputInfoInterval' : 1000,
                \   'logwin' : {
                \     'filetype' : 'ZFAsyncRunLog',
                \     'autoShow' : 1,
                \   },
                \   'popup' : {
                \     'pos' : 'bottom',
                \     'width' : 1.0/3,
                \     'height' : 1.0/4,
                \     'x' : 1,
                \     'y' : 2,
                \     'wrap' : 1,
                \     'contentAlign' : 'bottom',
                \   },
                \ }
endif

" ============================================================
command! -nargs=+ -complete=customlist,ZFJobCmdComplete ZFAsyncRun :call ZFAsyncRun(<q-args>)
command! -nargs=0 ZFAsyncRunStop :call ZFAsyncRunStop()
command! -nargs=0 ZFAsyncRunStopAll :call ZFAsyncRunStopAll()
command! -nargs=* ZFAsyncRunSend :call ZFAsyncRunSend(<q-args> . "\n")
command! -nargs=0 ZFAsyncRunLog :call ZFAsyncRunLog()
command! -nargs=0 ZFAsyncRunLogAll :call ZFAsyncRunLogAll()

let s:taskNameDefault = '-'
function! s:taskName(taskName)
    if type(a:taskName) == type(0)
        let jobStatus = ZFGroupJobStatus(a:taskName)
        if empty(jobStatus)
            return ''
        else
            return jobStatus['jobImplData']['ZFAsyncRun_taskName']
        endif
    else
        if empty(a:taskName)
            return s:taskNameDefault
        else
            return a:taskName
        endif
    endif
endfunction

function! ZFAsyncRun(param, ...)
    let taskName = s:taskName(get(a:, 1, ''))
    if empty(taskName)
        return -1
    endif
    call ZFAsyncRunStop(taskName)

    let outputTo = deepcopy(g:ZFAsyncRun_outputTo)
    if type(a:param) == type('') || ZFJobFuncCallable(a:param)
        let jobOption = {
                    \   'jobCmd' : a:param,
                    \   'outputTo' : outputTo,
                    \ }
    elseif type(a:param) == type({})
        let jobOption = deepcopy(a:param)
        let jobOption['outputTo'] = extend(outputTo, get(jobOption, 'outputTo', {}))
    else
        echomsg '[ZFVimJob] unsupported param type: ' . type(a:param)
        return -1
    endif
    let outputTo['initCallback'] = ZFJobFunc(function('ZFAsyncRunImpl_logwinOnInit'), [taskName, get(outputTo, 'initCallback', '')])

    if empty(get(jobOption['outputTo'], 'outputId', ''))
        let jobOption['outputTo']['outputId'] = 'ZFAsyncRun:' . taskName
    endif

    if !exists("jobOption['jobImplData']")
        let jobOption['jobImplData'] = {}
    endif
    let jobOption['jobImplData']['ZFAsyncRun_taskName'] = taskName

    let jobId = ZFGroupJobStart(extend(deepcopy(jobOption), {
                \   'onExit' : ZFJobFunc(function('ZFAsyncRunImpl_onExit'), [taskName, get(jobOption, 'onExit', '')]),
                \ }))
    if jobId == -1
        " fail or finished sync
        return jobId
    endif
    if jobId == 0
        " nothing to do, s:taskMap would be set during ZFAsyncRunImpl_onExit
        return jobId
    endif
    let s:taskMap[taskName] = ZFGroupJobStatus(jobId)
    return jobId
endfunction

function! ZFAsyncRunStop(...)
    let taskName = s:taskName(get(a:, 1, ''))
    if empty(taskName)
        return 0
    endif
    let task = get(s:taskMap, taskName, {})
    if empty(task) || task['jobId'] == -1
        return 0
    endif
    call ZFGroupJobStop(task['jobId'])
    let task['jobId'] = -1
    return 1
endfunction

function! ZFAsyncRunStopAll()
    let taskNameList = copy(keys(s:taskMap))
    for taskName in taskNameList
        call ZFAsyncRunStop(taskName)
    endfor
endfunction

function! ZFAsyncRunSend(text, ...)
    let taskName = s:taskName(get(a:, 1, ''))
    if !exists('s:taskMap[taskName]')
        return 0
    endif

    let jobId = s:taskMap[taskName]['jobId']
    if jobId <= 0
        return 0
    endif

    call ZFGroupJobSend(jobId, a:text)
    return 1
endfunction

function! ZFAsyncRunLog(...)
    let taskName = s:taskName(get(a:, 1, ''))
    if !exists('s:taskMap[taskName]')
        return []
    endif

    let jobId = s:taskMap[taskName]['jobId']
    if jobId > 0
        let statusHint = 'running ' . jobId
    else
        let statusHint = 'finished ' . s:taskMap[taskName]['exitCode']
    endif
    echo taskName . ' (' . statusHint . ') : ' . ZFGroupJobInfo(s:taskMap[taskName])

    let jobOutput = s:taskMap[taskName]['jobOutput']
    for log in jobOutput
        echo '    ' . log
    endfor
    return jobOutput
endfunction

function! ZFAsyncRunLogAll()
    let ret = {}
    for taskName in keys(s:taskMap)
        let ret[taskName] = ZFAsyncRunLog(taskName)
    endfor
    return ret
endfunction

function! ZFAsyncRunStatus(...)
    let taskName = s:taskName(get(a:, 1, ''))
    return get(s:taskMap, taskName, {})
endfunction

function! ZFAsyncRunTaskMap()
    return s:taskMap
endfunction

" ============================================================
" {
"   'taskName' : jobStatus,
" }
if !exists('s:taskMap')
    let s:taskMap = {}
endif

function! ZFAsyncRunImpl_logwinOnInit(taskName, initCallback, logId)
    let b:ZFAsyncRun_taskName = a:taskName
    if get(get(ZFLogWinStatus(a:logId), 'config', {}), 'makeDefaultKeymap', 1)
        call ZF_AsyncRunMakeDefaultKeymap()
    endif
    call ZFJobFuncCall(a:initCallback, [a:logId])
endfunction

function! ZFAsyncRunImpl_onExit(taskName, onExit, jobStatus, exitCode)
    let s:taskMap[a:taskName] = a:jobStatus
    call ZFJobFuncCall(a:onExit, [a:jobStatus, a:exitCode])
endfunction

