if exists('g:vjde_preview_loaded')
	finish
endif

if !exists('g:vjde_loaded') || &cp
		finish
endif
let g:vjde_preview_loaded=1
"{{{1 
if !exists('g:vjde_show_preview')
    let g:vjde_show_preview=1
endif
if !exists('g:vjde_preview_gui')
	let g:vjde_preview_gui = 0
endif
if !exists('g:vjde_preview_gui_width')
	let g:vjde_preview_gui_width = 350
endif
if !exists('g:vjde_preview_gui_height')
	let g:vjde_preview_gui_height= 170 
endif
if !exists('g:vjde_doc_gui_width')
	let g:vjde_doc_gui_width = 350
endif
if !exists('g:vjde_doc_gui_height')
	let g:vjde_doc_gui_height= 170 
endif
if !exists('g:vjde_doc_delay')
	let g:vjde_doc_delay= 2000 
endif

if !exists('g:vjde_javadoc_path')
	let g:vjde_javadoc_path ='.'
endif

func! VjdePreviewCFU(char,...) dict "{{{2 
	if strlen(&cfu)<=0
		return 
	endif
	let useshort = 0
	if ( a:0 > 0)
		let useshort = a:1
	endif
	let Cfufun = function(&cfu)
	let show_prev_old = g:vjde_show_preview
	let g:vjde_show_preview=1
	let linestr= getline(line('.'))
	let cnr = col('.')
	let s = Cfufun(1,'')
	let mretstr=Cfufun(0,strpart(linestr,s,cnr-s))
	let g:vjde_show_preview=show_prev_old

    if ( !empty(self.preview_buffer))
	    call remove(self.preview_buffer,0,-1)
    endif
        if len(mretstr)!=0
	    if strlen(self.previewLinesFun)>0 
		    let FunGetLines = function(self.previewLinesFun)
		    call FunGetLines(self)
	    endif
	    let self.base =strpart(linestr,s,cnr-s)
	    call self.Preview(useshort)
        endif
endf "}}}2
func! VjdeShowJavadoc() "{{{2 remove
	if !has('ruby')
		return
	endif
    if bufname("%")!="Vjde_preview"
	    return
    endif
    let lnr = line('.')
    if lnr < 2
	    return
    endif
    let fname=g:vjde_javadoc_path.substitute(substitute(getline(1),'^\([^:]\+\):.*$','\1',''),'\.','/','g').'.html'
    let funname=substitute(getline(lnr),'^[^ \t]\+\s\([^)]\+[)]\|[^(;]\+\).*$','\1','')
ruby<<EOF
lnr = VIM::evaluate("lnr").to_i
$vjde_doc_reader.read(VIM::evaluate("fname"),VIM::evaluate("funname"))
VIM::Buffer.current.append(lnr,"**")
lnr += 1
$vjde_doc_reader.to_text_arr.each { |l|
	l[-1]=''
	VIM::Buffer.current.append(lnr," * #{l}")
	lnr +=1
}
VIM::Buffer.current.append(lnr," *")
EOF
endf "}}}2
func! VjdeGetCaretPos() "{{{2 
	let cols = wincol()
	let lines = winline()
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
	if wcount >0
		exec wcount.'wincmd l'
	endif
	
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
	if wcount > 0
		exec wcount.'wincmd j'
	endif
	exec 'set ei='.oei
	return [cols,lines]
endf "}}}2

func! VjdePreviewSelect2(d,k)  "{{{2 remove
	let d1 = a:d
	let clnr = line('.')
	let word = d1.key_preview
	if a:k !="\n" 
		"let clnr = search('^[^ \t]\+\s\([^(;]\+\)[(;].*$','')
		let clnr = search('^[^ \t]\+\s\('.d1.base.word.'[^(;]*\)[(;].*$','')
	endif
	if clnr>1
		let cstr = getline(clnr)
		let word = substitute(cstr,'^[^ \t]\+\s\([^(;]\+\)[(;].*$','\1','')
		let word = strpart(word,strlen(d1.base))
	endif
        match none
	silent! wincmd k
    let nr = winnr()
	if strlen( d1.onSelect ) > 0 
		let SelectFun = function(d1.onSelect)
		call SelectFun(word)
	endif
	silent wincmd P
	q!
	exec nr.'wincmd w'
    "if nr != winnr()
        "silent! wincmd k
    "endif
	"call s:VjdeInsertWord(word)
endf "}}}2

func! VjdePreviewKeyPress2(d,k)  "{{{2 remove
	let d1 = a:d
	if a:k != "Backspace"
		let d1.key_preview .= a:k
	elseif strlen(d1.key_preview)>0
		let d1.key_preview = strpart(d1.key_preview,0,strlen(d1.key_preview)-1)
	endif
	call d1.Update(d1.base.d1.key_preview)
