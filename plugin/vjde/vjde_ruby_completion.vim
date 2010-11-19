if !exists('g:vjde_loaded') || &cp
	finish
endif
if !exists('g:vjde_ruby_include')
	let g:vjde_ruby_include=''
endif
let g:vjde_ruby_previewer= VjdePreviewWindow_New()
let g:vjde_ruby_previewer.name = 'g:vjde_ruby_previewer'
let g:vjde_ruby_previewer.onSelect='VjdeInsertWord'
let g:vjde_ruby_previewer.previewLinesFun='GetRubyCompletionLines'
let g:vjde_ruby_previewer.docLineFun=''

let s:matched_member=[]
let s:types=[]
let s:header=''
func! GetRubyCompletionLines(previewer) "{{{2
	call add(a:previewer.preview_buffer,s:header)
	for item in s:matched_member
		call add(a:previewer.preview_buffer,item.kind.' '.item.name.';')
	endfor
endf
func! RubyMember_New(kind,name)
	return {'kind' : a:kind,
				\ 'name':a:name }
endf
func! VjdeGetRubyType(v)
	let stopline=1
	let vtp=''
	let pos=getpos('.')
	"lvim /^\s*require\s\+.\+$/ %
	let [lnum,lcol] = searchpos('^\s*#\s*@var\s*'.a:v.'\>\s\+[^ \t]\+\s*$','nb',stopline)
	if lnum!=0 && lcol!=0
		call setpos('.',pos)
		let str = getline(lnum)
		let vtp = substitute(str,'^\s*#\s*@var\s*'.a:v.'\>\s\+\([^ \t]\+\)\s*$','\1','')
		return vtp
	endif
	call setpos('.',pos)
	let [lnum,lcol] = searchpos(''.a:v.'\>\s*[+\-*/]*=\s*\([^ \t]\+.\(new\|open\|get_instance\)\>\|[\[{"''/]\|%r{\)','nb',stopline)
	if lnum!=0 && lcol!=0
		let str = matchstr(getline(lnum),'=\s*\([^ \t]\+.\(new\|open\|get_instance\)\>\|[\[{"''/]\|%r{\)',lcol)
		let str = substitute(str,'^=\s*','','')
		call setpos('.',pos)
		if str=='"' || str==''''
			return 'String'
		elseif str=='['
			return 'Array'
		elseif str=='{'
			return 'Hash'
                elseif str=='/' || str=='%'
                        return 'Regexp'
		elseif strlen(str)>4
                    let l = stridx(str,'.')
                    return str[0:l-1]
		end
		return 'Object'
	endif
	call setpos('.',pos)
	if vtp==''
		if g:vjde_for_ruby==2
			return inputdialog('Input the type of the variable','Object')
		else
			return "Object"
		endif
	endif
endf
func! VjdeRubyCFU0(findstart,base)
	return VjdeRubyCFU(getline('.'),a:base,col('.'),a:findstart)
endf
func! s:AddToPreviews(kind,name)
	call add(s:matched_member,{'kind' : a:kind , 'word':a:name})
	"call add(s:matched_member,RubyMember_New(a:kind,a:name))
endf
func! VjdeRubyCFU(line,base,col,findstart) "{{{2
    if a:findstart
        let s:last_start  = VjdeFindStart(a:line,a:base,a:col,'[.> \t:?)(+\-*/&|^,]')
	return s:last_start
    endif
    let s:types=VjdeObejectSplit(VjdeFormatLine(strpart(a:line,0,s:last_start)))
    if len(s:types) ==0
	    return []
    endif
    let tp = VjdeGetRubyType(s:types[0])
    if strlen(tp) < 1
	    return ''
    endif
    let base=a:base
    let s:lines=''
    let s:header=tp.':'
    if !empty(s:matched_member)
	    call remove(s:matched_member,0,-1)
    endif
ruby <<EOF
	re = /^\s*require\s*['"][^'"]*['"]\s*$/
	cbuf = VIM::Buffer.current
	for i in ( 1..cbuf.line_number) 
		str = cbuf[i]
		eval(str) if str.index(re)
	end
	eval("methods = "+VIM::evaluate('tp')+".public_instance_methods - Object.methods")
	#eval("methods = "+VIM::evaluate('tp')+".instance_variables")
	methods.sort!
	base = VIM::evaluate('base')
	if base==nil || base==''
		methods.each { |m|
		VIM::command('call s:AddToPreviews("f","'+m+'")')
		}
	else
		methods.each { |m|
		VIM::command('call s:AddToPreviews("f","'+m+'")') if m[0,base.length]==base
		}
	end
	eval("methods = "+VIM::evaluate('tp')+".instance_variables - Object.instance_variables")
	methods.sort!
	if base==nil || base==''
		methods.each { |m|
		VIM::command('call s:AddToPreviews("m","'+m+'")')
		}
	else
		methods.each { |m|
		VIM::command('call s:AddToPreviews("m","'+m+'")') if m[0,base.length]==base
		}
	end
EOF
	return s:matched_member
	"return join(s:matched_member,"\n")
endf
let item='rb'
exec 'au BufNewFile,BufRead,BufEnter *.'.item.' set cfu=VjdeRubyCFU0'
exec 'au BufNewFile,BufRead,BufEnter *.'.item.' imap <buffer> '.g:vjde_completion_key.' <Esc>:call g:vjde_ruby_previewer.CFU("<C-space>",0)<CR>a'
