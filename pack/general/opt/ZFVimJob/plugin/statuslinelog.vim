
function! ZF_StatuslineLog_prefix(statuslineOld)
    return ''
endfunction
function! ZF_StatuslineLog_postfix(statuslineOld)
    let pos = match(a:statuslineOld, '%=')
    if pos >= 0
        return strpart(a:statuslineOld, pos)
    else
        return ''
    endif
endfunction

" {
"   'timeout' : 'when set, auto hide after miliseconds, 5000 by default',
"   'escape' : '0/1, whether escape the text, 1 by default',
"   'prefixChecker' : 'string or function, when set, used as prefix, ZF_StatuslineLog_prefix by default',
"   'postfixChecker' : 'string or function, when set, used as postfix, ZF_StatuslineLog_postfix by default',
" }
if !exists('g:ZFStatuslineLog_defaultConfig')
    let g:ZFStatuslineLog_defaultConfig = {}
endif

" ============================================================
" option: timeout or g:ZFStatuslineLog_defaultConfig
function! ZFStatuslineLog(text, ...)
    call s:log(a:text, get(a:, 1, {}))
endfunction

function! ZFStatuslineLogClear()
    call s:cleanup()
endfunction

" option : {
"   'statuslineOld' : 'when set, use to apply text',
"   ... // other option in g:ZFStatuslineLog_defaultConfig
" }
function! ZFStatuslineLogValue(text, ...)
    let option = get(a:, 1, {})
    let statuslineOld = get(option, 'statuslineOld', &g:statusline)

    let PrefixChecker = get(option, 'prefixChecker', function('ZF_StatuslineLog_prefix'))
    if ZFJobFuncCallable(PrefixChecker)
        let prefix = ZFJobFuncCall(PrefixChecker, [statuslineOld])
    else
        let prefix = PrefixChecker
    endif
    let PostfixChecker = get(option, 'postfixChecker', function('ZF_StatuslineLog_postfix'))
    if ZFJobFuncCallable(PostfixChecker)
        let postfix = ZFJobFuncCall(PostfixChecker, [statuslineOld])
    else
        let postfix = PostfixChecker
    endif

    if get(option, 'escape', 1)
        let text = substitute(a:text, '%', '%%', 'g')
    else
        let text = a:text
    endif
    return prefix . text . postfix
endfunction

" ============================================================
if !exists('s:timeoutId')
    let s:timeoutId = -1
endif
if !exists('s:observerAttached')
    let s:observerAttached = 0
endif
if !exists('s:statuslineSaved')
    let s:statuslineSaved = ''
endif
if !exists('s:statuslineOverrideFlag')
    let s:statuslineOverrideFlag = 0
endif

function! s:log(text, option)
    call s:cleanup()

    if type(a:option) == type(0)
        let option = {
                    \   'timeout' : a:option,
                    \ }
        let timeout = a:option
    else
        let option = copy(a:option)
        let timeout = get(option, 'timeout', 5000)
    endif

    let s:statuslineSaved = &g:statusline
    let s:statuslineOverrideFlag += 1
    let &g:statusline = ZFStatuslineLogValue(a:text, extend(option, {
                \   'statuslineOld' : s:statuslineSaved,
                \ }))
    let s:statuslineOverrideFlag -= 1

    augroup ZFStatuslineLog_observer_augroup
        autocmd!
        if exists('##OptionSet')
            autocmd OptionSet statusline call s:statuslineSetByOther()
        endif
    augroup END
    let s:observerAttached = 1
    if timeout > 0
        if ZFJobTimerAvailable()
            let s:timeoutId = ZFJobTimerStart(timeout, ZFJobFunc(function('ZFStatuslineLogImpl_statuslineTimeout')))
        endif
    endif
endfunction

function! s:cleanup()
    if s:timeoutId != -1
        call ZFJobTimerStop(s:timeoutId)
        let s:timeoutId = -1
    endif
    if s:observerAttached
        let s:observerAttached = 0
        augroup ZFStatuslineLog_observer_augroup
            autocmd!
        augroup END
        let s:statuslineOverrideFlag += 1
        let &g:statusline = s:statuslineSaved
        let s:statuslineOverrideFlag -= 1
    endif
endfunction

function! ZFStatuslineLogImpl_statuslineTimeout(...)
    let s:timeoutId = -1
    call s:cleanup()
endfunction

function! s:statuslineSetByOther()
    if !exists('v:option_type') || v:option_type != 'global' || s:statuslineOverrideFlag > 0
        return
    endif
    if s:timeoutId != -1
        call ZFJobTimerStop(s:timeoutId)
        let s:timeoutId = -1
    endif
    if s:observerAttached
        let s:observerAttached = 0
        augroup ZFStatuslineLog_observer_augroup
            autocmd!
        augroup END
    endif
endfunction