endf "}}}2
func! VjdePreviewWindowInit() dict "{{{2 
	setlocal pvw
	setlocal buftype=nofile
	setlocal nobuflisted
	setlocal ft=preview
	let chars= self.input_chars
	let start=strlen(chars)
	while start>0
		let var = chars[start-1]
		exec 'inoremap <buffer> '.var.' <Esc>:call VjdePreviewKeyPress2('.self.name.',"'.var.'")<cr>a'
		let start -= 1
	endwhile
	exec 'inoremap <buffer> <Backspace> <Esc>:call VjdePreviewKeyPress2('.self.name.',"Backspace")<cr>a'
	exec 'inoremap <buffer> <Space> <Esc>:call VjdePreviewSelect2('.self.name.'," ")<cr>a'
	exec 'inoremap <buffer> <cr> <Esc>:call VjdePreviewSelect2('.self.name.',"\n")<cr>a'
	exec 'inoremap <buffer> ( <Esc>:call VjdePreviewSelect2('.self.name.',"(")<cr>a('
	exec 'inoremap <buffer> [ <Esc>:call VjdePreviewSelect2('.self.name.',"[")<cr>a['
	exec 'inoremap <buffer> ; <Esc>:call VjdePreviewSelect2('.self.name.',";")<cr>a;'
	exec 'inoremap <buffer> ? <Esc>:call VjdePreviewSelect2('.self.name.',"?")<cr>a?'
	"inoremap <buffer> : <Esc>:call VjdePreviewSelect(':')<cr>a:
	exec 'inoremap <buffer> " <Esc>:call VjdePreviewSelect2('.self.name.',"\"")<cr>a"'
	exec 'inoremap <buffer> <C-CR> <Esc>:call VjdePreviewSelect2('.self.name.',"C-CR")<cr>a'
	inoremap <buffer> <M-d> <Esc>:call VjdeShowJavadoc()<cr>a

	exec 'nnoremap <buffer> <Space> :call VjdePreviewSelect2('.self.name.'," ")<cr>a'
	exec 'nnoremap <buffer> <cr> :call VjdePreviewSelect2('.self.name.',"\n")<cr>a'
	exec 'nnoremap <buffer> <C-CR> :call VjdePreviewSelect2('.self.name.',"C-CR")<cr>a'
	nnoremap <buffer> <M-d> :call VjdeShowJavadoc()<cr>
	exec 'nnoremap <buffer> <Backspace> :call VjdePreviewKeyPress2('.self.name.',"Backspace")<cr>'
	au CursorHold <buffer> call VjdeShowJavadoc()
	hi def link User1 Tag
endf
func! VjdePreviewWindowGetBuffer() dict "{{{2 VjdeGetPreviewWindowBuffer
	let l:b_n = -1
	if &pvw
		let l:b_n = bufnr("%")
		if bufname("%")!= 'Vjde_preview'
			let l:b_n = -1
		end
		return  l:b_n
	end
	silent! wincmd P
	if !&pvw
		exec 'silent! bel '.&pvh.'sp Vjde_preview'
		call self.Init()
		let l:b_n = bufnr("%")
		"setlocal noma
	else
		let l:b_n = bufnr("%")
		if bufname("%")!= 'Vjde_preview'
			let l:b_n = -1
		end
	end
	silent! wincmd k
	return l:b_n
endf "}}}2
"{{{2 VjdeCallPreviewWindow
func! VjdePreviewWindow_Preview(useshort) dict 

    if len(self.preview_buffer) < 2
	    return
    endif
    if len(self.preview_buffer)==2  " only one 
	    let mretstr = self.preview_buffer[1]
	    let word = substitute(mretstr,'^[^ \t]\+\s\([^(;]\+\)[(;].*$','\1','')
	    if strlen(self.onSelect)>0
		    let SelectFun = function(self.onSelect)
		    call SelectFun(strpart(word,strlen(self.base)))
	    endif
	    return
    endif
    if g:vjde_preview_gui && g:vjde_preview_lib!=''
	    let word = self.PreviewGUI(a:useshort)
	    if strlen(word)>0
		    if strlen(self.onSelect)>0
			    let SelectFun = function(self.onSelect)
			    call SelectFun(strpart(word,strlen(self.base)))
		    endif
	    endif
    else
	    let self.key_preview=''
	    call self.Update(self.base)
	    call self.GetBuffer()
	    wincmd P
	    if &pvw
		    let self.key_preview=''
		    exec 'silent! normal $'
	    endif
    endif
