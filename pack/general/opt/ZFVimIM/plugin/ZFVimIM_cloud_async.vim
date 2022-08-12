
" ============================================================
" <= 0 : disable
" 1 : upload immediately
" > 1 : delay miliseconds and upload
if !exists('g:ZFVimIM_cloudAsync_enable')
    let g:ZFVimIM_cloudAsync_enable=30000
endif
if !exists('g:ZFVimIM_cloudAsync_timeout')
    let g:ZFVimIM_cloudAsync_timeout=60000
endif
if !exists('g:ZFVimIM_cloudAsync_autoCleanup')
    let g:ZFVimIM_cloudAsync_autoCleanup=30
endif
if !exists('g:ZFVimIM_cloudAsync_autoCleanup_timeout')
    let g:ZFVimIM_cloudAsync_autoCleanup_timeout=g:ZFVimIM_cloudAsync_timeout
endif
if !exists('g:ZFVimIM_cloudAsync_autoInit')
    let g:ZFVimIM_cloudAsync_autoInit=(g:ZFVimIM_cloudAsync_enable > 0)
endif
if !exists('g:ZFVimIM_cloudAsync_outputTo')
    let g:ZFVimIM_cloudAsync_outputTo = {
                \   'outputType' : 'statusline',
                \   'outputId' : 'ZFVimIM_cloud_async',
                \ }
endif


" ============================================================
function! ZFVimIM_cloudAsyncAvailable()
    if !exists('s:uploadAsyncAvailableCache')
        let s:uploadAsyncAvailableCache = exists('*ZFJobAvailable') && ZFJobAvailable()
    endif
    return s:uploadAsyncAvailableCache
endfunction


function! ZFVimIM_initAsync(cloudOption)
    call s:initAsync(a:cloudOption)
endfunction


function! ZFVimIM_downloadAsync(cloudOption)
    call s:uploadAsync(a:cloudOption, 'download')
endfunction
function! ZFVimIM_downloadAllAsync()
    call ZFVimIM_downloadAllAsyncCancel()
    for cloudOption in g:ZFVimIM_cloudOption
        call ZFVimIM_downloadAsync(cloudOption)
    endfor
endfunction
function! ZFVimIM_downloadAllAsyncCancel()
    call s:UA_cancel()
endfunction


function! ZFVimIM_uploadAsync(cloudOption)
    call s:uploadAsync(a:cloudOption, 'upload')
endfunction
function! ZFVimIM_uploadAllAsync()
    for cloudOption in g:ZFVimIM_cloudOption
        call s:uploadAsync(cloudOption, 'upload')
    endfor
endfunction
function! ZFVimIM_uploadAllAsyncCancel()
    call s:UA_cancel()
endfunction


" ============================================================
augroup ZFVimIM_cloud_async_augroup
    autocmd!
    autocmd User ZFVimIM_event_OnUpdateDb
                \  if g:ZFVimIM_cloudAsync_enable > 0 && ZFVimIM_cloudAsyncAvailable()
                \|     call s:autoUploadAsync()
                \| endif
    autocmd VimEnter * call s:UA_autoInit()
augroup END

" ============================================================
" {
"   'dbId' : {
"     'mode' : 'init/download/upload/autoUpload',
"     'cloudOption' : {},
"     'jobId' : -1,
"     'cachePath' : '',
"     'dbMapNew' : {}, // if update success, change cur db to this
"     'dbEdit' : [], // dbEdit being uploading
"   },
" }
let s:UA_taskMap = {}

function! s:UA_autoInit()
    if g:ZFVimIM_cloudAsync_autoInit
                \ && ZFVimIM_cloudAsyncAvailable()
                \ && !ZFVimIM_cloud_isFallback()
        let cloudInitMode = get(g:, 'ZFVimIM_cloudInitMode', '')
        let g:ZFVimIM_cloudInitMode = 'forceAsync'
        call ZFVimIME_init()
        let g:ZFVimIM_cloudInitMode = cloudInitMode
    endif
endfunction
function! s:UA_cancel()
    call s:autoUploadAsyncCancel()
    let taskMap = s:UA_taskMap
    for task in values(taskMap)
        if task['jobId'] > 0
            call ZFGroupJobStop(task['jobId'])
        endif
    endfor
endfunction

