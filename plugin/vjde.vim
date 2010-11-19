if exists('g:vjde_loaded') || &cp 
    finish
endif
if v:version<700
	echo 'Vim>=700 is require for VJDE!' 
	finish
endif
if !has('ruby')
   " echo 'VJDE need +ruby future is enabled!'
endif
let g:vjde_loaded = 1

if !exists('g:vjde_taglib_uri') 
	let g:vjde_taglib_uri={}
endif
if !exists('g:vjde_show_paras') 
    let g:vjde_show_paras = 0
endif
if !exists('g:vjde_completion_key')
	if has('gui_running')
		let g:vjde_completion_key='<c-space>'
	else
		let g:vjde_completion_key='<c-l>'
	endif
endif
if !exists('g:vjde_use_window')
	let g:vjde_use_window=1
endif

if !exists('g:vjde_out_path')
    let g:vjde_out_path = "."
endif

if !exists('g:vjde_lib_path') 
    let g:vjde_lib_path = ''
endif

if !exists('g:vjde_src_path')
    let g:vjde_src_path=""
endif
if !exists('g:vjde_test_path')
    let g:vjde_test_path=""
endif
if !exists('g:vjde_web_app')
    let g:vjde_web_app=""
endif
if !exists('g:vjde_cfu_downcase')
    let g:vjde_cfu_downcase="0"
endif
if !exists('g:vjde_autoload_taglib')
    let g:vjde_autoload_taglib=1
endif
if !exists('g:vjde_auto_mark')
    let g:vjde_auto_mark=1
endif
if !exists('g:vjde_xml_advance')
    let g:vjde_xml_advance=0
endif

if !exists('g:vjde_cfu_java_dot')
	let g:vjde_cfu_java_dot = 0
endif
if !exists('g:vjde_cfu_java_para')
	let g:vjde_cfu_java_para = 0
endif

if !exists('g:vjde_use_project')
	let g:vjde_use_project = 0
endif
if !exists('g:vjde_jsp_exts')
	let g:vjde_jsp_exts=''
endif

if !exists('g:vjde_java_exception')
	let g:vjde_java_exception = '\(unreported exception \)\([^ \t;]*\);'
endif
if !exists('g:vjde_java_symbol')
	let g:vjde_java_symbol= 'cannot find symbol\nsymbol\s*: class \([^ \t;\s]*\)\n'
endif

let g:vjde_path_spt=':'
if has('win32')
	let g:vjde_path_spt=';'
endif
let g:vjde_install_path=expand('<sfile>:p:h')
if has('win32unix') 
	let g:vjde_install_path=expand('`cygpath -wp '.g:vjde_install_path.'`')
endif
let g:vjde_preview_lib = ''
if has('gui_running')
if has('gui_win32') 
	let g:vjde_preview_lib = g:vjde_install_path.'/vjde/preview.dll'
elseif has('gui_gtk2')
	let g:vjde_preview_lib = g:vjde_install_path.'/vjde/preview4gtk.so'
endif
endif
let g:wspawn_available=1
if has('win32')
	let g:wspawn_available = executable('wspawn.exe')
	if !g:wspawn_available
		"echoerr 'wspawn.exe which come from plugin/vjde/ is not runable'
		"echoerr ':h vjde-install for detail'
                let g:vjde_preview_gui=0
	endif
endif

if has('ruby')
	"exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_taglib_cfu.rb'
	"command! -nargs=0 VjdeJstl ruby Vjde::init_jstl(VIM::evaluate('g:vjde_install_path')+"/vjde/tlds/")
endif

runtime plugin/vjde/vjde_preview.vim
runtime plugin/vjde/vjde_window.vim
runtime plugin/vjde/vjde_java_completion.vim
runtime plugin/vjde/vjde_tag_loader.vim
runtime plugin/vjde/vjde_java_utils.vim
runtime plugin/vjde/vjde_completion.vim
runtime plugin/vjde/vjde_menu_def.vim
runtime plugin/vjde/vjde_template.vim
runtime plugin/vjde/vjde_iab.vim
"runtime plugin/vjde/vjde_cs_completion.vim
runtime plugin/vjde/vjde_javadoc.vim

if has('ruby') && exists('g:vjde_for_ruby')
	runtime plugin/vjde/vjde_ruby_completion.vim
endif

runtime plugin/vjde/vjde_ctags_completion.vim
runtime plugin/vjde/vjde_cpp_completion.vim

if !exists('*JCommentWriter')
	runtime plugin/vjde/jcommenter.vim
endif
if !exists(':Project') && g:vjde_use_project
	runtime plugin/vjde/project.vim
endif

let java_previewer = VjdePreviewWindow_New()
let java_previewer.name = 'java_previewer'
let java_previewer.onSelect='VjdeInsertWord'
let java_previewer.previewLinesFun='GetJavaCompletionLines'
let java_previewer.docLineFun='VjdeGetDocWindowLine'

if g:vjde_autoload_taglib 
	let g:vjde_taglib_uri['http://java.sun.com/jsp/jstl/core']='stl_c'
	let g:vjde_taglib_uri['http://java.sun.com/jsp/jstl/sql']='stl_sql'
	let g:vjde_taglib_uri['http://java.sun.com/jsp/jstl/fmt']='stl_fmt'
	let g:vjde_taglib_uri['http://java.sun.com/jsp/jstl/xml']='stl_x'
	let g:vjde_taglib_uri['http://myfaces.apache.org/tobago/component']='tc'
	let g:vjde_taglib_uri['http://myfaces.apache.org/tobago/extension']='tx'
	let g:vjde_taglib_uri['http://java.sun.com/jsf/core']='jsf_c'
	let g:vjde_taglib_uri['http://java.sun.com/jsf/html']='jsf_h'
