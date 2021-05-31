" ============================================================
" options
" ============================================================

" whether to show files that are same
if !exists('g:ZFDirDiffShowSameFile')
    let g:ZFDirDiffShowSameFile = 1
endif

" file name exclude pattern, e.g. `*.class,*.o`
if !exists('g:ZFDirDiffFileExclude')
    let g:ZFDirDiffFileExclude = ''
endif
if get(g:, 'ZFDirDiffFileExcludeUseDefault', 1)
    augroup ZFDirDiffFileExclude_augroup
        autocmd!
        autocmd User ZFIgnoreOnUpdate let g:ZFDirDiffFileExclude = join(ZFIgnoreToWildignore(ZFIgnoreGet(get(g:, 'ZFIgnoreOption_ZFDirDiff', {
                    \   'bin' : 0,
                    \   'media' : 0,
                    \   'ZFDirDiff' : 1,
                    \ }))), ',')
    augroup END
endif

" file content exclude pattern, e.g. `log:,id:`
if !exists('g:ZFDirDiffContentExclude')
    let g:ZFDirDiffContentExclude = ''
endif

" whether ignore file name case
if !exists('g:ZFDirDiffFileIgnoreCase')
    let g:ZFDirDiffFileIgnoreCase = 0
endif

" additional diff args passed to `diff`
if !exists('g:ZFDirDiffCustomDiffArg')
    let g:ZFDirDiffCustomDiffArg = ''
endif

" diff lang string
if !exists('g:ZFDirDiffLang')
    let g:ZFDirDiffLang = ''
endif
if !exists('g:ZFDirDiffLangString')
    if has('win32') && !has('win32unix')
        let g:ZFDirDiffLangString = 'SET LANG=' . g:ZFDirDiffLang . ' && '
    else
        let g:ZFDirDiffLangString = 'LANG=' . g:ZFDirDiffLang . ' '
    endif
endif
if !exists('*ZF_DirDiffTempname')
    function! ZF_DirDiffTempname()
        return CygpathFix_absPath(tempname())
    endfunction
endif
if !exists('*ZF_DirDiffShellEnv_pathFormat')
    function! ZF_DirDiffShellEnv_pathFormat(path)
        return fnamemodify(a:path, ':.')
    endfunction
endif

" sort function
if !exists('g:ZFDirDiffSortFunc')
    let g:ZFDirDiffSortFunc = 'ZF_DirDiffSortFunc'
endif
function! ZF_DirDiffSortFunc(item0, item1)
    let priority0 = s:ZF_DirDiffSortFunc_priority(a:item0.type)
    let priority1 = s:ZF_DirDiffSortFunc_priority(a:item1.type)
    if priority0 != priority1
        return (priority0 > priority1) ? -1 : 1
    endif

    return (a:item0.name < a:item1.name) ? -1 : 1
endfunction
function! s:ZF_DirDiffSortFunc_priority(type)
    if a:type == 'T_DIR' || a:type == 'T_DIR_LEFT' || a:type == 'T_DIR_RIGHT'
        return 2
    elseif a:type == 'T_CONFLICT_DIR_LEFT' || a:type == 'T_CONFLICT_DIR_RIGHT'
        return 1
    else
        return 0
    endif
endfunction

" ============================================================

let g:ZFDirDiff_exitCode_NoDiff = 0
let g:ZFDirDiff_exitCode_HasDiff = 1
let g:ZFDirDiff_exitCode_BothFile = -9999

