" vim-git-log.vim - Browse your git log changes
" Maintainer:  Eric Johnson <http://kablamo.org>
" Version:     0.01
"
" TODO: 
"  - smoother diff action
"  - exit if Fugitive is not found

let g:RibbonBufname = 'Ribbon'
let g:GitLogBufname = 'GitLog'
let g:RibbonHeight  = 10
let g:GitLogGitCmd  = 'git log --pretty=format:''\%an (\%cr) \%p:\%h\%n\%s'' --name-only --no-merges --topo-order '
let g:GitLogShowCmd = 'git show '
let g:GitLogShowLines = 300

let s:bufnr = 0
let s:cmd = 0
let s:lines = 0

function! s:GitLog(ribbon, ...)
    " create new buffer
    let l:bufname = g:GitLogBufname
    if a:ribbon == 1
        let l:bufname = g:RibbonBufname
    endif
    let l:cmd = 'edit ' . l:bufname
    execute l:cmd

    " setup new buffer
    call vimgitlog#setupNewBuf()
    noremap <buffer> <silent> q    :call vimgitlog#quit()<cr>
    noremap <buffer> <silent> d    :call vimgitlog#diff()<cr>
    noremap <buffer> <silent> <cr> :call vimgitlog#showdiffstat()<cr>
    noremap <buffer> <silent> f    :call vimgitlog#nextFile()<cr>
    noremap <buffer> <silent> F    :call vimgitlog#prevFile()<cr>
    noremap <buffer> <silent> M    :call vimgitlog#loadMoreCmd('-')<cr>

    " load git log output into the new buffer
    let l:cmd = g:GitLogGitCmd
    if a:ribbon == 1
        let l:cmd = l:cmd . '--reverse _ribbon..origin/master'
    endif
    for c in a:000
        let l:cmd = l:cmd . ' ' . c . ' '
    endfor
    call vimgitlog#loadMoreCmd(l:cmd)

    let s:bufnr = bufnr(g:RibbonBufname)
endfunction

function! vimgitlog#loadMoreCmd(cmd)
    if a:cmd != '-'
        let s:lines = g:GitLogShowLines
        let s:cmd   = a:cmd
    else
        let s:lines = s:lines + g:GitLogShowLines
        normal G
    endif
    let l:fullCmd = 'silent read ! ' . s:cmd . ' | head -' . s:lines . ' | tail -' . g:GitLogShowLines
    execute l:fullCmd
    if a:cmd != '-'
        normal 1G
    else
        let l:l = s:lines - g:GitLogShowLines
        exe "normal " . l:l . "G"
    endif
endfunction

function! vimgitlog#quit()
    if bufloaded('diffstat')
        wincmd l
        bdelete
    endif
    bdelete
endfunction

function! vimgitlog#loadCmdIntoBuffer(cmd)
    let l:fullCmd = 'silent 0read ! ' . a:cmd
    execute l:fullCmd
    normal 1G
endfunction

function! vimgitlog#setupNewBuf()
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nowrap
    setlocal ft=git
    "set bufhidden=hide
    "setlocal nobuflisted
    "setlocal nolist
    setlocal noinsertmode
    setlocal nonumber
    setlocal cursorline
    setlocal nospell
    setlocal matchpairs=""
    if exists('+concealcursor')
      setlocal concealcursor=nc conceallevel=2
    endif
endfunction

function! vimgitlog#showdiffstat()
    let l:oldLineNr = line(".")
    let l:lineNr    = search(') \(\w\+:\w\+\)$', 'b')
    let l:line      = getline(l:lineNr)
    let l:revisions = substitute(l:line, '.*) \(\w\+:\w\+\)$', '\=submatch(1)', "")
    let l:rev       = split(l:revisions, ':')
    execute 'normal ' . l:lineNr . 'Gjj'

    if bufloaded('diffstat')
        wincmd l
    else
        vsplit diffstat
        wincmd r
        call vimgitlog#setupNewBuf()
    endif

    " clear buffer
    normal 1GdG

    " load diffstat into buffer
    let l:cmd = 'git show ' . l:rev[1]
    call vimgitlog#loadCmdIntoBuffer(l:cmd)

    wincmd h
endfunction

function! vimgitlog#nextFile()
    let l:oldLineNr = line(".")
    let l:lineNr    = search(') \(\w\+:\w\+\)$')
    let l:line      = getline(l:lineNr)
    let l:revisions = substitute(l:line, '.*) \(\w\+:\w\+\)$', '\=submatch(1)', "")
    let l:rev       = split(l:revisions, ':')
    execute 'normal ' . l:lineNr . 'Gjj'
endfunction

function! vimgitlog#prevFile()
    let l:oldLineNr = line(".")
    let l:lineNr    = search(') \(\w\+:\w\+\)$', 'b')
    let l:lineNr    = search(') \(\w\+:\w\+\)$', 'b')
    let l:line      = getline(l:lineNr)
    let l:revisions = substitute(l:line, '.*) \(\w\+:\w\+\)$', '\=submatch(1)', "")
    let l:rev       = split(l:revisions, ':')
    execute 'normal ' . l:lineNr . 'Gjj'
endfunction

function! vimgitlog#diff()

    " get filename to diff
    let l:filename = getline(".")
    
    " return if file does not exist
    let l:cwd = getcwd()
    Gcd
    let l:repo = getcwd()
    if !filereadable(l:repo . '/' . l:filename)
        execute 'cd ' . l:cwd
        return
    endif

    " parse git output in Ribbon buffer to get revisions
    let l:oldLineNr = line(".")
    let l:lineNr    = search(') \(\w\+:\w\+\)$', 'b')
    let l:line      = getline(l:lineNr)
    let l:revisions = substitute(l:line, '.*) \(\w\+:\w\+\)$', '\=submatch(1)', "")
    let l:rev       = split(l:revisions, ':')
    execute 'normal ' . l:oldLineNr . 'G'

    " show rev0:file
    execute 'Git! show ' . l:rev[0] . ':' . l:filename
    let l:bufnr0 = bufnr("")

    " show rev1:file
    execute 'rightbelow vsplit | Git! show ' . l:rev[1] . ':' . l:filename
    let l:bufnr1 = bufnr("")
    let l:cmd='nnoremap <buffer> <silent> q :' . l:bufnr0 . 'bunload<cr>:' . l:bufnr1 . 'bunload<cr>'

    " show diff
    diffthis
    wincmd p
    execute l:cmd
    diffthis
    wincmd p
    execute l:cmd

    " return user to original wd
    execute 'cd ' . l:cwd
endfunction

function! s:RibbonSave()
    silent !git tag --force _ribbon origin/master
    redraw!
endfunction

command! -nargs=* GitLog     :call s:GitLog(0, <f-args>)
command!          Ribbon     :call s:GitLog(1)
command!          RibbonSave :call s:RibbonSave()


