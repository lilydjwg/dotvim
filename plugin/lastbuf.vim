"=============================================================
"  Script: LastBuf
"    File: plugin/lastbuf.vim
" Summary: open last closed buffers.
"  Author: Rykka <Rykka10(at)gmail.com>
" Last Update: 2012-04-03
"=============================================================

let s:save_cpo = &cpo
set cpo&vim
" this option decides the max reopen buf number.
let g:lastbuf_num= exists("g:lastbuf_num") ? g:lastbuf_num : 20
" this option decides to reopen which level of hided buffer.
" :hid   bufhidden  (will always be reopened)
" :bun   bufunload  (will be reopened if level >= 1)
" :bd    bufdelete  (will be reopened if level >= 2)
" :bw    bufwipeout (will never be reopened!CAUTION!!)
" default is 1 , means :bd and :bw not be reopened.
" if you want the same effect of 'nohidden'. 
" set it to 0 and  set 'nohidden'
let g:lastbuf_level= exists("g:lastbuf_level") ? g:lastbuf_level : 1

let s:bufList=[]
" 'tab':tab '':split 'vert':vertical
let s:w = ''
function! s:setLastBuf() "{{{
    if tabpagenr() > 1 && len(tabpagebuflist()) == 1
        let s:w = 'tab'
    else
        let s:w = ''
    endif
endfunction "}}}
function! s:addLastBuf() "{{{
    let b = expand('<abuf>') 
    if b > 0
        call insert(s:bufList,[b,s:w])
    endif
endfunction "}}}
function! s:chkLastBuf(e) "{{{
    if ( a:e=="unload" && g:lastbuf_level == 0 ) 
      \ || ( a:e=="delete" && g:lastbuf_level == 1 )
      \ || ( a:e=="wipeout" && g:lastbuf_level >= 2 )
        let b=expand('<abuf>') 
        if b > 0 && len(s:bufList)!=0 && s:bufList[0][0] == b
            call remove(s:bufList,0)
        endif
    endif
endfunction "}}}
function! s:openLastBuf() "{{{
    if len(s:bufList) != 0
        " reopen the tab
        let [b,w] = remove(s:bufList,0)
        exec w." sb ".b
        
        " remove long list last items
        if len(s:bufList) > g:lastbuf_num+10
            call remove(s:bufList,g:lastbuf_num,-1)
        endif
    endif
endfunction "}}} 
command! -nargs=0  LastBuf call <SID>openLastBuf()
aug lastbuf#LastBuf "{{{
    au! 
    " BufWinLeave is triggered after the window is closed. 
    " so use BufLeave to get the closing window info.
    au BufLeave     *   call s:setLastBuf()
    au BufWinLeave  *   call s:addLastBuf()

    " au BufHidden    *   call s:chkLastBuf("hidden")
    au BufUnload    *   call s:chkLastBuf("unload")
    au BufDelete    *   call s:chkLastBuf("delete")
    au BufWipeout   *   call s:chkLastBuf("wipeout")
aug END "}}}
if !hasmapto(':LastBuf<CR>') "{{{
  silent! nmap <unique> <silent> <c-w>z :LastBuf<CR>
  silent! nmap <unique> <silent> <c-w><c-z> :LastBuf<cr>
endif "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim:tw=78:fdm=marker:
