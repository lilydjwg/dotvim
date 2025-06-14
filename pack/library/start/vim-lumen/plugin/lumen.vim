if exists('g:loaded_lumen') || !(has('nvim') || has('job'))
	finish
endif
let g:loaded_lumen = 1

call lumen#init()
