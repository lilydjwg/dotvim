autocmd! BufWritePost * Neomake
let g:neomake_error_sign = { 'text': ">>", 'texthl': 'ErrorMsg' }
let g:neomake_warning_sign = { 'text': ">>", 'texthl': 'WarningMsg' }
let g:neomake_info_sign = { 'text': "->", 'texthl': 'Normal' }
let g:neomake_message_sign = { 'text': "->", 'texthl': 'Normal' }

let g:neomake_python_enabled_makers = ['python']
