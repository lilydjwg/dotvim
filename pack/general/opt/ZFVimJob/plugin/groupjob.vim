
function! ZFGroupJobChildImpl()
    if !exists('s:ZFGroupJobChildImpl')
        let s:ZFGroupJobChildImpl = {
                    \   'jobStart' : function('ZFJobPoolStart'),
                    \   'jobStop' : function('ZFJobPoolStop'),
                    \   'jobSend' : function('ZFJobPoolSend'),
                    \   'jobStatus' : function('ZFJobPoolStatus'),
                    \   'jobInfo' : function('ZFJobPoolInfo'),
                    \   'jobLog' : function('ZFJobPoolLog'),
                    \ }
    endif
    return s:ZFGroupJobChildImpl
endfunction

" param can be any type that ZFJobStart supports, or groupJobOption: {
"   'jobList' : [
"     [
"       {
"         'jobCmd' : '',
"         'onOutput' : '',
"         'onExit' : '',
"         ...
"       },
"       {
"         'jobList' : [ // group job can be chained
"           ...
"         ],
"       },
"       ...
"     ],
"     ...
"   ],
"   'jobCmd' : 'optional, used only when jobList not supplied',
"   'jobCwd' : 'optional, if supplied, would use as default value for child ZFJobStart',
"   'onLog' : 'optional, func(groupJobStatus, log)',
"   'onOutputFilter' : 'optional, func(groupJobStatus, textList, type[stdout/stderr]), modify textList or empty to discard',
"   'onOutput' : 'optional, func(groupJobStatus, textList, type[stdout/stderr])',
"   'onEnter' : 'optional, func(groupJobStatus)',
"   'onExit' : 'optional, func(groupJobStatus, exitCode)',
"   'jobOutputDelay' : 'optional, default is g:ZFJobOutputDelay',
"   'jobOutputLimit' : 'optional, max line of jobOutput that would be stored in groupJobStatus, default is g:ZFJobOutputLimit',
"   'jobOutputCRFix' : 'optional, whether try to replace `\r\n` to `\n`, default is g:ZFJobOutputCRFix',
"   'jobEncoding' : 'optional, if supplied, would use as default value for child ZFJobStart',
"   'jobTimeout' : 'optional, if supplied, would use as default value for child ZFJobStart',
"   'jobFallback' : 'optional, if supplied, would use as default value for child ZFJobStart',
"   'jobImplData' : {}, // optional, if supplied, merge to groupJobStatus['jobImplData']
"
"   'groupJobTimeout' : 'optional, if supplied, ZFGroupJobStop would be called with g:ZFJOBTIMEOUT',
"   'groupJobStopOnChildError' : 'optional, 1 by default, whether stop group job when any of child has exitCode!=0',
"   'onJobLog' : 'optional, func(groupJobStatus, jobStatus, log)',
"   'onJobOutput' : 'optional, func(groupJobStatus, jobStatus, textList, type[stdout/stderr])',
"   'onJobExit' : 'optional, func(groupJobStatus, jobStatus, exitCode)',
" }
"
" jobList:
" contain each child job group,
" child job group would be run one by one only when previous exit successfully,
" while grand child within child job group would be run concurrently
"
" return:
" * -1 if failed
" * 0 if fallback to `system()`
" * groupJobId if success (ensured greater than 0)
function! ZFGroupJobStart(param)
    return s:groupJobStart(a:param)
endfunction

function! ZFGroupJobStop(groupJobId, ...)
    return s:groupJobStop(ZFGroupJobStatus(a:groupJobId), {}, '' . get(a:, 1, g:ZFJOBSTOP))
endfunction

function! ZFGroupJobSend(groupJobId, text)
    let groupJobStatus = ZFGroupJobStatus(a:groupJobId)
    if empty(groupJobStatus)
        return 0
    endif
    let sendCount = 0
    for jobStatusList in groupJobStatus['jobStatusList']
        for jobStatus in jobStatusList
            call ZFGroupJobChildImpl()['jobSend'](jobStatus['jobId'], a:text)
            let sendCount += 1
        endfor
    endfor
    return sendCount
endfunction

