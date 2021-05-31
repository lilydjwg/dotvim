
if !get(g:, 'ZFDirDiff_nerdtreeMenu_enable', 1)
    finish
endif

call NERDTreeAddMenuItem({
            \   'text': get(g:, 'ZFDirDiff_nerdtreeMenu_text', '(z) mark to diff'),
            \   'shortcut': get(g:, 'ZFDirDiff_nerdtreeMenu_key', 'z'),
            \   'callback': 'NERDTreeMarkToDiff',
            \ })

function! NERDTreeMarkToDiff()
    let path = g:NERDTreeFileNode.GetSelected().path.str()
    redraw!
    call ZF_DirDiffMark(path, {
                \   'markDir' : 0,
                \ })
endfunction

