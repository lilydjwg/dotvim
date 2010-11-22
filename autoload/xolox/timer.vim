" Vim script
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: June 16, 2010
" URL: http://peterodding.com/code/vim/profile/autoload/xolox/timer.vim

if !exists('g:timer_enabled')
  let g:timer_enabled = 0
endif

if !exists('g:timer_verbosity')
  let g:timer_verbosity = 1
endif

let s:has_reltime = has('reltime')

function! xolox#timer#start()
  if g:timer_enabled || &verbose >= g:timer_verbosity
    return s:has_reltime ? reltime() : [localtime()]
  endif
  return []
endfunction

function! xolox#timer#stop(...)
  if (g:timer_enabled || &verbose >= g:timer_verbosity)
    call call('xolox#message', map(copy(a:000), 's:convert_value(v:val)'))
  endif
endfunction

function! s:convert_value(value)
  if type(a:value) != type([])
    return a:value
  elseif !empty(a:value)
    if s:has_reltime
      let ts = xolox#trim(reltimestr(reltime(a:value)))
    else
      let ts = localtime() - a:value[0]
    endif
    return xolox#timer#format_timespan(ts)
  else
    return '?'
  endif
endfunction

function! xolox#timer#format_timespan(ts)

  " Convert timespan to integer.
  let seconds = a:ts + 0

  " Fast common case with extra precision from reltime().
  if seconds < 5
    let extract = matchstr(a:ts, '^\d\+\(\.0*[123456789][123456789]\?\)\?')
    if extract =~ '[123456789]'
      return extract . ' second' . (extract != '1' ? 's' : '')
    endif
  endif

  " Generic but slow code.
  let result = []
  for [name, size] in s:units
    if seconds >= size
      let counter = seconds / size
      let seconds = seconds % size
      let suffix = counter != 1 ? 's' : ''
      call add(result, printf('%i %s%s', counter, name, suffix))
    endif
  endfor

  " Format the resulting text?
  if len(result) == 1
    return result[0]
  else
    return join(result[0:-2], ', ') . ' and ' . result[-1]
  endif

endfunction

let s:units = [['day', 60 * 60 * 24], ['hour', 60 * 60], ['minute', 60], ['second', 1]]

" vim: ts=2 sw=2 et
