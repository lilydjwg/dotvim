" transwrd.vim: As M-t (transpose-words) function in Emacs (bash)
"               This version of the script act more likely to M-t in bash
"               rather than in emacs.
" Last Change:  2011-07-05
" Maintainer:   Fermat <Fermat618@gmail.com>
" Licence: This script is released under the Vim License.
" Install: 
"     Put this file in ~/.vim/plugin
" Mappings:
"     <Alt-t> (<Meta-t>) in any mode except cmdline with = prompt.
"         transpose words. Same as press <Alt-t> (<Meta-t>) in Emacs or
"         bash(default mode)

if !has('python3')
    finish
endif
if exists("g:loaded_transwrd")
    finish
endif
let g:loaded_transwrd = 1
let s:save_cpo = &cpo
set cpo&vim


" Functions
python3 << EOF

import vim
import re

vim_enc = vim.eval('&enc')
p_word = re.compile(r'\w+')

def transpose_word_inline(cline, col):
    uni_pos = len((cline.encode(vim_enc)[:col]).decode())
    line_iter = p_word.finditer(cline)
    try:
        prev = next(line_iter)
        this = next(line_iter)
    except StopIteration:
        return (cline, col)

    if prev.end() > uni_pos:
        return (cline, col)
    elif this.end() > uni_pos:
        pass
    else:
        for word in line_iter:
            prev = this
            this = word
            if this.end() > uni_pos:
                break

    line_out = cline[0:prev.start()] + this.group() + \
            cline[prev.end():this.start()] + prev.group() + \
            cline[this.end():]
    col_out = len(cline[:this.end()].encode(vim_enc))

    return (line_out, col_out)

def transpose_word():
    cline = vim.current.line
    col = vim.current.window.cursor[1]
    (cline_out, col_out) = transpose_word_inline(cline, col)
    if (cline_out, col_out) == (cline, col):
        return False
    vim.current.line = cline_out
    vim.current.window.cursor = (vim.current.window.cursor[0], col_out)
    return True

def transpose_word_cmdline():
    cline = vim.eval("getcmdline()")
    col = int(vim.eval("getcmdpos()")) - 1
    (cline_out, col_out) = transpose_word_inline(cline, col)
    if (cline_out, col_out) == (cline, col):
        return False
    vim.command("let s:cmdline=" + '"' + cline_out + '"')
    vim.command("call setcmdpos(" + str(col_out + 1) + ")")
    return True

EOF

function s:transpose_word()
    py3 transpose_word()
    return ''
endfunction

function s:transpose_word_cmdline()
    py3 transpose_word_cmdline()
    return s:cmdline
endfunction

" Mappings
nnoremap <unique> <silent> <Plug>Transposewords :py3 transpose_word()<CR>
inoremap <unique> <silent> <Plug>Transposewords <C-R>=<SID>transpose_word()<CR>
cnoremap <unique> <Plug>Transposewords <C-\>e<SID>transpose_word_cmdline()<CR>

if !hasmapto('<Plug>Transposewords')
    nmap <unique> <M-t> <Plug>Transposewords
    imap <unique> <M-t> <Plug>Transposewords
    cmap <unique> <M-t> <Plug>Transposewords
endif

let &cpo = s:save_cpo

" vim:set ft=vim expandtab sw=4 sts=4 ts=4 tw=79:
