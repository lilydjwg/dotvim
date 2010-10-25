if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match preInput /:[^:]*$/hs=s+1 

syn keyword docOther : *
syn keyword javaScopeDecl	public protected private abstract
syn keyword javaStorageClass	static synchronized transient volatile final strictfp serializable
syn keyword javaType void boolean char byte short int long float double String null
syn keyword javaDoc Throws Returns Parameters Since
syn match docName /^ \* \i\+\(\s\+\-\)/he=e-2,hs=s+3

hi def link javaScopeDecl Keyword
hi def link javaStorageClass Keyword
hi def link javaDoc Identifier
hi def link javaType Keyword
hi def link docName Typedef
hi def link preInput Tag
hi def link docOther Special
