" Vim syntax file
" FileType:     Javascript Templates
" Author:       lilydjwg <lilydjwg@gmail.com>

" For this one: http://blueimp.github.io/JavaScript-Templates/
" with this setting:
" tmpl.regexp = /([\s'\\])(?!(?:[^[]|\[(?!%))*%\])|(?:\[%(=|#)([\s\S]+?)%\])|(\[%)|(%\])/g;

" Add something like the following in modeline to your templates:
" <!-- vim:se ft=html syntax=html.jsjstmpl: -->

syntax region jstmplCode matchgroup=PreProc start="\[%=\?" end="%\]" contains=@JavaScript containedin=ALL

let b:current_syntax_save = b:current_syntax
unlet b:current_syntax
syntax include @Javascript syntax/javascript.vim
let b:current_syntax = b:current_syntax_save
unlet b:current_syntax_save
