" Taken from http://en.wikipedia.org/wiki/Wikipedia:Text_editor_support#Vim
" 	Ian Tegebo <ian.tegebo@gmail.com>

" Wikipedia syntax file for Vim
" Published on Wikipedia in 2003-04 and declared authorless.
" 
" Based on the HTML syntax file. Probably too closely based, in fact. There
" may well be name collisions everywhere, but ignorance is bliss, so they say.
"
" To do: plug-in support for downloading and uploading to the server.

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
  finish
endif
  let main_syntax = 'html'
endif

if version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif

syn case ignore

syn spell toplevel
" lilydjwg: 取消了拼写检查
" set spell

" tags
syn region  htmlString   contained start=+"+ end=+"+ contains=htmlSpecialChar
syn region  htmlString   contained start=+'+ end=+'+ contains=htmlSpecialChar
syn match   htmlValue    contained "=[\t ]*[^'" \t>][^ \t>]*"hs=s+1
syn region  htmlEndTag             start=+</+      end=+>+ contains=htmlTagN

"syn region  htmlTag                start=+<[^/]+   end=+>+ contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,@htmlArgCluster
syn region  htmlTag                start=+<[^/]+   end=+>+ contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent,htmlCssDefinition,@htmlPreproc,@htmlArgCluster

syn match   htmlTagN     contained +<\s*[-a-zA-Z0-9]\++hs=s+1 contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster
syn match   htmlTagN     contained +</\s*[-a-zA-Z0-9]\++hs=s+2 contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster
syn match   htmlTagError contained "[^>]<"ms=s+1

" allowed tag names
syn keyword htmlTagName contained b i u font big small sub sup 
syn keyword htmlTagName contained h1 h2 h3 h4 h5 h6 cite code em s strike strong tt var div center
syn keyword htmlTagName contained blockquote ol ul dl table caption pre
syn keyword htmlTagName contained ruby rt rb rp
syn keyword htmlTagName contained br p hr li dt dd
syn keyword htmlTagName contained table tr td th div blockquote ol ul
syn keyword htmlTagName contained dl font big small sub sup
syn keyword htmlTagName contained td th tr
syn keyword htmlTagName contained nowiki math

" allowed arg names
syn keyword htmlArg contained title align lang dir width height
syn keyword htmlArg contained bgcolor clear noshade
syn keyword htmlArg contained cite size face color
syn keyword htmlArg contained type start value compact
syn keyword htmlArg contained summary width border frame rules
syn keyword htmlArg contained cellspacing cellpadding valign char
syn keyword htmlArg contained charoff colgroup col span abbr axis
syn keyword htmlArg contained headers scope rowspan colspan
syn keyword htmlArg contained id class name style

" special characters
syn match htmlSpecialChar "&#\=[0-9A-Za-z]\{1,8};"

" comments
syn region htmlComment                start=+<!+      end=+>+   contains=htmlCommentPart,htmlCommentError
syn match  htmlCommentError contained "[^><!]"
syn region htmlCommentPart  contained start=+--+      end=+--\s*+  contains=@htmlPreProc
syn region htmlComment                  start=+<!DOCTYPE+ keepend end=+>+

" HTML formatting
syn cluster htmlTop contains=@Spell,htmlTag,htmlEndTag,htmlSpecialChar,htmlComment,htmlLink

syn region htmlBold start="<b\>" end="</b>"me=e-4 contains=@htmlTop,htmlBoldUnderline,htmlBoldItalic
syn region htmlBold start="<strong\>" end="</strong>"me=e-9 contains=@htmlTop,htmlBoldUnderline,htmlBoldItalic
syn region htmlBoldUnderline contained start="<u\>" end="</u>"me=e-4 contains=@htmlTop,htmlBoldUnderlineItalic
syn region htmlBoldItalic contained start="<i\>" end="</i>"me=e-4 contains=@htmlTop,htmlBoldItalicUnderline
syn region htmlBoldItalic contained start="<em\>" end="</em>"me=e-5 contains=@htmlTop,htmlBoldItalicUnderline
syn region htmlBoldUnderlineItalic contained start="<i\>" end="</i>"me=e-4 contains=@htmlTop
syn region htmlBoldUnderlineItalic contained start="<em\>" end="</em>"me=e-5 contains=@htmlTop
syn region htmlBoldItalicUnderline contained start="<u\>" end="</u>"me=e-4 contains=@htmlTop,htmlBoldUnderlineItalic

