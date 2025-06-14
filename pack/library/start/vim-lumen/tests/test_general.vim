let s:socket = "/tmp/socket"

func SetUp()
	" init plugin manually, because VimEnter is not triggered
	call lumen#init()
	call lumen#fork_job()
	" init fake gdbus
	call Change_system_dark_mode(0)
endfunc

func Test_loaded()
	call assert_equal(1, g:loaded_lumen)
endfunc

func Change_system_dark_mode(value)
	call writefile([a:value], s:socket)
	sleep 200m
endfunc

func Test_job_runs()
	let job = lumen#debug#info()
	" background job is still running
	call assert_match("^run", job.job_state)
	" no errors
	call assert_true(job.job_errors->empty(), job.job_errors)
endfunc

func Test_changes()
	" light mode
	call Change_system_dark_mode(2)
	call assert_equal("light", &background)

	" dark mode
	call Change_system_dark_mode(1)
	call assert_equal("dark", &background)
endfunc

func Test_autocmds()
	call Change_system_dark_mode(1)
	let g:test_var = 0
	let g:light_count = 0
	let g:dark_count = 0

	" Make sure that the correct autocommands are triggered
	au User LumenLight let g:light_count += 1
	au User LumenDark let g:dark_count += 1

	au User LumenLight let g:test_var = 2
	call Change_system_dark_mode(2)
	call assert_equal(2, g:test_var)
	call assert_equal(1, g:light_count)
	call assert_equal(0, g:dark_count)

	au User LumenDark let g:test_var = 1
	call Change_system_dark_mode(1)
	call assert_equal(1, g:test_var)
	call assert_equal(1, g:light_count)
	call assert_equal(1, g:dark_count)

	au! User LumenLight
	au! User LumenDark
endfunc

func Test_duplicate_hooks()
	call Change_system_dark_mode(1)
	let g:light_count = 0
	let g:dark_count = 0
	" if two light (or two dark) hooks follow
	" without a dark hook (light hook respectively) inbetween,
	" then the User autocommands should only be triggered once
	au User LumenLight let g:light_count += 1
	au User LumenDark let g:dark_count += 1

	call Change_system_dark_mode(1)
	call assert_equal(0, g:light_count)
	call assert_equal(0, g:dark_count)

	call Change_system_dark_mode(2)
	call assert_equal(1, g:light_count)
	call assert_equal(0, g:dark_count)

	call Change_system_dark_mode(2)
	" doesn't trigger again
	call assert_equal(1, g:light_count)
	call assert_equal(0, g:dark_count)

	call Change_system_dark_mode(2)
	call assert_equal(1, g:light_count)
	call assert_equal(0, g:dark_count)

	call Change_system_dark_mode(1)
	call assert_equal(1, g:light_count)
	call assert_equal(1, g:dark_count)

	call Change_system_dark_mode(1)
	call assert_equal(1, g:light_count)
	call assert_equal(1, g:dark_count)

	call Change_system_dark_mode(2)
	call assert_equal(2, g:light_count)
	call assert_equal(1, g:dark_count)

	call Change_system_dark_mode(1)
	call assert_equal(2, g:light_count)
	call assert_equal(2, g:dark_count)

	au! User LumenLight
	au! User LumenDark
endfunc
