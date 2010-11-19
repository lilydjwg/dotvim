
if !exists('g:vjde_loaded') || &cp
		finish
endif
if exists('g:vjde_template_loaded') || &cp 
	finish
endif
let g:vjde_template_loaded = 1

"{{{1
if !has('ruby')
	finish
endif	
let s:VjdeNewFileTypes={1:"NewClass",2:"NewClassWithMain",3:"NewInterface"}
let s:added_lines = []
let s:add_methods = []

exec "rubyf ".g:vjde_install_path."/vjde/vjde_template.rb"
ruby Vjde::VjdeTemplateManager.load_all(VIM::evaluate('g:vjde_install_path'))
function! VjdeNewClass(type,...) "{{{2
    let pkg=''
    let cn =''
    let path=g:vjde_src_path
    if strlen(path)==0
        let path="."
    endif
    if  a:0 < 2
        let cn=inputdialog("Class Name:","")
    else
        let cn=a:2
    end
    let cpath = expand("%:h")
    if  match(cpath,g:vjde_src_path)==0 && strlen(g:vjde_src_path)!=0
	    let cpath = strpart(cpath,strlen(g:vjde_src_path)+1)
    endif
    if a:0 <1
        let pkg=inputdialog("Package Name:",substitute(cpath,'[/\\]','.','g'))
    else
        let pkg=a:1
    end
    if (cn !~ '[^ \t@$.;+\-*%&\|\^(){}/]\+') 
        echo 'Invalide Class Name:'.cn
        return 
    end
    if len(pkg)>0
        let path=path.'/'.substitute(pkg,'\.','/','g')
    end
    if (!isdirectory(path)) && exists("*mkdir")
	    call mkdir(path,'p')
    endif
    exec 'edit '.path.'/'.cn.'.java'
    let paras = {"classname":cn,"package":pkg}
    let lines = VjdeTemplateJavaRuby(s:VjdeNewFileTypes[a:type],paras)
    call append(line('$'),lines)
    let s:added_lines=[]
endf
func! VjdeJUnitCase(...)
    let pkg=''
    let cn =''
    let path=g:vjde_test_path
    if strlen(path)==0
        let path="."
    endif
    if  a:0 < 2
        let cn=inputdialog("Class Name which tested(package not required) :",expand("%:t:r"))
    else
        let cn=a:2
    end
    let cpath = expand("%:h")
    if  match(cpath,g:vjde_src_path)==0 && strlen(g:vjde_src_path)!=0
	    let cpath = strpart(cpath,strlen(g:vjde_src_path)+1)
    endif
    if a:0 <1
        let pkg=inputdialog("Package Name of class which tested:",substitute(cpath,'[/\\]','.','g'))
    else
        let pkg=a:1
    end
    if (cn !~ '[^ \t@$.;+\-*%&\|\^(){}/]\+') 
        echo 'Invalide Class Name:'.cn
        return 
    end
    if len(pkg)>0
        let path=path.'/'.substitute(pkg,'\.','/','g')
    end
    if (!isdirectory(path)) && exists("*mkdir")
	    call mkdir(path,'p')
    endif
    let s:add_methods = VjdeSelectMethods(pkg.'.'.cn,g:vjde_lib_path)
    let paras = {"classname":cn."Test","package":pkg,"testclass":cn}
    call VjdeTemplateJavaRuby("JUnitTestCase",paras)
    exec 'edit '.path.'/'.cn.'Test.java'
    call append(line('$'),s:added_lines)
    exec 'normal '.len(s:added_lines).'=='
    let s:added_lines=[]
endf
func! VjdeTemplateJavaRuby(tn,paras) "{{{2
    let s:added_lines = []
    let mf = &ft
    if mf==''
	    let mf = inputdialog('Input a file type to use.',mf)
	    if mf==''
		    echo 'Template must used with a filetype!!'
		    return 
	    endif
    endif
