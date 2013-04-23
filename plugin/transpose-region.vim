" transpose-region.vim: swap regions. Firstly visual select a region, press
"         g<A-t>; then visual select another regison, and press <A-t> to swap.
" Last Change:  2013-04-23
" Maintainer:   Fermat <Fermat618@gmail.com>
" Licence: This script is released under the Vim License.
" Install:
"     Put this file in ~/.vim/plugin
" Variable:
"     b:transpose_region_last_region
"     used to save the region when g<A-t> is pressed.

if has('python3')
    command! -nargs=1 PythonUsedInTransposeRegion python3 <args>
else
    command! -nargs=1 PythonUsedInTransposeRegion python <args>
end

function! s:mark_region()
    let b:transpose_region_last_region = {
                \ 'b': getpos("'<")[1 : 2],
                \ 'e': getpos("'>")[1 : 2],
                \ 'mode': mode(),
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
                \ 'mode': mode(),
                \ 'selection': &selection
                \ }
    PythonUsedInTransposeRegion transpose_region(vim.eval('snd_region'))
endfunction

PythonUsedInTransposeRegion << PYTHONEND
import vim

def transpose_region(snd_region):
    fst_region = vim.eval('b:transpose_region_last_region')

    fst_region['b'] = tuple(int(x) for x in fst_region['b'])
    snd_region['b'] = tuple(int(x) for x in snd_region['b'])
    fst_region['e'] = tuple(int(x) for x in fst_region['e'])
    snd_region['e'] = tuple(int(x) for x in snd_region['e'])

    def canonize_pos(pos):
        b = list(pos['b'])
        e = list(pos['e'])
        b[0] -= 1
        e[0] -= 1
        b[1] -= 1
        if pos['mode'] == 'V':
            e = len(vim.current.buffer[e[0]]) + 1
            # + 1 because of the '\n' on line end
            return
        if pos['selection'] == 'exclusive':
            if e[1] == 1:
                e[0] -= 1
                e[1] = len(vim.current.buffer[e[0]]) + 1
            else:
                e[0] -= 1
        return {'b': tuple(b), 'e': tuple(e)}

    fst_region = canonize_pos(fst_region)
    snd_region = canonize_pos(snd_region)
    if fst_region['b'] > snd_region['b']:
        fst_region, snd_region = snd_region, fst_region
    if fst_region['e'] > snd_region['b']:
        raise ValueError('The two region to swap cannot overlap!')

    start_lineno = fst_region['b'][0]
    end_lineno = snd_region['e'][0]
    rel_lines = vim.current.buffer[start_lineno : end_lineno + 1]
    rel_lines = [x + '\n' for x in rel_lines]

    rel_lens = [len(x) for x in rel_lines]
    def accu(lst):
        t = 0
        yield t
        for i in lst:
            t += i
            yield t
    rel_lens_acc = [x for x in accu(rel_lens)]

    def pos2idx(pos):
        return rel_lens_acc[pos[0] - start_lineno] + pos[1]

    fst_region['b'] = pos2idx(fst_region['b'])
    snd_region['b'] = pos2idx(snd_region['b'])
    fst_region['e'] = pos2idx(fst_region['e'])
    snd_region['e'] = pos2idx(snd_region['e'])

    t = ''.join(rel_lines)
    t = (t[0:fst_region['b']] + t[snd_region['b']:snd_region['e']] +
         t[fst_region['e']:snd_region['b']] +
         t[fst_region['b']:fst_region['e']] +
         t[snd_region['e']:])
    vim.current.buffer[start_lineno : end_lineno + 1] = t.splitlines()

PYTHONEND

vnoremap <silent> g<A-t> :<C-u>call <SID>mark_region()<CR>
vnoremap <silent> <A-t> :<C-u>call <SID>transpose_region()<CR>