" return: {
"   'cmd' : 'original diff cmd',
"   'output' : 'output of diff',
"   'exitCode' : 'v:shell_error of diff',
"   'exitHint' : 'state hint',
"   'data' : [
"       {
"           'level' : 'depth of tree node, 0 for top most ones',
"           'path' : 'path relative to fileLeft/fileRight',
"           'name' : 'file or dir name, empty if fileLeft and fileRight is file',
"           'type' : '',
"               // T_DIR: current node is dir
"               // T_SAME: current node is file and has no diff
"               // T_DIFF: current node is file and has diff
"               // T_DIR_LEFT: only left exists and it is dir
"               // T_DIR_RIGHT: only right exists and it is dir
"               // T_FILE_LEFT: only left exists and it is dir
"               // T_FILE_RIGHT: only right exists and it is dir
"               // T_CONFLICT_DIR_LEFT: left is dir and right is file
"               // T_CONFLICT_DIR_RIGHT: left is file and right is dir
"           'diff' : '0/1, whether this node or children node contains diff',
"           'children' : [
"               ...
"           ],
"       },
"       ...
"   ]
" }
"
" all type: {T_DIR,T_SAME,T_DIFF,T_DIR_LEFT,T_DIR_RIGHT,T_FILE_LEFT,T_FILE_RIGHT,T_CONFLICT_DIR_LEFT,T_CONFLICT_DIR_RIGHT}
function! ZF_DirDiffCore(fileLeft, fileRight)
    let ret = {
                \   'cmd' : '',
                \   'output' : '',
                \   'exitCode' : '',
                \   'exitHint' : '',
                \   'data' : [],
                \ }

    let fileLeft = ZF_DirDiffShellEnv_pathFormat(ZF_DirDiffPathFormat(a:fileLeft))
    let fileRight = ZF_DirDiffShellEnv_pathFormat(ZF_DirDiffPathFormat(a:fileRight))

    if filereadable(fileLeft) && filereadable(fileRight)
        let ret['exitCode'] = g:ZFDirDiff_exitCode_BothFile
        let ret['exitHint'] = '[ZFDirDiff] left and right are both files'
        return ret
    endif

    redraw!
    echo '[ZFDirDiff] running diff, it may take a while...'
    let diffResult = ZF_DirDiffCmd(a:fileLeft, a:fileRight)
    call extend(ret, diffResult)

    if diffResult['exitCode'] == g:ZFDirDiff_exitCode_NoDiff
        " nothing to do
        " same file should also be parsed and show in diff window
    elseif diffResult['exitCode'] != g:ZFDirDiff_exitCode_HasDiff
        let ret['exitHint'] = '[ZFDirDiff] diff failed with exit code: ' . diffResult['exitCode']
        echo ret['exitHint']
        for line in diffResult['output']
            if !empty(line)
                echo '    ' . line
            endif
        endfor
        return ret
    endif

    let ret['data'] = s:parse(fileLeft, fileRight, diffResult['output'])
    echo '[ZFDirDiff] sorting result, it may take a while...'
    call s:sortResult(ret['data'])

    redraw!
    if diffResult['exitCode'] == g:ZFDirDiff_exitCode_NoDiff
        let ret['exitHint'] = '[ZFDirDiff] no diff found'
    else
        let ret['exitHint'] = '[ZFDirDiff] diff complete'
    endif
    echo ret['exitHint']
    return ret
endfunction

" return: {
"   'cmd' : 'original diff cmd',
"   'output' : 'output of diff',
"   'exitCode' : 'v:shell_error of diff',
" }
function! ZF_DirDiffCmd(fileLeft, fileRight, ...)
    let checkOnly = get(a:, 1, 0)
    let fileLeft = ZF_DirDiffShellEnv_pathFormat(ZF_DirDiffPathFormat(a:fileLeft))
    let fileRight = ZF_DirDiffShellEnv_pathFormat(ZF_DirDiffPathFormat(a:fileRight))

    " use temp file to solve encoding issue
    let tmpFile = ZF_DirDiffTempname()
    let cmd = g:ZFDirDiffLangString . 'diff'
    let cmdarg = ' -r --brief'

    if g:ZFDirDiffShowSameFile
        let cmdarg .= ' -s'
    endif
    if g:ZFDirDiffFileIgnoreCase
        let cmdarg .= ' -i'
    endif
    if g:ZFDirDiffCustomDiffArg != ''
        let cmdarg .= ' ' . g:ZFDirDiffCustomDiffArg . ' '
    endif
    if g:ZFDirDiffFileExclude != ''
        let excludeFile = ZF_DirDiffTempname()
        call writefile(split(g:ZFDirDiffFileExclude, ','), excludeFile)
        let cmdarg .= ' -X "' . excludeFile . '"'
    else
        let excludeFile = ''
    endif
    if g:ZFDirDiffContentExclude != ''
        let cmdarg .= ' -I"' . substitute(g:ZFDirDiffContentExclude, ',', '" -I"', 'g') . '"'
    endif
    let cmd = cmd . cmdarg . ' "' . fileLeft . '" "' . fileRight . '"'
    let cmd = cmd . ' > "' . tmpFile . '" 2>&1'

    if checkOnly
        let exitCode = 0
    else
        call system(cmd)
        let exitCode = v:shell_error
    endif
    redraw!
    if !empty(excludeFile)
        call delete(excludeFile)
    endif

    if checkOnly
        let output = ''
    else
        let output = readfile(tmpFile)
        silent! call delete(tmpFile)
    endif

    return {
                \   'cmd' : cmd,
                \   'output' : output,
                \   'exitCode' : exitCode,
                \ }
