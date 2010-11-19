if exists('g:vjde_tag_loader_loaded')
	finish
endif
if !exists('g:vjde_loaded') || &cp
		finish
endif
let g:vjde_tag_loader_loaded=1

let s:vjde_tag_loaded={}
let s:RE_ENUM='[,; \t]'
let s:RE_PARENT='[,; \t<]'
let s:RE_ATTRIBUTE='[;|}]'
let s:RE_SPLIET_ATTR='[{,; \t]'
let s:RE_LINE_ENUM='\s*\(private\|public\)*\s\+enum\s*\([^ \t]\+\)\s*{\([^}]*\)}'
let s:RE_LINE =  '\s*\(private\|public\)*\s*\(tag\)\s\+\([^ \t<{]\+\)\s*\([^<{]*\)\(<\?\s*[^{]*\){\(\(\s*attr\s\+[^;{]*\s*\(;\|{[^\}]*}\)\)*\)\s*}'
let s:RE_COMMENT='^\s*[*/]'
let s:RE_ELEM_CHILD='[?+* \t()|,]'

func! VjdeTagType_New(name,val) 
	return {'name':a:name, 'values':a:val}
endf
func! VjdeTagAttributeElement_AddValue(val) dict
	call add(self.values,a:val)
endf
func! VjdeTagAttributeElement_New(name)
	return {'name':a:name , 
				\'type':'' , 
				\'values':[] , 
				\'AddValue':function('VjdeTagAttributeElement_AddValue') }
endf
func! VjdeTagElement_AddAttribute(val) dict
	call add(self.attributes,a:val)
endf
func! VjdeTagElement_AddParent(val) dict
	call add(self.parents,a:val)
endf
func! VjdeTagElement_New(name) 
	return { 'name' : a:name ,
				\'attributes' : [] ,
				\'parents' : [] ,
				\'children' : [] ,
				\'AddAttribute' : function('VjdeTagElement_AddAttribute') ,
				\'AddParent' : function('VjdeTagElement_AddParent')
				\}
endf
func! VjdeTagLoaderGet(name,fname) 
	if ! has_key(s:vjde_tag_loaded,a:name)
		let loader = VjdeTagLoader_New()
		if  filereadable(a:fname) 
			call loader.Load(a:fname) 
		endif
		if filereadable(expand('~/.vim/vjde/'.a:name.'.def'))
			call loader.Load(expand('~/.vim/vjde/'.a:name.'.def'))
		endif
		let s:vjde_tag_loaded[a:name]=loader
	endif
	return s:vjde_tag_loaded[a:name]
endf
func! VjdeTagLoader_Load(fname) dict
	let str = ''
	let lines = readfile(a:fname)
	for line in lines
		if line =~ s:RE_COMMENT 
			continue
		endif
		let str = str.' '.substitute(line,'\s*$','','')
		if str[-1:-1]!='}'
			continue
		endif
		let subs = matchlist(str ,s:RE_LINE_ENUM)
		if len(subs)==4
			let attrs = split(subs[3],s:RE_ENUM)
			let define = VjdeTagType_New(subs[2],attrs)
			call add(self.types,define)
			let str = strpart(str,strlen(subs[0]))
		endif
		let subs = matchlist( str, s:RE_LINE)
		let all_pat = ''
		if len(subs)>0
			let all_pat = remove(subs,0)
			let str = strpart(str,strlen(all_pat))
		endif
		if len(subs)>=5
			if subs[0]=='private'
				if subs[1]=='tag'
					call add(self.parents,self.ParseTag(subs[2],subs[3],subs[4],subs[5]))
				endif
			elseif subs[0]=='public' && strlen(subs[2])!=0
				if subs[1]=='tag'
					call add(self.tags,self.ParseTag(subs[2],subs[3],subs[4],subs[5]))
				endif
			else
				if subs[1]=='tag' && strlen(subs[2])!=0
					call add(self.tags,self.ParseTag(subs[2],subs[3],subs[4],subs[5]))
				endif
			endif
		endif
	endfor
endf
func! VjdeTagLoader_ParseTag(name,children,parent,attris) dict
	let ele = VjdeTagElement_New(a:name)
	if strlen(a:children) > 0
		let cs = split(a:children,s:RE_ELEM_CHILD)
		call filter(cs,'strlen(v:val)>0')
		let ele.children += cs
	endif
	if strlen(a:parent)>0
		let ps = split(a:parent,s:RE_PARENT)
		call filter(ps,'strlen(v:val)!=0')
		let ele.parents += ps
	endif
	if strlen(a:attris)<0
		return ele
	endif
	let attrs = split(a:attris,s:RE_ATTRIBUTE)
	for attr in attrs
		if stridx(attr,'{')>0
			let values = split(attr,s:RE_SPLIET_ATTR)
			call filter(values , 'strlen(v:val)>0')
			if len(values)<3
				continue
			endif
			let attr_ele = VjdeTagAttributeElement_New(values[1])
			if len(values)>=3
				let attr_ele.values += values[2:-1]
			endif
			call ele.AddAttribute(attr_ele)
		else
			let values = split(attr,'[ \t]\+')
			call filter(values,'strlen(v:val)>0')
			if len(values) < 2
				continue
			endif
			let att_ele = VjdeTagAttributeElement_New(values[-1])
			if len(values)==3
				let att_ele.type=values[1]
			endif
			call ele.AddAttribute(att_ele)
		endif
	endfor
	return ele
