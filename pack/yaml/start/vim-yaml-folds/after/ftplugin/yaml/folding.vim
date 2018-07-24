function! YamlFolds()
  let previous_level = indent(prevnonblank(v:lnum - 1)) / &shiftwidth
  let current_level = indent(v:lnum) / &shiftwidth
  let next_level = indent(nextnonblank(v:lnum + 1)) / &shiftwidth

  if getline(v:lnum + 1) =~ '^\s*$'
    return "="

  elseif current_level < next_level
    return next_level

  elseif current_level > next_level
    return ('s' . (current_level - next_level))

  elseif current_level == previous_level
    return "="

  endif

  return next_level
endfunction

function! YamlFoldText()
  let lines = v:foldend - v:foldstart
  return getline(v:foldstart) . '   (level ' . v:foldlevel . ', lines ' . lines . ')'
endfunction


setlocal foldmethod=expr
setlocal foldexpr=YamlFolds()
setlocal foldtext=YamlFoldText()

let b:undo_ftplugin =
      \ exists('b:undo_ftplugin')
        \  ? b:undo_ftplugin . ' | '
        \ : ''
      \ . 'setlocal foldexpr< foldmethod< foldtext<'
