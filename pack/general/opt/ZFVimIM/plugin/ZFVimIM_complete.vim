
" params:
"   key : the input key, e.g. `ceshi`
"   option: {
"     'sentence' : '0/1, default to g:ZFVimIM_sentence',
"     'crossDb' : 'maxNum, default to g:ZFVimIM_crossDbLimit',
"     'predict' : 'maxNum, default to g:ZFVimIM_predictLimit',
"     'match' : '', // > 0 : limit to this num, allow sub match
"                   // = 0 : disable match
"                   // < 0 : limit to (0-match) num, disallow sub match
"                   // default to g:ZFVimIM_matchLimit
"     'db' : {
"       // db object in g:ZFVimIM_db
"       // when specified, use the specified db, otherwise use current db
"     },
"   }
" return : [
"   {
"     'dbId' : 'match from which db',
"     'len' : 'match count in key',
"     'key' : 'matched full key',
"     'word' : 'matched word',
"     'type' : 'type of completion: sentence/match/predict/subMatch',
"     'sentenceList' : [ // (optional) for sentence type only, list of word that complete as sentence
"       {
"         'key' : '',
"         'word' : '',
"       },
"     ],
"   },
"   ...
" ]
function! ZFVimIM_completeDefault(key, ...)
    call ZFVimIM_DEBUG_profileStart('complete')
    let ret = s:completeDefault(a:key, get(a:, 1, {}))
    call ZFVimIM_DEBUG_profileStop()
    return ret
endfunction

function! s:completeDefault(key, ...)
    let option = get(a:, 1, {})
    let db = get(option, 'db', {})
    if empty(db) && g:ZFVimIM_dbIndex < len(g:ZFVimIM_db)
        let db = g:ZFVimIM_db[g:ZFVimIM_dbIndex]
    endif
    if empty(a:key) || empty(db)
        return []
    endif

    if !exists("option['dbSearchCache']")
        let option['dbSearchCache'] = {}
    endif

    if ZFVimIM_funcCallable(get(db, 'dbCallback', ''))
        let option = copy(option)
        let option['db'] = db
        call ZFVimIM_DEBUG_profileStart('dbCallback')
        let ret = ZFVimIM_funcCall(db['dbCallback'], [a:key, option])
        call ZFVimIM_DEBUG_profileStop()
        for item in ret
            if !exists("item['dbId']")
                let item['dbId'] = db['dbId']
            endif
        endfor
        return ret
    endif

    let data = {
                \   'sentence' : [],
                \   'crossDb' : [],
                \   'predict' : [],
                \   'match' : [],
                \   'subMatch' : [],
                \ }

    call s:complete_sentence(data['sentence'], a:key, option, db)
    call s:complete_crossDb(data['crossDb'], a:key, option, db)
    call s:complete_predict(data['predict'], a:key, option, db)
    call s:complete_match(data['match'], data['subMatch'], a:key, option, db)

    return s:mergeResult(data, a:key, option, db)
endfunction


" complete exact match only
function! ZFVimIM_completeExact(key, ...)
    let max = get(a:, 1, -1)
    if max < 0
        let max = 99999
    endif
    return ZFVimIM_complete(a:key, {
                \   'sentence' : 0,
                \   'crossDb' : 0,
                \   'predict' : 0,
                \   'match' : (0 - max),
                \ })
endfunction


function! s:complete_sentence(ret, key, option, db)
    if !get(a:option, 'sentence', g:ZFVimIM_sentence)
        return
    endif

    let sentence = {
                \   'dbId' : a:db['dbId'],
                \   'len' : 0,
                \   'key' : '',
                \   'word' : '',
                \   'type' : 'sentence',
                \   'sentenceList' : [],
                \ }
    let keyLen = len(a:key)
    let iL = 0
    let iR = keyLen
    while iL < keyLen && iR > iL
        let subKey = strpart(a:key, iL, iR - iL)
        let index = ZFVimIM_dbSearch(a:db, subKey[0],
                    \ '^' . subKey,
                    \ 0)
        if index < 0
            let iR -= 1
            continue
        endif
        let index = ZFVimIM_dbSearch(a:db, subKey[0],
                    \ '^' . subKey . g:ZFVimIM_KEY_S_MAIN,
                    \ 0)
        if index < 0
            let iR -= 1
            continue
        endif

        let dbItem = ZFVimIM_dbItemDecode(a:db['dbMap'][subKey[0]][index])
        if empty(dbItem['wordList'])
            let iR -= 1
            continue
        endif
        let sentence['len'] += len(subKey)
        let sentence['key'] .= subKey
        let sentence['word'] .= dbItem['wordList'][0]
        call add(sentence['sentenceList'], {
                    \   'key' : subKey,
                    \   'word' : dbItem['wordList'][0],
                    \ })
        let iL = iR
        let iR = keyLen
    endwhile

    if len(sentence['sentenceList']) > 1
        call add(a:ret, sentence)
    endif