endf
func! VjdeTagLoader_FindTag(name) dict
	for item in self.tags
		if item.name==a:name
			return item
		endif
	endfor
	for item in self.parents
		if item.name==a:name
			return item
		endif
	endfor
	return {}
endf

func! VjdeTagLoader_SearchTags(cond) dict
	let array = []
	for vjde_item in self.tags
		if eval(a:cond)
			call add(array,vjde_item)
		endif
	endfor
	return array
endf
func! VjdeTagLoader_SearchAttributes(name,cond) dict
	let tag = self.FindTag(a:name)
	let array = []
	if empty(tag)
		return array
	endif

	for vjde_item in tag.attributes
		if eval(a:cond)
			call add(array,vjde_item)
		endif
	endfor
	for par in tag.parents
		if par==a:name
			continue
		endif
		let array2 = self.SearchAttributes(par,a:cond)
		if !empty(array2)
			let array+=array2
		endif
	endfor
	return array
endf
func! VjdeTagLoader_FindAttribute(tagname,name) dict
	let mtag = self.FindTag(a:tagname)
	if empty(mtag)
		return mtag
	endif
	for val in mtag.attributes
		if val.name==a:name
			return val
		endif
	endfor
	for par in mtag.parents
		if par==a:tagname
			continue
		endif
		let mtag = self.FindAttribute(par,a:name)
		if !empty(mtag)
			return mtag
		endif
	endfor
	return {}
endf
func! VjdeTagLoader_FindValues(tagname,attrname) dict
	let values = []
	let attr = self.FindAttribute(a:tagname,a:attrname)
	let array=[]
	if !empty(attr) && strlen(attr.type)>0 
		for type in self.types
			if type.name==attr.type
				for typev in type.values
					call add(array,typev)
				endfor
			endif
		endfor
	endif
	if !empty(attr) 
		for val in attr.values
			call add(array,val)
		endfor
	endif
	return array
endf
func! VjdeTagLoader_SearchValues(tagname,attrname,cond) dict
	let array=[]
	for vjde_item in self.FindValues(a:tagname,a:attrname)
		if eval(a:cond)
			call add(array,vjde_item)
		endif
	endfor
	return array
endf
func! VjdeTagLoader_New()
	return {'tags' : [],
				\'parents' : [] ,
				\'types' :[],
				\'Load' : function('VjdeTagLoader_Load'),
				\'ParseTag' :function('VjdeTagLoader_ParseTag'),
				\'FindTag' :function('VjdeTagLoader_FindTag'),
				\'FindAttribute' :function('VjdeTagLoader_FindAttribute'),
				\'FindValues' :function('VjdeTagLoader_FindValues'),
				\'SearchTags' :function('VjdeTagLoader_SearchTags'),
				\'SearchValues' :function('VjdeTagLoader_SearchValues'),
				\'SearchAttributes':function('VjdeTagLoader_SearchAttributes')	}
endf

func! s:ShowElement(item2,mloader)
	let item2 = a:item2
if !empty(item2)
	echo item2.name
	for item3 in item2.attributes
		echo "\t".item3.type.' =>'.item3.name
		if strlen(item3.type)>0
			for type in a:mloader.types
				if type.name==item3.type
					for typev in type.values
						echo "\t\t".typev
					endfor
				endif
			endfor
		endif
		for item5 in item3.values
			echo "\t\t".item5
		endfor
	endfor
	for item4 in item2.parents
		echo "\t-------------".item4
		let p =  {}
		for par in a:mloader.parents
			if par.name==item4
				let p = par
				break
			endif
		endfor
		call s:ShowElement(p,a:mloader)

	endfor
endif
endf

let g:vjde_tag_loader={}
"let g:vjde_tag_loader =  VjdeTagLoaderGet('html',g:vjde_install_path.'/vjde/tlds/html.def')
"let item2 = g:vjde_tag_loader.FindTag('html')
"call s:ShowElement(item2,g:vjde_tag_loader)

"let item3 = g:vjde_tag_loader.FindAttribute('tr','align')
"for val in item3.values
	"echo val
"endfor

"for item  in g:vjde_tag_loader.FindValues('table','bgcolor')
	"echo item
"endfor

"let m_loader = VjdeTagLoader_New()
"call m_loader.Load('/usr/share/vim/vimfiles/plugin/vjde/tlds/html.def')
"let mcount=0
"let item2 = m_loader.FindTag('tr')
"call s:ShowElement(item2,m_loader)
"
"vim:fdm=marker:ff=unix
