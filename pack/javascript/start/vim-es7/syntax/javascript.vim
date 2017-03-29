" Vim syntax file
" Language:     JavaScript
" Maintainer:   Kao Wei-Ko(othree) <othree@gmail.com>
" Last Change:  2015-09-11
" Version:      1.5
" Changes:      Go to https://github.com/othree/yajs.vim for recent changes.
" Origin:       https://github.com/jelera/vim-javascript-syntax
" Credits:      Jose Elera Campana, Zhao Yi, Claudio Fleiner, Scott Shattuck 
"               (This file is based on their hard work), gumnos (From the #vim 
"               IRC Channel in Freenode)


" if exists("b:yajs_loaded")
  " finish
" else
  " let b:yajs_loaded = 1
" endif
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'javascript'
endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_javascript_syn_inits")
  let did_javascript_hilink = 1
  if version < 508
    let did_javascript_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
else
  finish
endif

"Dollar sign is permitted anywhere in an identifier
setlocal iskeyword-=$
if &filetype =~ 'javascript'
  setlocal iskeyword+=$
  syntax cluster htmlJavaScript                 contains=TOP
endif

syntax sync fromstart

"Syntax coloring for Node.js shebang line
syntax match   shellbang "^#!.*node\>"
syntax match   shellbang "^#!.*iojs\>"

syntax match   javascriptOpSymbols             /[+\-*/%\^=!&|?:]\+/ contains=javascriptOpSymbol nextgroup=@javascriptBlock,@javascriptComments,@javascriptExpression skipwhite skipempty
syntax match   javascriptOpSymbols             /:\ze\_[^+\-*/%\^=!<>&|?:]/ nextgroup=@javascriptComments,@javascriptStatement,javascriptCase skipwhite skipempty

syntax match   javascriptInvalidOp             contained /[+\-*/%\^=!<>&|?:]\+/ 

