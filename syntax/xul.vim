" Vim synatx file
" Language:     XUL
" Version:	0.35
" Maintainer:   Miguel Rodriguez <lmrodriguezr@unal.edu.co>
" 		Based on xul.vim v0.5 from
" 		Nikolai Nespor <nikolai.nespor@utanet.at>	
" ChangeLog:	Miguel's version new features:
"		- Adds events as an special attribute
"		- JavaScript's Syntax for event's values and
"		code into <script> tag.
"		- A lot of new XUL-Keywords and ATTs
"		- Shows attributes syntax by default
"		- Special Attribute xulDev created for debug
" Bugs:		- 2 bugs! at XUL-Script :(
" URL:          http://bioinf.ibun.unal.edu.co/~miguel/scripts/xul.vim
" 		Nikolai's script:
" 		http://www.unet.univie.ac.at/~a9600989/vim/xul.vim (not longer exists)
" Last Change:  2007 06 28 (Miguel's last change)
" 		2005 02 22 (Nikolai's last change)
" Remarks:      Adds XUL-Highlighting (based on docbk.vim)
"               If you DON'T want XUL-Attribute-Highlighting (only common
"               attributes are highlighted) put a line like this:
"               
"               let nohl_xul_atts = 1
"
"               If you don't want to be forced to close the script tag with
"               </script> (which have a bug), put a line like this:
"
"               let xul_noclose_script = 1
"
"               in your $HOME/.vimrc file.
"
"


" Backward compatibility
"
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" set filetype to xml (xml highlighting for free ;-)
" 
doau FileType xml

" don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ XulHiLink hi link <args>
else
  command! -nargs=+ XulHiLink hi def link <args>
endif

" syntax-matching is case-sensitive
"
syn case match

" add XUL-Keywords to XML-Tags
" 
syn cluster xmlTagHook add=xulKW

" XUL-Script
" 
syn cluster xmlRegionHook add=xulScript
if !exists("g:xul_noclose_script")
   syn region xulScript start=+<script[^>]*>+ keepend end=+</script>+me=s-1 contains=openScriptTag,@xulJavaScript,scriptTag
else
   syn region xulScript start=+<script[^/>]*>+ keepend end=+</script>+me=s-1 contains=openScriptTag,@xulJavaScript,scriptTag
endif
syn match openScriptTag "<" contained
" Bug: When one types </script> inside script (into an String, for
" instance) it matches and closes the script, but xul won't close it.  Ideas?
" Bug: When one types / inside script it doesn't play the script game (with
" js).  Solution would be remove / from <script[^/>]*>, but then the script
" tag without closer tag (finished in />) is highlighted as a js container and
" crashes everything from then on. (only if xul_close_script is set).
syn region scriptTag start=+<script+lc=1 end=+>+ contained contains=xmlError,xmlTagName,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook
XulHiLink scriptTag xmlTag
XulHiLink openScriptTag xmlTag
XulHiLink xulScript Special

" if attribute highlighting is NOT disabled
"
if !exists("g:nohl_xul_atts")
  
  " Add Attributes and Events
  syn cluster xmlAttribHook add=xulAT,xulDev
  syn cluster xmlStartTagHook add=xulEvent
  syn region xulScriptIn start=+\s*=\s*"+ skip=+\\"+ end=+"+ contained contains=@xulJavaScriptIn,xulJavaScriptStringSQ
  syn region xulScriptIn start=+\s*=\s*'+ skip=+\\'+ end=+'+ contained contains=@xulJavaScriptIn,xulJavaScriptStringDQ
  syn region xulJavaScriptStringDQ start=+"+ skip=+\\"+ end=+"+ contained
  syn region xulJavaScriptStringDQ start=+\\'+ end=+\\'+ contained
  syn region xulJavaScriptStringSQ start=+'+ skip=+\\'+ end=+'+ contained
  syn region xulJavaScriptStringSQ start=+\\"+ end=+\\"+ contained
  XulHiLink xulJavaScriptStringSQ String
  XulHiLink xulJavaScriptStringDQ String

endif

" set a javascript cluster special for xulScriptIn, Warning: it doesn't
" contain all the elements in javascript.vim
syn cluster xulJavaScriptIn add=javaScriptCommentTodo,javaScriptLineComment,javaScriptCommentSkip,javaScriptComment,javaScriptSpecial
syn cluster xulJavaScriptIn add=javaScriptSpecialCharacter,javaScriptNumber,javaScriptRegexpString
syn cluster xulJavaScriptIn add=javaScriptConditional,javaScriptRepeat,javaScriptBranch,javaScriptOperator
syn cluster xulJavaScriptIn add=javaScriptType,javaScriptStatement,javaScriptBoolean,javaScriptNull,javaScriptIdentifier
syn cluster xulJavaScriptIn add=javaScriptLabel,javaScriptException,javaScriptMessage,javaScriptGlobal,javaScriptMember
syn cluster xulJavaScriptIn add=javaScriptDeprecated,javaScriptReserved


unlet b:current_syntax
if version < 600
  syn include @xulJavaScript <sfile>:p:h/javascript.vim
else
  syn include @xulJavaScript syntax/javascript.vim
endif
unlet b:current_syntax


" XUL-Keywords
" 
"
syn keyword xulKW action arrowscrollbox bbox binding contained
syn keyword xulKW bindings box broadcaster broadcasterset contained
syn keyword xulKW browser button caption checkbox contained
syn keyword xulKW colorpicker column columns command contained
syn keyword xulKW commandset conditions content deck description contained
syn keyword xulKW dialog dialogheader editor grid grippy groupbox contained
syn keyword xulKW hbox iframe image key keyset label contained
syn keyword xulKW listbox listcell listcol listcols listhead contained
syn keyword xulKW listheader listitem member menu menubar contained
syn keyword xulKW menuitem menulist menupopup menuseparator observes contained
syn keyword xulKW overlay page popup popupset progressmeter radio contained
syn keyword xulKW radiogroup resizer row rows rule contained
syn keyword xulKW script scrollbar scrollbox contained
syn keyword xulKW separator spacer splitter stack contained
syn keyword xulKW statusbar statusbarpanel stringbundle contained
syn keyword xulKW stringbundleset tab tabbrowser tabbox tabpanel contained
syn keyword xulKW tabpanels tabs template textnode textbox contained
syn keyword xulKW titlebar toolbar toolbarbutton toolbargrippy contained
syn keyword xulKW toolbaritem toolbarpalette toolbarseparator contained
syn keyword xulKW toolbarset toolbarspacer toolbarspring toolbox contained
syn keyword xulKW tooltip tree treecell treechildren treecol treecols contained
syn keyword xulKW treeitem treerow treeseparator triple vbox window contained
syn keyword xulKW wizard wizardpage contained

" XUL-Attributes
"
syn keyword xulAT contained acceltext accessible accesskey afterselected align allowevents allownegativassertions
syn keyword xulAT contained alternatingbackground alwaysopenpopup attribute autocheck autoCheck
syn keyword xulAT contained autocompleteenabled autocompletepopup autocompletesearch autocompletesearchparam
syn keyword xulAT contained autoFill autoFillAfterMatch autoscroll beforeselected buttonaccesskeyaccept
syn keyword xulAT contained buttonaccesskeycancel buttonaccesskeydisclosure buttonaccesskeyextra1 buttonaccesskeyextra2
syn keyword xulAT contained buttonaccesskeyhelp buttonalign buttondir buttonlabelaccept buttonlabelcancel
syn keyword xulAT contained buttonlabeldisclosure buttonlabelextra1 buttonlabelextra2 buttonlabelhelp buttonorient
syn keyword xulAT contained buttonpack buttons checked checkState
syn keyword xulAT contained class closebutton coalesceduplicatearcs collapse collapsed color cols command commandupdater
syn keyword xulAT contained completedefaultindex container
syn keyword xulAT contained containment contentcontextmenu contenttooltip context contextmenu control crop curpos current
syn keyword xulAT contained currentset customindex customizable cycler datasources default defaultButton defaultset description
syn keyword xulAT contained dir disableAutocomplete disableautocomplete disableautoselect disableclose disabled disablehistory
syn keyword xulAT contained disableKeyNavigation disablekeynavigation disablesecurity dlgType dragging editable editortype
syn keyword xulAT contained element empty enableColumnDrag enablehistory equalsize eventnode events firstpage first-tab
syn keyword xulAT contained fixed flags flex focused forceComplete forcecomplete grippyhidden grippytooltiptext group
syn keyword xulAT contained handleCtrlPageUpDown handleCtrlTab  height helpURI hidden hidechrome hidecolumnpicker hideheader
syn keyword xulAT contained homepage icon id ignoreBlurWhileSearching ignoreblurwhilesearching ignorecolumnpicker ignorekeys
syn keyword xulAT contained image increment inputtooltiptext insertafter insertbefore instantApply inverted iscontainer
syn keyword xulAT contained isempty key keycode keytext label lastpage lastSelected last-tab left linkedpanel maxheight
syn keyword xulAT contained maxlength maxpos maxrows maxwidth member menu menuactive minheight minResultsForPopup
syn keyword xulAT contained minresultsforpopup minwidth mode modifiers mousethrough multiline name next noautohide nomatch
syn keyword xulAT contained observes open ordinal orient pack pageid pageincrement pagestep parent parsetype persist phase
syn keyword xulAT contained pickertooltiptext popup position preference preference-editable primary properties readonly
syn keyword xulAT contained ref removeelement resizeafter resizebefore rows screenX screenY searchSessions selected
syn keyword xulAT contained selectedIndex seltype setfocus showCommentColumn showcommentcolumn showpopup size sizemode
syn keyword xulAT contained sizetopopup sort sortActive sortDirection sortResource
syn keyword xulAT contained sortResource2 src state statedatasource statusbar statustext style substate suppressonselect tabindex
syn keyword xulAT contained tabScrolling tabscrolling targets template timeout title toolbarname tooltip
syn keyword xulAT contained tooltiptext top type uri userAction validate value wait-cursor width windowtype wrap
syn keyword xulDev contained debug

" XUL-Events
"
" on* events
syn match xulEvent /on\w\w*/ contained nextgroup=xulScriptIn
" other events
syn keyword xulEvent CheckboxStateChange DOMAttrModified DOMMenuItemActive DOMMenuItemInactive contained nextgroup=xulScriptIn
syn keyword xulEvent DOMMouseScroll DOMNodeInserted DOMNodeRemoved RadioStateChange contained nextgroup=xulScriptIn

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_xul_syn_inits")
  if version < 508
    let did_xul_syn_inits = 1
    command -nargs=+ XulHiLink hi link <args>
  else
    command! -nargs=+ XulHiLink hi def link <args>
  endif
  
  XulHiLink xulKW Statement
  XulHiLink xulAT Function
  XulHiLink xulDev String
  XulHiLink xulEvent javaScript
  XulHiLink xulScriptIn javaScript
  XulHiLink javaScript Special

  
  delcommand XulHiLink
endif

" finally set syntax
"
let b:current_syntax = "xul"

" vim: ts=8