endfunction


function! s:complete_crossDb(ret, key, option, db)
    if get(a:option, 'crossDb', g:ZFVimIM_crossDbLimit) <= 0
        return
    endif

    let crossDbRetList = []
    for crossDbTmp in g:ZFVimIM_db
        if crossDbTmp['dbId'] == a:db['dbId']
                    \ || crossDbTmp['crossable'] == 0
                    \ || crossDbTmp['crossDbLimit'] <= 0
            continue
        endif

        let otherDbRetLimit = crossDbTmp['crossDbLimit']
        let otherDbRet = ZFVimIM_complete(a:key, {
                    \   'sentence' : 0,
                    \   'crossDb' : 0,
                    \   'predict' : ((crossDbTmp['crossable'] >= 2) ? otherDbRetLimit : 0),
                    \   'match' : ((crossDbTmp['crossable'] >= 3) ? otherDbRetLimit : (0 - otherDbRetLimit)),
                    \   'db' : crossDbTmp,
                    \ })
        if !empty(otherDbRet)
            if len(otherDbRet) > otherDbRetLimit
                call remove(otherDbRet, otherDbRetLimit, -1)
            endif
            call add(crossDbRetList, otherDbRet)
        endif
    endfor
    if empty(crossDbRetList)
        return
    endif

    " before g:ZFVimIM_crossDbLimit, take first from each cross db, if match
    let crossDbIndex = 0
    let hasMatch = 0
    while !empty(crossDbRetList) && len(a:ret) < g:ZFVimIM_crossDbLimit
        if empty(crossDbRetList[crossDbIndex])
            call remove(crossDbRetList, crossDbIndex)
            let crossDbIndex = crossDbIndex % len(crossDbRetList)
            continue
        endif
        if crossDbRetList[crossDbIndex][0]['type'] == 'match'
            call add(a:ret, crossDbRetList[crossDbIndex][0])
            call remove(crossDbRetList[crossDbIndex], 0)
        endif
        let crossDbIndex = (crossDbIndex + 1) % len(crossDbRetList)
        if crossDbIndex == 0
            if !hasMatch
                break
            else
                let hasMatch = 0
            endif
        endif
    endwhile

    " before g:ZFVimIM_crossDbLimit, take first from each cross db, even if not match
    let crossDbIndex = 0
    while !empty(crossDbRetList) && len(a:ret) < g:ZFVimIM_crossDbLimit
        if empty(crossDbRetList[crossDbIndex])
            call remove(crossDbRetList, crossDbIndex)
            let crossDbIndex = crossDbIndex % len(crossDbRetList)
            continue
        endif
        call add(a:ret, crossDbRetList[crossDbIndex][0])
        call remove(crossDbRetList[crossDbIndex], 0)
        let crossDbIndex = (crossDbIndex + 1) % len(crossDbRetList)
    endwhile

    " after g:ZFVimIM_crossDbLimit, add all to tail, by db index
    for crossDbRet in crossDbRetList
        call extend(a:ret, crossDbRet)
    endfor
endfunction

