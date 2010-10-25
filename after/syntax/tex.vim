" Vim syntax file
" FileType:    TeX
" Author:      lilydjwg
" Last Change: 2009年8月14日

syntax case match

" 在 MediaWiki 中，如果含有 \section 片断，不能让它吃掉 </code>
if &ft == 'wiki'
  syn region texSectionZone	matchgroup=texSection start='\\section\>'		 end='\ze\s*\\\%(section\>\|chapter\>\|part\>\|end\s*{\s*document\s*}\)\|\ze</code>'	fold contains=@texFoldGroup,@texSectionGroup,@Spell
endif
