" Vim script
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: August 31, 2010
" URL: http://peterodding.com/code/vim/profile/autoload/xolox/escape.vim

" pattern() -- convert a string into a :substitute pattern that matches the string literally {{{1

function! xolox#escape#pattern(string)
  if type(a:string) == type('')
    let string = escape(a:string, '^$.*\~[]')
    return substitute(string, '\n', '\\n', 'g')
  endif
  return ''
endfunction

" substitute() -- convert a string into a :substitute replacement that inserts the string literally {{{1

function! xolox#escape#substitute(string)
  if type(a:string) == type('')
    let string = escape(a:string, '\&~%')
    return substitute(string, '\n', '\\r', 'g')
  endif
  return ''
endfunction

" vim: ts=2 sw=2 et
