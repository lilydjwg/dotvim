
if has('timers') || !get(g:, 'ZFJobTimerFallback', 1)
    finish
endif

if !exists('g:ZFJobTimerFallbackInterval')
    let g:ZFJobTimerFallbackInterval = 50
endif

function! ZFJobTimerFallbackStart(delay, jobFunc)
    while 1
        let s:timerIdCur += 1
        if s:timerIdCur <= 0
            let s:timerIdCur = 1
        endif
        if !exists("s:taskMap[s:timerIdCur]")
            break
        endif
    endwhile
    let s:taskMap[s:timerIdCur] = {
                \   'delay' : a:delay,
                \   'jobFunc' : a:jobFunc,
                \ }
    if len(s:taskMap) == 1
        call s:implStart()
    endif
    return s:timerIdCur
endfunction

function! ZFJobTimerFallbackStop(timerId)
    let taskData = get(s:taskMap, a:timerId, {})
    if empty(taskData)
        return
    endif
    unlet s:taskMap[a:timerId]
    if empty(s:taskMap)
        call s:implStop()
    endif
endfunction

" {
"   'timerId' : { // timerId ensured > 0
"     'delay' : N, // dec offset time for each impl interval, when reached to 0, invoke the jobFunc
"     'jobFunc' : {...},
"   },
" }
if !exists('s:taskMap')
    let s:taskMap = {}
endif
if !exists('s:timerIdCur')
    let s:timerIdCur = 0
endif
if !exists('s:updatetimeSaved')
    let s:updatetimeSaved = -1
endif

function! s:implStart()
    if s:updatetimeSaved != -1
        return
    endif
    let s:updatetimeSaved = &updatetime
    let &updatetime = g:ZFJobTimerFallbackInterval
    let s:lastTime = reltime()
    augroup ZFJobTimerFallback_augroup
        autocmd!
        autocmd CursorHold,CursorHoldI * call s:implCallback()
    augroup END
endfunction

function! s:implStop()
    if s:updatetimeSaved == -1
        return
    endif
    augroup ZFJobTimerFallback_augroup
        autocmd!
    augroup END
    let &updatetime = s:updatetimeSaved
    let s:updatetimeSaved = -1
endfunction

function! s:implCallback()
    let offset = float2nr(str2float(reltimestr(reltime(s:lastTime))) * 1000)
    let s:lastTime = reltime()

    let toInvokeList = []
    for timerId in keys(s:taskMap)
        let taskData = s:taskMap[timerId]
        let taskData['delay'] -= offset
        if taskData['delay'] <= 0
            unlet s:taskMap[timerId]
            call add(toInvokeList, [timerId, taskData])
        endif
    endfor
    for toInvoke in toInvokeList
        call ZFJobFuncCall(toInvoke[1]['jobFunc'], [toInvoke[0]])
    endfor
    if empty(s:taskMap)
        call s:implStop()
        return
    endif

    call s:implPostUpdate()
endfunction

function! s:implPostUpdate()
    if (mode() != 'n' && mode() != 'i')
                \ || getpos('.')[0] <= 0
        return
    endif
    if line('.') > 1
        call feedkeys("\<up>\<down>", 'nt')
    else
        call feedkeys("\<down>\<up>", 'nt')
    endif
endfunction

let g:ZFJobTimerImpl = {
            \   'timerStart' : function('ZFJobTimerFallbackStart'),
            \   'timerStop' : function('ZFJobTimerFallbackStop'),
            \ }

