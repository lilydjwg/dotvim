
" ============================================================
function! ZF_DirDiff_mkdir(path)
    if has('unix')
        silent execute '!mkdir -p "' . a:path . '"'
    elseif has('win32')
        silent execute '!mkdir "' . substitute(a:path, '/', '\', 'g') . '"'
    endif
endfunction

function! ZF_DirDiff_cpfile(from, to)
    call ZF_DirDiff_mkdir(fnamemodify(a:to, ":h"))
    if has('unix')
        silent execute '!cp -rf "' . a:from . '" "' . a:to . '"'
    elseif has('win32')
        silent execute '!copy "' . substitute(a:from, '/', '\', 'g') . '" "' . substitute(a:to, '/', '\', 'g') . '"'
    endif
endfunction

function! ZF_DirDiff_rmdir(path)
    if has('unix')
        silent execute '!rm -rf "' . a:path . '"'
    elseif has('win32')
        silent execute '!rmdir /s/q "' . substitute(a:path, '/', '\', 'g') . '"'
    endif
endfunction

function! ZF_DirDiff_rmfile(path)
    if has('unix')
        silent execute '!rm -f "' . a:path . '"'
    elseif has('win32')
        silent execute '!del /f/q "' . substitute(a:path, '/', '\', 'g') . '"'
    endif
endfunction

" ============================================================
" for data's format, see ZF_DirDiffCore
" syncType:
"   * 'l2r' : sync left to right
"   * 'r2l' : sync right to left
"   * 'dl' : delete left
"   * 'dr' : delete right
" return : a/y/n/q
function! ZF_DirDiffSync(fileLeft, fileRight, path, data, syncType, syncAll)
    if 0
    elseif a:syncType == 'dl' || a:syncType == 'dr' | return s:syncDelete(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_DIR' | return s:sync_T_DIR(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_SAME' | return s:sync_T_SAME(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_DIFF' | return s:sync_T_DIFF(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_DIR_LEFT' | return s:sync_T_DIR_LEFT(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_DIR_RIGHT' | return s:sync_T_DIR_RIGHT(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_FILE_LEFT' | return s:sync_T_FILE_LEFT(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_FILE_RIGHT' | return s:sync_T_FILE_RIGHT(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_CONFLICT_DIR_LEFT' | return s:sync_T_CONFLICT_DIR_LEFT(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    elseif a:data.type == 'T_CONFLICT_DIR_RIGHT' | return s:sync_T_CONFLICT_DIR_RIGHT(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, a:syncAll)
    endif
endfunction

function! s:syncAllFix(syncAll)
    if a:syncAll
        return 'a'
    else
        return 'y'
    endif
endfunction
function! s:syncChoice()
    echo "\n"
    echo '  (a)ll'
    echo '  (y)es'
    echo '  (n)o'
    echo '  (q)uit'
    echo "\n"
    echo 'choose: '

    let choice = getchar()
    if 0
    elseif choice == char2nr('a') || choice == char2nr('A')
        return 'a'
    elseif choice == char2nr('y') || choice == char2nr('Y')
        return 'y'
    elseif choice == char2nr('n') || choice == char2nr('N')
        return 'n'
    elseif choice == char2nr('q') || choice == char2nr('Q')
        return 'q'
    else
        return 'n'
    endif
endfunction
function! s:syncConfirm(hint, fileLeft, fileRight, type)
    redraw!

    let Fn_headerText = function(g:ZFDirDiffUI_confirmHintHeaderFunc)
    let headerText = Fn_headerText(a:fileLeft, a:fileRight, a:type)
    echo join(headerText, "\n")
    echo '[ZFDirDiff] ' . a:hint
    return s:syncChoice()
endfunction

function! s:syncBackupIsEnable()
    return get(t:, 'ZFDirDiffUI_autoBackup', get(g:, 'ZFDirDiffUI_autoBackup', 1)) && exists('*ZFBackupSave')
endfunction
function! s:syncBackupFile(file)
    if s:syncBackupIsEnable()
        call ZFBackupSave(a:file)
    endif
endfunction
function! s:syncBackupDir(src, dst)
    if !s:syncBackupIsEnable()
        return
    endif
    if empty(a:src)
        let dst = substitute(CygpathFix_absPath(a:dst), '\\', '/', 'g')
        let dstFiles = split(globpath(dst, '**/*.*'), "\n")
        for f in dstFiles
            call ZFBackupSave(f)
        endfor
    else
        let src = substitute(CygpathFix_absPath(a:src), '\\', '/', 'g')
        let dst = substitute(CygpathFix_absPath(a:dst), '\\', '/', 'g')
        let dstLen = len(dst)
        let dstFiles = split(globpath(dst, '**/*.*'), "\n")
        for f in dstFiles
            let f = substitute(CygpathFix_absPath(f), '\\', '/', 'g')
            if filereadable(src . strpart(f, dstLen))
                call ZFBackupSave(f)
            endif
        endfor
    endif
endfunction

" ============================================================
function! s:syncDelete(fileLeft, fileRight, path, data, syncType, syncAll)
    if a:syncType == 'dl'
        if a:data.type == 'T_DIR_RIGHT' || a:data.type == 'T_FILE_RIGHT'
            return s:syncAllFix(a:syncAll)
        endif
        let parent = a:fileLeft
        let isLeft = 1
    else
        if a:data.type == 'T_DIR_LEFT' || a:data.type == 'T_FILE_LEFT'
            return s:syncAllFix(a:syncAll)
        endif
        let parent = a:fileRight
        let isLeft = 0
    endif

    if filereadable(parent . '/' . a:path)
        let isDir = 0
        let confirmOption = get(t:, 'ZFDirDiffConfirmRemoveFile', g:ZFDirDiffConfirmRemoveFile)
    else
        let isDir = 1
        let confirmOption = get(t:, 'ZFDirDiffConfirmRemoveDir', g:ZFDirDiffConfirmRemoveDir)
    endif

    let syncAll = a:syncAll
    if !syncAll && confirmOption
        if isLeft
            if isDir
                let hint = 'confirm REMOVE?  ' . '[LEFT(dir)] <= [RIGHT(___)]'
            else
                let hint = 'confirm REMOVE?  ' . '[LEFT(file)] <= [RIGHT(___)]'
            endif
            let choice = s:syncConfirm(hint, parent . '/' . a:path, '', a:syncType)
        else
            if isDir
                let hint = 'confirm REMOVE?  ' . '[LEFT(___)] => [RIGHT(dir)]'
            else
                let hint = 'confirm REMOVE?  ' . '[LEFT(___)] => [RIGHT(file)]'
            endif
            let choice = s:syncConfirm(hint, '', parent . '/' . a:path, a:syncType)
        endif
        if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
    endif

    if isDir
        call s:syncBackupDir('', parent . '/' . a:path)
        if empty(globpath(parent . '/' . a:path, '*')) || empty(a:data.children)
            call ZF_DirDiff_rmdir(parent . '/' . a:path)
        else
            for child in a:data.children
                let choice = ZF_DirDiffSync(a:fileLeft, a:fileRight, a:path . '/' . child.name, child, a:syncType, syncAll)
                if choice == 'q' | return 'q' | elseif choice == 'a' | let syncAll = 1 | endif
            endfor
            if empty(globpath(parent . '/' . a:path, '*'))
                call ZF_DirDiff_rmdir(parent . '/' . a:path)
            endif
        endif
    else
        call s:syncBackupFile(parent . '/' . a:path)
        call ZF_DirDiff_rmfile(parent . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:syncCopyDir(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    for child in a:data.children
        if 0
        elseif a:syncType == 'l2r'
                    \ && a:data.type == 'T_DIR_RIGHT'
                    \ && a:data.type == 'T_FILE_RIGHT'
            continue
        elseif a:syncType == 'r2l'
                    \ && a:data.type == 'T_DIR_LEFT'
                    \ && a:data.type == 'T_FILE_LEFT'
            continue
        endif
        let choice = ZF_DirDiffSync(a:fileLeft, a:fileRight, a:path . '/' . child.name, child, a:syncType, syncAll)
        if choice == 'q' | return 'q' | elseif choice == 'a' | let syncAll = 1 | endif
    endfor
    return s:syncAllFix(syncAll)
endfunction

" ============================================================
function! s:sync_T_DIR(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if !syncAll && get(t:, 'ZFDirDiffConfirmSyncDir', g:ZFDirDiffConfirmSyncDir)
        let hint = 'confirm sync?  ' . (a:syncType == 'l2r' ? '[LEFT(dir)] => [RIGHT(dir)]' : '[LEFT(dir)] <= [RIGHT(dir)]')
        let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
        if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
    endif

    for child in a:data.children
        let choice = ZF_DirDiffSync(a:fileLeft, a:fileRight, a:path . '/' . child.name, child, a:syncType, syncAll)
        if choice == 'q' | return 'q' | elseif choice == 'a' | let syncAll = 1 | endif
    endfor
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_SAME(fileLeft, fileRight, path, data, syncType, syncAll)
    if !get(t:, 'ZFDirDiffUI_syncSameFile', g:ZFDirDiffUI_syncSameFile)
        return s:syncAllFix(a:syncAll)
    endif

    let syncAll = a:syncAll
    if !syncAll && get(t:, 'ZFDirDiffConfirmSyncFile', g:ZFDirDiffConfirmSyncFile)
        let hint = 'confirm sync?  ' . (a:syncType == 'l2r' ? '[LEFT(file)] => [RIGHT(file)]' : '[LEFT(file)] <= [RIGHT(file)]')
        let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
        if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
    endif

    if a:syncType == 'l2r'
        call s:syncBackupFile(a:fileRight . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path)
    else
        call s:syncBackupFile(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileRight . '/' . a:path, a:fileLeft . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_DIFF(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if !syncAll && get(t:, 'ZFDirDiffConfirmSyncFile', g:ZFDirDiffConfirmSyncFile)
        let hint = 'confirm sync?  ' . (a:syncType == 'l2r' ? '[LEFT(file)] => [RIGHT(file)]' : '[LEFT(file)] <= [RIGHT(file)]')
        let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
        if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
    endif

    if a:syncType == 'l2r'
        call s:syncBackupFile(a:fileRight . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path)
    else
        call s:syncBackupFile(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileRight . '/' . a:path, a:fileLeft . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_DIR_LEFT(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if a:syncType == 'l2r'
        if !syncAll && get(t:, 'ZFDirDiffConfirmCopyDir', g:ZFDirDiffConfirmCopyDir)
            let hint = 'confirm copy?  ' . '[LEFT(dir)] => [RIGHT(___)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call ZF_DirDiff_mkdir(a:fileRight . '/' . a:path)
        call s:syncCopyDir(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, syncAll)
    else
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveDir', g:ZFDirDiffConfirmRemoveDir)
            let hint = 'confirm REMOVE?  ' . '[LEFT(dir)] <= [RIGHT(___)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, '', 'dl')
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupDir('', a:fileLeft . '/' . a:path)
        call ZF_DirDiff_rmdir(a:fileLeft . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_DIR_RIGHT(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if !(a:syncType == 'l2r')
        if !syncAll && get(t:, 'ZFDirDiffConfirmCopyDir', g:ZFDirDiffConfirmCopyDir)
            let hint = 'confirm copy?  ' . '[LEFT(___)] <= [RIGHT(dir)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call ZF_DirDiff_mkdir(a:fileLeft . '/' . a:path)
        call s:syncCopyDir(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, syncAll)
    else
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveDir', g:ZFDirDiffConfirmRemoveDir)
            let hint = 'confirm REMOVE?  ' . '[LEFT(___)] => [RIGHT(dir)]'
            let choice = s:syncConfirm(hint, '', a:fileRight . '/' . a:path, 'dr')
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupDir('', a:fileRight . '/' . a:path)
        call ZF_DirDiff_rmdir(a:fileRight . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_FILE_LEFT(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if a:syncType == 'l2r'
        if !syncAll && get(t:, 'ZFDirDiffConfirmCopyFile', g:ZFDirDiffConfirmCopyFile)
            let hint = 'confirm copy?  ' . '[LEFT(file)] => [RIGHT(___)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupFile(a:fileRight . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path)
    else
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveFile', g:ZFDirDiffConfirmRemoveFile)
            let hint = 'confirm REMOVE?  ' . '[LEFT(file)] <= [RIGHT(___)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, '', 'dl')
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupFile(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_rmfile(a:fileLeft . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_FILE_RIGHT(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if !(a:syncType == 'l2r')
        if !syncAll && get(t:, 'ZFDirDiffConfirmCopyFile', g:ZFDirDiffConfirmCopyFile)
            let hint = 'confirm copy?  ' . '[LEFT(___)] <= [RIGHT(file)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupFile(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileRight . '/' . a:path, a:fileLeft . '/' . a:path)
    else
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveFile', g:ZFDirDiffConfirmRemoveFile)
            let hint = 'confirm REMOVE?  ' . '[LEFT(___)] => [RIGHT(file)]'
            let choice = s:syncConfirm(hint, '', a:fileRight . '/' . a:path, 'dr')
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupFile(a:fileRight . '/' . a:path)
        call ZF_DirDiff_rmfile(a:fileRight . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_CONFLICT_DIR_LEFT(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if a:syncType == 'l2r'
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveFile', g:ZFDirDiffConfirmRemoveFile)
            let hint = 'confirm sync CONFLICT?  ' . '[LEFT(dir)] => [RIGHT(file)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupFile(a:fileRight . '/' . a:path)
        call ZF_DirDiff_rmfile(a:fileRight . '/' . a:path)
        call ZF_DirDiff_mkdir(a:fileRight . '/' . a:path)
        call s:syncCopyDir(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, 1)
    else
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveDir', g:ZFDirDiffConfirmRemoveDir)
            let hint = 'confirm sync CONFLICT?  ' . '[LEFT(dir)] <= [RIGHT(file)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupDir('', a:fileLeft . '/' . a:path)
        call ZF_DirDiff_rmdir(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileRight . '/' . a:path, a:fileLeft . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

function! s:sync_T_CONFLICT_DIR_RIGHT(fileLeft, fileRight, path, data, syncType, syncAll)
    let syncAll = a:syncAll
    if !(a:syncType == 'l2r')
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveFile', g:ZFDirDiffConfirmRemoveFile)
            let hint = 'confirm sync CONFLICT?  ' . '[LEFT(file)] <= [RIGHT(dir)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupFile(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_rmfile(a:fileLeft . '/' . a:path)
        call ZF_DirDiff_mkdir(a:fileLeft . '/' . a:path)
        call s:syncCopyDir(a:fileLeft, a:fileRight, a:path, a:data, a:syncType, 1)
    else
        if !syncAll && get(t:, 'ZFDirDiffConfirmRemoveDir', g:ZFDirDiffConfirmRemoveDir)
            let hint = 'confirm sync CONFLICT?  ' . '[LEFT(file)] => [RIGHT(dir)]'
            let choice = s:syncConfirm(hint, a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path, a:syncType)
            if choice == 'a' | let syncAll = 1 | elseif choice == 'n' || choice == 'q' | return choice | endif
        endif
        call s:syncBackupDir('', a:fileRight . '/' . a:path)
        call ZF_DirDiff_rmdir(a:fileRight . '/' . a:path)
        call ZF_DirDiff_cpfile(a:fileLeft . '/' . a:path, a:fileRight . '/' . a:path)
    endif
    return s:syncAllFix(syncAll)
endfunction

