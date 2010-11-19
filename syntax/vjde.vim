" Vjde syntax file
" language : vjde template ,def files
"
if exists("b:current_syntax")
    finish
endif
syn keyword vjdeKeyword template temp endtemplate endt parameter param body 
syn keyword vjdeKeyword2 paras @paras @name name manager contained
syn match vjdeComment "^/.*$"
syn match vjdeEntity "^%.*%$"
syn match vjdeSpecialChar "^\\"
syn match vjdeDesc "\(^\(para\|temp\).*\)\@<=;.*$"
syn match vjdeParaName "\(^para[a-z]\+\s\+\)\@<=\<\i\+\>"
syn match vjdeTempName "\(^temp[a-z]\+\s\+\)\@<=\<\i\+\>"
syn region vjdeBody  matchgroup=vjdeIgnore start="^body" end="^endt" 
syn match vjdeIgnore "." contained
"syn match vjdeVariable "%{[^}]\+}"
syn region vjdeVariable start="%{" end="}" contains=vjdeKeyword2

hi def link vjdeComment Comment
hi def link vjdeEntity Typedef
hi def link vjdeKeyword Keyword 
hi def link vjdeKeyword2 Identifier 
hi def link vjdeBody Constant
hi def link vjdeDesc String
hi def link vjdeParaName Typedef
hi def link vjdeTempName Typedef
hi def link vjdeVariable Typedef
hi def link vjdeSpecialChar SpecialChar

