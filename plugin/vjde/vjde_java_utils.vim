if exists("g:vjde_java_utils")
        "finish
endif
if !exists('g:vjde_loaded') || &cp
		finish
endif

let g:vjde_java_utils=1  "{{{1
if !exists("g:vjde_utils_setup")
	let g:vjde_utils_setup=1
endif
let s:cursor_l=1
let s:cursor_c=0
   
func! VjdeGetFullImportsList() "{{{2
    let lnum = line('.')
    let lcol = col('.')
    call cursor(line('$'),1)
    let l:line_imp = search ("^\\s*import\\s\\+","b")
    let l:res = []
    while l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let l:cend = matchend(l:str,"^\\s*import\\s")
        if  l:cend!= -1
            if l:str  !~ '\*\s*;$'
                call add(l:res,{ 'impt' : substitute(matchstr(l:str,".*$",l:cend),'\s*\(.*\)\s*;\s*$','\1',''),'line' : l:line_imp})
            endif
        endif
        let l:line_imp -= 1
    endw
    call cursor(lnum,lcol)
    return l:res
endf "}}}2
func! GetImportsStr() "{{{2
    let l:line_imp = search ("^\\s*import\\s\\+","nb")
    let l:res = "java.lang.*;"
    "if l:line_imp == 0 
        "return l:res
    "endif
    while l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let l:cend = matchend(l:str,"^\\s*import\\s")
        if  l:cend!= -1
           
            let l:res =l:res.matchstr(l:str,".*$",l:cend)
                "echo matchstr(l:str,".*$",l:cend)
        endif
        let l:line_imp -= 1
    endw

    let l:line_imp = search ('^\s*package\s\+',"nb")
    if  l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let l:cend = matchend(l:str,'^\s*package\s\+')
        if  l:cend!= -1
           
            let l:tmp = matchstr(l:str,".*$",l:cend)
            
            let l:res =l:res.strpart(l:tmp,0,stridx(l:tmp,";"))
            let l:res = l:res.".*;"
                "echo matchstr(l:str,".*$",l:cend)
        endif
    endif
    return l:res
endf
func! VjdeFindParent(findimps) "{{{2
    let x_l = line('.')
    let x_c = col('.')
    let res1 = []
    "let l = search('extends\s\+\(\i\+\.\)*\<\i\+\>','nb')
    let pos = VjdeGotoDefPos('\<extends\>','b')
    let l = pos[0]
    if ( l > 0 )
        let str = matchstr(getline(l),  'extends\s\+\(\i\+\.\)*\<\i\+\>',pos[1]-1)
        call add(res1,substitute(str, 'extends\s\+\(\(\i\+\.\)*\<\i\+\>\)','\1',''))
    else
        call add(res1,'java.lang.Object')
    endif
	call cursor(x_l,x_c)
    if !a:findimps
        return res1
    endif
    "let l = search('implements\s\+','nb')
    if l > 0 
        let pos2 = VjdeGotoDefPos('\<implements\>','b')
        "let pos2 = VjdeGotoDefPos('\(\<implements\>\|{\)','b')
    else
        let pos2 = VjdeGotoDefPos('\<implements\>','b')
    endif
    if ( pos2[0] >0 )
		let str=''
		let lnum = pos2[0]
		let linestr = getline(lnum)
		if linestr[pos2[1]-1]!='{'
				let str.=linestr[pos2[1]+10:-1]
				let lnum+=1
				while stridx(str,'{')<0
						let str.=getline(lnum)
						let lnum+=1
				endw
				let lthrows = stridx(str,'throws')
				if lthrows>0
						let str=str[0:lthrows]
				endif
				let array = split(str,'[, \t{]')
				call filter(array,'strlen(v:val)>0')
				let res1+=array
		endif
endif
call cursor(x_l,x_c)
return res1
endf
func! s:VjdeGetStrBetween(lstart,cstart,lend,cend) "{{{2
    let str = ''
    if a:lstart == a:lend
        str = strpart(getline(a:lstart),a:cstart-1,a:cend-a:cstart+1)
    else
        let lcurr = a:lstart+1
        let str=strpart(getline(a:lstart,a:cstart-1))
        while lcurr < a:lend
            let str = str.getline(lcurr)
        endw
        let str = str.strpart(getline(a:lend),0,a:cend)
    endif
    return str
endf
" search a block backward , such as try { , public class .. { .....
" don't move the cursor
"
func! VjdeFindDefination(pattern) "{{{2
    let l = line('.')
    let c = col('.')
        let res1 = VjdeGotoDefPos(a:pattern,'b')
        let res2 = VjdeGotoDefPos('{','')
        call cursor(l,c)
        return res1+res2
