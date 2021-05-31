" ============================================================
" options
" ============================================================

" dir diff buffer filetype
if !exists('g:ZFDirDiffUI_filetypeLeft')
    let g:ZFDirDiffUI_filetypeLeft = 'ZFDirDiffLeft'
endif
if !exists('g:ZFDirDiffUI_filetypeRight')
    let g:ZFDirDiffUI_filetypeRight = 'ZFDirDiffRight'
endif

" tabstop of the diff buffer
if !exists('g:ZFDirDiffUI_tabstop')
    let g:ZFDirDiffUI_tabstop = 2
endif

if !exists('g:ZFDirDiffUI_dirExpandable')
    let g:ZFDirDiffUI_dirExpandable = '+'
endif
if !exists('g:ZFDirDiffUI_dirCollapsible')
    let g:ZFDirDiffUI_dirCollapsible = '~'
endif

" when > 0, fold items whose level greater than this value
if !exists('g:ZFDirDiffUI_foldlevel')
    let g:ZFDirDiffUI_foldlevel = 0
endif

" autocmd
augroup ZF_DirDiff_augroup
    autocmd!
    autocmd User ZFDirDiff_DirDiffEnter silent
    autocmd User ZFDirDiff_FileDiffEnter silent
augroup END

" function name to get the header text
"     YourFunc()
" return a list of string
"   Use b:ZFDirDiff_isLeft, t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight to
"   build your header
if !exists('g:ZFDirDiffUI_headerTextFunc')
    let g:ZFDirDiffUI_headerTextFunc = 'ZF_DirDiff_headerText'
endif
function! ZF_DirDiff_headerText()
    let text = []
    if b:ZFDirDiff_isLeft
        call add(text, '[LEFT]: ' . ZF_DirDiffPathHint(t:ZFDirDiff_fileLeft, ':~'))
        call add(text, '[LEFT]: ' . ZF_DirDiffPathHint(t:ZFDirDiff_fileLeft, ':.'))
    else
        call add(text, '[RIGHT]: ' . ZF_DirDiffPathHint(t:ZFDirDiff_fileRight, ':~'))
        call add(text, '[RIGHT]: ' . ZF_DirDiffPathHint(t:ZFDirDiff_fileRight, ':.'))
    endif
    call add(text, '------------------------------------------------------------')
    return text
endfunction

" function name to get the confirm hint
"     YourFunc(fileLeft, fileRight, type)
" return a list of string
" type:
"   * 'l2r' : sync left to right
"   * 'r2l' : sync right to left
"   * 'dl' : delete left
"   * 'dr' : delete right
"   * 'diff' : diff two path
if !exists('g:ZFDirDiffUI_confirmHintHeaderFunc')
    let g:ZFDirDiffUI_confirmHintHeaderFunc = 'ZF_DirDiff_confirmHintHeader'
endif
function! ZF_DirDiff_confirmHintHeader(fileLeft, fileRight, type)
    let text = []
    call add(text, '----------------------------------------')
    if !empty(a:fileLeft)
        let path = ZF_DirDiffPathHint(a:fileLeft, ':t')
        let relpath = ZF_DirDiffPathHint(a:fileLeft, ':~')
        call add(text, '[LEFT] : ' . path)
        if path != relpath
            call add(text, '    ' . relpath)
        endif
    endif
    if !empty(a:fileRight)
        let path = ZF_DirDiffPathHint(a:fileRight, ':t')
        let relpath = ZF_DirDiffPathHint(a:fileRight, ':~')
        call add(text, '[RIGHT]: ' . path)
        if path != relpath
            call add(text, '    ' . relpath)
        endif
    endif
    call add(text, '----------------------------------------')
    call add(text, "\n")
    return text
endfunction

" function name to setup fold after each update
"     YourFunc(foldedMap)
" each `t:ZFDirDiff_dataUI[line].folded` is reset to 0 before entering this function,
" you may update it accorrding to your case
" params:
" * foldedMap : Dict<path, dummy>,
"   store previous folded path (relative to fileLeft/fileRight)
if !exists('g:ZFDirDiffUI_foldSetupFunc')
    let g:ZFDirDiffUI_foldSetupFunc = 'ZF_DirDiff_foldSetup'
endif
function! ZF_DirDiff_foldSetup(foldedMap)
    if !empty(a:foldedMap)
        for dataUI in t:ZFDirDiff_dataUI
            if exists('a:foldedMap[dataUI.data.path]')
                let dataUI.folded = 1
            endif
        endfor
    else
        for dataUI in t:ZFDirDiff_dataUI
            if g:ZFDirDiffUI_foldlevel > 0 && dataUI.data.level >= g:ZFDirDiffUI_foldlevel
                        \ || !dataUI.data.diff
                let dataUI.folded = 1
            endif
        endfor
    endif
endfunction

" whether need to sync same file
if !exists('g:ZFDirDiffUI_syncSameFile')
    let g:ZFDirDiffUI_syncSameFile = 0
endif

" overwrite confirm
if !exists('g:ZFDirDiffConfirmSyncDir')
    let g:ZFDirDiffConfirmSyncDir = 1
endif
if !exists('g:ZFDirDiffConfirmSyncFile')
    let g:ZFDirDiffConfirmSyncFile = 1
endif
if !exists('g:ZFDirDiffConfirmCopyDir')
    let g:ZFDirDiffConfirmCopyDir = 1
endif
if !exists('g:ZFDirDiffConfirmCopyFile')
    let g:ZFDirDiffConfirmCopyFile = 0
endif
if !exists('g:ZFDirDiffConfirmRemoveDir')
    let g:ZFDirDiffConfirmRemoveDir = 1
endif
if !exists('g:ZFDirDiffConfirmRemoveFile')
    let g:ZFDirDiffConfirmRemoveFile = 1
endif

" keymaps
if !exists('g:ZFDirDiffKeymap_update')
    let g:ZFDirDiffKeymap_update = ['DD']
endif
if !exists('g:ZFDirDiffKeymap_open')
    let g:ZFDirDiffKeymap_open = ['<cr>', 'o']
