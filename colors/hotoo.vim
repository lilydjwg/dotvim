" Vim color file
" Maintainer:	闲耘™(hotoo) <mail@xianyun.org>
" Last Change:	$Date: 2009/10/11 $
" URL:		http://hotoo.googlecode.com/svn/trunk/vim/colors/hotoo.vim
" Version:	$Id: hotoo.vim,v 1.1 2009/10/11 19:30:30 vimboss Exp $

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

set background=dark
if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
	syntax reset
    endif
endif
let g:colors_name="hotoo"

hi Normal	guifg=White guibg=grey20

" highlight groups
hi Cursor	guibg=khaki guifg=slategrey
"hi CursorIM
"hi Directory
"hi DiffAdd
"hi DiffChange
"hi DiffDelete
"hi DiffText
"hi ErrorMsg
hi VertSplit	guibg=#c2bfa5 guifg=grey50 gui=none
"hi Folded	guibg=grey30 guifg=gold
hi Folded	guibg=#444444 guifg=#888888
hi FoldColumn	guibg=grey30 guifg=tan
hi IncSearch	guifg=slategrey guibg=khaki
hi LineNr guibg=#555555
hi ModeMsg	guifg=goldenrod
hi MoreMsg	guifg=SeaGreen
hi NonText	guifg=LightBlue guibg=grey30
hi Question	guifg=springgreen
hi Search	guibg=peru guifg=wheat
hi SpecialKey	guifg=yellowgreen
hi StatusLine	guibg=#c2bfa5 guifg=black gui=none
hi StatusLineNC	guibg=#c2bfa5 guifg=grey50 gui=none
hi Title	guifg=indianred
hi Visual	gui=none guifg=khaki guibg=olivedrab
"hi VisualNOS
hi WarningMsg	guifg=salmon
"hi WildMenu
"hi Menu
"hi Scrollbar
"hi Tooltip

" syntax highlighting groups
" SkyBlue
hi Comment	guifg=#666666
hi Constant	guifg=#ffa0a0
hi String 		guifg=#95e454 gui=italic
hi Identifier	guifg=palegreen
" khaki
hi Statement	guifg=#8AC6F2
hi PreProc	guifg=indianred
hi Type		guifg=darkkhaki
hi Special	guifg=navajowhite
"hi Underlined
hi Ignore	guifg=grey40
"hi Error
hi Todo		guifg=orangered guibg=yellow2

" color terminal definitions
hi SpecialKey	ctermfg=darkgreen
hi NonText	cterm=bold ctermfg=darkblue
hi Directory	ctermfg=darkcyan
hi ErrorMsg	cterm=bold ctermfg=7 ctermbg=1
hi IncSearch	cterm=NONE ctermfg=yellow ctermbg=green
hi Search	cterm=NONE ctermfg=grey ctermbg=blue
hi MoreMsg	ctermfg=darkgreen
hi ModeMsg	cterm=NONE ctermfg=brown
hi LineNr	ctermfg=3
hi Question	ctermfg=green
hi StatusLine	cterm=bold,reverse
hi StatusLineNC cterm=reverse
hi VertSplit	cterm=reverse
hi Title	ctermfg=5
hi Visual	cterm=reverse
hi VisualNOS	cterm=bold,underline
hi WarningMsg	ctermfg=1
hi WildMenu	ctermfg=0 ctermbg=3
hi Folded	ctermfg=darkgrey ctermbg=NONE
hi FoldColumn	ctermfg=darkgrey ctermbg=NONE
hi DiffAdd	ctermbg=4
hi DiffChange	ctermbg=5
hi DiffDelete	cterm=bold ctermfg=4 ctermbg=6
hi DiffText	cterm=bold ctermbg=1
hi Comment	ctermfg=darkcyan
hi Constant	ctermfg=brown
hi Special	ctermfg=5
hi Identifier	ctermfg=6
hi Statement	ctermfg=3
hi PreProc	ctermfg=5
hi Type		ctermfg=2
hi Underlined	cterm=underline ctermfg=5
hi Ignore	cterm=bold ctermfg=7
hi Ignore	ctermfg=darkgrey
hi Error	cterm=bold ctermfg=7 ctermbg=1

" Init "{{{
if !has("gui_running")
  echomsg "manuscript colorscheme: please use GUI vim."
  finish
endif


let g:colors_name = expand('<sfile>:t:r')
"}}}

" General "{{{
"hi Normal       guifg=#e5e5e5 guibg=#242424 gui=none

hi Cursor       guifg=#304050 guibg=#f0e68c gui=none
hi lCursor      guifg=#000000 guibg=#55cc55 gui=none

hi CursorColumn guifg=fg      guibg=#323232 gui=none
" hi CursorLine   guifg=fg      guibg=#323232 gui=none


"hi Folded       guifg=#b0b0b0 guibg=#343434 gui=none
"hi FoldColumn   guifg=#707070 guibg=#181818 gui=none
"hi SignColumn   guifg=#707070 guibg=#181818 gui=none
"hi LineNr       guifg=#707070 guibg=bg      gui=none
hi StatusLine   guifg=#000000 guibg=#c2bfa5 gui=none
hi StatusLineNC guifg=#5a5a5a guibg=#c2bfa5 gui=none
hi VertSplit    guifg=#3a3a3a guibg=#c2bfa5 gui=none
hi WildMenu     guifg=fg      guibg=#000000 gui=none

hi Pmenu        guifg=#e0e0e0 guibg=#494949 gui=none
hi PmenuSel     guifg=#000000 guibg=#808080 gui=none
hi PmenuSbar    guifg=fg      guibg=#595959 gui=none
hi PmenuThumb   guifg=fg      guibg=#707070 gui=none

hi TabLineSel   guifg=#000000 guibg=#c2bfa5 gui=NONE
hi TabLine      guifg=#c2bfa5 guibg=#3a3a3a gui=underline
hi TabLineFill  guifg=#c2bfa5 guibg=NONE    gui=underline

hi Search       guifg=fg      guibg=#4466bb gui=none
hi IncSearch    guifg=fg      guibg=#119922 gui=none

hi Visual       guifg=#f0f0f0 guibg=#406070 gui=none

hi Directory    guifg=#bf8f67 guibg=bg      gui=none

hi Underlined   guifg=#779fcf guibg=bg      gui=underline
hi Todo         guifg=#e0c000 guibg=#000000 gui=bold
hi Title        guifg=#e06070 guibg=NONE    gui=bold

hi NonText      guifg=#707070 guibg=NONE    gui=none
hi Ignore       guifg=#232323 guibg=NONE    gui=none

" hi Question     guifg=#23f923 guibg=bg      gui=none
" hi ModeMsg      guifg=#c3f3a3 guibg=bg      gui=none
" hi MoreMsg      guifg=#23c3a3 guibg=bg      gui=none
" hi ErrorMsg     guifg=fg      guibg=#f00000 gui=none

hi SpecialKey   guifg=#5f8f37 guibg=bg      gui=none

hi MatchParen   guifg=#f0f0f0 guibg=#008b8b gui=none
"}}}

" Syntax "{{{
hi Statement    guifg=#779fcf guibg=bg      gui=none
hi Identifier   guifg=#ffdead guibg=bg      gui=none
hi Type         guifg=#87ceeb guibg=bg      gui=none
hi Comment      guifg=#7f9f7f guibg=bg      gui=none

hi Constant     guifg=#c8a4c4 guibg=bg      gui=none
hi Number       guifg=#9fdf77 guibg=bg      gui=none
hi PreProc      guifg=#bf7f6f guibg=bg      gui=none
hi Special      guifg=#cfbfaf guibg=bg      gui=none
hi Error        guifg=fg      guibg=#b03030 gui=none
"}}}

" Diff "{{{
hi diffAdd      guifg=bg      guibg=#80a080 gui=none
hi diffDelete   guifg=fg      guibg=bg      gui=none
hi diffChange   guifg=bg      guibg=#a08080 gui=none
hi diffText     guifg=bg      guibg=#a05c5c gui=none
"}}}


"vim: sw=4
