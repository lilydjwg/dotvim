hi link deniteMatchedChar IncSearch
hi link deniteMatchedRange IncSearch

nmap <M-d>f :Denite file_rec -path=
nmap <M-d>l :DeniteBufferDir file_rec<CR>
nmap <M-d>b :Denite buffer<CR>
nmap <M-d>m :Denite file_mru<CR>
nmap <M-d>: :Denite command_history<CR>
nmap <M-d>r :Denite register<CR>

if executable('rg')
  call denite#custom#var('file_rec', 'command', ['rg', '--files', '--glob', '!.git', ''])
endif

call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
