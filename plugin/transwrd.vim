
" transwrd.vim: Swap two words as M-t (transpose-words) function in Emacs (Bash)
"               This version of the script act more likely to M-t in Bash
"               rather than in emacs.
" Last Change:  2012-02-25
" Maintainer:   Fermat <Fermat618@gmail.com>
" Licence: This script is released under the Vim License.
" Install:
"     Put this file in ~/.vim/plugin
" Mappings:
"     <Alt-t> (<Meta-t>) in any mode except command-line with '=' prompt.
"         transpose words. Same as press <Alt-t> (<Meta-t>) in Emacs or
"         Bash(default mode)
"         count can also be used, e.g. 8<Alt-t>
"         repeat.vim (vimscript#2136) is supported. When repeat.vim present,
"         you can use dot (.) to repeat.
" Variable:
"     g:transwrd_wordpattern
"     b:transwrd_wordpattern
"     When b:transwrd_wordpattern is set, wordpattern is set to it, otherwise,
"     g:transwrd_wordpattern, otherwise, '\k\+'

if exists("g:loaded_transwrd")
    finish
endif
let g:loaded_transwrd = 1
let s:save_cpo = &cpo
set cpo&vim

let s:wordpattern = '\k\+'

" Functions
let s:largest_offset = 1024 - 1
function s:transpose_word_inline(cline, col)
    if exists("b:transwrd_wordpattern")
        let wordpattern = b:transwrd_wordpattern
    elseif exists("g:transwrd_wordpattern")
        let wordpattern = g:transwrd_wordpattern
    else
        let wordpattern = s:wordpattern
    endif

    if a:col > s:largest_offset
        let m_start0 = a:col - s:largest_offset
    else
        let m_start0 = 0
    endif
    let m_start = m_start0
    let prev = {}
    let this = {}
    let m_start_new = match(a:cline, wordpattern, m_start)
    if m_start_new == -1
        return [a:cline, a:col]
    else
        let prev.start = m_start_new
        let prev.end = matchend(a:cline, wordpattern, m_start)
        if prev.end - prev.start == 0
            return [a:cline, a:col]
        endif
        let prev.str = matchstr(a:cline, wordpattern, m_start)
        let m_start = prev.end
    endif
    let m_start_new = match(a:cline, wordpattern, m_start)
    if m_start_new == -1
        return [a:cline, a:col]
    else
        let this.start = m_start_new
        let this.end = matchend(a:cline, wordpattern, m_start)
        if this.end - this.start == 0
            return [a:cline, a:col]
        endif
        let this.str = matchstr(a:cline, wordpattern, m_start)
        let m_start = this.end
    endif

    if prev.end > a:col - 1
        return [a:cline, a:col]
    elseif this.end > a:col - 1
    else
        let m_start_new = match(a:cline, wordpattern, m_start)
        while m_start_new != -1
            let m_end = matchend(a:cline, wordpattern, m_start)
            if m_end - m_start_new == 0
                return [a:cline, a:col]
            endif
            let prev = deepcopy(this)
            let this.start = m_start_new
            let this.end = m_end
            let this.str = matchstr(a:cline, wordpattern, m_start)
            let m_start = this.end
            let m_start_new = match(a:cline, wordpattern, m_start)
            if this.end > a:col - 1
                break
            endif
        endwhile
    endif
    if m_start0 != 0 && prev.start == m_start0
        echohl WarningMsg
        echomsg "transwrd.vim: Too long word"
             \ "or too many non-word charactors before cursor!"
        echohl None
        return [a:cline, a:col]
    endif
    let cline = strpart(a:cline, 0, prev.start) . this.str .
                \ strpart(a:cline, prev.end, this.start - prev.end) .
                \ prev.str . strpart(a:cline, this.end)
    return [cline, this.end + 1]
endfunction

function s:transpose_word()
    if mode() == 'i'
        let counts = 1
    elseif exists("s:last_mode_is_insert")
        let counts = 1
    elseif v:count < 1
        let counts = 1
    else
        let counts = v:count
    endif
    if mode() == 'i'
        let s:last_mode_is_insert = 1
    else
        unlet! s:last_mode_is_insert
    endif

    let cline = getline(".")
    let col = col(".")
    let i = 1
    let [cline_out, col_out] = s:transpose_word_inline(cline, col)
    while i < counts
        let i += 1
        let [cline_out, col_out] = s:transpose_word_inline(cline_out, col_out)
    endwhile
    if [cline_out, col_out] ==# [cline, col]
        return ''
    else
        let lnum = line(".")
        call setline(lnum, cline_out)
        if col_out != col
            call setpos(".", [0, lnum, col_out, 0])
        endif
    endif
    if mode() == 'n'
        silent! call repeat#set("\<Plug>Transposewords", v:count)
        " In insert mode this cause problem when the cursor in in the end of a
        " line.
    endif
    return ''
endfunction

function s:transpose_word_cmdline()
    let cline = getcmdline()
    let col = getcmdpos()
    let [cline_out, col_out] = s:transpose_word_inline(cline, col)
    if [cline_out, col_out] !=# [cline, col]
        call setcmdpos(col_out)
    endif
    return cline_out
endfunction

" Mappings
nnoremap <unique> <silent> <Plug>Transposewords
                \ :<C-u>call <SID>transpose_word()<CR>
inoremap <unique> <silent> <Plug>Transposewords <C-g>u<C-R>=<SID>transpose_word()<CR>
cnoremap <unique> <Plug>Transposewords <C-\>e<SID>transpose_word_cmdline()<CR>

if !hasmapto('<Plug>Transposewords')
    nmap <unique> <M-t> <Plug>Transposewords
    imap <unique> <M-t> <Plug>Transposewords
    cmap <unique> <M-t> <Plug>Transposewords
endif

let &cpo = s:save_cpo

" vim:set ft=vim expandtab sw=4 tw=79:
