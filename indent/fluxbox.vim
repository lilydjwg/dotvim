" File Name: fluxbox.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Original Date: June 15, 2003
" Last Update: June 15, 2003
" Description: indent file for fluxbox (or blackbox) window manager menu file
" Depends on the GenericIndent function in genindent.vim

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let b:indent_block_start = '^\s*\[\(submenu\|begin\)\]'
let b:indent_block_end = '^\s*\[end\]'
let b:indent_ignore = '^\s*#'

setlocal indentexpr=GenericIndent(v:lnum)
setlocal indentkeys=o,O,!^F,0=[exec],0=[end],0=[submenu],0=[restart],
      \0=[config],0=[reconfig],0=[stylesdir],0=[stylesmenu],0=[begin],
      \0=[workspaces],0=[exit],0=[include],0=[nop]

