function Lilydjwg_tryswitch(dir)
  let pat = Lilydjwg_get_pattern_at_cursor('[+-]\?\d\+')
  if pat
    if a:dir ==? 'x'
      return "\<C-X>"
    else
      return "\<C-A>"
    end
  else
    if a:dir == 'x'
      return ":\<C-U>SwitchReverse\<CR>"
    else
      return ":\<C-U>Switch\<CR>"
    endif
  end
endfunction

nnoremap <expr> <silent> <C-X> Lilydjwg_tryswitch('x')
vnoremap <expr> <silent> <C-X> Lilydjwg_tryswitch('x')
nnoremap <expr> <silent> <C-A> Lilydjwg_tryswitch('a')
vnoremap <expr> <silent> <C-A> Lilydjwg_tryswitch('a')
