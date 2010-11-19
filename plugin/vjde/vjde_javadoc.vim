if exists('g:vjde_javadoc_loaded') || &cp
    finish
endif
if !exists('g:vjde_loaded') || &cp
	finish
endif
let g:vjde_javadoc_loaded=1

func! VjdeJavaDoc() 
    if !pumvisible()
        return "\<F1>"
    endif
    call VjdeReadJavaDoc()
    return ''
endf
func! VjdeReadJavaDoc() "{{{2
    if !pumvisible()
        return
    endif
    if &previewwindow
        return
    endif
    if t:vjde_preview_num < 0 
        call confirm('no preview existed')
        return
    endif
    let str2 = g:vjde_java_command.' -cp "'.substitute(g:vjde_install_path,'\','/','g').'/vjde/vjde.jar" vjde.completion.Document '
    if ( strlen(g:vjde_src_path)>0) 
        let str2 = str2.'"'.g:vjde_javadoc_path.'" "'.g:vjde_src_path.'" '
    else
        let str2 = str2.'"'.g:vjde_javadoc_path.'" "./" '

    endif
    let previewlines = getbufline(t:vjde_preview_num,1,'$')
    if len(previewlines)>0
        let lstr = previewlines[0]
        let lstr2 = substitute(lstr,'^[^ ]\+ \([^);]\+[;)]\).*$','\1','')
        let str2 = str2.g:vjde_java_cfu.class.name.' "'.lstr2.'"'
        let res = system(str2)
        if strlen(res) > 20
            call VjdeShowTipsWnd(res)
        endif
    endif
endf
func! VjdeShowTipsWnd(info)
        let pos = VjdeGetCaretPosEx() 
        let posstr = printf("%d;%d;%d;%d;\n",pos[0],pos[1],&lines,&columns)
        call libcallnr(g:vjde_install_path.'/vjde/tipswnd.dll','tipsWnd',posstr.a:info)
endf
let s:m_winnr = -1
let s:left_cols=-1
let s:top_lines=-1
func! VjdeAdjustCaretPos(bforce)
    let cnr = winnr()
    "if  s:m_winnr != cnr || a:bforce
        let s:m_winnr = cnr
        call s:VjdeAdjustTopLeft()
    "endif
endf
func! s:VjdeAdjustTopLeft()
	let cols = 0
	let lines = 0
	let cnr = winnr()

	let oei = &ei
	set ei=WinEnter,WinLeave,BufEnter,BufLeave

	let wcount = 0
	wincmd  h
	let prenr = cnr
	let lastnr = winnr()
	while prenr != lastnr
		let wcount +=1
		let cols += winwidth(0)+1
		let prenr = lastnr
		wincmd h
		let lastnr = winnr()
	endw
	exec cnr.'wincmd w'
	let wcount = 0
	wincmd k
	let prenr = cnr
	let lastnr = winnr()
	while prenr != lastnr
		let wcount +=1
		let lines += winheight(0)+1
		let prenr = lastnr
		wincmd k
		let lastnr = winnr()
	endw
	exec cnr.'wincmd w'
	exec 'set ei='.oei
        let s:left_cols= cols
        let s:top_lines = lines
endf
" 
func VjdeGetCaretPosEx() 
    return [s:top_lines + winline() , s:left_cols+wincol()]
endf

if has('win32') && has('gui_running')
    let t:vjde_preview_num=-1
    au BufWinEnter * if &pvw | let t:vjde_preview_num = bufnr('%') | endif
    au BufWinLeave * if &pvw | let t:vjde_preview_num = -1 | endif
    au BufNewFile,BufRead,BufEnter *.java inoremap <buffer> <expr> <f1> VjdeJavaDoc()
    au! WinEnter * silent call VjdeAdjustCaretPos(1)
endif