ruby<<EOF
    tn = VIM::evaluate("a:tn")
    $vjde_template_manager = Vjde::VjdeTemplateManager.[](VIM::evaluate("mf"))
    tplt = $vjde_template_manager.getTemplate(tn)
    if tplt != nil
	tplt.each_para { |p|
		if "1"==VIM::evaluate('has_key(a:paras,"'+p.name+'")')
			tplt.set_para(p.name,VIM::evaluate('a:paras["'+p.name+'"]'))
		else
		str=VIM::evaluate('inputdialog(\''+p.desc.gsub(/'/,"''")+' : \',"")')
		tplt.set_para(p.name,str)
		end
	}
	
    tplt.each_line { |l|
    	l.gsub!(/'/,"''")
	l.chomp!
    	VIM::command("call add(s:added_lines,'"+l+"')")
    }
    end
EOF
return s:added_lines
endf
func! s:AddMethods() 
    let l = line('.')
    for item in s:add_methods 
	call add(s:added_lines,'// Test method:')
	let str= '// '.item[0]." ".item[1]. " ".item[2]."(".join(item[3],",").")"
	if (len(item[4])>0)
		let str=str." throws ".join(item[4],",")
	endif
	call add(s:added_lines,str)
        call add(s:added_lines,'public void test'.toupper(item[2][0]).item[2][1:-1].'() {')
        call add(s:added_lines,'}')
    endfor
endf
func! VjdeAppendTemplate(name)
	call VjdeTemplateJavaRuby(a:name,{})
	let lnum = len(s:added_lines)
	if lnum>=1
		call setline(line('.'),s:added_lines[0])
	endif
	if lnum>1
		call append(line('.'),s:added_lines[1:-1])
	endif
	exec 'normal '.lnum.'=='
endf
func! VjdeTemplateWizard()
ruby<<EOF
$vjde_template_manager = Vjde::VjdeTemplateManager.[](VIM::evaluate("&ft"))
$vjde_template_manager.indexs.each_with_index { |ti,i|
	VIM::command("echo \" #{i}\t#{ti.name}\t#{ti.desc}\"")
}
puts "Enter a number of template:"
str = VIM::evaluate('inputdialog("Enter a number of template:","")')
str.strip!
if str.length > 0
	VIM::command('call VjdeAppendTemplate("'+$vjde_template_manager.indexs[str.to_i].name+'")')
end
EOF
endf
func! s:VjdeAddTemplate(fname)
	ruby $vjde_template_manager = Vjde::VjdeTemplateManager.[](VIM::evaluate("&ft"))
	ruby $vjde_template_manager.add_file(VIM::evaluate("a:fname"))
	call VjdeTemplateReload()
endf
func! VjdeBrowsTemplate()
    let prj=""
    if has("gui_running")
        let prj = browse("Please Select a VJDE template file :","Template file",".","")
    else
        let prj = input("Please Enter a VJDE template filename :")
    endif
    if prj == ""
        return 
    endif
	ruby $vjde_template_manager = Vjde::VjdeTemplateManager.[](VIM::evaluate("&ft"))
	ruby $vjde_template_manager.add_file(VIM::evaluate("prj"))
	call VjdeTemplateReload()
endf
let s:templates=[]
func! s:VjdeTemplatesAdd(name,desc)
	call add(s:templates,{'name':a:name,'desc': substitute(a:desc,'\s*\(.*\)[\n\r]*\s*$','\1','') })
endf
func! s:VjdeTemplatesCreateMenu(f)
for item in s:templates
	exec 'amenu Vim\ &JDE.&Wizard.&'.a:f.'\ Templates.'.item.name.' :call VjdeAppendTemplate("'.item.name.'")<cr>'
	"if strlen(item.name) 
		"exec 'tmenu Vim\ &JDE.Wizard.All\ Templates.'.item.name.' '.item.desc
	"endif
endfor
endf
func! s:VjdeTemplates2Menu(f)
	if !empty(s:templates)
		call remove(s:templates,0,-1)
	endif
	let f=a:f
ruby<<EOF
	$vjde_template_manager = Vjde::VjdeTemplateManager.[](VIM::evaluate("f"))
$vjde_template_manager.indexs.each_with_index { |ti,i|
	VIM::command('call s:VjdeTemplatesAdd("'+ti.name+'","'+ti.desc+'")')
}
EOF
	call s:VjdeTemplatesCreateMenu(f)
endf
func! VjdeTemplateReload()
	unmenu! Vim\ &JDE.&Wizard.All\ Templates
endf
"{{{2 menu defination
amenu Vim\ &JDE.&Wizard.&New\ Class\ \.\.\.    :call VjdeNewClass(1) <CR>
amenu Vim\ &JDE.&Wizard.New\ Class\ (&main)\ \.\.\.    :call VjdeNewClass(2) <CR>
amenu Vim\ &JDE.&Wizard.New\ &Interface\ \.\.\.    :call VjdeNewClass(3) <CR>
amenu Vim\ &JDE.&Wizard.--JUnit--    :
amenu Vim\ &JDE.&Wizard.New\ &TestCase\ \.\.\.    :call VjdeJUnitCase()<CR>
amenu Vim\ &JDE.&Wizard.--Variable--    :
amenu Vim\ &JDE.&Wizard.Add\ &Property\ \.\.\.    :call VjdeAppendTemplate("NewMember") <CR>
amenu Vim\ &JDE.&Wizard.Add\ &Singleton\ stub    :call VjdeAppendTemplate("Singleton") <CR>
amenu Vim\ &JDE.&Wizard.--Cosutom--    :
amenu Vim\ &JDE.&Wizard.Add\ Template\ file\ \.\.\.	:call VjdeBrowsTemplate() <CR>
amenu Vim\ &JDE.&Wizard.Select\ Template\ \.\.\.	:call VjdeTemplateWizard() <CR>
amenu Vim\ &JDE.&Wizard.--Cosutom2--    :
ruby<<EOF
Vjde::VjdeTemplateManager.loaded.each_key { |k|
	VIM::command('call s:VjdeTemplates2Menu("'+k+'")')
}
EOF
"call s:VjdeTemplates2Menu('java')
"{{{2 command defination

command! -nargs=* VjdeNclass call VjdeNewClass(1,<f-args>)
command! -nargs=* VjdeNmain call VjdeNewClass(2,<f-args>)
command! -nargs=* VjdeNinte call VjdeNewClass(3,<f-args>)
command! -nargs=0 VjdeNprop call VjdeAppendTemplate("NewMember")
command!  -nargs=1 -complete=file VjdeWadd call s:VjdeAddTemplate(<f-args>)
command!  -nargs=0  VjdeWizard call VjdeTemplateWizard(<f-args>)

" vim:fdm=marker:ft=vim:ff=unix

