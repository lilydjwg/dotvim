
func! VjdeReadIniFile(filename)
	if !filereadable(a:filename)
		return {}
	endif
	let lines = readfile(a:filename)
	call filter(lines,'v:val !~ "^\s*$"')
	let mps = {}
	for item in lines
		if item[0]=~'^\s*#'
			continue 
		endif
		let pairs = matchlist(item,'^\s*\([^ \t]*\)\s*=\s*\(.*\)$')
		if len(pairs)>=3
			let mps[pairs[1]] = pairs[2]
		endif
	endfor
	return mps
endf

func! SkipToIgnoreString(line,index,target) "{{{2
    let start = a:index
    let len = strlen(a:line)
    while start < len
        if ( a:line[start]=~a:target) 
            return start
        endif
        if ( a:line[start]=='\')
            let start=start+1
        elseif (a:line[start]=='"')
            let start=SkipToIgnoreString(a:line,start+1,'"')
            if start == -1
                return -1
            end
        endif
        let start=start + 1
    endwhile
    return -1
endf

func! VjdeFindUnendPair(line,firstc,secondc,start,endcol) "{{{2
    let res = SkipToIgnoreString(a:line,a:start,a:firstc)
    while res != -1
        let res2 = SkipToIgnoreString(a:line,res,a:secondc)
        if ( res2 == -1 || res2>=a:endcol )
            return res
        endif
        let res = SkipToIgnoreString(a:line,res2,a:firstc)
    endw
    return -1
endf "}}}2


let s:types=[]
func! VjdeObejectSplit(line) "{{{2 remove
    let s:types=[]
    let len = strlen(a:line)
    let index = SkipToIgnoreString(a:line,0,'[a-zA-Z_]')
    let oind = s:ObjectSplit(a:line,index)
    while ( oind!=-1 && oind < len )
        if a:line[oind]=='('
            let oind = SkipToIgnoreString(a:line,oind+1,')')
            if ( oind == -1 )
                return s:types
            endif
            let oind = SkipToIgnoreString(a:line,oind,'\.')
            if ( oind == -1 )
                return s:types
            endif
        endif
        if a:line[oind]=='['
           let oind = SkipToIgnoreString(a:line,oind+1,'\]')
           if ( oind == -1 )
               return s:types
           endif
        endif
        let oind = oind+1
        let oind = s:ObjectSplit(a:line,oind)
    endw
    return s:types
endf
func! s:ObjectSplit(line,index) "{{{2 remove
    let oend = SkipToIgnoreString(a:line,a:index,'[\.(\[]')
    if ( oend!= -1 && oend!=a:index)
        call add(s:types,strpart(a:line,a:index,oend-a:index))
    end
    return oend
endf
func! VjdeFormatLine(line) "{{{2 remove
    let len = strlen(a:line)
    let index0 = SkipToIgnoreString(a:line,0,'[=<>+\-\*\/%?:\&|\^|,;]')
    let index=0
    while index0 != -1
        let index = index0
        let index0 = SkipToIgnoreString(a:line,index0+1,'[=<>+\-\*\/%?:\&\^|,;]')
    endw
    let index0 = MatchToIgnoreString(a:line,index+1,'^return')
    if  index0 != -1
			let index = index0+6
	else	
			let index0 = MatchToIgnoreString(a:line,index+1,'^new')
			if  index0 != -1
					let index = index0+3
			else
					let index0 = MatchToIgnoreString(a:line,index+1,'^case')
					if  index0 != -1
							let index = index0+4
					endif
			endif
    endif
    let index = SkipToIgnoreString(a:line,index,'[^=<>+\-\*\/%?:\&\^|,;]')
    if index == -1
	    return ""
    else
	    "let index = index0
    endif


    let l:index2= index
    let ret_index = index

    let l:stack = [l:index2]
    while  l:index2 < len
        let c= a:line[l:index2]
        if  c == '(' || c=='['
            call add(l:stack,l:index2+1)
        elseif c == ')' || c==']'
            call remove(l:stack,-1)
        elseif c == '\'
            let l:index2 = l:index2+1
        elseif c=='"'
            let l:index2 = SkipToIgnoreString(a:line,l:index2+1,'"')
            if  l:index2 == -1 " Can't find the next \" for the current one
                return ""
            endif
        endif
        let l:index2 = l:index2+1
    endw
    if len(l:stack)>0 
        let ret_index=remove(l:stack,-1)
    else
        return ""   " incorrectly line
    endif
    let l:index2 = matchend(a:line,'^\s*\(return\s\+\|new\s\+\|([^)]*)\s*\)',ret_index)
    if  l:index2 != -1
        let ret_index = l:index2 
    endif
    "let l:index2 = matchend(a:line,"new\\s\\+",ret_index)
    "if  l:index2 != -1
        "let ret_index = l:index2 
    "endif
    "let l:index2 = matchend(a:line,"return\\s\\+",ret_index)
    "if  l:index2 != -1
        "let ret_index = l:index2 
    "endif
    return strpart(a:line,ret_index)
endf
func! MatchToIgnoreString(line,index,target) "{{{2 remove
    let start = a:index
    let len = strlen(a:line)
    while start < len
        if ( match(a:line,a:target,start)==start)
            return start
        endif
        if ( a:line[start]=='\')
            let start=start+1
        elseif (a:line[start]=='"')
            let start=SkipToIgnoreString(a:line,start+1,'"')
            if start == -1
                return -1
            end
        endif
        let start=start + 1
    endwhile
    return -1
endf
func! VjdeGetAnnotationObjects(l)
	let rv = []
	let idx = 0
	let len = strlen(a:l)
	while idx < len
		if a:l[idx]=='"'
			let idx= SkipToIgnoreString(a:l,idx+1,'"')
			if idx == -1
				return rv
			endif
		elseif a:l[idx]=="{" || a:l[idx]=="("
			call add(rv,idx)
		elseif a:l[idx] == "}" || a:l[idx]==")"
			call remove(rv,-1)
		endif
		let idx = idx +1
	endwhile
	let lv2=[]
	for idx in rv
		let str = matchstr(strpart(a:l,0,idx+1),'[^@,({]*\s*[({]$')
		let str = substitute(str,'[ \t]','','g')
		call add(lv2,str)
	endfor
	let len = len(lv2)
	echo lv2
	let idx = len-1
	echo idx
	while idx >= 0
		if lv2[idx][-1:-1]=='('
			break
		endif
		let idx = idx-1
	endwhile
	if ( idx > 0 ) 
		call remove(lv2,0,idx-1)
	endif
	return lv2
endf
"   vim600:fdm=marker:ff=unix
"vim:fdm=marker:ff=unix
