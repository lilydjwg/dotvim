" Name Of File: colorizer.vim
" Description:  Colorize all text in the form #hhhhhh
" Maintainer:	lilydjwg <lilydjwg@gmail.com>
" Last Change:	2011-04-28
" Licence:      No Warranties. Do whatever you want with this. But please tell me!
" Version:      1.0
" Usage:        This file should reside in the plugin directory.
" Modified From:This is a modification of css.vim http://www.vim.org/scripts/script.php?script_id=2150

" Reload guard and 'compatible' handling {{{1
let s:save_cpo = &cpo
set cpo&vim

if exists("loaded_colorizer")
  finish
endif

let loaded_colorizer = 1

" main part {{{1
function! s:FGforBG(bg) "{{{2
   " takes a 6hex color code and returns a matching color that is visible
   let pure = substitute(a:bg,'^#','','')
   let r = eval('0x'.pure[0].pure[1])
   let g = eval('0x'.pure[2].pure[3])
   let b = eval('0x'.pure[4].pure[5])
   if r*30 + g*59 + b*11 > 12000
      return '#000000'
   else
      return '#ffffff'
   end
endfunction
function! s:Rgb2xterm(color) "{{{2
   " selects the nearest xterm color for a rgb value like #FF0000
   let best_match=0
   let smallest_distance = 10000000000
   let r = eval('0x'.a:color[1].a:color[2])
   let g = eval('0x'.a:color[3].a:color[4])
   let b = eval('0x'.a:color[5].a:color[6])
   for c in range(0,254)
      let d = s:pow(s:colortable[c][0]-r,2) + s:pow(s:colortable[c][1]-g,2) + s:pow(s:colortable[c][2]-b,2)
      if d<smallest_distance
      let smallest_distance = d
      let best_match = c
      endif
   endfor
   return best_match
endfunction
"" the 6 value iterations in the xterm color cube {{{2
let s:valuerange = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]

"" 16 basic colors {{{2
let s:basic16 = [ [ 0x00, 0x00, 0x00 ], [ 0xCD, 0x00, 0x00 ], [ 0x00, 0xCD, 0x00 ], [ 0xCD, 0xCD, 0x00 ], [ 0x00, 0x00, 0xEE ], [ 0xCD, 0x00, 0xCD ], [ 0x00, 0xCD, 0xCD ], [ 0xE5, 0xE5, 0xE5 ], [ 0x7F, 0x7F, 0x7F ], [ 0xFF, 0x00, 0x00 ], [ 0x00, 0xFF, 0x00 ], [ 0xFF, 0xFF, 0x00 ], [ 0x5C, 0x5C, 0xFF ], [ 0xFF, 0x00, 0xFF ], [ 0x00, 0xFF, 0xFF ], [ 0xFF, 0xFF, 0xFF ] ]

function! s:Xterm2rgb(color) "{{{2
	" 16 basic colors
   let r=0
   let g=0
   let b=0
   if a:color<16
      let r = s:basic16[a:color][0]
      let g = s:basic16[a:color][1]
      let b = s:basic16[a:color][2]
   endif
	
	" color cube color
   if a:color>=16 && a:color<=232
      let color=a:color-16
      let r = s:valuerange[(color/36)%6]
      let g = s:valuerange[(color/6)%6]
      let b = s:valuerange[color%6]
   endif
	
	" gray tone
	if a:color>=233 && a:color<=253
      let r=8+(a:color-232)*0x0a
      let g=r
      let b=r
   endif
   let rgb=[r,g,b]
   return rgb
endfunction
function! s:pow(x, n) "{{{2
   let x = a:x
   for i in range(a:n-1)
      let x = x*a:x
   return x
endfunction
function! s:SetMatcher(clr,pat) "{{{2
   let group = 'Color'.substitute(a:clr,'^#','','')
   redir => s:currentmatch
      silent! exe 'syn list '.group
   redir END
   if s:currentmatch !~ a:pat.'\/'
      exe 'syn match '.group.' /'.a:pat.'\>/ containedin=ALL'
      exe 'syn cluster Colors add='.group
      if has('gui_running')
        exe 'hi '.group.' guifg='.s:FGforBG(a:clr)
        exe 'hi '.group.' guibg='.a:clr
      elseif &t_Co == 256
        exe 'hi '.group.' ctermfg='.s:Rgb2xterm(s:FGforBG(a:clr))
        exe 'hi '.group.' ctermbg='.s:Rgb2xterm(a:clr)
      endif
      return 1
   else
      return 0
   endif
endfunction
function! s:PreviewColorInLine(where) "{{{2
   " TODO 一行有两个颜色时
   let place = 0
   let foundcolor = matchstr(getline(a:where), '#[0-9A-Fa-f]\{6\}\d\@!')
   while foundcolor != ''
      let color = ''
      let color = foundcolor
      call s:SetMatcher(color,foundcolor)
      let place = match(getline(a:where), '#[0-9A-Fa-f]\{6\}\d\@!', place) + 1
      let foundcolor = matchstr(getline(a:where), '#[0-9A-Fa-f]\{6\}\d\@!', place)
   endwhile
endfunction
function s:UpdateAll() "{{{2
   let i = 1
   while i <= line("$")
      call s:PreviewColorInLine(i)
      let i = i+1
   endwhile
   unlet i
endfunction
let s:colortable=[] "{{{2
for c in range(0, 254)
   let color = s:Xterm2rgb(c)
   call add(s:colortable, color)
endfor
if has("gui_running") || &t_Co==256 "{{{2
   call s:UpdateAll()

   autocmd CursorHold * silent call s:PreviewColorInLine('.')
   autocmd CursorHoldI * silent call s:PreviewColorInLine('.')
   set ut=1000
   set nocuc nocul
   command UpdateColor call s:UpdateAll()
endif
" Cleanup and modelines {{{1
let &cpo = s:save_cpo

" vim:ft=vim:sw=3:fdm=marker:fen:fmr={{{,}}}:
