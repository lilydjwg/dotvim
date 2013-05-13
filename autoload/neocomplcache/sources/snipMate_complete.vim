scriptencoding utf-8
let s:source = {
      \ 'name' : 'snipMate_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()
  let s:snip_list = {}
endfunction

function! s:source.finalize()
endfunction

function! s:source.get_keyword_list(cur_keyword_str)
  let ft = neocomplcache#get_context_filetype()

  if has_key(s:snip_list, ft)
    return neocomplcache#keyword_filter(copy(s:snip_list[ft]), a:cur_keyword_str)
  end

  let snips = GetSnippetsList(ft)
  if empty(snips)
    return []
  endif

  let l:abbr_pattern = printf('%%.%ds..%%s', g:neocomplcache_max_keyword_width-10)
  let l:menu_pattern = '<S> %.'.g:neocomplcache_max_menu_width.'s'

  let list = []
  for trig in keys(snips)
    if type(snips[trig]) == type([])
      let s:triger = 'multi snips - ' . snips[trig][0][1]
    else
      let s:triger = snips[trig]
    endif

    let l:abbr = substitute(
      \ substitute(s:triger, '\n', '⏎', 'g'),
      \ '\s', ' ', 'g')
    let l:menu = printf(l:menu_pattern, trig)
    let list += [{'word' : trig, 'menu' : l:menu, 'abbr' : l:abbr}]
  endfor

  let s:snip_list[ft] = list
  return neocomplcache#keyword_filter(copy(list), a:cur_keyword_str)
endfunction

function! neocomplcache#sources#snipMate_complete#define()
  return s:source
endfunction

