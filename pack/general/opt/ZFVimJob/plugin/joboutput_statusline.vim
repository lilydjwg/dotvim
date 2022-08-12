
function! s:fallbackCheck()
    return ''
endfunction

function! s:init(outputStatus, jobStatus)
endfunction

function! s:cleanup(outputStatus, jobStatus)
    call ZFStatuslineLogClear()
endfunction

function! s:attach(outputStatus, jobStatus)
endfunction

function! s:detach(outputStatus, jobStatus)
endfunction

function! s:output(outputStatus, jobStatus, textList, type)
    let option = get(a:outputStatus['outputTo'], 'statusline', {})
    if !exists("option['timeout']")
        let option = copy(option)
        let option['timeout'] = 0
    endif
    call ZFStatuslineLog(a:textList[-1], option)
endfunction

if !exists('g:ZFJobOutputImpl')
    let g:ZFJobOutputImpl = {}
endif
let g:ZFJobOutputImpl['statusline'] = {
            \   'fallbackCheck' : function('s:fallbackCheck'),
            \   'init' : function('s:init'),
            \   'cleanup' : function('s:cleanup'),
            \   'attach' : function('s:attach'),
            \   'detach' : function('s:detach'),
            \   'output' : function('s:output'),
            \ }

