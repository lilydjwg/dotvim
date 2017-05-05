hi link deniteMatchedChar IncSearch
hi link deniteMatchedRange IncSearch

function! s:denite_with_path()
  let path = input('path: ', '', 'dir')
  exec "Denite file_rec -path=" . path
endfunction

nmap <M-d>f :call <SID>denite_with_path()<CR>
nmap <M-d>L :DeniteBufferDir file_rec<CR>
nmap <M-d>l :Denite line<CR>
nmap <M-d>b :Denite buffer<CR>
nmap <M-d>m :Denite file_mru<CR>
nmap <M-d>: :Denite command_history<CR>
nmap <M-d>r :Denite register<CR>

if executable('rg')
  call denite#custom#var('file_rec', 'command', ['rg', '--files', '--glob', '!.git', ''])
endif

call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
