if did_filetype()	" filetype 已经设立..
  finish		" ..不需要这些检测
endif
if expand('%:t') =~? '^rfc\d\+'
  setfiletype rfc
  finish
endif
if expand('%:p') =~ '\vnginx.*(conf|sites).*'
  setfiletype nginx
  finish
endif
if expand('%:t') =~ '^\v\.?magic$'
  setfiletype magic
  finish
endif
if getline(1) =~ '^\(\S\+(\d)\).*\1$'
  setfiletype man
  finish
endif
if getline(1) =~ '^#!\s*/usr/bin/tcc\s\+-run'
  setfiletype c
  syn match cCommentL /^\%1l\#\!.*/
  finish
endif
if getline(1) =~ '^#!\s*/usr/bin/sage\s\+-python'
  setfiletype python
  finish
endif