let s:autoUploadAsyncRetryTimeInc = 1
let s:autoUploadAsyncDelayTimerId = -1
function! s:autoUploadAsync()
    if g:ZFVimIM_cloudAsync_enable <= 0
        return
    endif
    if !has('timers')
                \ || (g:ZFVimIM_cloudAsync_enable * s:autoUploadAsyncRetryTimeInc) == 1
        call s:autoUploadAsyncAction()
        return
    endif
    if s:autoUploadAsyncDelayTimerId != -1
        call timer_stop(s:autoUploadAsyncDelayTimerId)
    endif
    let s:autoUploadAsyncDelayTimerId = timer_start(g:ZFVimIM_cloudAsync_enable * s:autoUploadAsyncRetryTimeInc, function('s:autoUploadAsync_timeout'))
endfunction
function! s:autoUploadAsyncCancel()
    if s:autoUploadAsyncDelayTimerId != -1
        call timer_stop(s:autoUploadAsyncDelayTimerId)
        let s:autoUploadAsyncDelayTimerId = -1
    endif
    let taskMap = s:UA_taskMap
    for dbId in keys(taskMap)
        let task = taskMap[dbId]
        if task['jobId'] != -1
            call ZFGroupJobStop(task['jobId'])
        endif
    endfor
endfunction
function! s:autoUploadAsync_timeout(...)
    let s:autoUploadAsyncDelayTimerId = -1
    call s:autoUploadAsyncAction()
endfunction
function! s:autoUploadAsyncAction()
    for cloudOption in g:ZFVimIM_cloudOption
        call s:uploadAsync(cloudOption, 'autoUpload')
    endfor
endfunction


function! s:cloudAsyncLog(groupJobStatus, msg)
    call ZFVimIM_cloudLogAdd(a:msg)
    if !empty(a:groupJobStatus)
        call ZFJobOutput(a:groupJobStatus, a:msg)
    endif
endfunction


function! s:UA_gitInfoPrepare(cloudOption, downloadOnly)
    if !isdirectory(get(a:cloudOption, 'repoPath', ''))
        redraw!
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'invalid repoPath: ' . get(a:cloudOption, 'repoPath', ''))
        return 0
    endif
    if filewritable(ZFVimIM_cloud_file(a:cloudOption, 'dbFile')) != 1
        redraw!
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'invalid dbFile: ' . ZFVimIM_cloud_file(a:cloudOption, 'dbFile'))
        return 0
    endif
    if a:downloadOnly
        return 1
    endif
    if empty(a:cloudOption['gitUserEmail'])
        redraw!
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'missing gitUserEmail')
        return 0
    endif
    if empty(a:cloudOption['gitUserName'])
        redraw!
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'missing gitUserName')
        return 0
    endif
    if empty(a:cloudOption['gitUserToken'])
        redraw!
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'missing gitUserToken')
        return 0
    endif
    return 1
endfunction

function! s:initAsync(cloudOption)
    call s:uploadAsync(a:cloudOption, 'init')
endfunction