syntax match   javascriptOpSymbol              contained /\(:\|=\|?\)/ nextgroup=@javascriptExpression,javascriptInvalidOp skipwhite skipempty " 3
syntax match   javascriptOpSymbol              contained /\(===\|==\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 2
syntax match   javascriptOpSymbol              contained /!\+/ nextgroup=javascriptRegexpString,javascriptInvalidOp skipwhite skipempty " 1
syntax match   javascriptOpSymbol              contained /\(!==\|!=\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 2
syntax match   javascriptOpSymbol              contained /\(>>>=\|>>>\|>>=\|>>\|>=\|>\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 6
syntax match   javascriptOpSymbol              contained /\(<<=\|<<\|<=\|<\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 4
syntax match   javascriptOpSymbol              contained /\(++\|+=\|+\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 3
syntax match   javascriptOpSymbol              contained /\(--\|-=\|-\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 3
syntax match   javascriptOpSymbol              contained /\(||\||=\||\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 3
syntax match   javascriptOpSymbol              contained /\(&&\|&=\|&\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 3
syntax match   javascriptOpSymbol              contained /\(*=\|*\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 2
syntax match   javascriptOpSymbol              contained /\(%=\|%\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 2
syntax match   javascriptOpSymbol              contained /\(\/=\|\/\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 2
syntax match   javascriptOpSymbol              contained /\(^\|\~\)/ nextgroup=javascriptInvalidOp skipwhite skipempty " 2

" 37 operators
" syntax match   javascriptOpSymbol              contained /\(<\|>\|<=\|>=\|==\|!=\|===\|!==\|+\|*\|%\|++\|--\|<<\|>>\|>>>\|&\||\|^\|!\|\~\|&&\|||\|?\|=\|+=\|-=\|*=\|%=\|<<=\|>>=\|>>>=\|&=\||=\|^=\|\/\|\/=\)/ nextgroup=javascriptInvalidOp skipwhite skipempty

"JavaScript comments
syntax keyword javascriptCommentTodo           contained TODO FIXME XXX TBD
syntax region  javascriptLineComment           start="//" end="\n" contains=@Spell,javascriptCommentTodo 
syntax region  javascriptComment               start="/\*"  end="\*/" contains=@Spell,javascriptCommentTodo extend
syntax cluster javascriptComments              contains=javascriptDocComment,javascriptComment,javascriptLineComment

"JSDoc
syntax case ignore

syntax region  javascriptDocComment            start="/\*\*"  end="\*/" contains=javascriptDocNotation,javascriptCommentTodo,@Spell fold keepend
syntax match   javascriptDocNotation           contained / @/ nextgroup=javascriptDocTags

syntax keyword javascriptDocTags               contained constant constructor constructs function ignore inner private public readonly static
syntax keyword javascriptDocTags               contained const dict expose inheritDoc interface nosideeffects override protected struct
syntax keyword javascriptDocTags               contained example global

" syntax keyword javascriptDocTags               contained ngdoc nextgroup=javascriptDocNGDirective
syntax keyword javascriptDocTags               contained ngdoc scope priority animations
syntax keyword javascriptDocTags               contained ngdoc restrict methodOf propertyOf eventOf eventType nextgroup=javascriptDocParam skipwhite
syntax keyword javascriptDocNGDirective        contained overview service object function method property event directive filter inputType error

syntax keyword javascriptDocTags               contained abstract virtual access augments

syntax keyword javascriptDocTags               contained arguments callback lends memberOf name type kind link mixes mixin tutorial nextgroup=javascriptDocParam skipwhite
syntax keyword javascriptDocTags               contained variation nextgroup=javascriptDocNumParam skipwhite

syntax keyword javascriptDocTags               contained author class classdesc copyright default defaultvalue nextgroup=javascriptDocDesc skipwhite
syntax keyword javascriptDocTags               contained deprecated description external host nextgroup=javascriptDocDesc skipwhite
syntax keyword javascriptDocTags               contained file fileOverview overview namespace requires since version nextgroup=javascriptDocDesc skipwhite
syntax keyword javascriptDocTags               contained summary todo license preserve nextgroup=javascriptDocDesc skipwhite

syntax keyword javascriptDocTags               contained borrows exports nextgroup=javascriptDocA skipwhite
syntax keyword javascriptDocTags               contained param arg argument property prop module nextgroup=javascriptDocNamedParamType,javascriptDocParamName skipwhite
syntax keyword javascriptDocTags               contained type nextgroup=javascriptDocParamType skipwhite
syntax keyword javascriptDocTags               contained define enum extends implements this typedef nextgroup=javascriptDocParamType skipwhite
syntax keyword javascriptDocTags               contained return returns throws exception nextgroup=javascriptDocParamType,javascriptDocParamName skipwhite
syntax keyword javascriptDocTags               contained see nextgroup=javascriptDocRef skipwhite

"syntax for event firing
syntax keyword javascriptDocTags               contained emits fires nextgroup=javascriptDocEventRef skipwhite

syntax keyword javascriptDocTags               contained function func method nextgroup=javascriptDocName skipwhite
syntax match   javascriptDocName               contained /\h\w*/

syntax keyword javascriptDocTags               contained fires event nextgroup=javascriptDocEventRef skipwhite
syntax match   javascriptDocEventRef           contained /\h\w*#\(\h\w*\:\)\?\h\w*/

syntax match   javascriptDocNamedParamType     contained /{.\+}/ nextgroup=javascriptDocParamName skipwhite
syntax match   javascriptDocParamName          contained /\(\[.\{-}\]\|[0-9a-zA-Z_\.]\+\)/ nextgroup=javascriptDocDesc skipwhite
syntax match   javascriptDocParamType          contained /{.\+}/ nextgroup=javascriptDocDesc skipwhite
syntax match   javascriptDocA                  contained /\%(#\|\w\|\.\|:\|\/\)\+/ nextgroup=javascriptDocAs skipwhite
syntax match   javascriptDocAs                 contained /\s*as\s*/ nextgroup=javascriptDocB skipwhite
syntax match   javascriptDocB                  contained /\%(#\|\w\|\.\|:\|\/\)\+/
syntax match   javascriptDocParam              contained /\%(#\|\w\|\.\|:\|\/\|-\)\+/
syntax match   javascriptDocNumParam           contained /\d\+/
syntax match   javascriptDocRef                contained /\%(#\|\w\|\.\|:\|\/\)\+/
syntax region  javascriptDocLinkTag            contained matchgroup=javascriptDocLinkTag start=/{/ end=/}/ contains=javascriptDocTags

syntax cluster javascriptDocs                  contains=javascriptDocParamType,javascriptDocNamedParamType,javascriptDocParam

if main_syntax == "javascript"
  syntax sync clear
  syntax sync ccomment javascriptComment minlines=200
endif

syntax case match

syntax cluster javascriptAfterIdentifier       contains=javascriptDotNotation,javascriptFuncCallArg,javascriptComputedProperty,javascriptWSymbols,@javascriptSymbols
syntax match   javascriptIdentifierName        /\<[^=<>!?+\-*\/%|&,;:. ~@#`"'\[\]\(\)\{\}\^0-9][^=<>!?+\-*\/%|&,;:. ~@#`"'\[\]\(\)\{\}\^]*/ nextgroup=@javascriptAfterIdentifier contains=@_semantic
" runtime syntax/semhl.vim

"Block VariableStatement EmptyStatement ExpressionStatement IfStatement IterationStatement ContinueStatement BreakStatement ReturnStatement WithStatement LabelledStatement SwitchStatement ThrowStatement TryStatement DebuggerStatement

syntax cluster javascriptStatement             contains=javascriptBlock,javascriptVariable,@javascriptExpression,javascriptConditional,javascriptRepeat,javascriptBranch,javascriptLabel,javascriptStatementKeyword,javascriptTry,javascriptDebugger

"Syntax in the JavaScript code
" syntax match   javascriptASCII                 contained /\\\d\d\d/
" syntax region  javascriptTemplateSubstitution  contained matchgroup=javascriptTemplateSB start=/\${/ end=/}/ contains=javascriptTemplateSBlock,javascriptTemplateSString 
syntax region  javascriptTemplateSubstitution  contained matchgroup=javascriptTemplateSB start=/\${/ end=/}/ contains=@javascriptExpression
syntax region  javascriptTemplateSBlock        contained start=/{/ end=/}/ contains=javascriptTemplateSBlock,javascriptTemplateSString transparent
syntax region  javascriptTemplateSString       contained start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/ extend contains=javascriptTemplateSStringRB transparent
syntax match   javascriptTemplateSStringRB     /}/ contained 
syntax region  javascriptString                start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/ nextgroup=@javascriptComments skipwhite skipempty
syntax region  javascriptTemplate              start=/`/  skip=/\\\\\|\\`\|\n/  end=/`\|$/ contains=javascriptTemplateSubstitution nextgroup=@javascriptComments,@javascriptSymbols skipwhite skipempty
" syntax match   javascriptTemplateTag           /\k\+/ nextgroup=javascriptTemplate
syntax region  javascriptArray                 matchgroup=javascriptBraces start=/\[/ end=/]/ contains=@javascriptValue,javascriptForComprehension,@javascriptComments nextgroup=@javascriptComments,@javascriptSymbols,@javascriptAfterIdentifier skipwhite skipempty

syntax match   javascriptNumber                /\<0[bB][01]\+\>/ nextgroup=@javascriptComments skipwhite skipempty
syntax match   javascriptNumber                /\<0[oO][0-7]\+\>/ nextgroup=@javascriptComments skipwhite skipempty
syntax match   javascriptNumber                /\<0[xX][0-9a-fA-F]\+\>/ nextgroup=@javascriptComments skipwhite skipempty
syntax match   javascriptNumber                /[+-]\=\%(\d\+\.\d\+\|\d\+\|\.\d\+\)\%([eE][+-]\=\d\+\)\=\>/ nextgroup=@javascriptComments skipwhite skipempty

syntax cluster javascriptTypes                 contains=javascriptString,javascriptTemplate,javascriptRegexpString,javascriptNumber,javascriptBoolean,javascriptNull,javascriptArray
syntax cluster javascriptValue                 contains=@javascriptTypes,@javascriptExpression,javascriptFuncKeyword,javascriptClassKeyword,javascriptObjectLiteral,javascriptIdentifier,javascriptIdentifierName,javascriptOperator,@javascriptSymbols

syntax match   javascriptLabel                 /[a-zA-Z_$]\k*\_s*:/he=e-1 contains=javascriptReserved nextgroup=@javascriptValue,@javascriptStatement skipwhite skipempty
syntax match   javascriptObjectLabel           contained /\k\+\_s*:/he=e-1 contains=javascriptObjectLabelColon nextgroup=@javascriptComments,@javascriptValue,@javascriptStatement skipwhite skipempty
syntax match   javascriptObjectLabelColon      contained /:/ nextgroup=@javascriptValue skipwhite skipempty
" syntax match   javascriptPropertyName          contained /"[^"]\+"\s*:/he=e-1 nextgroup=@javascriptValue skipwhite skipempty
" syntax match   javascriptPropertyName          contained /'[^']\+'\s*:/he=e-1 nextgroup=@javascriptValue skipwhite skipempty
syntax region  javascriptPropertyName          contained start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/ nextgroup=javascriptObjectLabelColon skipwhite skipempty
syntax region  javascriptComputedPropertyName  contained matchgroup=javascriptPropertyName start=/\[/rs=s+1 end=/]/ contains=@javascriptValue nextgroup=javascriptObjectLabelColon skipwhite skipempty
syntax region  javascriptComputedProperty      contained matchgroup=javascriptProperty start=/\[/rs=s+1 end=/]/ contains=@javascriptValue,@javascriptSymbols nextgroup=@javascriptAfterIdentifier skipwhite skipempty
" Value for object, statement for label statement

syntax cluster javascriptTemplates             contains=javascriptTemplate,javascriptTemplateSubstitution,javascriptTemplateSBlock,javascriptTemplateSString,javascriptTemplateSStringRB,javascriptTemplateSB
syntax cluster javascriptStrings               contains=javascriptProp,javascriptString,@javascriptTemplates,@javascriptComments,javascriptDocComment,javascriptRegexpString,javascriptPropertyName
syntax cluster javascriptNoReserved            contains=@javascriptStrings,@javascriptDocs,shellbang,javascriptObjectLiteral,javascriptObjectLabel,javascriptClassBlock,javascriptMethodDef,javascriptMethodName,javascriptMethod
"https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar#Keywords
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved break case catch class const continue
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved debugger default delete do else export
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved extends finally for function if 
"import,javascriptRegexpString,javascriptPropertyName
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved in instanceof let new return super
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved switch throw try typeof var
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved void while with yield

syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved enum implements package protected static
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved interface private public abstract boolean
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved byte char double final float goto int
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved long native short synchronized transient
syntax keyword javascriptReserved              containedin=ALLBUT,@javascriptNoReserved volatile

"this

"JavaScript Prototype
syntax keyword javascriptPrototype             prototype

"Program Keywords
syntax keyword javascriptIdentifier            arguments this nextgroup=@javascriptAfterIdentifier
syntax keyword javascriptVariable              let var const
syntax keyword javascriptOperator              delete new instanceof typeof void in nextgroup=@javascriptValue,@javascriptTypes skipwhite skipempty
syntax keyword javascriptForOperator           contained in of
syntax keyword javascriptBoolean               true false nextgroup=@javascriptComments skipwhite skipempty
syntax keyword javascriptNull                  null undefined nextgroup=@javascriptComments skipwhite skipempty
syntax keyword javascriptMessage               alert confirm prompt status
syntax keyword javascriptGlobal                self top parent

"Statement Keywords
syntax keyword javascriptExceptions            catch throw finally
syntax keyword javascriptConditional           if else
syntax keyword javascriptConditionalElse       else
syntax keyword javascriptRepeat                do while for nextgroup=javascriptLoopParen skipwhite skipempty
syntax keyword javascriptBranch                break continue
syntax keyword javascriptSwitch                switch nextgroup=javascriptSwitchExp skipwhite
syntax keyword javascriptCase                  case nextgroup=@javascriptTypes skipwhite
syntax keyword javascriptDefault               default nextgroup=javascriptCaseColon skipwhite
syntax keyword javascriptStatementKeyword      return with yield
syntax keyword javascriptReturn                return nextgroup=@javascriptValue skipwhite
syntax keyword javascriptYield                 yield

syntax keyword javascriptTry                   try
syntax keyword javascriptExceptions            catch throw finally
syntax keyword javascriptDebugger              debugger

syntax region  javascriptSwitchExp             contained start=/(/ end=/)/ matchgroup=javascriptParens contains=javascriptFuncKeyword,javascriptFuncComma,javascriptDefaultAssign,@javascriptComments nextgroup=javascriptSwitchBlock skipwhite skipwhite skipempty
syntax region  javascriptSwitchBlock           matchgroup=javascriptBraces start=/\([\^:]\s\*\)\=\zs{/ end=/}/ contains=javascriptCaseColon,@htmlJavaScript
syntax match   javascriptCaseColon             contained /:/ nextgroup=javascriptBlock

syntax match   javascriptProp                  contained /[a-zA-Z_$][a-zA-Z0-9_$]*/ contains=@props,@_semantic transparent nextgroup=@javascriptAfterIdentifier
syntax match   javascriptMethod                contained /[a-zA-Z_$][a-zA-Z0-9_$]*\ze(/ contains=@props transparent nextgroup=javascriptFuncCallArg
syntax match   javascriptDotNotation           /\./ nextgroup=javascriptProp,javascriptMethod
syntax match   javascriptDotStyleNotation      /\.style\./ nextgroup=javascriptDOMStyle transparent

runtime syntax/yajs/javascript.vim
runtime syntax/yajs/es6-number.vim
runtime syntax/yajs/es6-string.vim
runtime syntax/yajs/es6-array.vim
runtime syntax/yajs/es6-object.vim
runtime syntax/yajs/es6-symbol.vim
runtime syntax/yajs/es6-function.vim
runtime syntax/yajs/es6-math.vim
runtime syntax/yajs/es6-date.vim
runtime syntax/yajs/es6-json.vim
runtime syntax/yajs/es6-regexp.vim
runtime syntax/yajs/es6-map.vim
runtime syntax/yajs/es6-set.vim
runtime syntax/yajs/es6-proxy.vim
runtime syntax/yajs/es6-promise.vim
runtime syntax/yajs/ecma-402.vim
runtime syntax/yajs/node.vim
runtime syntax/yajs/web.vim
runtime syntax/yajs/web-window.vim
runtime syntax/yajs/web-navigator.vim
runtime syntax/yajs/web-location.vim
runtime syntax/yajs/web-history.vim
runtime syntax/yajs/web-console.vim
runtime syntax/yajs/web-xhr.vim
runtime syntax/yajs/web-blob.vim
runtime syntax/yajs/web-crypto.vim
runtime syntax/yajs/web-fetch.vim
runtime syntax/yajs/web-service-worker.vim
runtime syntax/yajs/dom-node.vim
runtime syntax/yajs/dom-elem.vim
runtime syntax/yajs/dom-document.vim
runtime syntax/yajs/dom-event.vim
runtime syntax/yajs/dom-storage.vim
runtime syntax/yajs/css.vim

let javascript_props = 1

runtime syntax/yajs/event.vim
syntax region  javascriptEventString           contained start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/ contains=javascriptASCII,@events

"Import
syntax region  javascriptImportDef             start=/import/ end=/;\|\n/ contains=javascriptImport,javascriptImportBlock,javascriptString,javascriptEndColons
syntax keyword javascriptImport                contained from as import
syntax keyword javascriptImportAs              contained as
syntax region  javascriptImportBlock           matchgroup=javascriptBraces start=/\([\^:]\s\*\)\=\zs{/ end=/}/ contains=javascriptImportAs
syntax keyword javascriptExport                export module

syntax region  javascriptBlock                 matchgroup=javascriptBraces start=/\([\^:]\s\*\)\=\zs{/ end=/}/ contains=@htmlJavaScript

" syntax region  javascriptMethodDef             contained start=/\(\(\(set\|get\)\_s\+\)\?\)[a-zA-Z_$]\k*\_s*(/ end=/)/ contains=javascriptMethodAccessor,javascriptMethodName,javascriptFuncArg nextgroup=javascriptBlock skipwhite keepend
syntax region  javascriptMethodDef             contained start=/\(\(\(set\|get\)\_s\+\|\*\s*\)\?\)[a-zA-Z_$]\k*\_s*(/ end=/)/ contains=javascriptMethodAccessor,javascriptMethodName,javascriptFuncArg nextgroup=javascriptBlock skipwhite keepend
syntax match   javascriptMethodName            contained /[a-zA-Z_$]\k*/ nextgroup=javascriptFuncArg skipwhite skipempty
syntax match   javascriptMethodAccessor        contained /\(set\|get\)\s\+\ze\k/ contains=javascriptMethodAccessorWords
syntax keyword javascriptMethodAccessorWords   contained get set
syntax region  javascriptMethodName            contained matchgroup=javascriptPropertyName start=/\[/ end=/]/ contains=@javascriptValue nextgroup=javascriptFuncArg skipwhite skipempty

" syntax keyword javascriptFuncKeyword           function nextgroup=javascriptAsyncFunc,javascriptSyncFunc
syntax match   javascriptSyncFunc              contained /\s*/ nextgroup=javascriptFuncName,javascriptFuncArg
syntax match   javascriptAsyncFunc             contained /\s*\*\s*/ nextgroup=javascriptFuncName,javascriptFuncArg skipwhite skipempty
syntax match   javascriptFuncName              contained /[a-zA-Z_$]\k*/ nextgroup=javascriptFuncArg skipwhite
syntax region  javascriptFuncArg               contained matchgroup=javascriptParens start=/(/ end=/)/ contains=javascriptFuncKeyword,javascriptFuncComma,javascriptDefaultAssign,@javascriptComments nextgroup=flowBlockTypeAnnotation,javascriptBlock skipwhite skipwhite skipempty

" syntax match   javascriptFuncArg               contained /(\_[^()]*)/ contains=javascriptParens,javascriptFuncKeyword,javascriptFuncComma,javascriptDefaultAssign,@javascriptComments nextgroup=javascriptBlock skipwhite skipwhite skipempty
syntax match   javascriptFuncComma             contained /,/
syntax match   javascriptDefaultAssign         contained /=/ nextgroup=@javascriptExpression skipwhite skipempty


"Class
syntax keyword javascriptClassKeyword          class nextgroup=javascriptClassName skipwhite
syntax keyword javascriptClassSuper            super
syntax match   javascriptClassName             contained /\k\+/ nextgroup=javascriptClassBlock,javascriptClassExtends skipwhite
syntax match   javascriptClassSuperName        contained /[a-zA-Z_$][a-zA-Z_$\[\]\.]*/ nextgroup=javascriptClassBlock skipwhite
syntax keyword javascriptClassExtends          contained extends nextgroup=javascriptClassSuperName skipwhite
syntax region  javascriptClassBlock            contained matchgroup=javascriptBraces start=/{/ end=/}/ contains=javascriptMethodName,javascriptMethodAccessor,javascriptClassStatic,@javascriptComments
syntax keyword javascriptClassStatic           contained static nextgroup=javascriptMethodName,javascriptMethodAccessor skipwhite


syntax keyword javascriptForComprehension      contained for nextgroup=javascriptForComprehensionTail skipwhite skipempty
syntax region  javascriptForComprehensionTail  contained matchgroup=javascriptParens start=/(/ end=/)/ contains=javascriptOfComprehension,@javascriptExpression nextgroup=javascriptForComprehension,javascriptIfComprehension,@javascriptExpression skipwhite skipempty
syntax keyword javascriptOfComprehension       contained of
syntax keyword javascriptIfComprehension       contained if nextgroup=javascriptIfComprehensionTail
syntax region  javascriptIfComprehensionTail   contained matchgroup=javascriptParens start=/(/ end=/)/ contains=javascriptExpression nextgroup=javascriptForComprehension,javascriptIfComprehension skipwhite skipempty

syntax region  javascriptObjectLiteral         contained matchgroup=javascriptBraces start=/{/ end=/}/ contains=@javascriptComments,javascriptObjectLabel,javascriptObjectComma,javascriptPropertyName,javascriptMethodDef,javascriptComputedPropertyName,@javascriptValue

syntax match javascriptObjectComma             contained /,/

" syntax match   javascriptBraces                /[\[\]]/
syntax match   javascriptParens                /[()]/
" syntax match   javascriptOpSymbols             /[^+\-*/%\^=!<>&|?]\@<=\(<\|>\|<=\|>=\|==\|!=\|===\|!==\|+\|-\|*\|%\|++\|--\|<<\|>>\|>>>\|&\||\|^\|!\|\~\|&&\|||\|?\|=\|+=\|-=\|*=\|%=\|<<=\|>>=\|>>>=\|&=\||=\|^=\|\/\|\/=\)\ze\_[^+\-*/%\^=!<>&|?]/ nextgroup=@javascriptExpression skipwhite
syntax region  htmlScriptTag     contained start=+<script+ end=+>+ fold contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent
syntax match   javascriptWOpSymbols            contained /\_s\+/ nextgroup=javascriptOpSymbols
syntax match   javascriptEndColons             /[;,]/
syntax match   javascriptLogicSymbols          /[&|]\+/ contains=javascriptLogicSymbol nextgroup=@javascriptExpression skipwhite skipempty
syntax match   javascriptLogicSymbol           /\(&&\|||\)/ nextgroup=javascriptInvalidOp
syntax cluster javascriptSymbols               contains=javascriptOpSymbols,javascriptLogicSymbols
syntax match   javascriptWSymbols              contained /\_s\+/ nextgroup=@javascriptSymbols,@javascriptComments

syntax region  javascriptRegexpString          start="\(^\|&\||\|=\|(\|{\|;\|:\|\[\|!\|?\)\@<=\_s*/\ze[^/*]" skip="\\\\\|[^\\]\@<=\\/" end="/[gimy]\{0,2\}" oneline contains=javascriptRegexpSet,javascriptRegexpLeftBracket
syntax region  javascriptRegexpSet             contained start="\[" skip="[^\\]\@<=\\\]" end="\]" extend transparent 
syntax match   javascriptRegexpLeftBracket     contained /\\\[/ 

syntax cluster javascriptEventTypes            contains=javascriptEventString,javascriptTemplate,javascriptNumber,javascriptBoolean,javascriptNull
syntax cluster javascriptOps                   contains=javascriptOpSymbols,javascriptLogicSymbols,javascriptOperator
syntax region  javascriptParenExp              matchgroup=javascriptParens start=/(/ end=/)/ contains=@javascriptExpression nextgroup=@javascriptComments,@javascriptSymbols skipwhite skipempty
syntax cluster javascriptExpression            contains=javascriptArrowFuncDef,javascriptParenExp,@javascriptValue,javascriptObjectLiteral,javascriptFuncKeyword,javascriptYield,javascriptIdentifierName,javascriptRegexpString,@javascriptTypes,@javascriptOps,javascriptGlobal,javascriptGlobalMethod,jsxRegion
syntax cluster javascriptEventExpression       contains=javascriptArrowFuncDef,javascriptParenExp,@javascriptValue,javascriptObjectLiteral,javascriptFuncKeyword,javascriptIdentifierName,javascriptRegexpString,@javascriptEventTypes,@javascriptOps,javascriptGlobal,jsxRegion

syntax region  javascriptLoopParen             contained matchgroup=javascriptParens start=/(/ end=/)/ contains=javascriptVariable,javascriptForOperator,javascriptEndColons,@javascriptExpression nextgroup=javascriptBlock skipwhite skipempty

" syntax match   javascriptFuncCall              contained /[a-zA-Z]\k*\ze(/ nextgroup=javascriptFuncCallArg
syntax region  javascriptFuncCallArg           contained matchgroup=javascriptParens start=/(/ end=/)/ contains=javascriptFuncComma,@javascriptExpression,@javascriptComments nextgroup=@javascriptAfterIdentifier
syntax cluster javascriptSymbols               contains=javascriptOpSymbols,javascriptLogicSymbols
" syntax match   javascriptWSymbols              contained /\_s\+/ nextgroup=@javascriptSymbols
syntax region  javascriptEventFuncCallArg      contained matchgroup=javascriptParens start=/(/ end=/)/ contains=@javascriptEventExpression,@javascriptComments

syntax match   javascriptArrowFuncDef          contained /([^)]*)\_s*=>/ contains=javascriptParens,javascriptFuncArg,javascriptFuncComma,javascriptArrowFunc nextgroup=javascriptOperator,javascriptIdentifierName,javascriptBlock,javascriptArrowFuncDef skipwhite skipempty
syntax match   javascriptArrowFuncDef          contained /[a-zA-Z_$][a-zA-Z0-9_$]*\_s*=>/ contains=javascriptArrowFuncArg,javascriptArrowFunc nextgroup=javascriptOperator,javascriptIdentifierName,javascriptBlock,javascriptArrowFuncDef skipwhite skipempty
syntax match   javascriptArrowFunc             /=>/
syntax match   javascriptArrowFuncArg          contained /[a-zA-Z_$]\k*/
syntax keyword javascriptFuncKeyword           function nextgroup=javascriptAsyncFunc,javascriptSyncFunc

" ==============================================================================
" Flow
syntax region  flowBlockTypeAnnotation      contained start=/:/ end=/{/me=s-1 contains=@flowType,flowColon nextgroup=javascriptBlock skipwhite skipempty
syntax cluster flowType                     contains=flowKeyword,javascriptIdentifierName,flowPolymorphicType
syntax match   flowColon                    contained /:/
syntax match   flowBrackets                 contained /[<>]/
syntax region  flowPolymorphicType          contained matchgroup=flowBrackets start=/</ end=/>/ contains=@flowType
syntax keyword flowKeyword                  contained any boolean mixed number string void

" ==============================================================================
" ES7
"
" Vim syntax file
" Language:     JavaScript
" Maintainer:   Kao Wei-Ko(othree) <othree@gmail.com>
" Last Change:  2015-08-05
" Version:      0.1
" Changes:      Go to https://github.com/othree/es.next.syntax.vim for recent changes.

" decorator
syntax match   javascriptDecorator             /@/ containedin=javascriptClassBlock nextgroup=javascriptDecoratorFuncName
syntax match   javascriptDecoratorFuncName     contained /\<[^=<>!?+\-*\/%|&,;:. ~@#`"'\[\]\(\)\{\}\^0-9][^=<>!?+\-*\/%|&,;:. ~@#`"'\[\]\(\)\{\}\^]*/ nextgroup=javascriptDecoratorFuncCall,javascriptDecorator,javascriptClassMethodName skipwhite skipempty
syntax region  javascriptDecoratorFuncCall     contained matchgroup=javascriptDecoratorParens start=/(/ end=/)/ contains=@javascriptExpression,@javascriptComments nextgroup=javascriptDecorator,javascriptClassMethodName skipwhite skipempty

" class property initializer
syntax match   javascriptClassProperty         containedin=javascriptClassBlock /[a-zA-Z_$]\k*\s*=/ nextgroup=@javascriptExpression skipwhite skipempty
syntax keyword javascriptClassStatic           contained static nextgroup=javascriptClassProperty,javascriptMethodName,javascriptMethodAccessor skipwhite

" async await
syntax keyword javascriptAsyncFuncKeyword      async nextgroup=javascriptFuncKeyword,javascriptArrowFuncDef skipwhite
syntax keyword javascriptAsyncFuncKeyword      await nextgroup=@javascriptExpression skipwhite

syntax cluster javascriptExpression            add=javascriptAsyncFuncKeyword

" ==============================================================================
" highlighting

if exists("did_javascript_hilink")
  HiLink javascriptReserved             Error
  HiLink javascriptInvalidOp            Error

  HiLink javascriptEndColons            Exception
  HiLink javascriptOpSymbol             Normal
  HiLink javascriptLogicSymbol          Boolean
  HiLink javascriptBraces               Function
  HiLink javascriptParens               Normal
  HiLink javascriptComment              Comment
  HiLink javascriptLineComment          Comment
  HiLink javascriptDocComment           Comment
  HiLink javascriptCommentTodo          Todo
  HiLink javascriptDocNotation          SpecialComment
  HiLink javascriptDocTags              SpecialComment
  HiLink javascriptDocNGParam           javascriptDocParam
  HiLink javascriptDocParam             Function
  HiLink javascriptDocNumParam          Function
  HiLink javascriptDocEventRef          Function
  HiLink javascriptDocNamedParamType    Type
  HiLink javascriptDocParamName         Type
  HiLink javascriptDocParamType         Type
  HiLink javascriptString               String
  HiLink javascriptTemplate             String
  HiLink javascriptEventString          String
  HiLink javascriptASCII                Label
  HiLink javascriptTemplateSubstitution Label
  " HiLink javascriptTemplateSBlock       Label
  " HiLink javascriptTemplateSString      Label
  HiLink javascriptTemplateSStringRB    javascriptTemplateSubstitution
  HiLink javascriptTemplateSB           javascriptTemplateSubstitution
  HiLink javascriptRegexpString         String
  HiLink javascriptRegexpLeftBracket    javascriptRegexpString
  HiLink javascriptGlobal               Constant
  HiLink javascriptCharacter            Character
  HiLink javascriptPrototype            Type
  HiLink javascriptConditional          Conditional
  HiLink javascriptConditionalElse      Conditional
  HiLink javascriptSwitch               Conditional
  HiLink javascriptCase                 Conditional
  HiLink javascriptDefault              javascriptCase
  HiLink javascriptBranch               Conditional
  HiLink javascriptIdentifier           Structure
  HiLink javascriptVariable             Identifier
  HiLink javascriptRepeat               Repeat
  HiLink javascriptForComprehension     Repeat
  HiLink javascriptIfComprehension      Repeat
  HiLink javascriptOfComprehension      Repeat
  HiLink javascriptForOperator          Repeat
  HiLink javascriptStatementKeyword     Statement
  HiLink javascriptReturn               Statement
  HiLink javascriptYield                Statement
  HiLink javascriptMessage              Keyword
  HiLink javascriptOperator             Identifier
  " HiLink javascriptType                 Type
  HiLink javascriptNull                 Boolean
  HiLink javascriptNumber               Number
  HiLink javascriptBoolean              Boolean
  HiLink javascriptObjectLabel          javascriptLabel
  HiLink javascriptLabel                Label
  HiLink javascriptPropertyName         Label
  HiLink javascriptImport               Special
  HiLink javascriptImportAs             Special
  HiLink javascriptExport               Special
  HiLink javascriptTry                  Special
  HiLink javascriptExceptions           Special

  HiLink javascriptMethodName           Function
  HiLink javascriptMethodAccessor       Operator

  HiLink javascriptFuncKeyword          Keyword
  HiLink javascriptAsyncFunc            Keyword
  HiLink javascriptArrowFunc            Type
  HiLink javascriptFuncName             Function
  HiLink javascriptFuncArg              Special
  HiLink javascriptArrowFuncArg         javascriptFuncArg
  HiLink javascriptFuncComma            Operator

  HiLink javascriptClassKeyword         Keyword
  HiLink javascriptClassExtends         Keyword
  HiLink javascriptClassName            Function
  HiLink javascriptClassSuperName       Function
  HiLink javascriptClassStatic          StorageClass
  HiLink javascriptClassSuper           keyword

  " ES7
  HiLink javascriptDecorator            Statement
  HiLink javascriptDecoratorFuncName    Statement
  HiLink javascriptDecoratorFuncCall    Statement
  HiLink javascriptDecoratorParens      Statement
  HiLink javascriptClassProperty        Normal
  HiLink javascriptAsyncFuncKeyword     Keyword

  " Flow
  HiLink flowBrackets                   Operator
  HiLink flowColon                      Operator
  HiLink flowKeyword                    Keyword

  HiLink shellbang                      Comment

  highlight link javaScript             NONE

  delcommand HiLink
  unlet did_javascript_hilink
endif

" ==============================================================================
" activating

let b:current_syntax = "javascript"
if main_syntax == 'javascript'
  unlet main_syntax
endif