endf
" search a block backward , such as try { , public class .. { .....
func! VjdeGotoDefination(pattern,dir)
        let res1 = VjdeGotoDefPos(a:pattern,a:dir)
        let res2 = VjdeGotoDefPos('{',a:dir)
        return res1+res2
endf
" search a pttern by ,f_dir is 'nb' 'b' ''... , ignore occured in Constant and comment
func! VjdeGotoDefPos(pattern,f_dir) "{{{2
        let l:firsttime = 0
        let l:firstpos = 0
        let res1 = [0,0]
        let l:line_d = search(a:pattern,a:f_dir)
        while line_d > 0 
                "let l:col_i = match(getline(l:line_d),a:pattern)
                let l:col_i = col('.') " match(getline(l:line_d),a:pattern)
                let synname= synIDattr(synIDtrans(synID(l:line_d,l:col_i+1,1)),"name")
                if synname != "Comment" && synname!="Constant" && synname!="Special"
                        break
                else
                        if ( l:firsttime == 0 )
                                let l:firsttime = 1
                                let l:firstpos = l:line_d
                        else
                                if ( l:firstpos == l:line_d)
                                        let l:line_d = 0
                                        break
                                endif
                        endif
                        let l:line_d=search(a:pattern,a:f_dir)
                endif
        endw
        if l:line_d > 0 
                let res1[0] = l:line_d
                let res1[1] = l:col_i
        endif
        return res1
endf "}}}2
" search a pair block ,such as { } , 
func! VjdeGotoBlock(mpre,mnext) "{{{2
	let stack=[line('.')]
	while len(stack)>0
		let l:pos = VjdeGotoDefPos('\('.a:mpre.'\|'.a:mnext.'\)','W')
		if l:pos[0]==0
			echo 'Block search failed!'
			return [0,0]
		endif
		if match(getline(l:pos[0]),'^'.a:mpre,l:pos[1]-1) == l:pos[1]-1
			call add(stack,l:pos[0])
		else
			call remove(stack,-1)
		endif
	endw
	return l:pos
endf
" find a code block , such as try { ... } , if { ... } , backward
func! VjdeFindBlockUp(patt) "{{{2
	let res_pos=[]	
	let pos = VjdeFindDefination(a:patt)
	if pos[0] <= 0 || pos[2]<=0
		return [0,0,0,0,0,0]
	endif
	let res_pos+=pos

	let l:line = line('.')
	let l:col= line('.')
	call cursor(pos[2],pos[3]+1)
	let res_pos += VjdeGotoBlock('{','}')

	return res_pos
endf
" find a code block , such as try { ... } , if { ... } , forward
func! VjdeFindBlockDown(patt) "{{{2
	let res_pos=[]	
	let pos = VjdeGotoDefination(a:patt,'')
	if pos[0] <= 0 || pos[2]<=0
		return [0,0,0,0,0,0]
	endif
	let res_pos+=pos

	let l:line = line('.')
	let l:col= line('.')
	call cursor(pos[2],pos[3]+1)
	let res_pos += VjdeGotoBlock('{','}')

	return res_pos
endf
func! s:Java_get_type(str,v_v) "{{{2
        let str1 = matchstr(a:str,'\<[^ \t]\+\s\+\<'.a:v_v.'\>')
        return substitute(str1,'\<\([^ \t]\+\)\s\+\<'.a:v_v.'\>','\1','')
endf
func! Vjde_get_set() " {{{2
        let l:line = line('.')
        let l:v_v = expand('<cword>')
        let str = getline(l:line)
        let l:v_t = s:Java_get_type(str,l:v_v)
        "let l:v_t = VjdeGetTypeName(l:v_v)
        let l:v_Va = substitute(l:v_v,"^\\(.\\)","\\U\\1","")
		call append(l:line,"\t/**")
		call append(l:line+1,"\t * get the value of ".l:v_v)
		call append(l:line+2,"\t * @return the value of ".l:v_v)
		call append(l:line+3,"\t */")
        call append(l:line+4,"\tpublic ".l:v_t." get".l:v_Va."(){")
        call append(l:line+5,"\t\treturn this.".l:v_v.";")
        call append(l:line+6,"\t}")
		call append(l:line+7,"\t/**")
		call append(l:line+8,"\t * set a new value to ".l:v_v)
		call append(l:line+9,"\t * @param ".l:v_v." the new value to be used")
		call append(l:line+10,"\t */")
        call append(l:line+11,"\tpublic void set".l:v_Va."(".l:v_t." ".l:v_v.") {")
        call append(l:line+12,"\t\tthis.".l:v_v."=".l:v_v.";")
        call append(l:line+13,"\t}")
endf 
func! VjdePackageNameCompare1(i1,i2)
    return a:i1==a:i2?0 : a:i1 > a:i2 ? 1 : -1
endf
func! VjdePackageNameCompare(i1,i2) "{{{2
		let maw=substitute(a:i1,'\s*import\s\+\(static\s\+\)*\(\w\+\)\..*$','\2','')
		let mbw=substitute(a:i2,'\s*import\s\+\(static\s\+\)*\(\w\+\)\..*$','\2','')
		if maw==mbw
				return VjdePackageNameCompare1(a:i1,a:i2)
		endif
		if maw=='java'
				return -1
		elseif mbw=='java'
				return 1
		elseif maw=='javax'
				return -1
		elseif mbw=='javax'
				return 1
		elseif maw=='org'
				return -1
		elseif mbw=='org'
				return 1
		elseif maw=='net'
				return -1
		elseif mbw=='net'
				return 1
		else
				return VjdePackageNameCompare1(a:i1,a:i2)
		endif
endf

func! Vjde_sort_import() range "{{{2
let lines = []
let index = a:firstline
while index<= a:lastline
		call add(lines,getline(index))
		let index+=1
endwhile
call filter(lines,'strlen(v:val)>0')
call sort(lines,'VjdePackageNameCompare')
let lstart = a:firstline
let mcount = lstart
let header =len(lines)>0? substitute(lines[0],'\s*import\s\+\(static\s\+\)*\(\w\+\).*$','\2',''):''
for lstr in lines
		let mh = substitute(lstr,'\s*import\s\+\(static\s\+\)*\(\w\+\).*$','\2','')
		if mh != header
				let header = mh
				if mcount <= a:lastline
						call setline(mcount,'')
				else
						call append(mcount-1,'')
				endif
				let mcount+=1
		endif
		if mcount <= a:lastline
				call setline(mcount,lstr)
		else
				call append(mcount-1,lstr)
		endif
		let mcount+=1
endfor
return
endf