endif
if !exists('g:ZFDirDiffKeymap_foldOpenAll')
    let g:ZFDirDiffKeymap_foldOpenAll = ['O']
endif
if !exists('g:ZFDirDiffKeymap_foldClose')
    let g:ZFDirDiffKeymap_foldClose = ['x']
endif
if !exists('g:ZFDirDiffKeymap_foldCloseAll')
    let g:ZFDirDiffKeymap_foldCloseAll = ['X']
endif
if !exists('g:ZFDirDiffKeymap_goParent')
    let g:ZFDirDiffKeymap_goParent = ['U']
endif
if !exists('g:ZFDirDiffKeymap_diffThisDir')
    let g:ZFDirDiffKeymap_diffThisDir = ['cd']
endif
if !exists('g:ZFDirDiffKeymap_diffParentDir')
    let g:ZFDirDiffKeymap_diffParentDir = ['u']
endif
if !exists('g:ZFDirDiffKeymap_markToDiff')
    let g:ZFDirDiffKeymap_markToDiff = ['DM']
endif
if !exists('g:ZFDirDiffKeymap_markToSync')
    let g:ZFDirDiffKeymap_markToSync = ['DN']
endif
if !exists('g:ZFDirDiffKeymap_quit')
    let g:ZFDirDiffKeymap_quit = ['q']
endif
if !exists('g:ZFDirDiffKeymap_quitFileDiff')
    let g:ZFDirDiffKeymap_quitFileDiff = g:ZFDirDiffKeymap_quit
endif
if !exists('g:ZFDirDiffKeymap_nextDiff')
    let g:ZFDirDiffKeymap_nextDiff = [']c', 'DJ']
endif
if !exists('g:ZFDirDiffKeymap_prevDiff')
    let g:ZFDirDiffKeymap_prevDiff = ['[c', 'DK']
endif
if !exists('g:ZFDirDiffKeymap_nextDiffFile')
    let g:ZFDirDiffKeymap_nextDiffFile = []
endif
if !exists('g:ZFDirDiffKeymap_prevDiffFile')
    let g:ZFDirDiffKeymap_prevDiffFile = []
endif
if !exists('g:ZFDirDiffKeymap_syncToHere')
    let g:ZFDirDiffKeymap_syncToHere = ['do', 'DH']
endif
if !exists('g:ZFDirDiffKeymap_syncToThere')
    let g:ZFDirDiffKeymap_syncToThere = ['dp', 'DL']
endif
if !exists('g:ZFDirDiffKeymap_deleteFile')
    let g:ZFDirDiffKeymap_deleteFile = ['dd']
endif
if !exists('g:ZFDirDiffKeymap_getPath')
    let g:ZFDirDiffKeymap_getPath = ['p']
endif
if !exists('g:ZFDirDiffKeymap_getFullPath')
    let g:ZFDirDiffKeymap_getFullPath = ['P']
endif

" highlight
" {Title,Dir,DirContainDiff,Same,Diff,DirOnlyHere,DirOnlyThere,FileOnlyHere,FileOnlyThere,ConflictDir,ConflictFile,MarkToDiff,MarkToSync}
highlight default link ZFDirDiffHL_Title Title
highlight default link ZFDirDiffHL_Dir Directory
highlight default link ZFDirDiffHL_DirContainDiff DiffAdd
highlight default link ZFDirDiffHL_Same Folded
highlight default link ZFDirDiffHL_Diff DiffText
highlight default link ZFDirDiffHL_DirOnlyHere DiffAdd
highlight default link ZFDirDiffHL_DirOnlyThere Normal
highlight default link ZFDirDiffHL_FileOnlyHere DiffAdd
highlight default link ZFDirDiffHL_FileOnlyThere Normal
highlight default link ZFDirDiffHL_ConflictDir ErrorMsg
highlight default link ZFDirDiffHL_ConflictFile WarningMsg
highlight default link ZFDirDiffHL_MarkToDiff Cursor
highlight default link ZFDirDiffHL_MarkToSync Cursor

" custom highlight function
"   your_resetHL() : used to reset all highlight
"   your_addHL(group, line) : used to add highlight for each line in diff buffer
"     group: ZFDirDiffHL_Title series
"     line: line num in buffer, including title, start from 1
"
" builtin impl:
" * `ZF_DirDiffHL_resetHL_default` / `ZF_DirDiffHL_addHL_default`:
"   use plugin default
" * `ZF_DirDiffHL_resetHL_matchadd` / `ZF_DirDiffHL_addHL_matchadd`:
"   use `matchadd()`
" * `ZF_DirDiffHL_resetHL_matchaddWithCursorLineHL` / `ZF_DirDiffHL_addHL_matchaddWithCursorLineHL`:
"   same as `ZF_DirDiffHL_resetHL_matchadd`,
"   but modify `cursorline` settings automatically
" * `ZF_DirDiffHL_resetHL_sign` / `ZF_DirDiffHL_addHL_sign`:
"   use `:sign place`
if !exists('g:ZFDirDiffHLFunc_resetHL')
    let g:ZFDirDiffHLFunc_resetHL='ZF_DirDiffHL_resetHL_default'
endif
if !exists('g:ZFDirDiffHLFunc_addHL')
    let g:ZFDirDiffHLFunc_addHL='ZF_DirDiffHL_addHL_default'
endif

" ============================================================
command! -nargs=+ -complete=file ZFDirDiff :call ZF_DirDiff(<f-args>)

" ============================================================
function! ZF_DirDiff(fileLeft, fileRight)
    call s:clearMark()
    let diffResult = ZF_DirDiffCore(a:fileLeft, a:fileRight)
    if diffResult['exitCode'] == g:ZFDirDiff_exitCode_BothFile
        call s:diffByFile(a:fileLeft, a:fileRight)
    else
        call s:ZF_DirDiff_UI(a:fileLeft, a:fileRight, diffResult)
    endif
    echo diffResult['exitHint']
    return diffResult
endfunction