endf
"{{{2 preview in gui
func! VjdePreviewWindow_PreviewInfo(data) dict
	let pos = VjdeGetCaretPos()
	let x = pos[0]
	let y = pos[1]
	let tw = &columns
	let th = &lines
	let width=g:vjde_preview_gui_width
	let height= g:vjde_preview_gui_height
	let cmdline = y.';'.x.';'.tw.";".th.";".width.';'.height.';'
	let cmdline .= getwinposx().';'.getwinposy().";\n"
	let data = a:data
	if g:vjde_preview_gui && g:vjde_preview_lib!=''
		return libcallnr(g:vjde_preview_lib,'_Z11informationPc',cmdline.data)
	else
		if ( !empty(self.preview_buffer))
			call remove(self.preview_buffer,0,-1)
		endif
		call add(self.preview_buffer,'information:')
		let self.preview_buffer+= split(data,"\n")
		call self.Update('')
		call self.GetBuffer()

		"wincmd P
		"if &pvw
			"let self.key_preview=''
			"exec 'silent! normal $'
		"endif
	endif
endf
func! VjdePreviewWindow_PreviewGUI(useshort) dict 
	if len(self.preview_buffer)==0
		return ''
	endif

	let doc_line = "\n"
	if strlen(self.docLineFun)>0 
		let LineFun = function(self.docLineFun)
		let doc_line = LineFun()
	endif


	let pos = VjdeGetCaretPos()
	let x = pos[0]
	let y = pos[1]
	let tw = &columns
	let th = &lines
	let width=g:vjde_preview_gui_width
	let height= g:vjde_preview_gui_height
	let str = join(self.preview_buffer,"\n")
	let cmdline = y.';'.x.';'.tw.";".th.";".width.';'.height.';'
	let cmdline .= getwinposx().';'.getwinposy().';'
	let cmdline .= a:useshort.';'.self.base.";\n"
	let cmdline .= doc_line
	let cstr = libcall(g:vjde_preview_lib,'_Z7previewPc',cmdline.str)
	let cstr = substitute(cstr,'\([^(;]\+\)[(;].*$','\1','')
	return cstr
endf

func! VjdePreviewUpdate(base) dict "{{{2 
	call self.BufferUpdate(a:base)
endf
"a:1 beforeenter a:2 afterenter a:3 beforeleave a:4 afterleave
func! VjdePreviewBufferUpdate(base,...)  dict "{{{2
    if len(self.preview_buffer)==0
	return 
    endif
    let prenr = self.GetBuffer()
    let thesame = 1
    if prenr ==-1
        return
    endif
    if prenr != bufnr("%")
        if a:0>=1 && type(a:1)==2 
            call a:1()
        endif
        silent! wincmd P
        if a:0>=2 && type(a:2)==2 
            call a:2()
        endif
	let thesame = 0
    endif
    exec '1,$d'
    exec 'setlocal statusline=%t\ %w\ :%1*'.substitute(a:base,'%','%%','').'\|%0*'
    if ( prenr == bufnr("%"))
        if strlen(a:base)>0 
            call append(1,filter(copy(self.preview_buffer),'v:val =~ ''^[^ \t]\+\s'.a:base.'.*$'''))
            exec 'match Tag /\s'.a:base.'/' 
        else 
            call append(0,self.preview_buffer)
            match none
        end
        call setline(1,self.preview_buffer[0].a:base)
    endif
    call cursor(1,col('$'))
    if !thesame
        if a:0>=3 && type(a:3)==2 
            call a:3()
        endif
        silent! wincmd k
        if a:0>=4 && type(a:4)==2 
            call a:4()
        endif
    endif
endf
func! VjdePreviewAdd(str) dict "{{{2
	call add(self.preview_buffer,a:str)
endf
func! VjdePreviewClear() dict "{{{2
	let self.preview_buffer=[]
endf
func! VjdePreviewGet() dict "{{{2
	return self.preview_buffer
endf
"{{{2 create a preview window
func! VjdePreviewWindow_New()
	return {'base':'' ,
		\ 'preview_buffer' : [],
		\ 'key_preview':'',
		\ 'name':'',
		\ 'input_chars' : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._:%@!',
		\ 'Preview':function('VjdePreviewWindow_Preview'),
		\ 'PreviewInfo':function('VjdePreviewWindow_PreviewInfo'),
		\ 'PreviewGUI':function('VjdePreviewWindow_PreviewGUI'),
		\ 'Update' :function('VjdePreviewUpdate'),
		\ 'BufferUpdate' :function('VjdePreviewBufferUpdate'),
		\ 'Add' :function('VjdePreviewAdd'),
		\ 'Get' :function('VjdePreviewGet'),
		\ 'Clear' :function('VjdePreviewClear'),
		\ 'GetBuffer':function('VjdePreviewWindowGetBuffer'),
		\ 'Init':function('VjdePreviewWindowInit'),
		\ 'CFU':function('VjdePreviewCFU'),
		\ 'previewLinesFun':'',
		\ 'docLineFun':'',
		\ 'onSelect':''}
endf


" vim :ft=vim :fdm=marker:ff=unix
