scriptencoding utf-8
" ========================================================================
" 依云(lilydjwg) 的 vimrc
" 我的博客： http://lilydjwg.is-programmer.com/
"
" 整个适用于本人 *Only*
" 不过，其中的部分配置很可能非常适合你哦～～
" 不要整个地照搬，只“抄袭”对你自己有用的部分！
"
" 有任何意见和建议，或者其它想说的，可以到我的博客留言。
"
" 许可：GFDL
" ========================================================================
" 其他文件[[[1
try
  source $VIMRUNTIME/vimrc_example.vim
catch
endtry
runtime macros/matchit.vim
"]]]
" 我的设置
" 函数[[[1
"   检查当前目录附近是否有 tags 文件[[[2
function Lilydjwg_checktags(file)
  let path = fnamemodify(a:file, ':p:h')
  while path != '/' && path !~ '^[[:alpha:]]:[\\/]$'
    if filereadable(path.'/tags')
      let &l:tags = path.'/tags'
      break
    endif
    let path = fnamemodify(path, ':h')
  endwhile
endfunction
"   切换显示行号/相对行号/不显示 [[[2
function Lilydjwg_toggle_number()
  if &nu
    setl rnu
  elseif &rnu
    setl nornu
  else
    setl nu
  endif
endfunction
"   更改缩进[[[2
function Lilydjwg_reindent(...)
  if a:0 != 2
    echoerr "需要两个参数"
  endif
  let save_et = &et
  let save_ts = &ts
  try
    let &ts = a:1
    set noet
    retab!
    let &ts = a:2
    set et
    retab!
  finally
    let &et = save_et
    let &ts = save_ts
  endtry
endfunction
"   将当前窗口置于屏幕中间（全屏时用）[[[2
function CenterFull()
  on
  vs
  ene
  setl nocul
  setl nonu
  40winc |
  winc l
  vs
  winc l
  ene
  setl nocul
  setl nonu
  40winc |
  winc h
  redr!
endfunction
" 使用 colorpicker 程序获取颜色值(hex/rgba)[[[2
function Lilydjwg_colorpicker()
  if exists("g:last_color")
    let color = substitute(system("colorpicker ".shellescape(g:last_color)), '\n', '', '')
  else
    let color = substitute(system("colorpicker"), '\n', '', '')
  endif
  if v:shell_error == 1
    return ''
  elseif v:shell_error == 2
    " g:last_color 值不对
    unlet g:last_color
    return Lilydjwg_colorpicker()
  else
    let g:last_color = color
    return color
  endif
endfunction
" 更改光标下的颜色值(hex/rgba/rgb)[[[2
function Lilydjwg_changeColor()
  let color = Lilydjwg_get_pattern_at_cursor('\v\#[[:xdigit:]]{6}(\D|$)@=|<rgba\((\d{1,3},\s*){3}[.0-9]+\)|<rgb\((\d{1,3},\s*){2}\d{1,3}\)')
  if color == ""
    echohl WarningMsg
    echo "No color string found."
    echohl NONE
    return
  endif
  let g:last_color = color
  call Lilydjwg_colorpicker()
  exe 'normal eF'.color[0]
  call setline('.', substitute(getline('.'), '\%'.col('.').'c\V'.color, g:last_color, ''))
endfunction
" Locate and return character "above" current cursor position[[[2
function LookFurther(down)
  "来源 http://www.ibm.com/developerworks/cn/linux/l-vim-script-1/，有修改
  "Locate current column and preceding line from which to copy
  let column_num      = virtcol('.')
  let target_pattern  = '\%' . column_num . 'v.'
  let target_pattern_1  = '\%' . (column_num+1) . 'v.'

  " FIXed 当光标位于如下 | 所示位置时，将取得错误的虚拟列号
  "          /中文
  "          |中文
  " 光标下的字符是多字节的？
  " echo '['.matchstr(getline('.'), target_pattern).']'
  if matchstr(getline('.'), target_pattern) == '' &&
	\ matchstr(getline('.'), target_pattern_1) != ''
    let column_num -= 1
    " 上面的字符可能是英文（前者）或者中文（后者）的
    let target_pattern  = '\%' . column_num . 'v.\|' . target_pattern
  endif
  if a:down
    let target_line_num = search(target_pattern, 'nW')
  else
    let target_line_num = search(target_pattern, 'bnW')
  endif

  "If target line found, return vertically copied character
  if !target_line_num
    return ""
  else
    return matchstr(getline(target_line_num), target_pattern)
  endif
