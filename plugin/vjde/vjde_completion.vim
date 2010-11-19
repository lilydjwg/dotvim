if exists('g:vjde_completion') || &cp
    "finish
endif
if !exists('g:vjde_loaded') || &cp
	finish
endif

let g:vjde_completion=1 "{{{1
let s:key_preview=''
let s:preview_buffer=[]
let s:taglib_loaded=[]
let s:base_types=["void","int","long","float","double","boolean","char","byte"]
let s:directives={}
let s:types=[]
let s:cfu_type=0
let s:xml_start = -1
let s:wait_import=[]
let s:vjde_doccmd=''
func! s:VjdeDirectiveAttribute(name,...) "{{{2
	let attr = VjdeTagAttributeElement_New(a:name)
	if a:0>0
		let attr.values+=a:1
	endif
	return attr
endf
func! s:VjdeDirectiveInit() "{{{2
	let elepage = VjdeTagElement_New("page")
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("language",["java"]))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("extends"))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("import"))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("session",["true","false"]))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("buffer"))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("autoFlush",["true","false"]))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("isThreadSafe",["true","false"]))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("errorPage"))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("info"))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("isErrorPage",["true","false"]))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("pageEncoding",["GBK","GB2312","ISO-8859-1","UTF-8"]))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("contentType"))
	call elepage.AddAttribute(s:VjdeDirectiveAttribute("isELIgnored",["true","false"]))

	let eleinclude = VjdeTagElement_New("include")
	call eleinclude.AddAttribute(s:VjdeDirectiveAttribute("file"))

	let eletaglib  = VjdeTagElement_New("taglib")
	call eletaglib.AddAttribute(s:VjdeDirectiveAttribute("uri"))
	call eletaglib.AddAttribute(s:VjdeDirectiveAttribute("tagdir"))
	call eletaglib.AddAttribute(s:VjdeDirectiveAttribute("prefix"))

	let eleattr = VjdeTagElement_New("attribute")
	call eleattr.AddAttribute(s:VjdeDirectiveAttribute("name"))
	call eleattr.AddAttribute(s:VjdeDirectiveAttribute("type"))

	let s:directives['page']=elepage
	let s:directives['include']=eleinclude
	let s:directives['taglib']=eletaglib
	let s:directives['attribute']=eleattr
endf
call s:VjdeDirectiveInit()

func! VjdeAddToPreview(str) 
	call add(s:preview_buffer,a:str)
endf
func! VjdeClearPreview() 
	let s:preview_buffer=[]
endf
func! VjdeGetPreview() 
	return s:preview_buffer
endf

func! VjdeGetTypeName(var) "{{{2
        return s:GettypeName(a:var)
endf
func! s:GettypeName(var) " {{{2
    let l:firsttime = 0
    let l:firstpos = 0
    let l:oldl= line('.')
    let l:oldc= col('.')
    "let l:pattern = "\\<\\i\\+\\>\\(\\s*<.*>\\)*[\\[\\]\\t\\* ]\\+\\<".a:var."\\>"
    "let l:pattern = '\(return\|new\)\@!\<\i\+\>\(\s*<.*>\)*\(\s*\[.*\]\)*\s\+\<'.a:var.'\>'
    "let l:pattern = '\(return\)\@!\<\i\+\>\(\s*<.*>\)*\(\s*\[.*\]\)*\s\+\<'.a:var.'\>'
    "let l:pattern = '\(return\|import\|package\)\@!\<[^@\$=<>+\-\*\/%?:\&|\^ \t]\+\(\s*<.*>\)*\(\s*\[.*\]\)*\s*\<'.a:var.'\>'
    let l:pattern = '\(case\|return\|import\|package\|public\|private\|protected\|static\|final\|synchronzied\|native\)\@!\(\<\i\+\>\.\)*\<\i\+\>\(\s*<.*>\)*\(\s*\[.*\]\)*\s\+\<'.a:var.'\>'
    let l:ldefine=search(l:pattern,"b")
    while l:ldefine > 0 
        let l:curr_line = getline(l:ldefine)
        let l:col_index = match(l:curr_line,l:pattern)
        "if synIDattr(synID(l:ldefine,matchend(l:curr_line,l:pattern),1),"name") == ""
        "if synIDattr(synID(l:ldefine,l:col_index+1,1),"name") == ""
        let synname= synIDattr(synIDtrans(synID(l:ldefine,l:col_index+1,1)),"name")
        if synname != "Comment" && synname!="Constant" &&synname!="Special"
            call cursor(l:oldl,l:oldc)
            "let r = matchstr(l:curr_line,'\<\i\+\>',l:col_index)
            let r = matchstr(l:curr_line,'[^ \t\[<]\+',l:col_index)
            "let r = matchstr(l:curr_line,'[^ \t]*',l:col_index)
            if r=='new'
                return a:var
            else 
                return r
            endif
        else
            if ( l:firsttime == 0 )
                let l:firsttime = 1
                let l:firstpos = l:ldefine
            else
                if ( l:firstpos == l:ldefine)
                    call cursor(l:oldl,l:oldc)
                    return ""
                endif
            endif
            let l:ldefine=search(l:pattern,"b")
        endif
    endw
    call cursor(l:oldl,l:oldc)
    return ""
endf

func! VjdeCommentFun(line,base,col,findstart) "{{{2
    if a:findstart
        return VjdeFindStart(a:line,a:base,a:col,'[@ \t"]')
    endif
    let ele = a:line[s:last_start-1]=='@'
    let g:vjde_tag_loader = VjdeTagLoaderGet("xdoclet",g:vjde_install_path.'/vjde/tlds/xdoclet.def')
    if ele  " element
        call VjdeTagCompletion('',a:base,2)
        return s:retstr
    endif
    let l = search('\*\s*@[^ \t]\+','nb')
    if l<=0 
        return ""
    endif
    let tag = strpart(matchstr(getline(l),'@[^ \t]\+',0),1)

    let ele = a:line[s:last_start-1]=~'[ \t]'
    if ele " attribute
        call VjdeTagCompletion(tag,a:base,3)
        return s:retstr
    endif
    let id1=VjdeFindStart(a:line,'',a:col,'[ \t]')
    let id2=VjdeFindStart(a:line,'',a:col,'[=]')
    if ( id1 < 0 || id2<id1)
        return id1."--".id2
    endif
    call VjdeTagCompletion(tag,strpart(a:line,id1,id2-id1-1),11,a:base)
    return s:retstr
endf



func! s:VjdeGetAllTaglibPrefix() "{{{2
    let l:line_imp = search ('^\s*<%@\s\+taglib\s\+\>',"nb")
    let l:res = []
    if l:line_imp == 0 
        return l:res
    endif
    while l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let index = matchend(l:str,'^\s*<%@\s\+taglib\s\+.*\<uri\>\s*="')
        if  index!= -1 
            let index2 = SkipToIgnoreString(l:str,index+1,'"')
            if index2 >index+1
                call add(l:res,strpart(l:str,index+1,index2-index-1))
            endif
        endif
        let l:line_imp -= 1
    endw

    return l:res
endf
func! s:GetJspImportStr() "{{{2
    let l:line_imp = search ('^\s*<%@\s\+page\s\+\<import\>',"nb")
    let l:res = "java.lang.*;"
    if l:line_imp == 0 
        return l:res
    endif
    while l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let index = matchend(l:str,'^\s*<%@\s\+page\s\+\<import\>\s*="')
        if  index!= -1 
            let index2 = SkipToIgnoreString(l:str,index+1,'"')
            if index2 >index+1
                let l:res =l:res.strpart(l:str,index,index2-index)
                if l:str[index2-1]!=';'
                    let l:res = l:res.';'
                endif
            endif
        endif
        let l:line_imp -= 1
    endw

    return substitute(l:res,',',';','g')
