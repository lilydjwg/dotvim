if has("gui_running")
  finish
endif

let g:togglecursor_insert = 'line'

if $TERM_PROGRAM == "Konsole" || exists("$KONSOLE_DBUS_SESSION")
  let g:togglecursor_force = 'cursorshape'
else
  let g:togglecursor_force = 'xterm'
endif