endif
"if g:vjde_autoload_stl && has('ruby')
"    ruby Vjde::init_jstl(VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/")
"endif
if v:version>=700
    "au BufNewFile,BufRead,BufEnter *.html set cfu=VjdeHTMLFun0 | let g:vjde_tag_loader=VjdeTagLoaderGet("html",g:vjde_install_path."/vjde/tlds/html.def")
    "au BufNewFile,BufRead,BufEnter *.htm set cfu=VjdeHTMLFun0 | let g:vjde_tag_loader=VjdeTagLoaderGet("html",g:vjde_install_path."/vjde/tlds/html.def")
    "au BufNewFile,BufRead,BufEnter *.xsl set cfu=VjdeHTMLFun0 | let g:vjde_tag_loader=VjdeTagLoaderGet("xsl",g:vjde_install_path."/vjde/tlds/xsl.def")
    "au BufNewFile,BufRead,BufEnter *.xsd set cfu=VjdeHTMLFun0 | let g:vjde_tag_loader=VjdeTagLoaderGet("xsl",g:vjde_install_path."/vjde/tlds/xsd.def")
    au BufNewFile,BufRead,BufEnter *.java set cfu=VjdeCompletionFun0 
    "| inoremap <buffer> <expr> <f1> VjdeJavaDoc()

    au BufNewFile,BufRead,BufEnter *.jsp set cfu=VjdeCompletionFun0  
    "| let g:vjde_tag_loader=VjdeTagLoaderGet("html",g:vjde_install_path."/vjde/tlds/html.def")

    "au! CursorHold *.java nested call java_previewer.CFU()

    for item in split(g:vjde_jsp_exts,';')
	    if strlen(item)==0 | continue | endif
	    exec 'au BufNewFile,BufRead,BufEnter *.'.item.' set cfu=VjdeCompletionFun0 '
            exec 'au BufNewFile,BufRead,BufEnter *.'.item.' imap <buffer> '.g:vjde_completion_key.' <Esc>:call java_previewer.CFU(":")<CR>a'
            exec 'au BufNewFile,BufRead,BufEnter *.'.item.' set ft=jsp'
    endfor
endif
    if g:vjde_cfu_java_dot
        au BufNewFile,BufRead,BufEnter *.java nested inoremap <buffer> . .<Esc>:call java_previewer.CFU('.')<CR>a
        au BufNewFile,BufRead,BufEnter *.java nested inoremap <buffer> @ @<Esc>:call java_previewer.CFU('@')<CR>a

        au BufNewFile,BufRead,BufEnter *.jsp nested inoremap <buffer> < <<Esc>:call java_previewer.CFU('<')<CR>a
        au BufNewFile,BufRead,BufEnter *.jsp nested inoremap <buffer> : :<Esc>:call java_previewer.CFU(':')<CR>a

        au BufNewFile,BufRead,BufEnter *.html nested inoremap <buffer> < <<Esc>:call java_previewer.CFU('<')<CR>a
        au BufNewFile,BufRead,BufEnter *.htm nested inoremap <buffer> < <<Esc>:call java_previewer.CFU('<')<CR>a

        au BufNewFile,BufRead,BufEnter *.xml nested inoremap <buffer> < <<Esc>:call java_previewer.CFU('<')<CR>a

    endif
    if g:vjde_cfu_java_para
	    au BufNewFile,BufRead,BufEnter *.java nested inoremap <buffer> ( <Esc>:call VjdeJavaParameterPreview()<CR>a(
    endif
	if g:vjde_use_window
		au BufNewFile,BufRead,BufEnter *.java nnoremap <buffer> <silent> <Leader>jd :call VjdeGetDocUnderCursor()<CR>
	endif
if has('ruby')
    func! s:VjdeGenTldData(file,name)
        if has('win32') || has('dos')
            exec '!ruby '.g:vjde_install_path.'/vjde/tld2xmldata.rb '.a:file.' '.a:name.' >'.g:vjde_install_path[0:-8].'\autoload\xml\'.a:name.'.vim'
        else
            exec '!ruby '.g:vjde_install_path.'/vjde/tld2xmldata.rb '.a:file.' '.a:name.' >'.g:vjde_install_path[0:-8].'/autoload/xml/'.a:name.'.vim'
        endif
    endf
    func! s:VjdeGenDtdData(file,name)
        if has('win32') || has('dos')
            exec '!ruby '.g:vjde_install_path.'/vjde/genvimdata.rb '.a:file.' '.a:name.' >'.g:vjde_install_path[0:-8].'\autoload\xml\'.a:name.'.vim'
        else
            exec '!ruby '.g:vjde_install_path.'/vjde/genvimdata.rb '.a:file.' '.a:name.' >'.g:vjde_install_path[0:-8].'/autoload/xml/'.a:name.'.vim'
        endif
    endf
    command -nargs=+ -complete=file VjdeTld2Data call s:VjdeGenTldData(<f-args>)
    command -nargs=+ -complete=file VjdeDtd2Data call s:VjdeGenDtdData(<f-args>)
endif

"------------------------------------------------------
"vim:fdm=marker:ff=unix
