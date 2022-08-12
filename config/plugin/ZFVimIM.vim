function! s:dbInit()
  let topPath = expand('<script>:p:h:h:h') . '/data'
  let dbFile = 'wubi.txt'
  let dbCountFile = 'wubi_count.txt'

  let db = ZFVimIM_dbInit({
        \   'name': '五笔',
        \ })
  call ZFVimIM_cloudRegister({
        \   'mode': 'local',
        \   'dbId': db['dbId'],
        \   'repoPath': topPath,
        \   'dbFile': dbFile,
        \   'dbCountFile': dbCountFile,
        \ })
endfunction

augroup ZFVimIM_wubi_augroup
  autocmd!
  autocmd User ZFVimIM_event_OnDbInit call s:dbInit()
augroup END

function! s:on_enable()
  let s:completeopt = &completeopt
  NeoCompleteDisable
  set completeopt&
endfunction

function! s:on_disable()
  NeoCompleteEnable
  let &completeopt = s:completeopt
endfunction

function! s:enable()
  packadd ZFVimIM
  packadd ZFVimJob

  augroup ZFVimIM_autoDisable_augroup
    autocmd!
    autocmd User ZFVimIM_event_OnEnable call s:on_enable()
    autocmd User ZFVimIM_event_OnDisable call s:on_disable()
  augroup END

  let g:ZFVimIM_cachePath = expand('~/.cache')
  doautocmd ZFVimIM_cloud_async_augroup VimEnter
endfunction

command! ZFVimIMEnable call s:enable()
