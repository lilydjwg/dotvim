
if !exists('g:vjde_loaded') || &cp
	finish
endif
"{{{2
func! VjdeGetCtags()
endf
"}}}2
"{{{2
func! VjdeCppType4Line(lstr,v)
	let pattern='\(\<\i\+\>\(\s*<.*>\s*\)*::\)*\<\i\+\>\(\s*<.*>\s*\)*\(\[.*\]\)*[* \t]\+\<'.a:v.'\>'
	let lstr = matchstr(a:lstr,pattern)
	if lstr=='' | return '' | endif
	let lend = match(lstr,'[* \t]\+\<'.a:v.'\>')
	let vt = strpart(lstr,0,lend+1)
	while ( stridx(vt,'<')>0) 
		let len = strlen(vt)
		let vt=substitute(vt,'<[^<>]*>','','g')
		if len == strlen(vt) 
			break
		endif
	endwhile
	return vt
endf
"}}}2
"{{{2
func! VjdeReadTags_FindClass(className1) dict
	if index(self.searched,a:className1) != -1 || len(self.searched)>=self.max_deep
		return {}
	endif
	call add(self.searched,a:className1)

	let className = a:className1
	let ns =''
	let idx = strridx(a:className1,"::")
	if idx!=-1
		let ns = a:className1[0 : idx-1]
		let className = a:className1[ idx+2 : -1]
	endif
	for item in split(self.tags,',')
		if !filereadable(item) | continue | endif
		let cmdline = self.cmd.' -e -k ncstu -t '. item. ' '.className
		let lines = system(cmdline)
		for lstr in split(lines,"\n")
			let tg = VjdeCreateTag(lstr)
			if empty(tg) | continue | endif
			if tg.kind!='v'
			endif
			if tg.kind=='c' || tg.kind=='n' || tg.kind=='s' || tg.kind=='u'
				if tg.ns=='' && ns==''
					if strridx(tg.ns,ns)!=strlen(t.ns)-strlen(ns) | continue | endif
				endif
				if tg.className!=''
					if strridx(tg.className,a:className1)!=strlen(tg.className)-strlen(a:className1)
						continue
					endif
				end
				return {'tag': tg , 'file' : item }
			elseif tg.kind=='t'
				if tg.ns=='' && ns==''
					if strridx(tg.ns,ns)!=strlen(t.ns)-strlen(ns) | continue | endif
				endif
				if tg.className!='' && ns!=''
					if strridx(tg.className,ns)!=strlen(tg.className)-strlen(ns) | continue | endif
				endif
				if tg.cmd!=''
					let cmd = VjdeCppType4Line(tg.cmd,className)
					if cmd != ''
						return self.FindClass(cmd)
					endif
				endif
			elseif tg.kind=='v'
				let cmd = VjdeCppType4Line(tg.cmd,className)
				if cmd != ''
					return self.FindClass(cmd)
				endif
			endif
		endfor
	endfor
	return {}
endf
"}}}2

"{{{2
func! VjdeReadTags_EachTag(base,fn,...) dict
	let Fn = function(a:fn)
	let full= 0
	let para = ''
	if a:0 >= 1 | let full=a:1 | endif
	if !full | let para = ' -p ' | endif
	let count1 = 0

	for item in split(self.tags,',')
		if !filereadable(item) | continue | endif
		let cmdline = self.cmd.' -e '.para
		if self.max_tags!=-1 | let cmdline.= ' -m '.(self.max_tags-count1) | endif
		if a:base!='' | let cmdline.= ' -t '.item.' '.a:base | else | let cmdline.= ' -t '.item.' -l ' | endif
		let result = system(cmdline)
		for lstr in split(result,"\n")
			let tg = VjdeCreateTag(lstr)
			if empty(tg) | continue | endif
			if !Fn(tg,item) | return | endif
			let count1+=1
		endfor
		if self.max_tags==count1 | break | endif
	endfor
endf
"}}}2

