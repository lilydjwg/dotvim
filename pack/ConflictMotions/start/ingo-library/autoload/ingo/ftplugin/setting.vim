" ingo/ftplugin/setting.vim: Functions for filetype plugin settings in a buffer-local Dict.
"
" DEPENDENCIES:
"
" Copyright: (C) 2018 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:GetOption( variableName )
    return 'b:' . a:variableName
endfunction

function! ingo#ftplugin#setting#Get( variableName, key, default )
    let l:option = s:GetOption(a:variableName)
    if ! exists(l:option)
	return a:default
    endif
    execute 'return get(' . l:option . ', a:key, a:default)'
endfunction

function! ingo#ftplugin#setting#Set( variableName, key, value )
    let l:option = s:GetOption(a:variableName)
    if ! exists(l:option)
	execute 'let' l:option '= {}'
    endif

    execute 'let' l:option . '[a:key] = a:value'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
