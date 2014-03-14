" vis.vim:
" Function:	Perform an Ex command on a visual highlighted block (CTRL-V).
" Date:		May 18, 2010
" GetLatestVimScripts: 1066 1 cecutil.vim
" GetLatestVimScripts: 1195 1 :AutoInstall: vis.vim
" Verse: For am I now seeking the favor of men, or of God? Or am I striving
" to please men? For if I were still pleasing men, I wouldn't be a servant
" of Christ. (Gal 1:10, WEB)

" ---------------------------------------------------------------------
"  Details: {{{1
" Requires: Requires 6.0 or later  (this script is a plugin)
"           Requires <cecutil.vim> (see :he vis-required)
"
" Usage:    Mark visual block (CTRL-V) or visual character (v),
"           press ':B ' and enter an Ex command [cmd].
"
"           ex. Use ctrl-v to visually mark the block then use
"                 :B cmd     (will appear as   :'<,'>B cmd )
"
"           ex. Use v to visually mark the block then use
"                 :B cmd     (will appear as   :'<,'>B cmd )
"
"           Command-line completion is supported for Ex commands.
"
" Note:     There must be a space before the '!' when invoking external shell
"           commands, eg. ':B !sort'. Otherwise an error is reported.
"
" Author:   Charles E. Campbell <NdrchipO@ScampbellPfamily.AbizM> - NOSPAM
"           Based on idea of Stefan Roemer <roemer@informatik.tu-muenchen.de>
"
" ------------------------------------------------------------------------------
" Initialization: {{{1
" Exit quickly when <Vis.vim> has already been loaded or
" when 'compatible' is set
if &cp
  finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ------------------------------------------------------------------------------
" Public Interface: {{{1
"  -range       : VisBlockCmd operates on the range itself
"  -com=command : Ex command and arguments
"  -nargs=+     : arguments may be supplied, up to any quantity
com! -range -nargs=+ -com=command    B  silent <line1>,<line2>call vis#VisBlockCmd(<q-args>)
com! -range -nargs=* -com=expression S  silent <line1>,<line2>call vis#VisBlockSearch(<q-args>)

" Suggested by Hari --
if exists("g:vis_WantSlashSlash") && g:vis_WantSlashSlash
 vn // <esc>/<c-r>=vis#VisBlockSearch()<cr>
endif
vn ?? <esc>?<c-r>=vis#VisBlockSearch()<cr>

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
