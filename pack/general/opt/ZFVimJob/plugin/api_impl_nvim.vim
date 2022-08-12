if !exists('*jobstart')
    finish
endif
if !empty(get(g:, 'ZFJobImpl', {}))
    finish
endif

" {
"   'jobImplId' : {
"     'onOutput' : '',
"     'onExit' : '',
"     'stdoutFix' : [],
"     'stderrFix' : [],
"   }
" }
if !exists('s:jobImplStateMap')
    let s:jobImplStateMap = {}
endif

function! s:jobStart(jobStatus, onOutput, onExit)
    let jobImplOption = {
                \   'on_stdout' : function('s:nvim_on_stdout'),
                \   'on_stderr' : function('s:nvim_on_stderr'),
                \   'on_exit' : function('s:nvim_on_exit'),
                \ }
    if !empty(get(a:jobStatus['jobOption'], 'jobCwd', ''))
        let jobImplOption['cwd'] = a:jobStatus['jobOption']['jobCwd']
    endif

    try
        let jobImplId = jobstart(a:jobStatus['jobOption']['jobCmd'], jobImplOption)
    catch
        let jobImplId = -1
    endtry
    if jobImplId == 0 || jobImplId == -1
        return 0
    endif
    let a:jobStatus['jobImplData']['jobImplId'] = jobImplId
    let s:jobImplStateMap[jobImplId] = {
                \   'onOutput' : a:onOutput,
                \   'onExit' : a:onExit,
                \   'stdoutFix' : [],
                \   'stderrFix' : [],
                \ }
    return 1
endfunction

function! s:jobStop(jobStatus)
    let jobImplId = a:jobStatus['jobImplData']['jobImplId']
    if exists('s:jobImplStateMap[jobImplId]')
        call remove(s:jobImplStateMap, jobImplId)
    endif
    call jobstop(jobImplId)
    return 1
endfunction

function! s:jobSend(jobStatus, text)
    call chansend(a:jobStatus['jobImplData']['jobImplId'], a:text)
    return 1
endfunction

function! s:nvim_on_stdout(jobImplId, msgList, ...)
    call s:nvim_outputFix(a:jobImplId, a:msgList, 'stdout')
endfunction
function! s:nvim_on_stderr(jobImplId, msgList, ...)
    call s:nvim_outputFix(a:jobImplId, a:msgList, 'stderr')
endfunction
function! s:nvim_on_exit(jobImplId, exitCode, ...)
    if !exists('s:jobImplStateMap[a:jobImplId]')
        return
    endif
    let jobImplState = remove(s:jobImplStateMap, a:jobImplId)
    call ZFJobFuncCall(jobImplState['onExit'], ['' . a:exitCode])
endfunction

let g:ZFJobImpl = {
            \   'jobStart' : function('s:jobStart'),
            \   'jobStop' : function('s:jobStop'),
            \   'jobSend' : function('s:jobSend'),
            \ }

" ============================================================
" output end:
"   ['aaa', 'bbb', '']
" output truncated:
"   ['aaa', 'bb']
"   ['b', '']
" output truncated:
"   ['aaa', 'bb']
"   ['']
" dummy end, no need to output:
"   ['']
function! s:nvim_outputFix(jobImplId, msgList, type)
    let jobImplState = get(s:jobImplStateMap, a:jobImplId, {})
    if empty(jobImplState)
        return
    endif

    if a:type == 'stdout'
        let fixKey = 'stdoutFix'
    else
        let fixKey = 'stderrFix'
    endif

    if !empty(jobImplState[fixKey])
                \ && jobImplState[fixKey][-1] != ''
                \ && !empty(a:msgList)
                \ && a:msgList[0] != ''
        let jobImplState[fixKey][-1] = jobImplState[fixKey][-1] . a:msgList[0]
        call extend(jobImplState[fixKey], a:msgList[1:-1])
    else
        call extend(jobImplState[fixKey], a:msgList)
    endif

    if !empty(jobImplState[fixKey]) && jobImplState[fixKey][-1] == ''
        let msgList = jobImplState[fixKey]
        let jobImplState[fixKey] = []
        call remove(msgList, -1)
        if empty(msgList)
            return
        endif
    else
        return
    endif

    call ZFJobFuncCall(jobImplState['onOutput'], [msgList, a:type])
endfunction

