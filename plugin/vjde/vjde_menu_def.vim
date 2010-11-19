
if !exists('g:vjde_loaded') || &cp
		finish
endif
let s:project_name=""
func!  VjdeJavaProjectAddJars()
    let prj=""
    if has("browse")
        let prj = browsedir("Select the directory of jars",".")
    else
        let prj = input("Input the directory of jars:",'.')
    endif
    let str = glob(prj.'/*.jar')
    for item in split(str,"\n")
	    if stridx(g:vjde_lib_path,item)<0
		    let g:vjde_lib_path.= (g:vjde_path_spt.item)
	    endif
    endfor
    let g:vjde_java_cfu={}
endf
func! VjdeNewJavaProject()
	call VjdeSaveAsMenu()
	if  s:project_name==''
		return
	endif
	let src=inputdialog('Input a source path(relative your project):','src')
	let out=inputdialog('Input a output path(relative your project):','classes')
	let g:vjde_src_path=src
	let g:vjde_out_path=out
	let g:vjde_lib_path.= (g:vjde_path_spt.out)
	call s:VjdeSaveProject()
	exec 'cd '.substitute(s:project_name,'[\\/]\+[^\\/]*$','','')
endf
function! s:VjdeUpdateMenu(name) "{{{2
    "exec 'aun .10 Vim\ &JDE.Project<TAB>'.s:project_name.' :<CR>'
    "let s:project_name=a:name
    "exec 'amenu! .10 Vim\ &JDE.Project<TAB>'.s:project_name.' :<CR>'