endfunction
inoremap <silent> <C-Y> <C-R><C-R>=LookFurther(0)<CR>
inoremap <silent> <M-y> <C-R><C-R>=LookFurther(1)<CR>
" 对齐 xxx: xxx （两栏） [[[2
function Lilydjwg_AP() range
  if getline('.') =~ '^\s'
    let pat = "wll:p0P0"
  else
    let pat = "wl:p0P0"
  endif
  call Align#AlignPush()
  call Align#AlignCtrl(pat)
  exe a:firstline.','.a:lastline."call Align#Align(0, '\\s\\S')"
  call Align#AlignPop()
  exe a:firstline.','.a:lastline.'s/^\ze\s/ /ge'
  nohls
endfunction
"  退格删除自动缩进 [[[2
function! Lilydjwg_checklist_bs(pat)
  " 退格可清除自动出来的列表符号
  if getline('.') =~ a:pat
    let ind = indent(line('.')-1)
    if !ind
      let ind = indent(line('.')+1)
    endif
    call setline(line('.'), repeat(' ', ind))
    return ""
  else
    return "\<BS>"
  endif
endfunction
"   字典补全 <C-X><C-K> 与 <C-K>[[[2
function Lilydjwg_dictcomplete()
  if pumvisible()
    return "\<C-K>"
  else
    return "\<C-X>\<C-K>"
  endif
endfunction
"   自动加执行权限[[[2
function Lilydjwg_chmodx()
  if strpart(getline(1), 0, 2) == '#!'
    let f = expand("%:p")
    if stridx(getfperm(f), 'x') != 2
      call system("chmod +x ".shellescape(f))
      " 重新载入，FIXME 不会重新检测文件类型
      edit!
      syntax on
    endif
  endif
endfunction
"   返回当前日期的中文表示[[[2
function Lilydjwg_zh_date()
  let d = strftime("%Y年%m月%d日")
  let d = substitute(d, '[年月]\@<=0', '', 'g')
  return d
endfunction
"   关闭某个窗口[[[2
function Lilydjwg_close(winnr)
  let winnum = bufwinnr(a:winnr)
  if winnum == -1
    return 0
  endif
  " Goto the workspace window, close it and then come back to the
  " original window
  let curbufnr = bufnr('%')
  exe winnum . 'wincmd w'
  close
  " Need to jump back to the original window only if we are not
  " already in that window
  let winnum = bufwinnr(curbufnr)
  if winnr() != winnum
    exe winnum . 'wincmd w'
  endif
  return 1
endfunction
"  补全 So 命令[[[2
function Lilydjwg_complete_So(ArgLead, CmdLine, CursorPos)
  let path = 'so/' . a:ArgLead . '*'
  let ret = split(globpath(&rtp, path), '\n')
  call filter(ret, 'v:val =~ "\.vim$"')
  " XXX 如果文件名特殊则可能不对
  call map(ret, 'fnamemodify(v:val, '':t:r'')')
  return ret
endfunction
"  取得光标处的匹配[[[2
function Lilydjwg_get_pattern_at_cursor(pat)
  let col = col('.') - 1
  let line = getline('.')
  let ebeg = -1
  let cont = match(line, a:pat, 0)
  while (ebeg >= 0 || (0 <= cont) && (cont <= col))
    let contn = matchend(line, a:pat, cont)
    if (cont <= col) && (col < contn)
      let ebeg = match(line, a:pat, cont)
      let elen = contn - ebeg
      break
    else
      let cont = match(line, a:pat, contn)
    endif
  endwhile
  if ebeg >= 0
    return strpart(line, ebeg, elen)
  else
    return ""
  endif
endfunction
"   切换配色方案[[[2
function Lilydjwg_toggle_color()
  let colors = ['pink_lily', 'lilypink', 'darkBlue', 'spring2']
  " spring2 是增加了彩色终端支持的 spring
  if !exists("g:colors_name")
    let g:colors_name = 'pink_lily'
  endif
  let i = index(colors, g:colors_name)
  let i = (i+1) % len(colors)
  exe 'colorscheme ' . get(colors, i)
endfunction
" 打开 snippets 文件[[[2
function Lilydjwg_snippets(ft)
  if a:ft == ''
    exe 'tabe '.g:snippets_dir.&ft.'.snippets'
  else
    exe 'tabe '.g:snippets_dir.a:ft.'.snippets'
  endif
