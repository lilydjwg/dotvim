if exists(':packadd') && executable("tern")
  let g:tern#command = ['tern', '--no-port-file']
  packadd tern_for_vim
endif