endf


func! s:VjdeCompletionByVIM(imps,...) "{{{2
    let level=0
    if ( a:0  > 0 ) 
        let level = a:1
    endif
	if empty(g:vjde_java_cfu)
		"let g:vjde_java_cfu = VjdeJavaCompletion_New(g:vjde_install_path.'/vjde/vjde.jar',g:vjde_lib_path)
		let g:vjde_java_cfu = VjdeJavaCompletion_New(g:vjde_install_path.'/vjde/vjde.jar',g:vjde_out_path.g:vjde_path_spt.g:vjde_lib_path)
	endif
	if index(s:base_types,s:type)>=0
		return 0
	endif
	"call g:vjde_java_cfu.FindClass(s:type,a:imps)
	"if !g:vjde_java_cfu.success
	"	return 0
	"endif
    let s:types[0]=s:type
    if len(s:types)>1
        call g:vjde_java_cfu.FindClass2(s:types,a:imps,level)
    else
        call g:vjde_java_cfu.FindClass(s:type,a:imps,level)
    endif
    let s:success=g:vjde_java_cfu.success
    return s:success
"	let index =1
"	let length = len(s:types)
"	let success = g:vjde_java_cfu.success
"	while index < length && success
"		let returntype = ''
"		for member in g:vjde_java_cfu.class.members
"			if s:types[index]==member.name
"				let returntype = member.type
"			endif
"		endfor
"		if returntype==''
"			for method in g:vjde_java_cfu.class.methods
"				if s:types[index] == method.name
"					let returntype=method.ret_type
"				endif
"			endfor
"		endif
"		if returntype==''
"			let success = 0
"		else
"			if index(s:base_types,returntype)>=0
"				let success = 0
"			else
"				call g:vjde_java_cfu.FindClass(returntype,'')
"				let success = g:vjde_java_cfu.success
"			endif
"		endif
"		let index+=1
"	endwhile
"	let s:success = success
"	return s:success
endf

func! VjdeCompletionFun0(findstart,base)
	if a:findstart
		return VjdeCompletionFun(getline('.'),a:base,col('.'),a:findstart)
	endif
	let lval = VjdeCompletionFun(strpart(getline('.'),0,col('.')),a:base,col('.'),a:findstart)
        if type(lval) ==3 " List
            return lval
        endif
	if strlen(s:retstr)<2
		return []
	else
		return split(s:retstr,"\n")
	endif
endf
"1 java 0 taglib 2 html 3 comment 4 xsl
func! VjdeCompletionFun(line,base,col,findstart) "{{{2
    if a:findstart 
        let ext = &ft "expand('%:e')
        if ext == 'java'
            if synIDattr(synIDtrans(synID(line('.'),a:col-1,1)),"name") == "Comment"
                let s:cfu_type=3
            else
                let s:cfu_type=4
            endif
        elseif ext=='jsp' " 0 1 2
            let t = s:VjdeJspTaglib() 
            let s:cfu_type=t
			"call confirm(s:cfu_type)
        elseif ext=='xsl'
            let s:cfu_type=5
        endif
    endif

    if s:cfu_type == 0 "taglib
		return s:VjdeTaglibCompletionFun(a:line,a:base,a:col,a:findstart)
		if  s:xml_start == 0
			let id1 = VjdeFindUnendPair(a:line,'<','>',0,a:col) " TODO:find uncompleted <
			let id2 = stridx(a:line,':',id1)
			if ( id2 == -1 && id1>=0 ) " this is a <%@ ....
				if a:findstart
					call VjdeFindStart(a:line,a:base,a:col,'[ \t:@"]')
					return s:last_start
				endif
				call s:VjdeDirectiveCFUVIM(a:line,a:base,a:col,a:findstart)
				return s:retstr
			endif
		endif
		if a:findstart 
			call VjdeFindStart(a:line,a:base,a:col,'[ \t:@"]')
			return s:last_start
		endif
		if (s:last_start>= 0 ) 
			"call confirm(getline('.'))
			"call confirm(s:last_start)
			"call confirm(col('.'))
			"let l:str2 = strpart(line,s:last_start,col('.')-s:last_start)
			"call confirm(l:str2)
			return s:VjdeTaglibCompletionFun(a:line,a:base,a:col,a:findstart)
			"let l:str2 = strpart(line,s:xml_start,col('.')-s:xml_start)
			"return xmlcomplete#CompleteTags(0,l:str2)
		else
			return ""
		endif
    elseif s:cfu_type==1 "java in jsp
		"call confirm('here')
	    return s:VjdeJspCompletionFun(a:line,a:base,a:col,a:findstart)
    elseif s:cfu_type==2 "html
        if a:findstart 
            "let s:last_start = htmlcomplete#CompleteTags(1,'')
            "return s:last_start
			return VjdeFindStart(a:line,a:base,a:col,'[ \t:@"<]')
        endif
			return s:VjdeTaglibCompletionFun(a:line,a:base,a:col,a:findstart)
    elseif s:cfu_type==3 "comment
            let s:retstr= VjdeCommentFun(a:line,a:base,a:col,a:findstart)
    elseif s:cfu_type==4 "java
        return s:VjdeJavaCompletionFun(a:line,a:base,a:col,a:findstart)
    endif
    if g:vjde_show_preview && strlen(s:retstr)!=0
	    let s:beginning=a:base
	    let s:key_preview=''
    endif
    return s:retstr
endf
"1 java in jsp 0 taglib 2 html
func! s:VjdeJspTaglib() "{{{2
        let grp = synIDattr(synIDtrans(synID(line('.'),col('.'),1)),"name")
        if (grp == 'jspExpr' || grp=='jspScriptlet' || grp=='jspDecl')
            return 1
        else
             let ed = matchend(getline(line('.')),'^\s*<%') 
             if ( ed != -1)
                 return 0
             endif
             let ed = matchend(getline(line('.')),'^\s*<jsp:') 
             if ( ed!=-1) 
                 return 2
             endif
             let ed = matchend(getline(line('.')),'^\s*<[0-9a-zA-Z]\+:') 
             if ( ed != -1)
                 return 0
             endif
             let ed = matchend(getline(line('.')),'^\s*<') 
             if ( ed != -1)
                 return 2
             endif
			call VjdeFindStart(getline(line('.')),'',col('.'),'[ \t:@"]')
			let pf = VjdeXMLPrefix(getline(line('.')),'',col('.'),1)
			if pf[1] != -1 
				if strlen(pf[0]) > 0 
					return 0
				else
					if match(getline(pf[1]),':')> 0 
						return 2
					endif
					return 1
				endif
			endif
			return 1
         endif
endf

func! s:VjdeParentCFUVIM(pars,imps) "{{{2
	let s:preview_buffer=[]
        let lval=[]
for par in a:pars
    let s:type = par
    call s:VjdeCompletionByVIM(a:imps,1)
    if !g:vjde_java_cfu.success
        continue
    endif
    if g:vjde_show_preview
	    call s:VjdeGeneratePreviewBuffer(s:beginning)
    endif
    let lval +=s:VjdeGeneratePreveiewMenu(s:beginning)
endfor
return lval
endf

func! s:VjdePkgCfuByVIM(prefix,base)
	let s:preview_buffer=[]
    call add(s:preview_buffer,'import '.a:prefix.':')
    let len = strlen(a:prefix)
    let lval = [] 
    let isclass=0
    for item in VjdeJavaSearchPackagesAndClasses(g:vjde_install_path.'/vjde/vjde.jar',g:vjde_lib_path,a:prefix,a:base)
	    let part = strlen(item) > len ? strpart(item,len) : item
	    
	    let s:retstr.= part."\n"
	    if isclass
		    call add(lval,{'word': item, 'info': 'class '.item,'icase':0})
	    else
		    if item[0] =~'[a-z]'
                            call add(lval,{'word': part , 'info': 'package '.item,'icase':0 })
		    else
                            call add(lval,{'word': item , 'info': 'class '.item.'.class' ,'icase':0})
			    let isclass = 1
		    endif
	    endif
    endfor
    return lval
