" ingo/buffer/scratch/converted.vim: Functions for editing a converted buffer in a scratch duplicate.
"
" DEPENDENCIES:
"
" Copyright: (C) 2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#buffer#scratch#converted#Create( startLnum, endLnum, scratchFilename, ForwardConverter, BackwardConverter, windowOpenCommand, ... ) abort
"******************************************************************************
"* PURPOSE:
"   Convert the current buffer via a:ForwardConverter into a scratch buffer
"   named a:scratchFilename that can be toggled back (via a:BackwardConverter)
"   and forth; writes update the original buffer.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   - Creates or opens scratch buffer and loads it in a window (as specified by
"     a:windowOpenCommand) and activates that window.
"   - Sets up autocmd, buffer-local mappings and commands.
"* INPUTS:
"   a:startLnum     First line number in the current buffer to be edited.
"   a:endLnum       Last line number in the current buffer to be edited.
"   a:scratchFilename	The name for the scratch buffer.
"   a:ForwardConverter  Ex command or Funcref that converts the buffer contents.
"			To support updates to arbitrary ranges in the original
"			buffer, the conversion should be applied to :'[,'], the
"			changed area, and keep / adapt those marks.
"   a:BackwardConverter Ex command or Funcref that converts the buffer contents
"                       back to the original contents.
"   a:windowOpenCommand	Ex command to open the scratch window, e.g. :vnew or
"			:topleft new.
"   a:option.NextFilenameFuncref
"			    Funcref that is invoked (with a:filename) to
"			    generate file names for the generated buffer should
"			    the desired one (a:filename) already exist but not
"			    be a generated buffer.
"   a:option.toggleCommand  Name of a buffer-local command to toggle the scratch
"                           contents between original and converted formats.
"                           Defaults to :Toggle. No command is defined when an
"                           empty String is passed.
"   a:option.toggleMapping  Name of a buffer-local mapping to toggle the scratch
"                           contents between original and converted formats.
"                           Defaults to <LocalLeader><LocalLeader>. No mapping
"                           is defined when an empty String is passed.
"   a:option.quitMapping    Name of a buffer-local mapping to exit the scratch
"                           buffer. Defaults to q.
"   a:option.isShowDiff     Flag whether the scratch buffer is diffed with the
"                           original buffer when it is toggled back. By default
"                           is turned on if the entire buffer is being edited.
"   a:option.isAllowUpdate  Flag whether :write can be used to update the
"                           original buffer. Default true.
"   Note: To handle errors caused by the initial conversion via
"   a:ForwardConverter, you need to put this method call into a try..catch block
"   and :bwipe the buffer when an exception is thrown.
"* RETURN VALUES:
"   Indicator whether the scratch buffer has been opened:
"   0	Failed to open scratch buffer.
"   1	Already in scratch buffer window.
"   2	Jumped to open scratch buffer window.
"   3	Loaded existing scratch buffer in new window.
"   4	Created scratch buffer in new window.
"******************************************************************************
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]
    let l:isEntireBuffer = ingo#range#IsEntireBuffer(l:startLnum, l:endLnum)

    let l:options = (a:0 ? a:1 : {})
    let l:NextFilenameFuncref = get(l:options, 'NextFilenameFuncref', '')
    let l:toggleCommand = get(l:options, 'toggleCommand', 'Toggle')
    let l:toggleMapping = get(l:options, 'toggleMapping', '<LocalLeader><LocalLeader>')
    let l:quitMapping = get(l:options, 'quitMapping', 'q')
    let l:isAllowUpdate = get(l:options, 'isAllowUpdate', 1)

    let l:record = {
    \   'isConverted': 1,
    \   'ForwardConverter': a:ForwardConverter,
    \   'BackwardConverter': a:BackwardConverter,
    \   'isShowDiff': get(l:options, 'isShowDiff', l:isEntireBuffer),
    \   'originalDiff': &l:diff,
    \   'originalBufNr': bufnr(''),
    \   'originalBuffer': ingo#window#switches#WinSaveCurrentBuffer(1),
    \}
    let g:ingo#buffer#scratch#converted#CreationContext = {
    \   'lines': getline(l:startLnum, l:endLnum),
    \   'Converter': a:ForwardConverter,
    \}
    if l:isAllowUpdate && ! l:isEntireBuffer
	" Use marks to keep track of the changed area in the original buffer, so
	" that other edits (which clobber the change marks) can be made in
	" parallel.
	let l:reservedMarksRecord = ingo#plugin#marks#Reserve(2)
	let l:reservedMarks = keys(l:reservedMarksRecord)
	call setpos("'" . l:reservedMarks[0], [0, l:startLnum, 1, 0])
	call setpos("'" . l:reservedMarks[1], [0, l:endLnum, 1, 0])
    endif

    if l:record.isShowDiff
	diffthis
    endif

    let l:status = call('ingo#buffer#scratch#CreateWithWriter',
    \   [a:scratchFilename,
    \   (l:isAllowUpdate ? function('ingo#buffer#scratch#converted#Writer') : ''),
    \   function('ingo#buffer#scratch#converted#Creator'),
    \   a:windowOpenCommand] +
    \   (empty(l:NextFilenameFuncref) ? [] : [l:NextFilenameFuncref])
    \)
    if l:status == 0
	let &l:diff = l:record.originalDiff    " The other participant isn't there, so undo enabling of diff mode.
	return l:status
    endif

    " We're in the scratch buffer now.
    if exists('l:reservedMarksRecord')
	" Unreserve the reserved marks. As these are local marks in the original
	" buffer, we do this when we enter it after the scratch buffer got
	" deleted.
	augroup IngoLibraryScratchConverter
	    execute printf('autocmd! BufEnter <buffer=%d> if ! bufexists(%d) | call ingo#plugin#marks#Unreserve(%s) | execute "autocmd! IngoLibraryScratchConverter * <buffer>" | endif',
	    \   l:record.originalBufNr,
	    \   bufnr(''),
	    \   string(l:reservedMarksRecord)
	    \)
	augroup END
    endif

    if ! empty(l:toggleCommand)
	execute printf('command! -buffer -bar %s if ! ingo#buffer#scratch#converted#Toggle() | echoerr ingo#err#Get() | endif', l:toggleCommand)
    endif
    if ! empty(l:toggleMapping)
	execute printf('nnoremap <buffer> <silent> %s :<C-u>if ! ingo#buffer#scratch#converted#Toggle()<Bar>echoerr ingo#err#Get()<Bar>endif<CR>', l:toggleMapping)
    endif
    if ! empty(l:quitMapping)
	if l:record.isShowDiff
	    " Restore the original buffer's diff mode.
	    execute printf('nnoremap <buffer> <silent> <nowait> %s :<C-u>let g:ingo#buffer#scratch#converted#record = b:IngoLibrary_scratch_converted_record<Bar>bwipe<Bar>call setbufvar(g:ingo#buffer#scratch#converted#record.originalBufNr, "&diff", g:ingo#buffer#scratch#converted#record.originalDiff)<Bar>unlet g:ingo#buffer#scratch#converted#record<CR>', l:quitMapping)
	else
	    execute printf('nnoremap <buffer> <silent> <nowait> %s :<C-u>bwipe<CR>', l:quitMapping)
	endif
    endif

    let b:IngoLibrary_scratch_converted_record = l:record
    if exists('l:reservedMarksRecord')
	let b:IngoLibrary_scratch_converted_record.reservedMarks = l:reservedMarks
    endif

    return l:status
