
let s:t_string = type('')
let s:t_list = type([])
let s:t_dict = type({})
let s:t_func = type(function('function'))

" ============================================================
" utils to support `function(xx, arglist)` low vim version
function! ZFJobFuncImpl_funcWrap(cmd, ...)
    if type(a:cmd) == s:t_string
        execute a:cmd
    elseif type(a:cmd) == s:t_list
        for cmd in a:cmd
            execute cmd
        endfor
    endif
    if exists('ZFJobFuncRet')
        return ZFJobFuncRet
    endif
endfunction

let s:jobFuncKey_func = 'ZF_func'
let s:jobFuncKey_arglist = 'ZF_arglist'

" NOTE: if you want to support vim 7.3, func must be placed in global scope
function! ZFJobFunc(func, ...)
    if empty(a:func)
        return {}
    elseif type(a:func) == s:t_func
        let argList = get(a:, 1, [])
        if empty(argList)
            return a:func
        endif
        return {
                    \   s:jobFuncKey_func : a:func,
                    \   s:jobFuncKey_arglist : argList,
                    \ }
    elseif type(a:func) == s:t_string || type(a:func) == s:t_list
        if type(a:func) == s:t_list
            for line in a:func
                if type(line) != s:t_string
                    throw '[ZFJobFunc] unsupported func type: mixed array'
                    return {}
                endif
            endfor
        endif
        return ZFJobFunc(function('ZFJobFuncImpl_funcWrap'), extend([a:func], get(a:, 1, [])))
    else
        throw '[ZFJobFunc] unsupported func type: ' . type(a:func)
        return {}
    endif
endfunction

function! ZFJobFuncCall(func, ...)
    if empty(a:func)
        return 0
    elseif type(a:func) == s:t_func
        let Fn = a:func
        return call(a:func, get(a:, 1, []))
    elseif type(a:func) == s:t_dict
        if !exists("a:func[s:jobFuncKey_func]") || !exists("a:func[s:jobFuncKey_arglist]")
            throw '[ZFJobFunc] unsupported func value'
            return 0
        endif
        return call(a:func[s:jobFuncKey_func], extend(copy(a:func[s:jobFuncKey_arglist]), get(a:, 1, [])))
    elseif type(a:func) == s:t_string || type(a:func) == s:t_list
        return ZFJobFuncCall(ZFJobFunc(a:func), get(a:, 1, []))
    else
        throw '[ZFJobFunc] unsupported func type: ' . type(a:func)
        return 0
    endif
endfunction

function! ZFJobFuncCallable(func)
    if empty(a:func)
        return 0
    elseif type(a:func) == s:t_func
        return 1
    elseif type(a:func) == s:t_dict
        if !exists("a:func[s:jobFuncKey_func]") || !exists("a:func[s:jobFuncKey_arglist]")
            return 0
        endif
        return 1
    elseif type(a:func) == s:t_string
        " for logical safe, string is not treated as callable
        " wrap as ZFJobFunc should do the work
        return 0
    elseif type(a:func) == s:t_list
        for line in a:func
            if type(line) != s:t_string
                return 0
            endif
        endfor
        return 1
    else
        return 0
    endif
endfunction

function! ZFJobFuncInfo(jobFunc)
    if type(a:jobFunc) == s:t_string
        return a:jobFunc
    elseif type(a:jobFunc) == s:t_func
        silent let info = s:jobFuncInfo(a:jobFunc)
        return substitute(info, '\n', '', 'g')
    elseif type(a:jobFunc) == s:t_dict
        silent let info = s:jobFuncInfo(a:jobFunc[s:jobFuncKey_func])
        return substitute(info, '\n', '', 'g')
    elseif type(a:jobFunc) == s:t_list
        if len(a:jobFunc) == 1
            return string(a:jobFunc[0])
        else
            return string(a:jobFunc)
        endif
    else
        return string(a:jobFunc)
    endif
endfunction

if exists('*string')
    function! s:jobFuncInfo(jobFunc)
        return string(a:jobFunc)
    endfunction
elseif exists('*execute')
    function! s:jobFuncInfo(jobFunc)
        return execute('echo a:jobFunc')
    endfunction
else
    function! s:jobFuncInfo(jobFunc)
        try
            redir => info
            silent echo a:jobFunc
        finally
            redir END
        endtry
        return info
    endfunction
endif
function! s:funcScopeIsValid(funcString)
    return match(a:funcString, 's:\|w:\|t:\|b:') < 0
endfunction
function! s:funcFromString(funcString)
    if !s:funcScopeIsValid(a:funcString)
        throw '[ZFJobFunc] no `s:func` supported, use `function("s:func")` or put the func to global scopre instead, func: ' . a:funcString
    endif
    return function(a:funcString)
endfunction

" ============================================================
" arg parse
function! ZFJobCmdToList(jobCmd)
    let jobCmd = substitute(a:jobCmd, '\\ ', '_ZF_SPACE_ZF_', 'g')
    let jobCmd = substitute(jobCmd, '\\"', '_ZF_QUOTE_ZF_', 'g')
    let prevQuote = -1
    let i = len(jobCmd)
    while i > 0
        let i -= 1

        if jobCmd[i] == '"'
            if prevQuote == -1
                let prevQuote = i
            else
                let prevQuote = -1
            endif
            let jobCmd = strpart(jobCmd, 0, i)
                        \ . strpart(jobCmd, i + 1)
            continue
        endif

        if jobCmd[i] == ' ' && prevQuote != -1
            let jobCmd = strpart(jobCmd, 0, i)
                        \ . '_ZF_SPACE_ZF_'
                        \ . strpart(jobCmd, i + 1)
        endif
    endwhile
    let ret = []
    for item in split(jobCmd)
        let t = substitute(item, '_ZF_SPACE_ZF_', ' ', 'g')
        let t = substitute(t, '_ZF_QUOTE_ZF_', '"', 'g')
        call add(ret, t)
    endfor
    return ret
endfunction

" ============================================================
" running token
function! ZFJobRunningToken(jobStatus, ...)
    if len(get(a:jobStatus, 'exitCode', '')) != 0
        return get(a:, 1, ' ')
    endif
    let token = get(a:, 2, '-\|/')
    let a:jobStatus['jobImplData']['jobRunningTokenIndex']
                \ = (get(a:jobStatus['jobImplData'], 'jobRunningTokenIndex', -1) + 1) % len(token)
    return token[a:jobStatus['jobImplData']['jobRunningTokenIndex']]
endfunction

" ============================================================
" others
function! CygpathFix_absPath(path)
    if len(a:path) <= 0|return ''|endif
    if !exists('g:CygpathFix_isCygwin')
        let g:CygpathFix_isCygwin = has('win32unix') && executable('cygpath')
    endif
    let path = fnamemodify(a:path, ':p')
    if !empty(path) && g:CygpathFix_isCygwin
        if 0 " cygpath is really slow
            let path = substitute(system('cygpath -m "' . path . '"'), '[\r\n]', '', 'g')
        else
            if match(path, '^/cygdrive/') >= 0
                let path = toupper(strpart(path, len('/cygdrive/'), 1)) . ':' . strpart(path, len('/cygdrive/') + 1)
            else
                if !exists('g:CygpathFix_cygwinPrefix')
                    let g:CygpathFix_cygwinPrefix = substitute(system('cygpath -m /'), '[\r\n]', '', 'g')
                endif
                let path = g:CygpathFix_cygwinPrefix . path
            endif
        endif
    endif
    return substitute(substitute(path, '\\', '/', 'g'), '\%(\/\)\@<!\/\+$', '', '') " (?<!\/)\/+$
endfunction