endf
func! s:VjdeJavaCompletionFun(line,base,col,findstart) "{{{2
    if a:findstart
        return VjdeFindStart(a:line,a:base,a:col,'[.@ \t(]')
    endif
    let s:beginning = a:base
    let lll = substitute(getline('.'),'^\s*\([^ \t(]*\)[ \t(].*$','\1','')
    if strlen(lll)>0
	    if lll[0]=='@'
		    "call add(s:types , lll[1:-1])
		    "let s:type=s:types[0]
		    let types2=VjdeGetAnnotationObjects(strpart(getline('.'),0,col('.')))
		    if len(types2)==0 
			    return ""
		    endif
		    let s:type=types2[0][0:-2]
		    let s:types=[]
		    call add(s:types,s:type)
		    let l:imps = GetImportsStr()
		    call s:VjdeCompletionByVIM(l:imps)
		    "echo g:vjde_java_cfu
		    if !g:vjde_java_cfu.success
			    let s:retstr=""
		    else
			    if len(types2) > 1
				    let name='value'
				    if strlen(types2[1])>1
					    let name=types2[1][0:-3]
				    endif
				    return s:VjdeAnnotationPreveiewMenu2(name) 
			    endif
			    return s:VjdeAnnotationPreveiewMenu(s:beginning) 
		    endif
		    return s:retstr
	    endif
    endif
    if a:line[s:last_start-1]=='('
	    let retdict = VjdeJavaParameterPreview(2)
            for item in retdict
                let item.abbr= item.word
                let item.word=' '
                let item.dup=1
            endfor
	    call add(retdict,{'abbr' : 'Parameters' , 'word' : ' ', 'dup' : 1})
            return retdict
    endif

    let s:retstr=""
    let idx = match(a:line,'^\s*import\s*')
    if ( idx >= 0 ) 
        let str = substitute(a:line,'\s*import\s*\(static\)*\s*\(.*\)','\2','')
	return s:VjdePkgCfuByVIM(str,a:base)
    endif
    if a:line[s:last_start-1]=='@'
        call VjdeCommentFun(a:line,a:base,a:col,a:findstart)
        return s:retstr
    endif


    let l:imps = GetImportsStr()

    let s:types=[]
    if a:line[s:last_start-1]=~'[ \t]'
        let ps = VjdeFindParent(1)
        let lval = s:VjdeParentCFUVIM(ps,l:imps)
        if len(lval)==0 " not found , completion for package
            return s:VjdePkgCfuByVIM('',a:base)
	endif
        return s:retstr
    endif

    "let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(a:line,0,a:col)))
    let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(a:line,0,s:last_start)))


    if  len(s:types)<1 
		return s:VjdePkgCfuByVIM('',a:base)
        "return ""
    endif

    if   len(s:types)<1 || s:types[0]== "this"|| s:types[0]== "super"
        "TODO add parent implements here
        let ps = VjdeFindParent(len(s:types)<1 || s:types[0]=="this")
        return s:VjdeParentCFUVIM(ps,l:imps)
        return s:retstr
    endif
    
    let staticcfu=0
    let s:type=s:GettypeName(s:types[0])
    if s:type == ""
	
	if s:types[0][0]=~'[a-z]' " something like java.util ...
		return s:VjdePkgCfuByVIM(join(s:types,'.').'.',a:base)
	endif
        let s:type=s:types[0]
	let staticcfu = 1
    end

    
    call s:VjdeCompletionByVIM(l:imps)
    if !g:vjde_java_cfu.success
	    let s:retstr=""
    else
	    if g:vjde_show_preview
		  call s:VjdeGeneratePreviewBuffer(s:beginning)
	    endif
	    "return s:VjdeCreateString4CFU(s:beginning)
            return s:VjdeGeneratePreveiewMenu(s:beginning)
    endif
    return s:retstr
endf

func! s:VjdeCreateString4CFU(base) "{{{2
    let str=''
    if strlen(a:base)==0
        for member in g:vjde_java_cfu.class.members
            let str.=member.name."\n"
        endfor
        for method in g:vjde_java_cfu.class.methods
            let str.=method.name."\n"
        endfor
    else
        for member in g:vjde_java_cfu.class.SearchMembers('stridx(member.name,"'.a:base.'")==0')
            let str.=member.name."\n"
        endfor
        for method in g:vjde_java_cfu.class.SearchMethods('stridx(method.name,"'.a:base.'")==0')
            let str.=method.name."\n"
        endfor

    endif
    return str
endf

func! VjdespFun(line) "{{{2
    echo VjdeObejectSplit(a:line)
endf

func! s:VjdeInfomation() "{{{2
    let ext = expand('%:e')
    if ext == 'java'
        return VjdeInfo()
    elseif ext=='jsp'
        let t = s:VjdeJspTaglib()
        if t == 1
            return s:VjdeJspInfo()
        elseif t == 0
            return s:VjdeTaglibInfo()
        else
            return 
        endif
    elseif ext=='xsl'
        return s:VjdeXslInfo()
    endif
endf
func! s:VjdeGotoDecl() "{{{2
    let key = expand('<cword>')
    let m_line = line('.')
    let m_col = col('.')
    let line = getline(m_line)
    let idx = matchend(line,'.\>',m_col)
    let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(line,0,idx)).".")
    if len(s:types)<1
        echo "no object find by ".key
        return 
    endif
    if s:types[0]== "this"
        "TODO add parent implements here
        return ""
    endif
    let s:type=s:GettypeName(s:types[0])
    if s:type == ""
        let s:type=s:types[0]
    end

    let l:imps = GetImportsStr()
    if expand("%:e")=="jsp"
	    let l:imps = s:GetJspImportStr()
    endif
    let s:retstr=""

    if ( len(s:types) > 1 )
        let s:beginning = remove(s:types,-1)
    else 
        let s:beginning = ""
    endif
 
    call s:VjdeCompletionByVIM(l:imps)

    let classname=''
    if g:vjde_java_cfu.success
	    let classname=g:vjde_java_cfu.class.name
    else
        echo 'class under cursor is not found.'
        return
    endif
    if g:vjde_auto_mark == 1
        mark J
    endif
    for mpath in split(&path.';'.g:vjde_src_path,';')

        let fp = findfile(substitute(classname,'\.','/','g').'.java',mpath)
        if fp != ''
            exec 'edit '.fp
        else
            continue
        endif
        if s:beginning == "" 
            return 
        endif
        call search('\s*\(\<public\|protected\|\)\s*\(static\s\|virtual\s\|final\s\)*[^ \t]\+\s\+\<'.s:beginning.'\>','w')
            return
        endfor
        echo 'source for :'.classname.' is not found in[path]:'.&path
        return
endf
func! s:VjdeTaglibPrefix(line) "{{{2
    let id1 = stridx(a:line,'<')
    let id2 = stridx(a:line,':',id1)
    if ( id1 < 0 || id2<id1) 
        return ""
    endif
    return strpart(a:line,id1+1,id2-id1-1)
endf
func! s:VjdeTaglibTag(line) "{{{2
    let id1 = stridx(a:line,':')
    let id2 = SkipToIgnoreString(a:line,id1,'[ \t]')
    if ( id1 < 0 || id2<id1) 
        return ""
    endif
    return strpart(a:line,id1+1,id2-id1-1)
