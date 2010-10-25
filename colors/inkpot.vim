" Vim color file
" Name:       inkpot.vim
" Maintainer: Ciaran McCreesh <ciaranm@gentoo.org>
" This should work in the GUI, rxvt-unicode (88 colour mode) and xterm (256
" colour mode). It won't work in 8/16 colour terminals.

set background=dark
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "inkpot"

" map a urxvt cube number to an xterm-256 cube number
fun! <SID>M(a)
    return strpart("0135", a:a, 1) + 0
endfun

" map a urxvt colour to an xterm-256 colour
fun! <SID>X(a)
    if &t_Co == 88
        return a:a
    else
        if a:a == 8
            return 237
        elseif a:a < 16
            return a:a
        elseif a:a > 79
            return 232 + (3 * (a:a - 80))
        else
            let l:b = a:a - 16
            let l:x = l:b % 4
            let l:y = (l:b / 4) % 4
            let l:z = (l:b / 16)
            return 16 + <SID>M(l:x) + (6 * <SID>M(l:y)) + (36 * <SID>M(l:z))
        endif
    endif
endfun

if has("gui_running")
    hi Normal         gui=NONE   guifg=#cfbfad   guibg=#1e1e27
    hi IncSearch      gui=BOLD   guifg=#303030   guibg=#cd8b60
    hi Search         gui=NONE   guifg=#303030   guibg=#cd8b60
    hi ErrorMsg       gui=BOLD   guifg=#ffffff   guibg=#ff3300
    hi WarningMsg     gui=BOLD   guifg=#ffffff   guibg=#ff6600
    hi ModeMsg        gui=BOLD   guifg=#7e7eae   guibg=NONE
    hi MoreMsg        gui=BOLD   guifg=#7e7eae   guibg=NONE
    hi Question       gui=BOLD   guifg=#ffcd00   guibg=NONE
    hi StatusLine     gui=BOLD   guifg=#b9b9b9   guibg=#3e3e5e
    hi StatusLineNC   gui=NONE   guifg=#b9b9b9   guibg=#3e3e5e
    hi VertSplit      gui=NONE   guifg=#b9b9b9   guibg=#3e3e5e
    hi WildMenu       gui=BOLD   guifg=#ffcd00   guibg=#1e1e2e

    hi DiffText       gui=NONE   guifg=#ffffcd   guibg=#00cd00
    hi DiffChange     gui=NONE   guifg=#ffffcd   guibg=#008bff
    hi DiffDelete     gui=NONE   guifg=#ffffcd   guibg=#cd0000
    hi DiffAdd        gui=NONE   guifg=#ffffcd   guibg=#00cd00

    hi Cursor         gui=NONE   guifg=#404040   guibg=#8b8bff
    hi lCursor        gui=NONE   guifg=#404040   guibg=#8b8bff
    hi CursorIM       gui=NONE   guifg=#404040   guibg=#8b8bff

    hi Folded         gui=NONE   guifg=#cfcfcd   guibg=#4b208f
    hi FoldColumn     gui=NONE   guifg=#8b8bcd   guibg=#2e2e2e

    hi Directory      gui=NONE   guifg=#00ff8b   guibg=NONE
    hi LineNr         gui=NONE   guifg=#8b8bcd   guibg=#2e2e2e
    hi NonText        gui=BOLD   guifg=#8b8bcd   guibg=NONE
    hi SpecialKey     gui=BOLD   guifg=#8b00cd   guibg=NONE
    hi Title          gui=BOLD   guifg=#af4f4b   guibg=#1e1e27
    hi Visual         gui=NONE   guifg=#603030   guibg=#edab60

    hi Comment        gui=NONE   guifg=#cd8b00   guibg=NONE
    hi Constant       gui=NONE   guifg=#ffcd8b   guibg=NONE
    hi String         gui=NONE   guifg=#ffcd8b   guibg=#404040
    hi Error          gui=NONE   guifg=#ffffff   guibg=#ff0000
    hi Identifier     gui=NONE   guifg=#ff8bff   guibg=NONE
    hi Ignore         gui=NONE   guifg=#8b8bcd   guibg=NONE
    hi Number         gui=NONE   guifg=#506dbd   guibg=NONE
    hi PreProc        gui=NONE   guifg=#409090   guibg=NONE
    hi Special        gui=NONE   guifg=#c080d0   guibg=NONE
    hi Statement      gui=NONE   guifg=#808bed   guibg=NONE
    hi Todo           gui=BOLD   guifg=#303030   guibg=#c080d0
    hi Type           gui=NONE   guifg=#ff8bff   guibg=NONE
    hi Underlined     gui=BOLD   guifg=#ffffcd   guibg=NONE
    hi TaglistTagName gui=BOLD   guifg=#808bed   guibg=NONE

