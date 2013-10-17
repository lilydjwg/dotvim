" histwin.vim - Vim global plugin for browsing the undo tree {{{1
" -------------------------------------------------------------
" Last Change: Tue, 02 Aug 2011 07:48:56 +0200
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.24
" Copyright:   (c) 2009, 2010 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" GetLatestVimScripts: 2932 17 :AutoInstall: histwin.vim

" Init: {{{2
if exists("g:loaded_undo_browse") || &cp || &ul == -1
  finish
endif

let g:loaded_undo_browse = 0.24
let s:cpo                = &cpo
set cpo&vim

fun! WarningMsg(msg) "{{{2
	let msg = "histwin: " . a:msg
	echomsg msg
	let v:errmsg = msg
endfun "}}}
" Check version "{{{2
if v:version < 703
	call WarningMsg("This plugin requires Vim 7.3 or higher")
	finish
endif

" Enable displaying the differences with Signs
if exists("g:undo_tree_highlight_changes") &&
			\ g:undo_tree_highlight_changes == 1
	call histwin#PreviewAuCmd(1)
endif

" User_Command: {{{2
if exists(":UB") != 2
	com -nargs=0 UB :call histwin#UndoBrowse()
	com -nargs=0 Histwin :UB
else
	call WarningMsg("UB is already defined. May be by another Plugin?")
endif " }}}

if exists(":HistID") != 2
	com -nargs=0 HistID :call histwin#SignChanges(1)
else
	call WarningMsg("HistID is already defined. May be by another Plugin?")
endif " }}}

" ChangeLog: {{{2
" see :h histwin-history
" Restore: {{{2
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdm=syntax
