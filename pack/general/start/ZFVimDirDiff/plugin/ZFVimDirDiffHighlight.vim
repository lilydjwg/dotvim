
" ============================================================
function! ZF_DirDiffHL_resetHL_default()
    call ZF_DirDiffHL_resetHL_matchadd()
endfunction
function! ZF_DirDiffHL_addHL_default(group, line)
    call ZF_DirDiffHL_addHL_matchadd(a:group, a:line)
endfunction

" ============================================================
" use matchadd() and save/restore CursorLine highlight automatically
function! ZF_DirDiffHL_resetHL_matchaddWithCursorLineHL()
    call ZF_DirDiffHL_resetHL_matchadd()
    call s:setCursorLineHL()
endfunction
function! ZF_DirDiffHL_addHL_matchaddWithCursorLineHL(group, line)
    call ZF_DirDiffHL_addHL_matchadd(a:group, a:line)
endfunction

function! s:setCursorLineHL()
    execute 'augroup ZF_DirDiffHL_CursorLine_augroup_' . bufnr('')
    autocmd!
    autocmd BufDelete <buffer> call s:restoreCursorLineHL()
                \| call s:ZF_DirDiffHL_CursorLine_augroup_cleanup()
    autocmd BufHidden <buffer> call s:restoreCursorLineHL()
    autocmd BufEnter <buffer> call s:setCursorLineHL()
    execute 'augroup END'

    if exists('s:cursorlineSaved')
        return
    endif
    call s:saveCursorLineHL()

    if get(g:, 'ZF_DirDiffHL_matchadd_cursorline', 1)
        set cursorline
    endif
    if get(g:, 'ZF_DirDiffHL_matchadd_cursorlineHL', 1)
        highlight CursorLine gui=underline guibg=NONE guifg=NONE
        highlight CursorLine cterm=underline ctermbg=NONE ctermfg=NONE
    endif
endfunction
function! s:ZF_DirDiffHL_CursorLine_augroup_cleanup()
    execute 'augroup ZF_DirDiffHL_CursorLine_augroup_' . expand('<abuf>')
    autocmd!
    execute 'augroup END'
endfunction

function! s:saveCursorLineHL()
    let s:cursorlineSaved = &cursorline

    if exists('*execute')
        let highlight = execute('hi CursorLine')
    else
        try
            redir => highlight
            silent hi CursorLine
        finally
            redir END
        endtry
    endif
    if highlight =~ 'links to '
        let s:hl_link = matchstr(highlight, 'links to \zs\S*')
    elseif highlight =~ '\<cleared\>'
        let s:hl_link = ''
        for substr in ['term', 'cterm', 'ctermfg', 'ctermbg',
                    \ 'gui', 'guifg', 'guibg', 'guisp']
            let s:hl_{substr} = substr . '=NONE'
        endfor
    else
        let s:hl_link = ''
        for substr in ['term', 'cterm', 'ctermfg', 'ctermbg',
                    \ 'gui', 'guifg', 'guibg', 'guisp']
            if highlight =~ substr . '='
                let s:hl_{substr} = matchstr(highlight,
                            \ substr . '=\S*')
            else
                let s:hl_{substr} = substr . '=NONE'
            endif
        endfor
    endif
endfunction
function! s:restoreCursorLineHL()
    if !exists('s:cursorlineSaved')
        return
    endif

    let &cursorline = s:cursorlineSaved

    hi clear CursorLine
    if s:hl_link == ''
        exe 'hi CursorLine' s:hl_term s:hl_cterm s:hl_ctermfg
                    \ s:hl_ctermbg s:hl_gui s:hl_guifg s:hl_guibg
                    \ s:hl_guisp
    elseif s:hl_link != 'NONE'
        exe 'hi link CursorLine' s:hl_link
    endif

    unlet s:cursorlineSaved
    unlet s:hl_link
endfunction

" ============================================================
" use matchadd()
" * highlight can not be applied to entire line
function! ZF_DirDiffHL_resetHL_matchadd()
    call clearmatches()
    let b:ZF_DirDiffHL_matchadd_HLSaved = []
    execute 'augroup ZF_DirDiffHL_matchadd_augroup_' . bufnr('')
    autocmd!
    autocmd BufDelete <buffer> call clearmatches()
                \| call s:ZF_DirDiffHL_matchadd_augroup_cleanup()
    autocmd BufHidden <buffer> call clearmatches()
    autocmd BufEnter <buffer>
                \  for hl in b:ZF_DirDiffHL_matchadd_HLSaved
                \|     call s:ZF_DirDiffHL_addHL_matchadd(hl[0], hl[1])
                \| endfor
    execute 'augroup END'
