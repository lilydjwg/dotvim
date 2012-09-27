" Vim indent file
" Language:	SystemTap
" Maintainer:	SystemTap Developers <systemtap@sourceware.org>
" Last Change:	2011 Aug 4

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" SystemTap indenting works *mostly* the same as C, so this gets things pretty
" close.  For 'real' SystemTap indenting, we would have to write a custom
" indentexpr function.

" indenting is similar to C, so start there...
setlocal cindent

" Statements don't require a ';', so don't indent following lines
setlocal cino=+0

" Known issues:
" - need to detect when following lines are a continuation of the previous
"   statement, and indent appropriately.
" - one-liners with control flow try to indent the next line if there's no
"   ';'.  For example:
"       if (my_condition) break
"           do_work()
"   The second line should not be indented.
" - The embedded-C braces do not line up correctly
" - Preprocessor braces don't line up correctly, and internals of the
"   preprocessor aren't getting any special handling.
" - Embedded-C statements across multiple lines don't indent
" - '#' comments don't maintain indenting (they get treated like C
"   preprocessor statements)
