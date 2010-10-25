if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn case ignore
syn spell toplevel

syn match bbcodeItem contained "\[\s*[-a-zA-Z0-9]\+"hs=s+1 contains=@NoSpell
syn match bbcodeItem contained "\[/\s*[-a-zA-Z0-9]\+"hs=s+2 contains=@NoSpell
syn match bbcodeItem contained "\[\s*\*\s*\]"hs=s+1,he=e-1 contains=@NoSpell
syn match bbcodeArgument contained "\s[-a-zA-Z0-9]\+\s*="ms=s+1,me=e-1 contains=@NoSpell
syn region bbcodeValue contained start="\"" end="\"" contains=@NoSpell
syn region bbcodeValue contained start="'" end="'" contains=@NoSpell
syn match bbcodeValue contained "=[\t ]*[^'" \t\]][^ \t\]]*"hs=s+1 contains=@NoSpell
syn region bbcodeTag start="\[/\{0,1}" end="\]" contains=@NoSpell,bbcodeItem,bbcodeArgument,bbcodeValue

syn region bbcodeBold start="\[b\]" end="\[/b\]"me=e-4 contains=bbcodeTag,bbcodeBoldItalic,bbcodeBoldUnderline
syn region bbcodeBoldItalic contained start="\[i\]" end="\[/i\]"me=e-4 contains=bbcodeTag,bbcodeBoldItalicUnderline
syn region bbcodeBoldItalicUnderline contained start="\[u\]" end="\[/u\]"me=e-4 contains=bbcodeTag
syn region bbcodeBoldUnderline contained start="\[u\]" end="\[/u\]"me=e-4 contains=bbcodeTag,bbcodeBoldUnderlineItalic
syn region bbcodeBoldUnderlineItalic contained start="\[i\]" end="\[/i\]"me=e-4 contains=bbcodeTag

syn region bbcodeItalic start="\[i\]" end="\[/i\]"me=e-4 contains=bbcodeTag,bbcodeItalicBold,bbcodeItalicUnderline
syn region bbcodeItalicBold contained start="\[b\]" end="\[/b\]"me=e-4 contains=bbcodeTag,bbcodeItalicBoldUnderline
syn region bbcodeItalicBoldUnderline contained start="\[u\]" end="\[/u\]"me=e-4 contains=bbcodeTag
syn region bbcodeItalicUnderline contained start="\[u\]" end="\[/u\]"me=e-4 contains=bbcodeTag,bbcodeItalicUnderlineBold
syn region bbcodeItalicUnderlineBold contained start="\[b\]" end="\[/b\]"me=e-4 contains=bbcodeTag

syn region bbcodeUnderline start="\[u\]" end="\[/u\]"me=e-4 contains=bbcodeTag,bbcodeUnderlineBold,bbcodeUnderlineItalic
syn region bbcodeUnderlineBold contained start="\[b\]" end="\[/b\]"me=e-4 contains=bbcodeTag,bbcodeUnderlineBoldItalic
syn region bbcodeUnderlineBoldItalic contained start="\[i\]" end="\[/i\]"me=e-4 contains=bbcodeTag
syn region bbcodeUnderlineItalic contained start="\[i\]" end="\[/i\]"me=e-4 contains=bbcodeTag,bbcodeUnderlineItalicBold
syn region bbcodeUnderlineItalicBold contained start="\[b\]" end="\[/b\]"me=e-4 contains=bbcodeTag

syn region bbcodeUrl start="\[url\s*[=\]]" end="\[/url\]"me=e-6 contains=@NoSpell,bbcodeTag

hi link bbcodeTag Identifier
hi link bbcodeItem Statement
hi link bbcodeArgument Type
hi link bbcodeValue Constant
hi link bbcodeUrl Underlined

hi link bbcodeBoldUnderlineItalic bbcodeBoldItalicUnderline
hi link bbcodeItalicBold bbcodeBoldItalic
hi link bbcodeItalicBoldUnderline bbcodeBoldItalicUnderline
hi link bbcodeItalicUnderlineBold bbcodeBoldItalicUnderline
hi link bbcodeUnderlineBold bbcodeBoldUnderline
hi link bbcodeUnderlineBoldItalic bbcodeBoldItalicUnderline
hi link bbcodeUnderlineItalic bbcodeItalicUnderline
hi link bbcodeUnderlineItalicBold bbcodeBoldItalicUnderline

hi def bbcodeBold term=bold cterm=bold gui=bold
hi def bbcodeBoldItalic term=bold,italic cterm=bold,italic gui=bold,italic
hi def bbcodeBoldItalicUnderline term=bold,italic,underline cterm=bold,italic,underline gui=bold,italic,underline
hi def bbcodeBoldUnderline term=bold,underline cterm=bold,underline gui=bold,underline
hi def bbcodeItalic term=italic cterm=italic gui=italic
hi def bbcodeItalicUnderline term=italic,underline cterm=italic,underline gui=italic,underline
hi def bbcodeUnderline term=underline cterm=underline gui=underline

let b:current_syntax = "bbcode"