endfunction
function! s:ZF_DirDiffHL_matchadd_augroup_cleanup()
    execute 'augroup ZF_DirDiffHL_matchadd_augroup_' . expand('<abuf>')
    autocmd!
    execute 'augroup END'
endfunction

function! ZF_DirDiffHL_addHL_matchadd(group, line)
    call add(b:ZF_DirDiffHL_matchadd_HLSaved, [a:group, a:line])
    call s:ZF_DirDiffHL_addHL_matchadd(a:group, a:line)
endfunction
function! s:ZF_DirDiffHL_addHL_matchadd(group, line)
    if get(g:, 'ZF_DirDiffHL_matchadd_useExactHL', 1)
        let line = getline(a:line)
        if a:line >= b:ZFDirDiff_iLineOffset + 1 && a:line < len(t:ZFDirDiff_dataUIVisible) + b:ZFDirDiff_iLineOffset + 1
            let line = substitute(line, '/', '', 'g')

            " calc indent
            let indentIndex = 0
            while line[indentIndex] == ' '
                let indentIndex += 1
            endwhile
            if line[indentIndex] == g:ZFDirDiffUI_dirExpandable
                let dirChar = g:ZFDirDiffUI_dirExpandable
            elseif line[indentIndex] == g:ZFDirDiffUI_dirCollapsible
                let dirChar = g:ZFDirDiffUI_dirCollapsible
            else
                let dirChar = ''
            endif
            if dirChar != ''
                let dirCharLen = len(dirChar)
                if indentIndex + dirCharLen + 1 < len(line)
                            \ && line[indentIndex + dirCharLen] == ' '
                    let indentIndex += dirCharLen + 1
                endif
            endif

            call matchadd(a:group, ''
                        \   . '\%' . a:line . 'l'
                        \   . '\%>' . indentIndex . 'c'
                        \   . '\%<' . (len(line) + 1) . 'c'
                        \ )
        else
            call matchadd(a:group, '\%' . a:line . 'l')
        endif
    else
        if exists('*matchaddpos')
            call matchaddpos(a:group, [a:line])
        else
            call matchadd(a:group, '\%' . a:line . 'l')
        endif
    endif
endfunction

" ============================================================
" use sign-commands
" * current line would have no highlight
function! ZF_DirDiffHL_resetHL_sign()
    silent! execute 'sign unplace * buffer=' . bufnr('')

    sign define ZFDirDiffHLSign_Title linehl=ZFDirDiffHL_Title
    sign define ZFDirDiffHLSign_Dir linehl=ZFDirDiffHL_Dir
    sign define ZFDirDiffHLSign_DirContainDiff linehl=ZFDirDiffHL_DirContainDiff
    sign define ZFDirDiffHLSign_Same linehl=ZFDirDiffHL_Same
    sign define ZFDirDiffHLSign_Diff linehl=ZFDirDiffHL_Diff
    sign define ZFDirDiffHLSign_DirOnlyHere linehl=ZFDirDiffHL_DirOnlyHere
    sign define ZFDirDiffHLSign_DirOnlyThere linehl=ZFDirDiffHL_DirOnlyThere
    sign define ZFDirDiffHLSign_FileOnlyHere linehl=ZFDirDiffHL_FileOnlyHere
    sign define ZFDirDiffHLSign_FileOnlyThere linehl=ZFDirDiffHL_FileOnlyThere
    sign define ZFDirDiffHLSign_ConflictDir linehl=ZFDirDiffHL_ConflictDir
    sign define ZFDirDiffHLSign_ConflictFile linehl=ZFDirDiffHL_ConflictFile
    sign define ZFDirDiffHLSign_MarkToDiff linehl=ZFDirDiffHL_MarkToDiff

    let b:ZFDirDiffHLSignIndex = 1
endfunction
function! ZF_DirDiffHL_addHL_sign(group, line)
    let cmd = 'sign place '
    let cmd .= b:ZFDirDiffHLSignIndex
    let cmd .= ' line=' . a:line
    let cmd .= ' name=' . substitute(a:group, 'ZFDirDiffHL_', 'ZFDirDiffHLSign_', '')
    let cmd .= ' buffer=' . bufnr('%')
    execute cmd
    let b:ZFDirDiffHLSignIndex += 1
endfunction

