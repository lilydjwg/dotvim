" Google Closure templates syntax file.
" Language: Soy
" Maintainer: Dugan Chen (https://github.com/duganchen)
"
if exists("b:current_syntax")
	finish
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax clear
syntax case match

syntax keyword soyConstant contained null
syntax keyword soyConstant contained false
syntax keyword soyConstant contained true

syntax keyword soyFunction contained isFirst
syntax keyword soyFunction contained isLast
syntax keyword soyFunction contained index
syntax keyword soyFunction contained hasData
syntax keyword soyFunction contained length
syntax keyword soyFunction contained round
syntax keyword soyFunction contained floor
syntax keyword soyFunction contained ceiling
syntax keyword soyFunction contained min
syntax keyword soyFunction contained max
syntax keyword soyFunction contained randomInt
syntax keyword soyFunction contained bidiGlobalDir
syntax keyword soyFunction contained bidiDirAttr
syntax keyword soyFunction contained bidiMark
syntax keyword soyFunction contained bidiMarkAfter
syntax keyword soyFunction contained bidiStartEdge
syntax keyword soyFunction contained bidiEndEdge
syntax keyword soyFunction contained bidiTextDir

syntax keyword soyKeyword contained namespace
syntax keyword soyKeyword contained template
syntax keyword soyKeyword contained literal
syntax keyword soyKeyword contained print

syntax keyword soyKeyword contained namespace
syntax keyword soyKeyword contained template
syntax keyword soyKeyword contained literal
syntax keyword soyKeyword contained print

syntax keyword soyStatement contained namespace
syntax keyword soyStatement contained template

syntax keyword soyKeyword contained literal
syntax keyword soyKeyword contained print
syntax keyword soyKeyword contained msg
syntax keyword soyKeyword contained call
syntax keyword soyKeyword contained param
syntax keyword soyKeyword contained nil

syntax keyword soyConditional contained if
syntax keyword soyConditional contained elseif
syntax keyword soyConditional contained else
syntax keyword soyConditional contained switch
syntax keyword soyConditional contained case
syntax keyword soyConditional contained default
syntax keyword soyConditional contained ifempty

syntax keyword soyRepeat contained foreach
syntax keyword soyRepeat contained for
syntax keyword soyRepeat contained in
syntax keyword soyRepeat contained range

syntax keyword soyCharacter contained r
syntax keyword soyCharacter contained n
syntax keyword soyCharacter contained t
syntax keyword soyCharacter contained lb
syntax keyword soyCharacter contained rb

syntax keyword soyDirective contained private
syntax keyword soyDirective contained autoescape
syntax keyword soyDirective contained noAutoescape
syntax keyword soyDirective contained id
syntax keyword soyDirective contained escapeHtml
syntax keyword soyDirective contained escapeUri
syntax keyword soyDirective contained escapeJs
syntax keyword soyDirective contained insertWordBreaks
syntax keyword soyDirective contained desc
syntax keyword soyDirective contained meaning
syntax keyword soyDirective contained data
syntax keyword soyDirective contained bidiSpanWrap
syntax keyword soyDirective contained bidiUnicodeWrap

syntax match soySpecialComment /@param?\?/ contained

syntax region soyCommand start="{" end="}" contains=soyKeyword, soyDirective, soyIdentifier, soyString, soyTemplate, soyConstant, soyInteger, soyCharacter, soyFloat, soySci, soyOperator, soyFunction, soyRepeat, soyConditional, soyStatement, soyLabel

syntax region soyString contained start="\'" end="\'"
syntax region soyString contained start="\"" end="\""

syntax match soyIdentifier /\$[a-zA-Z0-9._]*\>/ contained
syntax region soyComment start=/\/\*/ end='\\*\/' contains=soySpecialComment

syntax match soyComment /\/\/.*$/
syntax match soyTemplate /\s\+\.\w\+\>/ contained

syntax match soyInteger /\-\?\(0x\)\?[A-F0-9]\+\>/ contained

syntax match soyNumber /\-\?\d\+\(e\-\?\d\+\)\?\>/ contained

syntax match soyFloat /\-\?\d\+\.\d\+\>/ contained
syntax match soySci /\-\?\d\+e\-\?\d\+\>/ contained

syntax match soyOperator /\<\(not\|and\|or\)\>/ contained

syntax match soyLabel /\<\w\+:/ contained

" Yes, this causes the - in -1 to show as an operator. This is a bug.
syntax match soyOperator /[-*/%+<>=!?:]/ contained

highlight def link soyOperator Operator
highlight def link soyKeyword Statement
highlight def link soyDirective Type
highlight def link soyIdentifier Identifier
highlight def link soyString String
highlight def link soyComment Comment
highlight def link soyTemplate Identifier
highlight def link soyInteger Number
highlight def link soyFloat Float
highlight def link soySci Float
highlight def link soyConstant Constant
highlight def link soyCharacter Character
highlight def link soyFunction Function
highlight def link soyRepeat Repeat
highlight def link soyConditional Conditional
highlight def link soyStatement Statement
highlight def link soySpecialComment SpecialComment
highlight def link soyLabel Identifier
