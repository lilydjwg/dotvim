" Vim syntax file
" Language:     SystemTap
" Maintainer:   SystemTap Developers <systemtap@sourceware.org>
" Last Change:  2011 Aug 4

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syn clear
elseif exists("b:current_syntax")
  finish
endif

setlocal iskeyword=@,48-57,_,$

syn keyword stapStatement contained break continue return next delete containedin=stapBlock
syn keyword stapRepeat contained while for foreach in limit containedin=stapBlock
syn keyword stapConditional contained if else containedin=stapBlock
syn keyword stapDeclaration global probe function
syn keyword stapType string long

syn region stapProbeDec start="\<probe\>"lc=5 end="{"me=s-1 contains=stapString,stapNumber
syn match stapProbe contained "\<\w\+\>" containedin=stapProbeDec

syn region stapFuncDec start="\<function\>"lc=8 end=":\|("me=s-1 contains=stapString,stapNumber
syn match stapFuncCall contained "\<\w\+\ze\(\s\|\n\)*(" containedin=stapBlock
syn match stapFunc contained "\<\w\+\>" containedin=stapFuncDec,stapFuncCall

syn match stapStat contained "@\<\w\+\ze\(\s\|\n\)*(" containedin=stapBlock

" decimal number
syn match stapNumber "\<\d\+\>" containedin=stapBlock
" octal number
syn match stapNumber "\<0\o\+\>" contains=stapOctalZero containedin=stapBlock
" Flag the first zero of an octal number as something special
syn match stapOctalZero contained "\<0"
" flag an octal number with wrong digits
syn match stapOctalError "\<0\o*[89]\d*" containedin=stapBlock
" hex number
syn match stapNumber "\<0x\x\+\>" containedin=stapBlock
" numeric arguments
syn match stapNumber "\<\$\d\+\>" containedin=stapBlock
syn match stapNumber "\<\$#" containedin=stapBlock

syn region stapString oneline start=+"+ skip=+\\"+ end=+"+ containedin=stapBlock
" string arguments
syn match stapString "@\d\+\>" containedin=stapBlock
syn match stapString "@#" containedin=stapBlock

syn match stapTarget contained "\w\@<!\$\h\w*\>" containedin=stapBlock

syn region stapPreProc fold start="%(" end="%)" contains=stapNumber,stapString containedin=ALL
syn keyword stapPreProcCond contained kernel_v kernel_vr arch containedin=stapPreProc

syn include @C syntax/c.vim
syn keyword stapCMacro  contained THIS CONTEXT containedin=@C,stapCBlock
syn region  stapCBlock fold matchgroup=stapCBlockDelims start="%{"rs=e end="%}"re=s contains=@C

syn region stapBlock fold matchgroup=stapBlockEnds start="{"rs=e end="}"re=s containedin=stapBlock

syn keyword stapTodo contained TODO FIXME XXX

syn match stapComment "#.*" contains=stapTodo containedin=stapBlock
syn match stapComment "//.*" contains=stapTodo containedin=stapBlock
syn region stapComment matchgroup=stapComment start="/\*" end="\*/" contains=stapTodo,stapCommentBad containedin=stapBlock
syn match stapCommentBad contained "/\*"

" treat ^#! as special
syn match stapSharpBang "^#!.*"


" define the default highlighting
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlightling yet
if version >= 508 || !exists("did_stap_syn_inits")
  if version < 508
    let did_stap_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink stapNumber Number
  HiLink stapOctalZero PreProc " c.vim does it this way...
  HiLink stapOctalError Error
  HiLink stapString String
  HiLink stapTodo Todo
  HiLink stapComment Comment
  HiLink stapCommentBad Error
  HiLink stapSharpBang PreProc
  HiLink stapCBlockDelims Special
  HiLink stapCMacro Macro
  HiLink stapStatement Statement
  HiLink stapConditional Conditional
  HiLink stapRepeat Repeat
  HiLink stapType Type
  HiLink stapProbe Function
  HiLink stapFunc Function
  HiLink stapStat Function
  HiLink stapPreProc PreProc
  HiLink stapPreProcCond Special
  HiLink stapDeclaration Typedef
  HiLink stapTarget Special

  delcommand HiLink
endif

let b:current_syntax = "stap"
