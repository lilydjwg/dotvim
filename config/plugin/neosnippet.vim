" disable warning
let g:neosnippet#disable_runtime_snippets = {
      \   '_' : 1,
      \ }

let g:neosnippet#snippets_directory = g:vimfiles . '/snippets'
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \: "\<TAB>"

function s:open_snippets(ft)
  let d = g:neosnippet#snippets_directory
  if a:ft == ''
    exe 'tabe '.d.'/'.&ft.'.snip'
  else
    exe 'tabe '.d.'/'.a:ft.'.snip'
  endif
endfunction

command -nargs=? Snippets silent call s:open_snippets("<args>")
