" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 17, 2010
" URL: http://peterodding.com/code/vim/profile/autoload/xolox.vim

" Miscellaneous functions used throughout my Vim profile and plug-ins.

" Lately I've been losing my message history a lot so I've added this option
" which keeps a ring buffer with the last N messages in "g:xolox_messages".
if !exists('g:xolox_message_buffer')
  let g:xolox_message_buffer = 100
endif

if !exists('g:xolox_messages')
  let g:xolox_messages = []
endif

function! xolox#is_windows() " {{{1
  return has('win16') || has('win32') || has('win64')
endfunction

function! xolox#trim(s) " -- trim whitespace from start and end of {s} {{{1
  return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! xolox#quote_pattern(s) " -- convert {s} to pattern that matches {s} literally (on word boundaries!) {{{1
  let patt = xolox#escape#pattern(a:s)
  if patt =~ '^\w'
    let patt = '\<' . patt
  endif
  if patt =~ '\w$'
    let patt = patt . '\>'
  endif
  return patt
endfunction

function! xolox#unique(list) " -- remove duplicate values from {list} (in-place) {{{1
	let index = 0
	while index < len(a:list)
		let value = a:list[index]
		let match = index(a:list, value, index+1)
		if match >= 0
			call remove(a:list, match)
		else
			let index += 1
		endif
		unlet value
	endwhile
	return a:list
endfunction

function! xolox#message(...) " -- show a formatted informational message to the user {{{1
	call s:message('title', a:000)
endfunction

function! xolox#warning(...) " -- show a formatted warning message to the user {{{1
	call s:message('warningmsg', a:000)
endfunction

function! xolox#debug(...) " -- show a formatted debugging message to the user {{{1
  if &vbs >= 1
	  call s:message('question', a:000)
  endif
endfunction

function! s:message(hlgroup, args) " -- implementation of message() and warning() {{{1
  let nargs = len(a:args)
  if nargs == 1
    let message = a:args[0]
  elseif nargs >= 2
    let message = call('printf', a:args)
  endif
  if exists('message')
    try
      " Temporarily disable Vim's |hit-enter| prompt and mode display.
      if !exists('s:more_save')
        let s:more_save = &more
        let s:ruler_save = &ruler
        let s:smd_save = &showmode
      endif
      set nomore noshowmode
      if winnr('$') == 1 | set noruler | endif
      augroup PluginXoloxHideMode
        autocmd! CursorHold,CursorHoldI * call s:clear_message()
      augroup END
	  	execute 'echohl' a:hlgroup
      " Redraw to avoid |hit-enter| prompt.
      redraw | echomsg message
      if g:xolox_message_buffer > 0
        call add(g:xolox_messages, message)
        if len(g:xolox_messages) > g:xolox_message_buffer
          call remove(g:xolox_messages, 0)
        endif
      endif
	  finally
      " Always clear message highlighting -- even when interrupted by Ctrl-C.
  		echohl none
	  endtry
  endif
endfunction

function! s:clear_message()
  echo ''
  let &more = s:more_save
  let &showmode = s:smd_save
  let &ruler = s:ruler_save
  unlet s:more_save s:ruler_save s:smd_save
  autocmd! PluginXoloxHideMode
  augroup! PluginXoloxHideMode
endfunction
