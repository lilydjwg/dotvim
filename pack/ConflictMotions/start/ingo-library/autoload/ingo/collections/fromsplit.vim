" ingo/collections/fromsplit.vim: Functions to split a string and operate on the results.
"
" DEPENDENCIES:
"   - ingo/collections.vim autoload script
"   - ingo/list.vim autoload script
"
" Copyright: (C) 2016-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! ingo#collections#fromsplit#MapOne( isItems, expr, pattern, Expr2 )
"******************************************************************************
"* PURPOSE:
"   Split a:expr on a:pattern, then apply a:Expr2 over the List of items or
"   separators, depending on a:isItems, and return a List of [ item1,
"   delimiter1, item2, delimiter2, ...]
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isItems   Flag whether separators (0) or items (1) are to be mapped.
"   a:expr	Text to be split.
"   a:pattern	Regular expression that specifies the separator text that
"		delimits the items.
"   a:Expr2     String or Funcref argument to |map()|.
"* RETURN VALUES:
"   Single list of split items and separators interspersed.
"******************************************************************************
    let l:result = ingo#collections#SeparateItemsAndSeparators(a:expr, a:pattern, 1)
    call map(l:result[! a:isItems], a:Expr2)
    return ingo#list#Join(l:result[0], l:result[1])
endfunction
function! ingo#collections#fromsplit#MapItems( expr, pattern, Expr2 )
"******************************************************************************
"* PURPOSE:
"   Split a:expr on a:pattern, then apply a:Expr2 over the List of items (i.e.
"   the elements in between the a:pattern matches), and return a List of [
"   mapped-item1, delimiter1, mapped-item2, delimiter2, ...]
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr	Text to be split.
"   a:pattern	Regular expression that specifies the separator text that
"		delimits the items.
"   a:Expr2     String or Funcref argument to |map()|.
"* RETURN VALUES:
"   Single list of split items and separators interspersed.
"******************************************************************************
    return ingo#collections#fromsplit#MapOne(1, a:expr, a:pattern, a:Expr2)
endfunction
function! ingo#collections#fromsplit#MapSeparators( expr, pattern, Expr2 )
"******************************************************************************
"* PURPOSE:
"   Split a:expr on a:pattern, then apply a:Expr2 over the List of separators
"   (i.e. the a:pattern matches), and return a List of [ item1,
"   mapped-delimiter1, item2, mapped-delimiter2, ...]
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr	Text to be split.
"   a:pattern	Regular expression that specifies the separator text that
"		delimits the items.
"   a:Expr2     String or Funcref argument to |map()|.
"* RETURN VALUES:
"   Single list of split items and separators interspersed.
"******************************************************************************
    return ingo#collections#fromsplit#MapOne(0, a:expr, a:pattern, a:Expr2)
endfunction
function! ingo#collections#fromsplit#MapItemsAndSeparators( expr, pattern, ItemExpr2, SeparatorExpr2 )
"******************************************************************************
"* PURPOSE:
"   Split a:expr on a:pattern, then apply a:ItemExpr2 over the List of items
"   (i.e. the elements in between the a:pattern matches) and apply
"   a:SeparatorExpr2 over the List of separators (i.e. the a:pattern matches),
"   and return a List of [ mapped-item1, mapped-delimiter1, mapped-item2,
"   mapped-delimiter2, ...]
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:expr	Text to be split.
"   a:pattern	Regular expression that specifies the separator text that
"		delimits the items.
"   a:ItemExpr2         String or Funcref argument to |map()|.
"   a:SeparatorExpr2    String or Funcref argument to |map()|.
"* RETURN VALUES:
"   Single list of split items and separators interspersed.
"******************************************************************************
    let l:result = ingo#collections#SeparateItemsAndSeparators(a:expr, a:pattern, 1)
    call map(l:result[0], a:ItemExpr2)
    call map(l:result[1], a:SeparatorExpr2)
    return ingo#list#Join(l:result[0], l:result[1])
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
