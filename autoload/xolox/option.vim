" Vim script
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: June 10, 2010
" URL: http://peterodding.com/code/vim/profile/autoload/xolox/option.vim

" Functions to parse multi-valued Vim options like &tags and &runtimepath.

function! xolox#option#split(value) " {{{1
  let values = split(a:value, '[^\\]\zs,')
  return map(values, 's:unescape(v:val)')
endfunction

function! s:unescape(s)
  return substitute(a:s, '\\\([\\,]\)', '\1', 'g')
endfunction

function! xolox#option#join(values) " {{{1
  let values = copy(a:values)
  call map(values, 's:escape(v:val)')
  return join(values, ',')
endfunction

function! s:escape(s)
  return escape(a:s, ',\')
endfunction

function! xolox#option#split_tags(value) " {{{1
  let values = split(a:value, '[^\\]\zs,')
  return map(values, 's:unescape_tags(v:val)')
endfunction

function! s:unescape_tags(s)
  return substitute(a:s, '\\\([\\, ]\)', '\1', 'g')
endfunction

function! xolox#option#join_tags(values) " {{{1
  let values = copy(a:values)
  call map(values, 's:escape_tags(v:val)')
  return join(values, ',')
endfunction

function! s:escape_tags(s)
  return escape(a:s, ', ')
endfunction

" vim: ts=2 sw=2 et