" optional params:
" * fileLeft, fileRight : when specified, use as new diff setting
" * foldedMap : a dict whose key is relative path to diff,
"   indicates these items should be folded
function! ZF_DirDiffUpdate(...)
    if !exists('t:ZFDirDiff_dataUI')
        echo '[ZFDirDiff] no previous diff found'
        return
    endif
    call s:clearMark()

    if empty(get(a:, 1, '')) && empty(get(a:, 2, ''))
                \ && (ZF_DirDiffPathFormat(t:ZFDirDiff_fileLeftOrig) != t:ZFDirDiff_fileLeft
                \ || ZF_DirDiffPathFormat(t:ZFDirDiff_fileRightOrig) != t:ZFDirDiff_fileRight)
        let fileLeft = fnamemodify(t:ZFDirDiff_fileLeft, ':.')
        let fileRight = fnamemodify(t:ZFDirDiff_fileRight, ':.')
    else
        let fileLeft = get(a:, 1, t:ZFDirDiff_fileLeftOrig)
        let fileRight = get(a:, 2, t:ZFDirDiff_fileRightOrig)
    endif

    let foldedMap = get(a:, 3, {})
    let isLeft = b:ZFDirDiff_isLeft
    let cursorPos = getpos('.')
    if empty(foldedMap)
                \ && ZF_DirDiffPathFormat(fileLeft) == t:ZFDirDiff_fileLeft
                \ && ZF_DirDiffPathFormat(fileRight) == t:ZFDirDiff_fileRight
        let foldedMap = ZF_DirDiffGetFolded()
    endif

    let diffResult = ZF_DirDiffCore(fileLeft, fileRight)
    let t:ZFDirDiff_fileLeft = ZF_DirDiffPathFormat(fileLeft)
    let t:ZFDirDiff_fileRight = ZF_DirDiffPathFormat(fileRight)
    let t:ZFDirDiff_fileLeftOrig = substitute(substitute(fileLeft, '\\', '/', 'g'), '/\+$', '', 'g')
    let t:ZFDirDiff_fileRightOrig = substitute(substitute(fileRight, '\\', '/', 'g'), '/\+$', '', 'g')
    let t:ZFDirDiff_hasDiff = (diffResult['exitCode'] == g:ZFDirDiff_exitCode_HasDiff)
    let t:ZFDirDiff_data = diffResult['data']
    if diffResult['exitCode'] == g:ZFDirDiff_exitCode_BothFile
        call ZF_DirDiffQuit()
        call s:diffByFile(fileLeft, fileRight)
        return
    endif

    call s:setupDiffDataUI()
    let Fn_foldSetup = function(g:ZFDirDiffUI_foldSetupFunc)
    call Fn_foldSetup(foldedMap)
    call s:ZF_DirDiff_redraw()

    if isLeft
        execute "normal! \<c-w>h"
    endif
    call setpos('.', cursorPos)
endfunction

function! ZF_DirDiffGetFolded()
    if !exists('t:ZFDirDiff_dataUI')
        return {}
    endif
    let folded = {}
    for dataUI in t:ZFDirDiff_dataUI
        if dataUI.folded
            let folded[dataUI.data.path] = 1
        endif
    endfor
    return folded
endfunction

function! ZF_DirDiffDataUIUnderCursor()
    return ZF_DirDiffDataUIForLine(getpos('.')[1])
endfunction

function! ZF_DirDiffDataUIForLine(line)
    let iLine = a:line - b:ZFDirDiff_iLineOffset - 1
    if iLine >= 0 && iLine < len(t:ZFDirDiff_dataUIVisible)
        return t:ZFDirDiff_dataUIVisible[iLine]
    else
        return ''
    endif
endfunction

" side:
"   (default) : both
"   'leftOnly' : left only
"   'rightOnly' : right only
function! ZF_DirDiffDataUIForRange(first, last, ...)
    let iLineStart = a:first - b:ZFDirDiff_iLineOffset - 1
    let iLineEnd = a:last - b:ZFDirDiff_iLineOffset - 1
    let len = len(t:ZFDirDiff_dataUIVisible)
    if iLineStart < 0
        let iLineStart = 0
    endif
    if iLineEnd > len
        let iLineEnd = len
    endif
    if iLineStart >= len || iLineEnd < 0 || iLineStart > iLineEnd
        return []
    endif
    execute 'let dataUIList = t:ZFDirDiff_dataUIVisible[' . iLineStart . ':' . iLineEnd . ']'

    let side = get(a:, 1, '')
    let i = len(dataUIList) - 1
    if side == 'leftOnly'
        let rightOnlyPattern = ['T_DIR_RIGHT', 'T_FILE_RIGHT']
        while i >= 0
            if index(rightOnlyPattern, dataUIList[i].data.type) >= 0
                call remove(dataUIList, i)
            endif
            let i -= 1
        endwhile
    elseif side == 'rightOnly'
        let leftOnlyPattern = ['T_DIR_LEFT', 'T_FILE_LEFT']
        while i >= 0
            if index(leftOnlyPattern, dataUIList[i].data.type) >= 0
                call remove(dataUIList, i)
            endif
            let i -= 1
        endwhile
    endif

    return dataUIList
endfunction

function! ZF_DirDiffOpen()
    let dataUI = ZF_DirDiffDataUIUnderCursor()
    if empty(dataUI)
        return
    endif
    if index(['T_DIR', 'T_DIR_LEFT', 'T_DIR_RIGHT'], dataUI.data.type) >= 0
        let dataUI.folded = dataUI.folded ? 0 : 1
        call s:ZF_DirDiff_redraw()
        return
    endif
    if index(['T_CONFLICT_DIR_LEFT', 'T_CONFLICT_DIR_RIGHT'], dataUI.data.type) >= 0
        echo '[ZFDirDiff] can not be compared: ' . dataUI.data.path
        return
    endif

    let fileLeft = t:ZFDirDiff_fileLeftOrig . '/' . dataUI.data.path
    let fileRight = t:ZFDirDiff_fileRightOrig . '/' . dataUI.data.path

    call s:diffByFile(fileLeft, fileRight)
endfunction

