" Vim syntax file
" FileType:     Tornado pretty log without color (saved or copied)
" Author:       lilydjwg <lilydjwg@gmail.com>

syntax match tlogDebug   /^\[D\>[^]]\+\]/
syntax match tlogInfo    /^\[I\>[^]]\+\]/
syntax match tlogWarning /^\[W\>[^]]\+\]/
syntax match tlogError   /^\[E\>[^]]\+\]/

highlight tlogDebug   ctermfg=4 guifg=#0000aa
highlight tlogInfo    ctermfg=2 guifg=#00aa00
highlight tlogWarning ctermfg=3 guifg=#aa5500
highlight tlogError   ctermfg=1 guifg=#aa0000

setlocal nocursorline
