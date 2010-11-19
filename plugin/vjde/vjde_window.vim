
if exists('g:vjde_window_loaded')
	finish
endif
if !exists('g:vjde_loaded') || &cp
		finish
endif

let g:vjde_window_loaded = 1
if !exists('g:vjde_window_svr_cmd')
	if has('win32') && has('gui_running')
		let g:vjde_window_svr_cmd='!start gvim --servername VJDEWINDOW '
	else
		let g:vjde_window_svr_cmd=''
	endif
endif
"let g:vjde_window_svr_cmd='!start gvim --servername VJDEWINDOW '
if strlen(g:vjde_window_svr_cmd)==0
	finish
endif
func! s:VjdeRemoteN(str)
	let md = remote_expr("VJDEWINDOW","mode()")
	if ( md[0] == 'n')
		call remote_send("VJDEWINDOW",':'.a:str."<cr><cr>")
	endif
endf
func! VjdeWindowInit()
	setlocal pvw
	setlocal buftype=nofile
	setlocal nobuflisted
	setlocal ft=preview
endf
func! VjdeWindowOpen()
	let svrs = serverlist()
		if stridx(svrs,"VJDEWINDOW") >=0 
			return
		endif
	exec 'silent '.g:vjde_window_svr_cmd
	sleep 1
	call s:VjdeRemoteN("call VjdeWindowInit()")
endf
func! VjdeWindowCloseImpl()
	exec ":qa!"
endf
func! VjdeWindowClearImpl()
	exec "normal gg"
	exec "normal ".line('$').'D'
endf
func! VjdeWindowAddImpl(str)
	call append(line('$'),split(a:str,"\n"))
endf
func! VjdeWindowClear()
	call VjdeWindowOpen()
	call s:VjdeRemoteN("call VjdeWindowClearImpl()")
endf
func! VjdeWindowAdd(str)
	call VjdeWindowOpen()
	let idx = 0
	let len = strlen(a:str)
	let str=''
	while idx < len
		if a:str[idx]=='\'
			let str=str.'\\'
		elseif a:str[idx]=='"'
			let str=str.'\"'
		elseif a:str[idx]=="\n"
			let str=str."\\n"
		else
			let str=str.a:str[idx]
		endif
		let idx = idx +1
	endwhile
	"call confirm("call VjdeWindowAddImpl(\"".str."\")")
	call s:VjdeRemoteN("call VjdeWindowAddImpl(\"".str."\")")
endf

func! VjdeWindowClose()
	call VjdeWindowOpen()
	call s:VjdeRemoteN("call VjdeWindowCloseImpl()")
endf