" mode:
" * init
" * download
" * upload
" * autoUpload
function! s:uploadAsync(cloudOption, mode)
    let dbId = a:cloudOption['dbId']
    let db = ZFVimIM_dbForId(dbId)
    if exists('s:UA_taskMap[dbId]') || empty(db)
        return
    endif

    call ZFVimIM_cloudLogClear()

    let applyOnly = (get(a:cloudOption, 'mode', '') == 'local')
    let downloadOnly = (a:mode == 'download')
    let initOnly = (a:mode == 'init') || !executable('git')
    let askIfNoGitInfo = (a:mode == 'upload')

    if !initOnly && !downloadOnly && !empty(db['dbMap']) && empty(db['dbEdit'])
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'canceled: nothing to upload')
        return
    endif
    if !ZFVimIM_cloudAsyncAvailable()
        call s:cloudAsyncLog({}, ZFVimIM_cloud_logInfo(a:cloudOption) . 'canceled: async mode not available')
        return
    endif
    if !initOnly && !applyOnly && !s:UA_gitInfoPrepare(a:cloudOption, downloadOnly)
        if askIfNoGitInfo
            call ZFVimIM_uploadSync(a:cloudOption)
        endif
        return
    endif

    let task = {
                \   'mode' : a:mode,
                \   'cloudOption' : a:cloudOption,
                \   'jobId' : -1,
                \   'cachePath' : ZFVimIM_cloud_cachePath(a:cloudOption),
                \   'dbMapNew' : {},
                \   'dbEdit' : [],
                \ }
    call mkdir(task['cachePath'], 'p')
    let s:UA_taskMap[db['dbId']] = task
    let task['dbEdit'] = db['dbEdit']
    let db['dbEdit'] = []

    let groupJobOption = {
                \   'jobList' : [],
                \   'onExit' : ZFJobFunc(function('s:UA_onExit'), [db['dbId']]),
                \   'jobTimeout' : g:ZFVimIM_cloudAsync_timeout,
                \   'outputTo' : g:ZFVimIM_cloudAsync_outputTo,
                \ }

    " download and load to vim
    if !initOnly && !applyOnly
        call add(groupJobOption['jobList'], [{
                    \   'jobCmd' : ZFVimIM_cloud_dbDownloadCmd(a:cloudOption),
                    \   'onOutputFilter' : function('ZFVimIM_cloudLog_stripSensitiveForJob'),
                    \   'onOutput' : ZFJobFunc(function('s:UA_dbDownloadOnOutput'), [db['dbId']]),
                    \ }])
    endif
    " for performance, we only load if db is empty
    if empty(db['dbMap'])
        let dbLoadCmd = ZFVimIM_cloud_dbLoadCmd(a:cloudOption, task['cachePath'] . '/dbLoadCache')
        if empty(dbLoadCmd)
            if initOnly
                " load without python takes a long time,
                " do not load during init
                return
            endif
            call add(groupJobOption['jobList'], [{
                        \   'jobCmd' : ZFJobFunc(function('s:UA_dbLoadFallback'), [db['dbId']]),
                        \ }])
        else
            call add(groupJobOption['jobList'], [{
                        \   'jobCmd' : dbLoadCmd,
                        \   'onEnter' : ZFJobFunc(function('s:UA_dbLoadOnEnter'), [db['dbId']]),
                        \   'onExit' : ZFJobFunc(function('s:UA_dbLoadOnExit'), [db['dbId']]),
                        \   'onOutput' : ZFJobFunc(function('s:UA_dbLoadOnOutput'), [db['dbId']]),
                        \ }])
            let dbLoadPartTasks = []
            for c_ in range(char2nr('a'), char2nr('z'))
                let c = nr2char(c_)
                call add(dbLoadPartTasks, {
                            \   'jobCmd' : 10,
                            \   'onOutputFilter' : function('s:UA_dbLoadPartOnOutputFilter'),
                            \   'onExit' : ZFJobFunc(function('s:UA_dbLoadPartOnExit'), [db['dbId'], c]),
                            \ })
            endfor
            call add(groupJobOption['jobList'], dbLoadPartTasks)
        endif
    endif

    " save to file and upload
    if !initOnly && !downloadOnly && !empty(task['dbEdit'])
        let dbSaveCmd = ZFVimIM_cloud_dbSaveCmd(a:cloudOption, task['cachePath'] . '/dbSaveCache', task['cachePath'])
        if empty(dbSaveCmd)
            call add(groupJobOption['jobList'], [{
                        \   'jobCmd' : ZFJobFunc(function('s:UA_dbSaveFallback'), [db['dbId']]),
                        \ }])
        else
            call add(groupJobOption['jobList'], [{
                        \   'jobCmd' : dbSaveCmd,
                        \   'onEnter' : ZFJobFunc(function('s:UA_dbSaveOnEnter'), [db['dbId']]),
                        \   'onOutput' : ZFJobFunc(function('s:UA_dbSaveOnOutput'), [db['dbId']]),
                        \ }])
        endif

        if !applyOnly
            call add(groupJobOption['jobList'], [{
                        \   'jobCmd' : ZFVimIM_cloud_dbUploadCmd(a:cloudOption),
                        \   'onEnter' : ZFJobFunc(function('s:UA_dbUploadOnEnter'), [db['dbId']]),
                        \   'onOutputFilter' : function('ZFVimIM_cloudLog_stripSensitiveForJob'),
                        \   'onOutput' : ZFJobFunc(function('s:UA_dbUploadOnOutput'), [db['dbId']]),
                        \ }])

            if g:ZFVimIM_cloudAsync_autoCleanup > 0 && ZFVimIM_cloud_gitInfoSupplied(a:cloudOption)
                let dbCleanupCmd = ZFVimIM_cloud_dbCleanupCmd(a:cloudOption, task['cachePath'] . '/dbCleanupCache')
                if !empty(dbCleanupCmd)
                    call add(groupJobOption['jobList'], [{
                                \   'jobCmd' : ZFVimIM_cloud_dbCleanupCheckCmd(a:cloudOption),
                                \   'onOutput' : ZFJobFunc(function('s:UA_dbCleanupCheckOnOutput'), [db['dbId']]),
                                \ }])

                    if get(db['implData'], '_dbCleanupHistory', 0) >= g:ZFVimIM_cloudAsync_autoCleanup
                        call add(groupJobOption['jobList'], [{
                                    \   'jobCmd' : dbCleanupCmd,
                                    \   'onOutputFilter' : function('ZFVimIM_cloudLog_stripSensitiveForJob'),
                                    \   'onOutput' : ZFJobFunc(function('s:UA_dbCleanupOnOutput'), [db['dbId']]),
                                    \ }])
                        let groupJobOption['jobTimeout'] += g:ZFVimIM_cloudAsync_autoCleanup_timeout
                    endif
                endif
            endif
        endif
    endif

    call s:cloudAsyncLog(ZFGroupJobStatus(task['jobId']), ZFVimIM_cloud_logInfo(a:cloudOption) . 'updating...')
    let task['jobId'] = ZFGroupJobStart(groupJobOption)
    if task['jobId'] == -1
        if exists("s:UA_taskMap[db['dbId']]")
            unlet s:UA_taskMap[db['dbId']]
        endif
        return
    endif
