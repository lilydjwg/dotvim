let s:watched_line = "/org/freedesktop/portal/desktop: org.freedesktop.portal.Settings.SettingChanged ('org.freedesktop.appearance', 'color-scheme', <uint32 "

func lumen#platforms#linux#watch_cmd()
	" TODO: Implement our own dbus client to get rid of the gdbus dependency
	" dbus is just communicating with an Unix socket after all
	return "gdbus monitor --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop"->split()
endfunc

func lumen#platforms#linux#parse_line(line)
	if match(a:line, s:watched_line) == 0
		" 0 is ASCII 48
		let val = strgetchar(a:line, strchars(a:line) - 3) - 48
		" 0 = No preference
		" 1 = Prefer Dark
		" 2 = Prefer Light
		if val == 2 || val == 0
			" We have to add this workaround, because Gnome returns 0 (No preference) when the user prefers a light theme
			" Perhaps a g:my_next_de_wont_be_gnome variable should optionally enable this workaround instead
			call lumen#light_hook()
		elseif val == 1
			call lumen#dark_hook()
		endif
	endif
endfunc

func lumen#platforms#linux#oneshot()
	silent let out = trim(system('gdbus call -t 1 --session --dest=org.freedesktop.portal.Desktop --object-path=/org/freedesktop/portal/desktop --method=org.freedesktop.portal.Settings.Read org.freedesktop.appearance color-scheme'))
	if match(out, "(<<uint32 ") == 0
		call lumen#platforms#linux#parse_line(s:watched_line . strcharpart(out, 10, 1) . ">)")
	else
		call lumen#debug#log_err(out)
	endif
endfunc
