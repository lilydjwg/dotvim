" ingo/regexp/comments.vim: Functions that converts 'comments' to regular expressions.
"
" DEPENDENCIES:
"   - ingo/option.vim autoload script
"   - IndentCommentPrefix.vim plugin (optional integration)
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.020.003	03-Jun-2014	Use ingo#option#Split().
"   1.013.002	12-Sep-2013	Avoid using \ze in
"				ingo#regexp#comments#CommentToExpression(). It
"				may be used in a larger expression that still
"				wants to match after the prefix.
"   1.009.001	18-Jun-2013	file creation from
"				AdvancedJoiners/CommentJoin.vim

function! ingo#regexp#comments#CommentToExpression( comment )
    let [l:flags, l:comment] = matchlist(a:comment, '\([^:]*\):\(.*\)')[1:2]

    " Mask backslash for "very nomagic" pattern.
    let l:comment = escape(l:comment, '\')

    " Observe when a blank is required after the comment string, but do not
    " include it in the match, so that it is preserved during the join.
    " Illustration: With :setlocal comments=b:#,:>
    " # This is				>This is
    " # text.				> specta
    " Will be joined to			>cular.
    " # This is text.			Will be joined to
    "					>This is spectacular.
    return (l:flags =~# 'b' ? l:comment . '\%(\s\|\$\)\@=': l:comment)
endfunction
function! ingo#regexp#comments#FromSetting()
    if empty(&l:comments)
	" For this buffer, no comment markers are defined. Use any non-word
	" non-whitespace sequence as a generalization.
	let l:commentExpressions = ['\%(\W\&\S\)\+']
    else
	" Convert each comment marker of the 'comments' setting into a regular
	" expression.
	let l:commentExpressions = map(ingo#option#Split(&l:comments), 'ingo#regexp#comments#CommentToExpression(v:val)')
    endif

    " Integration with IndentCommentPrefix.vim plugin.
    let l:commentExpressions += map(copy(ingo#plugin#setting#GetBufferLocal('IndentCommentPrefix_Whitelist', [])), 'escape(v:val, ''\\'')')

    return l:commentExpressions
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