function! ZF_DirDiffFoldOpenAll()
    let dataUI = ZF_DirDiffDataUIUnderCursor()
    if empty(dataUI) || index(['T_DIR', 'T_DIR_LEFT', 'T_DIR_RIGHT'], dataUI.data.type) < 0
        return
    endif

    let dataUI.folded = 0
    let level = dataUI.data.level
    let i = dataUI.indexVisible + 1
    let iEnd = len(t:ZFDirDiff_dataUI)
    while i < iEnd
        let dataUI = t:ZFDirDiff_dataUI[i]
        if dataUI.data.level <= level
            break
        endif
        let dataUI.folded = 0
        let i += 1
    endwhile

    call s:ZF_DirDiff_redraw()
endfunction

function! ZF_DirDiffFoldClose()
    let dataUI = ZF_DirDiffDataUIUnderCursor()
    if empty(dataUI)
        return
    endif

    let level = dataUI.data.level
    let i = dataUI.indexVisible - 1
    while i >= 0
        let dataUI = t:ZFDirDiff_dataUIVisible[i]
        if dataUI.data.level < level
            let dataUI.folded = 1
            break
        endif
        let i -= 1
    endwhile

    call s:ZF_DirDiff_redraw()
    if i >= 0
        let cursor = getpos('.')
        let cursor[1] = i + b:ZFDirDiff_iLineOffset + 1
        call setpos('.', cursor)
    endif
endfunction

function! ZF_DirDiffFoldCloseAll()
    let isDirCheck = ['T_DIR', 'T_DIR_LEFT', 'T_DIR_RIGHT']
    for dataUI in t:ZFDirDiff_dataUI
        if index(isDirCheck, dataUI.data.type) >= 0
            let dataUI.folded = 1
        endif
    endfor
    call s:ZF_DirDiff_redraw()
    let cursor = getpos('.')
    let cursor[1] = b:ZFDirDiff_iLineOffset + 1
    call setpos('.', cursor)
endfunction

function! ZF_DirDiffGoParent()
    let fileLeft = fnamemodify(t:ZFDirDiff_fileLeftOrig, ':h')
    let fileRight = fnamemodify(t:ZFDirDiff_fileRightOrig, ':h')
    let name = fnamemodify(fileLeft, ':t')
    let foldedMap = {}
    for item in keys(ZF_DirDiffGetFolded())
        let foldedMap[name . '/' . item] = 1
    endfor
    call ZF_DirDiffUpdate(fileLeft, fileRight, foldedMap)
endfunction

function! ZF_DirDiffDiffThisDir()
    let dataUI = ZF_DirDiffDataUIUnderCursor()
    if empty(dataUI)
        return
    endif
    if b:ZFDirDiff_isLeft
        let fileRight = t:ZFDirDiff_fileRightOrig
        let fileLeft = t:ZFDirDiff_fileLeftOrig . '/' . dataUI.data.path
        if index(['T_DIR', 'T_DIR_LEFT', 'T_CONFLICT_DIR_LEFT'], dataUI.data.type) < 0
            let fileLeft = fnamemodify(fileLeft, ':h')
        endif
    else
        let fileLeft = t:ZFDirDiff_fileLeftOrig
        let fileRight = t:ZFDirDiff_fileRightOrig . '/' . dataUI.data.path
        if index(['T_DIR', 'T_DIR_RIGHT', 'T_CONFLICT_DIR_RIGHT'], dataUI.data.type) < 0
            let fileRight = fnamemodify(fileRight, ':h')
        endif
    endif
    call ZF_DirDiffUpdate(fileLeft, fileRight)
endfunction

function! ZF_DirDiffDiffParentDir()
    let fileLeft = b:ZFDirDiff_isLeft ? fnamemodify(t:ZFDirDiff_fileLeftOrig, ':h') : t:ZFDirDiff_fileLeftOrig
    let fileRight = !b:ZFDirDiff_isLeft ? fnamemodify(t:ZFDirDiff_fileRightOrig, ':h') : t:ZFDirDiff_fileRightOrig
    call ZF_DirDiffUpdate(fileLeft, fileRight)
endfunction

function! ZF_DirDiffMarkToDiff()
    let indexVisible = getpos('.')[1] - b:ZFDirDiff_iLineOffset - 1
    if indexVisible < 0
                \ || indexVisible >= len(t:ZFDirDiff_dataUIVisible)
                \ || (b:ZFDirDiff_isLeft && index(['T_DIR_RIGHT', 'T_FILE_RIGHT'], t:ZFDirDiff_dataUIVisible[indexVisible].data.type) >= 0)
                \ || (!b:ZFDirDiff_isLeft && index(['T_DIR_LEFT', 'T_FILE_LEFT'], t:ZFDirDiff_dataUIVisible[indexVisible].data.type) >= 0)
        echo '[ZFDirDiff] no file under cursor'
        return
    endif

    if !exists('t:ZFDirDiff_markToDiff')
        let t:ZFDirDiff_markToDiff = {
                    \   'isLeft' : b:ZFDirDiff_isLeft,
                    \   'index' : t:ZFDirDiff_dataUIVisible[indexVisible].index,
                    \ }
        call s:ZF_DirDiff_redraw()
        echo '[ZFDirDiff] mark again to diff with: '
                    \ . (b:ZFDirDiff_isLeft ? '[LEFT]' : '[RIGHT]')
                    \ . '/' . t:ZFDirDiff_dataUIVisible[indexVisible].data.path
        return
    endif

    if t:ZFDirDiff_markToDiff.isLeft == b:ZFDirDiff_isLeft
                \ && t:ZFDirDiff_markToDiff.index == t:ZFDirDiff_dataUIVisible[indexVisible].index
        unlet t:ZFDirDiff_markToDiff
        call s:ZF_DirDiff_redraw()
        return
    endif

    let fileLeft = (t:ZFDirDiff_markToDiff.isLeft ? t:ZFDirDiff_fileLeftOrig : t:ZFDirDiff_fileRightOrig)
                \ . '/' . t:ZFDirDiff_dataUI[t:ZFDirDiff_markToDiff.index].data.path
    let fileRight = (b:ZFDirDiff_isLeft ? t:ZFDirDiff_fileLeftOrig : t:ZFDirDiff_fileRightOrig)
                \ . '/' . t:ZFDirDiff_dataUIVisible[indexVisible].data.path
    unlet t:ZFDirDiff_markToDiff
    call ZF_DirDiffUpdate(fileLeft, fileRight)
