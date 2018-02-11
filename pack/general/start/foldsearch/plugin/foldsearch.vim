" Name:    foldsearch.vim
" Version: 1.1.0
" Author:  Markus Braun <markus.braun@krawel.de>
" Summary: Vim plugin to fold away lines that don't match a pattern
" Licence: This program is free software: you can redistribute it and/or modify
"          it under the terms of the GNU General Public License as published by
"          the Free Software Foundation, either version 3 of the License, or
"          (at your option) any later version.
"
"          This program is distributed in the hope that it will be useful,
"          but WITHOUT ANY WARRANTY; without even the implied warranty of
"          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"          GNU General Public License for more details.
"
"          You should have received a copy of the GNU General Public License
"          along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" Section: Plugin header {{{1

" guard against multiple loads {{{2
if (exists("g:loaded_foldsearch") || &cp)
  finish
endi
let g:loaded_foldsearch = 1

" check for correct vim version {{{2
" matchadd() requires at least 7.1.40
if !(v:version > 701 || (v:version == 701 && has("patch040")))
  finish
endif

" define default "foldsearch_highlight" {{{2
if (!exists("g:foldsearch_highlight"))
  let g:foldsearch_highlight = 0
endif

" define default "foldsearch_disable_mappings" {{{2
if (!exists("g:foldsearch_disable_mappings"))
  let g:foldsearch_disable_mappings = 0
endif

" define default "foldsearch_debug" {{{2
if (!exists("g:foldsearch_debug"))
  let g:foldsearch_debug = 0
endif

" Section: Commands {{{1

command! -nargs=* -complete=command Fs call foldsearch#foldsearch#FoldSearch(<f-args>)
command! -nargs=* -complete=command Fw call foldsearch#foldsearch#FoldCword(<f-args>)
command! -nargs=1 Fp call foldsearch#foldsearch#FoldPattern(<q-args>)
command! -nargs=* -complete=command FS call foldsearch#foldsearch#FoldSpell(<f-args>)
command! -nargs=0 Fl call foldsearch#foldsearch#FoldLast()
command! -nargs=* Fc call foldsearch#foldsearch#FoldSearchContext(<f-args>)
command! -nargs=0 Fi call foldsearch#foldsearch#FoldContextAdd(+1)
command! -nargs=0 Fd call foldsearch#foldsearch#FoldContextAdd(-1)
command! -nargs=0 Fe call foldsearch#foldsearch#FoldSearchEnd()

" Section: Mappings {{{1

if !g:foldsearch_disable_mappings
   map <Leader>fs :call foldsearch#foldsearch#FoldSearch()<CR>
   map <Leader>fw :call foldsearch#foldsearch#FoldCword()<CR>
   map <Leader>fS :call foldsearch#foldsearch#FoldSpell()<CR>
   map <Leader>fl :call foldsearch#foldsearch#FoldLast()<CR>
   map <Leader>fi :call foldsearch#foldsearch#FoldContextAdd(+1)<CR>
   map <Leader>fd :call foldsearch#foldsearch#FoldContextAdd(-1)<CR>
   map <Leader>fe :call foldsearch#foldsearch#FoldSearchEnd()<CR>
endif

" Section: Menu {{{1

if has("menu")
  amenu <silent> Plugin.FoldSearch.Context.Increment\ One\ Line :Fi<CR>
  amenu <silent> Plugin.FoldSearch.Context.Decrement\ One\ Line :Fd<CR>
  amenu <silent> Plugin.FoldSearch.Context.Show :Fc<CR>
  amenu <silent> Plugin.FoldSearch.Search :Fs<CR>
  amenu <silent> Plugin.FoldSearch.Current\ Word :Fw<CR>
  amenu <silent> Plugin.FoldSearch.Pattern :Fp
  amenu <silent> Plugin.FoldSearch.Spelling :FS<CR>
  amenu <silent> Plugin.FoldSearch.Last :Fl<CR>
  amenu <silent> Plugin.FoldSearch.End :Fe<CR>
endif

" vim600: foldmethod=marker foldlevel=0 :
