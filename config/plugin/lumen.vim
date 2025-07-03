if $WAYLAND_DISPLAY == '' && $DISPLAY == ''
  finish
endif

function s:Colorscheme(name)
  exec 'colorscheme' a:name
  exec 'doautocmd ColorScheme' a:name
endfunction

au User LumenLight call s:Colorscheme('pink_lily')
au User LumenDark call s:Colorscheme('lilypink')

packadd vim-lumen
