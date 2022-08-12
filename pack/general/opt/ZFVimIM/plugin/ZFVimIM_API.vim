
" ============================================================
if !exists('g:ZFVimIM_matchLimit')
    let g:ZFVimIM_matchLimit = 2000
endif

if !exists('g:ZFVimIM_predictLimitWhenMatch')
    let g:ZFVimIM_predictLimitWhenMatch = 5
endif
if !exists('g:ZFVimIM_predictLimit')
    let g:ZFVimIM_predictLimit = 1000
endif

if !exists('g:ZFVimIM_sentence')
    let g:ZFVimIM_sentence = 1
endif

if !exists('g:ZFVimIM_crossable')
    let g:ZFVimIM_crossable = 2
endif
if !exists('g:ZFVimIM_crossDbLimit')
    let g:ZFVimIM_crossDbLimit = 2
endif
if !exists('g:ZFVimIM_crossDbPos')
    let g:ZFVimIM_crossDbPos = 5
endif

if !exists('g:ZFVimIM_cachePath')
    let g:ZFVimIM_cachePath = get(g:, 'zf_vim_cache_path', $HOME . '/.vim_cache') . '/ZFVimIM'
endif

function! ZFVimIM_cachePath()
    if !isdirectory(g:ZFVimIM_cachePath)
        call mkdir(g:ZFVimIM_cachePath, 'p')
    endif
    return g:ZFVimIM_cachePath
endfunction

function! ZFVimIM_randName()
    return fnamemodify(tempname(), ':t')
endfunction

function! ZFVimIM_rm(path)
    if (has('win32') || has('win64')) && !has('unix')
        silent! call system('rmdir /s/q "' . substitute(CygpathFix_absPath(a:path), '/', '\', 'g') . '"')
    else
        silent! call system('rm -rf "' . CygpathFix_absPath(a:path) . '"')
    endif
endfunction

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

" db : [
"   {
"     'dbId' : 'auto generated id',
"     'name' : '(required) name of the db',
"     'priority' : '(optional) priority of the db, smaller value has higher priority, 100 by default',
"     'switchable' : '(optional) 1 by default, when off, won't be enabled by ZFVimIME_keymap_next_n() series',
"     'editable' : '(optional) 1 by default, when off, no dbEdit would applied',
"     'crossable' : '(optional) g:ZFVimIM_crossable by default, whether to show result when inputing in other db',
"                   // 0 : disable
"                   // 1 : show only when full match
"                   // 2 : show and allow predict
"                   // 3 : show and allow predict and sub match
"     'crossDbLimit' : '(optional) g:ZFVimIM_crossDbLimit by default, when crossable, limit max result to this num',
"     'dbCallback' : '(optional) func(key, option), see ZFVimIM_complete',
"                    // when dbCallback supplied, words would be fetched from this callback instead
"     'menuLabel' : '(optional) string or function(item), when not empty, show label after key hint',
"                   // when not set, or set to number `0`, we would show db name if it's completed from crossDb
"     'implData' : {
"       // extra data for impl
"     },
"
"     // generated data:
"     'dbMap' : { // split a-z to improve performance, ensured empty if no data
"       'a' : [
"         'a#啊,阿#3,2',
"         'ai#爱,哀#3',
"       ],
"       'c' : [
"         'ceshi#测试',
"       ],
"     },
"     'dbEdit' : [
"       {
"         'action' : 'add/remove/reorder',
"         'key' : 'key',
"         'word' : 'word',
"       },
"       ...
"     ],
"   },
"   ...
" ]
if !exists('g:ZFVimIM_db')
    let g:ZFVimIM_db = []
endif
if !exists('g:ZFVimIM_dbIndex')
    let g:ZFVimIM_dbIndex = 0
endif

let g:ZFVimIM_KEY_S_MAIN = '#'
let g:ZFVimIM_KEY_S_SUB = ','
let g:ZFVimIM_KEY_SR_MAIN = '_ZFVimIM_m_'
let g:ZFVimIM_KEY_SR_SUB = '_ZFVimIM_s_'

" ============================================================
augroup ZFVimIM_event_OnUpdateDb_augroup
    autocmd!
    autocmd User ZFVimIM_event_OnUpdateDb silent
augroup END

" ============================================================
function! ZFVimIM_funcCallable(func)
    if exists('*ZFJobFuncCallable')
        return ZFJobFuncCallable(a:func)
    else
        return type(a:func) == type(function('function'))
    endif
endfunction
function! ZFVimIM_funcCall(func, argList)
    if exists('*ZFJobFuncCall')
        return ZFJobFuncCall(a:func, a:argList)
    else
        return call(a:func, a:argList)
    endif
endfunction

" option: {
"   'name' : '(required) name of your db',
"   ... // see g:ZFVimIM_db for more info
" }
function! ZFVimIM_dbInit(option)
    let db = extend({
                \   'dbId' : -1,
                \   'name' : 'ZFVimIM',
                \   'priority' : -1,
                \   'switchable' : 1,
                \   'editable' : 1,
                \   'crossable' : g:ZFVimIM_crossable,
                \   'crossDbLimit' : g:ZFVimIM_crossDbLimit,
                \   'dbCallback' : '',
                \   'menuLabel' : 0,
                \   'dbMap' : {},
                \   'dbEdit' : [],
                \   'implData' : {},
                \ }, a:option)
    if db['priority'] < 0
        let db['priority'] = 100
    endif
    call ZFVimIM_dbSearchCacheClear(db)

    let s:dbId = get(s:, 'dbId', 0) + 1
    while ZFVimIM_dbIndexForId(s:dbId) >= 0
        let s:dbId += 1
        if s:dbId <= 0
            let s:dbId = 1
        endif
    endwhile
    let db['dbId'] = s:dbId

    let index = len(g:ZFVimIM_db) - 1
    while index >= 0 && db['priority'] < g:ZFVimIM_db[index]['priority']
        let index -= 1
    endwhile
    call insert(g:ZFVimIM_db, db, index + 1)

    return db
endfunction

function! ZFVimIM_dbIndexForId(dbId)
    for dbIndex in range(len(g:ZFVimIM_db))
        if g:ZFVimIM_db[dbIndex]['dbId'] == a:dbId
            return dbIndex
        endif
    endfor
    return -1
endfunction
function! ZFVimIM_dbForId(dbId)
    for dbIndex in range(len(g:ZFVimIM_db))
        if g:ZFVimIM_db[dbIndex]['dbId'] == a:dbId
            return g:ZFVimIM_db[dbIndex]
        endif
    endfor
    return {}
endfunction

function! ZFVimIM_dbLoad(db, dbFile, ...)
    call s:dbLoad(a:db, a:dbFile, get(a:, 1, ''))
endfunction
function! ZFVimIM_dbSave(db, dbFile, ...)
    call s:dbSave(a:db, a:dbFile, get(a:, 1, ''))
endfunction

function! ZFVimIM_dbEditApply(db, dbEdit)
    call ZFVimIM_DEBUG_profileStart('dbEditApply')
    call s:dbEditApply(a:db, a:dbEdit)
    call ZFVimIM_DEBUG_profileStop()
endfunction

function! ZFVimIM_wordAdd(db, word, key)
    call s:dbEdit(a:db, a:word, a:key, 'add')
endfunction
command! -nargs=+ IMAdd :call ZFVimIM_wordAdd({}, <f-args>)

function! ZFVimIM_wordRemove(db, word, ...)
    call s:dbEditWildKey(a:db, a:word, get(a:, 1, ''), 'remove')
endfunction
command! -nargs=+ IMRemove :call ZFVimIM_wordRemove({}, <f-args>)

function! ZFVimIM_wordReorder(db, word, ...)
    call s:dbEditWildKey(a:db, a:word, get(a:, 1, ''), 'reorder')
endfunction
command! -nargs=+ IMReorder :call ZFVimIM_wordReorder({}, <f-args>)

function! s:dbItemReorderFunc(item1, item2)
    return (a:item2['count'] - a:item1['count'])
endfunction
function! ZFVimIM_dbItemReorder(dbItem)
    call ZFVimIM_DEBUG_profileStart('ItemReorder')
    let tmp = []
    let i = 0
    let iEnd = len(a:dbItem['wordList'])
    while i < iEnd
        call add(tmp, {
                    \   'word' : a:dbItem['wordList'][i],
                    \   'count' : a:dbItem['countList'][i],
                    \ })
        let i += 1
    endwhile
    call sort(tmp, function('s:dbItemReorderFunc'))
    let a:dbItem['wordList'] = []
    let a:dbItem['countList'] = []
    for item in tmp
        call add(a:dbItem['wordList'], item['word'])
        call add(a:dbItem['countList'], item['count'])
    endfor
    call ZFVimIM_DEBUG_profileStop()
endfunction

" dbItemEncoded:
"   'a#啊,阿#123'
" dbItem:
"   {
"     'key' : 'a',
"     'wordList' : ['啊', '阿'],
"     'countList' : [123],
"   }
function! ZFVimIM_dbItemDecode(dbItemEncoded)
    let split = split(a:dbItemEncoded, g:ZFVimIM_KEY_S_MAIN)
    let wordList = split(split[1], g:ZFVimIM_KEY_S_SUB)
    for i in range(len(wordList))
        let wordList[i] = substitute(
                    \   substitute(wordList[i], g:ZFVimIM_KEY_SR_MAIN, g:ZFVimIM_KEY_S_MAIN, 'g'),
                    \   g:ZFVimIM_KEY_SR_SUB, g:ZFVimIM_KEY_S_SUB, 'g'
                    \ )
    endfor
    let countList = []
    for cnt in split(get(split, 2, ''), g:ZFVimIM_KEY_S_SUB)
        call add(countList, str2nr(cnt))
    endfor
    while len(countList) < len(wordList)
        call add(countList, 0)
    endwhile
    return {
                \   'key' : split[0],
                \   'wordList' : wordList,
                \   'countList' : countList,
                \ }
endfunction

function! ZFVimIM_dbItemEncode(dbItem)
    let dbItemEncoded = a:dbItem['key']
    let dbItemEncoded .= g:ZFVimIM_KEY_S_MAIN
    for i in range(len(a:dbItem['wordList']))
        if i != 0
            let dbItemEncoded .= g:ZFVimIM_KEY_S_SUB
        endif
        let dbItemEncoded .= substitute(
                    \   substitute(a:dbItem['wordList'][i], g:ZFVimIM_KEY_S_MAIN, g:ZFVimIM_KEY_SR_MAIN, 'g'),
                    \   g:ZFVimIM_KEY_S_SUB, g:ZFVimIM_KEY_SR_SUB, 'g'
                    \ )
    endfor
    for i in range(len(a:dbItem['countList']))
        if a:dbItem['countList'][i] <= 0
            break
        endif
        if i == 0
            let dbItemEncoded .= g:ZFVimIM_KEY_S_MAIN
        else
            let dbItemEncoded .= g:ZFVimIM_KEY_S_SUB
        endif
        let dbItemEncoded .= a:dbItem['countList'][i]
    endfor
    return dbItemEncoded
endfunction

if !exists('*ZFVimIM_complete')
    function! ZFVimIM_complete(key, ...)
        return ZFVimIM_completeDefault(a:key, get(a:, 1, {}))
    endfunction
endif


" db: {
"   'dbSearchCache' : {
"     'c . start . pattern' : index,
"   },
"   'dbSearchCacheKeys' : [
"     'c . start . pattern',
"   ],
" }
function! ZFVimIM_dbSearch(db, c, pattern, start)
    let patternKey = a:c . a:start . a:pattern
    let index = get(a:db['dbSearchCache'], patternKey, -2)
    if index != -2
        return index
    endif
    " this may take long time for large db
    call ZFVimIM_DEBUG_profileStart('dbSearch')
    let index = match(get(a:db['dbMap'], a:c, []), a:pattern, a:start)
    call ZFVimIM_DEBUG_profileStop()

    if a:start == 0
        let a:db['dbSearchCache'][patternKey] = index
        call add(a:db['dbSearchCacheKeys'], patternKey)

        " limit cache size
        if len(a:db['dbSearchCacheKeys']) >= 300
            for patternKey in remove(a:db['dbSearchCacheKeys'], 0, 200)
                unlet a:db['dbSearchCache'][patternKey]
            endfor
        endif
    endif

    return index
endfunction

function! ZFVimIM_dbSearchCacheClear(db)
    let a:db['dbSearchCache'] = {}
    let a:db['dbSearchCacheKeys'] = []
endfunction


" ============================================================
function! s:dbLoad(db, dbFile, ...)
    call ZFVimIM_dbSearchCacheClear(a:db)

    " explicitly clear db content
    let a:db['dbMap'] = {}
    let a:db['dbEdit'] = []

    let dbMap = a:db['dbMap']
    call ZFVimIM_DEBUG_profileStart('dbLoadFile')
    let lines = readfile(a:dbFile)
    call ZFVimIM_DEBUG_profileStop()
    if empty(lines)
        return
    endif

    call ZFVimIM_DEBUG_profileStart('dbLoad')
    for line in lines
        if match(line, '\\ ') >= 0
            let wordListTmp = split(substitute(line, '\\ ', '_ZFVimIM_space_', 'g'))
            if !empty(wordListTmp)
                let key = remove(wordListTmp, 0)
            endif

            let wordList = []
            for word in wordListTmp
                call add(wordList, substitute(word, '_ZFVimIM_space_', ' ', 'g'))
            endfor
        else
            let wordList = split(line)
            if !empty(wordList)
                let key = remove(wordList, 0)
            endif
        endif
        if !empty(wordList)
            if !exists('dbMap[key[0]]')
                let dbMap[key[0]] = []
            endif
            call add(dbMap[key[0]], ZFVimIM_dbItemEncode({
                        \   'key' : key,
                        \   'wordList' : wordList,
                        \   'countList' : [],
                        \ }))
        endif
    endfor
    call ZFVimIM_DEBUG_profileStop()

    let dbCountFile = get(a:, 1, '')
    if filereadable(dbCountFile)
        call ZFVimIM_DEBUG_profileStart('dbLoadCountFile')
        let lines = readfile(dbCountFile)
        call ZFVimIM_DEBUG_profileStop()

        call ZFVimIM_DEBUG_profileStart('dbLoadCount')
        for line in lines
            let countTextList = split(line)
            if len(countTextList) <= 1
                continue
            endif
            let key = countTextList[0]
            let index = match(get(dbMap, key[0], []), '^' . key . g:ZFVimIM_KEY_S_MAIN)
            if index < 0
                continue
            endif
            let dbItem = ZFVimIM_dbItemDecode(dbMap[key[0]][index])
            let wordListLen = len(dbItem['wordList'])
            for i in range(len(countTextList) - 1)
                if i >= wordListLen
                    break
                endif
                let dbItem['countList'][i] = str2nr(countTextList[i + 1])
            endfor
            call ZFVimIM_dbItemReorder(dbItem)
            let dbMap[key[0]][index] = ZFVimIM_dbItemEncode(dbItem)
        endfor
        call ZFVimIM_DEBUG_profileStop()
    endif
endfunction

function! s:dbSave(db, dbFile, ...)
    let dbCountFile = get(a:, 1, '')

    let dbMap = a:db['dbMap']
    let lines = []
    " do not use `filewritable()`, since a not exist file is not treated `writable`
    if empty(dbCountFile)
        call ZFVimIM_DEBUG_profileStart('dbSave')
        for c in keys(dbMap)
            for dbItemEncoded in dbMap[c]
                let dbItem = ZFVimIM_dbItemDecode(dbItemEncoded)
                let line = dbItem['key']
                for word in dbItem['wordList']
                    let line .= ' '
                    let line .= substitute(word, ' ', '\\ ', 'g')
                endfor
                call add(lines, line)
            endfor
        endfor
        call ZFVimIM_DEBUG_profileStop()

        call ZFVimIM_DEBUG_profileStart('dbSaveFile')
        call writefile(lines, a:dbFile)
        call ZFVimIM_DEBUG_profileStop()
    else
        let countLines = []
        call ZFVimIM_DEBUG_profileStart('dbSave')
        for c in keys(dbMap)
            for dbItemEncoded in dbMap[c]
                let dbItem = ZFVimIM_dbItemDecode(dbItemEncoded)
                let line = dbItem['key']
                let countLine = dbItem['key']
                for word in dbItem['wordList']
                    let line .= ' '
                    let line .= substitute(word, ' ', '\\ ', 'g')
                endfor
                call add(lines, line)
                for cnt in dbItem['countList']
                    if cnt <= 0
                        break
                    endif
                    let countLine .= ' '
                    let countLine .= cnt
                endfor
                if countLine != dbItem['key']
                    call add(countLines, countLine)
                endif
            endfor
        endfor
        call ZFVimIM_DEBUG_profileStop()

        call ZFVimIM_DEBUG_profileStart('dbSaveFile')
        call writefile(lines, a:dbFile)
        call ZFVimIM_DEBUG_profileStop()

        call ZFVimIM_DEBUG_profileStart('dbSaveCountFile')
        call writefile(countLines, dbCountFile)
        call ZFVimIM_DEBUG_profileStop()
    endif
endfunction

" ============================================================
function! s:dbEditWildKey(db, word, key, action)
    if empty(a:db)
        if g:ZFVimIM_dbIndex >= len(g:ZFVimIM_db)
            return
        endif
        let db = g:ZFVimIM_db[g:ZFVimIM_dbIndex]
    else
        let db = a:db
    endif
    if !get(db, 'editable', 1) || !empty(get(db, 'dbCallback', ''))
        return
    endif
    if !empty(a:key)
        call s:dbEdit(db, a:word, a:key, a:action)
        return
    endif
    if empty(a:word)
        return
    endif

    let keyToApply = []
    let dbMap = db['dbMap']
    for c in keys(dbMap)
        let index = match(dbMap[c], ''
                    \ . '\(' . g:ZFVimIM_KEY_S_MAIN . '\|' . g:ZFVimIM_KEY_S_SUB . '\)'
                    \ . a:word
                    \ . '\(' . g:ZFVimIM_KEY_S_MAIN . '\|' . g:ZFVimIM_KEY_S_SUB . '\|$\)'
                    \ )
        if index >= 0
            call add(keyToApply, ZFVimIM_dbItemDecode(dbMap[c][index])['key'])
        endif
    endfor

    for key in keyToApply
        call s:dbEdit(db, a:word, key, a:action)
    endfor
endfunction

function! s:dbEdit(db, word, key, action)
    if empty(a:db)
        if g:ZFVimIM_dbIndex >= len(g:ZFVimIM_db)
            return
        endif
        let db = g:ZFVimIM_db[g:ZFVimIM_dbIndex]
    else
        let db = a:db
    endif
    if !get(db, 'editable', 1) || !empty(get(db, 'dbCallback', ''))
        return
    endif
    if empty(a:key) || empty(a:word)
        return
    endif

    let dbEditItem = {
                \   'action' : a:action,
                \   'key' : a:key,
                \   'word' : a:word,
                \ }

    if !exists("db['dbEdit']")
        let db['dbEdit'] = []
    endif
    call add(db['dbEdit'], dbEditItem)

    let dbEditLimit = get(g:, 'ZFVimIM_dbEditLimit', 500)
    if dbEditLimit > 0 && len(db['dbEdit']) > dbEditLimit
        call remove(db['dbEdit'], 0, len(db['dbEdit']) - dbEditLimit - 1)
    endif

    call s:dbEditApply(db, [dbEditItem])
    doautocmd User ZFVimIM_event_OnUpdateDb
endfunction

function! s:dbEditApply(db, dbEdit)
    call ZFVimIM_DEBUG_profileStart('dbEditApply')
    call s:dbEditMap(a:db, a:dbEdit)
    call ZFVimIM_DEBUG_profileStop()
endfunction

function! s:dbEditMap(db, dbEdit)
    let dbMap = a:db['dbMap']
    let dbEdit = a:dbEdit
    for e in dbEdit
        let key = e['key']
        let word = e['word']
        if e['action'] == 'add'
            if !exists('dbMap[key[0]]')
                let dbMap[key[0]] = []
            endif
            let index = ZFVimIM_dbSearch(a:db, key[0],
                        \ '^' . key . g:ZFVimIM_KEY_S_MAIN,
                        \ 0)
            if index >= 0
                let dbItem = ZFVimIM_dbItemDecode(dbMap[key[0]][index])
                let wordIndex = index(dbItem['wordList'], word)
                if wordIndex >= 0
                    let dbItem['countList'][wordIndex] += 1
                else
                    call add(dbItem['wordList'], word)
                    call add(dbItem['countList'], 1)
                endif
                call ZFVimIM_dbItemReorder(dbItem)
                let dbMap[key[0]][index] = ZFVimIM_dbItemEncode(dbItem)
            else
                call add(dbMap[key[0]], ZFVimIM_dbItemEncode({
                            \   'key' : key,
                            \   'wordList' : [word],
                            \   'countList' : [1],
                            \ }))
                call ZFVimIM_dbSearchCacheClear(a:db)
            endif
        elseif e['action'] == 'remove'
            let index = ZFVimIM_dbSearch(a:db, key[0],
                        \ '^' . key . g:ZFVimIM_KEY_S_MAIN,
                        \ 0)
            if index < 0
                continue
            endif
            let dbItem = ZFVimIM_dbItemDecode(dbMap[key[0]][index])
            let wordIndex = index(dbItem['wordList'], word)
            if wordIndex < 0
                continue
            endif
            call remove(dbItem['wordList'], wordIndex)
            call remove(dbItem['countList'], wordIndex)
            if empty(dbItem['wordList'])
                call remove(dbMap[key[0]], index)
                if empty(dbMap[key[0]])
                    call remove(dbMap, key[0])
                endif
                call ZFVimIM_dbSearchCacheClear(a:db)
            else
                let dbMap[key[0]][index] = ZFVimIM_dbItemEncode(dbItem)
            endif
        elseif e['action'] == 'reorder'
            let index = ZFVimIM_dbSearch(a:db, key[0],
                        \ '^' . key . g:ZFVimIM_KEY_S_MAIN,
                        \ 0)
            if index < 0
                continue
            endif
            let dbItem = ZFVimIM_dbItemDecode(dbMap[key[0]][index])
            let wordIndex = index(dbItem['wordList'], word)
            if wordIndex < 0
                continue
            endif
            let dbItem['countList'][wordIndex] = 0
            let sum = 0
            for cnt in dbItem['countList']
                let sum += cnt
            endfor
            let dbItem['countList'][wordIndex] = float2nr(sum / 2)
            call ZFVimIM_dbItemReorder(dbItem)
            let dbMap[key[0]][index] = ZFVimIM_dbItemEncode(dbItem)
        endif
    endfor
endfunction

" ============================================================
if 0 " test db
    let g:ZFVimIM_db = [{
                \   'dbId' : '999',
                \   'name' : 'test',
                \   'priority' : 100,
                \   'dbMap' : {
                \     'a' : [
                \       'a#啊,阿#3,2',
                \       'ai#爱,哀#2',
                \     ],
                \     'a' : [
                \       'ceshi#测试',
                \     ],
                \   },
                \   'dbEdit' : [
                \   ],
                \   'implData' : {
                \   },
                \ }]
endif

