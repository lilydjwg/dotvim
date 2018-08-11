call neomake#configure#automake('w')

let g:neomake_error_sign = { 'text': ">>", 'texthl': 'ErrorMsg' }
let g:neomake_warning_sign = { 'text': ">>", 'texthl': 'WarningMsg' }
let g:neomake_info_sign = { 'text': "->", 'texthl': 'Normal' }
let g:neomake_message_sign = { 'text': "->", 'texthl': 'Normal' }

let g:neomake_python_enabled_makers = ['python', 'pyflakes']

" statusline config
" Not using colors because it's extremely complex:
"   we can't easily get the background
"   we can't easily distinguish between current and non-current

function! MyNeomakeStatus()
  let neomake_status_str = neomake#statusline#get(bufnr('%'), {
        \ 'format_running': '…({{running_job_names}})',
        \ 'format_loclist_ok': '✓',
        \ 'format_loclist_type_E': '{{type}}:{{count}}',
        \ 'format_loclist_type_W': '{{type}}:{{count}}',
        \ 'format_loclist_type_I': '{{type}}:{{count}}',
        \ 'format_loclist_issues': '%s',
        \ 'format_quickfix_issues': '%s',
        \ })
  if neomake_status_str == '?'
    return ''
  else
    return neomake_status_str
endfunction

let &statusline = substitute(&statusline, '%=', '%{MyNeomakeStatus()}&', '')