endfunction

function! s:UA_dbDownloadOnOutput(dbId, jobStatus, textList, type)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    for text in a:textList
        call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'updating : ' . text)
    endfor
endfunction

function! s:UA_dbLoadFallback(dbId, jobStatus)
    let task = get(s:UA_taskMap, a:dbId, {})
    let db = ZFVimIM_dbForId(a:dbId)
    if empty(task) || empty(db)
        return {
                    \   'output' : 'error',
                    \   'exitCode' : '-1',
                    \ }
    endif
    call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'loading (fallback)...')

    let dbFile = ZFVimIM_cloud_file(task['cloudOption'], 'dbFile')
    let dbCountFile = ZFVimIM_cloud_file(task['cloudOption'], 'dbCountFile')
    call extend(task['dbEdit'], db['dbEdit'])
    call ZFVimIM_dbLoad(db, dbFile, dbCountFile)
    call ZFVimIM_dbEditApply(db, task['dbEdit'])

    return {
                \   'output' : '',
                \   'exitCode' : '0',
                \ }
endfunction

function! s:UA_dbLoadOnEnter(dbId, jobStatus)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'loading...')
endfunction
function! s:UA_dbLoadOnExit(dbId, jobStatus, exitCode)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    if a:exitCode != '0'
        return
    endif
    call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'loading parts...')
endfunction
function! s:UA_dbLoadOnOutput(dbId, jobStatus, textList, type)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    for text in a:textList
        call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'loading: ' . text)
    endfor
endfunction

function! s:UA_dbLoadPartOnOutputFilter(jobStatus, textList, type)
    if !empty(a:textList)
        call remove(a:textList, 0, -1)
    endif
endfunction
function! s:UA_dbLoadPartOnExit(dbId, c, jobStatus, exitCode)
    let task = get(s:UA_taskMap, a:dbId, {})
    let db = ZFVimIM_dbForId(a:dbId)
    if empty(task) || empty(db)
        return
    endif
    if a:exitCode != '0'
        let task['dbMapNew'] = {}
        return
    endif
    if filereadable(task['cachePath'] . '/dbLoadCache_' . a:c)
        call ZFVimIM_DEBUG_profileStart('dbLoadPart')
        let task['dbMapNew'][a:c] = readfile(task['cachePath'] . '/dbLoadCache_' . a:c)
        call ZFVimIM_DEBUG_profileStop()
        if empty(task['dbMapNew'][a:c])
            unlet task['dbMapNew'][a:c]
        endif
    endif
endfunction

function! s:UA_dbSaveFallback(dbId, jobStatus)
    let task = get(s:UA_taskMap, a:dbId, {})
    let db = ZFVimIM_dbForId(a:dbId)
    if empty(task) || empty(db)
        return {
                    \   'output' : 'error',
                    \   'exitCode' : '-1',
                    \ }
    endif
    call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'saving (fallback)...')

    let dbFile = ZFVimIM_cloud_file(task['cloudOption'], 'dbFile')
    let dbCountFile = ZFVimIM_cloud_file(task['cloudOption'], 'dbCountFile')
    call ZFVimIM_dbSave(db, dbFile, dbCountFile)

    return {
                \   'output' : '',
                \   'exitCode' : '0',
                \ }
endfunction