else
    exec "hi Normal         cterm=NONE   ctermfg=" . <SID>X("78") . "   ctermbg=" . <SID>X(80) . ""
    exec "hi IncSearch      cterm=BOLD   ctermfg=" . <SID>X("80") . "   ctermbg=" . <SID>X(73) . ""
    exec "hi Search         cterm=NONE   ctermfg=" . <SID>X("80") . "   ctermbg=" . <SID>X(73) . ""
    exec "hi ErrorMsg       cterm=BOLD   ctermfg=" . <SID>X("79") . "   ctermbg=" . <SID>X(64) . ""
    exec "hi WarningMsg     cterm=BOLD   ctermfg=" . <SID>X("79") . "   ctermbg=" . <SID>X(68) . ""
    exec "hi ModeMsg        cterm=BOLD   ctermfg=" . <SID>X("39") . ""
    exec "hi MoreMsg        cterm=BOLD   ctermfg=" . <SID>X("39") . ""
    exec "hi Question       cterm=BOLD   ctermfg=" . <SID>X("72") . ""
    exec "hi StatusLine     cterm=BOLD   ctermfg=" . <SID>X("84") . "   ctermbg=" . <SID>X(81) . ""
    exec "hi StatusLineNC   cterm=NONE   ctermfg=" . <SID>X("84") . "   ctermbg=" . <SID>X(81) . ""
    exec "hi VertSplit      cterm=NONE   ctermfg=" . <SID>X("84") . "   ctermbg=" . <SID>X(82) . ""
    exec "hi WildMenu       cterm=BOLD   ctermfg=" . <SID>X("72") . "   ctermbg=" . <SID>X(80) . ""

    exec "hi DiffText       cterm=NONE   ctermfg=" . <SID>X("78") . "   ctermbg=" . <SID>X(24) . ""
    exec "hi DiffChange     cterm=NONE   ctermfg=" . <SID>X("78") . "   ctermbg=" . <SID>X(23) . ""
    exec "hi DiffDelete     cterm=NONE   ctermfg=" . <SID>X("78") . "   ctermbg=" . <SID>X(48) . ""
    exec "hi DiffAdd        cterm=NONE   ctermfg=" . <SID>X("78") . "   ctermbg=" . <SID>X(24) . ""

    exec "hi Cursor         cterm=NONE   ctermfg=" . <SID>X("8") . "    ctermbg=" . <SID>X(39) . ""
    exec "hi lCursor        cterm=NONE   ctermfg=" . <SID>X("8") . "    ctermbg=" . <SID>X(39) . ""
    exec "hi CursorIM       cterm=NONE   ctermfg=" . <SID>X("8") . "    ctermbg=" . <SID>X(39) . ""

    exec "hi Folded         cterm=NONE   ctermfg=" . <SID>X("78") . "   ctermbg=" . <SID>X(35) . ""
    exec "hi FoldColumn     cterm=NONE   ctermfg=" . <SID>X("38") . "   ctermbg=" . <SID>X(80) . ""

    exec "hi Directory      cterm=NONE   ctermfg=" . <SID>X("29") . "   ctermbg=NONE"
    exec "hi LineNr         cterm=NONE   ctermfg=" . <SID>X("38") . "   ctermbg=" . <SID>X(80) . ""
    exec "hi NonText        cterm=BOLD   ctermfg=" . <SID>X("38") . "   ctermbg=NONE"
    exec "hi SpecialKey     cterm=BOLD   ctermfg=" . <SID>X("34") . "   ctermbg=NONE"
    exec "hi Title          cterm=BOLD   ctermfg=" . <SID>X("52") . "   ctermbg=" . <SID>X(80) . ""
    exec "hi Visual         cterm=NONE   ctermfg=" . <SID>X("80") . "   ctermbg=" . <SID>X(73) . ""

    exec "hi Comment        cterm=NONE   ctermfg=" . <SID>X("52") . "   ctermbg=NONE"
    exec "hi Constant       cterm=NONE   ctermfg=" . <SID>X("73") . "   ctermbg=NONE"
    exec "hi String         cterm=NONE   ctermfg=" . <SID>X("73") . "   ctermbg=" . <SID>X(8) . ""
    exec "hi Error          cterm=NONE   ctermfg=" . <SID>X("79") . "   ctermbg=" . <SID>X(64) . ""
    exec "hi Identifier     cterm=NONE   ctermfg=" . <SID>X("71") . "   ctermbg=NONE"
    exec "hi Ignore         cterm=NONE   ctermfg=" . <SID>X("38") . "   ctermbg=NONE"
    exec "hi Number         cterm=NONE   ctermfg=" . <SID>X("22") . "   ctermbg=NONE"
    exec "hi PreProc        cterm=NONE   ctermfg=" . <SID>X("10") . "   ctermbg=NONE"
    exec "hi Special        cterm=NONE   ctermfg=" . <SID>X("39") . "   ctermbg=NONE"
    exec "hi Statement      cterm=NONE   ctermfg=" . <SID>X("26") . "   ctermbg=NONE"
    exec "hi Todo           cterm=BOLD   ctermfg=" . <SID>X("08") . "   ctermbg=" . <SID>X(39) . ""
    exec "hi Type           cterm=NONE   ctermfg=" . <SID>X("71") . "   ctermbg=NONE"
    exec "hi Underlined     cterm=BOLD   ctermfg=" . <SID>X("78") . "   ctermbg=NONE"
    exec "hi TaglistTagName cterm=BOLD   ctermfg=" . <SID>X("26") . "   ctermbg=NONE"
endif

" vim: set et :
