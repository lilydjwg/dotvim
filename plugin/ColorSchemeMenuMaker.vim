" ColorSchemeMenuMaker.vim: Generates Vim ColorScheme menu and organizes
" themes based upon background color of Normal highlight group, and by
" colorscheme name.

" Maintainer:       Erik Falor <ewfalor@gmail.com>
" Date:             Mar 27, 2008
" Version:          1.0
" License:          Vim License
"
" History: {{{
"   Version 1.0:    No reported problems for quite a while; I feel this
"                   plugin is no longer beta-quality.
"                   ReloadColorsMenu and RebuildColorsMenu commands will
"                   only remove menu items created by this plugin.  Other
"                   items placed in the ColorSchemes menu aren't destroyed
"                   when refreshing the menu unless absolutely necessary.
"
"   Version 0.10.1: Fixed bug: generated menu called non-existent
"                   function.
"
"   Version 0.10:   Menus sorted in case-insensitive fashion.  If this
"                   change breaks your muscle-memory, set the global var
"                   g:csmmIgnoreCase to 0 in your .vimrc to get the old
"                   behavior.  Super thanks to Bill McCarthy for
"                   suggesting this.
"                   Functions ReloadColors(), RefreshColors(), and their
"                   corresponding commands renamed to ReloadColorsMenu()
"                   and RebuildColorsMenu().
"
"   Version 0.9:    Will not create submenus which are too tall to fit
"                   on the screen.  By default, generated submenus are
"                   split so as to contain fewer than 45 items.  This
"                   number may be overridden via g:MaxEntriesPerSubmenu.
"
"   Version 0.8.1:  Shuangshi Jie bugfix: changed to Unix line endings.
"
"   Version 0.8:    Avoid loading menu in console mode.
"
"   Version 0.7:    Fixed some bugs in SDK mode.  Tweaked IsDarkGrey().
"
"   Version 0.6:    Created an SDK mode that creates an HTML page
"                   which aids in tweaking the color selection algorithm.
"                   To enable, define the variable g:ColorSchemeSDKMode
"                   and install ColorSchemeSDK.vim in the autoload/
"                   directory.
"                   Tweaked with IsYellow() and IsGreen() a bit... robinhood
"                   now shows up as green instead of yellow.
"                   Added IsPurple().
"                   I have forgotten to mention that if a colorscheme has more
"                   than one 'hi Normal ...' command its name will have a *
"                   prepended to it.  If such a theme shows up in the wrong
"                   color category, its because I guessed wrong at which
"                   Normal group is used.  It also means that you may be able
"                   to control the look and feel of the colorscheme by setting
"                   variables in your .vimrc file.
"
"   Version 0.5:    Store the generated menu under the same directory
"                   this file is located.  Thanks to Vincent Vandalon for
"                   pointing out that not all folks have a ~/vimfiles
"                   directory under WinXP.
"
"   Version 0.4:    Switched to Unix line endings.  Look for rgb.txt under
"                   /usr/share/X11 to accomodate Gentoo Linux.
"
"   Version 0.3:    Now works on Linux by looking for rgb.txt in
"                   /usr/X11R6/lib/X11 instead of $VIMRUNTIME.  If your
"                   rgb.txt is kept somewhere else, store that absolute
"                   pathname in your .vimrc in a variable called g:rgbtxt.
"
"   Version 0.2:    Menu categories include a count of contained items. 
"
"   Version 0.1:    Initial upload
" }}}

" Usage Notes: {{{
" Menu entries prepended with an asterisk denote colorschemes which contain
" more than one Normal highlight group.  CSMM does not parse the colorscheme
" files, it simply scans them looking for a Normal highlight group defining
" a guibg attribute.  When CSMM encounters more than one such group in a
" single file it assigns that colorscheme's category based upon the first 
" guibg attribute.  The asterisk serves as a disclaimer in such circumstances.
" Users unhappy with this behavior of the CSMM plugin are eligible for a full
" refund of the retail price of this plugin.
"
" The folowing globals impact the operation of this plugin:
" g:MaxEntriesPerSubmenu - The maximum height in rows for the submenus
"       containing the colorschemes sorted by color or by name.  This keeps
"       the menus short enough to fit entirely on the screen.  The default
"       height is set to 45.  
"
" g:rgbtxt - Contains the path to your installation of rgb.txt.  Set this if
"       the plugin fails because it cannot find this file itself.
"
" g:csmmIgnoreCase - The plugin sorts items in the submenus without regard to
"       case.  If you want it to regard case, set this variable to zero before
"       running :RebuildMenu.
"}}}

