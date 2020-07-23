function! MyAleStatus()
  " if ale#engine#IsCheckingBuffer(bufnr('')) == 1
  "   return '…'
  " endif

  if getbufvar(bufnr(''), 'ale_linted', 0) == 0
    return ''
  endif

  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? '✓' : printf(
        \   'E:%d W:%d',
        \   all_errors,
        \   all_non_errors,
        \ )
endfunction

let &statusline = substitute(&statusline, '%=', '%{MyAleStatus()}&', '')

let g:ale_linters = {
      \   'python': ['pyflakes'],
      \ }

let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