function! s:complete_predict(ret, key, option, db)
    let predictLimit = get(a:option, 'predict', g:ZFVimIM_predictLimit)
    if predictLimit <= 0
        return
    endif

    let p = len(a:key)
    while p > 0
        " try to find
        let subKey = strpart(a:key, 0, p)
        let subMatchIndex = ZFVimIM_dbSearch(a:db, a:key[0],
                    \ '^' . subKey,
                    \ 0)
        if subMatchIndex < 0
            let p -= 1
            continue
        endif
        let dbItem = ZFVimIM_dbItemDecode(a:db['dbMap'][a:key[0]][subMatchIndex])

        " found things to predict
        let wordIndex = 0
        while len(a:ret) < predictLimit
            call add(a:ret, {
                        \   'dbId' : a:db['dbId'],
                        \   'len' : p,
                        \   'key' : dbItem['key'],
                        \   'word' : dbItem['wordList'][wordIndex],
                        \   'type' : 'predict',
                        \ })
            let wordIndex += 1
            if wordIndex < len(dbItem['wordList'])
                continue
            endif

            " find next predict
            let subMatchIndex = ZFVimIM_dbSearch(a:db, a:key[0],
                        \ '^' . subKey,
                        \ subMatchIndex + 1)
            if subMatchIndex < 0
                break
            endif
            let dbItem = ZFVimIM_dbItemDecode(a:db['dbMap'][a:key[0]][subMatchIndex])
            let wordIndex = 0
        endwhile

        break
    endwhile
endfunction

function! s:complete_match(matchRet, subMatchRet, key, option, db)
    let matchLimit = get(a:option, 'match', g:ZFVimIM_matchLimit)
    if matchLimit < 0
        call s:complete_match_exact(a:matchRet, a:key, a:option, a:db, 0 - matchLimit)
    elseif matchLimit > 0
        call s:complete_match_allowSubMatch(a:matchRet, a:subMatchRet, a:key, a:option, a:db, matchLimit)
    endif
endfunction

function! s:complete_match_exact(ret, key, option, db, matchLimit)
    let index = ZFVimIM_dbSearch(a:db, a:key[0],
                \ '^' . a:key,
                \ 0)
    if index < 0
        return
    endif
    let index = ZFVimIM_dbSearch(a:db, a:key[0],
                \ '^' . a:key . g:ZFVimIM_KEY_S_MAIN,
                \ 0)
    if index < 0
        return
    endif

    " found match
    let matchLimit = a:matchLimit
    let keyLen = len(a:key)
    while index >= 0
        let dbItem = ZFVimIM_dbItemDecode(a:db['dbMap'][a:key[0]][index])
        if len(dbItem['wordList']) < matchLimit
            let numToAdd = len(dbItem['wordList'])
        else
            let numToAdd = matchLimit
        endif
        let matchLimit -= numToAdd
        let wordIndex = 0
        while wordIndex < numToAdd
            call add(a:ret, {
                        \   'dbId' : a:db['dbId'],
                        \   'len' : keyLen,
                        \   'key' : a:key,
                        \   'word' : dbItem['wordList'][wordIndex],
                        \   'type' : 'match',
                        \ })
            let wordIndex += 1
        endwhile
        if matchLimit <= 0
            break
        endif
        let index = ZFVimIM_dbSearch(a:db, a:key[0],
                    \ '^' . a:key . g:ZFVimIM_KEY_S_MAIN,
                    \ index + 1)
    endwhile
endfunction

function! s:complete_match_allowSubMatch(matchRet, subMatchRet, key, option, db, matchLimit)
    let matchLimit = a:matchLimit
    let keyLen = len(a:key)
    let p = keyLen
    while p > 0 && matchLimit > 0
        let subKey = strpart(a:key, 0, p)
        let index = ZFVimIM_dbSearch(a:db, a:key[0],
                    \ '^' . subKey,
                    \ 0)
        if index < 0
            let p -= 1
            continue
        endif
        let index = ZFVimIM_dbSearch(a:db, a:key[0],
                    \ '^' . subKey . g:ZFVimIM_KEY_S_MAIN,
                    \ 0)
        if index < 0
            let p -= 1
            continue
        endif

        " found match
        let dbItem = ZFVimIM_dbItemDecode(a:db['dbMap'][a:key[0]][index])
        if len(dbItem['wordList']) < matchLimit
            let numToAdd = len(dbItem['wordList'])
        else
            let numToAdd = matchLimit
        endif
        let matchLimit -= numToAdd
        let wordIndex = 0
        while wordIndex < numToAdd
            let isMatch = (p == keyLen)
            call add(isMatch ? a:matchRet : a:subMatchRet, {
                        \   'dbId' : a:db['dbId'],
                        \   'len' : p,
                        \   'key' : subKey,
                        \   'word' : dbItem['wordList'][wordIndex],
                        \   'type' : (isMatch ? 'match' : 'subMatch'),
                        \ })
            let wordIndex += 1
        endwhile

        let p -= 1
    endwhile