endfunction

function! ZF_DirDiffMarkToSync() range
    call ZF_DirDiffMarkToSyncForRange(a:firstline, a:lastline, b:ZFDirDiff_isLeft)
endfunction
" mode:
" * toggle
" * add
" * remove
function! ZF_DirDiffMarkToSyncForRange(first, last, isLeft, ...)
    let mode = get(a:, 1, '')
    let dataUIList = ZF_DirDiffDataUIForRange(a:first, a:last, a:isLeft ? 'leftOnly' : 'rightOnly')
    if empty(dataUIList)
        echo '[ZFDirDiff] no file under cursor'
        return
    endif

    if !exists('t:ZFDirDiff_markToSync')
        let t:ZFDirDiff_markToSync = []
    endif
    for dataUI in dataUIList
        let exist = len(t:ZFDirDiff_markToSync) - 1
        while exist >= 0
            if t:ZFDirDiff_markToSync[exist].isLeft == a:isLeft
                        \ && t:ZFDirDiff_markToSync[exist].index == dataUI.index
                break
            endif
            let exist -= 1
        endwhile
        if exist >= 0
            if mode != 'add'
                call remove(t:ZFDirDiff_markToSync, exist)
            endif
        else
            call add(t:ZFDirDiff_markToSync, {
                        \   'isLeft' : a:isLeft,
                        \   'index' : dataUI.index,
                        \ })
        endif
    endfor
    call s:ZF_DirDiff_redraw()
    if empty(t:ZFDirDiff_markToSync)
        echo printf('[ZFDirDiff] mark cleared, %s again to mark to sync', join(g:ZFDirDiffKeymap_markToSync, '/'))
    else
        echo printf('[ZFDirDiff] %d marked, %s %s %s to operate marked files, %s to clear marks'
                    \ , len(t:ZFDirDiff_markToSync)
                    \ , join(g:ZFDirDiffKeymap_syncToHere, '/')
                    \ , join(g:ZFDirDiffKeymap_syncToThere, '/')
                    \ , join(g:ZFDirDiffKeymap_deleteFile, '/')
                    \ , join(g:ZFDirDiffKeymap_update, '/')
                    \ )
    endif
endfunction

function! ZF_DirDiffQuit()
    let Fn_resetHL=function(g:ZFDirDiffHLFunc_resetHL)
    let ownerTab = t:ZFDirDiff_ownerTab

    " note winnr('$') always equal to 1 for last window
    while winnr('$') > 1
        call Fn_resetHL()
        bd!
    endwhile
    " delete again to delete last window
    call Fn_resetHL()
    bd!

    execute 'normal! ' . ownerTab . 'gt'
endfunction

function! ZF_DirDiffQuitFileDiff()
    let ownerDiffTab = t:ZFDirDiff_ownerDiffTab

    execute "normal! \<c-w>k"
    execute "normal! \<c-w>h"
    call s:askWrite()

    execute "normal! \<c-w>k"
    execute "normal! \<c-w>l"
    call s:askWrite()

    let tabnr = tabpagenr('$')
    while exists('t:ZFDirDiff_ownerDiffTab') && tabnr == tabpagenr('$')
        bd!
    endwhile

    execute 'normal! ' . ownerDiffTab . 'gt'
    call ZF_DirDiffUpdate()
endfunction

function! ZF_DirDiffNextDiff()
    call s:jumpDiff('next', 'dir_and_file')
endfunction
function! ZF_DirDiffPrevDiff()
    call s:jumpDiff('prev', 'dir_and_file')
endfunction
function! ZF_DirDiffNextDiffFile()
    call s:jumpDiff('next', 'file')
endfunction
function! ZF_DirDiffPrevDiffFile()
    call s:jumpDiff('prev', 'file')
endfunction
function! s:jumpDiff(nextOrPrev, condition)
    if a:nextOrPrev == 'next'
        let iOffset = 1
        let iEnd = len(t:ZFDirDiff_dataUIVisible)
    else
        let iOffset = -1
        let iEnd = -1
    endif

    let curPos = getpos('.')
    let iLine = curPos[1] - b:ZFDirDiff_iLineOffset - 1
    if iLine < 0
        let iLine = 0
    elseif iLine >= len(t:ZFDirDiff_dataUIVisible)
        let iLine = len(t:ZFDirDiff_dataUIVisible) - 1
    else
        let iLine += iOffset
    endif

    while iLine != iEnd
        if s:isDiff(iLine, a:condition)
            let curPos[1] = iLine + b:ZFDirDiff_iLineOffset + 1
            call setpos('.', curPos)
            normal! zz
            break
        endif
        let iLine += iOffset
    endwhile
endfunction

function! s:isDiff(iLine, condition)
    let dataUI = t:ZFDirDiff_dataUIVisible[a:iLine]
    if a:condition == 'dir_and_file'
        return dataUI.data.type != 'T_DIR' && dataUI.data.type != 'T_SAME'
    elseif a:condition == 'file'
        return dataUI.data.type != 'T_DIR' && dataUI.data.type != 'T_SAME'
                    \ && dataUI.data.type != 'T_DIR_LEFT' && dataUI.data.type != 'T_DIR_RIGHT'
    endif
endfunction

function! ZF_DirDiffFoldLevelUpdate(...)
    let foldLevel = get(a:, 1, g:ZFDirDiffUI_foldlevel)
    if foldLevel <= 0
        for dataUI in t:ZFDirDiff_dataUI
            let dataUI.folded = 0
        endfor
    else
        for dataUI in t:ZFDirDiff_dataUI
            let dataUI.folded = (dataUI.data.level >= foldLevel) ? 1 : 0
        endfor
    endif
    call s:setupDiffDataUIVisible()
endfunction

