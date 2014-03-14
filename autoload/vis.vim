" vis.vim:
" Function:	Perform an Ex command on a visual highlighted block (CTRL-V).
" Version:	20
" Date:		Mar 29, 2013
" GetLatestVimScripts: 1066 1 cecutil.vim
" GetLatestVimScripts: 1195 1 :AutoInstall: vis.vim
" Verse: For am I now seeking the favor of men, or of God? Or am I striving
" to please men? For if I were still pleasing men, I wouldn't be a servant
" of Christ. (Gal 1:10, WEB)
"
" Author:   Charles E. Campbell <NdrchipO@ScampbellPfamily.AbizM> - NOSPAM
"           Based on idea of Stefan Roemer <roemer@informatik.tu-muenchen.de>
"
" ------------------------------------------------------------------------------
" Initialization: {{{1
" Exit quickly when <Vis.vim> has already been loaded or
" when 'compatible' is set
if &cp || exists("g:loaded_vis")
  finish
endif
let s:keepcpo    = &cpo
let g:loaded_vis = "v20"
set cpo&vim

" ---------------------------------------------------------------------
"  Support Functions: {{{1
" ------------------------------------------------------------------------------
" vis#VisBlockCmd: {{{2
fun! vis#VisBlockCmd(cmd) range
"  call Dfunc("vis#VisBlockCmd(cmd<".a:cmd.">")

  " retain and re-use same visual mode
  sil! keepj norm `<
  let curposn = SaveWinPosn(0)
  let vmode   = visualmode()
"  call Decho("vmode<".vmode.">")

  call s:SaveUserSettings()

  if vmode == 'V'
"   call Decho("cmd<".a:cmd.">")
   exe "keepj '<,'>".a:cmd

  else " handle v and ctrl-v
   " Initialize so begcol<endcol for non-v modes
   let begcol   = s:VirtcolM1("<")
   let endcol   = s:VirtcolM1(">")
   if vmode != 'v'
    if begcol > endcol
     let begcol  = s:VirtcolM1(">")
     let endcol  = s:VirtcolM1("<")
    endif
   endif

   " Initialize so that begline<endline
   let begline  = a:firstline
   let endline  = a:lastline
   if begline > endline
    let begline = a:lastline
    let endline = a:firstline
   endif
"   call Decho('beg['.begline.','.begcol.'] end['.endline.','.endcol.']')

   " =======================
   " Modify Selected Region:
   " =======================
   " 1. delete selected region into register "a
"   call Decho("delete selected region into register a")
   sil! keepj norm! gv"ad

   " 2. put cut-out text at end-of-file
"   call Decho("put cut-out text at end-of-file")
   keepj $
   keepj pu_
   let lastline= line("$")
   sil! keepj norm! "ap
"   call Decho("reg-A<".@a.">")

   " 3. apply command to those lines
   let curline = line(".")
   ka
   keepj $
"   call Decho("apply command<".a:cmd."> to those lines (curline=".line(".").")")
   exe "keepj ". curline.',$'.a:cmd

   " 4. visual-block select the modified text in those lines
"   call Decho("visual-block select modified text at end-of-file")
   exe "keepj ".lastline
   exe "keepj norm! 0".vmode."G$\"ad"

   " 5. delete excess lines
"   call Decho("delete excess lines")
   exe "sil! keepj ".lastline.',$d'

   " 6. put modified text back into file
"   call Decho("put modifed text back into file (beginning=".begline.".".begcol.")")
   exe "keepj ".begline
   if begcol > 1
	exe 'sil! keepj norm! '.begcol."\<bar>\"ap"
   elseif begcol == 1
	norm! 0"ap
   else
	norm! 0"aP
   endif

   " 7. attempt to restore gv -- this is limited, it will
   " select the same size region in the same place as before,
   " not necessarily the changed region
   let begcol= begcol+1
   let endcol= endcol+1
   exe "sil keepj ".begline
   exe 'sil keepj norm! '.begcol."\<bar>".vmode
   exe "sil keepj ".endline
   exe 'sil keepj norm! '.endcol."\<bar>\<esc>"
   exe "sil keepj ".begline
   exe 'sil keepj norm! '.begcol."\<bar>"
  endif

  call s:RestoreUserSettings()
  call RestoreWinPosn(curposn)

"  call Dret("vis#VisBlockCmd")
endfun

" ------------------------------------------------------------------------------
" vis#VisBlockSearch: {{{2
fun! vis#VisBlockSearch(...) range
"  call Dfunc("vis#VisBlockSearch() a:0=".a:0." lines[".a:firstline.",".a:lastline."]")
  let keepic= &ic
  set noic

  if a:0 >= 1 && strlen(a:1) > 0
   let pattern   = a:1
   let s:pattern = pattern
"   call Decho("a:0=".a:0.": pattern<".pattern.">")
  elseif exists("s:pattern")
   let pattern= s:pattern
  else
   let pattern   = @/
   let s:pattern = pattern
  endif
  let vmode= visualmode()

  " collect search restrictions
  let firstline  = line("'<")
  let lastline   = line("'>")
  let firstcolm1 = s:VirtcolM1("<")
  let lastcolm1  = s:VirtcolM1(">")
"  call Decho("1: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolm1=".lastcolm1)

  if(firstline > lastline)
   let firstline = line("'>")
   let lastline  = line("'<")
   if a:0 >= 1
    keepj norm! `>
   endif
  else
   if a:0 >= 1
    keepj norm! `<
   endif
  endif
"  call Decho("2: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolm1=".lastcolm1)

  if vmode != 'v'
   if firstcolm1 > lastcolm1
   	let tmp        = firstcolm1
   	let firstcolm1 = lastcolm1
   	let lastcolm1  = tmp
   endif
  endif
"  call Decho("3: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolm1=".lastcolm1)

  let firstlinem1 = firstline  - 1
  let lastlinep1  = lastline   + 1
  let firstcol    = firstcolm1 + 1
  let lastcol     = lastcolm1  + 1
  let lastcolp1   = lastcol    + 1
"  call Decho("4: firstline=".firstline." lastline=".lastline." firstcolm1=".firstcolm1." lastcolp1=".lastcolp1)

  " construct search string
  if vmode == 'V'
   let srch= '\%(\%>'.firstlinem1.'l\%<'.lastlinep1.'l\)\&'
"   call Decho("V  srch: ".srch)
  elseif vmode == 'v'
   if firstline == lastline || firstline == lastlinep1
   	let srch= '\%(\%'.firstline.'l\%>'.firstcolm1.'v\%<'.lastcolp1.'v\)\&'
   else
    let srch= '\%(\%(\%'.firstline.'l\%>'.firstcolm1.'v\)\|\%(\%'.lastline.'l\%<'.lastcolp1.'v\)\|\%(\%>'.firstline.'l\%<'.lastline.'l\)\)\&'
   endif
"   call Decho("v  srch: ".srch)
  else
   let srch= '\%(\%>'.firstlinem1.'l\%>'.firstcolm1.'v\%<'.lastlinep1.'l\%<'.lastcolp1.'v\)\&'
"   call Decho("^v srch: ".srch)
  endif

  " perform search
  if a:0 <= 1
"   call Decho("Search forward: <".srch.pattern.">")
   call search(srch.pattern)
   let @/= srch.pattern

  elseif a:0 == 2
"   call Decho("Search backward: <".srch.pattern.">")
   call search(srch.pattern,a:2)
   let @/= srch.pattern
  endif

  " restore ignorecase
  let &ic= keepic

"  call Dret("vis#VisBlockSearch <".srch.">")
  return srch
endfun

" ------------------------------------------------------------------------------
" s:VirtcolM1: usually a virtcol(mark)-1, but due to tabs this can be different {{{2
fun! s:VirtcolM1(mark)
"  call Dfunc('s:VirtcolM1("'.a:mark.'")')

  if virtcol("'".a:mark) <= 1
"   call Dret("s:VirtcolM1 0")
   return 0
  endif

  if &ve == "block"
   " Works around a ve=all vs ve=block difference with virtcol().
   " Since s:SaveUserSettings() changes ve to ve=all, this small
   " ve override only affects vis#VisBlockSearch().
   set ve=all
"   call Decho("temporarily setting ve=all")
  endif

"  call Decho("exe norm! `".a:mark."h")
  exe "keepj norm! `".a:mark."h"

  let vekeep = &ve
  let vc     = virtcol(".")
  let &ve    = vekeep

