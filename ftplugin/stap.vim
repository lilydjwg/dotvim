" Vim filetype plugin file
" Language:	SystemTap
" Maintainer:	SystemTap Developers <systemtap@sourceware.org>
" Last Change:	2011 Aug 4

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

set cpo-=C

let b:undo_ftplugin = "setl cin< fo< com<"

setlocal cindent

" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croql

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://,:#
