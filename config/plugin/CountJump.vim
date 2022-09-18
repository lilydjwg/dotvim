"   Regex in Javascript, etc
call CountJump#TextObject#MakeWithCountSearch('', '/', 'ai', 'v', '\\\@<!/', '\\\@<!/')
call CountJump#TextObject#MakeWithCountSearch('', ':', 'ai', 'v', '\\\@<!:', '\\\@<!:')
call CountJump#TextObject#MakeWithCountSearch('', '_', 'ai', 'v', '_', '_')
call CountJump#TextObject#MakeWithCountSearch('', '<Tab>', 'ai', 'v', '\t', '\t')


function! s:JumpCommaBegin(count, isInner)
  for _ in range(a:count)
    let pos = searchpos('\%([,([{<]\s*\)\@<=\S\@=', 'cbW')
    if pos == [0, 0]
      break
    endif
  endfor
  if a:isInner && pos != [0, 0]
    normal! h
    let pos[1] = pos[1] - 1
  endif
  return pos
endfunction

function! s:JumpCommaEnd(count, isInner)
  let flag = a:isInner ? 'W' : 'eW'
  let found = 1
  for _ in range(a:count)
    let pos = searchpos('\%(,\s*\)\|[])}>]\@=', flag)
    if pos == [0, 0]
      let found = 0
      break
    endif
  endfor
  if found && !a:isInner && getline('.')[col('.')-1] !~ ',\|\s\+'
    normal! h
    let pos[1] = pos[1] - 1
  endif
  return pos
endfunction

call CountJump#TextObject#MakeWithJumpFunctions('', ',', 'ai', 'v', function('s:JumpCommaBegin'), function('s:JumpCommaEnd'))