function! s:UA_dbSaveOnEnter(dbId, jobStatus)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'saving...')

    " log
    let logHead = ZFVimIM_cloud_logInfo(task['cloudOption'])
    let groupJobStatus = ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId'])
    call s:cloudAsyncLog(groupJobStatus, logHead . 'changes:')
    for dbEdit in task['dbEdit']
        call s:cloudAsyncLog(groupJobStatus, logHead . '  ' . printf('%6s', dbEdit['action']) . "\t" . dbEdit['key'] . ' ' . dbEdit['word'])
    endfor

    " prepare to save
    call ZFVimIM_DEBUG_profileStart('dbSaveDBEditEncode')
    let dbEditJson = json_encode(task['dbEdit'])
    call ZFVimIM_DEBUG_profileStop()
    call ZFVimIM_DEBUG_profileStart('dbSaveDBEditWrite')
    call writefile([dbEditJson], task['cachePath'] . '/dbSaveCache')
    call ZFVimIM_DEBUG_profileStop()
endfunction
function! s:UA_dbSaveOnOutput(dbId, jobStatus, textList, type)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    for text in a:textList
        call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'saving: ' . text)
    endfor
endfunction

function! s:UA_dbUploadOnEnter(dbId, jobStatus)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'pushing...')
endfunction
function! s:UA_dbUploadOnOutput(dbId, jobStatus, textList, type)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    for text in a:textList
        call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'pushing : ' . text)
    endfor
endfunction

function! s:UA_dbCleanupCheckOnOutput(dbId, jobStatus, textList, type)
    let task = get(s:UA_taskMap, a:dbId, {})
    let db = ZFVimIM_dbForId(a:dbId)
    if empty(task) || empty(db)
        return
    endif
    for text in a:textList
        let history = substitute(text, '[\r\n]', '', 'g')
        if empty(history)
            continue
        endif
        let history = str2nr(history)
        let db['implData']['_dbCleanupHistory'] = history
        call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'history : ' . history)
    endfor
endfunction
function! s:UA_dbCleanupOnOutput(dbId, jobStatus, textList, type)
    let task = get(s:UA_taskMap, a:dbId, {})
    if empty(task)
        return
    endif
    for text in a:textList
        call s:cloudAsyncLog(ZFGroupJobStatus(a:jobStatus['jobImplData']['groupJobId']), ZFVimIM_cloud_logInfo(task['cloudOption']) . 'cleaning : ' . text)
    endfor
endfunction

function! s:UA_onExit(dbId, groupJobStatus, exitCode)
    while 1
        let task = get(s:UA_taskMap, a:dbId, {})
        if empty(task)
            break
        endif
        unlet s:UA_taskMap[a:dbId]

        let db = ZFVimIM_dbForId(a:dbId)
        if empty(db)
            break
        endif

        if !empty(task['dbMapNew'])
            let db['dbMap'] = task['dbMapNew']
            call ZFVimIM_dbSearchCacheClear(db)
        endif

        if a:exitCode == '0'
            call s:cloudAsyncLog(a:groupJobStatus, ZFVimIM_cloud_logInfo(task['cloudOption']) . 'update success')
            let s:autoUploadAsyncRetryTimeInc = 1
            if !empty(db['dbEdit'])
                call s:autoUploadAsync()
            endif
            break
        endif

        " upload failed, so restore dbEdit
        call extend(db['dbEdit'], task['dbEdit'], 0)

        call s:cloudAsyncLog(a:groupJobStatus, ZFVimIM_cloud_logInfo(task['cloudOption']) . 'update failed, exitCode: ' . a:exitCode . ', detailed log:')
        for output in a:groupJobStatus['jobOutput']
            call s:cloudAsyncLog(a:groupJobStatus, '    ' . output)
        endfor
        call s:cloudAsyncLog(a:groupJobStatus, ZFVimIM_cloud_logInfo(task['cloudOption']) . 'update failed, exitCode: ' . a:exitCode)

        " auto retry if not stopped by user
        if a:exitCode != g:ZFJOBSTOP
            let s:autoUploadAsyncRetryTimeInc = s:autoUploadAsyncRetryTimeInc * 2
            call s:autoUploadAsync()
        endif
        break
    endwhile

    " final cleanup
    if !empty(task)
        if isdirectory(task['cachePath'])
            call ZFVimIM_rm(task['cachePath'])
        endif
    endif
    call ZFJobOutputCleanup(a:groupJobStatus)

    if !empty(task) && task['mode'] == 'init' && get(task['cloudOption'], 'mode', '') != 'local'
        call s:uploadAsync(task['cloudOption'], 'download')
    endif
endfunction

