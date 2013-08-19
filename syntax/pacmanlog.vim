" Vim syntax file
" FileType:     pacman.log
" Author:       lilydjwg <lilydjwg@gmail.com>
" Version:      1.2

syntax clear
syntax case ignore

syn match pacmanlogTime		/\v^\[[^]]+\]/
syn match pacmanlogInstall	/\v(\]\s)@<=%(re)?installed\s\S+/
syn match pacmanlogUpgrade	/\v(\]\s)@<=upgraded\s\S+/
syn match pacmanlogDowngrade	/\v(\]\s)@<=downgraded\s\S+/
syn match pacmanlogRemove	/\v(\]\s)@<=removed\s\S+/
syn match pacmanlogError	/\v(\]\s)@<=ERROR:.*$/
syn match pacmanlogWarning	/\v(\]\s)@<=WARNING:.*$/
syn match pacmanlogProg 	/\v(\]\s)@<=\[[^]]+\]/

hi link pacmanlogTime		Constant
hi link pacmanlogInstall	Type
hi link pacmanlogUpgrade	PreProc
hi link pacmanlogDowngrade	Tag
hi link pacmanlogRemove		Statement
hi link pacmanlogError		ErrorMsg
hi link pacmanlogWarning	WarningMsg
hi link pacmanlogProg           Comment

let b:current_syntax = "pacmanlog"
