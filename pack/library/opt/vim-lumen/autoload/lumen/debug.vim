let s:stderr = []

func lumen#debug#info()
	let job_state = lumen#job_state()
	let platform = lumen#platforms#platform()
	return {'platform': platform, 'job_state': job_state, 'job_errors': s:stderr, 'shell': &shell}
endfunc

func lumen#debug#log_err(line)
	call add(s:stderr, a:line)
endfunc