" groupJobStatus : {
"   'jobId' : '',
"   'jobOption' : {},
"   'jobOutput' : [],
"   'exitCode' : 'ensured string type, empty if running, not empty when job finished',
"   'jobStatusFailed' : {},
"   'jobIndex' : 0,
"   'jobStatusList' : [[{jobStatus}], [{jobStatus}, {jobStatus}]],
"   'jobImplData' : {},
" }
" child jobStatus jobImplData: {
"   'groupJobId' : '',
"   'groupJobChildState' : '1: running, 0: successFinished, -1: failed',
"   'groupJobChildIndex' : 0,
"   'groupJobChildSubIndex' : 0,
" }
function! ZFGroupJobStatus(groupJobId)
    return get(s:groupJobMap, a:groupJobId, {})
endfunction

function! ZFGroupJobTaskMap()
    return s:groupJobMap
endfunction

function! ZFGroupJobInfo(groupJobStatus)
    if !exists("a:groupJobStatus['jobOption']['jobList']")
        return ZFGroupJobChildImpl()['jobInfo'](a:groupJobStatus)
    endif
    let jobStatusList = a:groupJobStatus['jobStatusList']
    if !empty(jobStatusList)
        let index = len(jobStatusList) - 1
        while index != -1
            if !empty(jobStatusList[index])
                return ZFGroupJobChildImpl()['jobInfo'](jobStatusList[index][-1])
            endif
            let index -= 1
        endwhile
    endif
    let jobList = a:groupJobStatus['jobOption']['jobList']
    if !empty(jobList) && !empty(jobList[0])
        return ZFGroupJobChildImpl()['jobInfo'](jobList[0][0])
    endif
    return ''
endfunction

function! ZFGroupJobLog(groupJobIdOrGroupJobStatus, log)
    if type(a:groupJobIdOrGroupJobStatus) == type({})
        let groupJobStatus = a:groupJobIdOrGroupJobStatus
    else
        let groupJobStatus = ZFGroupJobStatus(a:groupJobIdOrGroupJobStatus)
    endif
    if !empty(groupJobStatus)
        call s:groupJobLog(groupJobStatus, a:log)
    endif
endfunction

" ============================================================
if !exists('s:groupJobIdCur')
    let s:groupJobIdCur = 0
endif
if !exists('s:groupJobMap')
    let s:groupJobMap = {}
endif

function! s:groupJobIdNext()
    while 1
        let s:groupJobIdCur += 1
        if s:groupJobIdCur <= 0
            let s:groupJobIdCur = 1
        endif
        if exists('s:groupJobMap[s:groupJobIdCur]')
            continue
        endif
        return s:groupJobIdCur
    endwhile
endfunction

function! s:groupJobRemove(groupJobId)
    if exists('s:groupJobMap[a:groupJobId]')
        return remove(s:groupJobMap, a:groupJobId)
    else
        return {}
    endif
endfunction

if exists('*strftime')
    function! s:groupJobLogFormat(groupJobStatus, log)
        return strftime('%H:%M:%S') . ' groupJob ' . a:groupJobStatus['jobId'] . ' ' . a:log
    endfunction
else
    function! s:groupJobLogFormat(groupJobStatus, log)
        return 'groupJob ' . a:groupJobStatus['jobId'] . ' ' . a:log
    endfunction
endif
function! s:groupJobLog(groupJobStatus, log)
    let Fn_onLog = get(a:groupJobStatus['jobOption'], 'onLog', '')
    if g:ZFJobVerboseLogEnable || !empty(Fn_onLog)
        let log = s:groupJobLogFormat(a:groupJobStatus, a:log)
        if g:ZFJobVerboseLogEnable
            call add(g:ZFJobVerboseLog, log)
        endif
        call ZFJobFuncCall(Fn_onLog, [a:groupJobStatus, log])
    endif
endfunction

augroup ZFVimJob_ZFGroupJobOptionSetup_augroup
    autocmd!
    autocmd User ZFGroupJobOptionSetup silent
