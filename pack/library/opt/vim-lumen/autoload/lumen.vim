let s:background = ""
let s:exit_code = -1

func lumen#init()
	if !exists('g:lumen_startup_overwrite')
		let g:lumen_startup_overwrite = 1
	endif

	let s:is_nvim = has('nvim')
	if g:lumen_startup_overwrite
		call lumen#oneshot()
	endif

	augroup lumeni
		if v:vim_did_enter
			call lumen#fork_job()
		else
			au VimEnter * call lumen#fork_job()
		endif
	augroup END
endfunc

func lumen#apply_colorscheme()
	" apply colorscheme from g:lumen_light_colorscheme/g:lumen_dark_colorscheme
	let v = get(g:, printf("lumen_%s_colorscheme", s:background), '')
	if len(v) && get(g:, 'colors_name', '') != v
		exe printf("colorscheme %s", v)
	endif
endfunc

func lumen#light_hook()
	if s:background == 'light' && &background == s:background
		return
	endif


	set background=light
	let s:background = &background
	call lumen#apply_colorscheme()
	if exists('#User#LumenLight')
		doautocmd User LumenLight
	endif
endfunc

func lumen#dark_hook()
	if s:background == 'dark' && &background == s:background
		return
	endif


	set background=dark
	let s:background = &background
	call lumen#apply_colorscheme()
	if exists('#User#LumenDark')
		doautocmd User LumenDark
	endif
endfunc

func lumen#oneshot()
	call lumen#platforms#call("oneshot")
endfunc

func lumen#parse_output(line)
	call lumen#platforms#call("parse_line", [a:line])
endfunc

func lumen#on_stdout(chan_id, data, name)
	let s:lines[-1] .= a:data[0]
	call extend(s:lines, a:data[1:])
	while len(s:lines) > 1
		let line = remove(s:lines, 0)
		call lumen#parse_output(line)
	endwhile
endfunc

func lumen#out_cb(channel, msg)
	call lumen#parse_output(a:msg)
endfunc

func lumen#on_stderr(chan_id, data, name)
	let s:elines[-1] .= a:data[0]
	call extend(s:elines, a:data[1:])
	while len(s:elines) > 1
		let line = remove(s:elines, 0)
		call lumen#debug#log_err(line)
	endwhile
endfunc

func lumen#err_cb(channel, msg)
	call lumen#debug#log_err(a:msg)
endfunc

func lumen#on_exit(job, code, t)
	let s:exit_code = a:code
endfunc

func lumen#exit_cb(job, code)
	let s:exit_code = a:code
endfunc

func lumen#fork_job()
	au! lumeni

	let command = lumen#platforms#call("watch_cmd")
	if empty(command)
		return
	endif

	if s:is_nvim
		let s:lines = ['']
		let s:elines = ['']
		let options = #{on_stdout: function('lumen#on_stdout'), on_stderr: function('lumen#on_stderr'), on_exit: function('lumen#on_exit')}
		silent! let s:job = jobstart(command, options)
		if s:job == 0 || s:job == -1
			call lumen#debug#log_err('jobstart() failed: ' . v:errmsg)
			call lumen#on_exit(0, 256 - s:job, 0)
		endif
	else
		let options = #{out_cb: function('lumen#out_cb'), err_cb: function('lumen#err_cb'), exit_cb: function('lumen#exit_cb')}
		let s:job = job_start(command, options)
	endif
endfunc

func lumen#job_state()
	let res = ""
	if s:is_nvim
		let pid = 0
		if s:exit_code < 0
			let pid = jobpid(s:job)
		endif
		let res = pid ? "run as PID " . pid : "dead"
	else
		let res = job_status(s:job)
	endif
	if s:exit_code > -1
		let res .= printf(" (exit code %d)", s:exit_code)
	endif

	return res
endfunc
