" Vim syntax file for Trac wiki syntax
"
" Language:     trac wiki
" Maintainer:   Caleb Constantine <cadamantine@gmail.com>
" Last Change:  22 Nov 2010
" Version: 0.5

" Modified extensively from wiki.vim, by Andreas Kneib,
" http://www.vim.org/scripts/script.php?script_id=725

" To use this syntax file:
"
" - Put the file in your syntax directory, e.g. ~/.vim/syntax,
"   $HOME/vimfiles/syntax (see :help syntax).
" - Enable file type detection. One method is to add the following to your
"   filetype.vim file, which is usually located in ~/.vim or $HOME/vimfiles
"   (create it if not present, see :help filetype):
"
"       augroup tracwiki
"           au! BufRead,BufNewFile *.tracwiki   setfiletype tracwiki
"       augroup END
"
" TODO: 
" - Highlight tables.
" - Highlight Blockquotes
" - Highlight Numbered (ordered) lists
" - Highlight Processors. Some processors can have there own syntax highlight,
"   e.g. rst. Pull in syntax for these from existing syntax files.
" - Some wiki formatting is allowed inside discussion citations
"   (tracDisussion). We don't currently support that but we should.


" Quit if syntax file is already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn region  tracVerb        start="{\{3}" end="}\{3}"
syn region  tracVerb        start="`" end="`"

syn region  tracHead        start="^=\{1,5} " end="=\{1,5} *\(#[^ ]\+\)\?"
syn match   tracLine        "^----$"

syn region tracItalic       start=+''+ end=+''+ containedin=tracHead contains=tracEscape
syn region tracBold         start=+'''+ end=+'''+ containedin=tracHead contains=tracEscape
syn region tracBoldItalic   start=+'''''+ end=+'''''+ containedin=tracHead contains=tracEscape
syn region tracUnderline    start=+__+hs=s+2 end=+__+he=e-2 containedin=tracHead contains=tracEscape
syn region tracStrike       start=+\~\~+ end=+\~\~+ containedin=tracHead contains=tracEscape
syn region tracSuper        start=+\^+ end=+\^+ containedin=tracHead contains=tracEscape
syn region tracSub          start=+,,+ end=+,,+ containedin=tracHead contains=tracEscape

" This may need to be fine tuned.
syn match tracEscape        "![^ ]\+\( \|$\)" contained
syn region tracEscape       start=+!\[+ end=+\]+

syn region  tracLink        start=+\[+ end=+\]+
syn match   tracRawLink     "\<\%(\%(\%(https\=\|file\|ftp\|gopher\)://\|\%(mailto\|news\):\)[^[:space:]'\"<>]\+\|www[[:alnum:]_-]*\.[[:alnum:]_-]\+\.[^[:space:]'\"<>]\+\)[[:alnum:]/]" contains=@NoSpell
syn match   tracPageName    "\<\(wiki:\)\?\([A-Z][a-z]\+\)\{2,}\>\([#/]\<\([A-Z][a-z]\+\)\{2,}\>\)*"

" Trac links
"
" Tickets
syn match   tracLinks      "#\d\+"
" Reports
syn match   tracLinks     "{\d\+}"
" Change sets. Make sure defined after tracLink otherwise syntax will break.
syn match   tracLinks     "\<r\d\+"
" Revision log. Make sure defined after tracLink otherwise syntax will break.
syn match   tracLinks     "\<r\d\+:\d\+"
syn match   tracLinks     "\[\d\+:\d\+\(/[^]]\+\)*\]"
" General form, type:id (where id represents the number, name or path of the
" item)
syn match   tracLinks     `\<\(wiki\|source\|attachment\|milestone\|diff\|log\|report\|changeset\|comment\|ticket\):\(".\+"\|'.\+'\|\(\S\+\)\+\)`

" Change sets. Make sure defined after tracLink and before tracLinks otherwise
" syntax will break.
syn region  tracMacro       start=+\[\[+ end=+\]\]+

syn match   tracListItem    "^\s\+[*-]\s\+"
syn match   tracDefList     "^\s.\+::" 

syn region  tracDisussion   start="^>" end="$"

syn match   tracEscape      "!\<\([A-Z][a-z]\+\)\{2,}\>\([#/]\<\([A-Z][a-z]\+\)\{2,}\>\)*"

" The default highlighting.
  
hi def link tracLinks        Function
hi def link tracHead         Type
hi def link tracLine         Type
hi def link tracVerb         String
hi def      tracBold          term=bold cterm=bold gui=bold
hi def      tracItalic        term=italic cterm=italic gui=italic
hi def      tracUnderline     term=underline cterm=underline gui=underline
hi def      tracBoldItalic    term=bold,italic cterm=bold,italic gui=bold,italic
hi def link tracEscape       Special
hi def link tracStrike       Statement
hi def link tracSuper        Statement
hi def link tracSub          Statement
hi def link tracLink         Function
hi def link tracRawLink      Function
hi def link tracPageName     Function
hi def link tracListItem     Operator
hi def link tracDefList      tracBoldItalic
hi def link tracMacro        PreProc
hi def link tracDisussion    Comment

hi def link tracCurlyError  Error

let b:current_syntax = "trac"

"vim: tw=78:ft=vim:ts=8
