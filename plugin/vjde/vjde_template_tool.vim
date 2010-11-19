if !exists('g:vjde_loaded') || &cp
	finish
endif

func! VjdeTemplatePara_New(n,d) 
        return {"name":a:n,"desc":a:d,"value":''}
endf
func! VjdeTemplate_AddPara(n,d) dict
        let self.paras[a:n]= VjdeTemplatePara_New(a:n,a:d)
endf
func! VjdeTemplate_SetPara(n,v) dict
        let self.paras[a:n].value=a:v
endf
func! VjdeTemplate_GetValue(str) dict
        return has_key(self.paras,a:str) ? self.paras[a:str] : eval(a:str)
endf
func! VjdeTemplate_GetLines() dict 
        let lines=[]
        for line in self.lines
                let ent = matchstr(line,'^\s*%.*%\s*$')
                if ent!=""
                        let name=substitute(ent,'\s*%\(.*\)%\s*$','\1','')
                        let entity =  has_key(self.entities,name) ? self.entities[name]:self.manager.GetTemplate(name)
                        let lines += entity.GetLines()
                        continue
                endif
                call add(lines, substitute(line,'%{\([^}]\+\)}','\=self.GetValue(submatch(1))','g'))
        endfor
        return lines
endf
func! VjdeTemplate_GetParas() dict 
        let array = self.paras
        for line in self.lines
                let ent = matchstr(line,'^\s*%.*%\s*$')
                if ent!=""
                        let name=substitute(ent,'\s*%\(.*\)%\s*$','\1','')
                        let entity =  self.manager.GetTemplate(name)
                        let array2 = entity.GetParas()
                        for arr in array2
                                if has_key(self.paras,arr.name)
                                        call entity.SetPara(arr.name,self.paras[arr.name].value)
                                        continue
                                else
                                        call add(array,arr)
                                endif
                                let self.entities[name]=entity
                        endfor
                endif
        endfor
endf
func! VjdeTemplate_New(n,m) 
        return {"paras":{},
                                \"name":a:n,
                                \"desc":'',
                                \"lines":[],
                                \"manager":a:m
                                \"entities":{},
                                \"AddPara":function('VjdeTemplate_AddPara'),
                                \"SetPara":function('VjdeTemplate_SetPara'),
                                \"GetLines":function('VjdeTemplate_GetLines'),
                                \"GetParas":function('VjdeTemplate_GetParas')
                                \}
endf
func! VjdeTemplateIndex(name,desc,pos,file) 
        return {"name":a:name,"desc":a:desc,"pos":a:pos,"file":a:file}
endf
let s:RE_TEMPLATE='^temp'
let s:RE_BODY='^body'
let s:RE_END='^endt'
let s:RE_PARA='^para'
let s:RE_TEMP_SPLIT='^temp[a-z]*\s\+\(\w\+\)\(\s\+.*\)*$'
let s:RE_PARA_SPLIT='^para[a-z]*\s\+\(\w\+\)\(\s\+.*\)*$'
func! VjdeTemplateManager_LoadIndex(fname) dict
        if !filereadable(a:fname)
                return
        endif
        let lines = readfile(a:fname)
        let index=0
        for line in lines
                if line[0]=='/'
                        let index+=1
                        continue
                endif
                if match(line,s:RE_TEMPLATE)==0
                        echo line
                        let arr=matchlist(line,s:RE_TEMP_SPLIT)
                        call add(self.indexs,VjdeTemplateIndex(arr[1],len(arr)==3?arr[2]:'',index,a:fname))
                endif
                let index+=1
        endfor
endf
func! VjdeTemplateManager_GetTemplate(name) dict
        let index={}
        for item in self.indexs
                if item.name==a:name
                        let index=item
                        break
                endif
        endfor
        if empty(index)
                return index
        endif
        let filelines = readfile(index.file)
        let intemplate = 0
        let temp={}
        let pos = index.pos
        let max = len(filelines)
        while pos<max
                let line = filelines[pos]
                if line[0]=='/'
                        continue
                endif
                if match(line,s:RE_TEMPLATE)==0
                        let arr = matchlist(line,s:RE_TEMP_SPLIT)
                        let temp = VjdeTemplate_New(arr[1],self)
                        let temp.desc=arr[2]
                elseif match(line,s:RE_END)==0
                        break
                elseif match(line,s:RE_BODY)==0
                        let intemplate=1
                elseif match(line,s:RE_PARA)==0
                        let arr = matchlist(line,s:RE_PARA_SPLIT)
                        call temp.AddPara(arr[1],arr[2])
                else
                        if intemplate
                                if line[0]=='\'
                                        call add(temp.lines,strpart(line,1))
                                else
                                        call add(temp.lines,line)
                                endif
                        endif   
                endif
        endw
        return temp
endf
func! VjdeTemplateManager_New()
        return {"indexs":[],
                                \"LoadIndex":function('VjdeTemplateManager_LoadIndex'),
                                \"GetTemplate":function('VjdeTemplateManager_GetTemplate')}
endf
"let mana2 = VjdeTemplateManager_New()
"call mana2.LoadIndex('plugin/vjde/tlds/java.vjde')
"let temp = mana2.GetTemplate("NewClass")
"for item in temp.GetParas()
"        let str = inputdialog(item.desc)
"        temp.SetPara(item.name,str)
"endfor
"for line in temp.GetLines()
"        echo line
"endfor

"vim:fdm=marker:ff=unix