function! ZF_DirDiffSyncToHere() range
    let dataUIList = s:prepareDataUIForSync(a:firstline, a:lastline, 1 - b:ZFDirDiff_isLeft)
    if empty(dataUIList)
        echo '[ZFDirDiff] no file to sync to ' . (b:ZFDirDiff_isLeft ? '[LEFT]' : '[RIGHT]')
        return
    endif
    let syncAll = 0
    for dataUI in dataUIList
        let choice = ZF_DirDiffSync(t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight, dataUI.data.path, dataUI.data, b:ZFDirDiff_isLeft ? 'r2l' : 'l2r', syncAll)
        if choice == 'a'
            let syncAll = 1
        elseif choice == 'q'
            break
        endif
    endfor
    call ZF_DirDiffUpdate()
endfunction
function! ZF_DirDiffSyncToThere() range
    let dataUIList = s:prepareDataUIForSync(a:firstline, a:lastline, b:ZFDirDiff_isLeft)
    if empty(dataUIList)
        echo '[ZFDirDiff] no file to sync to ' . (!b:ZFDirDiff_isLeft ? '[LEFT]' : '[RIGHT]')
        return
    endif
    let syncAll = 0
    for dataUI in dataUIList
        let choice = ZF_DirDiffSync(t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight, dataUI.data.path, dataUI.data, b:ZFDirDiff_isLeft ? 'l2r' : 'r2l', 0)
        if choice == 'a'
            let syncAll = 1
        elseif choice == 'q'
            break
        endif
    endfor
    call ZF_DirDiffUpdate()
endfunction

function! ZF_DirDiffDeleteFile() range
    let dataUIList = s:prepareDataUIForSync(a:firstline, a:lastline, b:ZFDirDiff_isLeft)
    if empty(dataUIList)
        echo '[ZFDirDiff] no file to delete'
        return
    endif
    let syncAll = 0
    for dataUI in dataUIList
        let choice = ZF_DirDiffSync(t:ZFDirDiff_fileLeft, t:ZFDirDiff_fileRight, dataUI.data.path, dataUI.data, b:ZFDirDiff_isLeft ? 'dl' : 'dr', 0)
        if choice == 'a'
            let syncAll = 1
        elseif choice == 'q'
            break
        endif
    endfor
    call ZF_DirDiffUpdate()
endfunction

function! s:prepareDataUIForSync(first, last, isLeft)
    if empty(get(t:, 'ZFDirDiff_markToSync', []))
        silent call ZF_DirDiffMarkToSyncForRange(a:first, a:last, a:isLeft, 'add')
    endif
    if empty(get(t:, 'ZFDirDiff_markToSync', []))
        return []
    endif

    let dataUIList = []
    let allParent = {}
    for markToSync in t:ZFDirDiff_markToSync
        if markToSync.isLeft == a:isLeft
            call add(dataUIList, t:ZFDirDiff_dataUI[markToSync.index])
            let parent = fnamemodify(t:ZFDirDiff_dataUI[markToSync.index].data.path, ':h')
            if parent != '.'
                let allParent[parent] = 1
            endif
        endif
    endfor

    " filter out parent if children marked
    "
    " typical case:
    "   fileA     <= range start
    "   dirA/
    "       fileB <= range end
    "       fileC
    " dirA should be filtered to prevent fileC to be processed
    for key in keys(allParent)
        let parent = fnamemodify(key, ':h')
        while parent != '.'
            let allParent[parent] = 1
            let parent = fnamemodify(parent, ':h')
        endwhile
    endfor
    let i = len(dataUIList) - 1
    while i >= 0
        if exists('allParent[dataUIList[i].data.path]')
            call remove(dataUIList, i)
        endif
        let i -= 1
    endwhile

    return dataUIList
endfunction

