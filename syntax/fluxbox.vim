" File Name: fluxbox.vim
" Maintainer: Moshe Kaminsky <kaminsky@math.huji.ac.il>
" Original Date: May 23, 2002
" Last Update: October 17, 2004
" Description: fluxbox menu syntax file

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syntax keyword fluxboxMenu submenu end begin workspaces config stylesmenu separator nop contained
syntax keyword fluxboxAction exec stylesdir exit restart reconfig style commanddialog contained
syntax keyword fluxboxPreProc include
syntax region fluxboxType matchgroup=fbSqBrackets start=/\[/ end=/\]/ contains=fluxboxAction,fluxboxMenu,fluxboxPreProc nextgroup=fluxboxHeader skipwhite oneline display
syntax region fluxboxHeader matchgroup=fbRdBrackets start=/(/ end=/)/ contained nextgroup=fluxboxCommand,fluxboxIcon skipwhite oneline display
syntax region fluxboxCommand matchgroup=fbClBrackets start=/{/ end=/}/ contained oneline display contains=fluxboxParam nextgroup=fluxboxIcon skipwhite
syntax region fluxboxIcon matchgroup=fbAgBrackets start=/</ end=/>/ contained  oneline display
syntax region fluxboxFold fold start=/^\s*\[submenu\]/ start=/^\s*\[begin\]/ end=/^\s*\[end\]/ contains=TOP keepend extend transparent
syntax match fluxboxComment /#.*$/
syntax match fluxboxParam / [^}]*/ contained display

if version >= 508 || !exists("did_c_syn_inits")
  if version < 508
    let did_c_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink fluxboxMenu Special
  HiLink fluxboxAction Identifier
  HiLink fluxboxHeader Type
  HiLink fluxboxCommand Statement
  HiLink fluxboxPreProc PreProc
  HiLink fluxboxComment Comment
  HiLink fluxboxParam Constant
  HiLink fluxboxIcon Repeat

  delcommand HiLink
endif
setlocal foldmethod=syntax
syntax sync fromstart
let b:current_syntax = 'fluxbox'