func! Vjde_ext_import() "{{{2
        let l:line = line('.')
	let l:column = col('.')
        let l:str = getline(l:line)
	let l:head = strpart(l:str,0,match(l:str,'\([ \t,){(<]\|$\)',l:column))
        if l:head==''
            return
        endif
	"let l:target = strpart(matchstr(l:head,"[ \\t,(]\\(\\i\\+\\.\\)\\+\\i\\+$"),1)
	let l:target = strpart(matchstr(l:head,'[^0-9A-Za-z\.]\(\i\+\.\)\+\i\+$'),1)
        if l:target == ''
            return 
        endif
        let l:target_sub = strpart(l:target,match(l:target,"\\.\\i\\+$")+1)

        let l:line_pkg = search('^\s*package\s\+','nb')+1

        let l:line_imp = search('^\s*import\s\+'.l:target,'nb') +1
        if l:line_imp ==1
            exec '%s/'.l:target.'/'.l:target_sub.'/g'
            "call append(l:line_pkg,'import '.l:target.';')
			let idx = Vjde_import_check(l:target)
            call cursor(l:line+idx,l:column-strlen(l:target)+strlen(l:target_sub))
        else
            exec l:line_imp.',$s/'.l:target.'/'.l:target_sub.'/g'
            call cursor(l:line,l:column-strlen(l:target)+strlen(l:target_sub))
        endif
endf
func! s:Vjde_get_pkg(cls) "{{{2
        return substitute(a:cls,'^\(\(\w\+\.\)*\)\(\w\+\)$','\1','')
endf
func! s:Vjde_get_cls(cls)
        return substitute(a:cls,'^\(\(\w\+\.\)*\)\(\w\+\)$','\3','')
endf
func! VjdeGetClassName(longname)
		return s:Vjde_get_cls(a:longname)
endf
func! Vjde_import_check(cls) "{{{2
    if match(a:cls,'\<\(char\|int\|void\|long\|double\|byte\|boolean\|float\)\>')==0
        return 0
    endif
    return s:Vjde_add_import(a:cls)
endf
func! s:Vjde_add_import(cls) "{{{2
        if match(a:cls,'^java\.lang\.[A-Z]')==0
            return 0
        endif
        let l:line_imp = search('^\s*import\s\+'.a:cls.'\s*;','nb')
        if l:line_imp > 0 
                return 0
        endif
        let pkg = s:Vjde_get_pkg(a:cls)
        let l:line_imp = search('^\s*import\s\+'.pkg.'\*\s*;','nb')
        if l:line_imp > 0 
                return 0
        endif
        let l:line_imp = search('^\s*import\s\+','nb')
        if l:line_imp <= 0 
                let l:line_imp = search('^\s*package\s\+','nb')
        endif
        call append(l:line_imp,'import '.a:cls.';')
        return 1
endf
func! Vjde_remove_imports()
    let impts = VjdeGetFullImportsList()
    let lnum = line('.')
    let lcol = col('.')
    let cls=''
    let res=[]
    for  item in impts
		if ( match(item.impt,'static') >=0 )
			continue
		endif
        let cls = s:Vjde_get_cls(item.impt)
        call cursor(item.line+1,1)
        let res = VjdeGotoDefPos('\<'.cls.'\>','')
        if  res[0] == 0  || res[0] == item.line " not found
            call cursor(item.line,1)
            normal dd
        endif
    endfor
    call cursor(lnum,lcol)
endf
func! Vjde_fix_throws() "{{{2
    let bnum = bufnr('%')
    let lnum = line('.')
    let mfind = 0
    let offset = 1 
    let pos = s:Java_pos_fun()
    for item in getqflist()
        if item.bufnr == bnum && item.lnum == lnum  
            "let str = matchstr(item.text,'unreported exception [^ \t;]*;') 
            let str = matchstr(item.text,g:vjde_java_exception) 
            if str==""
                continue
            endif
            "let str = substitute(str,'\(unreported exception \)\([^ \t;]*\);','\2','')
            let str = substitute(str,g:vjde_java_exception,'\2','')
            let add = s:Vjde_add_import(str)
            let str = s:Vjde_get_cls(str)
            if !mfind
                let tpos = VjdeGotoDefination('\<throws\>','nb')
                if tpos[0]>=pos[0] && tpos[0] <=pos[2]
                    let mfind = 1
                    call cursor(tpos[0],1)
                    exec 's/\<throws\>/throws '.str.', '
                else
                    call cursor(pos[2],1)
                    exec 's/{/throws '.str.' {/'
                    let mfind =1 
                    continue
                endif
            else
                call cursor(tpos[0],1)
                exec 's/\<throws\>/throws '.str.', '
            endif
        endif
    endfor
    call cursor(lnum,1)
endf


func! Vjde_fix_try() "{{{2
        let bnum = bufnr('%')
        let lnum = line('.')
        let mfind = 0
        let offset = 1 
        for item in getqflist()
            if item.bufnr == bnum && item.lnum == lnum  
                "let str = matchstr(item.text,'unreported exception [^ \t;]*;') 
				let str = matchstr(item.text,g:vjde_java_exception) 
                if str==""
                    continue
                endif
                "let str = substitute(str,'\(unreported exception \)\([^ \t;]*\);','\2','')
				let str = substitute(str,g:vjde_java_exception,'\2','')
                let add = s:Vjde_add_import(str)
                let str = s:Vjde_get_cls(str)

                if !mfind
                    let bpos = VjdeFindBlockUp('^\s*try\>')
                    let lastpos =[0,0]
                    let lastpos[0:1] = bpos[4:5]
					if lnum > bpos[2] && lnum < bpos[4]
                        let cpos = VjdeFindBlockDown('\<\(catch\|finally\)\>')
                            while cpos[0]!=0 && cpos[2]!= 0 && cpos[4]!=0
                                let checkpos = VjdeGotoDefPos('}','b')
                                if checkpos[0]==lastpos[0] && checkpos[1]==lastpos[1]
                                    "call cursor(cpos[0],cpos[1]+1)  " fix for
                                    "try catch statment
                                    call cursor(cpos[0],cpos[1])
                                    if getline(cpos[0])[cpos[1]-1]=='c'
                                        let lastpos[0:1] = cpos[4:5]
                                    else
                                        break
                                    endif
                                else " not the last
                                    break
                                endif
                                let cpos = VjdeFindBlockDown('\<\(catch\|finally\)\>')
                                endw
                                let offset = lastpos[0]-lnum -1
                                let mfind = 1
                            endif
                        endif

							if mfind
									call append(lnum+offset+add,'catch('.str.' e'.offset.') {')
									call append(lnum+offset+add+1,'}')
									let offset += (2+add)
							else
									let mfind = 1
									call append(lnum-1+add,'try {')
									call append(lnum+1+add,'}')
									call append(lnum+2+add,'catch('.str.' e'.offset.') {')
									call append(lnum+3+add,'}')
									let offset = 4+add
							endif
					endif
        endfor
        if mfind
                call cursor(lnum-1,0)
                exec 'normal '.(offset+3).'=='
        endif
endf "}}}2
func! Vjde_fix_import() "{{{2
        let bnum = bufnr('%')
        let lnum = line('.')
        let mfind = 0
        let offset = 1 
		for item in getqflist()
				if item.bufnr == bnum && item.lnum == lnum  
						"let str = matchstr(item.text,'cannot find symbol\nsymbol\s*: class [^ \t;\s]*\n') 
						let str = matchstr(item.text,g:vjde_java_symbol) 
						if str == ""
								echo item.text
								echo g:vjde_java_symbol
								continue
						endif
						let str = substitute(str,g:vjde_java_symbol,'\1','') 
						call Vjde_fix_import1(str)
				endif
		endfor
endf
func! Vjde_fix_import1(...) "{{2
		let word = a:0 > 0 ? a:1 : expand('<cword>')
		let array = VjdeJavaSearch4Classes(g:vjde_install_path.'/vjde/vjde.jar',word,g:vjde_lib_path)
		let lens = len(array)
		if lens==0
				return
		elseif lens==1
				call s:Vjde_add_import(array[0])
				return
		endif

		let index=0
		for item in array
				echo "\t".index."\t".item 
				let index+=1
		endfor 
		let str = inputdialog("Select a class to import [0-".index.']:',"0")
		let str2 = match(str,'^[0-9]*$')==0 && str < len(array) ? str : "0"
		call s:Vjde_add_import(array[str])
endf
func! s:Java_add_arg(firstl,lastl,str_def) "{{{2
		let i = a:firstl
		let str=''
		while i <= a:lastl
				let str.= getline(i)
				if stridx(str,')')>=0
						break
				endif
				let i+=1
		endwhile
		let cm=''
		if match(str,'[^ \t(]\+\s*)')>=0
				let cm=','
		endif
		let str = getline(i)
		call setline(i,substitute(str,')',cm.a:str_def.')',''))
endf
func! s:Java_pos_fun() "{{{2
    "return VjdeFindDefination('^\s*\(public\|private\|protected\)\?\(\s\+final\|\s\+static\|\s\+synchronized\)*\s*[^ \t]\+\s\+\i\+(')
    return VjdeFindDefination('^\s*\(\(public\|private\|protected\|final\|static\|synchronized\|native\|abstract\|synchronized\)\s\+\)*\s*\(new\|return\)\@!\([^ \t]\+\)\s\+\(if\|while\|for\|catch\)\@!\(\i\+\)\s*(')
endf
func! s:Java_pos_class() "{{{2
    return VjdeFindDefination('^\s*\(public\|private\|protected\)\?\(\s*abstract\|\s*final\|\s*static\)*\s*\(class\|interface\)\s\+\i\+')
endf
func! Vjde_test(ll)
    echo s:Java_range_class(a:ll)
endf
func! s:Java_range_class(ll) "{{{2
        let l = line('.')
        let c = col('.')
    let pos=[0,0,0,0,0,0]
    while ( a:ll > pos[4])
        let pos = VjdeFindBlockUp('^\s*\(public\|private\|protected\)\?\(\s\+abstract\|\s\+final\|\s*static\)*\s*\(class\|interface\)\+\s\+\i\+')

        if pos[0]==0 || pos[2]==0 || pos[4] == 0
            break
        elseif pos[0]<=a:ll && pos[4]>=a:ll
            break
        else
            call cursor(pos[0],pos[1])
        end
    endw
    call cursor(l,c)
    return pos
endf
func! s:VjdeInitJavaCompletion() "{{{2
	if empty(g:vjde_java_cfu)
		let g:vjde_java_cfu = VjdeJavaCompletion_New(g:vjde_install_path.'/vjde/vjde.jar',g:vjde_out_path.g:vjde_path_spt.g:vjde_lib_path)
	endif
endf
func! Vjde_surround_try() range "{{{2
	call append(a:firstline-1,'try {')
	call append(a:lastline+1,'}')
	call append(a:lastline+2,'catch(Exception ex) {')
        call append(a:lastline+3,'//TODO: Add Exception handler here')
	call append(a:lastline+4,'}')
	call cursor(a:firstline-1,0)
	exec 'normal '.(a:lastline-a:firstline+7).'=='
	"exec (a:firstline-1).','.(a:lastline+4).'=='
endf "}}}2
func! Vjde_rft_var(pos_t) "{{{2
    let l:var = expand('<cword>')
    let l:lnum = line('.')
    let l:var_t = s:Java_get_type(getline(l:lnum),l:var)
    let pos = []
    let ident=''
    if a:pos_t == 1 " member
        "let pos = s:Java_pos_class()
        let pos = s:Java_range_class(l:lnum)
    elseif a:pos_t == 2 " local
        let pos = s:Java_pos_fun()
        let ident="\t"
    else
        let pos = s:Java_pos_class()
    endif

    if  pos[0]>0 && pos[2] > 0
	if stridx(getline(l:lnum),'=')>=0
		exec 's/'.l:var_t.'\s\+//'
	else
		exec 'normal dd'
	endif
        if match(l:var_t,'^\(int\|long\|boolean\|char\|double\|byte\)$') >= 0
            call append(pos[2],"\t".ident.l:var_t." ".l:var." ;")
        else
            call append(pos[2],"\t".ident.l:var_t." ".l:var." = null ;")
        endif
    else
        echo 'not found class defination.'
        "exec 'normal ^' 3.3
    endif
endf
func! Vjde_rft_arg() "{{{
    let l:var = expand('<cword>')
    let l:lnum = line('.')
    let l:var_t = s:Java_get_type(getline(l:lnum),l:var)
    let pos = s:Java_pos_fun()
    if  pos[0]>0 && pos[2] > 0
	if stridx(getline(l:lnum),'=')>=0
		exec 's/'.l:var_t.'\s\+//'
	else
		exec 'normal dd'
	endif
	call s:Java_add_arg(pos[0],pos[2],l:var_t.' '.l:var)
    else
        echo ' not found method defination.'
    endif
endf
func! Vjde_rft_const() range "{{{2
    let pos = s:Java_range_class(line('.'))
    if pos[0]==0 || pos[2] == 0
        echo 'Can''t find a class defination . Sorry!'
        return
    endif
    let v_t = inputdialog('Please enter the name of variable :','')
    if v_t == ''
        return
    endif
    let firstcol = col('''<')
    let lastcol = col('''>') 
    let str = ''
    if a:firstline == a:lastline
        let ll  = getline(a:firstline)
        let str = strpart(ll,firstcol-1,lastcol-firstcol+1)
        call setline(a:firstline,strpart(ll,0,firstcol-1).v_t.strpart(ll,lastcol))
        call s:Vjde_add_var(pos[2],str,v_t)
    else
        let lines = []
        call add(lines, "\tprivate final static String ".v_t." = ".strpart(getline(a:firstline),firstcol-1))
        let lcount = a:firstline+1
        while lcount < a:lastline
            call add(lines,getline(lcount))
            "call setline(lcount , '')
            let lcount+=1
        endw
        call add(lines,strpart(getline(a:lastline),0,lastcol).';')
        call setline(a:firstline,strpart(getline(a:firstline),0,firstcol-1).v_t.strpart(getline(a:lastline),lastcol))
        call cursor(a:firstline+1,1)
        exec 'normal '.(a:lastline-a:firstline).'dd'
        call append(pos[2],lines)
    endif

endf "}}}2
func! s:Vjde_add_var(lnum,str,v_t) "{{{2
        if a:str[0]=='"'
            call append(a:lnum,"\tprivate final static String ".a:v_t." = ".a:str." ; ")
        elseif a:str[0]==''''
            call append(a:lnum,"\tprivate final static char ".a:v_t." = ".a:str." ; ")
        elseif match(a:str,'\.')>=0 || match(a:str,'[dDfF]$')>=0
            call append(a:lnum,"\tprivate final static double ".a:v_t." = ".a:str." ; ")
        elseif  match(a:str,'[lL]$')>=0
            call append(a:lnum,"\tprivate final static long ".a:v_t." = ".a:str." ; ")
        else
            call append(a:lnum,"\tprivate final static int ".a:v_t." = ".a:str." ; ")
        endif
endf
func! NumberToBinary(nstr)
		let nstr=a:nstr
		let str=''
		while nstr>0
				let str=nstr%2.str
				let nstr=nstr/2
		endw
		return str
endf
func! Vjde_override(type) " 0 extends 1 implements {{{2
    let imps = GetImportsStr()
    let pars = VjdeFindParent(a:type)
    if len(pars) < 1
        return 
    endif
    "call cursor(line('$'),col('$'))
    "let pos = VjdeGotoDefPos('}','nb')
    let pos = s:Java_range_class(line('.'))
    if pos[0] == 0 || pos[2] == 0 || pos[4] == 0
        return
    endif
    if a:type==0
        let par_l = pars[0]
    elseif len(pars)>1
        let par_l = join(pars[1:-1],';')
    elseif a:type!=0
        echo 'not interface implements found.'
        return
    end
	call s:VjdeInitJavaCompletion()
	let roffset= -1
	let rpos=pos[4]
	let rsel = ''
	let rmymethods=[]
	let rallpars=split(par_l,';')
	let protected=3
	let abstract=11
	for item in rallpars
			let rmymethods= VjdeSelectMethods(item,imps,5)
			for rcm in rmymethods
					let rstr="\tpublic "
					let roffset+=Vjde_import_check(rcm.ret_type)
					let rstr.= s:Vjde_get_cls(rcm.ret_type)
					let rstr.= " ".rcm.name."("
					let rindex=0
					for para in rcm.paras
							let roffset+= Vjde_import_check(para)
							let rstr.= ( rindex==0?'':', ' )
							let rstr.= s:Vjde_get_cls(para).' arg'.rindex
							let rindex+=1
					endfor
					let rstr.=")"
					let rindex=0
					for exces in rcm.exces
							let rstr.= ( rindex==0?"  throws ":",")
							let rstr.= s:Vjde_get_cls(exces)
							let roffset += Vjde_import_check(exces)
							let rindex += 1
					endfor
					let rstr.=" {"
					call append(rpos+roffset,"\t/**")
					call append(rpos+roffset+1,"\t * @see ".g:vjde_java_cfu.class.name."#".rcm.name.'('.join(rcm.paras,', ').') '.rcm.name)
					call append(rpos+roffset+2,"\t */")
					call append(rpos+roffset+3,rstr)
					call append(rpos+roffset+4,"\t}")
					let roffset+=5
			endfor
	endfor

	return
endf "}}}2
func! VjdeImplementInner() "{{{2
    let rpos=line('.')
	let str = getline(rpos-1)
    let str = matchstr(str,"new\\s\\+\\([^(.]\\+\\.\\)*[^(.]\\+\\s*(\\s*)\\s*{\\s*$")
    if ( strlen(str)==0)
		let str = getline(rpos)
		let str = matchstr(str,"new\\s\\+\\([^(.]\\+\\.\\)*[^(.]\\+\\s*(\\s*)\\s*{\\s*$")
		if ( strlen(str)==0)
			echo 'not found for implements.'
		endif
		let rpos = rpos+1
    endif
    let name = substitute(str,"new\\s\\+\\(\\([^.]\\+\\.\\)*[^.]\\+\\)\\s*(\\s*)\\s*{\\s*$","\\1",'')
    let imps = GetImportsStr()
	call s:VjdeInitJavaCompletion()
	call g:vjde_java_cfu.FindClass(name,imps,5)
    if g:vjde_java_cfu.success
        let rindex=0
        let roffset= -1
        for rcm in g:vjde_java_cfu.class.methods
            
            let rstr="\tpublic "
            let roffset+=Vjde_import_check(rcm.ret_type)
            let rstr.= s:Vjde_get_cls(rcm.ret_type)
            let rstr.= " ".rcm.name."("
            let rindex=0
            for para in rcm.paras
                let roffset+= Vjde_import_check(para)
                let rstr.= ( rindex==0?'':', ' )
                let rstr.= s:Vjde_get_cls(para).' arg'.rindex
                let rindex+=1
            endfor
            let rstr.=")"
            let rindex=0
            for exces in rcm.exces
                let rstr.= ( rindex==0?"  throws ":",")
                let rstr.= s:Vjde_get_cls(exces)
                let roffset += Vjde_import_check(exces)
                let rindex += 1
            endfor
            let rstr.=" {"
            call append(rpos+roffset,"\t/**")
            call append(rpos+roffset+1,"\t * @see ".g:vjde_java_cfu.class.name."#".rcm.name.'('.join(rcm.paras,', ').') '.rcm.name)
            call append(rpos+roffset+2,"\t */")
            call append(rpos+roffset+3,rstr)
            call append(rpos+roffset+4,"\t}")
        endfor
    endif
endf
func! VjdeGenerateConstructor() "{{{2
		let cname = expand("%:t:r")
		let pkg=''
		let pkg_ln = VjdeGotoDefPos('^\s*package\s\+[a-zA-Z.0-9]*\s*;\s*$','nb')
		if pkg_ln[0]>0
				let pkg_lnstr = getline(pkg_ln[0])
				let pkg = substitute(getline(pkg_ln[0]),'^\s*package\s\+\([a-zA-Z0-9.]*\)\s*;\s*$','\1','').'.'
		endif
		call s:VjdeInitJavaCompletion()
		call g:vjde_java_cfu.FindClass(pkg.cname,'',5)
		let idx = line('.')
		let idxOld = idx
		let idx1 = 0
		if g:vjde_java_cfu.success
				for mem in g:vjde_java_cfu.class.members
						let idx += Vjde_import_check(mem.type)
						if idx1 == 0
								call append(idx+idx1,'public '.cname.'('.s:Vjde_get_cls(mem.type).' '.mem.name)
						else
								call append(idx+idx1,','.s:Vjde_get_cls(mem.type).' '.mem.name)
						endif
						let idx1 += 1
				endfor
				call append(idx+idx1,') {')
				let idx1 += 1
				for mem in g:vjde_java_cfu.class.members 
						call append(idx+idx1,'this.'.mem.name.' ='.mem.name.' ;')
						let idx1 += 1
				endfor
				call append(idx+idx1,'}')
				exec 'normal '.(idx+idx1-idxOld+2).'=='
		endif
endf
func! VjdeSelectMethods(class,imps,...) "{{{2
	let level=0
	if a:0>0
			let level=a:1
	endif
	call s:VjdeInitJavaCompletion()
	let roffset= -1
	let rsel = ''
	let rmymethods=[]
	let protected=3
	let abstract=11
	call g:vjde_java_cfu.FindClass(a:class,a:imps,level)
	if g:vjde_java_cfu.success
		   let rindex=0
		   for method in g:vjde_java_cfu.class.methods
				   let str=''
				   let modifierstr = NumberToBinary(method.modifier)
				   let len = strlen(modifierstr)
				   if  len >=3 && modifierstr[len-3]=='1'
						   let str.='protected '
				   endif
				   if  len >=11 && modifierstr[len-11]=='1'
						   let str.='abstract  '
				   endif
				   let str.= (str==''?"\t" : '')
				   let str="\t".rindex."\t".str.method.ToString()
				   echo str
				   if rindex%20==19
						   let rsel .= inputdialog("\tSelect methods ( comma or space sepearted: 1 2,3,4-6..)<CR>\t:","")
						   let rsel.=','
						   echo "\n"
				   endif
				   let rindex+=1
		   endfor
		   if len(g:vjde_java_cfu.class.methods)%20!=0
						   let rsel .= inputdialog("\tSelect methods ( comma or space sepearted: 1 2,3,4-6..)<CR>\t:","")
						   let rsel.=','
						   echo "\n"
		   endif
		   if strlen(rsel)>0
				   let rarr = split(rsel,'[, \t;]') 
				   for item1 in rarr
						   if match(item1,'^[0-9]\+$')>=0
								   call add(rmymethods,g:vjde_java_cfu.class.methods[item1])
						   elseif match(item1,'^[0-9]\+\s*-\s*[0-9]\+$')>=0
								   let rmymethods+= eval("g:vjde_java_cfu.class.methods[".substitute(item1,'-',':','')."]")
						   endif
				   endfor
		   endif
   endif
   return rmymethods
endf
function! s:Vjde_utils_setup() "{{{2
    nnoremap <buffer> <silent> <Leader>je :call Vjde_ext_import()<CR>
    nnoremap <buffer> <silent> <Leader>jg :call Vjde_get_set()<CR>
    nnoremap <buffer> <silent> <Leader>jc :call VjdeGenerateConstructor()<CR>
    nnoremap <buffer> <silent> <Leader>jt :call Vjde_surround_try()<CR>
    vnoremap <buffer> <silent> <Leader>jt :call Vjde_surround_try()<CR>
    vnoremap <buffer> <silent> <Leader>js :call Vjde_sort_import()<CR>

    nnoremap <buffer> <silent> <Leader>fr :call Vjde_fix_throws()<CR>
    nnoremap <buffer> <silent> <Leader>ft :call Vjde_fix_try()<CR>
    nnoremap <buffer> <silent> <Leader>fi :call Vjde_fix_import()<CR>
    nnoremap <buffer> <silent> <Leader>ai :call Vjde_fix_import1()<CR>
    nnoremap <buffer> <silent> <Leader>ri :call Vjde_remove_imports()<CR>
    " extract variable to local
    nnoremap <buffer> <silent> <Leader>el :call Vjde_rft_var(2)<CR>
    " extract variable to member
    nnoremap <buffer> <silent> <Leader>em :call Vjde_rft_var(1)<CR>
    nnoremap <buffer> <silent> <Leader>ep :call Vjde_rft_arg()<CR>
    vnoremap <buffer> <silent> <Leader>en :call Vjde_rft_const()<CR>

    nnoremap <buffer> <silent> <Leader>oe :call Vjde_override(0)<CR>
    nnoremap <buffer> <silent> <Leader>oi :call Vjde_override(1)<CR>
    nnoremap <buffer> <silent> <Leader>ii :call VjdeImplementInner()<CR>
    nnoremap <buffer> <silent> <Leader>as :call VjdeAppendTemplate("Singleton")<CR>
    "imap <M-g> <ESC> :call <SID> Vjde_get_set()<cr>
    "map <M-g> :call <SID>Vjde_get_set()<cr>
endf "}}}2

if g:vjde_utils_setup==1
	au BufNewFile,BufRead *.java silent call s:Vjde_utils_setup()
endif

" vim:fdm=marker:sts=4:ts=4:ff=unix
