" Vim syntax file
" Language: magic file for the file utility
" Maintainer: David Ne\v{c}as (Yeti) <yeti@physics.muni.cz>
" License: This file can be redistribued and/or modified under the same terms
"          as Vim itself.
" Last Change: 2006-04-23
" URL: http://trific.ath.cx/Ftp/vim/syntax/magic.vim

" Setup {{{
" React to possibly already-defined syntax.
" For version 5.x: Clear all syntax items unconditionally
" For version 6.x: Quit when a syntax file was already loaded
if version >= 600
  if exists("b:current_syntax")
    finish
  endif
else
  syntax clear
endif

syn case match
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Parse the line {{{
syn match magicError /\S/
syn match magicArbitrary /x\s/he=e-1 contained nextgroup=magicDescr skipwhite
syn match magicNumberConst /\<\%(0x\x\+\|0\o*\|-\?[1-9]\d*\)[Ll]\?\>/ contained
syn match magicOp /[-\/*+()!&=<>~^]/ contained
syn match magicOffsetType /\.[bslBSL]/lc=1 contained
syn match magicLevel />*/ contained nextgroup=magicOffset
syn match magicOffset /&\?\%(0x\x\+\|0\o*\|-\?[1-9]\d*\)\>/ contained contains=magicNumberConst,magicOp nextgroup=magicType skipwhite
syn match magicOffset /&\?(&\?\%(0x\x\+\|0\o*\|[1-9]\d*\)\%(\.[bslBSL]\)\?[-+*/%&|^]\?\%(0x\x\+\|0\o*\|[1-9]\d*\|(-\?\%(0x\x\+\|0\o*\|[1-9]\d*\))\)\?)/ contained contains=magicNumberConst,magicOp,magicOffsetType nextgroup=magicType skipwhite
syn match magicType /\<u\?\%(byte\|\%([blm]e\)\?short\|\%([blm]e\)\?long\|\%([blm]e\)\?l\?date\|[bl]estring16\)\%([-+&*/%^]\%(0x\x\+\|0\o*\|[1-9]\d*\)\)\?\>/ contained nextgroup=magicArbitrary,magicNumber contains=magicNumberConst,magicOp skipwhite
syn match magicNumber /!\?\%([&=<>~^]\|[<>]=\)\?\s*\%(0x\x\+\|0\o*\|-\?[1-9]\d*\)[Ll]\?\>/ contained contains=magicNumberConst,magicOp nextgroup=magicDescr skipwhite
syn keyword magicType pstring contained nextgroup=magicArbitrary,magicStringStart skipwhite
syn match magicType /\<string\%(\/[Bbc]*\)\?\>/ contained nextgroup=magicArbitrary,magicStringStart skipwhite
" Fixme: this is ugly
syn match magicStringStart /[!=<>]\|![=<>]/ contained nextgroup=magicString contains=magicOp skipwhite
syn match magicStringStart /x\s/ contained nextgroup=magicDescr contains=magicArbitrary skipwhite
syn match magicStringStart /[^!<>=x \t]/me=e-1 contained nextgroup=magicString skipwhite
syn match magicStringStart /x\S/me=e-2 contained nextgroup=magicString skipwhite
syn match magicString /\%(\\\s\|\S\)\+/ contained nextgroup=magicDescr contains=magicEscape skipwhite
syn match magicType /search\/\%(0x\x\+\|0\o*\|[1-9]\d*\)\>/ contained contains=magicOp,MagicNumberConst nextgroup=magicSearchStart skipwhite
syn match magicSearchStart /[!=<>]\|![=<>]/ contained nextgroup=magicSearch contains=magicOp skipwhite
syn match magicSearchStart /[^!<>=x \t]/me=e-1 contained nextgroup=magicSearch skipwhite
syn match magicSearch /\%(\\\s\|\S\)\+/ contained contains=magicEscape nextgroup=magicDescr skipwhite
syn match magicType /\<regex\%(\/c\)\?\>/ contained nextgroup=magicRegexStart skipwhite
syn match magicRegexStart /!/ contained nextgroup=magicRegex contains=magicOp skipwhite
syn match magicRegexStart /[^! \t]/me=e-1 contained nextgroup=magicRegex skipwhite
syn match magicRegex /\%(\\\s\|\S\)\+/ contained contains=magicEscape nextgroup=magicDescr skipwhite
syn match magicDescr /.*/ contained contains=magicEscape,magicCFormat
syn match magicEscape /\\[abfnrtv ]/ contained
syn match magicEscape /\\\o\{1,3\}/ contained
syn match magicEscape /\\x\x\x/ contained
syn match magicEscape /\\\\/ contained
" Fixme: taken from c.vim, matches floating-point formats too
syn match magicCFormat "%\(\d\+\$\)\=[-+' #0*]*\%(\d*\|\*\|\*\d\+\$\)\%(\.\(\d*\|\*\|\*\d\+\$\)\)\=\%([hlL]\|ll\)\=\%([diuoxXfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
syn match magicCFormat "%%" contained
syn match magicComment /#.*/ contained contains=magicTodo
syn keyword magicTodo TODO FIXME XXX contained
syn match magicBOL /^/ nextgroup=magicComment,magicLevel
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Define the default highlighting {{{
" For version 5.7 and earlier: Only when not done already
" For version 5.8 and later: Only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_magic_syntax_inits")
  if version < 508
    let did_magic_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink magicComment Comment
  HiLink magicTodo Todo
  HiLink magicType Type
  HiLink magicError Error
  HiLink magicLevel Preproc
  HiLink magicOp Keyword
  HiLink magicNumberConst Number
  HiLink magicOffsetType Type
  HiLink magicNumber Number
  HiLink magicString String
  HiLink magicRegex Constant
  HiLink magicSearch Constant
  HiLink magicEscape Special
  HiLink magicCFormat Special
  HiLink magicArbitrary Identifier

  delcommand HiLink
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
let b:current_syntax = "magic"