augroup END
function! s:groupJobStart(param)
    if type(a:param) == type('') || ZFJobFuncCallable(a:param)
        let groupJobOption = {
                    \   'jobCmd' : a:param,
                    \ }
    elseif type(a:param) == type({})
        let groupJobOption = copy(a:param)
    else
        echomsg '[ZFVimJob] unsupported param type: ' . type(a:param)
        return -1
    endif

    if empty(get(groupJobOption, 'jobList', []))
        if empty(get(groupJobOption, 'jobCmd', ''))
            return -1
        else
            let groupJobOption['jobList'] = [[{
                        \   'jobCmd' : groupJobOption['jobCmd']
                        \ }]]
            unlet groupJobOption['jobCmd']
        endif
    else
        let jobIndex = len(groupJobOption['jobList']) - 1
        while jobIndex >= 0
            if type(groupJobOption['jobList'][jobIndex]) != type([])
                let groupJobOption['jobList'][jobIndex] = [groupJobOption['jobList'][jobIndex]]
            endif
            let jobIndex -= 1
        endwhile
    endif

    let g:ZFGroupJobOptionSetup = groupJobOption
    doautocmd User ZFGroupJobOptionSetup
    unlet g:ZFGroupJobOptionSetup

    let groupJobId = s:groupJobIdNext()
    let groupJobStatus = {
                \   'jobId' : groupJobId,
                \   'jobOption' : groupJobOption,
                \   'jobOutput' : [],
                \   'exitCode' : '',
                \   'jobStatusFailed' : {},
                \   'jobIndex' : -1,
                \   'jobStatusList' : [],
                \   'jobImplData' : copy(get(groupJobOption, 'jobImplData', {})),
                \ }
    let groupJobStatus['jobImplData']['groupJobRunning'] = 1
    let jobStatusList = groupJobStatus['jobStatusList']
    for i in range(len(groupJobOption['jobList']))
        call add(jobStatusList, [])
    endfor
    let s:groupJobMap[groupJobId] = groupJobStatus

    call s:groupJobLog(groupJobStatus, 'start')

    call ZFJobFuncCall(get(groupJobStatus['jobOption'], 'onEnter', ''), [groupJobStatus])
    call s:groupJobRunNext(groupJobStatus)
    if groupJobStatus['jobId'] <= 0
        return groupJobStatus['jobId']
    endif

    if get(groupJobOption, 'groupJobTimeout', 0) > 0 && ZFJobTimerAvailable()
        let groupJobStatus['jobImplData']['groupJobTimeoutId'] = ZFJobTimerStart(
                    \ groupJobOption['groupJobTimeout'],
                    \ ZFJobFunc(function('ZFGroupJobImpl_onTimeout'), [groupJobStatus]))
    endif

    return groupJobId
endfunction

" change groupJobStatus['jobId'] to:
"   0 : if all child finished
"   -1 : failed or child failed
"   not modified : wait for child finish
function! s:groupJobRunNext(groupJobStatus)
    let a:groupJobStatus['jobIndex'] += 1
    let jobIndex = a:groupJobStatus['jobIndex']
    if jobIndex >= len(a:groupJobStatus['jobOption']['jobList'])
        call s:groupJobStop(a:groupJobStatus, {}, '0')
        let a:groupJobStatus['jobId'] = 0
        return
    endif
    let jobList = a:groupJobStatus['jobOption']['jobList'][jobIndex]
    if empty(jobList)
        call s:groupJobRunNext(a:groupJobStatus)
        return
    endif

    call s:groupJobLog(a:groupJobStatus, 'running group ' . jobIndex)
    let jobStatusList = a:groupJobStatus['jobStatusList'][jobIndex]

    let jobOptionDefault = {}
    if !empty(get(a:groupJobStatus['jobOption'], 'jobCwd', ''))
        let jobOptionDefault['jobCwd'] = a:groupJobStatus['jobOption']['jobCwd']
    endif
    if !empty(get(a:groupJobStatus['jobOption'], 'jobEncoding', ''))
        let jobOptionDefault['jobEncoding'] = a:groupJobStatus['jobOption']['jobEncoding']
    endif
    if !empty(get(a:groupJobStatus['jobOption'], 'jobTimeout', ''))
        let jobOptionDefault['jobTimeout'] = a:groupJobStatus['jobOption']['jobTimeout']
    endif
    if !empty(get(a:groupJobStatus['jobOption'], 'jobFallback', ''))
        let jobOptionDefault['jobFallback'] = a:groupJobStatus['jobOption']['jobFallback']
    endif

    for jobOption in jobList
        let jobOptionTmp = extend(extend(copy(jobOptionDefault), jobOption), {
                    \   'onLog' : ZFJobFunc(function('ZFGroupJobImpl_onJobLog'), [a:groupJobStatus, get(jobOption, 'onLog', '')]),
                    \   'onOutput' : ZFJobFunc(function('ZFGroupJobImpl_onJobOutput'), [a:groupJobStatus, get(jobOption, 'onOutput', '')]),
                    \   'onExit' : ZFJobFunc(function('ZFGroupJobImpl_onJobExit'), [a:groupJobStatus, get(jobOption, 'onExit', '')]),
                    \ })
        if !exists("jobOptionTmp['jobImplData']")
            let jobOptionTmp['jobImplData'] = {}
        endif
        let jobOptionTmp['jobImplData']['groupJobId'] = a:groupJobStatus['jobId']
        let jobOptionTmp['jobImplData']['groupJobChildState'] = 1
        let jobOptionTmp['jobImplData']['groupJobChildIndex'] = jobIndex
        let jobOptionTmp['jobImplData']['groupJobChildSubIndex'] = len(jobStatusList)
        if !exists("jobOptionTmp['jobOutputCRFix']") && exists("a:groupJobStatus['jobOption']['jobOutputCRFix']")
            let jobOptionTmp['jobOutputCRFix'] = a:groupJobStatus['jobOption']['jobOutputCRFix']
        endif

        if exists("jobOptionTmp['jobList']")
            let jobId = ZFGroupJobStart(jobOptionTmp)
            if jobId == 0
                continue
            endif
            let jobStatus = ZFGroupJobStatus(jobId)
            if empty(jobStatus)
                call s:groupJobStop(a:groupJobStatus, {}, '-1')
                return
            endif
        else
            let jobId = ZFGroupJobChildImpl()['jobStart'](jobOptionTmp)
            if jobId == 0
                continue
            endif
            let jobStatus = ZFGroupJobChildImpl()['jobStatus'](jobId)
            if empty(jobStatus)
                call s:groupJobStop(a:groupJobStatus, {}, '-1')
                return
            endif
        endif

        call add(jobStatusList, jobStatus)
    endfor
