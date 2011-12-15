" Vim syntax file
" Language:	C
" Maintainer:	lilydjwg <lilydjwg@gmail.com>

"========================================================
" Highlight All Function
"========================================================
" syn match   cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
" syn match   cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
" hi link cFunction Function

runtime! syntax/gtk.vim
runtime! syntax/gdk.vim
runtime! syntax/gdkpixbuf.vim
runtime! syntax/gobject.vim
runtime! syntax/glib.vim
runtime! syntax/cairo.vim