function! ZF_DirDiffGetPath()
    let dataUI = ZF_DirDiffDataUIUnderCursor()
    if empty(dataUI)
        return
    endif

    let path = fnamemodify(b:ZFDirDiff_isLeft ? t:ZFDirDiff_fileLeftOrig : t:ZFDirDiff_fileRightOrig, ':.') . '/' . dataUI.data.path
    let path = substitute(path, '\', '/', 'g')
    if has('clipboard')
        let @*=path
    else
        let @"=path
    endif

    echo '[ZFDirDiff] copied path: ' . path
endfunction
function! ZF_DirDiffGetFullPath()
    let dataUI = ZF_DirDiffDataUIUnderCursor()
    if empty(dataUI)
        return
    endif

    let path = (b:ZFDirDiff_isLeft ? t:ZFDirDiff_fileLeft : t:ZFDirDiff_fileRight) . '/' . dataUI.data.path
    if has('clipboard')
        let @*=path
    else
        let @"=path
    endif

    echo '[ZFDirDiff] copied full path: ' . path
endfunction

" ============================================================
function! s:diffByFile(fileLeft, fileRight)
    let ownerDiffTab = tabpagenr()

    execute 'tabedit ' . a:fileLeft
    diffthis
    call s:diffByFile_setup(ownerDiffTab)

    vsplit

    execute "normal! \<c-w>l"
    execute 'edit ' . a:fileRight
    diffthis
    call s:diffByFile_setup(ownerDiffTab)

    execute "normal! \<c-w>="
endfunction
function! s:diffByFile_setup(ownerDiffTab)
    let t:ZFDirDiff_ownerDiffTab = a:ownerDiffTab

    for k in g:ZFDirDiffKeymap_quitFileDiff
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffQuitFileDiff()<cr>'
    endfor

    doautocmd User ZFDirDiff_FileDiffEnter
endfunction

function! s:askWrite()
    if !&modified
        return
    endif
    let input = confirm("[ZFDirDiff] File " . expand("%:p") . " modified, save?", "&Yes\n&No", 1)
    if (input == 1)
        w!
    endif
endfunction

function! s:clearMark()
    if exists('t:ZFDirDiff_markToDiff')
        unlet t:ZFDirDiff_markToDiff
    endif
    if exists('t:ZFDirDiff_markToSync')
        unlet t:ZFDirDiff_markToSync
    endif
endfunction

function! s:ZF_DirDiff_UI(fileLeft, fileRight, diffResult)
    let ownerTab = tabpagenr()

    tabnew

    let t:ZFDirDiff_ownerTab = ownerTab
    let t:ZFDirDiff_fileLeft = ZF_DirDiffPathFormat(a:fileLeft)
    let t:ZFDirDiff_fileRight = ZF_DirDiffPathFormat(a:fileRight)
    let t:ZFDirDiff_fileLeftOrig = substitute(substitute(a:fileLeft, '\\', '/', 'g'), '/\+$', '', 'g')
    let t:ZFDirDiff_fileRightOrig = substitute(substitute(a:fileRight, '\\', '/', 'g'), '/\+$', '', 'g')
    let t:ZFDirDiff_hasDiff = (a:diffResult['exitCode'] == g:ZFDirDiff_exitCode_HasDiff)
    let t:ZFDirDiff_data = a:diffResult['data']

    call s:setupDiffDataUI()
    let Fn_foldSetup = function(g:ZFDirDiffUI_foldSetupFunc)
    call Fn_foldSetup({})
    call s:setupDiffDataUIVisible()

    vsplit
    call s:setupDiffUI(1)

    execute "normal! \<c-w>l"
    enew
    call s:setupDiffUI(0)

    execute 'normal! gg0'
    if b:ZFDirDiff_iLineOffset > 0
        execute 'normal! ' . b:ZFDirDiff_iLineOffset . 'j'
    endif
    redraw
endfunction

function! s:ZF_DirDiff_redraw()
    if !exists('t:ZFDirDiff_ownerTab')
        return
    endif
    let oldWin = winnr()
    let oldState = winsaveview()

    call s:setupDiffDataUIVisible()

    execute "normal! \<c-w>h"
    call s:setupDiffUI(1)
    execute "normal! \<c-w>l"
    call s:setupDiffUI(0)

    execute oldWin . 'wincmd w'
    call winrestview(oldState)
    redraw
endfunction

function! s:setupDiffDataUI()
    let t:ZFDirDiff_dataUI = []
    call s:setupDiffDataUI_recursive(t:ZFDirDiff_data)
endfunction
function! s:setupDiffDataUI_recursive(data)
    for data in a:data
        let dataUI = {
                    \   'index' : len(t:ZFDirDiff_dataUI),
                    \   'indexVisible' : -1,
                    \   'folded' : 0,
                    \   'data' : data,
                    \ }
        call add(t:ZFDirDiff_dataUI, dataUI)
        call s:setupDiffDataUI_recursive(data.children)
    endfor
endfunction
function! s:setupDiffDataUIVisible()
    let t:ZFDirDiff_dataUIVisible = []
    let i = 0
    let iEnd = len(t:ZFDirDiff_dataUI)
    while i < iEnd
        let dataUI = t:ZFDirDiff_dataUI[i]
        let dataUI.indexVisible = len(t:ZFDirDiff_dataUIVisible)
        call add(t:ZFDirDiff_dataUIVisible, dataUI)
        if dataUI.folded
            let i += 1
            while i < iEnd && t:ZFDirDiff_dataUI[i].data.level > dataUI.data.level
                let t:ZFDirDiff_dataUI[i].indexVisible = -1
                let i += 1
            endwhile
        else
            let i += 1
        endif
    endwhile
endfunction

function! s:setupDiffUI(isLeft)
    let b:ZFDirDiff_isLeft = a:isLeft
    let b:ZFDirDiff_iLineOffset = 0

    if b:ZFDirDiff_isLeft
        execute 'setlocal filetype=' . g:ZFDirDiffUI_filetypeLeft
    else
        execute 'setlocal filetype=' . g:ZFDirDiffUI_filetypeRight
    endif

    setlocal modifiable
    silent! normal! gg"_dG
    let contents = []

    " header
    let Fn_headerText = function(g:ZFDirDiffUI_headerTextFunc)
    let headerText = Fn_headerText()
    let b:ZFDirDiff_iLineOffset = len(headerText)
    call extend(contents, headerText)

    " contents
    call s:setupDiffItemList(contents)

    " write
    call setline(1, contents)

    " other buffer setting
    call s:setupDiffBuffer()
endfunction

function! s:setupDiffItemList(contents)
    let indentText = ''
    for i in range(g:ZFDirDiffUI_tabstop)
        let indentText .= ' '
    endfor

    for dataUI in t:ZFDirDiff_dataUIVisible
        let data = dataUI.data
        let line = ''
        let visible = 0
                    \ || (b:ZFDirDiff_isLeft && (data.type == 'T_DIR_RIGHT' || data.type == 'T_FILE_RIGHT'))
                    \ || (!b:ZFDirDiff_isLeft && (data.type == 'T_DIR_LEFT' || data.type == 'T_FILE_LEFT'))
                    \ ? 0 : 1

        if visible
            for i in range(data.level + 1)
                let line .= indentText
            endfor
            let isDir = data.type == 'T_DIR'
                        \ || (b:ZFDirDiff_isLeft && (data.type == 'T_DIR_LEFT' || data.type == 'T_CONFLICT_DIR_LEFT'))
                        \ || (!b:ZFDirDiff_isLeft && (data.type == 'T_DIR_RIGHT' || data.type == 'T_CONFLICT_DIR_RIGHT'))

            if isDir
                if dataUI.folded
                            \ || (b:ZFDirDiff_isLeft && data.type == 'T_CONFLICT_DIR_LEFT')
                            \ || (!b:ZFDirDiff_isLeft && data.type == 'T_CONFLICT_DIR_RIGHT')
                    let mark = g:ZFDirDiffUI_dirExpandable
                else
                    let mark = g:ZFDirDiffUI_dirCollapsible
                endif
            else
                let mark = ''
            endif
            if !empty(mark)
                let line = strpart(line, 0, len(line) - len(mark) - 1)
                let line .= mark . ' '
            endif

            let line .= data.name
            if isDir
                let line .= '/'
            endif
        endif
        let line = substitute(line, ' \+$', '', 'g')
        call add(a:contents, line)
    endfor

    call add(a:contents, '')
endfunction

function! s:setupDiffBuffer()
    call s:setupDiffBuffer_keymap()
    call s:setupDiffBuffer_statusline()
    call s:setupDiffBuffer_highlight()

    execute 'setlocal tabstop=' . g:ZFDirDiffUI_tabstop
    execute 'setlocal softtabstop=' . g:ZFDirDiffUI_tabstop
    setlocal buftype=nowrite
    setlocal bufhidden=hide
    setlocal nowrap
    setlocal nomodified
    setlocal nomodifiable
    set scrollbind
    set cursorbind
    execute 'augroup ZF_DirDiff_diffBuffer_augroup_' . bufnr('')
    autocmd!
    autocmd BufDelete <buffer> set noscrollbind | set nocursorbind
                \| call s:ZF_DirDiff_diffBuffer_augroup_cleanup()
    autocmd BufHidden <buffer> set noscrollbind | set nocursorbind
    autocmd BufEnter <buffer> set scrollbind | set cursorbind
    execute 'augroup END'

    doautocmd User ZFDirDiff_DirDiffEnter
endfunction

function! s:ZF_DirDiff_diffBuffer_augroup_cleanup()
    execute 'augroup ZF_DirDiff_diffBuffer_augroup_' . expand('<abuf>')
    autocmd!
    execute 'augroup END'
endfunction

function! s:setupDiffBuffer_keymap()
    for k in g:ZFDirDiffKeymap_update
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffUpdate()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_open
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffOpen()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_foldOpenAll
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffFoldOpenAll()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_foldClose
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffFoldClose()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_foldCloseAll
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffFoldCloseAll()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_goParent
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffGoParent()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_diffThisDir
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffDiffThisDir()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_diffParentDir
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffDiffParentDir()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_markToDiff
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffMarkToDiff()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_markToSync
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffMarkToSync()<cr>'
        execute 'xnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffMarkToSync()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_quit
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffQuit()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_nextDiff
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffNextDiff()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_prevDiff
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffPrevDiff()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_nextDiffFile
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffNextDiffFile()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_prevDiffFile
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffPrevDiffFile()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_syncToHere
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffSyncToHere()<cr>'
        execute 'xnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffSyncToHere()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_syncToThere
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffSyncToThere()<cr>'
        execute 'xnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffSyncToThere()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_deleteFile
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffDeleteFile()<cr>'
        execute 'xnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffDeleteFile()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_getPath
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffGetPath()<cr>'
    endfor
    for k in g:ZFDirDiffKeymap_getFullPath
        execute 'nnoremap <buffer><silent> ' . k . ' :call ZF_DirDiffGetFullPath()<cr>'
    endfor
endfunction

function! s:setupDiffBuffer_statusline()
    if b:ZFDirDiff_isLeft
        let hint = 'LEFT'
        let path = t:ZFDirDiff_fileLeftOrig
    else
        let hint = 'RIGHT'
        let path = t:ZFDirDiff_fileRightOrig
    endif
    let path = substitute(path, '%', '%%', 'g')
    let &l:statusline = '[' . hint . ']: ' . path . '%=%k %3p%%'
endfunction

function! s:setupDiffBuffer_highlight()
    let Fn_resetHL=function(g:ZFDirDiffHLFunc_resetHL)
    let Fn_addHL=function(g:ZFDirDiffHLFunc_addHL)

    call Fn_resetHL()

    if len(t:ZFDirDiff_dataUIVisible) > get(g:, 'ZFDirDiffHLMaxLine', 3000)
        return
    endif

    for i in range(1, b:ZFDirDiff_iLineOffset)
        call Fn_addHL('ZFDirDiffHL_Title', i)
    endfor

    for indexVisible in range(len(t:ZFDirDiff_dataUIVisible))
        let dataUI = t:ZFDirDiff_dataUIVisible[indexVisible]
        let data = dataUI.data
        let line = b:ZFDirDiff_iLineOffset + indexVisible + 1

        if exists('t:ZFDirDiff_markToDiff')
                    \ && b:ZFDirDiff_isLeft == t:ZFDirDiff_markToDiff.isLeft
                    \ && t:ZFDirDiff_dataUIVisible[indexVisible].index == t:ZFDirDiff_markToDiff.index
            call Fn_addHL('ZFDirDiffHL_MarkToDiff', line)
            continue
        endif

        if exists('t:ZFDirDiff_markToSync')
            let markToSyncFlag = 0
            for markToSync in t:ZFDirDiff_markToSync
                if b:ZFDirDiff_isLeft == markToSync.isLeft
                            \ && t:ZFDirDiff_dataUIVisible[indexVisible].index == markToSync.index
                    call Fn_addHL('ZFDirDiffHL_MarkToSync', line)
                    let markToSyncFlag = 1
                    break
                endif
            endfor
            if markToSyncFlag
                continue
            endif
        endif

        if 0
        elseif data.type == 'T_DIR'
            if dataUI.data.diff
                call Fn_addHL('ZFDirDiffHL_DirContainDiff', line)
            else
                call Fn_addHL('ZFDirDiffHL_Dir', line)
            endif
        elseif data.type == 'T_SAME'
            call Fn_addHL('ZFDirDiffHL_Same', line)
        elseif data.type == 'T_DIFF'
            call Fn_addHL('ZFDirDiffHL_Diff', line)
        elseif data.type == 'T_DIR_LEFT'
            if b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_DirOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_DirOnlyThere', line)
            endif
        elseif data.type == 'T_DIR_RIGHT'
            if !b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_DirOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_DirOnlyThere', line)
            endif
        elseif data.type == 'T_FILE_LEFT'
            if b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_FileOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_FileOnlyThere', line)
            endif
        elseif data.type == 'T_FILE_RIGHT'
            if !b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_FileOnlyHere', line)
            else
                call Fn_addHL('ZFDirDiffHL_FileOnlyThere', line)
            endif
        elseif data.type == 'T_CONFLICT_DIR_LEFT'
            if b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_ConflictDir', line)
            else
                call Fn_addHL('ZFDirDiffHL_ConflictFile', line)
            endif
        elseif data.type == 'T_CONFLICT_DIR_RIGHT'
            if !b:ZFDirDiff_isLeft
                call Fn_addHL('ZFDirDiffHL_ConflictDir', line)
            else
                call Fn_addHL('ZFDirDiffHL_ConflictFile', line)
            endif
        endif
    endfor
endfunction