endfunction

function! s:groupJobRunNextDelayed(groupJobStatus)
    if get(a:groupJobStatus['jobImplData'], 'groupJobRunNextDelayedId', -1) != -1
        return
    endif
    if a:groupJobStatus['jobIndex'] + 1 >= len(a:groupJobStatus['jobOption']['jobList'])
        call s:groupJobStop(a:groupJobStatus, {}, '0')
        let a:groupJobStatus['jobId'] = 0
        return
    endif

    let a:groupJobStatus['jobImplData']['groupJobRunNextDelayedId'] = ZFJobTimerStart(
                \   0,
                \   ZFJobFunc(function('ZFGroupJobImpl_groupJobRunNextDelayedAction'), [a:groupJobStatus])
                \ )
endfunction
function! ZFGroupJobImpl_groupJobRunNextDelayedAction(groupJobStatus, ...)
    let a:groupJobStatus['jobImplData']['groupJobRunNextDelayedId'] = -1
    call s:groupJobRunNext(a:groupJobStatus)
endfunction

function! s:groupJobStop(groupJobStatus, jobStatusFailed, exitCode)
    if empty(a:groupJobStatus)
        return 0
    endif

    if get(a:groupJobStatus['jobImplData'], 'groupJobRunNextDelayedId', -1) != -1
        call ZFJobTimerStop(a:groupJobStatus['jobImplData']['groupJobRunNextDelayedId'])
        let a:groupJobStatus['jobImplData']['groupJobRunNextDelayedId'] = -1
    endif

    call s:groupJobLog(a:groupJobStatus, 'stop [' . a:exitCode . ']')

    let groupJobStatus = s:groupJobRemove(a:groupJobStatus['jobId'])
    if empty(groupJobStatus)
        return 0
    endif

    let groupJobTimeoutId = get(groupJobStatus['jobImplData'], 'groupJobTimeoutId', -1)
    if groupJobTimeoutId != -1
        call ZFJobTimerStop(groupJobTimeoutId)
        unlet groupJobStatus['jobImplData']['groupJobTimeoutId']
    endif

    let groupJobStatus['jobImplData']['groupJobRunning'] = 0
    for jobStatusList in groupJobStatus['jobStatusList']
        for jobStatus in jobStatusList
            if jobStatus['jobImplData']['groupJobChildState'] == 1
                let jobStatus['jobImplData']['groupJobChildState'] = -1
                call ZFGroupJobChildImpl()['jobStop'](jobStatus['jobId'], a:exitCode)
            endif
        endfor
    endfor

    let groupJobStatus['exitCode'] = a:exitCode
    let groupJobStatus['jobStatusFailed'] = a:jobStatusFailed
    call ZFJobFuncCall(get(groupJobStatus['jobOption'], 'onExit', ''), [groupJobStatus, a:exitCode])
    call ZFJobOutputCleanup(a:groupJobStatus)

    let groupJobStatus['jobId'] = -1
    return 1