" GetLatestVimScripts: 2004 1 ColorSchemeMenuMaker.zip

" Initialization: {{{
if exists("g:loaded_theme_menu") && !exists("g:ColorSchemeSDKMode")
    finish
endif
let g:loaded_theme_menu= "0.10"
let s:keepcpo      = &cpo
set cpo&vim
"}}}

" Script Variables: {{{
"store the generated menu under the same path this file is found:
let s:MaxEntriesPerSubmenu = 45
let s:menuFile = expand('<sfile>:p:h') . '/ColorSchemes.vim'
let s:menuName = '&ColorSchemes'
let s:xdigit = '[0123456789ABCDEFabcdef]'
let s:hexvals = { 0:0, 1:1, 2:2, 3:3,
            \4:4, 5:5, 6:6, 7:7,
            \8:8, 9:9, 'a':10, 'b':11,
            \'c':12, 'd':13, 'e':14, 'f':15,
            \'A':10, 'B':11, 'C':12, 'D':13,
            \'E':14, 'F':15 }
"}}}

" Library Functions {{{
function! <SID>RGBtoHSV(r, g, b) "{{{
    let h = 0
    let s = 0
    let v = 0
    "blue is greatest
    if (a:b > a:g) && (a:b > a:r)
        let v = a:b
        if v != 0
            let min = 0
            if(a:r > a:g)
                let min = a:g
            else
                let min = a:r 
            endif

            let delta = v - min

            if delta != 0
                let s = (delta * 255) / v
                let h = 240 + (60 * a:r - 60 * a:g) / delta
            else 
                let s = 0
                let h = 240 + (60 * a:r - 60 * a:g)
            endif
            if h < 0 
                let h = h + 360 
            endif
        else 
            let s = 0
            let h = 0
        endif
    "green is greatest
    elseif a:g > a:r
        let v = a:g
        if v != 0
            let min = 0
            if a:r > a:b
                let min = a:b 
            else 
                let min = a:r 
            endif
            let delta = v - min
            if delta != 0
                let s = (delta * 255) / v
                let h = 120 + (60 * a:b - 60 * a:r) / delta
            else 
                let s = 0
                let h = 120 + (60 * a:b - 60 * a:r)
            endif
            if h < 0
                let h = h + 360 
            endif
        else 
            let s = 0
            let h = 0
        endif
    "red is greatest
    else
        let v = a:r
        if v != 0
            let min = 0
            if a:g > a:b
                let min = a:b
            else
                let min = a:g
            endif
            let delta = v - min
            if delta != 0
                let s = (delta * 255) / v
                let h = (60 * a:g - 60 * a:b) / delta
            else 
                let s = 0
                let h = 60 * a:g - 60 * a:b
            endif
            if h < 0
                let h = h + 360 
            endif
        else
            let s = 0
            let h = 0
        endif
    endif
    return [h, s, v]
endfunction "RGBtoHSV()
"}}}

function! <SID>IsBlack(r, g, b, h, s, v) "{{{
    if a:r == a:g && a:g == a:b && a:b == 0
        return 1
    else
        return 0
    endif
endfunction "IsBlack()}}}
    
function! <SID>IsWhite(r, g, b, h, s, v) "{{{
    if a:r == a:g && a:g == a:b && a:b == 255
        return 1
    else 
        return 0
    endif
endfunction "IsWhite()}}}

function! <SID>IsDarkGrey(r, g, b, h, s, v) "{{{
    let diffRGB = max([a:r, a:g, a:b]) - min([a:r, a:g, a:b])
    let darkGreyFuzz = 10
    if diffRGB <= darkGreyFuzz
        return 1
    else 
        return 0
    endif
endfunction "IsDarkGrey()}}}