endf
function! VjdeBrowseProject() " {{{2
    let prj=""
    if has("browse")
        let prj = browse(0,"Please Select a Vim JDE Project",".","")
    else
        let prj = input("Please Enter a Vim JDE Project:")
    endif
    if prj == ""
        return 
    endif
    
    if stridx(prj,'/')!=-1 || stridx(prj,'\')!=-1 
	    exec 'cd '.substitute(prj,'[\\/]\+[^\\/]*$','','')
    endif
    call s:VjdeLoadProject(prj)
    if exists(':Project')
	    if filereadable('.prj') 
		    exec 'Project .prj'
	    elseif filereadable('.vimprojects')
		    exec 'Project .vimprojects'
	    endif
    endif
endf

function! s:VjdeLoadProject(prj) " {{{2
    call s:VjdeUpdateMenu(a:prj)
    exec 'source '.a:prj
    let s:project_name=a:prj
    let g:vjde_java_cfu = {}
endf
function! VjdeSaveMenu()
    call s:VjdeSaveProject()
endf
function! VjdeSaveAsMenu()
        if has("browse")
            let prj = browse(1,"Please Select a Vim JDE Project",".","")
        else
            let prj = input("Please Enter a Vim JDE Project:")
        endif
        call s:VjdeSaveProjectAs(prj)
endf
function! s:VjdeSaveProject() " {{{2
    let prj=""
    if s:project_name==""
        if has("browse")
            let prj = browse(1,"Please Select a Vim JDE Project",".","")
        else
            let prj = input("Please Enter a Vim JDE Project:")
        endif
        if prj!=""
            call s:VjdeSaveProjectAs(prj)
            let s:project_name=prj
        endif
    else
        call s:VjdeSaveProjectAs(s:project_name)
    endif
endf
func! s:VjdeWriteStr(name) 
	call add(s:lines,'let '.a:name."='".escape(eval(a:name),"'")."'")
endf
func! s:VjdeWriteNumber(name) 
	call add(s:lines,'let '.a:name."=".eval(a:name))
endf
function! s:VjdeSaveProjectAs(prj) " {{{2
	if strlen(a:prj)==0 || a:prj=='<empty>'
		let s:project_name=''
		return
	endif
	let s:lines=[]
	call s:VjdeWriteStr("g:vjde_out_path")
	call s:VjdeWriteStr("g:vjde_src_path")
	call s:VjdeWriteStr("g:vjde_lib_path")
	call s:VjdeWriteStr("g:vjde_web_app")
	call s:VjdeWriteStr("g:vjde_test_path")
	call s:VjdeWriteStr("g:vjde_java_command")
	call s:VjdeWriteNumber("g:vjde_show_paras")
	call s:VjdeWriteNumber("g:vjde_xml_advance")
	call add(s:lines,'" vim :ft=vim:')
	call writefile(s:lines,a:prj)
	let s:lines=[]
	let s:project_name = a:prj
	return
endf
function! VjdeSetJava(str) 
	let g:vjde_java_command=a:str
endf
function! VjdeGetJava()
    return g:vjde_java_command
endf
function! s:VjdeAddTld(...) "{{{2
    let uri=""
    if (a:0==0) 
        echo "Vjdeaddtld <file> [uri]"
        return 
    endif
    if (a:0>=2)
        let uri=a:2
    endif
ruby<<EOF
    loader = Vjde::VjdeProjectTlds.instance
    loader.add(VIM::evaluate("a:1"),VIM::evaluate("uri"))
EOF
endf
function! s:VjdeAddDtd(...) "{{{2
    let al=''
    if (a:0==0) 
        echo 'VjdeAddDtd <file> [name]'
        return 0
    endif
    if (a:0>=2)
        let al=a:2
    endif
    ruby $vjde_dtd_loader.load(VIM::evaluate('a:1'),VIM::evaluate('al'))
endf
function! VjdeListDtds()
ruby<<EOF
str = "["
str << '"http://www.w3.org/1999/XSL/Transform"'
str << ","
str << '"http://www.w3.org/TR/html4"'
str << ","
str << '"http://www.w3.org/TR/html401"'
$vjde_dtd_loader.dtds.each { |d|
str << ',"'+d.malias+'"'
}
str << ']'
VIM::command("let res1="+str);
EOF
return res1
endf
func! s:VjdeRunParameter(t)
	let cls=''
	if ( a:t==1)
		let cls = inputdialog('Input the class name with full package name','')
	endif
	let para = inputdialog('Input the parameter for running','')
	call s:VjdeRunCurrent(cls,para)
endf
func! s:VjdeRunCurrent(...)
	let args=''
	let ct = 2
	while ct <= a:0
		exe "let args.=a:".ct
        let args.=" "
		let ct+=1
	endwhile
        if a:0>=1 && strlen(a:1)>0
                exec "!java  -cp \"".g:vjde_lib_path."\" ".a:1.' '.args
		return
        endif

        let cname = expand("%:t:r")
        let cpath= expand("%:h")
		let cpath= substitute(cpath,'^'.getcwd()."/","","g")
        if strlen(cpath)>strlen(g:vjde_src_path) "0
            if  strlen(g:vjde_src_path)!=0 && match(cpath,g:vjde_src_path)==0 
                let cpath = strpart(cpath,strlen(g:vjde_src_path)+1)
            elseif strlen(g:vjde_test_path)!=0 && match(cpath,g:vjde_test_path)==0  
                let cpath = strpart(cpath,strlen(g:vjde_test_path)+1)
            endif
            exec "!java  -cp \"".g:vjde_lib_path."\" ".substitute(cpath,'[/\\]','.','g').".".cname.' '.args
    else
        exec "!java  -cp \"".g:vjde_lib_path."\" ".cname.' '.args
    endif
endf
" create menu here {{{2
"amenu Vim\ &JDE.&Project.Project :
"amenu Vim\ &JDE.&Project.--Project1-- :
amenu Vim\ &JDE.&Project.&New\ Java\ Project\.\.\.    :call VjdeNewJavaProject() <CR>
amenu Vim\ &JDE.&Project.&New\ Web\ Project\.\.\.    :let g:vjde_web_app=inputdialog('Input the web-app where jsp/html is .','web-app') <bar> call VjdeNewJavaProject() <CR>
amenu Vim\ &JDE.&Project.--Project-- :
amenu Vim\ &JDE.&Project.&Load\ Project\.\.\.    :call VjdeBrowseProject() <CR>
tmenu Vim\ &JDE.&Project.&Load\ Project\.\.\.    Browse a project file to use.
amenu Vim\ &JDE.&Project.&Save\ Project    :call VjdeSaveMenu()<CR>
amenu Vim\ &JDE.&Project.&Save\ Project\ As\.\.\.      :call VjdeSaveAsMenu()<CR>
amenu Vim\ &JDE.&Project.--other--      :
amenu Vim\ &JDE.&Project.Load\ S&TL\ TLDS  :VjdeJstl <CR>
tmenu Vim\ &JDE.&Project.Load\ S&TL\ TLDS  loade the Standard taglibray for use
amenu Vim\ &JDE.&Project.Avaiable\ &Dtds\ \.\.\.      :echo VjdeListDtds()<CR>
tmenu Vim\ &JDE.&Project.Avaiable\ &Dtds      Query the available Docuement type definations (xml)
amenu <silent> Vim\ &JDE.Project.Add\ DTD(XML)\ \.\.\.      :let sefile =has('browse')? browse(0,"DTD File",".",""):inputdialog("Input a Document Type Define file",".","") <BAR> let ns=inputdialog("Enter the namspace or other name","") <BAR> call <SID>VjdeAddDtd(sefile,ns)<CR>
amenu <silent> Vim\ &JDE.Project.Add\ TLD(JSP)\ \.\.\.      :let sefile = has('browse')?browse(0,"TLD File",".",""):inputdialog("Input a Taglib Library Define file",".","") <BAR> let ns=inputdialog("Enter the uri for tld,(maybe empty)","") <BAR> call <SID>VjdeAddTld(sefile,ns)<CR>
tmenu <silent> Vim\ &JDE.Project.Add\ TLD(JSP)     add Taglib defination file to project 
amenu Vim\ &JDE.-Operation-    :
amenu Vim\ &JDE.Show\ &Information<TAB>:Vjdei  :Vjdei<CR>
tmenu Vim\ &JDE.Show\ &Information<TAB>:Vjdei  show the variable , function or class infomation
amenu Vim\ &JDE.Goto\ &Declarition<TAB>:Vjdegd        :Vjdegd<CR>
tmenu Vim\ &JDE.Goto\ &Declarition<TAB>:Vjdegd       Goto defination of current function, search the [path] 
amenu Vim\ &JDE.-template-    :
amenu Vim\ &JDE.&Wizard.Wizard  :
amenu Vim\ &JDE.&Wizard.--template1--  :
amenu Vim\ &JDE.-Refactor-    :
amenu Vim\ &JDE.&Source(Java).&Override\ methods\ \.\.\.  :call Vjde_override(0)<CR>
amenu Vim\ &JDE.&Source(Java).&Implements\ interfaces\ \.\.\.  :call Vjde_override(1)<CR>
amenu Vim\ &JDE.&Source(Java).&Generate\ Constructor  :call VjdeGenerateConstructor()<CR>
amenu Vim\ &JDE.&Source(Java).Generate\ Getter/&Setter :call Vjde_get_set()<CR>
amenu Vim\ &JDE.&Source(Java).Add\ S&ingleton\ stub    :call VjdeAppendTemplate("Singleton") <CR>
amenu Vim\ &JDE.&Source(Java).--source1-- :
amenu Vim\ &JDE.&Source(Java).Extract\ to\ &local  :call Vjde_rft_var(2)<CR>
amenu Vim\ &JDE.&Source(Java).Extract\ to\ &member  :call Vjde_rft_var(1)<CR>
amenu Vim\ &JDE.&Source(Java).Extract\ to\ &argument  :call Vjde_rft_arg()<CR>
vmenu Vim\ &JDE.&Source(Java).Extract\ to\ &const  :call Vjde_rft_const()<CR>
vmenu Vim\ &JDE.&Source(Java).Surround\ with\ &try/catch  :call Vjde_surround_try()<CR>
vmenu Vim\ &JDE.&Source(Java).&sort\ import  :call Vjde_sort_import()<CR>
amenu Vim\ &JDE.&Source(Java).&extract\ import\ \.\.\.  :call Vjde_ext_import()<CR>
amenu Vim\ &JDE.&Source(Java).--doc--  :
amenu Vim\ &JDE.&Source(Java).Create\ Java&Doc	:call JCommentWriter()<cr>
vmenu Vim\ &JDE.&Source(Java).Create\ JavaDocE&x	:call JCommentWriter()<cr>
amenu Vim\ &JDE.&Source(Java).Invalidate\ JavaDoc	:call SearchInvalidComment(0)<cr>
amenu Vim\ &JDE.-fixtools-    :
amenu Vim\ &JDE.&Fixerror\ with\ try/catch    :call Vjde_fix_try()<CR>
amenu Vim\ &JDE.Fi&xerror\ with\ throws    :call Vjde_fix_throws()<CR>
amenu Vim\ &JDE.Fixerror\ with\ i&mport    :call Vjde_fix_import()<CR>
amenu Vim\ &JDE.&Add\ import  :call Vjde_fix_import1()<CR>
amenu Vim\ &JDE.-tools-    :
amenu Vim\ &JDE.&Compile\ file    :comp javac <BAR> Vjdec <CR>
amenu Vim\ &JDE.&Run\ current    :Vjder <CR>
amenu <silent> Vim\ &JDE.Run\ current(&parameter)\.\.\.    :call <SID>VjdeRunParameter(0) <CR>
amenu <silent> Vim\ &JDE.Run\ c&lass\.\.\.    :let cls = inputdialog("input the class name(with package) :","") <BAR> call <SID>VjdeRunCurrent(cls) <CR>
amenu <silent> Vim\ &JDE.Run\ class(param&eter)\.\.\.    :call <SID>VjdeRunParameter(1) <CR>
amenu Vim\ &JDE.-Params-    :
"amenu Vim\ &JDE.Se&ttings.Settings     :
"amenu Vim\ &JDE.Se&ttings.-Params1-    :
amenu <silent> Vim\ &JDE.Se&ttings.Java.Set\ Source\ Path\ \.\.\. :let g:vjde_src_path=has('browse')?browsedir("The source path:",g:vjde_src_path): inputdialog("Please Enter the source path:",g:vjde_src_path) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Set\ Test-Source\ Path\ \.\.\. :let g:vjde_test_path=has('browse')?browsedir("Test-source path:",g:vjde_test_path):inputdialog("Please Enter the test-source path:",g:vjde_test_path) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Set\ WebApp\ Path\ \.\.\. :let g:vjde_web_app=has('browse')?browsedir("WebApp path:",g:vjde_web_app):inputdialog("Please Enter the WebApp path:",g:vjde_web_app) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Add(jar/path)\ To\ class\ path\ \.\.\. :let g:vjde_lib_path.=g:vjde_path_spt.(has('browse')?browse(0,"WebApp path:",".",''):inputdialog("Please Enter the classpath:",g:vjde_lib_path)) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Add(jars)\ under\ path\ \.\.\. :call VjdeJavaProjectAddJars()<cr>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Set\ Class\ Path\ \.\.\. :let g:vjde_lib_path=inputdialog("Please Enter the classpath:",g:vjde_lib_path) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Set\ Out\ Path\ \.\.\. :let g:vjde_out_path=has('browse')?browsedir("Out dir:",g:vjde_out_path):inputdialog("Please Enter the Out dir:",g:vjde_out_path) <CR>
amenu  Vim\ &JDE.Se&ttings.--cfu-- :
amenu <silent> Vim\ &JDE.Se&ttings.&Java.Set\ Java\ command :let str=inputdialog("Please Enter the java command[".VjdeGetJava()."]:","java") <BAR> call VjdeSetJava(str) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.&Reload\ lib\ path :let  g:vjde_java_cfu={} <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Java.&Document\ path :let  g:vjde_javadoc_path=inputdialog('Input the java document path',g:vjde_javadoc_path)
amenu  Vim\ &JDE.Se&ttings.&Java.--sp--	:
amenu  Vim\ &JDE.Se&ttings.&Java.Add\ out\ path\ to\ lib   :let g:vjde_lib_path.=g:vjde_out_path <CR>
amenu  Vim\ &JDE.Se&ttings.&Java.Add\ source\ to\ path   :exec 'set path+='.g:vjde_src_path <CR>
amenu  Vim\ &JDE.Se&ttings.&Java.Add\ Test\ source\ to\ path   :exec 'set path+='.g:vjde_src_path <CR>

amenu <silent> Vim\ &JDE.Se&ttings.Previews.Show\ &preview(console)\ (on/off) :let g:vjde_show_preview=1-g:vjde_show_preview <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Previews.Show\ preview(&gui)\ (on/off)	:let g:vjde_preview_gui=1-g:vjde_preview_gui <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Previews.Set\ preview(gui)\ &width	:let g:vjde_preview_gui_width=inputdialog("The width of the preview window",g:vjde_preview_gui_width) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Previews.Set\ preview(gui)\ &height	:let g:vjde_preview_gui_height=inputdialog("The height of the preview window",g:vjde_preview_gui_height) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Previews.Set\ document(gui)\ w&idth	:let g:vjde_doc_gui_width=inputdialog("The width of the document window",g:vjde_doc_gui_width) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Previews.Set\ document(gui)\ h&eight	:let g:vjde_doc_gui_height=inputdialog("The height of the document window",g:vjde_doc_gui_height) <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Previews.Show\ document(gui)\ &delay 	:let g:vjde_doc_delay=inputdialog("Show the document delay timemillis(ms)",g:vjde_doc_delay) <CR>

func! VjdeSetupCtagsCFU()
	set cfu=VjdeCtagsCFU0
	imap <buffer> <c-space> <esc>:call g:vjde_cpp_previewer.CFU("<c-space>",0)<cr>a
endf
amenu <silent> Vim\ &JDE.Se&ttings.&Ctags.&Use\ ctags\ Completion	:call VjdeSetupCtagsCFU()<cr>
amenu <silent> Vim\ &JDE.Se&ttings.&Ctags.&Generate\ tag\ index(s) :call VjdeCppGenerateIdx()<cr>
func! VjdeSetupIab()
	imap <buffer> <c-j> <esc>:call VjdePreviewIab({})<cr>a
endf
amenu Vim\ &JDE.Se&ttings.&Use\ Iabbr :call VjdeSetupIab()<cr>
func! VjdeSetupJSP()
	set cfu=VjdeCompletionFun0
	let g:vjde_tag_loader=VjdeTagLoaderGet("html",g:vjde_install_path."/vjde/tlds/html.def") 
	imap <buffer> <C-space> <Esc>:call java_previewer.CFU('<C-space>')<CR>a
	set ft=jsp
	"if strlen(&ft)==0 | set ft=jsp | endif
endf
func! VjdeSetupHTML()
	set cfu=VjdeHTMLFun0
	let g:vjde_tag_loader=VjdeTagLoaderGet("html",g:vjde_install_path."/vjde/tlds/html.def") 
	imap <buffer> <C-space> <Esc>:call java_previewer.CFU('<C-space>')<CR>a
	"if strlen(&ft)==0 | set ft=html | endif
endf
amenu Vim\ &JDE.Se&ttings.Treat\ as\ java	:call VjdeSetupJSP() <cr>
amenu Vim\ &JDE.Se&ttings.Treat\ as\ jsp	:call VjdeSetupJSP() <cr>
amenu Vim\ &JDE.Se&ttings.Treat\ as\ html	:call VjdeSetupHTML() <cr>
amenu <silent> Vim\ &JDE.Se&ttings.&Show\ Params(on/off) :let g:vjde_show_paras=1-g:vjde_show_paras <CR>
amenu <silent> Vim\ &JDE.Se&ttings.&Completion\ Child(XML)(on/off) :let g:vjde_xml_advance=1-g:vjde_xml_advance <CR>
amenu  Vim\ &JDE.Se&ttings.--find-- :
amenu Vim\ &JDE.-help-    :
amenu Vim\ &JDE.Create\ Index     :helptag $VIM/vimfiles/doc <CR>
amenu Vim\ &JDE.Vjde\ &Help<TAB>:h\ vjde     :h vjde<CR>
"command for project {{{2
command!  -nargs=1 -complete=file Vjdeload call s:VjdeLoadProject(<f-args>)
command!  -nargs=* -complete=file Vjdeas call s:VjdeSaveProjectAs(<f-args>)
command!  -nargs=* -complete=file VjdeaddTld call s:VjdeAddTld(<f-args>)
command!  -nargs=* -complete=file VjdeaddDtd call s:VjdeAddDtd(<f-args>)
command!  -nargs=0 Vjdelistdtds echo VjdeListDtds()
command!  -nargs=0 -complete=file Vjdesave call s:VjdeSaveProject()
command! -nargs=0 Vjdec :compiler javac_ex <bar> exec "make -d \"".g:vjde_out_path."\" -classpath \"".g:vjde_lib_path."\" ".expand("%")
command! -nargs=* Vjder :call s:VjdeRunCurrent(<f-args>)
if v:version>=700
    "command!  -nargs=0 Vjdesetup set cfu=VjdeCompletionFun0 
endif

" vim:fdm=marker :ff=unix