endf
func! s:VjdeTaglibInfo() "{{{2
    let key = expand('<cword>')
    let m_line = line('.')
    let m_col = col('.')
    let line = getline(m_line)
    let start=m_col
    let isattr=0
    while start >=0
        if line[start] =~ '[ \t]'
            let isattr = 1
            break
        elseif line[start]==':'
            let isattr = 0
            break
        end
        let start = start-1
    endw
    let prefix = s:VjdeTaglibPrefix(line)
    if prefix=='jsp'
        let uri="http://java.sun.com/jsp/jsp"
    "elseif prefix=='xsl'
    else
        let uri = s:VjdeTaglibGetURI(prefix)
        if (uri == '')
            return "no found uri for prefix:".prefix
        endif
    endif
    let tag = s:VjdeTaglibTag(line)
    if isattr
        if ( tag == '' ) 
            echo "no found tag for :".line
            return
        endif
        call s:VjdeTaglibInfoRuby(uri,key,"1",tag)
    else
        call s:VjdeTaglibInfoRuby(uri,key,"0","")
    endif
endf

func! VjdeFindClassUnderCursor() "{{{2
    let key = expand('<cword>')
    let m_line = line('.')
    let m_col = col('.')
    let line = getline(m_line)
    let idx = matchend(line,'.\>',m_col-1)
    let curr_part = strpart(line,0,idx)
    let matchdef = matchend(line,'\(\<\i\+\.\>\)*\(public\|private\|static\|protected\|final\)\@!\<\(\(\i\+\|'.key.'\)\)\>\(\s*<.*>\)*\(\s*\[.*\]\)*\s\+\<\(\i\+\|'.key.'\)\>',0)
    if matchdef>=0
	    let s:types=[]
	    if matchdef==idx
		    let s:type=s:GettypeName(key)
	    else
		    let s:type=key
	    endif
    else
	    let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(line,0,idx)).".")
	    if len(s:types)<1
		echo "no object find by ".key
		return 
	    endif
	    if s:types[0]== "this"
		"TODO add parent implements here
		return ""
	    endif
	    let s:type=s:GettypeName(s:types[0])
	    if s:type == ""
		let s:type=s:types[0]
	    endif
    endif

    let l:imps = GetImportsStr()
    let s:retstr=""

    if ( len(s:types) > 1 )
        let s:beginning = remove(s:types,-1)
    else 
        let s:beginning = ""
    endif
    echo s:type
 
    call s:VjdeCompletionByVIM(l:imps)
    if !g:vjde_java_cfu.success
	    let s:retstr=''
    else
	    let s:retstr = s:VjdeCreateString4CFU(s:beginning)
    endif
endf
func! VjdeInfo(...) "{{{2
	call VjdeFindClassUnderCursor()
	if a:0 >=1 && a:1==1
		return
	endif

	if g:vjde_java_cfu.success
		call s:VjdeGeneratePreviewBuffer(s:beginning)
		if g:vjde_use_window == 1
			call VjdeWindowClear()
			for item in s:preview_buffer
				call VjdeWindowAdd(item)
			endfor
		else
			for item in s:preview_buffer
				echo item
			endfor
		endif
	endif
endf


func! s:VjdeJspInfo() "{{{2
    let key = expand('<cword>')
    let m_line = line('.')
    let m_col = col('.')
    let line = getline(m_line)
    let idx = matchend(line,'.\>',m_col)
    let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(line,0,idx)).".")
    if len(s:types)<1
        echo "no object find by ".key
        return 
    endif
    if s:types[0]== "this"
        "TODO add parent implements here
        return ""
    endif
    let s:type=s:GettypeName(s:types[0])
    if s:type == ""
        let s:type=s:types[0]
    end

    let l:imps = ""
    
    if s:types[0] == 'out'
        let s:type = 'javax.servlet.jsp.JspWriter'
    elseif s:types[0]=='request'
        let s:type = 'javax.servlet.ServletRequest'
    elseif s:types[0]=='response'
        let s:type = 'javax.servlet.ServletResponse'
    elseif s:types[0]=='page'
        let s:type = 'java.lang.Object'
    elseif s:types[0]=='session'
        let s:type = 'javax.servlet.http.HttpSession'
    elseif s:types[0]=='application'
        let s:type = 'javax.serlet.ServletContext'
    else
        let s:type=s:GettypeName(s:types[0])
        if s:type == ""
            let s:type=s:types[0]
        end
        "TODO find the import for jsp pages
        let l:imps = s:GetJspImportStr()
    endif
 

    "let l:imps = GetImportsStr()
    let s:retstr=""

    if ( len(s:types) > 1 )
        let s:beginning = remove(s:types,-1)
    else 
        let s:beginning = ""
    endif
 
    call s:VjdeCompletionByVIM(l:imps)

    if g:vjde_java_cfu.success
	    call s:VjdeGeneratePreviewBuffer(s:beginning)
	    for item in s:preview_buffer
		    echo item
	    endfor
    endif
endf
func! s:VjdeJspCompletionFun(line,base,col,findstart) "{{{2
    if a:findstart
        return VjdeFindStart(a:line,a:base,a:col,'[\.]')
    endif

    let s:beginning = a:base

    "call s:VjdeObejectSplit(s:VjdeFormatLine(strpart(a:line,0,a:col)).'.')
    let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(a:line,0,a:col)))
    "call s:VjdeObejectSplit(a:line)

    if  len(s:types)<1 
        return ""
    endif
    if s:types[0]== "this"
        "TODO add parent implements here
        return ""
    endif
    let l:imps=""
    let l:imps = s:GetJspImportStr()

    if s:types[0] == 'out'
        let s:type = 'javax.servlet.jsp.JspWriter'
    elseif s:types[0]=='request'
        let s:type = 'javax.servlet.http.HttpServletRequest'
    elseif s:types[0]=='response'
        let s:type = 'javax.servlet.http.HttpServletResponse'
    elseif s:types[0]=='page'
        let s:type = 'java.lang.Object'
    elseif s:types[0]=='session'
        let s:type = 'javax.servlet.http.HttpSession'
    elseif s:types[0]=='application'
        let s:type = 'javax.serlet.ServletContext'
    else
        let s:type=s:GettypeName(s:types[0])
        if s:type == ""
		if s:types[0][0]=~'[a-z]' " something like java.util ...
			return s:VjdePkgCfuByVIM(join(s:types,'.').'.',a:base)
		endif
		let s:type=s:types[0]
        end
        "TODO find the import for jsp pages
    endif
    

    let s:retstr=""
    call s:VjdeCompletionByVIM(l:imps)

    if !g:vjde_java_cfu.success
	    let s:retstr=""
    else
	    "let s:retstr=s:VjdeCreateString4CFU(s:beginning)
            
	    if g:vjde_show_preview 
		  call s:VjdeGeneratePreviewBuffer(s:beginning)
	    endif
            return s:VjdeGeneratePreveiewMenu(s:beginning)
    endif
    return s:retstr
endf

"attr 1 is attribute completion
func! s:VjdeTaglibCompletionXmldata2(datafile,base,attr,tag) "{{{2
	let retitems=[]
	let ff=strlen(a:base)
	let datafile=a:datafile
if a:attr==1
	if !has_key(datafile,a:tag)
		let s:retstr=''
		return ""
	endif
	let t = datafile[a:tag]
	let ainfo={}
	if has_key(datafile, 'vimxmlattrinfo') 
		let ainfo= datafile['vimxmlattrinfo']
	endif
	"attrbiute for
	for key in keys(t[1])
		if ff>0
			if stridx(key,a:base) != 0 
				continue
			endif
		endif
		let row={'word' : key }
		if has_key(ainfo , key) 
			let row['menu']= ainfo[key][0]
			let row['info']= ainfo[key][1]
		endif
		call add(retitems,row)
	endfor
	if ( strlen(a:base)>0)
	endif
	return retitems