function! <SID>IsOffWhite(r, g, b, h, s, v) "{{{
    let offWhiteSat = 32
    let offWhiteVal = 255 - 32
    if a:v >= offWhiteVal && a:s <= offWhiteSat
        return 1
    else 
        return 0
    endif
endfunction "}}}

function! <SID>IsGrey(r, g, b, h, s, v) "{{{
    let diffRGB = max([a:r, a:g, a:b]) -  min([a:r, a:g, a:b])
    let greyFuzz = 28
    let greyVal = 32

    if diffRGB > greyFuzz
        return 0
    elseif (a:s <= greyFuzz )
            \&& (a:v <= 255 - (greyVal * 1))
            \&& (a:v >= 0   + (greyVal * 1))
        return 1 
    else
        return 0
    endif
endfunction "}}}

function! <SID>IsYellow(r, g, b, h, s, v) "{{{
    if a:h > 30 && a:h <= 69
        return 1
    else 
        return 0
    endif
endfunction "}}}

function! <SID>IsGreen(r, g, b, h, s, v) "{{{
    if a:h > 70 && a:h <= 180
        return 1
    else 
        return 0
    endif
endfunction "}}}

function! <SID>IsCyan(r, g, b, h, s, v) "{{{
"   cyan will be 180 deg +/- 10 deg
    let variance = 10
    if a:h > 180 - variance && a:h < 180 + variance
        return 1
    else 
        return 0
    endif
endfunction "}}}

function! <SID>IsPurple(r, g, b, h, s, v) "{{{
    if a:r >= a:g && a:b > a:g && a:r != 0 && a:g != 0
        return 1
    endif
    return 0
endfunction "}}}

function! <SID>IsBlue(r, g, b, h, s, v) "{{{
    if a:h > 180 && a:h <= 270
        return 1
    else 
        return 0
    endif
endfunction "}}}

function! <SID>IsMagenta(r, g, b, h, s, v) "{{{
    if a:h > 270 && a:h <= 330
        return 1
    else 
        return 0
    endif
endfunction }}}

function! <SID>IsOrange(r, g, b, h, s, v) "{{{
    "a magic number found through trial and error
    let greenFuzz = 172 
    if a:r > a:g && a:b == 0 && a:g < greenFuzz && a:g != 0
        return 1
    else
        return 0
    endif
endfunction "}}}

function! <SID>IsRed(r, g, b, h, s, v) "{{{
    if a:h > 330 || a:h <= 30
        return 1
    else
        return 0
    endif
endfunction "}}}

function! <SID>FindRgbTxt() "{{{
    "read rgb.txt, return dictionary mapping color names to hex triplet
    if exists("g:rgbtxt") && filereadable(g:rgbtxt)
        let rgbtxt = g:rgbtxt
    else
        if has("win32") || has("win64")
            let rgbtxt = expand("$VIMRUNTIME/rgb.txt")
        elseif filereadable("/usr/X11R6/lib/X11/rgb.txt")
            let rgbtxt = "/usr/X11R6/lib/X11/rgb.txt"
        elseif filereadable("/usr/share/X11/rgb.txt")
            let rgbtxt = "/usr/share/X11/rgb.txt"
        endif
    endif
    return rgbtxt
endfunction "}}}

function! <SID>RgbTxt2Hexes() "{{{
    let rgbtxt = <SID>FindRgbTxt()
    let rgbdict = {}
    if filereadable(rgbtxt)
        for line in readfile(rgbtxt)
            if line !~ '^\(!\|#\)'
                let l = matchlist(line, '\s*\(\d\+\)\s*\(\d\+\)\s*\(\d\+\)\s*\(.*\)')
                let rgbdict[tolower(l[4])] = printf('%02X%02X%02X', l[1], l[2], l[3])
            endif
        endfor
        "note: vim treats guibg=NONE as guibg=white
        let rgbdict['none'] = 'FFFFFF'
    else
        echoerr "ColorSchemeMenuMaker.vim could not open rgb.txt file at " . rgbtxt 
    endif
    return rgbdict
endfunction "}}}

function! <SID>RGBHexToHexes(rgb) "{{{
    let xdigits = '\(' . s:xdigit . '\{2\}\)'
    let pat = '\(#\)\?' . xdigits . xdigits . xdigits
    let l = matchlist(a:rgb, pat)
    if len(l) > 0
        return [ l[2], l[3], l[4] ]
    else
        return []
    endif
