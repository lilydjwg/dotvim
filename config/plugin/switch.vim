vim9script

def Lilydjwg_tryswitch(reverse: bool, visual: bool, count: number): void
  var ok = switch#Switch({'reverse': reverse})
  if !ok
    if visual
      if reverse
        exe "normal! gv" .. count .. "\<C-X>"
      else
        exe "normal! gv" .. count .. "\<C-A>"
      endif
    else
      if reverse
        exe "normal! " .. count .. "\<C-X>"
      else
        exe "normal! " .. count .. "\<C-A>"
      endif
    endif
  endif
enddef

nnoremap <silent> <C-X> <ScriptCmd>Lilydjwg_tryswitch(v:true, v:false, v:count1)<CR>
vnoremap <silent> <C-X> <ScriptCmd>Lilydjwg_tryswitch(v:true, v:true, v:count1)<CR>
nnoremap <silent> <C-A> <ScriptCmd>Lilydjwg_tryswitch(v:false, v:false, v:count1)<CR>
vnoremap <silent> <C-A> <ScriptCmd>Lilydjwg_tryswitch(v:false, v:true, v:count1)<CR>

# disable default mapping (gs)
g:switch_mapping = ''

g:switch_custom_definitions = [
  ['insert', 'delete']
]
