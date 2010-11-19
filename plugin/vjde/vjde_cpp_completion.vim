"{{{1
if !has('ruby')
	"echo 'C++ completion is ruby required!!'
	"finish
endif
if !exists('g:vjde_loaded') || &cp
	finish
endif


runtime plugin/vjde/vjde_preview.vim

let g:vjde_cpp_previewer= VjdePreviewWindow_New()

if !exists('g:vjde_cpp_exts')
	let g:vjde_cpp_exts='cpp;c;cxx;h;hpp;hh'
endif
if !exists('g:vjde_gtk_doc_path')
	if has('win32')
		let g:vjde_gtk_doc_path='d:/gtk/share/gtk-doc/html'
	else
		let g:vjde_gtk_doc_path='/usr/share/gtk-doc/html'
	endif
endif
let s:types=[]
let g:vjde_cpp_previewer.name = 'g:vjde_cpp_previewer'
let g:vjde_cpp_previewer.onSelect='VjdeInsertWord'
let g:vjde_cpp_previewer.previewLinesFun='GetCTAGSCompletionLines'
let g:vjde_cpp_previewer.docLineFun='VjdeGetCppDocLine'
func! VjdeGetCppDocLine()
	if !g:wspawn_available || strlen(g:vjde_gtk_doc_path)==0
		return "\n"
	endif
	let docpath = g:vjde_gtk_doc_path
	let str = g:vjde_doc_gui_width.';'.g:vjde_doc_gui_height.';'
	let str = str.g:vjde_doc_delay.';'
	let str = str.'ruby '.substitute(g:vjde_install_path,'\','/','g').'/vjde/vjde_cpp_doc_reader.rb '.docpath.' '
	return str.";\n"
endf
func! VjdeGetCppType(v)
	let lnr = line('.')
	let cnr = col('.')
	"let pattern='\<\i\+\>\(\s*<.*>\)*\(\s*\[.*\]\)*[* \t]\+\<'.a:v.'\>'
	"let pattern='\(\<\i\+\>\(\s*<.*>\s*\)*::\)*\<\(new\|delete\|return\)\@!\(\i\+\)\>\(\s*<.*>\s*\)*\(\[.*\]\)*\([ \t*]*\|[&]\?\)\<'.a:v.'\>'
	let pattern='\(\<\i\+\>\(\s*<.*>\s*\)*::\)*\<\(new\|delete\|return\)\@!\(\i\+\)\>\(\s*<.*>\s*\)*\(\[.*\]\)*\([ \t*]*\|[&]\?[ \t]\+[&]\?\)\<'.a:v.'\>'
	let pos = VjdeGotoDefPos(pattern,'b')
	if pos[0]==0
		call cursor(lnr,cnr)
		return a:v
	endif
	let lstr = getline(pos[0])
	let lend = match(lstr,'[*& \t]\+\<'.a:v.'\>',pos[1])
	let vt = strpart(lstr,pos[1]-1,lend-pos[1]+1)
	call cursor(lnr,cnr)
	while ( stridx(vt,'<')>0) 
		let len = strlen(vt)
		let vt=substitute(vt,'<[^<>]*>','','g')
		if len == strlen(vt) 
			break
		endif
	endwhile
	return vt
endf
func! VjdeCppObjectSplit(lstr)
	let lstr = a:lstr
	let lstr = substitute(lstr,'::','..','g')
	let lstr = substitute(lstr,'->','...','g')
	"let lstr = substitute(lstr,'<','.....','g')
	"let lstr = substitute(lstr,'>','......','g')
	let index0 = stridx(lstr,'"')
	let index1 = index0
	let str2 = ''
	let lastnr = -1
	while index1 > -1 && index0> -1
		let index1 = SkipToIgnoreString(lstr,index0+1,'"')
		if index1 > index0
			let str2.=strpart(lstr,lastnr,index0-lastnr)
			let index0 = index1
			let lastnr = index1
		else
			break
		endif
	endw
	let str2 .= strpart(lstr,lastnr+1)
	let len = -1
	while len!=strlen(str2)
		let len = strlen(str2)
		let str2=substitute(str2,'<[^<>]*>','','g')
	endwh
	let lstr = VjdeFormatLine(str2)
	let lstr = substitute(lstr,'\([^.]\)\.\.\([^.]\)','\1::\2','g')
	let header = matchstr(lstr,'^\s*\(\<\i\+\>\(\s*<.*>\)*::\)*')
	let s:types=VjdeObejectSplit(strpart(lstr,strlen(header)))
	if strlen(header)>0
		let header = substitute(header,'^\s*','','')
		while ( stridx(header,'<')>0) 
			let len = strlen(header)
			let header=substitute(header,'<[^<>]*>','','g')
			if len == strlen(header) 
				break
			endif
		endwhile
		if strlen(header)>2
			if len(s:types)>0
				let s:types[0]=header.s:types[0]
			else
				call add(s:types,header[0:-3])
			endif
		endif
	endif
	return s:types
endf
func! VjdeCppCFU0(findstart,base) 
	return VjdeCppCFU(getline('.'),a:base,col('.'),a:findstart)
endf
func! VjdeCppCFU(line,base,col,findstart) "{{{2
    if a:findstart
        let s:last_start  = VjdeFindStart(a:line,a:base,a:col,'[.> \t:?)(+\-*/&|^,]')
	return s:last_start
    endif
    let lstr = strpart(a:line,0,a:col)
    " call the parameter info
    if a:line[s:last_start-1]=='(' && (s:last_start == a:col)
	    let s:types=VjdeCppObjectSplit(lstr[0:-2].'.')
	    if len(s:types)==1
		    return CtagsCompletion(s:types[0],1)
	    elseif len(s:types)>1
		    let vt = VjdeGetCppType(s:types[0])
		    return CtagsCompletion2(vt,s:types[-1],1)
	    end
	    return ""
    endif
    let s:types=VjdeCppObjectSplit(lstr)
    if len(s:types)==0  " completion for global functions
	    return CtagsCompletion(a:base)
    endif
    let v = s:types[0]
    " std:: string::
    if a:line[s:last_start-1]==':' 
	    return CtagsCompletion2(v,a:base)
    endif
    let vt = VjdeGetCppType(v)
    return CtagsCompletion2(vt,a:base)
    "if strlen(header)>0
	    "return CtagsCompletion2(header.v,a:base)
    "else
	    "if ( strlen(vt)>0)
	    "endif
    "endif
endf
func! VjdeCppCompletion(char,short)
    let lstr = getline(line('.'))
    let cnr = col('.')
    let Cfu=function(&cfu)
    let s:last_start  = Cfu(1,'')
    if s:last_start < 0
	    return
    endif

    if lstr[s:last_start-1]=='('
	    let mstr = Cfu(0,strpart(lstr,s:last_start,cnr-s:last_start))
	    if type(mstr)==1 "String
		    if mstr == ''
			    return ''
		    endif
	    else
		    if len(mstr) < 1
			    return ''
		    endif
	    endif
	    let str = ''
	    let items = VjdeGetCppCFUTags()
	    for item in items
		    let str.=item.word."\n"
	    endfor
	    call g:vjde_cpp_previewer.PreviewInfo(str)
	    return mstr
    endif
    call g:vjde_cpp_previewer.CFU(a:char,a:short)
endf

func! VjdeCppGenerateIdx(...)
	let mtags = &tags
	let len = 2
	if ( a:0 > 0)
		let len = a:1
	endif
	for item in split(mtags,",")
ruby<<EOF
	Vjde.generateIndex(VIM::evaluate("item"),VIM::evaluate("len").to_i)
EOF
	endfor
endf
"{{{ auto command 
for item in split(g:vjde_cpp_exts,';')
	if strlen(item)>0
		exec 'au BufNewFile,BufRead,BufEnter *.'.item.' set cfu=VjdeCppCFU0'
		exec 'au BufNewFile,BufRead,BufEnter *.'.item.' imap <buffer> '.g:vjde_completion_key.' <Esc>:call VjdeCppCompletion("<C-space>",0)<CR>a'
	endif
endfor


"vim:fdm=marker:ff=unix
