" Vim syntax file
" FileType:    lex
" Author:      lilydjwg

if has("folding")
 syn region lexInclude	fold matchgroup=lexSep	start="^%{"	end="%}"	contained	contains=ALLBUT,@lexListGroup,cCppInIf,cCppOutIf,cCppOutIf2,cCppOutElse,cCppOutSkip
else
 syn region lexInclude	matchgroup=lexSep		start="^%{"	end="%}"	contained	contains=ALLBUT,@lexListGroup,cCppInIf,cCppOutIf,cCppOutIf2,cCppOutElse,cCppOutSkip
endif
