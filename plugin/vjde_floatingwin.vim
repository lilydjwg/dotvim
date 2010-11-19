if exists('loaded_floatingwindow') || &cp
    finish
endif
let loaded_floatingwindow='yes'	
let enable_floatingwindow=1
let s:count=0

if !exists('g:floatingwindows')
	let g:floatingwindows="'__Todo_List__',1,24,1;'.vimproject',1,24,1;'.prj',1,24,1;"
endif
function! s:AddFloatingWindow(title,ver,max,min)
	let s:title_{s:count}=a:title
	let s:vertical_{s:count}=a:ver
	let s:max_{s:count}=a:max
	let s:min_{s:count}=a:min
	let s:count=s:count+1
endf
function! s:GetWindowIndex(title)
	let l:index=0
	while l:index < s:count
		if matchend(a:title,s:title_{l:index})!= "-1"
			"call confirm(s:title_{l:index}.a:title.matchend(s:title_{l:index},a:title))
		"if s:title_{l:index}==a:title
			return l:index
		endif
		let l:index=l:index+1
	endwhile
	return -1
endf
function! s:MaxmizedWindow(index)
	if s:vertical_{a:index}==1
		exec 'vertical resize '.s:max_{a:index}
            else
		exec 'resize '.s:max_{a:index}
	endif
endf
function! s:MinimizedWindow(index)
	if s:vertical_{a:index}==1
		exec 'vertical resize '.s:min_{a:index}
            else
		exec 'resize '.s:min_{a:index}
	endif
endf
function! s:OnBufferEnter()
    if !g:enable_floatingwindow 
        return
    endif
    let l:title = expand('%:t')
    let l:index = s:GetWindowIndex(l:title)
    if l:index != -1
	    call s:MaxmizedWindow(l:index)
    endif
endfunction

function! s:OnBufferLeave()
    if !g:enable_floatingwindow 
        return
    endif
    let l:title = expand('%:t')
    let l:index = s:GetWindowIndex(l:title)
    if l:index != -1
	    call s:MinimizedWindow(l:index)
    endif
endfunction

function! s:AddFloatingWindows()
	if v:version>=700
		for item in split(g:floatingwindows,';')
			if strlen(item)==0 | continue | endif
			exec "call s:AddFloatingWindow(".item.")"
		endfor
	else
		call s:AddFloatingWindow('.prj',1,24,1)
		call s:AddFloatingWindow('__Todo_List__',1,24,1)
	endif
endf
function! s:AddAutoCommands()
	autocmd BufEnter * silent call s:OnBufferEnter()
	"autocmd WinEnter * silent call s:OnBufferEnter()
	autocmd WinLeave * silent call s:OnBufferLeave()
endfunction
function! s:FloatWindow_Toggle()
    if g:enable_floatingwindow 
        let g:enable_floatingwindow=0
    else
        let g:enable_floatingwindow=1
    end
endfunction
call s:AddAutoCommands()
call s:AddFloatingWindows()
command! -nargs=0 FWToggle call s:FloatWindow_Toggle()
" vim: ff=unix