endfunction "}}}

function! <SID>RGBHexToInts(rgbList) "{{{
    return map(a:rgbList, '<SID>Hex2Int(v:val)')
endfunction "}}}

function! <SID>Hex2Int(hex) "{{{
    let xdigits = split(a:hex, '\zs')
    return 16 * s:hexvals[xdigits[0]] + s:hexvals[xdigits[1]]
endfunction "}}}

function! <SID>RGB2BoyColor(rgb) "{{{
    let rgbL = <SID>RGBHexToInts(<SID>RGBHexToHexes(a:rgb))
    let r = rgbL[0] | let g = rgbL[1] | let b = rgbL[2]
    let hsvL = <SID>RGBtoHSV(r, g, b)
    let h = hsvL[0] | let s = hsvL[1] | let v = hsvL[2]
    if <SID>IsBlack(r, g, b, h, s, v) == 1 | return 'black' | endif
    if <SID>IsWhite(r, g, b, h, s, v) == 1 | return 'white' | endif
    if <SID>IsGrey(r, g, b, h, s, v) == 1 | return 'grey' | endif
    if <SID>IsOffWhite(r, g, b, h, s, v) == 1 | return 'offwhite' | endif
    if <SID>IsDarkGrey(r, g, b, h, s, v) == 1 | return 'darkgrey' | endif
    if <SID>IsOrange(r, g, b, h, s, v) == 1 | return 'orange' | endif
    if <SID>IsYellow(r, g, b, h, s, v) == 1 | return 'yellow' | endif
    if <SID>IsCyan(r, g, b, h, s, v) == 1 | return 'cyan' | endif
    if <SID>IsGreen(r, g, b, h, s, v) == 1 | return 'green' | endif
    if <SID>IsPurple(r, g, b, h, s, v) == 1 | return 'purple' | endif
    if <SID>IsBlue(r, g, b, h, s, v) == 1 | return 'blue' | endif
    if <SID>IsMagenta(r, g, b, h, s, v) == 1 | return 'magenta' | endif
    if <SID>IsRed(r, g, b, h, s, v) == 1 | return 'red' | endif
    return 'unknown'
endfunction "}}}

function! <SID>GlobThemes() "{{{
    "return list containing paths to all theme files in &runtimepath
    return split(globpath(&rtp, 'colors/*.vim'), '\n')
endfunction "}}}

function! <SID>ScanThemeBackgrounds() "{{{
    "Read each of the theme files and find out which color
    "each theme 'basically' is.  Uses the last 'hi Normal' 
    "group found to classify by color.  Notes those color
    "files that do have more than one 'hi Normal' command.
    let name2hex = <SID>RgbTxt2Hexes()
    let themeColors = {}
    let themeNames = {}
    let i = 0
    let pat = 'hi.*\s\+Normal\s\+.\{-}guibg=\(#\?\)\(\w\+\)'
    for theme in <SID>GlobThemes()
        if filereadable(theme)

            "DEBUG
            "let i = i + 1
            "if i > 10
                "break
            "endif

            let higroupfound = 0
            let color = ''
            for line in readfile(theme)
                let bg = matchlist(line, pat)
                if len(bg) > 0
                    if bg[1] == '#'
                        let color = <SID>RGB2BoyColor(bg[2])
                    else
                        if has_key(name2hex, tolower(bg[2]))
                            let color = <SID>RGB2BoyColor(name2hex[tolower(bg[2])])
                        else
                            let color = 'unknown'
                        endif
                    endif
                    let higroupfound += 1
                endif
            endfor
            let themename = fnamemodify(theme, ':t:r')
            let letter = toupper(strpart(themename, 0, 1))
            if letter =~ '\d' | let letter = '#' | endif

            if len(color) < 1 
                let color = 'unknown'
            endif

            "allocate sub-dict if needed
            if !has_key(themeColors, color)
                let themeColors[color] = {}
            endif
            "allocate sub-dict if needed
            if !has_key(themeNames, letter)
                let themeNames[letter] = {}
            endif
            if higroupfound > 1
                "mark themes with many 'hi Normal' commands
                if len(color) > 0
                    let themeColors[color][themename] = '*' . themename
                endif
                let themeNames[letter][themename] = '*' . themename
            else
                if len(color) > 0
                    let themeColors[color][themename] = themename
                endif
                let themeNames[letter][themename] = themename
            endif
        endif
    endfor
    return [themeColors, themeNames]
