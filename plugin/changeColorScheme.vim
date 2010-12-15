"------------------------------------------------------------------------------
" File: changeColorScheme.vim 
" vimscript #870
" URL on VIM: http://www.vim.org/scripts/script.php?script_id=870
"------------------------------------------------------------------------------
" Got ideas from following tips and scripts 
" vimtip #341, vimtip #358, vimscript #668, vimscript #109 
"------------------------------------------------------------------------------
" Author: Hosup Chung <hosup.chung@gmail.com>
"
" Created: 2003 December 31
" Last Updated: 2010 July 23
"
" Version: 0.4
" 0.4: added RemoveCurrentColorScheme() function (requested by auto didakto)
" 
" 0.3: updated code to handle file not found error due to color schemes 
" 	were removed
"
" 0.2: updated RandomColorScheme()
"
" 0.12: I finally tested this plugin on OS X and Linux
"       When searching color schemes, substituting eol didn't work on Linux.
"       I'm using "\n" instead of '\n' now, and it seems working.
"
" 0.11: fixed some typo in Usage description 
"
" 0.1:  initial upload 
"------------------------------------------------------------------------------
" Install:
" Copy this script in your plugin directory
"------------------------------------------------------------------------------
" Usage:
" When this script is loaded, it will populate an array with each of color 
" scheme's file path.  You can then load different color schemes using 
" NextColorScheme(), PreviousColorScheme() or RandomColorScheme(). 
"
" Or if you don't like current color scheme you can call
" RemoveCurrentColorScheme() to remove the file.
"
" There are 4 main functions 
"   1. You can either call them directly
"      :call NextColorScheme()
"      :call PreviousColorScheme() 
"      :call RandomColorScheme()
"      :call RemoveCurrentColorScheme()
"
"   2. You can map and save them in your [._]gvimrc.
"      map <F4>   :call NextColorScheme()<CR>
"      map <S-F4> :call PreviousColorScheme()<CR>
"      map <C-F4> :call RandomColorScheme()<CR>
"      map <F3>   :call RemoveCurrentColorScheme()<CR>
"
"   3. You can also start each vim session with random color scheme by 
"      adding following line in your [._]gvimrc
"      call RandomColorScheme()
"
"------------------------------------------------------------------------------
" Tip: 
" You can change your rulerformat in your [._]vimrc to display the name of 
" current color scheme on status line.
"
" First, add this line to display status information 
"     set ruler 
"
" And add %{g:colors_name} in rulerformat to display name of current color 
"  scheme. For example,
"     set rulerformat=%55(:%{g:colors_name}:\ %5l,%-6(%c%V%)\ %P%) 
"
" However, you will see an error message if you didn't load color scheme at
" startup. So you might want to add %{GetColorSyntaxName()} instead.
"     set rulerformat=%55(:%{GetColorSyntaxName()}:\ %5l,%-6(%c%V%)\ %P%) 
"
" GetColorSyntaxName() function is included in this script. It returns
" the value of g:colors_name if it exists, otherwise an empty string. If you
" are using a console version, then you might have to copy
" GetColorSyntaxName() into .vimrc, because I think the plugin files get
" loaded after evaluating .vimrc.
"------------------------------------------------------------------------------

if exists("g:change_color_scheme")
	finish
endif

let g:change_color_scheme="0.3"

if 1
	let s:save_cpo = &cpoptions
endif
set cpo&vim

" You can pick any sep character that will mark between array elements.
" However, because each array element is a file path, it would be better 
" to pick an invalid file character.
let s:sep='?'

" Just in case when some of color scheme files are removed, I need to keep track
" of which direction the user was moving in color scheme array. 
let s:direction='NEXT'

" I got an idea from lightWeightArray.vim, and came up ElementAt.
" array is actually a string. Each element in the array is separated by sep
" character. 
" The function will returns the array_index element or -1 for not found
function! ElementAt (array, sep, array_index)
	" if array is empty or array_index is negative then return -1
	if strlen(a:array) == 0 || a:array_index < 0
		return -1
	endif

	let char_pos = 0 	" current character position within array
	let i = 0		" current array index position

	" Search the array element on a:array_index position.
	while i != a:array_index 
		let char_pos = match(a:array, a:sep, char_pos)
		if char_pos == -1
			return -1	" couldn't find it
		endif

		let char_pos = char_pos + 1
		let i = i + 1
	endwhile
 
	" then find where the current array element ends 
	let array_element_endpos = match(a:array, a:sep, char_pos)
	if array_element_endpos == -1
		" must be the last array element
		let array_element_endpos = strlen(a:array) 
	endif

	let color_scheme_path = strpart(a:array,char_pos,(array_element_endpos-char_pos))

	" if path is not found, probably some of color scheme files are
	" removed. Reinitialize the array and call ElementAt again.
	if filereadable(color_scheme_path) == 0
		call InitializeVariables()

		if ((a:array_index == 0 || a:array_index >= s:total_schemes-1) && s:direction == 'NEXT')
			let s:scheme_index = 0
		else
			let s:scheme_index = s:total_schemes-1
		endif
		return ElementAt(s:color_schemes, s:sep, s:scheme_index)
	endif

	" return the color scheme file path in a:array_index position
	return color_scheme_path