else
	let ainfo={}
	if has_key(datafile, 'vimxmltaginfo') 
		let ainfo= datafile['vimxmltaginfo']
	endif
	for key in keys(datafile)
		if ff>0
			if stridx(key,a:base) != 0 
				continue
			endif
		endif
		if stridx(key, 'vimxml')==0
			continue
		endif
		let row={'word' : key }
		if has_key(ainfo , key) 
			let row['menu']= ainfo[key][0]
			let row['info']= ainfo[key][1]
		endif
		call add(retitems,row)
	endfor	
endif
return retitems
endf
func! s:VjdeTaglibCompletionXmldata(uri,base,attr,tag) "{{{2
	let xf = g:vjde_taglib_uri[a:uri]
	let datafile = g:xmldata{'_'.xf}
	return s:VjdeTaglibCompletionXmldata2(datafile,a:base,a:attr,a:tag)
endf 
func! s:VjdeTaglibCompletionFun(line,base,col,findstart) "{{{2
    if a:findstart
        return VjdeFindStart(a:line,a:base,a:col,'[ \t:@<"]')
    endif
    let s:retstr=""
	let prefix2 = VjdeXMLPrefix(a:line,a:base,a:col,a:findstart)
	if  prefix2[1]==-1
        return s:retstr
	endif
    let id5 = a:col
    while id5 >=0 
        if a:line[id5]=~'[ \t:<]'
            break
        endif
        let id5-=1
    endw
    if id5 < 0 
        return "unknown"
    endif
    let id2 = stridx(getline(prefix2[1]),':',prefix2[2])
    if ( id2 == -1 ) " this is a <%@ ....
		"html
		if strlen(prefix2[0])==0 
			"element
			if match(a:line,'<%') >=0
				call s:VjdeDirectiveCFUVIM(a:line,a:base,a:col,a:findstart)
				return s:retstr
			endif
			if a:line[id5]=='<' 
				return s:VjdeTaglibCompletionXmldata2(g:xmldata_html401t,a:base,0,'')
			else " attribute
				let line = getline(prefix2[1])
				let id2 = match(line,'<',0)
				let id3 = match(line,'[ \t]',id2)
				if ( id3 < id2 ) 
				endif
				let tag = strpart(line,id2+1,id3-id2-1)
				return s:VjdeTaglibCompletionXmldata2(g:xmldata_html401t,a:base,1,tag)
			endif
		endif
        return s:retstr
    endif
    let prefix=prefix2[0]
    if prefix=='jsp'
        let uri="http://java.sun.com/jsp/jsp"
	else
		let uri = s:VjdeTaglibGetURI(prefix)
    endif
	if index(s:taglib_loaded,uri) < 0 
		if ( has_key(g:vjde_taglib_uri,uri))
			exe "runtime autoload/xml/".g:vjde_taglib_uri[uri].".vim"
			"exec 'XMLns '. g:vjde_taglib_uri[uri].' '.prefix
		endif
		call add(s:taglib_loaded,uri)
	endif
	if !has_key(g:vjde_taglib_uri,uri)
		return s:retstr
	end

    if a:line[id5]!=':' 
		let line = getline(prefix2[1])
        let id3 = match(line,'[ \t]',id2)
        if ( id3 < id2 ) 
        endif
        let tag = strpart(line,id2+1,id3-id2-1)
        "call s:VjdeTaglibCompletionRuby(uri,a:base,1,tag)
        return s:VjdeTaglibCompletionXmldata(uri,a:base,1,tag)
    else 
        "call s:VjdeTaglibCompletionRuby(uri,a:base,0,'')
        return s:VjdeTaglibCompletionXmldata(uri,a:base,0,'')
    endif
    return s:retstr
endf


func! s:VjdeTaglibGetURI(prefix)  "{{{2
    let l:line_tld = search('prefix\s*=\s*"'.a:prefix.'"\s*',"nb")
    if l:line_tld==0
        return ''
    endif
    return substitute(getline(l:line_tld),'.\+\suri\s*=\s*"\([^"]*\)".*','\1',"")
endf

func! s:VjdeDirectiveCFUVIM(line,base,col,findstart) "{{{2
    let s:preview_buffer=[]
    let str=''
    let attr= match(a:line,'<%@\s\+\(page\|include\|taglib\|attribute\)\s')>=0?1:0
    "let attr = ( a:line[s:last_start-1]=='"' )
    if attr
	    let mtag = matchstr(a:line,'\(page\|include\|taglib\|attribute\)')
	    if mtag==''
		    return ''
	    endif
	    call add(s:preview_buffer,mtag.'=>attributes:')
	    let attr = ( a:line[s:last_start-1]=='"' )
	    if attr
		    let id1=VjdeFindStart(a:line,'',a:col,'[ \t]')
		    let id2=VjdeFindStart(a:line,'',a:col,'[=]')
		    if ( id1 < 0 || id2<id1)
			    return ""
		    endif
		    let attrname = strpart(a:line,id1,id2-id1-1)
		    for attribute in s:directives[mtag].attributes
			    if attribute.name == 'uri'
				    let str=join(keys(g:vjde_taglib_uri),"\n")
				    break
			    endif
			    if  attribute.name==attrname
				    let str = join(attribute.values,"\n")
				    break
				    "call add(s:preview_buffer,'attribute '.attribute.name.';')
			    endif
		    endfor
	    else 
		    for attribute in s:directives[mtag].attributes
			    if  stridx(attribute.name,a:base)==0
				    let str.=attribute.name."\n"
				    "call add(s:preview_buffer,'attribute '.attribute.name.';')
			    endif
		    endfor
	    endif
    else
	    for mdir in keys(s:directives)
		    if  stridx(mdir,a:base)==0
			    let str.=mdir."\n"
			    "call add(s:preview_buffer,'Directive '.mdir.';')
		    endif
	    endfor
    endif
    let s:retstr=str

    return s:retstr
endf
" uri http://java.... ; base ; attr 1 find attr 0 find tag
"

func! s:VjdeXslInfo() "{{{2
    let key = expand('<cword>')
    let m_line = line('.')
    let m_col = col('.')
    let line = getline(m_line)
    let start=m_col
    let isattr=0
    while start >=0
        if line[start] =~ '[ \t]'
            let isattr = 1
            break
        elseif line[start]==':'
            let isattr = 0
            break
        end
        let start = start-1
    endw
    let prefix = s:VjdeTaglibPrefix(line)

    if prefix!='xsl'
        echo "this cfu not useable for:".prefix
        return s:retstr
    endif
    let uri="http://www.w3c.org/1999/XSL/Transform"

    let tag = s:VjdeTaglibTag(line)
    if isattr
        if ( tag == '' ) 
            echo "no found tag for :".line
            return
        endif
    else
    endif
endf

func! s:VjdeXMLSetupNSLoader(prefix) "{{{2
    let l:line_imp = search('\sxmlns:'.a:prefix.'="[^"]*"','nb') " find xmlns:{name}=\".............\"
    if l:line_imp <= 0
        return 0
    endif
    let l:str = matchstr(getline(l:line_imp),'\sxmlns:'.a:prefix.'="[^"]*"')
    let id1 = stridx(l:str,'"')
    let ns = strpart(l:str,id1+1,strlen(l:str)-id1-2)
    if ns == 'http://www.w3c.org/1999/XSL/Transform' || ns == 'http://www.w3.org/1999/XSL/Transform'
        ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("xsl",VIM::evaluate('g:vjde_install_path')+"/vjde/tlds/xsl.def")
        let s:isfind=1
        return 
    elseif ns == 'http://www.w3.org/TR/html401' || ns == 'http://www.w3.org/TR/html4'|| ns == 'http://www.w3.org/TR/html'
        ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("html",VIM::evaluate('g:vjde_install_path')+"/vjde/tlds/html.def")
        let s:isfind = 1
        return
    end
    let s:isfind = 0
ruby<<EOF
   loader = $vjde_dtd_loader.find(VIM::evaluate("ns"))
   $vjde_def_loader=loader if loader!=nil
   VIM::command("let s:isfind=1") if loader!=nil
EOF
endf
func! s:VjdeXMLFindDTD() "{{{2
    let l:line_imp = search('<!DOCTYPE\s\+[^ \t]\+\s\+','nb') 
    "let l:line_imp = search('<!DOCTYPE\s\+[^ \t]\+\s\+SYSTEM\s\+"[^"]\+"','nb') 
    if l:line_imp <= 0
        let s:isfind = 0
        return
    endif
    "let l:str = matchstr(getline(l:line_imp),'<!DOCTYPE\s\+[^ \t]\+\s\+SYSTEM\s\+"[^"]\+"')
    "let id1 = stridx(l:str,'"')
    "let ns = strpart(l:str,id1+1,strlen(l:str)-id1-2)
    let s:isfind = 0
ruby<<EOF
    lnum = VIM::evaluate("l:line_imp").to_i
    str = VIM::Buffer.current[lnum]
    while str['>'] ==nil
        lnum +=1 
        str << " " << VIM::Buffer.current[lnum]
    end
    loader = nil
    str.sub!(/<!DOCTYPE\s+([^ \t]+)\s+(PUBLIC|SYSTEM)\s+"([^"]+)"\s*("([^"]*)")*/) { |p| 
        loader = $vjde_dtd_loader.find($3) if $3!=nil
        loader = $vjde_dtd_loader.find($5) if loader==nil && $5!=nil
    }
    $vjde_def_loader=loader if loader!=nil
    VIM::command("let s:isfind=1") if loader!=nil
EOF
endf


func! VjdeHTMLFun0(findstart,base)
	if a:findstart
		return VjdeHTMLFun(getline('.'),a:base,col('.'),a:findstart)
	endif
	call VjdeHTMLFun(strpart(getline('.'),0,col('.')),a:base,col('.'),a:findstart)
	if strlen(s:retstr)<2
		return []
	else
		return split(s:retstr,"\n")
	endif
endf
func! VjdeHTMLFun(line,base,col,findstart) "{{{2
    if a:findstart
        return VjdeFindStart(a:line,a:base,a:col,'[ \t=<"]')
    endif
    let s:retstr=""

    let ele = a:line[s:last_start-1]=='<'
    if ele " element
       call VjdeTagCompletion('',a:base,2)
       return s:retstr
    endif
    let def_line = search('<','nb')
    if def_line == -1
        return ' I can not find <'
    endif
    let def_col = a:col
    if  def_line < line('.')
        let def_col=9999
    endif

    let def_l = getline(def_line)
    let id1 = VjdeFindUnendPair(def_l,'<','>',0,def_col)
    let id2 = SkipToIgnoreString(def_l,id1,'[ \t]')
    if id1 < 0 || id2 <=id1
        return ""
    endif
    let tag = strpart(def_l,id1+1,id2-id1-1)

    let ele = a:line[s:last_start-1]=~'[ \t]'
    if ele " attribute
        call VjdeTagCompletion(tag,a:base,3)
        return s:retstr
    endif

    let id1=VjdeFindStart(a:line,'',a:col,'[ \t]')
    let id2=VjdeFindStart(a:line,'',a:col,'[=]')
    if ( id1 < 0 || id2<id1)
        return id1."--".id2
    endif
    let ele = a:line[s:last_start]=='"'
    "echo tag
    "echo strpart(a:line,id1,id2-id1-1)
    "echo a:base
    call VjdeTagCompletion(tag,strpart(a:line,id1,id2-id1-1),10+ele,a:base)
    return s:retstr
endf

func! VjdeFindStart(line,base,col,mode_p) "{{{2
        let start = a:col
        while start > 0 && a:line[start - 1] !~ a:mode_p
            let start = start - 1
        endwhile
        let s:last_start=start
        return start
endf

func! VjdeTagCompletion(tag,base,t,...) "{{{2
	call VjdeClearPreview()
	if empty(g:vjde_tag_loader)
		return 
	endif
	let str=''
	"element attribute value
	if a:t=="10" || a:t=="11" || a:t=="1" 
		let pre = a:1
		call VjdeAddToPreview(a:tag.'=>'.a:base.'=>values:')
		if strlen(pre)==0
			for val in g:vjde_tag_loader.FindValues(a:tag,a:base)
				if strlen(val)==0
					continue
				endif
				let str.=val."\n"
				call VjdeAddToPreview('value '.val.';')
			endfor
		else
			for val in g:vjde_tag_loader.SearchValues(a:tag,a:base,'stridx(vjde_item,"'.pre.'")==0')
				if strlen(val)==0
					continue
				endif
				let str.=val."\n"
				call VjdeAddToPreview('value '.val.';')
			endfor
		endif
	elseif a:t=='2' "tag
		call VjdeAddToPreview('element:')
		let cond='1'
		if strlen(a:base)>0
			let cond = 'stridx(vjde_item.name,"'.a:base.'")==0'
		endif
		for val in g:vjde_tag_loader.SearchTags(cond)
			let str.=val.name."\n"
			call VjdeAddToPreview('element '.val.name.';')
		endfor
	elseif a:t=='3' "attribute
		call VjdeAddToPreview(a:tag.'=>attributes:')
		let cond='1'
		if strlen(a:base)>0
			let cond = 'stridx(vjde_item.name,"'.a:base.'")==0'
		endif
		for val in g:vjde_tag_loader.SearchAttributes(a:tag,cond)
			let str.=val.name."\n"
			call VjdeAddToPreview('attribute '.val.name.';')
		endfor
	elseif a:t=='4' "children
	endif
	let s:retstr=str[0:1024]
endf
func! VjdeXMLFun0(findstart,base)
	if a:findstart
		return VjdeXMLFun(getline('.'),a:base,col('.'),a:findstart)
	endif
	call VjdeXMLFun(getline('.'),a:base,col('.'),a:findstart)
	if strlen(s:retstr)<2
		return []
	else
		return split(s:retstr,"\n")
	endif

endf
func! VjdeXMLPrefix(line,base,col,findstart)
    let aline=a:line
    let abase=a:base
    let acol=a:col

    let ele = aline[s:last_start-1] =~'[:<]'

    if ele
	    let def_line=line('.')
    else
	    let def_line = search('<','nb')
    endif
    if def_line == -1
		return ['',-1,-1]
    endif
    let def_l = getline(def_line)
    if aline[s:last_start-1]=='<'
	    let id1 = s:last_start-1
    else
	    let id1 = VjdeFindUnendPair(def_l,'<','>',0,a:col)
    endif
    if id1 == -1
		return ['',-1,-1]
    endif
    
    
    let prefix=''
    let id3 = stridx(def_l,':',id1)
    if id3 != -1 " has a namespace
		let prefix=strpart(def_l,id1+1,id3-id1-1) 
    endif
	return [prefix,def_line,id1]
endf
func! VjdeXMLFun(line,base,col,findstart) "{{{2
    if a:findstart
        return VjdeFindStart(a:line,a:base,a:col,'[ \t=<:"]')
    endif

    let aline=a:line
    let abase=a:base
    let acol=a:col

    let ele = aline[s:last_start-1] =~'[:<]'

    if ele
	    let def_line=line('.')
    else
	    let def_line = search('<','nb')
    endif
    if def_line == -1
	return ''
    endif
    let def_l = getline(def_line)
    if aline[s:last_start-1]=='<'
	    let id1 = s:last_start-1
    else
	    let id1 = VjdeFindUnendPair(def_l,'<','>',0,a:col)
    endif
    if id1 == -1
	return ''
    endif
    
    
    let prefix=''
    let id3 = stridx(def_l,':',id1)
    if id3 != -1 " has a namespace
	let prefix=strpart(def_l,id1+1,id3-id1-1) 
    endif

    let s:retstr=''
    if prefix!='' 
        call s:VjdeXMLSetupNSLoader(prefix) 
    else " find DTD and setup $vjde_def_loader
        call s:VjdeXMLFindDTD()
    endif
    if s:isfind == 0 
            return ' I can''t find namespace or dtd for :'.prefix
    endif

    if ele
        let tag=''
        if g:vjde_xml_advance
            "TODO search child
            "let tag = s:VjdeFindUnendElement(c_linenum,a:col)
            let tag = s:VjdeFindUnendElement(def_line,id1)
            if ( tag != '')
                if prefix!=''
                    call VjdeHTMLRuby(strpart(tag,strlen(prefix)+1),abase,4)
                else 
                    call s:VjdeHTMLRuby(tag,abase,4)
                endif
                return s:retstr
            endif
        endif
        call s:VjdeHTMLRuby('',abase,2)
        return s:retstr
    endif

    let id2 = SkipToIgnoreString(def_l,id1,'[ \t]')
    if id3!=-1
        let id1=id3
    endif
    let tag = strpart(def_l,id1+1,id2-id1-1)

    let ele = aline[s:last_start-1]=~'[ \t]'
    if ele " attribute
        call s:VjdeHTMLRuby(tag,abase,3)
        return s:retstr
    endif

    let id1=VjdeFindStart(aline,'',acol,'[ \t]')
    let id2=VjdeFindStart(aline,'',acol,'[=]')
    if ( id1 < 0 || id2<id1)
        return id1."--".id2
    endif
    let ele = aline[s:last_start]=='"'
    call s:VjdeHTMLRuby(tag,strpart(aline,id1,id2-id1-1),10+ele,abase)
    return s:retstr
endf
func! s:VjdeFindUnendElement(line_num,col_num) "{{{2
    let l = a:line_num
    let col = a:col_num
    let l:rpos=[[-1,0],[0,0]]
    while l > 0 && col>0
        let pos = s:VjdeFindPairBack(l,col,'<','>') " search for < .... >
        "echo pos
        if pos[0][0] < 0
            return ''
        endif
        let str = getline(pos[0][0])
        if str[pos[0][1]]=='/' " end element </...>
            let name = strpart(str,pos[0][1]+1,pos[1][1]-pos[0][1]-2)
            let l = search('<\<'.name.'\>','nb') " find <ele-name ... >
            if  l > 0 
                let str = getline(l)
                let col = match(str,'<\<'.name.'\>')
            endif
            continue
        endif
        if str[pos[0][1]]=~'[?!]' " end element <!--...> 
            let l = pos[0][0]    " next
            let col=pos[0][1] -1
            continue
        endif
        let str = getline(pos[1][0])
        if str[pos[1][1]-2]=='/' " end element  <.../>
            let l = pos[0][0]
            let col=pos[0][1]
            continue
        endif
       let l:rpos=pos
        break
    endw
    
    "echo l:rpos
    if l:rpos[0][0]>0
        "echo getline(l:rpos[0][0])
        return strpart(matchstr(getline(l:rpos[0][0]),'<[^ \t]\+',l:rpos[0][1]-1),1)
    else
        return ''
    endif
endf
func! s:VjdeFindPairBack(line,col,m_start,m_end) "{{{2
    let line = a:line
    let col = a:col
    let res = [[0,0],[0,0]]
    let e = VjdeFindStart(getline(line),'',col,a:m_end)
    while e <= 0 && line>0
        let line = line-1
        let str = getline(line)
        let e = VjdeFindStart(str,'',strlen(str),a:m_end)
    endw
    let res[1][0]=line
    let res[1][1]=e

    let e = VjdeFindStart(getline(line),'',e,a:m_start)
    while e <= 0 && line>0
        let line = line-1
        let str = getline(line)
        let e = VjdeFindStart(str,'',strlen(str),a:m_start)
    endw
    let res[0][0]=line
    let res[0][1]=e
    return res
endf

func! VjdeJavaParameterPreview(...) "{{{2
	let off = 0
	if a:0 > 0
		let off=a:1
	endif
	"let show_prev_old = g:vjde_show_preview
	"let g:vjde_show_preview=1
	let lstr = getline(line('.'))
	let cnr = col('.') - off
	let Cfu = function(&cfu)
	let mystr = strpart(lstr,0,col('.')-2)
	let myv = substitute(mystr,'^.*\<new\>\s\+\(\i\+\)$','\1','')
	if  strlen(myv) != strlen(mystr)
		if empty(g:vjde_java_cfu)
			let g:vjde_java_cfu = VjdeJavaCompletion_New(g:vjde_install_path.'/vjde/vjde.jar',g:vjde_out_path.g:vjde_path_spt.g:vjde_lib_path)
		endif
		call g:vjde_java_cfu.FindClass(myv,GetImportsStr())
		let lval=[]
		if g:vjde_java_cfu.success
			for constructor in g:vjde_java_cfu.class.constructors
				call add(lval,{'word': myv ,'menu': ' ', 'kind' : 'c', 'info': constructor.ToString(),'icase':0,'dup':1})
			endfor
        else
		endif
		return lval
	endif
        let s:last_start = VjdeCompletionFun(getline('.'),'',col('.')-2,1)
	let mstr = Cfu(0,strpart(lstr,s:last_start,cnr-s:last_start))
        
	"if len(s:preview_buffer)>0
	"	call g:java_previewer.PreviewInfo(join(s:preview_buffer,"\n"))
	"endif
	"let g:vjde_show_preview=show_prev_old
        return mstr
endf "}}}2
func! s:VjdeAnnotationPreveiewMenu2(name) "{{{2
    let lval= []
        "for member in g:vjde_java_cfu.class.members
        "    call add(lval,{'word': member.name ,'menu': member.type , 'kind': 'm' ,  'info': member.type.' '.member.name,'icase':0})
        "endfor
	for method in g:vjde_java_cfu.class.methods
		if method.name != a:name
			continue
		endif
		if method.ret_type=='java.lang.String[]'
			return lval
		elseif stridx( method.ret_type,'[]')> 0 
			let ret_type=method.ret_type[0:-3]
			if !index(s:wait_import,ret_type)
				call add(s:wait_import , ret_type)
			endif
			let ret_type=VjdeGetClassName(ret_type)
			"call Vjde_import_check(ret_type)
			call add(lval,{'word': '@'.ret_type."(" ,'menu':method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0, 'dup':1})
		endif
	endfor
    return lval
endf
func! s:VjdeAnnotationPreveiewMenu(base) "{{{2
    let lval= []
    if strlen(a:base)==0
        "for member in g:vjde_java_cfu.class.members
        "    call add(lval,{'word': member.name ,'menu': member.type , 'kind': 'm' ,  'info': member.type.' '.member.name,'icase':0})
        "endfor
        for method in g:vjde_java_cfu.class.methods
		if method.name=='annotationType'
			continue
		endif
		if method.name=='hashCode'
			continue
		endif
		if method.name=='toString'
			continue
		endif
		if method.name=='equals'
			continue
		endif
		if stridx( method.ret_type,'[]')> 0 
			call add(lval,{'word': method.name."={" ,'menu':method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0, 'dup':1})
		else
			call add(lval,{'word': method.name."=" ,'menu':method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0, 'dup':1})
		endif
        endfor
    else
        "for member in g:vjde_java_cfu.class.SearchMembers('stridx(member.name,"'.a:base.'")==0')
        "    call add(lval,{'word': member.name , 'kind': 'm' ,'menu':member.type ,  'info': member.type.' '.member.name ,'icase':0})
        "endfor
        for method in g:vjde_java_cfu.class.SearchMethods('stridx(method.name,"'.a:base.'")==0')
		if method.name=='annotationType'
			continue
		endif
		if method.name=='hashCode'
			continue
		endif
		if method.name=='toString'
			continue
		endif
		if method.name=='equals'
			continue
		endif
		if stridx( method.ret_type,'[]')> 0 
			call add(lval,{'word': method.name."{ }" ,'menu':method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0, 'dup':1})
		else
			call add(lval,{'word': method.name."=" ,'menu':method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0, 'dup':1})
		endif
        endfor
    endif
    return lval
endf
func! s:VjdeGeneratePreveiewMenu(base) "{{{2
    let lval= []
    if strlen(a:base)==0
        for member in g:vjde_java_cfu.class.members
            call add(lval,{'word': member.name ,'menu': member.type , 'kind': 'm' ,  'info': member.type.' '.member.name,'icase':0})
        endfor
        for method in g:vjde_java_cfu.class.methods
            call add(lval,{'word': method.name."(" ,'menu': method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0,'dup':1})
        endfor
    else
        for member in g:vjde_java_cfu.class.SearchMembers('stridx(member.name,"'.a:base.'")==0')
            call add(lval,{'word': member.name , 'kind': 'm' ,'menu':member.type ,  'info': member.type.' '.member.name ,'icase':0})
        endfor
        for method in g:vjde_java_cfu.class.SearchMethods('stridx(method.name,"'.a:base.'")==0')
            call add(lval,{'word': method.name."(" ,'menu':method.ret_type, 'kind' : 'f', 'info': method.ToString(),'icase':0, 'dup':1})
        endfor
    endif
    return lval
endf
func! s:VjdeGeneratePreviewBuffer(base) "{{{2
	call VjdeClearPreview()
	if g:vjde_java_cfu.success
		call add(s:preview_buffer,g:vjde_java_cfu.class.name.':')
	    if strlen(a:base)==0
		    for member in g:vjde_java_cfu.class.members
			    call add(s:preview_buffer,member.type.' '.member.name.';')
		    endfor
		    for method in g:vjde_java_cfu.class.methods
			    call add(s:preview_buffer,method.ToString())
		    endfor
	    else
		    for member in g:vjde_java_cfu.class.SearchMembers('stridx(member.name,"'.a:base.'")==0')
			    call add(s:preview_buffer,member.type.' '.member.name.';')
		    endfor
		    for method in g:vjde_java_cfu.class.SearchMethods('stridx(method.name,"'.a:base.'")==0')
			    call add(s:preview_buffer,method.ToString())
		    endfor
	    endif
	endif
	return
endf "}}}2
func! VjdePreviewGetLines() "{{{2
	return join(s:preview_buffer,"\n")
endf "}}}
func! VjdeAddOtherImport()
	if len(s:wait_import) == 0
		return
	endif
	for k in s:wait_import
		call Vjde_import_check(k)
	endfor
	let s:wait_import=[]
endf

" add by wangfc
func! VjdeInsertWord(word) "{{{2
	if strlen(a:word)==0
		return
	endif
	let lnr = line('.')
	let lcol = col('.')
	let str = getline(lnr)
	call setline(lnr,strpart(str,0,lcol).a:word.strpart(str,lcol))
	exec 'normal '.strlen(a:word).'l'
endf "}}}2
func! GetJavaCompletionLines(arr)
	let a:arr.preview_buffer += VjdeGetPreview()
endf
func! VjdeGetDocWindowLine() "{{{2
	if !g:wspawn_available
		return "\n"
	endif
	let ft=&ft
	if ft !='java'
		return "\n"
	endif
	if strlen(g:vjde_javadoc_path)<=2
		return "\n"
	endif
	if !isdirectory(g:vjde_javadoc_path)
		return "\n"
	endif
	let str = g:vjde_doc_gui_width.';'.g:vjde_doc_gui_height.';'
	let str = str.g:vjde_doc_delay.';'
	let str = str.'java -cp "'.substitute(g:vjde_install_path,'\','/','g').'/vjde/vjde.jar" vjde.completion.Document '
	if ( strlen(g:vjde_src_path)>0) 
		let str = str.'"'.g:vjde_javadoc_path.'" "'.g:vjde_src_path.'" '
	else
		let str = str.'"'.g:vjde_javadoc_path.'" "./" '
	endif
	return str.";\n"
endf "}}}
func! s:VjdeGetMethod(name) "{{{
	let res=[]
	for item in g:vjde_java_cfu.class.members 
		if a:name == item.name
			call add(res,a:name)
		endif
	endfor
	for item in g:vjde_java_cfu.class.methods
		if a:name == item.name
			let str = item.ToString()
			let idx = stridx(str," ")
			call add(res,strpart(str,idx+1))
		endif
	endfor
	return res
endf "}}}
func! VjdeGetDocUnderCursor() "{{{
	if strlen(s:vjde_doccmd) == 0 
		let str = g:vjde_java_command. ' -cp "'.substitute(g:vjde_install_path,'\','/','g').'/vjde/vjde.jar" vjde.completion.Document '
		if ( strlen(g:vjde_src_path)>0) 
			let str = str.'"'.g:vjde_javadoc_path.'" "'.g:vjde_src_path.'" '
		else
			let str = str.'"'.g:vjde_javadoc_path.'" "./" '
		endif
		let s:vjde_doccmd=str
	endif
	call VjdeFindClassUnderCursor()
	if g:vjde_java_cfu.success  && strlen(s:beginning)>0
		let mms = s:VjdeGetMethod(s:beginning)
		if  len(mms) > 0
			if g:vjde_use_window == 1
				call VjdeWindowClear()
			endif
			for mm in mms
				let str = s:vjde_doccmd.' '.g:vjde_java_cfu.class.name.' '.mm
				let doc = system(str)
				if g:vjde_use_window == 1
					call VjdeWindowAdd(doc)
					"for item in split(doc,"\n")
					"	call VjdeWindowAdd(item)
					"endfor
				else
					echo item
				endif
			endfor
		endif
	endif
endf

 "{{{2
command! -nargs=0 Vjdei call  s:VjdeInfomation()  
command! -nargs=0 Vjdei2 echo s:VjdeJspTaglib()
command! -nargs=0 Vjdegd call  s:VjdeGotoDecl()  
"command! -nargs=+ Vjdetld echo s:VjdeTaglibCompletionFun(<f-args>) 
"command! -nargs=1 Vjdeft echo s:VjdeFormatLine(<f-args>)  

"command! -nargs=0 Vjdetest  call s:VjdeObejectSplit(s:VjdeFormatLine(getline(line('.'))).'.') <BAR> echo s:types <BAR> echo s:VjdeFormatLine(getline(line('.'))).'.wfc'
"command! -nargs=0 Vjdetest1  echo s:VjdeFormatLine(getline(line('.')))

"command! -nargs=1 Vjdedef echo s:GettypeName(<f-args>)  
"command! -nargs=0 VjdeXML echo s:VjdeFindUnendElement(line('.'),col('.'))  

command! -nargs=0 Vjdetest echo s:GetJspImportStr()


"   vim600:fdm=marker:ff=unix