syn region htmlUnderline start="<u\>" end="</u>"me=e-4 contains=@htmlTop,htmlUnderlineBold,htmlUnderlineItalic
syn region htmlUnderlineBold contained start="<b\>" end="</b>"me=e-4 contains=@htmlTop,htmlUnderlineBoldItalic
syn region htmlUnderlineBold contained start="<strong\>" end="</strong>"me=e-9 contains=@htmlTop,htmlUnderlineBoldItalic
syn region htmlUnderlineItalic contained start="<i\>" end="</i>"me=e-4 contains=@htmlTop,htmUnderlineItalicBold
syn region htmlUnderlineItalic contained start="<em\>" end="</em>"me=e-5 contains=@htmlTop,htmUnderlineItalicBold
syn region htmlUnderlineItalicBold contained start="<b\>" end="</b>"me=e-4 contains=@htmlTop
syn region htmlUnderlineItalicBold contained start="<strong\>" end="</strong>"me=e-9 contains=@htmlTop
syn region htmlUnderlineBoldItalic contained start="<i\>" end="</i>"me=e-4 contains=@htmlTop
syn region htmlUnderlineBoldItalic contained start="<em\>" end="</em>"me=e-5 contains=@htmlTop

syn region htmlItalic start="<i\>" end="</i>"me=e-4 contains=@htmlTop,htmlItalicBold,htmlItalicUnderline
syn region htmlItalic start="<em\>" end="</em>"me=e-5 contains=@htmlTop
syn region htmlItalicBold contained start="<b\>" end="</b>"me=e-4 contains=@htmlTop,htmlItalicBoldUnderline
syn region htmlItalicBold contained start="<strong\>" end="</strong>"me=e-9 contains=@htmlTop,htmlItalicBoldUnderline
syn region htmlItalicBoldUnderline contained start="<u\>" end="</u>"me=e-4 contains=@htmlTop
syn region htmlItalicUnderline contained start="<u\>" end="</u>"me=e-4 contains=@htmlTop,htmlItalicUnderlineBold
syn region htmlItalicUnderlineBold contained start="<b\>" end="</b>"me=e-4 contains=@htmlTop
syn region htmlItalicUnderlineBold contained start="<strong\>" end="</strong>"me=e-9 contains=@htmlTop

syn region htmlH1 start="<h1\>" end="</h1>"me=e-5 contains=@htmlTop
syn region htmlH2 start="<h2\>" end="</h2>"me=e-5 contains=@htmlTop
syn region htmlH3 start="<h3\>" end="</h3>"me=e-5 contains=@htmlTop
syn region htmlH4 start="<h4\>" end="</h4>"me=e-5 contains=@htmlTop
syn region htmlH5 start="<h5\>" end="</h5>"me=e-5 contains=@htmlTop
syn region htmlH6 start="<h6\>" end="</h6>"me=e-5 contains=@htmlTop
syn region htmlHead start="<head\>" end="</head>"me=e-7 end="<body\>"me=e-5 end="<h[1-6]\>"me=e-3 contains=htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,htmlLink,htmlTitle,cssStyle
syn region htmlTitle start="<title\>" end="</title>"me=e-8 contains=htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment

" wiki formatting
"syn region wikiItalic start="\([^']\|\_^\)''[^']"hs=s+1 end="[^']''\([^']\|\_$\)"he=e-1 skip="<nowiki>.*</nowiki>" contains=wikiLink,wikiItalicBold
"syn region wikiBold start="\([^']\|\_^\)'''[^']" end="[^']'''\([^']\|\_$\)" skip="<nowiki>.*</nowiki>" contains=wikiLink,wikiBoldItalic

"syn region wikiBoldItalic contained start="\([^']\|\_^\)''[^']" end="[^']''\([^']\|\_$\)" skip="<nowiki>.*</nowiki>" contains=wikiLink
"syn region wikiItalicBold contained start="\([^']\|\_^\)'''[^']" end="[^']'''\([^']\|\_$\)" skip="<nowiki>.*</nowiki>" contains=wikiLink

"syn region wikiBoldAndItalic start="'''''" end="'''''" skip="<nowiki>.*</nowiki>" contains=wikiLink

syn region wikiItalic			start=+'\@<!'''\@!+	end=+''+ contains=@Spell,wikiLink,wikiItalicBold
syn region wikiBold				start=+'''+			end=+'''+ contains=@Spell,wikiLink,wikiBoldItalic
syn region wikiBoldAndItalic	start=+'''''+		end=+'''''+ contains=@Spell,wikiLink

syn region wikiBoldItalic	contained	start=+'\@<!'''\@!+	end=+''+ contains=@Spell,wikiLink
syn region wikiItalicBold	contained	start=+'''+			end=+'''+ contains=@Spell,wikiLink

syn region wikiH1 start="^=" 		end="=" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH2 start="^==" 		end="==" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH3 start="^===" 		end="===" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH4 start="^====" 	end="====" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH5 start="^=====" 	end="=====" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiH6 start="^======" 	end="======" 	skip="<nowiki>.*</nowiki>" oneline contains=@Spell,wikiLink
syn region wikiLink start="\[\[" end="\]\]\(s\|'s\|es\|ing\|\)" skip="<nowiki>.*</nowiki>" oneline contains=wikiLink
syn region wikiLink start="\[http:" end="\]" skip="<nowiki>.*</nowiki>" oneline
syn region wikiLink start="\[https:" end="\]" skip="<nowiki>.*</nowiki>" oneline
syn region wikiLink start="\[ftp:" end="\]" skip="<nowiki>.*</nowiki>" oneline
syn region wikiLink start="\[gopher:" end="\]" skip="<nowiki>.*</nowiki>" oneline
syn region wikiLink start="\[news:" end="\]" skip="<nowiki>.*</nowiki>" oneline
syn region wikiLink start="\[mailto:" end="\]" skip="<nowiki>.*</nowiki>" oneline
syn region wikiTemplate start="{{" end="}}" skip="<nowiki>.*</nowiki>" 

syn match wikiParaFormatChar /^[\:|\*|;|#]\+/
syn match wikiParaFormatChar /^-----*/
syn match wikiPre /^\ .*$/

syn include @TeX syntax/tex.vim
syntax region wikiTeX matchgroup=htmlTag start="<math>" end="</math>" skip="<nowiki>.*</nowiki>" contains=@TeX 
syntax region wikiRef matchgroup=htmlTag start="<ref>" end="</ref>" skip="<nowiki>.*</nowiki>"


" HTML highlighting

HtmlHiLink htmlTag                     Function
HtmlHiLink htmlEndTag                  Identifier
HtmlHiLink htmlArg                     Type
HtmlHiLink htmlTagName                 htmlStatement
HtmlHiLink htmlSpecialTagName          Exception
HtmlHiLink htmlValue                     String
HtmlHiLink htmlSpecialChar             Special

HtmlHiLink htmlH1                      Title
HtmlHiLink htmlH2                      htmlH1
HtmlHiLink htmlH3                      htmlH2
HtmlHiLink htmlH4                      htmlH3
HtmlHiLink htmlH5                      htmlH4
HtmlHiLink htmlH6                      htmlH5
HtmlHiLink htmlHead                    PreProc
HtmlHiLink htmlTitle                   Title
HtmlHiLink htmlBoldItalicUnderline     htmlBoldUnderlineItalic
HtmlHiLink htmlUnderlineBold           htmlBoldUnderline
HtmlHiLink htmlUnderlineItalicBold     htmlBoldUnderlineItalic
HtmlHiLink htmlUnderlineBoldItalic     htmlBoldUnderlineItalic
HtmlHiLink htmlItalicUnderline         htmlUnderlineItalic
HtmlHiLink htmlItalicBold              htmlBoldItalic
HtmlHiLink htmlItalicBoldUnderline     htmlBoldUnderlineItalic
HtmlHiLink htmlItalicUnderlineBold     htmlBoldUnderlineItalic

HtmlHiLink htmlSpecial            Special
HtmlHiLink htmlSpecialChar        Special
HtmlHiLink htmlString             String
HtmlHiLink htmlStatement          Statement
HtmlHiLink htmlComment            Comment
HtmlHiLink htmlCommentPart        Comment
HtmlHiLink htmlValue              String
HtmlHiLink htmlCommentError       htmlError
HtmlHiLink htmlTagError           htmlError
HtmlHiLink htmlEvent              javaScript
HtmlHiLink htmlError              Error

HtmlHiLink htmlCssStyleComment    Comment
HtmlHiLink htmlCssDefinition      Special

" The default highlighting.
if version >= 508 || !exists("did_html_syn_inits")
  if version < 508
    let did_html_syn_inits = 1
  endif
  HtmlHiLink htmlTag                     Function
  HtmlHiLink htmlEndTag                  Identifier
  HtmlHiLink htmlArg                     Type
  HtmlHiLink htmlTagName                 htmlStatement
  HtmlHiLink htmlSpecialTagName          Exception
  HtmlHiLink htmlValue                     String
  HtmlHiLink htmlSpecialChar             Special

if !exists("html_no_rendering")
    HtmlHiLink htmlH1                      Title
    HtmlHiLink htmlH2                      htmlH1
    HtmlHiLink htmlH3                      htmlH2
    HtmlHiLink htmlH4                      htmlH3
    HtmlHiLink htmlH5                      htmlH4
    HtmlHiLink htmlH6                      htmlH5
    HtmlHiLink htmlHead                    PreProc
    HtmlHiLink htmlTitle                   Title
    HtmlHiLink htmlBoldItalicUnderline     htmlBoldUnderlineItalic
    HtmlHiLink htmlUnderlineBold           htmlBoldUnderline
    HtmlHiLink htmlUnderlineItalicBold     htmlBoldUnderlineItalic
    HtmlHiLink htmlUnderlineBoldItalic     htmlBoldUnderlineItalic
    HtmlHiLink htmlItalicUnderline         htmlUnderlineItalic
    HtmlHiLink htmlItalicBold              htmlBoldItalic
    HtmlHiLink htmlItalicBoldUnderline     htmlBoldUnderlineItalic
    HtmlHiLink htmlItalicUnderlineBold     htmlBoldUnderlineItalic
    HtmlHiLink htmlLink			   Underlined
  if !exists("html_my_rendering")
    hi def htmlBold                term=bold cterm=bold gui=bold
    hi def htmlBoldUnderline       term=bold,underline cterm=bold,underline gui=bold,underline
    hi def htmlBoldItalic          term=bold,italic cterm=bold,italic gui=bold,italic
    hi def htmlBoldUnderlineItalic term=bold,italic,underline cterm=bold,italic,underline gui=bold,italic,underline
    hi def htmlUnderline           term=underline cterm=underline gui=underline
    hi def htmlUnderlineItalic     term=italic,underline cterm=italic,underline gui=italic,underline
    hi def htmlItalic              term=italic cterm=italic gui=italic
  endif
endif

  HtmlHiLink htmlPreStmt            PreProc
  HtmlHiLink htmlPreError           Error
  HtmlHiLink htmlPreProc            PreProc
  HtmlHiLink htmlPreAttr            String
  HtmlHiLink htmlPreProcAttrName    PreProc
  HtmlHiLink htmlPreProcAttrError   Error
  HtmlHiLink htmlSpecial            Special
  HtmlHiLink htmlSpecialChar        Special
  HtmlHiLink htmlString             String
  HtmlHiLink htmlStatement          Statement
  HtmlHiLink htmlComment            Comment
  HtmlHiLink htmlCommentPart        Comment
  HtmlHiLink htmlValue              String
  HtmlHiLink htmlCommentError       htmlError
  HtmlHiLink htmlTagError           htmlError
  HtmlHiLink htmlEvent              javaScript
  HtmlHiLink htmlError              Error

  HtmlHiLink javaScript             Special
  HtmlHiLink javaScriptExpression   javaScript
  HtmlHiLink htmlCssStyleComment    Comment
  HtmlHiLink htmlCssDefinition      Special
endif

" wiki highlighting

HtmlHiLink wikiItalic		htmlItalic
HtmlHiLink wikiBold		htmlBold

HtmlHiLink wikiBoldItalic	htmlBoldItalic
HtmlHiLink wikiItalicBold	htmlBoldItalic

HtmlHiLink wikiBoldAndItalic	htmlBoldItalic

HtmlHiLink wikiH1		htmlH1
HtmlHiLink wikiH2		htmlH2
HtmlHiLink wikiH3		htmlH3
HtmlHiLink wikiH4		htmlH4
HtmlHiLink wikiH5		htmlH5
HtmlHiLink wikiH6		htmlH6
HtmlHiLink wikiLink		Underlined
HtmlHiLink wikiTemplate		Special
HtmlHiLink wikiParaFormatChar	Special
HtmlHiLink wikiPre		Constant
HtmlHiLink wikiRef		Comment


let b:current_syntax = "html"

delcommand HtmlHiLink

if main_syntax == 'html'
  unlet main_syntax
endif
