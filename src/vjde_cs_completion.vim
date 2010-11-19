if !exists('g:vjde_loaded') || &cp
	finish
endif
if !exists('g:vjde_cs_libs')
	let g:vjde_cs_libs=''
	"echo 'Add g:vjde_cs_libs in your _vimrc!'
endif
if !exists('g:vjde_cs_cmd')
	let g:vjde_cs_cmd='mono.exe '.g:vjde_install_path.'/vjde/CSParser.exe'
endif
if !exists('g:vjde_cs_using')
	let g:vjde_cs_using=g:vjde_install_path.'\vjde\UsingFinder.exe'
endif
if !exists('g:vjde_cs_find')
	let g:vjde_cs_find=g:vjde_install_path.'\vjde\TypeFinder.exe'
endif
let g:vjde_cs_cfu={}
let s:vjde_cs_default_types={'context' : 'System.Web.HttpContext' , 'Request' : ' System.Web.HttpRequest' , 'Response' : 'System.Web.HttpResponse'}
let s:types=[]
let s:type=''
let s:success=1
let s:last_start = 0

func! s:VjdeCSGetTypeName(var) 
	if ( 'cs' != expand('%:e'))
		if  has_key(s:vjde_cs_default_types,a:var)
			return s:vjde_cs_default_types[a:var]
		endif
	endif
	let tname = VjdeGetTypeName(a:var)
	if tname=='string'
		return "String"
	endif
	return tname
endf
func! VjdeCSGetUsing() 
	let retstr=''
	let l = line('.')
	let c = col('.')
	let l:line_us = search('^\s*using\s\+','Wb')
	let l:str=''
	let l:cend=0
	while l:line_us > 0 
		let l:str = getline(l:line_us)
		let l:cend = matchend(l:str,'^\s*using\s\+')
		if l:cend != -1
			let retstr = retstr.matchstr(l:str,".*$",l:cend)
		endif
		let l:line_us = search('^\s*using\s\+','Wb')
	endwhile
	call cursor(l,c)
	return retstr
endf
func! VjdeCSCompletion(findstart,base)
	if a:findstart
		let s:last_start=VjdeFindStart(getline('.'),a:base,col('.'),'[.@ \t]')
		return s:last_start
	endif
	let lline = getline('.')
	let l:cend = matchend(lline,'^\s*using\s\+')
	if l:cend != -1
		let lline = matchstr(lline,".*$",l:cend)
		return s:VjdeCsCompletionUsing(lline,a:base)
	endif
	let usingstr = VjdeCSGetUsing().';System.Data;System.Text;System.Web'
	let lline = getline('.')
	let lcol = col('.')
	let s:types = VjdeObejectSplit(VjdeFormatLine(strpart(lline,0,s:last_start)))
	if len(s:types) < 1 
		return ""
	endif
	let s:type=s:VjdeCSGetTypeName(s:types[0])
	if s:type=='' 
		let s:type=s:types[0]
	endif
        let s:beginning = a:base
	call VjdeCSCompletionVIM(usingstr)
	if g:vjde_cs_cfu.success
		return s:VjdeGeneratePerviewMenu(a:base)
	endif
	return ""
endf
func! s:VjdeCsCompletionUsing(l,b)
	let lidx = stridx(a:l,'.')
	let l:ln=''
	"if ( strlen(a:l) > 0)
	"	let l:ln = a:l
	"endif
	"if lidx>0
	"	let l:ln = strpart(a:l,0,lidx)
	"endif
	let cmd = g:vjde_cs_using. ' "'.l:ln.'" "'.g:vjde_cs_libs.'" '
	let str = system(cmd)
	exec 'let arr = '.str
	let res=[]
	for a1 in arr
		if strlen(a1) > lidx
			call add(res,strpart(a1,lidx+1))
		endif
	endfor
	return res
