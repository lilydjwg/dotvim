" ingo/text/surroundings/Lines/Creator.vim: Create custom commands and mappings to surround whole lines with something.
"
" DEPENDENCIES:
"   - repeatableMapping.vim plugin (optional)
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

":{range}Command	Insert ??? around {range}.
":Command		Insert ??? around the last changed text.
":Command {cmd}		Execute {cmd} (e.g. :read) and insert ???
"			around the changed text.
function! ingo#text#surroundings#Lines#Creator#MakeCommand( commandArgs, commandName, beforeLines, afterLines, ... )
    let l:options = (a:0 ? a:1 : {})
    " Note: No -bar; can take a sequence of Vim commands.
    execute printf('command! %s -range=-1 -nargs=* -complete=command %s call setline(<line1>, getline(<line1>)) |' .
    \	'if ! ingo#text#surroundings#Lines#SurroundCommand(%s, %s, %s, <count>, <line1>, <line2>, <q-args>) | echoerr ingo#err#Get() | endif',
    \   a:commandArgs, a:commandName,
    \	string(a:beforeLines), string(a:afterLines), string(l:options)
    \)
endfunction

" [count]<Leader>??	Insert ??? around [count] lines.
" [count]<Leader>?{motion}
"			Insert ??? around lines covered by {motion}.
" {Visual}<Leader>?	Insert ??? around the selection.
function! ingo#text#surroundings#Lines#Creator#MakeMapping( mapArgs, keys, commandName, mapName )
    let l:doubledKey = matchstr(a:keys, '\(<[[:alpha:]-]\+>\|.\)$')
    let l:lineMappingKeys = a:keys . l:doubledKey

    " Because of a:commandName defaulting to the last changed text, we have to
    " insert the "." range when no [count] is given.
    " Because an a:commandName that is defined through
    " ingo#text#surroundings#Lines#Creator#MakeCommand() does not support
    " command sequencing with <Bar>, we must enclose the entire command with
    " :execute (but keep the range directly before the command, so that it is
    " invoked only once) to make the transformation through repeatableMapping
    " work. (Otherwise, the appended <Bar>silent! call repeat#set() would be
    " interpreted as a command argument to a:commandName, and the wrong range
    " would be used).
    execute printf('nnoremap %s %s :<Home>execute ''<End><C-r><C-r>=v:count ? "" : "."<CR>%s''<CR>',
    \   a:mapArgs, l:lineMappingKeys, substitute(a:commandName, "'", "''", 'g')
    \)
    execute printf('xnoremap %s %s :<Home>execute "<End>" . ''%s''<CR>',
    \   a:mapArgs, a:keys, substitute(a:commandName, "'", "''", 'g')
    \)

    silent! call repeatableMapping#makeCrossRepeatable(
    \   'nnoremap ' . a:mapArgs, l:lineMappingKeys, a:mapName . 'Line',
    \   'xnoremap ' . a:mapArgs, a:keys,            a:mapName . 'Selection'
    \)
    call ingo#mapmaker#OperatorMappingForRangeCommand(a:mapArgs, a:keys, a:commandName)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
