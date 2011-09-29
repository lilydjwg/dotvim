" Vim file type plug-in
" Language: Lua 5.1
" Author: Peter Odding <peter@peterodding.com>
" Last Change: August 27, 2011
" URL: http://peterodding.com/code/vim/lua-ftplugin

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3625 1 :AutoInstall: lua.zip

" Don't source the plug-in when it's already been loaded or &compatible is set.
if &cp || exists('g:loaded_lua_ftplugin')
  finish
endif

" Commands to manually check for syntax errors and undefined globals.
command! -bar LuaCheckSyntax call xolox#lua#checksyntax()
command! -bar -bang LuaCheckGlobals call xolox#lua#checkglobals(<q-bang> == '!')

" Automatic commands to check for syntax errors and/or undefined globals
" and change Vim's "completeopt" setting on the fly for Lua buffers.
augroup PluginFileTypeLua
  autocmd!
  autocmd WinEnter * call xolox#lua#tweakoptions()
  autocmd BufWritePost * call xolox#lua#autocheck()
augroup END

" Make sure the plug-in is only loaded once.
let g:loaded_lua_ftplugin = 1

" vim: ts=2 sw=2 et
