" Vim syntax file
" Language:  YAML (YAML Ain't Markup Language)
" Author:    Igor Vergeichik <iverg@mail.ru>
" Author:    Nikolai Weibull <now@bitwi.se>
" Sponsor:   Tom Sawyer <transfire@gmail.com>
" Version:   2.0
"

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
syntax clear

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn keyword yamlTodo            contained TODO FIXME XXX NOTE

syn region  yamlDocumentHeader  start='---' end='$' contains=yamlDirective
syn match   yamlDocumentEnd     '\.\.\.'
syn match   yamlDirective       contained '%[^:]\+:.\+'

syn region  yamlComment         display oneline start='\%(^\|\s\)#' end='$'
                                \ contains=yamlTodo,@Spell
"syn region yamlMapping         start="\w+:\s*\w+" end="$"
                                \ contains=yamlKey,yamlValue
syn match   yamlNodeProperty    "!\%(![^\\^%     ]\+\|[^!][^:/   ]*\)"
syn match   yamlAnchor          "&.\+"
syn match   yamlAlias           "\*.\+"
syn match   yamlDelimiter       "[-,:]\(\s\|\n\)"
syn match   yamlBlock           "[\[\]\{\}>|]"
syn match   yamlOperator        '[?+-]'
syn match   yamlKey             '\(\.\|\w\)\+\(\s\+\(\.\|\w\)\+\)*\ze\s*:\(\s\|\n\)'
syn match   yamlScalar          '\(\(|\|>\)\s*\n*\r*\)\@<=\(\s\+\).*\n*\r*\(\(\3\).*\n\)*'

" Predefined data types

" Yaml Integer type
syn match   yamlInteger         display "[-+]\?\(0\|[1-9][0-9,]*\)"
syn match   yamlInteger         display "[-+]\?0[xX][0-9a-fA-F,]\+"

" floating point number
syn match   yamlFloating        display "\<\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match   yamlFloating        display "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match   yamlFloating        display "\<\d\+e[-+]\=\d\+[fl]\=\>"
syn match   yamlFloating        display "\(([+-]\?inf)\)\|\((NaN)\)"
" TODO: sexagecimal and fixed (20:30.15 and 1,230.15)
syn match   yamlNumber          display
                                \ '\<[+-]\=\d\+\%(\.\d\+\%([eE][+-]\=\d\+\)\=\)\='
syn match   yamlNumber          display '0\o\+'
syn match   yamlNumber          display '0x\x\+'
syn match   yamlNumber          display '([+-]\=[iI]nf)'

" Boolean
syn keyword yamlBoolean         true True TRUE false False FALSE yes Yes YES no No NO on On ON off Off OFF
syn match   yamlBoolean         ":.*\zs\W[+-]\(\W\|$\)"

syn match   yamlConstant        '\<[~yn]\>'

" Null
syn keyword yamlNull            null Null NULL nil Nil NIL
syn match   yamlNull            "\W[~]\(\W\|$\)"

syn match   yamlTime            "\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\?Z"
syn match   yamlTime            "\d\d\d\d-\d\d-\d\dt\d\d:\d\d:\d\d.\d\d-\d\d:\d\d"
syn match   yamlTime            "\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d.\d\d\s-\d\d:\d\d"
syn match   yamlTimestamp       '\d\d\d\d-\%(1[0-2]\|\d\)-\%(3[0-2]\|2\d\|1\d\|\d\)\%( \%([01]\d\|2[0-3]\):[0-5]\d:[0-5]\d.\d\d [+-]\%([01]\d\|2[0-3]\):[0-5]\d\|t\%([01]\d\|2[0-3]\):[0-5]\d:[0-5]\d.\d\d[+-]\%([01]\d\|2[0-3]\):[0-5]\d\|T\%([01]\d\|2[0-3]\):[0-5]\d:[0-5]\d.\dZ\)\='

" Single and double quoted scalars
syn region  yamlString          start="'" end="'" skip="\\'"
                                \ contains=yamlSingleEscape
syn region  yamlString          start='"' end='"' skip='\\"'
                                \ contains=yamlEscape

" Escaped symbols
" every charater preceeded with slash is escaped one
syn match   yamlEscape          "\\."
" 2,4 and 8-digit escapes
syn match   yamlEscape          "\\\(x\x\{2\}\|u\x\{4\}\|U\x\{8\}\)"
syn match   yamlEscape          contained display +\\[\\"abefnrtv^0_ NLP]+
syn match   yamlEscape          contained display '\\x\x\{2}'
syn match   yamlEscape          contained display '\\u\x\{4}'
syn match   yamlEscape          contained display '\\U\x\{8}'
" TODO: how do we get 0x85, 0x2028, and 0x2029 into this?
syn match   yamlEscape          display '\\\%(\r\n\|[\r\n]\)'
syn match   yamlSingleEscape    contained display +''+

syn match   yamlKey             "\w\+\ze\s*:\(\s\|\n\)"
syn match   yamlType            "![^\s]\+\s\@="

hi link yamlKey             Identifier
hi link yamlType            Type
hi link yamlInteger         Number
hi link yamlFloating        Float
hi link yamlNumber          Number
hi link yamlEscape          Special
hi link yamlSingleEscape    SpecialChar
hi link yamlComment         Comment
hi link yamlBlock           Operator
hi link yamlDelimiter       Delimiter
hi link yamlString          String
hi link yamlBoolean         Boolean
hi link yamlNull            Boolean
hi link yamlTime            String
hi link yamlTodo            Todo
hi link yamlDocumentHeader  PreProc
hi link yamlDocumentEnd     PreProc
hi link yamlDirective       Keyword
hi link yamlNodeProperty    Type
hi link yamlAnchor          Type
hi link yamlAlias           Type
hi link yamlOperator        Operator
hi link yamlScalar          String
hi link yamlConstant        Constant
hi link yamlTimestamp       Number

let b:current_syntax = "yaml"

let &cpo = s:cpo_save
unlet s:cpo_save