endfunction
function! s:ConvertEntireBuffer( Converter ) abort
    call ingo#change#Set([1, 1], [line('$'), 1])
    call ingo#actions#ExecuteOrFunc(a:Converter)
endfunction
function! ingo#buffer#scratch#converted#Creator() abort
    call setline(1, g:ingo#buffer#scratch#converted#CreationContext.lines)
    call s:ConvertEntireBuffer(g:ingo#buffer#scratch#converted#CreationContext.Converter)
    unlet g:ingo#buffer#scratch#converted#CreationContext
endfunction
function! ingo#buffer#scratch#converted#Toggle() abort
    let l:isConverted = b:IngoLibrary_scratch_converted_record.isConverted
    let l:Converter = get(b:IngoLibrary_scratch_converted_record, l:isConverted ? 'BackwardConverter' : 'ForwardConverter')
    let l:save_modified = &l:modified
    try
	call s:ConvertEntireBuffer(l:Converter)
	let &l:modified = l:save_modified
	let b:IngoLibrary_scratch_converted_record.isConverted = ! l:isConverted

	if b:IngoLibrary_scratch_converted_record.isShowDiff
	    if l:isConverted
		diffthis
	    else
		diffoff
	    endif
	endif

	return 1
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    endtry
endfunction
function! ingo#buffer#scratch#converted#Writer() abort
    let l:record = b:IngoLibrary_scratch_converted_record  " Need to save this here as we're switching buffers.
    let l:lines = getline(1, '$')   " Always write back the entire scratch buffer contents.

    let l:scratchTabNr = tabpagenr()
    let l:previousWinNr = winnr('#') ? winnr('#') : 1
    let l:scratchWinNr = winnr()
    try
	call ingo#window#switches#WinRestoreCurrentBuffer(l:record.originalBuffer, 1)
    catch /^WinRestoreCurrentBuffer:/
	try
	    execute l:record.originalBufNr . 'sbuffer'
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#err#SetVimException()
	    return 0
	endtry
    endtry

    let l:success = 1
    let [l:startLnum, l:endLnum] = (has_key(l:record, 'reservedMarks') ?
    \   [line("'" . l:record.reservedMarks[0]), line("'" . l:record.reservedMarks[1])] :
    \   [1, line('$')]
    \)
    let l:save_lines = getline(l:startLnum, l:endLnum)
    call ingo#lines#Replace(l:startLnum, l:endLnum, l:lines)
    if l:record.isConverted
	" Need to convert back.
	try
	    call ingo#actions#ExecuteOrFunc(l:record.BackwardConverter)

	    if has_key(l:record, 'reservedMarks')
		" The marks need to be redone after the change.
		call setpos("'" . l:record.reservedMarks[0], getpos("'["))
		call setpos("'" . l:record.reservedMarks[1], getpos("']"))
	    endif
	catch /^Vim\%((\a\+)\)\=:/
	    let l:success = 0
	    call ingo#err#SetVimException()

	    " Restore the original buffer contents.
	    call ingo#lines#Replace(l:startLnum, l:endLnum, l:save_lines)

	    " Don't return yet, we still need to go back to the scratch buffer.
	endtry
    endif

    " Go back to the scratch buffer.
    if tabpagenr() != l:scratchTabNr
	execute l:scratchTabNr . 'tabnext'
    endif
    execute l:previousWinNr . 'wincmd w'
    execute l:scratchWinNr . 'wincmd w'

    setlocal nomodified " Contents have been persisted.
    return l:success
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