endfunction

function! s:removeDuplicate(ret, exists)
    let i = 0
    let iEnd = len(a:ret)
    while i < iEnd
        let item = a:ret[i]
        let hash = item['key'] . item['word']
        if exists('a:exists[hash]')
            call remove(a:ret, i)
            let iEnd -= 1
            let i -= 1
        else
            let a:exists[hash] = 1
        endif
        let i += 1
    endwhile
endfunction
" data: {
"   'sentence' : [],
"   'crossDb' : [],
"   'predict' : [],
"   'match' : [],
" }
" return final result list
function! s:mergeResult(data, key, option, db)
    let ret = []
    let sentenceRet = a:data['sentence']
    let crossDbRet = a:data['crossDb']
    let predictRet = a:data['predict']
    let matchRet = a:data['match']
    let subMatchRet = a:data['subMatch']
    let tailRet = []

    " remove duplicate
    let exists = {}
    " ordered from high priority to low
    call s:removeDuplicate(matchRet, exists)
    call s:removeDuplicate(predictRet, exists)
    call s:removeDuplicate(sentenceRet, exists)
    call s:removeDuplicate(subMatchRet, exists)
    call s:removeDuplicate(crossDbRet, exists)

    " crossDb may return different type
    let iCrossDb = 0
    while iCrossDb < len(crossDbRet)
        if 0
        elseif crossDbRet[iCrossDb]['type'] == 'sentence'
            call add(sentenceRet, remove(crossDbRet, iCrossDb))
        elseif crossDbRet[iCrossDb]['type'] == 'predict'
            call add(predictRet, remove(crossDbRet, iCrossDb))
        elseif crossDbRet[iCrossDb]['type'] == 'match'
            call add(matchRet, remove(crossDbRet, iCrossDb))
        else
            let iCrossDb += 1
        endif
    endwhile

    " limit predict if has match
    if len(sentenceRet) + len(matchRet) + len(subMatchRet) >= 5 && len(predictRet) > g:ZFVimIM_predictLimitWhenMatch
        call extend(tailRet, remove(predictRet, g:ZFVimIM_predictLimitWhenMatch, len(predictRet) - 1))
    endif

    " order:
    "   exact match
    "   sentence
    "   predict(len > match)
    "   subMatch
    "   predict(len <= match)
    "   tail
    "   all crossDb
    call extend(ret, matchRet)
    call extend(ret, sentenceRet)

    " longer predict should higher than match for smart recommend
    let maxMatchLen = 0
    if !empty(subMatchRet)
        let maxMatchLen = subMatchRet[0]['len']
    endif
    if maxMatchLen > 0
        let iPredict = 0
        while iPredict < len(predictRet)
            if predictRet[iPredict]['len'] > maxMatchLen
                call add(ret, remove(predictRet, iPredict))
            else
                let iPredict += 1
            endif
        endwhile
    endif

    call extend(ret, subMatchRet)
    call extend(ret, predictRet)
    call extend(ret, tailRet)


    " crossDb should be placed at lower order,
    if g:ZFVimIM_crossDbPos >= len(ret)
        call extend(ret, crossDbRet)
    elseif len(crossDbRet) > g:ZFVimIM_crossDbLimit
        let i = 0
        let iEnd = g:ZFVimIM_crossDbLimit
        while i < iEnd
            call insert(ret, crossDbRet[i], g:ZFVimIM_crossDbPos + i)
            let i += 1
        endwhile
        let iEnd = len(crossDbRet)
        while i < iEnd
            call insert(ret, crossDbRet[i], g:ZFVimIM_crossDbPos + i)
            let i += 1
        endwhile
    else
        let i = 0
        let iEnd = len(crossDbRet)
        while i < iEnd
            call insert(ret, crossDbRet[i], g:ZFVimIM_crossDbPos + i)
            let i += 1
        endwhile
    endif

    return ret
endfunction