endfunction

function! ZF_DirDiffPathFormat(path, ...)
    let path = a:path
    let path = CygpathFix_absPath(path)
    if !empty(get(a:, 1, ''))
        let mod_path = fnamemodify(path, a:1)
        if get(a:, 1, '') == ':.' && path != mod_path
            " If relative path under cwd, then prefix with . to show it's
            " relative.
            let mod_path = './' . mod_path
        endif
        let path = mod_path
    endif
    let path = substitute(path, '\\$\|/$', '', '')
    return substitute(path, '\\', '/', 'g')
endfunction

function! ZF_DirDiffPathHint(path, ...)
    if isdirectory(a:path)
        return ZF_DirDiffPathFormat(a:path, get(a:, 1, '')) . '/'
    else
        return ZF_DirDiffPathFormat(a:path, get(a:, 1, ''))
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

" ============================================================
" $ diff -rq left right
" Files left/p0/p1/a.txt and right/p0/p1/a.txt differ
" Only in right/p0/p1: b.txt
" Only in left/p0/p1: c.txt
" Only in left/p0/p1: 的.txt
" File left/p0/p1/conflict_left is a directory while file right/p0/p1/conflict_left is a regular file
" File left/p0/p1/conflict_right is a regular file while file right/p0/p1/conflict_right is a directory
" Only in left/p0/p1: dir
" Files test/left/p0/p1/dir_same/a.txt and test/right/p0/p1/dir_same/a.txt are identical
"
" types:
" * Files [A]/p0/p1/a.txt and [B]/p0/p1/a.txt differ
" * Files [A]/p0/p1/a.txt and [B]/p0/p1/a.txt are identical
" * Only in [B]/p0/p1: b.txt
" * File [A]/p0/p1/conflict_left is a directory while file [B]/p0/p1/conflict_left is a regular file
" * File [A]/p0/p1/conflict_right is a regular file while file [B]/p0/p1/conflict_right is a directory
" ============================================================
function! s:parse(fileLeft, fileRight, content)
    let pDiff = get(g:, 'ZFDirDiff_patternDiff',
                \ 'Files \(.*\) and \(.*\) differ')
    let pSame = get(g:, 'ZFDirDiff_patternSame',
                \ 'Files \(.*\) and \(.*\) are identical')
    let pOnly = get(g:, 'ZFDirDiff_patternOnly',
                \ 'Only in \(.*\): \(.*\)')
    let pConflictL = get(g:, 'ZFDirDiff_patternConflictL',
                \ 'File \(.*\) is a directory while file \(.*\) is a regular file')
    let pConflictR = get(g:, 'ZFDirDiff_patternConflictR',
                \ 'File \(.*\) is a regular file while file \(.*\) is a directory')

    let fileLeft = substitute(a:fileLeft, '\', '/', 'g')
    let fileRight = substitute(a:fileRight, '\', '/', 'g')

    let data = []
    for line in a:content
        let line = substitute(line, '\', '/', 'g')
        if 0
        elseif match(line, pSame) >= 0
            let left = substitute(line, pSame, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(fileLeft, fileRight, data, path, 'T_SAME')
        elseif match(line, pDiff) >= 0
            let left = substitute(line, pDiff, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(fileLeft, fileRight, data, path, 'T_DIFF')
        elseif match(line, pOnly) >= 0
            let path = substitute(line, pOnly, '\1', '')
            let file = substitute(line, pOnly, '\2', '')

            let matchLeft = (match(path, fileLeft) >= 0)
            let matchRight = (match(path, fileRight) >= 0)
            if matchLeft && matchRight
                if len(fileLeft) >= len(fileRight)
                    let matchRight = 0
                else
                    let matchLeft = 0
                endif
            endif

            let parent = matchLeft ? fileLeft : fileRight
            let path = substitute(path, parent, '', '')
            let path = path . '/' . file
            if filereadable(parent . path)
                call s:addDiff(fileLeft, fileRight, data, path, matchLeft ? 'T_FILE_LEFT' : 'T_FILE_RIGHT')
            else
                let files = extend(split(globpath(parent . path, '**'), "\n"), split(globpath(parent . path, '**/.[^.]*'), "\n"))
                if empty(files)
                    call s:addDiff(fileLeft, fileRight, data, path, matchLeft ? 'T_DIR_LEFT' : 'T_DIR_RIGHT')
                else
                    for file in files
                        if filereadable(file)
                            let type = matchLeft ? 'T_FILE_LEFT' : 'T_FILE_RIGHT'
                        else
                            let type = matchLeft ? 'T_DIR_LEFT' : 'T_DIR_RIGHT'
                        endif
                        call s:addDiff(fileLeft, fileRight, data,
                                    \ substitute(substitute(file, '\', '/', 'g'), parent, '', ''), type)
                    endfor
                endif
            endif
        elseif match(line, pConflictL) >= 0
            let left = substitute(line, pConflictL, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(fileLeft, fileRight, data, path, 'T_CONFLICT_DIR_LEFT')
        elseif match(line, pConflictR) >= 0
            let left = substitute(line, pConflictR, '\1', '')
            let path = substitute(left, fileLeft, '', '')
            call s:addDiff(fileLeft, fileRight, data, path, 'T_CONFLICT_DIR_RIGHT')
        endif
    endfor
    return data
endfunction

function! s:addDiff(fileLeft, fileRight, data, path, type)
    let path = substitute(a:path, '\\', '/', 'g')
    let path = substitute(path, '^/\+', '', 'g')
    let path = substitute(path, '/\+$', '', 'g')
    if exists('*ZFDirDiffCustomFilter')
        if ZFDirDiffCustomFilter(path, a:type)
            return
        endif
    endif
    let diff = (a:type != 'T_SAME') ? 1 : 0
    let item = a:data
    let nameList = split(path, '/')
    let nameIndex = 0

    while nameIndex < len(nameList)
        let nameExists = 0
        for itItem in item
            if itItem.name == nameList[nameIndex]
                if diff
                    let itItem.diff = diff
                endif
                call s:fixDirOnlyType(itItem, a:type)
                let nameExists = 1
                let item = itItem.children
                break
            endif
        endfor
        if !nameExists
            break
        endif
        let nameIndex += 1
    endwhile

    while nameIndex < len(nameList)
        let newItem = {
                    \   'level' : nameIndex,
                    \   'path' : nameList[nameIndex],
                    \   'name' : nameList[nameIndex],
                    \   'type' : 'T_DIR',
                    \   'diff' : diff,
                    \   'children' : [],
                    \ }
        if nameIndex > 0
            let newItem.path = join(nameList[0:(nameIndex-1)], '/') . '/' . nameList[nameIndex]
        endif
        if nameIndex == len(nameList) - 1
            let newItem.type = a:type
        else
            if a:type == 'T_DIR_LEFT' || a:type == 'T_FILE_LEFT'
                if isdirectory(a:fileRight . '/' . newItem.path)
                    let newItem.type = 'T_DIR'
                else
                    let newItem.type = 'T_DIR_LEFT'
                endif
            elseif a:type == 'T_DIR_RIGHT' || a:type == 'T_FILE_RIGHT'
                if isdirectory(a:fileLeft . '/' . newItem.path)
                    let newItem.type = 'T_DIR'
                else
                    let newItem.type = 'T_DIR_RIGHT'
                endif
            endif
        endif

        call add(item, newItem)
        let item = newItem.children
        let nameIndex += 1
    endwhile
endfunction

function! s:fixDirOnlyType(item, addType)
    if a:item.type == 'T_DIR_LEFT'
        if 0
                    \ || a:addType == 'T_SAME'
                    \ || a:addType == 'T_DIFF'
                    \ || a:addType == 'T_CONFLICT_DIR_LEFT'
                    \ || a:addType == 'T_CONFLICT_DIR_RIGHT'
                    \ || a:addType == 'T_DIR_RIGHT'
                    \ || a:addType == 'T_FILE_RIGHT'
            let a:item.type = 'T_DIR'
        endif
    elseif a:item.type == 'T_DIR_RIGHT'
        if 0
                    \ || a:addType == 'T_SAME'
                    \ || a:addType == 'T_DIFF'
                    \ || a:addType == 'T_CONFLICT_DIR_LEFT'
                    \ || a:addType == 'T_CONFLICT_DIR_RIGHT'
                    \ || a:addType == 'T_DIR_LEFT'
                    \ || a:addType == 'T_FILE_LEFT'
            let a:item.type = 'T_DIR'
        endif
    endif
endfunction

function! s:sortResult(data)
    call sort(a:data, g:ZFDirDiffSortFunc)
    for item in a:data
        call s:sortResult(item.children)
    endfor
endfunction

