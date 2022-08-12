
function! ZFVimIM_DEBUG_checkHealth()
    redraw!
    echom 'ZFJobAvailable: ' . (exists('*ZFJobAvailable') && ZFJobAvailable())
    echom '    vim version: ' . v:version
    echom '    vim job: ' . has('job')
    echom '    nvim job: ' . exists('*jobstart')
    echom 'python: ' . (executable('python') || executable('python'))
    echom '    python: ' . executable('python') . ' ' . (exists('*exepath') ? exepath('python') : 'NA')
    if executable('python')
        echom '        ' . substitute(system('python --version'), '[\r\n]', '', 'g')
    endif
    echom '    python3: ' . executable('python3') . ' ' . (exists('*exepath') ? exepath('python3') : 'NA')
    if executable('python3')
        echom '        ' . substitute(system('python3 --version'), '[\r\n]', '', 'g')
    endif
endfunction

" ============================================================
if !exists('g:ZFVimIM_DEBUG_profile')
    let g:ZFVimIM_DEBUG_profile = 0
endif
" result store to g:ZFVimIM_DEBUG_profileData:
" {
"   'name' : {
"     'name' : '',
"     'total' : '',
"     'count' : '',
"     'avg' : '',
"     'min' : '',
"     'max' : '',
"   },
" }
function! ZFVimIM_DEBUG_profileStart(name)
    if !g:ZFVimIM_DEBUG_profile
        return
    endif
    if !exists('s:ZFVimIM_DEBUG_profileStack')
        " {
        "   'name' : '',
        "   'start' : 'reltime()',
        " }
        let s:ZFVimIM_DEBUG_profileStack = []
    endif
    call add(s:ZFVimIM_DEBUG_profileStack, {
                \   'name' : a:name,
                \   'start' : reltime(),
                \ })
endfunction
function! ZFVimIM_DEBUG_profileStop()
    if !g:ZFVimIM_DEBUG_profile || !exists('s:ZFVimIM_DEBUG_profileStack') || empty(s:ZFVimIM_DEBUG_profileStack)
        return
    endif
    if !exists('g:ZFVimIM_DEBUG_profileData')
        let g:ZFVimIM_DEBUG_profileData = {}
    endif
    let stack = remove(s:ZFVimIM_DEBUG_profileStack, len(s:ZFVimIM_DEBUG_profileStack) - 1)
    let name = stack['name']
    let cost = float2nr(reltimefloat(reltime(stack['start'], reltime())) * 1000 * 1000)
    let data = get(g:ZFVimIM_DEBUG_profileData, name, {
                \   'name' : name,
                \   'total' : 0,
                \   'count' : 0,
                \   'avg' : 0,
                \   'min' : -1,
                \   'max' : 0,
                \ })
    let g:ZFVimIM_DEBUG_profileData[name] = data
    let data['total'] += cost
    let data['count'] += 1
    let data['avg'] = data['total'] / data['count']
    if data['min'] < 0 || data['min'] > cost
        let data['min'] = cost
    endif
    if data['max'] < cost
        let data['max'] = cost
    endif
endfunction

function! s:ZFVimIM_DEBUG_profileInfo_sort(e0, e1)
    return a:e1['avg'] - a:e0['avg']
endfunction
function! ZFVimIM_DEBUG_profileInfo()
    let list = values(get(g:, 'ZFVimIM_DEBUG_profileData', {}))
    call sort(list, function('s:ZFVimIM_DEBUG_profileInfo_sort'))
    let ret = []
    for item in list
        let total = item['total'] / 1000
        let avg = item['avg'] / 1000
        let max = item['max'] / 1000
        let min = item['min'] / 1000
        call add(ret, [item['name']
                    \ , '  avg:' , string(avg) , ' (' , total , '/' , string(item['count']) , ')'
                    \ , '  max:' , string(max)
                    \ , '  min:' , string(min)
                    \ ])
    endfor
    let ret = s:joinAligned(ret)
    echo join(ret, "\n")
    return ret
endfunction
function! s:joinAligned(list)
    if empty(a:list)
        return []
    endif
    let n = len(a:list[0])
    let nList = []
    for line in a:list
        for i in range(len(line))
            let len = len(line[i])
            if i >= len(nList)
                call add(nList, len)
            elseif len > nList[i]
                let nList[i] = len
            endif
        endfor
    endfor

    let ret = []
    for line in a:list
        let t = ''
        for i in range(len(line))
            let t .= repeat(' ', nList[i] - len(line[i])) . line[i]
        endfor
        call add(ret, t)
    endfor
    return ret
endfunction

function! ZFVimIM_DEBUG_start(logFile)
    if exists('s:ZFVimIM_DEBUG_start_logFile')
        return
    endif
    let s:ZFVimIM_DEBUG_start_logFile = a:logFile
    let g:ZFVimIM_DEBUG_profile = 1
endfunction

function! ZFVimIM_DEBUG_stop()
    if !exists('s:ZFVimIM_DEBUG_start_logFile')
        return
    endif
    execute 'redir! > ' . s:ZFVimIM_DEBUG_start_logFile

    silent echo '==================== profileInfo ===================='
    silent call ZFVimIM_DEBUG_profileInfo()

    silent echo '==================== cloud log ===================='
    silent IMCloudLog

    if exists('*ZFGroupJobTaskMap')
        silent echo '==================== jobs ===================='
        silent echo ZFGroupJobTaskMap()
    endif

    silent echo '==================== db ===================='
    silent echo g:ZFVimIM_db

    execute 'redir END'
    unlet s:ZFVimIM_DEBUG_start_logFile
    let g:ZFVimIM_DEBUG_profile = 0
endfunction