endfunction

function! ZFGroupJobImpl_onJobLog(groupJobStatus, onLog, jobStatus, log)
    if !a:groupJobStatus['jobImplData']['groupJobRunning']
        return
    endif

    call s:groupJobLog(a:groupJobStatus, a:log)

    call ZFJobFuncCall(a:onLog, [a:jobStatus, a:log])
    call ZFJobFuncCall(get(a:groupJobStatus['jobOption'], 'onJobLog', ''), [a:groupJobStatus, a:jobStatus, a:log])
endfunction

function! ZFGroupJobImpl_onJobOutput(groupJobStatus, onOutput, jobStatus, textList, type)
    if !a:groupJobStatus['jobImplData']['groupJobRunning']
        return
    endif

    if !empty(get(a:groupJobStatus['jobOption'], 'onOutputFilter', ''))
        call ZFJobFuncCall(a:groupJobStatus['jobOption']['onOutputFilter'], [a:groupJobStatus, a:textList, a:type])
        if empty(a:textList)
            return
        endif
    endif

    call extend(a:groupJobStatus['jobOutput'], a:textList)
    let jobOutputLimit = get(a:groupJobStatus['jobOption'], 'jobOutputLimit', g:ZFJobOutputLimit)
    if jobOutputLimit >= 0 && len(a:groupJobStatus['jobOutput']) > jobOutputLimit
        call remove(a:groupJobStatus['jobOutput'], 0, len(a:groupJobStatus['jobOutput']) - jobOutputLimit - 1)
    endif

    call ZFJobFuncCall(a:onOutput, [a:jobStatus, a:textList, a:type])
    call ZFJobFuncCall(get(a:groupJobStatus['jobOption'], 'onJobOutput', ''), [a:groupJobStatus, a:jobStatus, a:textList, a:type])
    call ZFJobFuncCall(get(a:groupJobStatus['jobOption'], 'onOutput', ''), [a:groupJobStatus, a:textList, a:type])
    call ZFJobOutput(a:groupJobStatus, a:textList, a:type)
endfunction

function! ZFGroupJobImpl_onJobExit(groupJobStatus, onExit, jobStatus, exitCode)
    let childError = a:exitCode != '0' && get(a:groupJobStatus['jobOption'], 'groupJobStopOnChildError', 1)

    if a:jobStatus['jobImplData']['groupJobChildState'] == 1
        if childError
            let a:jobStatus['jobImplData']['groupJobChildState'] = -1
        else
            let a:jobStatus['jobImplData']['groupJobChildState'] = 0
        endif
    endif

    call ZFJobFuncCall(a:onExit, [a:jobStatus, a:exitCode])
    call ZFJobFuncCall(get(a:groupJobStatus['jobOption'], 'onJobExit', ''), [a:groupJobStatus, a:jobStatus, a:exitCode])

    if !a:groupJobStatus['jobImplData']['groupJobRunning']
        return
    endif

    if childError
        call s:groupJobLog(a:groupJobStatus, printf('stop by child job error: %s, job: %s'
                    \   , a:exitCode
                    \   , ZFGroupJobInfo(a:jobStatus)
                    \ ))
        call s:groupJobStop(a:groupJobStatus, a:jobStatus, g:ZFJOBSTOP)
        return
    endif

    let jobIndex = a:groupJobStatus['jobIndex']
    let jobStatusList = a:groupJobStatus['jobStatusList'][jobIndex]
    if a:jobStatus['jobId'] == 0
        call add(jobStatusList, a:jobStatus)
    endif

    if len(jobStatusList) < len(a:groupJobStatus['jobOption']['jobList'][jobIndex])
        return
    endif

    for jobStatus in jobStatusList
        if jobStatus['jobImplData']['groupJobChildState'] != 0
            return
        endif
    endfor

    if ZFJobTimerAvailable()
        call s:groupJobRunNextDelayed(a:groupJobStatus)
    else
        call s:groupJobRunNext(a:groupJobStatus)
    endif
endfunction

function! ZFGroupJobImpl_onTimeout(groupJobStatus, ...)
    call ZFGroupJobStop(a:groupJobStatus['jobId'], g:ZFJOBTIMEOUT)
endfunction

