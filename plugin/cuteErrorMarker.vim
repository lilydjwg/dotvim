"=============================================================================
" What Is This: Display marks at lines with compilation error.
" File: cuteErrorMarker.vim
" Author: Vincent Berthoux <twinside@gmail.com>
" Last Change: 2010 oct 12
" Version: 1.5
" Thanks:
" Require:
"   set nocompatible
"     somewhere on your .vimrc
"
" Usage:
"      :MarkErrors
"        Place markers near line from the error list
"
"      :CleanupMarkErrors
"        Remove all the markers
"
"      :RemoveErrorMarkersHook
"        Remove the autocommand for sign placing
"
"      :make
"        Place marker automatically by default
"
"      :grep
"        Place search marke automatically by default
"
" Additional:
"     * if you don't want the automatic placing of markers
"       after a make, you can define :
"       let g:cuteerrors_no_autoload = 1
"     * If you don't want the balloon to display error text,
"       define :
"       let g:cuteerrors_no_baloons = 1
"
" ChangeLog:
"     * 1.5  :- Added marks for grep search
"     * 1.4.4:- Changed sign highlighting
"     * 1.4.3:- Changing 'sign' verification mode
"     * 1.4.2:- Avoid loading script if :signs command is not available.
"     * 1.4.1:- No checking that the balloon option is present
"     * 1.4  :- Added ballon to display error messages when overing
"               an error line.
"     * 1.3.2:- Changed loading of files using globpath()
"     * 1.3.1:- Changed data retrievel function to getqflist().
"     * 1.3  :- Taking into account "Documents and Settings" folder...
"             - Adding icons source from $VIM or $VIMRUNTIME
"             - Checking the nocompatible option (the only one required)
"     * 1.2  :- Fixed problems with subdirectory
"             - Warning detection is now case insensitive
"     * 1.1  :- Bug fix when make returned only an error
"             - reduced flickering by avoiding redraw when not needed.
"     * 1.0  : Original version
"
" Thanks:
"       - Ingo Karkat - Suggestion of signs check enhancement
"       - A. S. Budden for the globpath function
"       - Benoît Pierre for pointing the function getqflist() and
"         providing a patch.
"       - Yazilim Duzenleci for stressing the plugin and forcing
"         me to make it more general.
"
if exists("g:__CUTEERRORMARKER_VIM__")
    finish
endif
let g:__CUTEERRORMARKER_VIM__ = 1

"======================================================================
"           Configuration checking
"======================================================================
" Check that vim is not set in compatible mode
if &compatible
    echom 'Cute Error Marker require the nocompatible option, loading aborted'
    echom "To fix it add 'set nocompatible' in your .vimrc file"
    finish
endif

" Verify that signs are available with the vim version.
" If not avoid loading the extension
if !has("signs")
    echom 'Cute Error Marker require signs to be compiled within vim'
    echom 'Please compile vim with +signs . plugin not loaded.'
    finish
endif

if has("win32")
    let s:ext = '.ico'
elseif has("gui_mac")
    let s:ext = '.xpm'
else
    let s:ext = '.png'
endif

let s:path = globpath( &rtp, 'signs/err' . s:ext )
if s:path == ''
    echom "Cute Error Marker can't find icons, plugin not loaded" 
    finish
endif

"======================================================================
"           Plugin data
"======================================================================
let s:signId = 33000
let s:signCount = 0

fun! s:RefreshErrorHighlight() "{{{
    hi CuteErrorMarkerErrorColor term=bold ctermfg=white ctermbg=red guifg=white guibg=red
    hi CuteErrorMarkerWarningColor term=bold ctermfg=black ctermbg=yellow guifg=black guibg=yellow
    hi CuteErrorMarkerInfoColor term=bold ctermfg=White ctermbg=blue guifg=white guibg=blue
endfunction "}}}

" We call it here to be sure of it's existence.
call s:RefreshErrorHighlight()

exec 'sign define errhere texthl=CuteErrorMarkerErrorColor text=[X icon=' . escape( globpath( &rtp, 'signs/err' . s:ext ), ' \' )
exec 'sign define warnhere texthl=CuteErrorMarkerWarningColor  text=/! icon=' . escape( globpath( &rtp, 'signs/warn' . s:ext ), ' \' )
exec 'sign define infohere texthl=CuteErrorMarkerInfoColor text=(? icon=' . escape( globpath( &rtp, 'signs/info' . s:ext ), ' \' )

fun! PlaceErrorMarkersHook() "{{{
    augroup cuteerrors
        " au !
        au QuickFixCmdPre *make call CleanupMarkErrors()
        au QuickFixCmdPost *make call MarkErrors('err')
        au QuickFixCmdPre *grep* call CleanupMarkErrors()
        au QuickFixCmdPost *grep* call MarkErrors('search')
    augroup END
endfunction "}}}

fun! RemoveErrorMarkersHook() "{{{
    augroup cuteerrors
        au!
    augroup END
endfunction "}}}

fun! s:SelectClass( kind, error ) "{{{
	if a:kind == 'search'
		return 'infohere'
    endif

    if a:error =~ '\cwarning'
        return 'warnhere'
    else
        return 'errhere'
    endif
endfunction "}}}

" List used to keep error text to display it on the good
" line. Assumed type :
" s:errBallons :: [ (BufNumber, LinNumber, text) ]
let s:errBalloons = []

fun! MarkErrors( kind ) "{{{
    call s:RefreshErrorHighlight()

    let errList = getqflist()
    let s:errBalloons = []

    for error in errList
        if error.valid
            let matchedBuf = error.bufnr

            if matchedBuf >= 0
                let s:signCount = s:signCount + 1
                let id = s:signId + s:signCount
                let errClass = s:SelectClass( a:kind, error.text )

                call add( s:errBalloons, [error.bufnr, error.lnum, error.text] )
                let toPlace = 'sign place ' . id
                            \ . ' line=' . error.lnum
                            \ . ' name=' . errClass
                            \ . ' buffer=' . matchedBuf
                exec toPlace
            endif
        endif
    endfor

    " If we have placed some markers
    if s:signCount > 0
        redraw!
    endif
endfunction "}}}

fun! CleanupMarkErrors() "{{{
    let i = s:signId + s:signCount

    let s:errBalloons = []
    " this if is here to avoid redraw if un-needed
    if i > s:signId
        while i > s:signId
            let toRun = "sign unplace " . i
            exec toRun
            let i = i - 1
        endwhile

        let s:signCount = 0
        redraw!
    endif
endfunction "}}}

fun! CuteErrorBalloon() "{{{
    for [bufNumber, lineNumber, txt] in s:errBalloons
        if v:beval_bufnr == bufNumber && v:beval_lnum == lineNumber
            return txt
        endif
    endfor
    return ''
endfunction "}}}

if !exists("g:cuteerrors_no_autoload")
    call PlaceErrorMarkersHook()
endif

if exists("+ballooneval") && !exists("g:cuteerrors_no_baloons")
    set ballooneval
    set balloonexpr=CuteErrorBalloon()
endif

command! MarkErrors call MarkErrors('err')
command! CleanupMarkErrors call CleanupMarkErrors()

