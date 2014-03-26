" transpose-region.vim: swap regions. Firstly visual select a region, press
"         g<A-t>; then visual select another regison, and press <A-t> to swap.
" Last Change:  2014-03-26
" Author:       Fermat <Fermat618@gmail.com>
" Maintainer:   lilydjwg <lilydjwg@gmail.com>
" Licence:      This script is released under the Vim License.
" Install:
"     Put this file in ~/.vim/plugin
" Variable:
"     b:transpose_region_last_region
"     used to save the region when g<A-t> is pressed.

if !has('python3')
    finish
end

function! s:mark_region()
    let b:transpose_region_last_region = {
                \ 'b': getpos("'<")[1 : 2],
                \ 'e': getpos("'>")[1 : 2],
                \ 'mode': visualmode(),
                \ 'selection': &selection
                \ }
endfunction

function! s:transpose_region()
    if !exists('b:transpose_region_last_region')
        return
    endif
    let snd_region = {
                \ 'b': getpos("'<")[1 : 2],
                \ 'e': getpos("'>")[1 : 2],
                \ 'mode': visualmode(),
                \ 'selection': &selection
                \ }
    python3 transpose_region(vim.eval('snd_region'))
endfunction

python3 << PYTHONEND
import vim
from itertools import accumulate

def transpose_region(snd_region):
    enc = vim.eval('&l:encoding')
    fst_region = vim.eval('b:transpose_region_last_region')

    fst_region['b'] = [int(x) for x in fst_region['b']]
    snd_region['b'] = [int(x) for x in snd_region['b']]
    fst_region['e'] = [int(x) for x in fst_region['e']]
    snd_region['e'] = [int(x) for x in snd_region['e']]

    def canonize_region(region):
        b = region['b']
        e = region['e']

        # adjust index base for Python
        b[0] -= 1
        e[0] -= 1
        b[1] -= 1
        e[1] -= 1

        if region['mode'] == 'V':
            # select to line end, regardless of 'selection'
            line = vim.current.buffer[e[0]]
            e[1] = len(line.encode(enc)) + 1
        else:
            line = vim.current.buffer[e[0]] + '\n'
            last_ch_tail = line.encode(enc)[e[1]:]
            if region['selection'] != 'exclusive':
              last_ch_len = len(last_ch_tail.decode(enc)[0].encode(enc))
              e[1] += last_ch_len

    canonize_region(fst_region)
    canonize_region(snd_region)
    if fst_region['b'] > snd_region['b']:
        fst_region, snd_region = snd_region, fst_region
    if fst_region['e'] > snd_region['b']:
        raise ValueError('The two region to swap cannot overlap!')

    start_lineno = fst_region['b'][0]
    end_lineno = snd_region['e'][0]
    rel_lines = vim.current.buffer[start_lineno : end_lineno + 1]
    rel_lines = [x + '\n' for x in rel_lines]
    rel_lens_acc = [0]
    rel_lens_acc.extend(accumulate(len(x.encode(enc)) for x in rel_lines))

    def pos2idx(pos):
        return rel_lens_acc[pos[0] - start_lineno] + pos[1]

    fst_region['b'] = pos2idx(fst_region['b'])
    snd_region['b'] = pos2idx(snd_region['b'])
    fst_region['e'] = pos2idx(fst_region['e'])
    snd_region['e'] = pos2idx(snd_region['e'])
    # print(rel_lines, rel_lens_acc, fst_region, snd_region)

    t = ''.join(rel_lines).encode(enc)
    t = (t[0:fst_region['b']] + t[snd_region['b']:snd_region['e']] +
         t[fst_region['e']:snd_region['b']] +
         t[fst_region['b']:fst_region['e']] +
         t[snd_region['e']:]).decode(enc)
    vim.current.buffer[start_lineno : end_lineno + 1] = t.splitlines()

PYTHONEND

vnoremap <silent> g<A-t> :<C-u>call <SID>mark_region()<CR>
vnoremap <silent> <A-t> :<C-u>call <SID>transpose_region()<CR>
