" let me use s instead of c
let g:surround_no_mappings = 1

" original
nmap ds  <Plug>Dsurround
nmap ys  <Plug>Ysurround
nmap yS  <Plug>YSurround
nmap yss <Plug>Yssurround
nmap ySs <Plug>YSsurround
nmap ySS <Plug>YSsurround
xmap S   <Plug>VSurround
xmap gS  <Plug>VgSurround
imap <C-G>s <Plug>Isurround
imap <C-G>S <Plug>ISurround
" mine
xmap c <Plug>VSurround
xmap C <Plug>VSurround
" cs is for cscope
nmap cS <Plug>Csurround
