" Vim syntax file
" Language: Smali (Dalvik) Assembly
" Maintainer:   Jon Larimer <jlarimer@gmail.com>
" Last change:  2010 Jan 8
"
" Syntax highlighting for baksmali (Dalvik disassembler) output

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

setlocal iskeyword=@,48-57,_,128-167,224-235,.,-,/

syn region dalvikComment start="#" keepend end="$"

" directives
syn keyword dalvikDirective .class .super .implements .field
syn keyword dalvikDirective .subannotation .annotation 
syn keyword dalvikDirective .enum .method .registers .locals .array-data
syn keyword dalvikDirective .packed-switch 
syn keyword dalvikDirective .sparse-switch .catch .catchall .line
syn keyword dalvikDirective .parameter .local 
syn keyword dalvikDirective .prologue .epilogue
syn keyword dalvikDirective .source
syn match dalvikDirective /\.end\s\+\(field\|subannotation\|annotation\|method\|array-data\)/
syn match dalvikDirective /\.end\s\+\(packed-switch\|sparse-switch\|parameter\|local\)/
syn match dalvikDirective /\.restart\s+local/

" access modifiers
syn keyword dalvikAccess public private protected static final synchronized bridge varargs
syn keyword dalvikAccess native abstract strictfp synthetic constructor declared-synchronized
syn keyword dalvikAccess interface enum annotation volatile transient

" instructions
syn keyword dalvikInstruction goto return-void nop const/4 move-result move-result-wide 
syn keyword dalvikInstruction move-result-object move-exception return return-wide 
syn keyword dalvikInstruction return-object monitor-enter monitor-exit throw move 
syn keyword dalvikInstruction move-wide move-object array-length neg-int not-int neg-long 
syn keyword dalvikInstruction not-long neg-float neg-double int-to-long int-to-float 
syn keyword dalvikInstruction int-to-double long-to-int long-to-float long-to-double 
syn keyword dalvikInstruction float-to-int float-to-long float-to-double double-to-int 
syn keyword dalvikInstruction double-to-long double-to-float int-to-byte int-to-char 
syn keyword dalvikInstruction int-to-short add-int/2addr sub-int/2addr mul-int/2addr 
syn keyword dalvikInstruction div-int/2addr rem-int/2addr and-int/2addr or-int/2addr 
syn keyword dalvikInstruction xor-int/2addr shl-int/2addr shr-int/2addr ushr-int/2addr 
syn keyword dalvikInstruction add-long/2addr sub-long/2addr mul-long/2addr div-long/2addr 
syn keyword dalvikInstruction rem-long/2addr and-long/2addr or-long/2addr xor-long/2addr 
syn keyword dalvikInstruction shl-long/2addr shr-long/2addr ushr-long/2addr add-float/2addr 
syn keyword dalvikInstruction sub-float/2addr mul-float/2addr div-float/2addr rem-float/2addr 
syn keyword dalvikInstruction add-double/2addr sub-double/2addr mul-double/2addr 
syn keyword dalvikInstruction div-double/2addr rem-double/2addr goto/16 sget sget-wide 
syn keyword dalvikInstruction sget-object sget-boolean sget-byte sget-char sget-short sput 
syn keyword dalvikInstruction sput-wide sput-object sput-boolean sput-byte sput-char sput-short 
syn keyword dalvikInstruction const-string check-cast new-instance const-class const/high16 
syn keyword dalvikInstruction const-wide/high16 const/16 const-wide/16 if-eqz if-nez if-ltz 
syn keyword dalvikInstruction if-gez if-gtz if-lez add-int/lit8 rsub-int/lit8 mul-int/lit8 
syn keyword dalvikInstruction div-int/lit8 rem-int/lit8 and-int/lit8 or-int/lit8 xor-int/lit8 
syn keyword dalvikInstruction shl-int/lit8 shr-int/lit8 ushr-int/lit8 iget iget-wide iget-object 
syn keyword dalvikInstruction iget-boolean iget-byte iget-char iget-short iput iput-wide iput-object 
syn keyword dalvikInstruction iput-boolean iput-byte iput-char iput-short instance-of new-array 
syn keyword dalvikInstruction iget-quick iget-wide-quick iget-object-quick iput-quick 
syn keyword dalvikInstruction iput-wide-quick iput-object-quick rsub-int add-int/lit16 mul-int/lit16 
syn keyword dalvikInstruction div-int/lit16 rem-int/lit16 and-int/lit16 or-int/lit16 xor-int/lit16 
syn keyword dalvikInstruction if-eq if-ne if-lt if-ge if-gt if-le move/from16 move-wide/from16 
syn keyword dalvikInstruction move-object/from16 cmpl-float cmpg-float cmpl-double cmpg-double 
syn keyword dalvikInstruction cmp-long aget aget-wide aget-object aget-boolean aget-byte aget-char 
syn keyword dalvikInstruction aget-short aput aput-wide aput-object aput-boolean aput-byte aput-char 
syn keyword dalvikInstruction aput-short add-int sub-int mul-int div-int rem-int and-int or-int 
syn keyword dalvikInstruction xor-int shl-int shr-int ushr-int add-long sub-long mul-long div-long 
syn keyword dalvikInstruction rem-long and-long or-long xor-long shl-long shr-long ushr-long 
syn keyword dalvikInstruction add-float sub-float mul-float div-float rem-float add-double 
syn keyword dalvikInstruction sub-double mul-double div-double rem-double goto/32 const-string/jumbo 
syn keyword dalvikInstruction const const-wide/32 fill-array-data packed-switch sparse-switch move/16 
syn keyword dalvikInstruction move-wide/16 move-object/16 invoke-virtual invoke-super invoke-direct 
syn keyword dalvikInstruction invoke-static invoke-interface filled-new-array invoke-direct-empty 
syn keyword dalvikInstruction execute-inline invoke-virtual-quick invoke-super-quick 
syn keyword dalvikInstruction invoke-virtual/range invoke-super/range invoke-direct/range 
syn keyword dalvikInstruction invoke-static/range invoke-interface/range filled-new-array/range 
syn keyword dalvikInstruction invoke-virtual-quick/range invoke-super-quick/range const-wide 

" class names (between L and ;)
syn region dalvikName matchgroup=dalvikNameWrapper start="L" end=";" oneline 
syn region dalvikString start=+"+ end=+"+

" branch labels
syn match dalvikLabel "\<[A-Za-z0-9_]\+\>:$"

" registers
syn match dalvikRegister "\<[vp]\d\+\>"

" number literals
syn match dalvikNumber       "\<\-\?\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lLst]\=\>"
syn match dalvikNumber       "\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match dalvikNumber       "\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match dalvikNumber       "\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"

" default colors (for background=dark):
" Comment/Identifier = cyan
" Constant = magenta
" Special = lightred
" Identifier = cyan
" Statement = yellow
" PreProc = lightblue
" Type = lightgreen

hi def link dalvikDirective PreProc
hi def link dalvikAccess Statement
hi def link dalvikComment Comment
hi def link dalvikName Constant
"hi def link dalvikNameWrapper Special
hi def link dalvikNumber Constant
hi def link dalvikString Constant
hi def link dalvikLabel Statement
hi def link dalvikRegister Special
hi def link dalvikInstruction Type

let b:current_syntax = "smali"

