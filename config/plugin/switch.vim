vim9script

def Lilydjwg_tryswitch(reverse: bool, visual: bool): void
  var ok = switch#Switch({'reverse': reverse})
  if !ok
    if visual
      if reverse
        exe "normal! gv\<C-X>"
      else
        exe "normal! gv\<C-A>"
      endif
    else
      if reverse
        exe "normal! \<C-X>"
      else
        exe "normal! \<C-A>"
      endif
    endif
  endif
enddef

nnoremap <silent> <C-X> <ScriptCmd>Lilydjwg_tryswitch(v:true, v:false)<CR>
vnoremap <silent> <C-X> <ScriptCmd>Lilydjwg_tryswitch(v:true, v:true)<CR>
nnoremap <silent> <C-A> <ScriptCmd>Lilydjwg_tryswitch(v:false, v:false)<CR>
vnoremap <silent> <C-A> <ScriptCmd>Lilydjwg_tryswitch(v:false, v:true)<CR>

# disable default mapping (gs)
g:switch_mapping = ''

g:switch_custom_definitions = [
  ['insert', 'delete']
]