endfunction "}}}

function! <SID>CSMMSort(list, ignoreCase) "{{{
    if a:ignoreCase == 0
        return sort(a:list)
    else
        return sort(a:list, 1)
    endif
endfunction "}}}

function! <SID>BuildMenu(dicts) "{{{
    "puts menu commands into a list
    let menu = []
    if !exists('g:csmmIgnoreCase') | let g:csmmIgnoreCase = 1 | endif

    if exists('g:MaxEntriesPerSubmenu')
        let MaxEntriesPerSubmenu = g:MaxEntriesPerSubmenu
    else
        let MaxEntriesPerSubmenu = s:MaxEntriesPerSubmenu
    endif

    call add(menu, '"ColorScheme menu generated ' . strftime("%c", localtime()))
    call add(menu, '"Menu created with ColorSchemeMenuMaker.vim by Erik Falor')
    call add(menu, '"Get the latest version at http://www.vim.org/scripts/script.php?script_id=2004')
    call add(menu, '')
    call add(menu, '"Do not load this menu unless running in GUI mode')
    call add(menu, 'if !has("gui_running") | finish | endif')
    call add(menu, '')

    "ColorSchemes Sub-Menu, by Color
    call add(menu, '"Themes by color:')
    "count number of themes categorized by color
    let totThemes = 0
    for i in keys(a:dicts[0])
        let totThemes += len(a:dicts[0][i])
    endfor
    for color in <SID>CSMMSort(keys(a:dicts[0]), g:csmmIgnoreCase)
        call add(menu, '')
        call add(menu, '"submenu '. color)
        let numThemes = len(a:dicts[0][color])
        "if the number of themes for this color does not exceed the total for
        "any sub menu, go ahead and add them all to the same menu
        if numThemes <= MaxEntriesPerSubmenu
            for theme in <SID>CSMMSort(keys(a:dicts[0][color]), g:csmmIgnoreCase)
                call add(menu, '9000amenu '. s:menuName. '.&Colors\ ('. totThemes . ').'
                        \. color . '\ ('. numThemes . ').'
                        \. a:dicts[0][color][theme]. '  :colo '. theme . '<CR>')
            endfor
        else
            let submenus = []
            let i = 0
            while i < numThemes / MaxEntriesPerSubmenu
                call add(submenus, MaxEntriesPerSubmenu)
                let i += 1
            endwhile
            if numThemes % MaxEntriesPerSubmenu != 0
                call add(submenus, numThemes % MaxEntriesPerSubmenu)
            endif
            if len(submenus) > 1 && submenus[-1] != submenus[-2]
                let submenus = <SID>BalanceSubmenu(submenus)
            endif
            let i = 0
            let j = 0
            for theme in <SID>CSMMSort(keys(a:dicts[0][color]), g:csmmIgnoreCase)
                call add(menu, '9000amenu '. s:menuName. '.&Colors\ ('. totThemes . ').'
                        \. color . '-' . string(i+1) . '\ ('. submenus[i] . ').'
                        \. a:dicts[0][color][theme]. '  :colo '. theme . '<CR>')
                let j += 1
                if j == submenus[i]
                    let j = 0
                    let i += 1
                endif
            endfor
        endif
    endfor
    
    "ColorSchemes Sub-Menu, by Name
    call add(menu, '"Themes by name:')
    call add(menu, '')
    "count number of themes categorized by name
    let totThemes = 0
    for i in keys(a:dicts[1])
        let totThemes += len(a:dicts[1][i])
    endfor
    for letter in <SID>CSMMSort(keys(a:dicts[1]), g:csmmIgnoreCase)
        let numThemes = len(a:dicts[1][letter])
        call add(menu, '')
        call add(menu, '"submenu '. letter)
        "if the number of themes for this letter does not exceed the total for
        "any sub menu, go ahead and add them all to the same menu
        if numThemes <= MaxEntriesPerSubmenu
            for theme in <SID>CSMMSort(keys(a:dicts[1][letter]), g:csmmIgnoreCase)
                call add(menu, 'amenu '. s:menuName. '.&Names\ (' . totThemes . ').'
                        \. letter . '\ ('. numThemes .').'
                        \.  a:dicts[1][letter][theme] . '  :colo '. theme . '<CR>')
            endfor
        else
            let submenus = []
            let i = 0
            while i < numThemes / MaxEntriesPerSubmenu
                call add(submenus, MaxEntriesPerSubmenu)
                let i += 1
            endwhile
            if numThemes % MaxEntriesPerSubmenu != 0
                call add(submenus, numThemes % MaxEntriesPerSubmenu)
            endif
            if len(submenus) > 1 && submenus[-1] != submenus[-2]
                let submenus = <SID>BalanceSubmenu(submenus)
            endif
            let i = 0
            let j = 0

            for theme in <SID>CSMMSort(keys(a:dicts[1][letter]), g:csmmIgnoreCase)
                call add(menu, '9000amenu '. s:menuName. '.&Names\ ('. totThemes . ').'
                        \. letter . '-' . string(i+1) . '\ ('. submenus[i] . ').'
                        \. a:dicts[1][letter][theme]. '  :colo '. theme . '<CR>')
                let j += 1
                if j == submenus[i]
                    let j = 0
                    let i += 1
                endif
            endfor
        endif
    endfor

    call add(menu, '')
    "add a separator and a command to re-init the menu
    call add(menu, 'amenu ' . s:menuName .'.-Sep-   :')
    call add(menu, 'amenu ' . s:menuName .'.Reload\ Menu    :ReloadColorsMenu<CR>')
    call add(menu, 'amenu ' . s:menuName .'.Rebuild\ Menu   :RebuildColorsMenu<CR>')
    call add(menu, '')
    call add(menu, 'command! -nargs=0       ReloadColorsMenu        call <SID>ReloadColorsMenu()')
    call add(menu, 'command! -nargs=0       RebuildColorsMenu       call <SID>RebuildColorsMenu()')
    call add(menu, '')
    call add(menu, 'if !exists("g:running_ReloadColorsMenu")')
    call add(menu, '    function! <SID>ReloadColorsMenu()')
    call add(menu, '        let g:running_ReloadColorsMenu = 1')
    call add(menu, '        aunmenu ' . s:menuName . '.&Colors\ (' . totThemes . ')')
    call add(menu, '        aunmenu ' . s:menuName . '.&Names\ (' . totThemes . ')')
    call add(menu, '        aunmenu ' . s:menuName . '.-Sep-')
    call add(menu, '        aunmenu ' . s:menuName . '.Reload\ Menu')
    call add(menu, '        aunmenu ' . s:menuName . '.Rebuild\ Menu')
    call add(menu, "        execute 'source " . s:menuFile . "'")
    call add(menu, '        unlet g:running_ReloadColorsMenu')
    call add(menu, "        echomsg 'Done reloading " . s:menuFile . "'")
    call add(menu, '    endfunction')
    call add(menu, 'endif')

    call add(menu, 'if !exists("g:running_RebuildColorsMenu")')
    call add(menu, '    function! <SID>RebuildColorsMenu()')
    call add(menu, '        let g:running_RebuildColorsMenu = 1')
    call add(menu, '        call WriteColorSchemeMenu()')
    call add(menu, '        call <SID>ReloadColorsMenu()')
    call add(menu, '        unlet g:running_RebuildColorsMenu')
    call add(menu, "        echomsg 'Done rebuilding " . s:menuFile . "'")
    call add(menu, '    endfunction')
    call add(menu, 'endif')
    return menu
endfunction "BuildMenu}}}

function! <SID>BalanceSubmenu(s) "{{{
    let next2last = len(a:s) - 2
    let i = next2last

    while a:s[-1] < a:s[-2]
        let a:s[-1] += 1
        let a:s[i] -= 1
        if i > 0
            let i -= 1
        elseif a:s[-2] -1 == a:s[-1]
            break
        else
            let i = next2last
        endif
    endwhile
    return a:s
endfunction "BalanceSubmenu}}}

function! WriteColorSchemeMenu() "{{{
    "Builds the menu from the two dicts returned by ScanThemeBackgrounds()
    "Stores menu in first plugin dir specified by &rtp
    let dicts = <SID>ScanThemeBackgrounds()
    let menu = <SID>BuildMenu(dicts)
    call writefile(menu, s:menuFile)
endfunction "}}}

function! <SID>InitMenu() "{{{
    call WriteColorSchemeMenu()
    execute "source " . s:menuFile
endfunction "}}}
"}}}

"{{{ SDK-Mode Section
if exists("g:ColorSchemeSDKMode")
    let g:mapping = 'map <F5> :so ' . g:ColorSchemeSDKMode . 
        \'/autoload/ColorSchemeSDK.vim \| so ' .
        \g:ColorSchemeSDKMode . '/plugin/ColorSchemeMenuMaker.vim ' .
        \'\| call GenHTML() <CR>'
    execute g:mapping

    "get the script ID for functions in this script
    function! <SID>SID() "{{{
        return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$') . '_'
    endfunction "}}}

    let s:sid = <SID>SID()

    let s:CSMMfuncs = { 
                \'CSMMSort'                 : function(s:sid . "CSMMSort"),
                \'RGBtoHSV'                 : function(s:sid . "RGBtoHSV"),
                \'IsBlack'                  : function(s:sid . "IsBlack"),
                \'IsWhite'                  : function(s:sid . "IsWhite"),
                \'IsDarkGrey'               : function(s:sid . "IsDarkGrey"),
                \'IsOffWhite'               : function(s:sid . "IsOffWhite"),
                \'IsGrey'                   : function(s:sid . "IsGrey"),
                \'IsYellow'                 : function(s:sid . "IsYellow"),
                \'IsGreen'                  : function(s:sid . "IsGreen"),
                \'IsCyan'                   : function(s:sid . "IsCyan"),
                \'IsBlue'                   : function(s:sid . "IsBlue"),
                \'IsPurple'                 : function(s:sid . "IsPurple"),
                \'IsMagenta'                : function(s:sid . "IsMagenta"),
                \'IsOrange'                 : function(s:sid . "IsOrange"),
                \'IsRed'                    : function(s:sid . "IsRed"),
                \'FindRgbTxt'               : function(s:sid . "FindRgbTxt"),
                \'RgbTxt2Hexes'             : function(s:sid . "RgbTxt2Hexes"),
                \'RGBHexToHexes'            : function(s:sid . "RGBHexToHexes"),
                \'RGBHexToInts'             : function(s:sid . "RGBHexToInts"),
                \'Hex2Int'                  : function(s:sid . "Hex2Int"),
                \'RGB2BoyColor'             : function(s:sid . "RGB2BoyColor"),
                \'GlobThemes'               : function(s:sid . "GlobThemes"),
                \'ScanThemeBackgrounds'     : function(s:sid . "ScanThemeBackgrounds"),
                \'BuildMenu'                : function(s:sid . "BuildMenu") }

    "let g:CSMMfuncs = s:CSMMfuncs 

    function! CallIt(key, ...) 
        return ColorSchemeSDK#Invoke1(s:CSMMfuncs[a:key], a:1)
    endfunction

    "creates an html file named a:destfile that shows the background color
    "along with the color guessed by this plugin
    function! GenHTML(...)
        if 0 == a:0 
            let destfile = 'ColorScheme.html'
        else
            let destfile = a:1
        endif
        return ColorSchemeSDK#GenHTML(destfile, s:CSMMfuncs)
    endfunction
    echom "Using ColorSchemeMenuMaker in SDK mode!"
    echom "unlet g:ColorSchemeSDKMode to disable"
endif
"}}}

" Restore &cpo: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
"}}}1

"Detect absence of ColorScheme menu, and generate a new one automatically
if has("gui_running") && !filereadable(s:menuFile) "{{{
    echomsg "Creating ColorScheme menu - Please Wait..."
    call <SID>InitMenu()
    echomsg "Done!"
endif "}}}

"  vim: tabstop=4 foldmethod=marker expandtab
