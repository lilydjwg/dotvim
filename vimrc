scriptencoding utf-8
" ========================================================================
" 依云(lilydjwg) 的 vimrc
" 我的博客： https://blog.lilydjwg.me/
"
" 整个配置仅适用于本人
" 不过，其中的部分配置很可能非常适合你哦～～
" 不要整个地照搬，只复制对你自己有用的部分！
"
" 有任何意见和建议，或者其它想说的，可以到我的博客留言。
"
" 许可：GPLv3
" ========================================================================
" 其他文件[[[1
try
  packadd! matchit
catch /.*/
  runtime macros/matchit.vim
endtry
runtime vimrc_example.vim
"]]]
" 我的设置
" 函数[[[1
"   复制缓冲区到新标签页[[[2
function Lilydjwg_copy_to_newtab()
  let temp = tempname()
  try
    let nr = bufnr('%')
    exec "mkview" temp
    tabnew
    silent exec "source" temp
    exec "buffer " nr
  finally
    call delete(temp)
  endtry
endfunction
"   删除所有未显示且无修改的缓冲区以减少内存占用[[[2
function Lilydjwg_cleanbufs()
  for bufNr in filter(range(1, bufnr('$')),
        \ 'buflisted(v:val) && !bufloaded(v:val)')
    execute bufNr . 'bdelete'
  endfor
