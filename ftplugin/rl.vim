" Vim filetype plugin file
" Language:	radio list
" Maintainer:	lilydjwg <lilydjwg@gmail.com>
" Last Change:	2010年3月7日

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

function! Lilydjwg_rl_play()
  let url = Lilydjwg_get_pattern_at_cursor('\v\w+://(\w|-|\.|/|:)+')
  if url == ""
    echohl WarningMsg
    echomsg '在光标处未发现流媒体！'
    echohl None
  else
    echo '打开流媒体URL：' . url
    if !(has("win32") || has("win64"))
      call system("setsid mplayer -channels 2 '" . url . "' &")
    else
      echohl WarningMsg
      echo "Windows 平台未配置！"
      echohl NONE
    endif
  endif
endfunction

setlocal nowrap

nmap <buffer> <silent> K :echo system("killall mplayer")<CR>
nmap <buffer> <silent> M :call Lilydjwg_rl_play()<CR>

