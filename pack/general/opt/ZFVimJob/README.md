
<!-- vim-markdown-toc GFM -->

* [Intro](#intro)
* [Workflow](#workflow)
* [How to use](#how-to-use)
    * [Fallback Limitations](#fallback-limitations)
* [API](#api)
    * [Jobs](#jobs)
    * [Group jobs](#group-jobs)
    * [Job Pool](#job-pool)
    * [Utils](#utils)
        * [Util functions](#util-functions)
        * [Job output](#job-output)
            * [Statusline log](#statusline-log)
            * [Log window](#log-window)
            * [Popup](#popup)
        * [Async run](#async-run)
        * [Auto script](#auto-script)
* [Other](#other)
    * [verbose log](#verbose-log)
    * [custom impl](#custom-impl)
        * [job](#job)
        * [timer](#timer)

<!-- vim-markdown-toc -->


# Intro

job util for `vim8` and `neovim`

features / why another remake:

* more convenient for caller and impl

    * tested on vim 7.3 or above, fallback to `system()` if no job impl available

        * job callback invoke normally, no job send support, though
        * further more, we bundled a builtin timer fallback impl,
            complex group job also works well even if no timer support (`!has('timers')`)

    * supply your own impl easily by setting `g:ZFJobImpl`

* many useful util functions

    * run multiple jobs or vim functions and manage them easily (`ZFGroupJobStart`)
    * thread pool like job queue, prevent too many jobs running at same time (`ZFJobPoolStart`)
    * manage job with task name, auto output to a temp log window (`ZFAsyncRun`)
    * abstract job output (`ZFJobOutput`)
        * output to `statusline` async (`ZFStatuslineLog`)
        * output to temp log window (`ZFLogWinAdd`)
        * output to popup window (`ZFPopupCreate`)
    * observe file write event and run build script automatically (`ZFAutoScript`)
    * timers and intervals, even for vim 7.3! (`ZFJobTimerStart` / `ZFJobIntervalStart`)


plugins that based on this plugin:

* [ZSaberLv0/ZFVimIM](https://github.com/ZSaberLv0/ZFVimIM) : input method by pure vim script
* [ZSaberLv0/ZFVimDirDiff](https://github.com/ZSaberLv0/ZFVimDirDiff) : directory diff tool like BeyondCompare, fully async
* [ZSaberLv0/ZFVimTerminal](https://github.com/ZSaberLv0/ZFVimTerminal) : terminal simulator in vim with low dependency


if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)


# Workflow

```
                      ZFJobStart - \
                           ^        \
                           |         \
                    ZFJobPoolStart    \
                           ^           \
ZFAsyncRun  \              |            \                       / ZFStatuslineLog
ZFAutoScript - => - ZFGroupJobStart ----- => - ZFJobOutput - => - ZFLogWin
                                                                \ ZFPopup
```

the job control is fully modularized, and can be combined easily to achieve complex logic

* one typical example:

    ```
    you saved a file
        => auto build, auto deploy (ZFAutoScript)
            => manage complex build workflow, with dependency logic and multithreaded (ZFGroupJobStart)
        => auto show build output as popup (ZFJobOutput)
    ```

* and one typical config:

    ```
    " what this config do

    " when you save files under `/path/to/LibA`:
    " * build LibA
    " when you save files under `/path/to/LibB`:
    " * build LibB, copy to Proj, and chain auto script to build Proj
    " when you save files under `/path/to/Proj`:
    " * build LibC and LibD concurrently, build Proj, and run

    let g:ZFAutoScript = {
            \   '/path/to/LibA' : {
            \     'memo' : 'build LibA',
            \     'jobCmd' : 'make',
            \     'jobCwd' : '/path/to/LibA',
            \   },
            \   '/path/to/LibB' : {
            \     'jobList' : [
            \       [
            \         {
            \           'memo' : 'build LibB',
            \           'jobCmd' : 'make',
            \           'jobCwd' : '/path/to/LibB',
            \         },
            \       ],
            \       [
            \         {
            \           'memo' : 'copy build result to Proj, this would run after build LibB',
            \           'jobCmd' : 'cp "/path/to/LibB/libB.so" "/path/to/Proj/lib/libB.so"',
            \         },
            \       ],
            \       [
            \         {
            \           'memo' : 'chain auto script, build Proj automatically',
            \           'jobCmd' : ['ZFAutoScriptRun "/path/to/Proj"'],
            \         },
            \       ],
            \     ],
            \   },
            \   '/path/to/Proj' : {
            \     'jobList' : [
            \       [
            \         {
            \           'memo' : 'jobs within same group, can be run concurrently',
            \           'jobCmd' : ['ZFAutoScriptRun "/path/to/LibC"'],
            \         },
            \         {
            \           'memo' : 'jobs within same group, can be run concurrently',
            \           'jobCmd' : ['ZFAutoScriptRun "/path/to/LibD"'],
            \         },
            \       ],
            \       [
            \         {
            \           'memo' : 'jobs in different group, would wait for prev group finish',
            \           'jobCmd' : 'make',
            \           'jobCwd' : '/path/to/Proj',
            \         },
            \       ],
            \       [
            \         {
            \           'memo' : 'automatically run Proj after build success',
            \           'jobCmd' : './build/a.out',
            \           'jobCwd' : '/path/to/Proj',
            \         },
            \       ],
            \     ],
            \   },
            \ }
    ```

it may hard to config for first time, but trust me, it changes the life


# How to use

1. use [Vundle](https://github.com/VundleVim/Vundle.vim) or any other plugin manager you like to install

    ```
    Plugin 'ZSaberLv0/ZFVimJob'
    Plugin 'ZSaberLv0/ZFVimPopup' " optional, support show job output as popup
    ```

1. start the job

    ```
    function! s:onOutput(jobStatus, textList, type)
    endfunction
    function! s:onExit(jobStatus, exitCode)
    endfunction
    let jobId = ZFJobStart({
            \   'jobCmd' : 'your job cmd',
            \   'onOutput' : function('s:onOutput'),
            \   'onExit' : function('s:onExit'),
            \   'jobEncoding' : '',
            \   'jobTimeout' : 0,
            \ })
    ```

    `onExit` would be called when:

    * job finished successfully, exitCode would be `0`
    * job failed, exitCode would be the job's exitCode (ensured string type)
    * stopped manually by `ZFJobStop(jobId)`, exitCode would be `g:ZFJOBSTOP`
    * failed to start job, exitCode would be `g:ZFJOBERROR`

1. start multiple jobs

    ```
    function! s:group1_job1(jobStatus)
        " note you may chain vim functions by setting `jobCmd` to vim function
        " no async support for vim functions, though
        call doSomeHeavyWork()
    endfunction

    function! s:groupJobOnExit(groupJobStatus, exitCode)
    endfunction
    let groupJobId = ZFGroupJobStart({
            \   'jobList' : [
            \     [
            \       {'jobCmd' : 'group0_job0'},
            \       {'jobCmd' : 'group0_job1'},
            \       ...
            \     ],
            \     [
            \       {'jobCmd' : 'group1_job0'},
            \       {'jobCmd' : function('s:group1_job1')},
            \     ],
            \     ...
            \   ],
            \   'onExit' : function('s:groupJobOnExit'),
            \   'jobTimeout' : 0,
            \ })
    ```

    `group1_xxx` would start only after previous `group0_xxx`'s jobs
    all finished with `0` exitCode

    group's `onExit` would be called when:

    * all child job finished successfully, group job's exitCode would be `0`
    * any child failed with none `0` exitCode, group job's exitCode would be the child's exitCode
    * stopped manually by `ZFGroupJobStop(groupJobId)`, group job's exitCode would be `g:ZFJOBSTOP`


## Fallback Limitations

by default, we would fallback to `system()` if not job impl available (`!ZFJobAvailable()`),
but there are some limitations you should concern:

* job send (`ZFJobSend()`, `ZFGroupJobSend()`, etc) not work,
    all sended text would be ignored
* if no `job` support, while using `ZFGroupJobStart()` / `ZFJobPoolStart()`
    with many child or queued jobs,
    it's easy to cause vim call stack exceeds `maxfuncdepth`

    to solve this problem, we have bundled a default timer impl fallback (see `custom impl` below),
    it should work well for most case


# API

## Jobs

* `ZFJobAvailable()`
* `ZFJobStart(jobCmd_or_jobOption)`

    ```
    jobOption: {
      'jobCmd' : 'job cmd',
                 // jobCmd can be:
                 // * string, shell command to run as job
                 // * vim `function(jobStatus)` or any callable object to `ZFJobFuncCall()`,
                 //   return `{output:xxx, exitCode:0}` to indicate invoke result,
                 //   if none, it's considered as success
                 // * number, use `ZFJobTimerStart()` to delay,
                 //   has better performance than starting a `sleep` job
      'jobCwd' : 'optional, cwd to run the job',
      'onLog' : 'optional, func(jobStatus, log)',
      'onOutputFilter' : 'optional, func(jobStatus, textList, type[stdout/stderr]), modify textList or empty to discard',
      'onOutput' : 'optional, func(jobStatus, textList, type[stdout/stderr])',
      'onEnter' : 'optional, func(jobStatus)',
      'onExit' : 'optional, func(jobStatus, exitCode)',
      'jobOutputDelay' : 'optional, default is g:ZFJobOutputDelay',
      'jobOutputLimit' : 'optional, max line of jobOutput that would be stored in jobStatus, default is g:ZFJobOutputLimit',
      'jobOutputCRFix' : 'optional, whether try to replace `\r\n` to `\n`, default is g:ZFJobOutputCRFix',
      'jobEncoding' : 'optional, if supplied, encoding conversion would be made before passing output textList',
      'jobTimeout' : 'optional, if supplied, ZFJobStop would be called with g:ZFJOBTIMEOUT',
      'jobFallback' : 'optional, true by default, whether fallback to `system()` if no job impl available',
      'jobImplData' : {}, // optional, if supplied, merge to jobStatus['jobImplData']
    }
    ```

* `ZFJobStop(jobId [, exitCode])`
* `ZFJobSend(jobId, text)`
* `ZFJobStatus(jobId)`

    ```
    {
      'jobId' : -1,
      'jobOption' : {},
      'jobOutput' : [],
      'jobImplData' : {},
    }
    ```

* `ZFJobTaskMap()`
* `ZFJobInfo(jobStatus)`
* `ZFJobLog(jobIdOrJobStatus, log)`


## Group jobs

* `ZFGroupJobStart(groupJobOption)`

    ```
    groupJobOption: {
      'jobList' : [
        [
          {
            'jobCmd' : '',
            'onOutput' : '',
            'onExit' : '',
            ...
          },
          {
            'jobList' : [ // group job can be chained
              ...
            ],
          },
          ...
        ],
        ...
      ],
      'jobCmd' : 'optional, used only when jobList not supplied',
      'jobCwd' : 'optional, if supplied, would use as default value for child ZFJobStart',
      'onLog' : 'optional, func(groupJobStatus, log)',
      'onOutputFilter' : 'optional, func(groupJobStatus, textList, type[stdout/stderr]), modify textList or empty to discard',
      'onOutput' : 'optional, func(groupJobStatus, textList, type[stdout/stderr])',
      'onEnter' : 'optional, func(groupJobStatus)',
      'onExit' : 'optional, func(groupJobStatus, exitCode)',
      'jobOutputDelay' : 'optional, default is g:ZFJobOutputDelay',
      'jobOutputLimit' : 'optional, max line of jobOutput that would be stored in jobStatus, default is g:ZFJobOutputLimit',
      'jobOutputCRFix' : 'optional, whether try to replace `\r\n` to `\n`, default is g:ZFJobOutputCRFix',
      'jobEncoding' : 'optional, if supplied, would use as default value for child ZFJobStart',
      'jobTimeout' : 'optional, if supplied, would use as default value for child ZFJobStart',
      'jobFallback' : 'optional, if supplied, would use as default value for child ZFJobStart',
      'jobImplData' : {}, // optional, if supplied, merge to groupJobStatus['jobImplData']

      'groupJobTimeout' : 'optional, if supplied, ZFGroupJobStop would be called with g:ZFJOBTIMEOUT',
      'groupJobStopOnChildError' : 'optional, 1 by default, whether stop group job when any of child has exitCode!=0',
      'onJobLog' : 'optional, func(groupJobStatus, jobStatus, log)',
      'onJobOutput' : 'optional, func(groupJobStatus, jobStatus, textList, type[stdout/stderr])',
      'onJobExit' : 'optional, func(groupJobStatus, jobStatus, exitCode)',
    }
    ```

* `ZFGroupJobStop(groupJobId [, exitCode])`
* `ZFGroupJobSend(groupJobId, text)`
* `ZFGroupJobStatus(groupJobId)`

    ```
    groupJobStatus : {
      'jobId' : '',
      'jobOption' : {},
      'jobOutput' : [],
      'jobStatusFailed' : {},
      'jobIndex' : 0,
      'jobStatusList' : [[{jobStatus}], [{jobStatus}, {jobStatus}]],
      'jobImplData' : {},
    }
    child jobStatus jobImplData: {
      'groupJobId' : '',
      'groupJobChildState' : '1: running, 0: successFinished, -1: failed',
      'groupJobChildIndex' : 0,
      'groupJobChildSubIndex' : 0,
    }
    ```

* `ZFGroupJobTaskMap()`
* `ZFGroupJobInfo(groupJobStatus)`
* `ZFGroupJobLog(groupJobId, log)`


## Job Pool

job pool is similar thread pool of other language,
you can run as many jobs up to `g:ZFJobPoolSize`,
when exceeds `g:ZFJobPoolSize`,
new jobs would be put to wait until other jobs stopped

job pool has same APIs as `ZFJobStart()` series,
and all of the behaviors are ensured the same:

* `ZFJobPoolStart(jobCmd_or_jobOption)`
* `ZFJobPoolStop(jobId [, exitCode])`
* `ZFJobPoolSend(jobId, text)`
* `ZFJobPoolStatus(jobId)`
* `ZFJobPoolTaskMap()`
* `ZFJobPoolInfo(jobStatus)`
* `ZFJobPoolLog(jobIdOrJobStatus, log)`


## Utils

### Util functions

since low version vim doesn't support `function(func, argList)`,
we supply a wrapper to simulate:

* `ZFJobFunc(func[, argList])` : return a Dictionary that can be run by `ZFJobFuncCall(jobFunc, argList)`

    func can be:

    * vim `function('name')`
        * for `vim 7.4` or above, `function('s:func')` can be used
        * for `vim 7.3` or below, you must put it in global scope, like `function('Fn_func')`
    * string or string list to `:execute`

        function params can be accessed by `a:000` series, example:

        ```
        let Fn = ZFJobFunc([
                \   'let ret = Wrap(a:1, a:2, a:3, a:4)',
                \   'let ZFJobFuncRet = ret["xxx"]',
                \ ], ['a', 'b'])
        call ZFJobFuncCall(Fn, ['c', 'd'])
        " Wrap() would be called as: Wrap('a', 'b', 'c', 'd')
        ```

        to return values within the strings to `:execute`, `let ZFJobFuncRet = yourValue`

* `ZFJobFuncCall(jobFunc, argList)` : run the function of `ZFJobFunc()`
* `ZFJobFuncInfo(jobFunc)` : return function info

and for timers:

* `ZFJobTimerAvailable()`
* `ZFJobTimerStart(delay, ZFJobFunc(...))`
* `ZFJobTimerStop(timerId)`

and for interval (require `ZFJobTimerAvailable()`):

* `ZFJobIntervalStart(interval, ZFJobFunc(...))`
* `ZFJobIntervalStop(intervalId)`


### Job output

abstract job output is done by default

typically, what you needs to care
is the `outputTo` option in your job option

you may also supply your own `onOutput`, though

functions:

* `call ZFJobOutput(jobStatus, textList [, type(stdout/stderr)])`

    output accorrding to job's output configs:

    ```
    jobStatus : {
        'jobOption' : {
            'outputTo' : {
                'outputType' : 'statusline/logwin',
                'outputId' : 'if exists, use this fixed outputId',
                'outputInfo' : 'optional, text or function(jobStatus) which return text',
                'outputInfoInterval' : 'if greater than 0, notify impl to update outputInfo with this interval',
                'outputAutoCleanup' : 10000,
                'outputManualCleanup' : 3000,

                // extra config for actual impl
                'statusline' : {...}, // see g:ZFStatuslineLog_defaultConfig
                'logwin' : { // see g:ZFLogWin_defaultConfig
                    ...
                    'logwinNoCloseWhenFocused' : 1,
                    'logwinAutoClosePreferHide' : 0,
                },
                'popup' : {...}, // see g:ZFPopup_defaultConfig
            },
        },
    }
    ```

* `call ZFJobOutputCleanup(jobStatus)`

    manually cleanup output


#### Statusline log

* `call ZFStatuslineLog('your msg'[, timeout/option])`

    output logs to statusline, restore statusline automatically if set by other code or timeout,
    or `call ZFStatuslineLogClear()` to restore manually


#### Log window

* `call ZFLogWinAdd(logId, content)`

    output logs to a temp log window

* control the log window:

    * `call ZFLogWinShow(logId)`
    * `call ZFLogWinFocus(logId)`
    * `call ZFLogWinHide(logId)`
    * `call ZFLogWinRedraw(logId)`
    * `call ZFLogWinClear(logId)`
    * `call ZFLogWinClose(logId)`

* `call ZFLogWinConfig(logId, option)`

    init or change log window config, the default option is:

    ```
    let g:ZFLogWin_defaultConfig = {
                \   'newWinCmd' : 'rightbelow 5new',
                \   'filetype' : 'ZFLogWin',
                \   'statusline' : '',
                \   'makeDefaultKeymap' : 1,
                \   'initCallback' : '',
                \   'cleanupCallback' : '',
                \   'updateCallback' : '',
                \   'lazyUpdate' : 100,
                \   'maxLine' : '10000',
                \   'revertLines' : 0,
                \   'autoShow' : 1,
                \ }
    ```

    * `statusline` : string or `function(logId)`
    * `makeDefaultKeymap` : if set, default `q` to hide log window
    * `initCallback` / `cleanupCallback` / `updateCallback` : `function(logId)`


#### Popup

use [ZSaberLv0/ZFVimPopup](https://github.com/ZSaberLv0/ZFVimPopup) to show job output,
see `g:ZFAutoScript_outputTo` for how to config


### Async run

* `:ZFAsyncRun your cmd` or `call ZFAsyncRun(jobCmd_or_jobOption[, taskNameOrJobId])`

    run shell async, output accorrding to `ZFJobOutput`

    you may use `call ZFAsyncRunStop([taskNameOrJobId])` to cancel,
    or check full log by `:ZFAsyncRunLog`

options:

* `let g:ZFAsyncRun_outputTo = {...}`

    output log to where (see `ZFJobOutput`), default:

    ```
    let g:ZFAsyncRun_outputTo = {
                \   'outputType' : 'logwin',
                \   'outputInfo' : function('ZF_AsyncRunOutputInfo'),
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
    ```


### Auto script

* `call ZFAutoScript(projDir, jobOption)`

    automaically run script when any file within `projDir` was written (via `FileWritePost` autocmd)

    `jobOption` can be `jobCmd` or:

    ```
    { // jobOption passed to ZFAsyncRun
        'autoScriptDelay' : 'optional, delay before run, 1 second by default',
    }
    ```

    use `call ZFAutoScriptRemove([projDir])` to cancel,
    use `call ZFAutoScriptLog([projDir])` to get log,
    use `call ZFAutoScriptStatus([projDir])` for active config, which would return:

    ```
    {
        'projDir' : {}, // jobStatus
    }
    ```

    you may also use `let g:ZFAutoScript={'projDir' : jobOption}` to config before plugin load

    typical config:

    ```
    let g:ZFAutoScript = {
            \   '/YourProjPath' : {
            \     'jobCmd' : 'make',
            \     'jobCwd' : '/YourProjPath',
            \   },
            \ }
    ```

options:

* `let g:ZFAutoScript_outputTo = {...}`

    output log to where (see `ZFJobOutput`), default:

    ```
    let g:ZFAutoScript_outputTo = {
                \   'outputType' : 'popup',
                \   'outputId' : 'ZFAutoScript',
                \   'outputInfo' : function('ZF_AutoScriptOutputInfo'),
                \   'logwin' : {
                \     'newWinCmd' : '99wincmd l | vertical rightbelow 20new',
                \     'filetype' : 'ZFAutoScriptLog',
                \     'autoShow' : 1,
                \   },
                \   'popup' : {
                \     'pos' : 'right|bottom',
                \     'width' : 1.0/3,
                \     'height' : 1.0/4,
                \     'x' : 1,
                \     'y' : 2,
                \     'wrap' : 0,
                \     'contentAlign' : 'bottom',
                \   },
                \ }
    ```

# Other

## verbose log

if any weird things happen, you may enable verbose log by:

```
let g:ZFJobVerboseLogEnable = 1
```

and dump the log to file:

```
:call writefile(g:ZFJobVerboseLog, 'log.txt')
```

## custom impl

### job

by default, we support `vim8`'s `job_start()` and `neovim`'s `jobstart()`,
    you may supply your own job impl by:

```
function! s:jobStart(jobStatus, onOutput, onExit)
    let jobImplId = yourJobStart(...)
    " store impl data if necessary
    let a:jobStatus['jobImplData']['yourJobImplId'] = jobImplId
    " return 1 if success or 0 if failed
    return 1
endfunction
function! s:jobStop(jobStatus)
endfunction
function! s:jobSend(extraArgs0, extraArgs1, jobStatus, text)
endfunction
let g:ZFJobImpl = {
        \   'jobStart' : function('s:jobStart'),
        \   'jobStop' : function('s:jobStop'),
        \   'jobSend' : ZFJobFunc(function('s:jobSend'), [extraArgs0, extraArgs1]),
        \ }
```

### timer

by default, we support by vim's `has('timers')`

also, we bundled a default fallback impl by `CursorHold`
(which can be disabled by `let g:ZFJobTimerFallback = 1`),
the fallback impl has these limitations:

* it's simutated by `CursorHold/CursorHoldI` and `feedkeys("\<up>\<down\>", 'nt')`,
    so the timer won't fired in modes except `Normal` and `Insert`,
    and it may or may not breaks some actions depends on the cursor movement


you may also supply your own timer impl by:

```
function! s:timerStart(delay, jobFunc)
    let timerId = xxx
    ...
    return timerId
endfunction
function! s:timerStop(timerId)
    ...
endfunction
let g:ZFJobTimerImpl = {
        \   'timerStart' : function('s:timerStart'),
        \   'timerStop' : function('s:timerStop'),
        \ }
```

