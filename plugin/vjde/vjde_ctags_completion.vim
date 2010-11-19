
if !exists('g:vjde_loaded') || &cp
	finish
endif

if !exists('g:vjde_ctags_exts')
		let g:vjde_ctags_exts=''
endif
if !exists('g:vjde_readtags')
		if has('win32') 
				let g:vjde_readtags=g:vjde_install_path.'/vjde/readtags.exe'
		else
				let g:vjde_readtags=g:vjde_install_path.'/vjde/readtags'
		endif

endif
if !exists('g:vjde_max_tags')
		let g:vjde_max_tags=100
endif
if !exists('g:vjde_max_deeps')
		let g:vjde_max_deeps=2
endif
if !exists('g:vjde_ctags_ruby')
		let g:vjde_ctags_ruby = has('ruby')
endif
if g:vjde_ctags_ruby 
		exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_ctags_support.rb'
else
		runtime plugin/vjde/vjde_ctags_support.vim
endif
let s:matched_tags=[]
let s:retlines=[]
let s:header=''
func! GetCTAGSCompletionLines(previewer) "{{{2
	call add(a:previewer.preview_buffer,s:header)
	for item in s:matched_tags
		call add(a:previewer.preview_buffer,item.kind.' '.item.word.';'.item.info)
	endfor
endf
func! VjdeGetMatchedTag() 
    return s:matched_tags
endf
func! s:VjdeAddToTags(name,kind,cmd) "{{{2
	call add(s:matched_tags,{ 'word' : a:name , 'kind' : a:kind , 'info' : a:cmd , 'icase': 0 })
	call add(s:retlines,a:name)
endf
func! s:VjdeCleanTags() "{{{2
	if !empty(s:matched_tags)
		call remove(s:matched_tags,0,-1)
	endif
	if !empty(s:retlines)
			call remove(s:retlines,0,-1)
	endif
endf
func! VjdeGetCppCFUTags()
	return s:matched_tags
endf
func!  VjdeHandleTags(tg,ff)
		call s:VjdeAddToTags(a:tg.name,a:tg.kind,a:tg.cmd)
		return 1
endf
" completion for a word, a:1 is fully or partly
func! CtagsCompletion(word,...) "{{{2
	if strlen(a:word)==0
		return
	endif
	let full=0
	if a:0 > 0
			let full = a:1
	endif
	call s:VjdeCleanTags()
	let word = a:word
	let s:header = word.':'
	let s:retlines=[]
	if !g:vjde_ctags_ruby && executable(g:vjde_readtags)
			let cmp = VjdeReadTags_New(&tags,g:vjde_readtags)
			let cmp.max_tags = g:vjde_max_tags
			call cmp.EachTag(word,'VjdeHandleTags',full)
			return s:matched_tags
	endif
ruby<<EOF
	taglist = Vjde::getCtags(VIM::evaluate('&tags'),VIM::evaluate('g:vjde_readtags'))
	taglist.max=VIM::evaluate("g:vjde_max_tags").to_i + 50
	taglist.max_deep=VIM::evaluate("g:vjde_max_deeps").to_i
	taglist.count=0
	taglist.each_tag(VIM::evaluate('word'),VIM::evaluate("full")==1) { |t,f|
		cmd = t.cmd
		cmd.gsub!('\\','\\\\\\')
		cmd.gsub!('"','\"')

		VIM::command('call s:VjdeAddToTags("'+t.name+'","'+t.kind+'","'+cmd+'")')
		taglist.count+=1
		#VIM::command('call add(s:retlines,"'+t.name+'")')
	}
EOF
	return s:matched_tags
endf

func! CtagsCompletion2(cls,word,...) "{{{2
	call s:VjdeCleanTags()
	let s:header = a:cls.':'
	let cls = a:cls
	let word = a:word
	let full=0
	if a:0 > 0
			let full = a:1
	endif
	let s:retlines=[]
	if !g:vjde_ctags_ruby && executable(g:vjde_readtags)
			let cmp = VjdeReadTags_New(&tags,g:vjde_readtags)
			let cmp.max_tags = g:vjde_max_tags
			call cmp.EachMember(cls,word,'VjdeHandleTags',full)
			return s:matched_tags
	endif
ruby<<EOF
	taglist = Vjde::getCtags(VIM::evaluate('&tags'),VIM::evaluate('g:vjde_readtags'))
	taglist.max=VIM::evaluate("g:vjde_max_tags").to_i 
	taglist.max_deep=VIM::evaluate("g:vjde_max_deeps").to_i
	taglist.count=0
	taglist.each_member(VIM::evaluate('cls'),VIM::evaluate('word'),VIM::evaluate("full")==1) { |t,f|
		cmd = t.cmd
		cmd.gsub!('\\','\\\\\\')
		cmd.gsub!('"','\"')
		VIM::command('call s:VjdeAddToTags("'+t.name+'","'+t.kind+'","'+cmd+'")')
		taglist.count+=1
		#VIM::command('call add(s:retlines,"'+t.name+'")')
	}
EOF
	return s:matched_tags
endf
func! VjdeCtagsCFU0(findstart,base)
		return VjdeCtagsCFU(getline('.'),a:base,col('.'),a:findstart)
endf
func! VjdeCtagsCFU(line,base,col,findstart) "{{{2
    if a:findstart
        let s:last_start  = VjdeFindStart(a:line,a:base,a:col,'[\[\].> \t:?)(+\-*/&|^,{}]')
	return s:last_start
    endif
	return CtagsCompletion(a:base)
endf

for item in split(g:vjde_ctags_exts,';')
	if strlen(item)>0
		exec 'au BufNewFile,BufRead,BufEnter *.'.item.' set cfu=VjdeCtagsCFU0'
		exec 'au BufNewFile,BufRead,BufEnter *.'.item.' imap <buffer> '.g:vjde_completion_key.' <Esc>:call g:vjde_cpp_previewer.CFU("<C-space>",0)<CR>a'
	endif
endfor
" vim:ft=vim:ts=4:tw=72