endf
func! VjdeCsFindUsing()
	let l:v_v = expand('<cword>')
        let l:line_imp = search('^\s*using\s\+.*\s*;','nb')
	if  l:line_imp<0
		let l:line_imp=1
	endif
	let cmd = g:vjde_cs_find. ' "'.l:v_v.'" "'.g:vjde_cs_libs.'" '
	let str = system(cmd)
	exec 'let arr = '.str
	if len(arr)==1
		call append(l:line_imp,'using '.arr[0].';')
		return
	endif
	if len(arr) ==0
		return
	end
	let l:i = 0
	while l:i < len(arr)
		echo l:i.'	'.arr[l:i]
		let l:i = l:i + 1
	endwhile
	let sel = inputdialog('select one to using')
	if strlen(sel)>0
		call append(l:line_imp,'using '.arr[sel].';')
		return
	endif
endf
func! s:VjdeGeneratePerviewMenu(base)
    let lval= []
    if strlen(a:base)==0
        for member in g:vjde_cs_cfu.class.members
            call add(lval,{'word': member.name , 'kind': 'm' ,  'info': member.type,'icase':0})
        endfor
        for method in g:vjde_cs_cfu.class.methods
            call add(lval,{'word': method.name."(" , 'kind' : 'f', 'info': method.ToString(),'icase':0})
        endfor
    else
        for member in g:vjde_cs_cfu.class.SearchMembers('stridx(member.name,"'.a:base.'")==0')
            call add(lval,{'word': member.name , 'kind': 'm' ,  'info': member.type ,'icase':0})
        endfor
        for method in g:vjde_cs_cfu.class.SearchMethods('stridx(method.name,"'.a:base.'")==0')
            call add(lval,{'word': method.name."(" , 'kind' : 'f', 'info': method.ToString(),'icase':0})
        endfor
    endif
    return lval
endf
func! VjdeCSCompletionVIM(usingstr)
	"if empty(g:vjde_cs_cfu) 
		let g:vjde_cs_cfu=VjdeCSCompletion_New(g:vjde_cs_cmd,g:vjde_cs_libs)
	"endif
	call g:vjde_cs_cfu.FindClass(s:type,a:usingstr)
	if !g:vjde_cs_cfu.success
		return 0
	endif
	let index = 1
	let length = len(s:types)
	let success = 1
	while index < length && success
		let rettype=''
		for member in g:vjde_cs_cfu.class.members
			if s:types[index]==member.name
				let rettype= member.type
			endif
		endfor
		if rettype==''
			for method in g:vjde_cs_cfu.class.methods
				if s:types[index]==method.name
					let rettype= method.ret_type
				endif
			endfor
		endif
		if rettype==''
			let success = 0
		else
			call g:vjde_cs_cfu.FindClass(rettype,'')
			let success = g:vjde_cs_cfu.success
		endif
		let index+=1
	endwhile
	let s:success = success
	return s:success
endf
func! VjdeCSCompletion_FindClass(name,imptstr,...) dict 
    let cmd = self.cmd. ' '.a:name.' "'.self.dllpath.'" "'.a:imptstr.'" '.s:beginning
    let str = system(cmd)
    if strlen(str) < 10 
        let self.success = 0
        return {}
    endif
    let self.success = 1
    let self.class = VjdeJavaClass_New(VjdeListStringToList(str))
    return self.class
endf
func! VjdeCSCompletion_New(cmd,path) 
    let inst = { 'cmd' : a:cmd , 'dllpath': a:path , 'class': { } , 'success' :0 ,
                \'FindClass':function('VjdeCSCompletion_FindClass') }
    return inst
endf
 if v:version>=700
    au BufNewFile,BufRead,BufEnter *.cs set cfu=VjdeCSCompletion
    au BufNewFile,BufRead,BufEnter *.aspx set cfu=VjdeCSCompletion
    au BufNewFile,BufRead,BufEnter *.ashx set cfu=VjdeCSCompletion
    au BufNewFile,BufRead,BufEnter *.cs nmap <leader>ai :call VjdeCsFindUsing()<cr>
 endif
"let cscompletion = VjdeCSCompletion_New('mono.exe '.g:vjde_install_path.'/vjde/CSParser.exe','d:\Mono-1.1.13.4\lib\mono\2.0\mscorlib.dll')
"let cscompletion = VjdeCSCompletion_New('mono.exe e:/temp/CSParser.exe','d:\Mono-1.1.13.4\lib\mono\2.0\mscorlib.dll')
"let mclass = cscompletion.FindClass('Console','System')
"if cscompletion.success 
"	for item2 in	mclass.members
"		echo item2.ToString()
"	endfor
"endif
