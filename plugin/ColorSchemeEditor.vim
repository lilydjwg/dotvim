" ColorSchemeEditor.vim: Provides a GUI to facilitate creating/editing a Vim colorscheme
" Maintainer:       Erik Falor <ewfalor@gmail.com>
" Date:             2008-05-08
" Version:          1.2.2
" License:          Vim license

let s:CSE_Version = "1.2.2"

" History: {{{
"   Version 1.2.2           Write colorscheme files with UNIX line endings,
"                           even on non-UNIX OSes.
"                           If the system's vim executable was not compiled
"                           with +clientserver feature, fall back to using
"                           gvim executable for IPC.
"                           Save dialog now prompts before overwriting an
"                           existing file. 
"
"   Version 1.2.1           Re-arranged code in __init__() so that all
"                           methods which may throw VimRemoteException are
"                           placed together under one try block instead of
"                           being spread throughout the constructor.
"
"   Version 1.2             Conditionally include SpellBad, SpellCap,
"                           SpellLocal, and SpellRare highlight groups in
"                           colorschemefile if spelling feature is enabled.
"
"   Version 1.1             Added Features:
"                           Color swatch displayed in TreeView along with hex
"                           triplet
"                           Display rgb.txt colors database in an auxiliary
"                           window
"                           Foreground and background color combinations for
"                           each highlight group are analysed for readability.
"
"   Version 1.0.2 beta:     Wasn't launching GUI in background on Unix systems
"                           Fixed a segfault in the TreeView on the PyGTK side.
"
"   Version 1.0 beta:       Initial upload
"}}}

" Initialization: {{{
if exists("g:loaded_colorschemeeditor")
    finish
endif
if !has('gui_running') || !has('clientserver') || v:version < 700
    finish
endif

let g:loaded_colorschemeeditor = s:CSE_Version
let s:keepcpo      = &cpo
set cpo&vim
"}}}

" Script Variables: {{{
let s:CSE_Path = globpath(&runtimepath, 'plugin/ColorSchemeEditor.py')

" for debugging purposes
let s:redrawCount = 0
"}}}

" Library Functions {{{

"External Interface {{{
function! CSE_GetAllHighlights() "{{{
    "print out all defined highlights
    redir => hi
    silent highlight
    "added so the final line isn't thrown away
    silent echo "END OF LINE"
    redir END
    return hi
endfunction "}}}

function! CSE_GetHighlight(hl) "{{{
    "print out single highlight
    redir => hi
    exe "silent highlight " . a:hl
    redir END
    return hi
endfunction "}}}

function! CSE_GetColorSchemeName() "{{{
    "called when refreshing or connecting to a new Vim instance
    let s:redrawCount = 0
    if exists("g:colors_name")
        return g:colors_name
    endif
    return
endfunction "}}}

function! CSE_GetMetadata() "{{{
    if exists("g:colors_name")
        let metadataDict = "g:" . g:colors_name . "_Metadata"
        if exists(metadataDict)
            return string(eval(metadataDict))
        endif
    endif
    return '{}'
endfunction "}}}

function! CSE_GetBackground() "{{{
    return &background
endfunction "}}}

function! CSE_SetBackground(value) "{{{
    "entered when the light or dark radio buttons are clicked
    if a:value == 'dark'
        set background=dark
    elseif a:value == 'light'
        set background=light
    endif
    redraw
endfunction "}}}

function! CSE_DoColorscheme(cs) "{{{
    "source the color scheme after saving the file
    "used to reset the metadata dict in Vim so that the
    "changes to the metadata stick
    execute "colorscheme " . fnamemodify(a:cs, ":t:r")
    redraw
endfunction "}}}

function! CSE_GetColorsDirs() "{{{
    "returns directories where colorschemes may be saved
    "used by the SaveAs dialog
    return globpath(&rtp, 'colors')
endfunction "}}}

function! CSE_SetHighlight(group, ...) "{{{
    "set highlight 'group' with arguments
    let cmd = ''
    for arg in a:000
        let cmd = cmd . ' ' . arg
    endfor

    exe 'highlight ' a:group . ' ' . cmd
    if exists("g:CSE_DebugMode")
        echom "redraw " . s:redrawCount
        let s:redrawCount += 1
    endif
    redraw

    redir => hi
    exe "silent highlight " . a:group
    redir END
    return hi
endfunction "}}}

function! CSE_GetDebugMode() "{{{
    if exists("g:CSE_DebugMode")
        return 1
    else
        return 0
    endif
endfunction "}}}

function! CSE_ShowHelp() "{{{
    help ColorSchemeEditor
endfunction"}}}

function! CSE_FindRgbTxt() "{{{
    "return location of rgb.txt
    let rgbtxt = ''
    if exists("g:rgbtxt") && filereadable(g:rgbtxt)
        let rgbtxt = g:rgbtxt
    else
        if has("win32") || has("win64")
            let rgbtxt = expand("$VIMRUNTIME/rgb.txt")
        elseif filereadable("/usr/X11R6/lib/X11/rgb.txt")
            let rgbtxt = "/usr/X11R6/lib/X11/rgb.txt"
        elseif filereadable("/usr/share/X11/rgb.txt")
            let rgbtxt = "/usr/share/X11/rgb.txt"
        endif
    endif
    return rgbtxt
endfunction "}}}

function! CSE_StdoutTest() "{{{
    "find out if 
    return "If you are reading this in a dialog box, you'll need to get a copy of Vim compiled with the clientserver feature"
endfunction "}}}

"}}}


" Launch the editor
function! <SID>ColorSchemeEditor () "{{{
    if has('gui_running') && has('clientserver')
        if has('gui_win32') 
            "if the editor is launched with the following command, it cannot
            "print any output, or else Vim will close it down
            if exists("g:CSE_DebugMode")
                exe 'silent !start python "' . s:CSE_Path . '" ' . v:servername .
                            \' "' . fnamemodify( s:CSE_Path, ':h') . '"'
            else
                exe 'silent ! start python "' . s:CSE_Path . '" '. v:servername .
                            \' "' . fnamemodify( s:CSE_Path, ':h') . '"'
            endif
        elseif has('unix')
            if exists("g:CSE_DebugMode")
                exe 'silent !xterm -e python "' . s:CSE_Path . '" '. v:servername .
                            \' "' . fnamemodify( s:CSE_Path, ':h') . '" &'
            else
                exe 'silent !python "' . s:CSE_Path . '" '. v:servername .
                            \' "' . fnamemodify( s:CSE_Path, ':h') . '" &'
            endif
        endif
    endif
endfunction "}}}

"}}}

" Setup menu and custom Vim command {{{
command! -nargs=0   ColorSchemeEditor call <SID>ColorSchemeEditor ()
amenu 9000.9000 &ColorSchemes.-EditorSep- :
amenu 9000.9000 &ColorSchemes.&Color\ Scheme\ Editor   :ColorSchemeEditor<CR>
"}}}

" Restore &cpo: {{{
let &cpo= s:keepcpo
unlet s:keepcpo
"}}}

"  vim: tabstop=4 shiftwidth=4 foldmethod=marker expandtab fileformat=unix:
