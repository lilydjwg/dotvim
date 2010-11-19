if !exists('g:vjde_loaded') || &cp
	finish
endif
let g:vjde_java_rt=';'
if !exists('g:vjde_java_command')
    let g:vjde_java_command='java'
    if has('win32')
            let g:vjde_java_command='javaw'
    endif
end
let s:java_home = expand('$JAVA_HOME')
if has('mac')
	let s:java_home = '/System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/'
end
if s:java_home != '$JAVA_HOME' && strlen(s:java_home) > 0 
    if s:java_home[strlen(s:java_home)-1]=='/' || s:java_home[strlen(s:java_home)-1]=='\'
	    if has('win32')
		    let g:vjde_java_rt =';'.s:java_home.'jre/lib/rt.jar'
	    elseif has('mac')
		    let g:vjde_java_rt =':'.s:java_home.'Classes/classes.jar'
	    else
		    let g:vjde_java_rt =':'.s:java_home.'jre/lib/rt.jar'
	    endif
    else
	    if has('win32')
		    let g:vjde_java_rt =';'.s:java_home. '/jre/lib/rt.jar'
	    elseif has('mac')
		    let g:vjde_java_rt =':'.s:java_home.'/Classes/classes.jar'
	    else
		    let g:vjde_java_rt =':'.s:java_home. '/jre/lib/rt.jar'
	    endif
    endif
endif

func! VjdeListStringToList(str) "{{{2
    let lines = split(a:str,"\n")
    let level = -1 " 0 for class , 1 for member, 2 constructor, 3 methods, 4 inners , //5 modifies
    let str = ''
    let arr=['',[],[],[],[],0]
    for str in lines
       if     str[0]=='[' 
           let level=level+1
       elseif str[0]==' '
           call add(arr[level],eval(str))
       elseif str[0]==',' 
           "echo level
           "echo eval(str[1:-1])
           call add(arr[level],eval(str[1:-1]))
       elseif str[0]==']'
       else
           if level==0
               let arr[0]=eval(str[0:-2])
           else
               let arr[5]=eval(str)
           endif
       endif
    endfor
    return arr
endf "}}}2

func! VjdeJavaNameCompare(i1,i2) "{{{2
    return a:i1.name==a:i2.name?0:a:i1.name>a:i2.name ? 1: -1
endf "}}}2
func! VjdeGetClassName(qn) "{{{2
    return substitute(a:qn,'^\(\(\w\+\.\)*\)\(\w\+\)$','\3','')
endf "}}}2
func! VjdeJavaMethod_Tos() dict "{{{2
    let str= self.ret_type.' '.self.name.'('.join(self.paras,', ').')'
    if len(self.exces)>0
        let str=str.' throws '.join(self.exces)
    endif
    return str.';'
endf
func! VjdeJavaMethod_New(arr)
    let arr=a:arr
    let instance= { 'ret_type':arr[1], 'name':arr[0], 'paras':arr[2:-3], 'exces':arr[-2], 'modifier':arr[-1] , 'ToString':function("VjdeJavaMethod_Tos") }
    return instance
endf
func! VjdeJavaConstructor_Tos() dict 
    let str=self.name.' '.VjdeGetClassName(self.name).'('.join(self.paras,', ').')'
    if len(self.exces)>0
        let str=str.' throws '.join(self.exces,',')
    endif
    return str.';'
endf
func! VjdeJavaConstructor_New(arr)
    "let arr=a:arr
    return { 'name':a:arr[0] , 
                \'paras':a:arr[1:-2], 
                \'exces':a:arr[-1] ,
                \'ToString':function("VjdeJavaConstructor_Tos") }
endf

func! VjdeJavaMember_Tos() dict
    return self.type.' '.self.name.';'
endf

func! VjdeJavaMember_New(arr)
    return { 'name':a:arr[0], 
                \'type':a:arr[1] , 
                \'ToString':function("VjdeJavaMember_Tos") }
endf
func! VjdeJavaClass_SearchMembers(cond) dict
	let arrary = []
	for member in self.members
		if eval(a:cond)
			call add(arrary,member)
		endif
	endfor
	return arrary
endf
func! VjdeJavaClass_SearchMethods(cond) dict
	let arrary = []
	for method in self.methods
		if eval(a:cond)
			call add(arrary,method)
		endif
	endfor
	return arrary
endf
func! VjdeJavaClass_New(arr)
    if len(a:arr)==0
        return {}
    endif
    let inst = { 'name':a:arr[0], 
                \'members' : [],
                \'constructors':[],
                \'methods':[],
                \'inners':a:arr[4],
                \'modifiers':a:arr[5] ,
		\'SearchMembers':function('VjdeJavaClass_SearchMembers'),
		\'SearchMethods':function('VjdeJavaClass_SearchMethods') }
    for item in a:arr[1]
        call add(inst.members,VjdeJavaMember_New(item))
    endfor
    for item in a:arr[2]
        call add(inst.constructors,VjdeJavaConstructor_New(item))
    endfor
    for item in a:arr[3]
        call add(inst.methods,VjdeJavaMethod_New(item))
    endfor
    "let inst.inners=a:arr[4][0:-1]
    call sort(inst.members,"VjdeJavaNameCompare")
    call sort(inst.methods,"VjdeJavaNameCompare")
    return inst
endf "}}}2
func! VjdeJavaCompletion_FindClass2(names,imptstr,...) dict "{{{2
    let level = 0
    if  a:0 > 0
        let level = a:1
    endif
    let name=a:names[0]
    let self.success = 0
    let imptstr = substitute(a:imptstr,'\*','','g')
    let impts = split(imptstr,'[; \t]')
    call filter(impts,'strlen(v:val)>0')
    let qn = 0
    if len(impts)>0
        for item in impts
            if match(item,'\.'.name.'\s*$')>=0
                let qn=1
                let name=item
                break
            endif
        endfor
    else
        let qn=1
    endif
    let cmd=''
    let namestr = name
    let namestr .= "|".join(a:names[1:-1],"|")
    if qn
        let cmd=g:vjde_java_command.' -jar "'.self.jar.'" "'.self.lib_path.'" "'.namestr.'" '.level
    else
	    call filter(impts,'v:val!="."')
        let cmd=g:vjde_java_command.' -jar "'.self.jar.'" "'.self.lib_path.'" "'.namestr.'" '.level.' '.join(impts,' ')
    endif
    let str = system(cmd)
    if strlen(str)<10
        let self.success=0
        return {}
    end
    let self.success=1
    let self.class = VjdeJavaClass_New( VjdeListStringToList(str))
    return self.class
endf
func! VjdeJavaCompletion_FindClass(name,imptstr,...) dict "{{{2
    let level = 0
    if  a:0 > 0
        let level = a:1
    endif
    let name=a:name
    let self.success = 0
    let imptstr = substitute(a:imptstr,'\*','','g')
    let impts = split(imptstr,'[; \t]')
    call filter(impts,'strlen(v:val)>0')
    let qn = 0
    if len(impts)>0
        for item in impts
            if match(item,'\.'.name.'\s*$')>=0
                let qn=1
		let name=item
                break
            endif
        endfor
    else
        let qn=1
    endif
    let cmd=''
    if qn
        let cmd=g:vjde_java_command.' -jar "'.self.jar.'" "'.self.lib_path.'" "'.name.'" '.level
    else
	    call filter(impts,'v:val!="."')
        let cmd=g:vjde_java_command.' -jar "'.self.jar.'" "'.self.lib_path.'" "'.a:name.'" '.level.' '.join(impts,' ')
    endif
    let str = system(cmd)
    if strlen(str)<10
        let self.success=0
        return {}
    end
    let self.success=1
    let self.class = VjdeJavaClass_New( VjdeListStringToList(str))
    return self.class
endf

func! VjdeJavaCompletion_New(jar,path)
    let inst = { 'jar':a:jar, 'lib_path':a:path , 'class':{}, 'success':0 ,
                \'FindClass':function('VjdeJavaCompletion_FindClass') ,
                \'FindClass2':function('VjdeJavaCompletion_FindClass2') }
    if inst.lib_path==""
        let inst.lib_path=''
    endif
    return inst
endf "}}}2

func! s:SearchPackages(jar,lib_path,prefix)
    let lib=''
    if  a:lib_path=='""'
        let lib=g:vjde_java_rt 
    else
        let lib=a:lib_path.g:vjde_java_rt
    endif
	let cmd=g:vjde_java_command.' -cp "'.a:jar.'" vjde.completion.PackageCompletion  "'.lib.'" '.a:prefix
	let array = split(system(cmd))
	return array
endf
func VjdeSearchClasses(jar,lib_path,prefix,base)
    return s:SearchClasses(a:jar,a:lib_path,a:prefix,a:base)
endf
func! s:SearchClasses(jar,lib_path,prefix,base)
    let lib=''
    if  a:lib_path=='""'
        let lib=g:vjde_java_rt 
    else
        let lib=a:lib_path.g:vjde_java_rt
    endif
	let jar_path = substitute(a:jar,'vjde\.jar$','','')
        let cmd=g:vjde_java_command.' -cp "'.a:jar.'" vjde.completion.PackageClasses  "'.lib.'" "'.a:prefix.'" "'
        let cmd.=substitute(jar_path,'\','/','g').'tlds/jdk1.5.lst" '.a:base
        return  split(system(cmd))
endf

func! VjdeJavaSearchPackagesAndClasses(jar,lib_path,prefix,base)
	let lib_path = a:lib_path
	if lib_path==''
		let lib_path='""'
	endif
	let array=[]
	if strlen(a:base) == 0 
		let array = s:SearchPackages(a:jar,lib_path,a:prefix)
		let array += s:SearchClasses(a:jar,lib_path,a:prefix,a:base)
		return array
	elseif a:base[0]=~'[A-Z]'
		return s:SearchClasses(a:jar,lib_path,a:prefix,a:base)
	else
		return s:SearchPackages(a:jar,lib_path,a:prefix.a:base)
	endif
endf
func! VjdeJavaSearch4Classes(jar,cname,lib_path)
	let jar_path = substitute(a:jar,'vjde\.jar$','','')
	let cmd=g:vjde_java_command.' -cp "'.a:jar.'" vjde.completion.ClassesByName '.a:cname.' "'.jar_path.'/tlds/jdk1.5.lst" '.a:lib_path.g:vjde_java_rt
	let array=[]
	let array += split(system(cmd))
	return array
endf
let g:vjde_java_cfu={}
"for item in VjdeJavaSearch4Classes(g:vjde_install_path.'/vjde/vjde.jar','String','')
	"echo item
"endfor
"for item in VjdeJavaSearchPackagesAndClasses(g:vjde_install_path.'/vjde/vjde.jar','""','java.util.','')
	"echo item
"endfor

"let javaMethod = VjdeJavaMethod_New(['toString', 'java.lang.String', 'int', 'java.util.Vector', ['Exece1', 'Exce2'],1])
"echo javaMethod.ToString()

"let javaConstructor = VjdeJavaConstructor_New(['java.lang.String', 'type[]',[] ])
"echo javaConstructor.ToString()

"let javaMeme = VjdeJavaMember_New(['wangfc', 'java.lang.String'])
"echo javaMeme.ToString()
"
"let mcfu = VjdeJavaCompletion_New('plugin/vjde/vjde.jar','""')
"let mclass= mcfu.FindClass('Vector','java.lang.*;java.util.*;')
"if mcfu.success
"for item in mclass.members
    "echo item.ToString()
"endfor
"for item in mclass.methods
    "echo item.ToString()
"endfor
"endif
"for item in mclass.constructors
    "echo item.to_s()
"endfor
"echo len(mclass.inners)
"for item2 in mclass.inners
    "echo item2
"endfor

"for item in VjdeJavaSearchPackages('vjde.jar','""','java.')
	"echo item
"endfor

"for item in VjdeJavaSearchClasses('vjde.jar','""','java.lang.','')
	"echo item
"endfor
"
" vim :ft=vim :fdm=marker :ff=unix