endfunction
"   %xx -> 对应的字符(到消息)[[[2
function Lilydjwg_hexchar()
  let chars = Lilydjwg_get_pattern_at_cursor('\(%[[:xdigit:]]\{2}\)\+')
  if chars == ''
    echohl WarningMsg
    echo '在光标处未发现%表示的十六进制字符串！'
    echohl None
    return
  endif
  let str = substitute(chars, '%', '\\x', 'g')
  exe 'py print ''' . str . ''''
endfunction
"   字符 -> %xx，取代当前选区 [[[2
function Lilydjwg_strhex(str)
  python << EOF
import vim
s = vim.eval('a:str')
l = ''
for i in s:
  l += '%' + hex(ord(i))[2:].rjust(2, '0')
vim.command("let ret = '"+l+"'")
EOF
  exe 'normal gvs' . ret
endfunction
"  用火狐打开链接[[[2
function Lilydjwg_open_url()
  let s:url = Lilydjwg_get_pattern_at_cursor('\v(https?://|ftp://|file:/{3}|www\.)(\w|[.-])+(:\d+)?(/(\w|[~@#$%^&+=/.?:-])+)?')
  if s:url == ""
    echohl WarningMsg
    echomsg '在光标处未发现URL！'
    echohl None
  else
    echo '打开URL：' . s:url
    if !(has("win32") || has("win64"))
      " call system("gnome-open " . s:url)
      call system("setsid firefox '" . s:url . "' &")
    else
      " start 不是程序，所以无效。并且，cmd 只能使用双引号
      " call system("start '" . s:url . "'")
      call system("cmd /q /c start \"" . s:url . "\"")
    endif
  endif
  unlet s:url
endfunction
"  Title Save [[[2
function Lilydjwg_TSave()
  let line = getline(1)
  if line =~ '^\s*$'
    let line = getline(2)
  endif
  let line = substitute(line, '[:/\\]', '-', 'g')
  let line = substitute(line, '^\s\+', '', 'g')
  let line = substitute(line, '\s\+$', '', 'g')
  let line = substitute(line, ' ', '\\ ', 'g')
  let line = substitute(line, '\r', '', 'g')
  exe 'sav ' . line . '.txt'
endfunction
"  切换 ve [[[2
function Lilydjwg_toggle_ve()
  if &ve == 'all'
    let &ve = ''
  else
    let &ve = 'all'
  endif
endfunction
"  切换 ambiwidth [[[2
function Lilydjwg_toggle_ambiwidth()
  if &ambiwidth == 'double'
    let &ambiwidth = 'single'
  else
    let &ambiwidth = 'double'
  endif
endfunction
"  打开日记文件 [[[2
function Lilydjwg_edit_diary()
  if exists("g:my_diary_file") && filewritable(expand(g:my_diary_file))
    exe 'e '.g:my_diary_file
    normal gg
  else
    echoerr "Diary not set or not exists!"
  endif
endfunction
"  重新载入 mark.vim 的高亮 [[[2
"     因为 .gvimrc、启动命令等 在脚本之后执行，而配色方案文件会清除高亮
function Lilydjwg_remark()
  highlight def MarkWord1  ctermbg=Cyan     ctermfg=Black  guibg=#8CCBEA    guifg=Black
  highlight def MarkWord2  ctermbg=Green    ctermfg=Black  guibg=#A4E57E    guifg=Black
  highlight def MarkWord3  ctermbg=Yellow   ctermfg=Black  guibg=#FFDB72    guifg=Black
  highlight def MarkWord4  ctermbg=Red      ctermfg=Black  guibg=#FF7272    guifg=Black
  highlight def MarkWord5  ctermbg=Magenta  ctermfg=Black  guibg=#FFB3FF    guifg=Black
  highlight def MarkWord6  ctermbg=Blue     ctermfg=Black  guibg=#9999FF    guifg=Black
endfunction
if exists("*strwidth")
  function Strwidth(s)
    return strwidth(a:s)
  endfunction
else
  function Strwidth(s)
    return len(a:s)
  endfunction
endif
" set 相关[[[1
"   一般设置[[[2
" set guifont=文泉驿等宽正黑\ Medium\ 10
set softtabstop=2
set viminfo='100,:10000,<50,s10,h
set history=10000
set wildmenu
set delcombine " 组合字符一个个地删除
set laststatus=2 " 总是显示状态栏
" 首先尝试最长的，接着轮换补全项
set wildmode=longest:full,full
set ambiwidth=double
set diffopt+=vertical,context:3,foldcolumn:0
set fileencodings=ucs-bom,utf-8,gb18030,cp936,latin1
set fileformats=unix,dos,mac
set formatoptions=croqn2mM1
" set guioptions=egmrLtai
set guioptions=acit
if v:lang =~ '^zh'
  set helplang=cn
endif
set keywordprg=:help
set mousemodel=popup
" 没必要，而且很多时候 = 表示赋值
set isfname-==
set nolinebreak
set nowrapscan
set scrolloff=5
set sessionoptions=blank,buffers,curdir,folds,help,options,tabpages,winsize,slash,unix,resize
set shiftwidth=2
set winaltkeys=no
set noequalalways
set listchars=eol:$,tab:>-,nbsp:~
set display=lastline
set completeopt+=longest
set maxcombine=4
set cedit=<C-Y>
set whichwrap=b,s,[,]
" Avoid command-line redraw on every entered character by turning off Arabic
" shaping (which is implemented poorly).
if has('arabic')
  set noarabicshape
endif
" Linux 与 Windows [[[2
if has("win32") || has("win64")
  let g:LustyExplorerSuppressRubyWarning = 1
  " Win 路径 [[[3
  let g:VEConf_favorite = expand("$VIM/vimfiles/ve_favorite")
  let g:NERDTreeBookmarksFile = expand("$VIM/vimfiles/NERDTreeBookmarks")
  let g:undodir = expand("$TMP/vimundo")
  let g:vimfiles = expand("$VIM/vimfiles")
  let g:dictfilePrefix = expand('$VIM/vimfiles/dict/')
  set errorfile=$TMP/error
  " Win 程序 [[[3
  "   用默认的程序打开文件
  nmap <C-S-F5> :!"%"<CR>
  command Hex silent !winhex '%'
  command SHELL silent cd %:p:h|silent exe "!start cmd"|silent cd -
  command Nautilus silent !explorer %:p:h
  " Win 配置 [[[3
  command FScreen simalt ~x
  command Fscreen simalt ~r
else
  " Linux 路径 [[[3
  let g:VEConf_favorite = expand("~/.vim/ve_favorite")
  let g:NERDTreeBookmarksFile = expand("~/.vim/NERDTreeBookmarks")
  let g:undodir = expand("~/tmpfs/.vimundo")
  let g:vimfiles = expand("~/.vim")
  let g:dictfilePrefix = expand('~/.vim/dict/')
  set errorfile=~/tmpfs/error
  let my_diary_file = expand('~/private/diary/2011.rj')
  cmap <C-T> ~/tmpfs/
  " cron 的目录不要备份
  set backupskip+=/etc/cron.*/*
  " Linux 程序 [[[3
  "   用默认的程序打开文件
  "   FIXME xdg-open 的配置在哪里？为什么不用浏览器打开 HTML 文件呢？
  nmap <C-S-F5> :!gnome-open "%"<CR>
  set grepprg=grep\ -nH\ $*
  command Hex silent !setsid ghex2 '%'
  command SHELL silent cd %:p:h|silent exe '!setsid gnome-terminal'|silent cd -
  command Nautilus silent !nautilus %:p:h
  autocmd BufWritePost    * call Lilydjwg_chmodx()
  " Linux 配置 [[[3
  command FScreen winpos 0 0|set lines=40|set columns=172
  command Fscreen set lines=40|set columns=88
endif
" 状态栏：先设置好编码。不然乱码 [[[3
" 缓冲区号 文件名 行数 修改 帮助 只读 编码 换行符 BOM ======== 字符编码 位置 
" 百分比位置
set statusline=%n\ %<%f\ %L行\ %{&modified?'[+]':&modifiable\|\|&ft=~'^\\vhelp\|qf$'?'':'[-]'}%h%r%{&fenc=='utf-8'\|\|&fenc==''?'':'['.&fenc.']'}%{&ff=='unix'?'':'['.&ff.']'}%{&bomb?'[BOM]':''}%{&eol?'':'[noeol]'}%=\ 0x%-4.4B\ \ \ \ %-14.(%l,%c%V%)\ %P
" 图形与终端 [[[2
if has("gui_running")
  " 有些终端不能改变大小
  set columns=88
  set lines=38
  set number
  set cursorline
  colorscheme pink_lily
else
  " 防止退出时终端乱码
  " 这里两者都需要。只前者标题会重复，只后者会乱码
  set t_fs=(B
  set t_IE=(B
  if &term =~ "256color"
    " 在不同模式下使用不同颜色的光标
    set cursorline
    colorscheme pink_lily
    if &term =~ "xterm"
      silent !echo -ne "\e]12;HotPink\007"
      let &t_SI="\e]12;RoyalBlue1\007"
      let &t_EI="\e]12;HotPink\007"
      autocmd VimLeave * :!echo -ne "\e]12;green\007"
    endif
  else
    " 暂时只有这个配色比较适合了
    colorscheme default
    " 在终端下自动加载vimim输入法
    runtime so/vimim.vim
    " 在Linux文本终端下非插入模式显示块状光标
    if &term == "linux"
       set t_ve+=[?6c
       autocmd InsertEnter * set t_ve-=[?6c
       autocmd InsertLeave * set t_ve+=[?6c
       autocmd VimLeave * set t_ve-=[?6c
    endif
  endif
endif
" 不同的 Vim 版本 [[[2
if has("conceal")
  set concealcursor=nc
endif
if has("persistent_undo")
  let &undodir=g:undodir
  if !isdirectory(&undodir)
    call mkdir(&undodir)
  endif
  set undofile
endif
unlet g:undodir
" map 相关[[[1
"   nmap [[[2
"     Fx 相关 [[[3
nmap <F2> <Leader>be
nmap <F4> :ls<CR>:buffer 
nmap <F6> :cnext<CR>
nmap <S-F6> :cprevious<CR>
nmap <silent> <F9> :enew<CR>
nmap <silent> <F8> :GundoToggle<CR>
nmap <F11> :next<CR>
nmap <S-F11> :previous<CR>
nmap <S-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
"     重新载入当前文件
nmap <F5> :e!<CR>
"     t 开头 [[[3
nmap <silent> tt :tabnew<CR>
nmap t= mxHmygg=G`yzt`x
nmap t{ A{{{1<ESC>
nmap ta ggVG
nmap <silent> tf :call Lilydjwg_open_url()<CR>
"     清除高亮
nmap <silent> th :nohls<CR>
nmap tj Jx
nmap tl ^v$h
nmap <silent> to :call append('.', '')<CR>j
nmap <silent> tO :call append(line('.')-1, '')<CR>k
nmap tp "+P
nmap <silent> tv :call Lilydjwg_toggle_ve()<CR>
nmap tw :call Lilydjwg_toggle_ambiwidth()<CR>
"     w 开头 [[[3
nmap wc :set cursorline!<CR>
nmap wd :diffsplit 
nmap wf :NERDTreeToggle<CR>
nmap <silent> wn :call Lilydjwg_toggle_number()<CR>
nnoremap <silent> wt :TlistToggle<CR>
"     - 开头 [[[3
nmap -+ :set nomodified<CR>
nmap -c :call Lilydjwg_toggle_color()<CR>
nmap -ft :exe 'tabe '.g:vimfiles.'/ftplugin/'.&ft.'.vim'<CR>
nmap -syn :exe 'tabe '.g:vimfiles.'/syntax/'.&ft.'.vim'<CR>
nmap -int :exe 'tabe '.g:vimfiles.'/indent/'.&ft.'.vim'<CR>
"     显示高亮组 [[[4
nnoremap wh :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
"     Alt 组合键 [[[3
nmap <M-m> :MRU 
nmap <silent> <M-f> :echo expand('%:p')<CR>
" 打开草稿
nmap <unique> <silent> <M-s> <Plug>ShowScratchBuffer
"     lusty-explorer [[[4
nmap <M-b> :LustyBufferExplorer<CR>
nmap <M-g> :LustyBufferGrep<CR>
nmap <M-l> :LustyFilesystemExplorerFromHere<CR>
"     其它开头的 [[[3
nmap <silent> <C-Tab> :tabnew<CR>
nmap <BS> <C-O>
nmap <C-D> <C-W>q
nnoremap <Space> za
nmap ' <C-W>
nmap Y y$
nmap 'm :MarksBrowser<CR>
nmap :: :!
nmap cd :silent lcd %:p:h<CR>:echo expand('%:p:h')<CR>
nmap gb :setl fenc=gb18030<CR>
nmap z<Space> i <ESC>
nmap d<CR> :%s/\r//eg<CR>``
nmap cac :call Lilydjwg_changeColor()<CR>
"   imap [[[2
inoremap <S-CR> <CR>    
inoremap <M-c> <C-R>=Lilydjwg_colorpicker()<CR>
inoremap <C-J> <C-P>
inoremap <M-j> <C-N>
imap <S-BS> <C-W>
cmap <S-BS> <C-W>
"     日期和时间 [[[3
imap <silent> <F5> <C-R>=Lilydjwg_zh_date()<CR>
imap <silent> <S-F5> <C-R>=strftime("%Y-%m-%d")<CR>
imap <silent> <C-F5> <C-R>=strftime("%Y-%m-%d %H:%M")<CR>
"     补全 [[[3
imap <F2> <C-X><C-O>
imap <F3> <C-X><C-F>
imap <S-F3> <C-X><C-L>
imap <F7> <C-R>=Lilydjwg_dictcomplete()<CR>
"     补全最长项
inoremap <expr> <C-L> pumvisible()?"\<C-E>\<C-N>":"\<C-N>"
"   vmap [[[2
vnoremap <Leader># "9y?<C-R>='\V'.substitute(escape(@9,'\?'),'\n','\\n','g')<CR><CR>
vnoremap <Leader>* "9y/<C-R>='\V'.substitute(escape(@9,'\/'),'\n','\\n','g')<CR><CR>
vnoremap <C-C> "+y
"     中文引号 [[[3
vmap “ <ESC>`<i“<ESC>`>a”<ESC>
vmap ” <ESC>`>a”<ESC>`<i“<ESC>
"   cmap [[[2
"     还是这样吧
"     FIXME 但这样在 wildmenu 补全时会有点奇怪
cmap <C-P> <Up>
cmap <C-N> <Down>
cnoremap <Left> <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>
"   g[jk] [[[2
nmap <M-j> gj
nmap <M-k> gk
vmap <M-j> gj
vmap <M-k> gk
"   surround [[[2
"      比起 c，我更喜欢用 s
xmap c <Plug>Vsurround
xmap C <Plug>VSurround
"      原 cs 和 cscope 的冲突了
nmap cS <Plug>Csurround
"     以 % 表示的字符 [[[2
nmap <silent> t% :call Lilydjwg_hexchar()<CR>
vmap <silent> t% y:call Lilydjwg_strhex(@")<CR>
"     Ctrl-S 保存文件 [[[2
nmap <silent> <C-S> :update<CR>
imap <silent> <C-S> <ESC>:update<CR>
vmap <silent> <C-S> <ESC>:update<CR>
"     快速隐藏当前窗口内容[[[2
nmap <F12> :tabnew<CR>
imap <F12> <ESC>:tabnew<CR>
vmap <F12> <ESC>:tabnew<CR>
"     Shift+鼠标滚动[[[2
if v:version < 703
  nmap <silent> <S-MouseDown> zhzhzh
  nmap <silent> <S-MouseUp> zlzlzl
  vmap <silent> <S-MouseDown> zhzhzh
  vmap <silent> <S-MouseUp> zlzlzl
else
  map <S-ScrollWheelDown> <ScrollWheelRight>
  map <S-ScrollWheelUp> <ScrollWheelLeft>
  imap <S-ScrollWheelDown> <ScrollWheelRight>
  imap <S-ScrollWheelUp> <ScrollWheelLeft>
endif
"     上下移动一行文字[[[2
nmap <C-j> mz:m+<cr>`z
nmap <C-k> mz:m-2<cr>`z
vmap <C-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <C-k> :m'<-2<cr>`>my`<mzgv`yo`z
" 自动命令[[[1
"   自动关闭预览窗口（不能用在命令窗口，所以设置了一个变量）
let s:cmdwin = 0
autocmd CmdwinEnter	* let s:cmdwin = 1
autocmd CmdwinLeave	* let s:cmdwin = 0
autocmd InsertLeave	* if s:cmdwin == 0 && pumvisible() == 0|pclose|endif
autocmd VimEnter,ColorScheme	* call Lilydjwg_remark()
autocmd BufReadCmd *.maff call zip#Browse(expand("<amatch>"))
autocmd BufReadPost	* let &l:sts = &l:sw
autocmd BufReadPost	* call Lilydjwg_checktags(expand("<amatch>"))
"   见 ft-syntax-omni
if has("autocmd") && exists("+omnifunc")
  autocmd Filetype *
	\ if &omnifunc == "" |
	\   setlocal omnifunc=syntaxcomplete#Complete |
	\ endif
endif
" 自定义命令[[[1
" 对齐 xxx: xxx （两栏）
" .vimrc 有可能是软链接
exe 'command Set tabe ' . escape(resolve($MYVIMRC), ' ')
" 删除当前文件
command Delete call delete(expand('%'))
command -nargs=+ Reindent call Lilydjwg_reindent(<f-args>)
command -range AP <line1>,<line2>call Lilydjwg_AP()
" TODO better implement
command -range=% ClsXML <line1>,<line2>!tidy -utf8 -iq -xml
command -range=% ClsHTML <line1>,<line2>!tidy -utf8 -iq -omit -w 0
command MB tabe ~/temp/mb
command -nargs=1 -complete=customlist,Lilydjwg_complete_So So runtime so/<args>.vim
"   读取命令内容并将其插入到当前光标下
command -nargs=1 -complete=command ReadCommand redir @">|exe "<args>"|normal $p:redir END<CR>
command -nargs=1 Delmark delm <args>|wviminfo!
"   删除空行
command -range=% DBlank <line1>,<line2>g/^\s*$/d|nohls
"   某个 pattern 出现的次数
command -range=% -nargs=1 Count <line1>,<line2>s/<args>//gn|nohls
command SBlank %s/\v(^\s*$\n){2,}/\r/g
"   删除拖尾的空白
command TWS %s/\s\+$//|nohls|normal ``
"   设置成 Linux 下适用的格式
command Lin setl ff=unix fenc=utf8 nobomb
"   设置成 Windows 下适用的格式
command Win setl ff=dos fenc=gb18030
"   以第一行的文字为名保存当前文件
command TSave call Lilydjwg_TSave()
command -nargs=? -complete=file RSplit vs <args>|normal <C-W>L<C-W>w
command SQuote %s/“\|”\|″/"/ge|%s/‘\|’\|′/'/ge
command RJ silent call Lilydjwg_edit_diary()
"   载入 snippets
command -nargs=? Snippets silent call Lilydjwg_snippets("<args>")
"   用 VimExplorer 插件打开当前文件所在的目录
command Path VE %:p:h
command -nargs=1 Enc e ++bad=keep ++enc=<args> %
command CenterFull call CenterFull()
"   Awesome 下全屏时有点 bug，这里将之加回去
command Larger :set lines+=1
" 其它命令[[[1
"   NERDTree[[[2
let g:NERDTreeMapToggleZoom = 'a'
let g:NERDTreeMapToggleHidden = 'h'
"   另见平台相关部分
"   DirDiff[[[2
let g:DirDiffDynamicDiffText = 1
let g:DirDiffExcludes = "*~,*.swp"
let g:DirDiffWindowSize = 20
"   gundo[[[2
let gundo_preview_bottom = 1
"   bufexplorer[[[2
let g:bufExplorerFindActive = 0
"   taglist[[[2
let tlist_vimwiki_settings = 'wiki;h:headers'
let tlist_tex_settings = 'latex;h:headers'
let tlist_wiki_settings = 'wiki;h:headers'
let tlist_diff_settings = 'diff;f:file'
let tlist_git_settings = 'diff;f:file'
let tlist_gitcommit_settings = 'gitcommit;f:file'
let tlist_privoxy_settings = 'privoxy;s:sections'
"  来源 http://gist.github.com/476387
let tlist_html_settings = 'html;h:Headers;o:IDs;c:Classes'
hi link MyTagListFileName Type
"   2html.vim, 使用XHTML格式[[[2
let use_xhtml = 1
"   Align[[[2
let g:Align_xstrlen = 3
"   EnhancedCommentify[[[2
let g:EnhCommentifyRespectIndent = 'Yes'
let g:EnhCommentifyUseSyntax = 'Yes'
let g:EnhCommentifyPretty = 'Yes'
let g:EnhCommentifyBindInInsert = 'No'
let g:EnhCommentifyMultiPartBlocks = 'Yes'
let g:EnhCommentifyCommentsOp = 'Yes'
let g:EnhCommentifyAlignRight = 'Yes'
let g:EnhCommentifyUseBlockIndent = 'Yes'
"   indent/html.vim[[[2
let g:html_indent_inctags = "html,body,head,tbody,p,li,dd,marquee"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
"   mru[[[2
if has("win32") || has("win64")
  let MRU_File = '$VIM/vimfiles/vim_mru_files'
else
  let MRU_File = '~/.vim/vim_mru_files'
endif
let MRU_Max_Entries = 2000
let MRU_Exclude_Files = '\v^.*\~$'
"  加载菜单太耗时
let MRU_Add_Menu = 0
"   syntax/python.vim[[[2
let python_highlight_all = 1
"   syntax/vim.vim 默认会高亮 s:[a-z] 这样的函数名为错误[[[2
let g:vimsyn_noerror = 1
let g:netrw_list_hide = '^\.[^.].*'
"   tasklist[[[2
let g:tlTokenList = ["FIXME", "TODO", "XXX", "NotImplemented"]
"   vimExplorer[[[2
let g:VEConf_showHiddenFiles = 0
"   另见平台相关部分
"   不要占用 ' 的映射
let g:VEConf_fileHotkey = {}
let g:VEConf_fileHotkey.gotoPlace = '`'
let g:VEConf_fileHotkey.help = '<F1>'
let g:VEConf_treeHotkey = {}
let g:VEConf_treeHotkey.help = '<F1>'
let g:VEConf_treeHotkey.toggleNode = '<Space>'
"   VimIm，不要更改弹出菜单的颜色[[[2
let g:vimim_menu_color = 1
"   vimwiki[[[2
let g:vimwiki_list = [{'path': '~/.vimwiki/'}]
let g:vimwiki_camel_case = 0
let g:vimwiki_hl_cb_checked = 1
let g:vimwiki_folding = 0
let g:vimwiki_browsers = ['firefox']
let g:vimwiki_CJK_length = 1
let g:vimwiki_dir_link = 'index'
let g:vimwiki_html_header_numbering = 2
"   xml.vim，使所有的标签都关闭[[[2
let xml_use_xhtml = 1
"   netrw，elinks不行，使用curl吧
if executable("curl")
  let g:netrw_http_cmd = "curl"
  let g:netrw_http_xcmd= "-o"
endif
" cscope setting [[[1
if has("cscope") && executable("cscope")
  " 设置 [[[2
  set csto=1
  set cst
  set cscopequickfix=s-,c-,d-,i-,t-,e-

  " add any database in current directory
  function Lilydjwg_csadd()
    set nocsverb
    if filereadable(expand('%:h:p') . "/cscope.out")
      exe 'cs add ' . expand('%:h:p') . '/cscope.out'
    elseif filereadable(expand('%:h:p') . "/../cscope.out")
      exe 'cs add ' . expand('%:h:p') . '/../cscope.out'
    elseif filereadable("cscope.out")
      cs add cscope.out
    endif
    set csverb
  endfunction

  autocmd BufRead *.c,*.cpp,*.h call Lilydjwg_csadd()

  " 映射 [[[2
  " 查找C语言符号，即查找函数名、宏、枚举值等出现的地方
  nmap css :cs find s <C-R>=expand("<cword>")<CR><CR>
  " 查找函数、宏、枚举等定义的位置，类似ctags所提供的功能
  nmap csg :cs find g <C-R>=expand("<cword>")<CR><CR>
  " 查找本函数调用的函数
  nmap csd :cs find d <C-R>=expand("<cword>")<CR><CR>
  " 查找调用本函数的函数
  nmap csc :cs find c <C-R>=expand("<cword>")<CR><CR>
  " 查找指定的字符串
  nmap cst :cs find t <C-R>=expand("<cword>")<CR><CR>
  " 查找egrep模式，相当于egrep功能，但查找速度快多了
  nmap cse :cs find e <C-R>=expand("<cword>")<CR><CR>
  " 查找并打开文件，类似vim的find功能
  nmap csf :cs find f <C-R>=expand("<cfile>")<CR><CR>
  " 查找包含本文件的文件
  nmap csi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
  " 生成新的数据库
  nmap csn :lcd %:p:h<CR>:!my_cscope<CR>
  " 自己来输入命令
  nmap cs<Space> :cs find 
endif
" vim:fdm=marker:fmr=[[[,]]]