endfunction
"   转成 HTML，只要 pre 标签部分[[[2
"   http://bootleq.blogspot.com/2012/12/tohtml-html-document-function-tohtmldoc.html
function Lilydjwg_to_html(line1, line2)
  let save_number = get(g:, 'html_number_lines', -1)
  let g:html_number_lines = 0
  call tohtml#Convert2HTML(a:line1, a:line2)
  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
  call search("<pre[^<]*>")
  normal! dit
  %delete _
  let @" = '<pre>' . substitute(@", '\v^\n\s*', '', '') . '</pre>'
  call setline(1, split(@", '\n'))
  if save_number > -1
    let g:html_number_lines = save_number
  else
    unlet g:html_number_lines
  endif
endfunction
"   获取可读的文件大小[[[2
function Lilydjwg_getfsize(file)
  let size = getfsize(a:file)
  if has('python3')
    try
      py3 from myutils import filesize
      return py3eval('filesize('.size.')')
    catch /.*/
    endtry
  endif
  return size . 'B'
endfunction
"   打开 NERDTree，使用当前文件目录或者当前目录[[[2
function Lilydjwg_NERDTreeOpen()
  if exists("t:NERDTreeBufName")
    NERDTreeToggle
  else
    try
      NERDTree `=expand('%:h')`
    catch /E121/
      NERDTree `=getcwd()`
    endtry
  endif
endfunction
"   Perl-style quoted lists[[[2
function Lilydjwg_qw()
  let in = input('qw(')
  return py3eval('LilyQw("'.escape(in, '"\').'")')
endfunction
"   使用分隔符连接多行 [[[2
function Lilydjwg_join(sep, bang) range
  if a:sep[0] == '\'
    let sep = strpart(a:sep, 1)
  else
    let sep = a:sep
  endif
  let lines = getline(a:firstline, a:lastline)
  if a:firstline == 1 && a:lastline == line('$')
    let dellast = 1
  else
    let dellast = 0
  endif
  exe a:firstline . ',' . a:lastline . 'd_'
  if a:bang != '!'
    call map(lines, "substitute(v:val, '^\\s\\+\\|\\s\\+$', '', 'g')")
  endif
  call append(a:firstline-1, join(lines, sep))
  if dellast
    $d_
  endif
endfunction
"   切换显示行号/相对行号/不显示 [[[2
function Lilydjwg_toggle_number()
  if &nu && &rnu
    set nonu nornu
  elseif &nu && !&rnu
    set rnu
  else
    set nu
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
    let &l:sw = a:2
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
  let new_color = Lilydjwg_colorpicker()
  if new_color != ''
    exe 'normal! eF'.color[0]
    call setline('.', substitute(getline('.'), '\%'.col('.').'c\V'.color, new_color, ''))
  endif
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
" 对齐命令[[[2
function Lilydjwg_Align(type) range
  try
    let pat = g:Myalign_def[a:type]
  catch /^Vim\%((\a\+)\)\=:E716/
    echohl ErrorMsg
    echo "对齐方式" . a:type . "没有定义"
    echohl None
    return
  endtry
  call Align#AlignPush()
  call Align#AlignCtrl(pat[0])
  if len(pat) == 3
    call Align#AlignCtrl(pat[2])
  endif
  exe a:firstline.','.a:lastline."call Align#Align(0, '". pat[1] ."')"
  call Align#AlignPop()
endfunction
function Lilydjwg_Align_complete(ArgLead, CmdLine, CursorPos)
  return filter(keys(g:Myalign_def), 'stridx(v:val, a:ArgLead) == 0')
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
  exe 'colorscheme' get(colors, i)
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
  exe 'echo "'. str . '"'
endfunction
"  用火狐打开链接[[[2
function Lilydjwg_open_url()
  let s:url = Lilydjwg_get_pattern_at_cursor('\v%(https?|ftp)://[^]''" \t\r\n>*。，\`)]*')
  if s:url == ""
    echohl WarningMsg
    echomsg '在光标处未发现URL！'
    echohl None
  else
    echo '打开URL：' . s:url
    if has("win32") || has("win64")
      " start 不是程序，所以无效。并且，cmd 只能使用双引号
      " call system("start '" . s:url . "'")
      call system("cmd /q /c start \"" . s:url . "\"")
    elseif has("mac")
      call system("open '" . s:url . "'")
    else
      " call system("gnome-open " . s:url)
      call system("xdg-open '" . s:url . "' &")
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
"  是否该调用 cycle？[[[2
function Lilydjwg_trycycle(dir)
  let pat = Lilydjwg_get_pattern_at_cursor('[+-]\?\d\+')
  if pat
    if a:dir ==? 'x'
      return "\<C-X>"
    else
      return "\<C-A>"
    end
  else
    let mode = mode() =~ 'n' ? 'w' : 'v'
    let dir = a:dir ==? 'x' ? -1 : 1
    return ":\<C-U>call Cycle('" . mode . "', " . dir . ", v:count1)\<CR>"
  end
endfunction
"  format the whole file [[[2
function Lilydjwg_formatall()
  let v = winsaveview()
  keepjumps normal! gg=G
  call winrestview(v)
endfunction
" set 相关[[[1
"   一般设置[[[2
" maybe necessary when root
syntax on
set number
set smarttab
set expandtab
" 不要响铃，更不要闪屏
set visualbell t_vb=
" when will this cause problems?
set ttyfast
set title
" 不要包含标准错误，但是允许 Vim 初始化其默认值
autocmd VimEnter * set shellredir=>
autocmd GUIEnter * set t_vb=
" ! is for histwin to save tags
set viminfo='100,:10000,<50,s10,h,!
set history=10000
set wildmenu
set delcombine " 组合字符一个个地删除
set laststatus=2 " 总是显示状态栏
" 首先尝试最长的，接着轮换补全项
set wildmode=longest:full,full
set shiftround
set diffopt+=vertical,context:3,foldcolumn:0
if &diffopt =~ 'internal'
  set diffopt+=indent-heuristic,algorithm:patience
endif
set fileencodings=ucs-bom,utf-8,gb18030,cp936,latin1
set fileformats=unix,dos,mac
set formatoptions=croqn2mB1
try
  " Vim 7.4
  set formatoptions+=j
catch /.*/
endtry
set nojoinspaces
set virtualedit=block
set nostartofline
" set guioptions=egmrLtai
set guioptions=acit
" 没必要，而且很多时候 = 表示赋值
set isfname-==
set nolinebreak
set nowrapscan
set scrolloff=5
set sessionoptions=blank,buffers,curdir,folds,help,options,tabpages,winsize,slash,unix,resize
set shiftwidth=2
set winaltkeys=no
set noequalalways
set listchars=eol:$,tab:>-,nbsp:␣
set display=lastline
set completeopt+=longest
try
  set completeopt+=popup
  set completepopup=border:off
catch /.*/
endtry
set maxcombine=4
set cedit=<C-Y>
set whichwrap=b,s,[,]
set tags+=./tags;
try
  set matchpairs=(:),{:},[:],《:》,〈:〉,［:］,（:）,「:」,『:』,‘:’,“:”
catch /^Vim\%((\a\+)\)\=:E474/
endtry
" Avoid command-line redraw on every entered character by turning off Arabic
" shaping (which is implemented poorly).
if has('arabic')
  set noarabicshape
endif
set wildignore+=*~,*.py[co],__pycache__,.*.swp
set shortmess-=S
if !has("patch-8.1.1270")
  try
    packadd! vim-searchindex
  catch /.*/
  endtry
endif
" will make termux mouse not work https://github.com/vim/vim/issues/7422
" if exists('&balloonevalterm')
"   set balloonevalterm
" endif
try
  set signcolumn=number
catch /.*/
endtry
set grepprg=grep\ -nH\ $*
if has('&clipboard')
  set clipboard=autoselect,html,exclude:cons\|linux
endif
set tabpagemax=50
" make it unusable so it won't clash
set termwinkey=<C-\\>
set backup backupcopy=no
if has('&splitkeep')
  set splitkeep=screen
endif
" Linux 与 Windows 等 [[[2
if has("gui_macvim")
  set macmeta
end
if has("win32") || has("win64")
  let g:vimfiles = split(&runtimepath, ',')[1]
  let g:mytmpdir = $TMP
  if has('directx')
    set renderoptions=type:directx
  endif
else
  " Linux 路径 [[[3
  let g:vimfiles = split(&runtimepath, ',')[0]
  if exists('$VIMTMP')
    let g:mytmpdir = $VIMTMP
  else
    let g:mytmpdir = expand("~/tmpfs")
  endif
  let g:MuttVim_configfile = expand('~/scripts/python/pydata/muttvim.json')
  cnoremap <expr> <C-T> getcmdtype() == ':' ? '~/tmpfs/' : "\<C-t>"
  " cron 的目录不要备份
  set backupskip+=/etc/cron.*/*
  set backupdir=.,/var/tmp,/tmp
endif
" 语言相关 [[[3
if $LANGUAGE =~ '^zh' || ($LANGUAGE == '' && v:lang =~ '^zh')
  " 缓冲区号 文件名 行数 修改 帮助 只读 编码 换行符 BOM ======== 字符编码 位置 百分比位置
  set statusline=%n\ %<%f\ %L行\ %{&modified?'[+]':&modifiable\|\|&ft=~'^\\vhelp\|qf$'?'':'[-]'}%h%r%{&fenc=='utf-8'\|\|&fenc==''?'':'['.&fenc.']'}%{&ff=='unix'?'':'['.&ff.']'}%{&bomb?'[BOM]':''}%{&eol?'':'[noeol]'}%{&diff?'[diff]':''}%=\ 0x%-4.8B\ \ \ \ %-14.(%l,%c%V%)\ %P
else
  set statusline=%n\ %<%f\ %LL\ %{&modified?'[+]':&modifiable\|\|&ft=~'^\\vhelp\|qf$'?'':'[-]'}%h%r%{&fenc=='utf-8'\|\|&fenc==''?'':'['.&fenc.']'}%{&ff=='unix'?'':'['.&ff.']'}%{&bomb?'[BOM]':''}%{&eol?'':'[noeol]'}%{&diff?'[diff]':''}%=\ 0x%-4.8B\ \ \ \ %-14.(%l,%c%V%)\ %P
endif
" 路径相关 [[[3
let g:VEConf_favorite = g:vimfiles . "/ve_favorite"
let g:NERDTreeBookmarksFile = g:vimfiles . "/NERDTreeBookmarks"
let g:dictfilePrefix = g:vimfiles . "/dict/"
if has("python3")
  exe "py3file" g:vimfiles . "/vimrc.py"
endif
if isdirectory(expand("/run/user/$UID"))
  let g:undodir = expand("/run/user/$UID/vimundo")
else
  let g:undodir = g:mytmpdir . "/.vimundo"
endif
let &errorfile = g:mytmpdir . "/.error"
" 图形与终端 [[[2
let g:colors_name = 'lilypink'
let &t_EI = "\e[2 q"
let &t_SI = "\e[6 q"
let &t_SR = "\e[4 q"
if has("gui_running")
  set mousemodel=popup
  " 有些终端不能改变大小
  set columns=88
  set lines=38
  set cursorline
elseif has("unix")
  set ambiwidth=single
  if $COLORTERM == 'truecolor'
    set cursorline
    set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  elseif &term =~ '256color\|nvim'
    set cursorline
  else
    " 在Linux文本终端下非插入模式显示块状光标
    if &term == "linux" || &term == "fbterm"
      exec "set t_ve+=\033[?6c"
      autocmd InsertEnter * exec "set t_ve-=\033[?6c"
      autocmd InsertLeave * exec "set t_ve+=\033[?6c"
      " autocmd VimLeave * exec "set t_ve-=\033[?6c"
    endif
    if &term == "fbterm"
      set cursorline
    elseif $TERMCAP =~ 'Co#256'
      set t_Co=256
      set cursorline
    else
      " 暂时只有这个配色比较适合了
      let g:colors_name = 'default'
    endif
  endif
elseif has('win32') && exists('$CONEMUBUILD')
  " enable 256 colors in ConEmu on Win
  set term=xterm
  set t_Co=256
  let &t_AB="\e[48;5;%dm"
  let &t_AF="\e[38;5;%dm"
  set cursorline
endif
exe "colorscheme" g:colors_name
" bracketed paste mode support for tmux
if &term =~ '^screen\|^tmux' && exists('&t_BE')
  let &t_BE = "\033[?2004h"
  let &t_BD = "\033[?2004l"
  " t_PS and t_PE are key code options and they are special
  exec "set t_PS=\033[200~"
  exec "set t_PE=\033[201~"
endif
if &term =~ '^screen\|^tmux'
  " This may leave mouse in use by terminal application
  " exec "set t_RV=\033Ptmux;\033\033[>c\033\\"
  set ttymouse=sgr
  if &t_GP == ''
    " for getwinpos
    exec "set t_GP=\033Ptmux;\033\033[13t\033\\"
  endif
  " Enable modified arrow keys, see  :help arrow_modifiers
  execute "silent! set <xUp>=\<Esc>[@;*A"
  execute "silent! set <xDown>=\<Esc>[@;*B"
  execute "silent! set <xRight>=\<Esc>[@;*C"
  execute "silent! set <xLeft>=\<Esc>[@;*D"
endif
" 不同的 Vim 版本 [[[2
if has("conceal")
  " 'i' is for neosnippet
  set concealcursor=nci
  " XXX: This will cause a redraw on startup
  set conceallevel=0
endif
if has("persistent_undo")
  let &undodir=g:undodir
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p', 0700)
  endif
  set undofile
endif
unlet g:undodir
let g:silent_unsupported = 1
" map 相关[[[1
"   nmap [[[2
"     Fx 相关 [[[3
" buffer list
nmap <F2> <Leader>be
nmap <F4> :ls<CR>:buffer<Space>
nmap <F6> :cnext<CR>
nmap <S-F6> :cprevious<CR>
nmap <silent> <F9> :enew<CR>
nmap <F11> :next<CR>
nmap <S-F11> :previous<CR>
" 重新载入当前文件
nmap <F5> :e!<CR>
"     t 开头 [[[3
nmap <silent> tt :tabnew<CR>
nmap <silent> TT :call Lilydjwg_copy_to_newtab()<CR>
nmap t= :call Lilydjwg_formatall()<CR>
" select all
nmap ta ggVG
nmap <silent> tf :call Lilydjwg_open_url()<CR>
" less style 清除高亮
nmap <silent> <M-u> :nohls<CR>
" join line without space
nmap tj Jx
" select line content
nnoremap tl ^vg_
nmap <silent> to :call append('.', '')<CR>j
nmap <silent> tO :call append(line('.')-1, '')<CR>k
nmap tp "+P
nmap <silent> tv :call Lilydjwg_toggle_ve()<CR>
nmap tw :call Lilydjwg_toggle_ambiwidth()<CR>
"     w 开头 [[[3
nmap wc :set cursorline!<CR>
nnoremap <silent> wf :call Lilydjwg_NERDTreeOpen()<CR>
nnoremap <silent> wn :call Lilydjwg_toggle_number()<CR>
nnoremap <silent> wt :TlistToggle<CR>
nnoremap <silent> wb :TagbarToggle<CR>
"     - 开头 [[[3
nmap -+ :set nomodified<CR>
nmap -c :call Lilydjwg_toggle_color()<CR>
nmap -ft :exe 'tabe '.g:vimfiles.'/ftplugin/'.&ft.'.vim'<CR>
nmap -syn :exe 'tabe '.g:vimfiles.'/syntax/'.&ft.'.vim'<CR>
nmap -int :exe 'tabe '.g:vimfiles.'/indent/'.&ft.'.vim'<CR>
"     显示高亮组 [[[4
nnoremap <silent> wh :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
"     Alt 组合键 [[[3
nmap <M-m> :MRU<Space>
" 打开草稿
nmap <unique> <silent> <M-s> <Plug>ShowScratchBuffer
for i in range(1, 8)
  exec 'nnoremap <silent> <M-' . i . '> '. i .'gt'
endfor
nnoremap <silent> <M-9> :exec "normal!" min([tabpagenr('$'),9])."gt"<CR>
"     lusty-explorer [[[4
nmap <M-b> :LustyBufferExplorer<CR>
nmap <M-g> :LustyBufferGrep<CR>
nmap <M-l> :LustyFilesystemExplorerFromHere<CR>
let g:LustyExplorerSuppressRubyWarning = 1
"     其它开头的 [[[3
nmap <BS> <C-O>
nmap <C-D> <C-W>q
nnoremap <Space> za
nmap ' <C-W>
nmap Y y$
nmap 'm :MarksBrowser<CR>
nmap :: :!
nmap cd :lcd %:p:h<CR>:echo expand('%:p:h')<CR>
nmap gb :setl fenc=gb18030<CR>
nmap d<CR> :%s/\r//eg<CR>``
nmap cac :call Lilydjwg_changeColor()<CR>
nmap gl :IndentGuidesToggle<CR>
nnoremap <silent> gs :echo Lilydjwg_getfsize(expand('%'))<CR>
"   imap [[[2
inoremap <M-c> <C-R>=Lilydjwg_colorpicker()<CR>
inoremap <C-J> <C-P>
inoremap <M-j> <C-N>
inoremap <M-q> <C-R>=Lilydjwg_qw()<CR>
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
"     以 % 表示的字符 [[[2
vmap <silent> t% :w !ascii2uni -a J -q<CR>
nmap <silent> t% :call Lilydjwg_hexchar()<CR>
"     HTML 转义 [[[2
"     I got the idea from unimpaired.vim
noremap <silent> [x :HTMLEscape<CR>
noremap <silent> ]x :HTMLUnescape<CR>
nnoremap <silent> [x :.HTMLEscape<CR>
nnoremap <silent> ]x :.HTMLUnescape<CR>
"     Ctrl-S 保存文件 [[[2
nmap <silent> <C-S> :update<CR>
imap <silent> <C-S> <ESC>:update<CR>
vmap <silent> <C-S> <ESC>:update<CR>
"     快速隐藏当前窗口内容[[[2
nmap <F12> :tabnew<CR>
imap <F12> <ESC>:tabnew<CR>
vmap <F12> <ESC>:tabnew<CR>
"     mouse mapping[[[2
map <S-ScrollWheelDown> <ScrollWheelRight>
map <S-ScrollWheelUp> <ScrollWheelLeft>
imap <S-ScrollWheelDown> <ScrollWheelRight>
imap <S-ScrollWheelUp> <ScrollWheelLeft>
nnoremap <silent> <S-MiddleMouse> <LeftMouse>"+P
inoremap <silent> <S-MiddleMouse> <C-r>+
"     上下移动一行文字[[[2
nmap <C-j> :m+<cr>
nmap <C-k> :m-2<cr>
vmap <C-j> :m'>+<cr>gv
vmap <C-k> :m'<-2<cr>gv
" 自动命令[[[1
"   自动关闭预览窗口（不能用在命令窗口，所以设置了一个变量）
let s:cmdwin = 0
autocmd CmdwinEnter     * let s:cmdwin = 1
autocmd CmdwinLeave     * let s:cmdwin = 0
autocmd InsertLeave     * if s:cmdwin == 0 && pumvisible() == 0|pclose|endif
"   插入模式下长时间不动则打断撒消序列
if (v:version == 800 && has("patch1407")) || v:version != 800
  autocmd CursorHoldI * call feedkeys("\<C-g>u", 'nt')
endif
autocmd BufReadCmd *.maff,*.xmind,*.crx,*.apk,*.whl,*.egg  call zip#Browse(expand("<amatch>"))
"   见 ft-syntax-omni
if has("autocmd") && exists("+omnifunc")
  autocmd Filetype *
        \ if &omnifunc == "" && !get(b:, 'disable_omnifunc') |
        \   setlocal omnifunc=syntaxcomplete#Complete |
        \ endif
endif
if exists('##TerminalWinOpen')
  autocmd TerminalWinOpen * setlocal nonumber
endif
" don't show q: hints
augroup vimHints | exe 'au!' | augroup END
" 自定义命令[[[1
" 对齐 xxx: xxx （两栏）
" .vimrc 有可能是软链接
exe 'command Set tabe ' . escape(resolve($MYVIMRC), ' ')
" 删除当前文件
command Delete if delete(expand('%')) | echohl WarningMsg | echo "删除当前文件失败" | echohl None | endif
command -nargs=1 -range=% -bang Join <line1>,<line2>call Lilydjwg_join(<q-args>, "<bang>")
command -nargs=+ Reindent call Lilydjwg_reindent(<f-args>)
" TODO better implement
command -range=% ClsXML <line1>,<line2>!tidy -utf8 -iq -xml
command -range=% ClsHTML <line1>,<line2>!tidy -utf8 -iq -omit -w 0
command -range=% ClsJSON setf json | <line1>,<line2>!jq .
command -nargs=1 -complete=customlist,Lilydjwg_complete_So So runtime so/<args>.vim
command -nargs=1 Delmark delm <args>|wviminfo!
"   删除空行
command -range=% -bar DBlank <line1>,<line2>g/^\s*$/d_|nohls
"   某个 pattern 出现的次数
command -range=% -nargs=1 Count <line1>,<line2>s/<args>//gn|nohls
command -range=% -bar SBlank <line1>,<line2>s/\v(^\s*$\n){2,}/\r/g
"   删除拖尾的空白
command -range=% -bar TWS <line1>,<line2>s/\s\+$//|nohls|normal ``
"   设置成 Linux 下适用的格式
command Lin setl ff=unix fenc=utf8 nobomb eol
"   设置成 Windows 下适用的格式
command Win setl ff=dos fenc=gb18030
"   以第一行的文字为名保存当前文件
command TSave call Lilydjwg_TSave()
command -nargs=? -complete=file RSplit vs <args>|normal <C-W>L<C-W>w
command -range=% -bar SQuote <line1>,<line2>s/“\|”\|″/"/ge|<line1>,<line2>s/‘\|’\|′/'/ge
command -range -bar HTMLEscape <line1>,<line2>s/&/\&amp;/ge|<line1>,<line2>s/</\&lt;/ge|<line1>,<line2>s/>/\&gt;/ge
command -range -bar HTMLUnescape <line1>,<line2>s/&amp;/\&/ge|<line1>,<line2>s/&lt;/</ge|<line1>,<line2>s/&gt;/>/ge
"   用 VimExplorer 插件打开当前文件所在的目录
command Path VE %:p:h
command -nargs=1 Enc e ++bad=keep ++enc=<args> %
command CenterFull call CenterFull()
command -nargs=1 -range=% -complete=customlist,Lilydjwg_Align_complete LA <line1>,<line2>call Lilydjwg_Align("<args>")
command -nargs=1 -range=% Column <line1>,<line2>Align! w<args>0P1p \S\@<=\s\@=
command -range=% Paste <line1>,<line2>py3 LilyPaste()
command -range=% Tohtml call Lilydjwg_to_html(<line1>, <line2>)
command BufClean call Lilydjwg_cleanbufs()
command Helptags for d in filter(globpath(&rtp, "doc/", 0, 1), 'filewritable(v:val)') | exec "helptags" d | endfor
" 插件配置[[[1
"   ft-rust[[[2
let g:rust_fold = 1
"   asyncrun.vim[[[2
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
"   choosewin[[[2
nmap <M-w> <Plug>(choosewin)
let g:choosewin_overlay_enable = 1
let g:choosewin_statusline_replace = 0
"   linediff[[[2
let g:linediff_buffer_type = 'scratch'
"   rst_tables[[[2
let g:rst_tables_no_warning = 1
"   signify [[[2
let g:signify_vcs_list = ['git']
let g:signify_sign_overwrite = 0
" signify won't update on FocusGained anymore
let g:signify_disable_by_default = 1
"   ConflictMotions [[[2
" 禁用 \x 开头的映射；它们与 EnhancedCommentify 冲突了
let g:ConflictMotions_TakeMappingPrefix = ''
"   NrrRgn[[[2
let g:nrrw_rgn_vert = 1
let g:nrrw_rgn_wdth = 80
let g:nrrw_rgn_hl = 'Folded'
"   cycle[[[2
"   https://github.com/lilydjwg/vim-cycle
nnoremap <expr> <silent> <C-X> Lilydjwg_trycycle('x')
vnoremap <expr> <silent> <C-X> Lilydjwg_trycycle('x')
nnoremap <expr> <silent> <C-A> Lilydjwg_trycycle('p')
vnoremap <expr> <silent> <C-A> Lilydjwg_trycycle('p')
nnoremap <Plug>CycleFallbackNext <C-A>
nnoremap <Plug>CycleFallbackPrev <C-X>
let g:cycle_no_mappings = 1
let g:cycle_default_groups = [
      \ [['true', 'false']],
      \ [['yes', 'no']],
      \ [['and', 'or']],
      \ [['on', 'off']],
      \ [['>', '<']],
      \ [['==', '!=']],
      \ [['是', '否']],
      \ [['有', '无']],
      \ [["in", "out"]],
      \ [["min", "max"]],
      \ [["get", "post"]],
      \ [["to", "from"]],
      \ [["read", "write"]],
      \ [['with', 'without']],
      \ [["exclude", "include"]],
      \ [["asc", "desc"]],
      \ [["next", "prev"]],
      \ [["encode", "decode"]],
      \ [["left", "right"]],
      \ [["hide", "show"]],
      \ [['「:」', '『:』'], 'sub_pairs'],
      \ [['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      \ 'Friday', 'Saturday'], 'hard_case', {'name': 'Days'}],
      \ [["enable", "disable"]],
      \ [["add", "remove"]],
      \ [['up', 'down']],
      \ [['after', 'before']],
      \ ]
"   Erlang[[[2
let g:erlangHighlightBif = 1
let g:erlangFold = 1
"   grep.vim[[[2
let g:Grep_Default_Options = '--binary-files=without-match'
"   NERDTree[[[2
let g:NERDTreeMapToggleZoom = 'a'
let g:NERDTreeMapToggleHidden = 'h'
"   另见平台相关部分
"   bufexplorer[[[2
let g:bufExplorerFindActive = 0
"   tagbar[[[2
let g:tagbar_type_dosini = {
      \ 'ctagstype': 'ini',
      \ 'kinds': ['s:sections', 'b:blocks'],
      \ }
let g:tagbar_type_pgsql = {
      \ 'ctagstype': 'pgsql',
      \ 'kinds': ['f:functions', 't:tables'],
      \ }
"   taglist[[[2
let Tlist_Show_One_File = 1
let tlist_vimwiki_settings = 'wiki;h:headers'
let tlist_tex_settings = 'latex;h:headers'
let tlist_tracwiki_settings = 'wiki;h:headers'
let tlist_diff_settings = 'diff;m:modified;n:created;d:deleted;h:hunks'
let tlist_git_settings = 'diff;m:modified;n:created;d:deleted;h:hunks'
let tlist_gitcommit_settings = 'gitcommit;f:file'
let tlist_privoxy_settings = 'privoxy;s:sections'
"  来源 http://gist.github.com/476387
let tlist_html_settings = 'html;h:Headers;o:IDs;c:Classes'
let tlist_dosini_settings = 'ini;s:sections'
let tlist_pgsql_settings = 'pgsql;f:functions;t:tables'
let tlist_markdown_settings = 'markdown;h:headers'
let tlist_rust_settings = 'rust;n:modules;s:structural types;i:trait interfaces;c:implementations;f:functions;g:enums;t:type aliases;v:global variables;M:macro definitions;m:struct fields;e:enum variants;F:methods'
hi link MyTagListFileName Type
"   2html.vim, 使用XHTML格式[[[2
let use_xhtml = 1
"   shell 脚本打开折叠
let g:sh_fold_enabled = 3 " 打开函数和 here 文档的折叠
"   Align[[[2
let g:Align_xstrlen = 4 " use strdisplaywidth
"   Lilydjwg_Align
"   Meanings:
"     colon:     dict definition like 'key: value,'
"     colonl:    list items like this one
"     comment:   #-style comments
"     jscomment: //-style comments
let g:Myalign_def = {
      \   'colon':     ['WP0p1l:', ':\@<=', 'g ,'],
      \   'colonl':    ['WP0p1l:', ':\@<='],
      \   'comma':     ['WP0p1l:', ',\@<=', 'g ,'],
      \   'commalist': ['WP0p1l', ',\@<=', 'g ,'],
      \   'comment':   ['WP1p1l:', '#'],
      \   'css':       ['WP0p1l:', ':\@<=', 'v \v^\s*/\*|\{|\}'],
      \   'define':    ['WP0p1l:', ' \d\@=', 'g ^#define\s'],
      \   'jscomment': ['WP0p1l:', '//'],
      \ }
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
let g:html_indent_inctags = "html,body,head,tbody,p,li,dd,marquee,header,nav,article,section"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
"   mru[[[2
let MRU_File = g:vimfiles . '/vim_mru_files'
let MRU_Max_Entries = 2000
let MRU_Exclude_Files = '\v^.*\~$|/COMMIT_EDITMSG$|/itsalltext/|^/tmp/'
"  加载菜单太耗时
let MRU_Add_Menu = 0
let MRU_Filename_Format = {
    \   'formatter': 'v:val',
    \   'parser': '.*',
    \   'syntax': '[^/]\+$'
    \ }
"   syntax/haskell.vim[[[2
let hs_highlight_boolean = 1
let hs_highlight_types = 1
let hs_highlight_more_types = 1
"   syntax/python.vim[[[2
let python_highlight_all = 1
"   syntax/vim.vim 默认会高亮 s:[a-z] 这样的函数名为错误[[[2
let g:vimsyn_noerror = 1
"   tasklist[[[2
let g:tlTokenList = ["FIXME", "TODO", "XXX", "NotImplemented", "unimplemented!()"]
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
"   vimwiki[[[2
let g:vimwiki_list = [{'path': '~/.vimwiki/'}]
let g:vimwiki_camel_case = 0
let g:vimwiki_hl_cb_checked = 1
let g:vimwiki_folding = 0
let g:vimwiki_browsers = ['firefox']
let g:vimwiki_CJK_length = 1
let g:vimwiki_dir_link = 'index'
let g:vimwiki_html_header_numbering = 2
let g:vimwiki_conceallevel = 2
"   xml.vim，使所有的标签都关闭[[[2
let xml_use_xhtml = 1
"   netrw[[[2
let g:netrw_list_hide = '^\.[^.].*'
" 不要用 elinks
if executable("curl")
  let g:netrw_http_cmd  = "curl"
  let g:netrw_http_xcmd = "-L --compressed -o"
endif
" don't use pscp if scp is available
" pscp could be "parallel scp"
" https://github.com/vim/vim/pull/14739
if executable("scp")
  let g:netrw_scp_cmd = "scp -q"
endif
" cscope setting [[[1
if has("cscope")
  " support GNU Global [[[2
  let s:tags_files = []
  if executable("gtags-cscope")
    call add(s:tags_files, ['GTAGS', 'gtags-cscope'])
  endif
  if executable("cscope")
    call add(s:tags_files, ['cscope.out', 'cscope'])
  endif

  if !empty(s:tags_files)
    " settings and autocmd [[[2
    set csto=1
    set cst
    set cscopequickfix=s-,c-,d-,i-,t-,e-

    " add any database in current directory
    function Lilydjwg_csadd()
      try
        cd %:h
      catch /.*/
        return
      endtry

      try
        for [filename, prgname] in s:tags_files
          let db = findfile(filename, '.;')
          if !empty(db)
            let &cscopeprg = prgname
            set nocscopeverbose
            exec "cs add" db expand('%:p:h')
            set cscopeverbose
            break
          endif
        endfor
      finally
        silent cd -
      endtry
    endfunction

    autocmd BufRead *.c,*.cpp,*.h,*.cc,*.java call Lilydjwg_csadd()

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
    " 自己来输入命令
    nmap cs<Space> :cs find<Space>
  endif
endif
" 最后 [[[1
if exists(':packadd')
  if exists('$VIMINIT')
    " .vim at another place; we need to manually update 'packpath'
    let &packpath = g:vimfiles . ',' . &packpath . ',' . g:vimfiles . '/after'
  endif
  " insert after the first one so spell changes won't go
  " into our config directory.
  let rtp = split(&runtimepath, ',')
  call insert(rtp, g:vimfiles . '/config', 1)
  let &runtimepath = join(rtp, ',')
  unlet rtp
endif
runtime abbreviate.vim
runtime local.vim
" don't load menu.vim; it takes time
let did_install_default_menus = 1
" vim:fdm=marker:fmr=[[[,]]]