"  call Dret("s:VirtcolM1 ".vc)
  return vc
endfun

" ---------------------------------------------------------------------
" s:SaveUserSettings: save options which otherwise may interfere {{{2
fun! s:SaveUserSettings()
"  call Dfunc("s:SaveUserSettings()")
  let s:keep_lz    = &lz
  let s:keep_fen   = &fen
  let s:keep_fo    = &fo
  let s:keep_ic    = &ic
  let s:keep_magic = &magic
  let s:keep_sol   = &sol
  let s:keep_ve    = &ve
  let s:keep_ww    = &ww
  let s:keep_cedit = &cedit
  set lz magic nofen noic nosol ve=all ww= fo=nroql2 cedit&

  " Save any contents in register a
  let s:rega= @a

"  call Dret("s:SaveUserSettings")
endfun

" ---------------------------------------------------------------------
" s:RestoreUserSettings: restore register a and options {{{2
fun! s:RestoreUserSettings()
"  call Dfunc("s:RestoreUserSettings()")
  let @a     = s:rega
  let &cedit = s:keep_cedit
  let &fen   = s:keep_fen
  let &fo    = s:keep_fo
  let &ic    = s:keep_ic
  let &lz    = s:keep_lz
  let &sol   = s:keep_sol
  let &ve    = s:keep_ve
  let &ww    = s:keep_ww
"  call Dret("s:RestoreUserSettings")
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" ------------------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