"{{{2
func! VjdeReadTags_EachMember(className1,beginning,fn,...) dict

	let className = a:className1
	let clsTag = {}
	let searchedFile = ''
	let cls = self.FindClass(className)
	if empty(cls) | return | endif

	let Fn = function(a:fn)
	let full= 0
	let para = ''
	if a:0 >=1 | let full = a:1 | endif
	if !full | let para = ' -p ' | endif

	let clsTag = cls.tag
	let searchedFile = cls.file

	let cmdline=self.cmd.' -e '.para
	if self.max_tags!=-1 | let cmdline.=' -m '.self.max_tags | endif

	let ns = ''
	if clsTag.ns!='' | let ns.=clsTag.ns.'::' | endif
	let ns .= clsTag.name
	if clsTag.kind=='n'
		let cmdline.= ' -f namespace '.ns
	elseif clsTag.kind=='c'
		let cmdline.= ' -f class '.ns
	elseif clsTag.kind=='s'
		let cmdline.= ' -f struct '.ns
	elseif clsTag.kind=='u'
		let cmdline.= ' -f union '.ns
	endif
	let cmdline .= ' -t '.searchedFile.' '.a:beginning
	let result = system(cmdline)
	for lstr in split(result,"\n")
		let tg=VjdeCreateTag(lstr)
		if empty(tg) | continue | endif
		if !Fn(tg,searchedFile) | break | endif
	endfor
endf
"}}}2

"{{{2
func! VjdeReadTags_New(tagsVar,cmd)
	return { 'cmd' : a:cmd ,
		\ 'tags' : a:tagsVar,
		\ 'searched' :[] ,
		\ 'max_deep' :2,
		\ 'max_tags' :-1,
		\ 'EachTag' : function('VjdeReadTags_EachTag'),
		\ 'EachMember' :function('VjdeReadTags_EachMember'),
		\ 'FindClass' : function('VjdeReadTags_FindClass') }
endf
"}}}2


"{{{2
func! VjdeCreateTag(lstr)
	let infos = split(a:lstr,';"')
	if len(infos)<1 | return {} | endif
	let infos_base = split(infos[0],"\t")
	let cmd = matchstr(a:lstr,'/^.*$/')
	if  len(infos)<2 || len(infos_base)<1 | return {} | endif
	let ext = split(infos[1],"\t")
	let idx = 1
	let max = len(ext)
	let cur =''
	let tag = CtagsTag_New(infos_base[0],'','','','','','','','',cmd)
	while idx < max
		let cur = ext[idx]
		let iidx = stridx(cur,':')
		if iidx == -1 | continue | endif 
		let cname = cur[0 : iidx-1]
		let cv = cur[ iidx+1 : -1]
		
                if cname=='signature'
                    let tag.cmd= cv
                elseif cname=='class' || cname=='interface' || cname=='struct' || cname=='union'
                    let tag.className = cv
		elseif cname=='namespace'
                    let tag.ns=cv
		else
                    let tag[cname]=cv
		endif
		let idx+=1
	endwhile
	let tag.file = get(infos_base,1,'')
	let tag.kind= get(ext,0,'')
	return tag
endf
"}}}2
"{{{2
func! CtagsTag_New(name, file, kind, line, scope, inherits, className, access,ns,cmd)
	return {'scope': a:scope , 
		\ 'name': a:name ,
		\ 'file': a:file ,
		\ 'kind': a:kind ,
		\ 'line': a:line ,
		\ 'inherits' : a:inherits,
		\ 'className' : a:className ,
		\ 'access' : a:access,
		\ 'ns' : a:ns,
		\ 'cmd' : a:cmd }
endf
"}}}2
"
"
"{{{2 
"TEST

"let cmp = VjdeReadTags_New('d:/mingw/include/tags,d:/boost_1_33_0/tags','d:/workspace/vjde/plugin/vjde/readtags.exe')
"func! ShowTag(tg,ff)
	"echo a:tg.name."\t".a:tg.ns."\t".a:tg.className."\t".a:tg.kind
	"return 1
"endf
"echo  cmp.FindClass('boost::multi_index::index')
"let cmp.max_tags=10
"call cmp.EachMember('vector','','ShowTag')
"call cmp.EachTag('printf','ShowTag',1)


"}}}2
" vim:ft=vim:fdm=marker:tw=72