endfunction  " ElementAt

" If g:colors_name is defined, return the name of current color syntax name.
" Otherwise return an empty string
function! GetColorSyntaxName()
	if exists('g:colors_name')
		return g:colors_name
	else
		return ''
	endif	
endfunction  "GetColorSyntaxName

function! InitializeVariables()
	" get all color scheme file path and save it to s:color_schemes. It will be 
	" treated as a string array which elements are separated by sep character. 
	let s:color_schemes = substitute(globpath(&runtimepath,"colors/*.vim"), "\n", s:sep, 'g')
	let s:total_schemes = 0
	let s:scheme_index = 0

	if (strlen(s:color_schemes) > 0)
		" determine the total number of color schemes by counting sep 
		" character from color_schemes string. Unless there's no color 
		" scheme, total number of color scheme is 1 bigger than number 
		" of sep characters
		let found = 0
		while found != -1
			let found = match(s:color_schemes, s:sep, found+1)
			let s:total_schemes = s:total_schemes + 1
		endwhile
	endif
endfunction

" load next color schemes.
function! NextColorScheme()
	let s:scheme_index = s:scheme_index + 1
	let s:direction = 'NEXT'
	call LoadColorScheme()
endfunction

" load previous color schemes.
function! PreviousColorScheme()
	let s:scheme_index = s:scheme_index - 1
	let s:direction = 'PREVIOUS'
	call LoadColorScheme()
endfunction

" load randomly chosen color scheme.
" vim still doesn't have a function that returns millisecons. As a result,
" it's difficult to generate a random number sequence. My previous attempt was 
" to use just localtime(). But since it only returns seconds, quickly calling 
" series of RandomColorScheme() is just same as NextColorScheme() except the 
" first call. Now I found another function getfsize(), which returns the file 
" size. I think adding localtime() and current color scheme's filesize seems 
" random enough for this script.
function! RandomColorScheme()
	let s:current_scheme_fsize = getfsize(ElementAt(s:color_schemes, s:sep, s:scheme_index))
	" set a random scheme_index from the range (0 ... total_schemes-1).
	let s:scheme_index = (localtime()+s:current_scheme_fsize) % s:total_schemes
	call LoadColorScheme()
endfunction

" load a color scheme 
function! LoadColorScheme()
	" quit if there's no color scheme
	if s:total_schemes == 0
		return 0
	endif

	" wrap around scheme_index for either direction
	if s:scheme_index < 0 
		let s:scheme_index = s:total_schemes-1
	elseif s:scheme_index >= s:total_schemes
		let s:scheme_index = 0
	endif

	" ElementAt returns the name of color scheme on scheme_index position in 
	" color_schemes array. Then we will load (source) the scheme.
	exe "source " ElementAt(s:color_schemes, s:sep, s:scheme_index)
endfunction

function! RemoveCurrentColorScheme()
	let s:current_scheme_path = ElementAt(s:color_schemes, s:sep, s:scheme_index)
	let s:isFilewritable = filewritable(s:current_scheme_path)

	if s:isFilewritable == 1
		let s:response = input("Are you sure to remove current color scheme (" . s:current_scheme_path . ") file? [y/n] ")

		if (s:response == "y" || s:response == "Y")
			let s:returnValue = delete(s:current_scheme_path)
			if s:returnValue == 0
				call InitializeVariables()
				call RandomColorScheme()
				redraw | echo s:current_scheme_path . " was removed"
			else
				echo 'Could not remove current color scheme file'
			endif
		else
			echo 'Removing current color scheme cancelled'
		endif
	elseif filereadable(s:current_scheme_path) == 1
		echo 'Could not remove current color scheme file'
	else
		echo 'Could not read the current color scheme file'
	endif
endfunction

call InitializeVariables()

" restore 'cpoptions'
set cpo&
if 1
	let &cpoptions = s:save_cpo
	unlet s:save_cpo
endif
