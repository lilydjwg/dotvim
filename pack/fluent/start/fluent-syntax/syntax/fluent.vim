if exists("b:current_syntax")
    finish
endif

syntax region fluentComment start="\v^#" end="\v^(#)@!" contains=fluentTitleComment
syntax region fluentTitleComment start=/\v(^#.*$\n)@<!^##/ms=e+1 end="$"
syntax match fluentIdentifier "^\v-?[a-zA-Z][a-zA-Z0-9_-]*" nextgroup=fluentDelimiter
syntax match fluentDelimiter "\s*=\s*" contained skipnl nextgroup=fluentPattern
syntax region fluentPattern contained start="" end="\v^(( )@!|( +[\.\[\*\}])@=)" contains=fluentPlaceable
syntax match fluentAttribute "\v\.[a-zA-Z][a-zA-Z0-9-]*" nextgroup=fluentDelimiter
syntax region fluentPlaceable contained start=+{+ end=+}+ contains=@fluentExpression

syntax cluster fluentExpression contains=fluentFunction,fluentVariantKey,fluentVariable,fluentIdentifierExpression,fluentVariantSelectorOperator

syntax match fluentVariantKey contained "\v\*?\[\s*[a-zA-Z0-9]+\s*\]" nextgroup=fluentPattern
syntax match fluentVariable contained "\v\$[a-zA-Z][a-zA-Z0-9_-]*"
syntax match fluentIdentifierExpression contained "\v\-?[a-zA-Z][a-zA-Z0-9_-]*"
syntax match fluentFunction contained "\v[A-Z]+"
syntax match fluentVariantSelectorOperator contained "\v\-\>"

highlight link fluentComment Comment
highlight link fluentTitleComment Constant
highlight link fluentIdentifier Identifier
highlight link fluentPattern String
highlight link fluentAttribute Keyword
highlight link fluentFunction Function
highlight link fluentVariantKey Tag
highlight link fluentVariable Keyword
highlight link fluentIdentifierExpression Identifier
highlight link fluentDelimiter Operator
highlight link fluentVariantSelectorOperator Operator

let b:current_syntax = "fluent"
