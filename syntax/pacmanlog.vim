" Vim syntax file
" FileType:     pacman.log
" Author:       lilydjwg <lilydjwg@gmail.com>

syntax clear
syntax case ignore

syn match pacmanlogTime		/\v^\[[^]]+\]/
syn match pacmanlogInstall	/\v(\]\s)@<=installed\s\S+/
syn match pacmanlogUpgrade	/\v(\]\s)@<=upgraded\s\S+/
syn match pacmanlogRemove	/\v(\]\s)@<=removed\s\S+/
syn match pacmanlogError	/\v(\]\s)@<=ERROR:.*$/
syn match pacmanlogWarning	/\v(\]\s)@<=WARNING:.*$/

hi link pacmanlogTime		Constant
hi link pacmanlogInstall	Type
hi link pacmanlogUpgrade	PreProc
hi link pacmanlogRemove		Statement
hi link pacmanlogError		ErrorMsg
hi link pacmanlogWarning	WarningMsg

let b:current_syntax = "pacmanlog"
