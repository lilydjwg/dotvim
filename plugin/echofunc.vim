"==================================================
" File:         echofunc.vim
" Brief:        Echo the function declaration in
"               the command line for C/C++, as well
"               as other languages that ctags
"               supports.
" Authors:      Ming Bai <mbbill AT gmail DOT com>,
"               Wu Yongwei <wuyongwei AT gmail DOT com>
" Last Change:  2009-04-30 21:17:26
" Version:      1.19
"
" Install:      1. Put echofunc.vim to /plugin directory.
"               2. Use the command below to create tags
"                  file including the language and
"                  signature fields.
"                    ctags -R --fields=+lS .
"
" Usage:        When you type '(' after a function name
"               in insert mode, the function declaration
"               will be displayed in the command line
"               automatically. Then you may use Alt+- and
"               Alt+= (configurable via EchoFuncKeyPrev
"               and EchoFuncKeyNext) to cycle between
"               function declarations (if exists).
"
"               Another feature is to provide a balloon tip
"               when the mouse cursor hovers a function name,
"               macro name, etc. This works with when
"               +balloon_eval is compiled in.
"
" Options:      g:EchoFuncLangsDict
"                 Dictionary to map the Vim file types to
"                 tags languages that should be used. You do
"                 not need to touch it in most cases.
"               g:EchoFuncLangsUsed
"                 File types to enable echofunc, in case you
"                 do not want to use EchoFunc on all file
"                 types supported. Example:
"                   let g:EchoFuncLangsUsed = ["java","cpp"]
"               g:EchoFuncMaxBalloonDeclarations
"                 Maximum lines to display in balloon declarations.
"               g:EchoFuncKeyNext
"                 Key to echo the next function
"               g:EchoFuncKeyPrev
"                 Key to echo the previous function
"
" Thanks:       edyfox minux
"
"==================================================

" Vim version 7.x is needed.
if v:version < 700
     echohl ErrorMsg | echomsg "Echofunc.vim needs vim version >= 7.0!" | echohl None
     finish
endif

let s:res=[]
let s:count=1

function! s:EchoFuncDisplay()
    if len(s:res) == 0
        return
    endif
    set noshowmode
    let content=s:res[s:count-1]
    let wincols=&columns
    let allowedheight=&lines/5
    let statusline=(&laststatus==1 && winnr('$')>1) || (&laststatus==2)
    let reqspaces_lastline=(statusline || !&ruler) ? 12 : 29
    let width=len(content)
    let height=width/wincols+1
    let cols_lastline=width%wincols
    if cols_lastline > wincols-reqspaces_lastline
        let height=height+1
    endif
    if height > allowedheight
        let height=allowedheight
    endif
    let &cmdheight=height
    echohl Type | echo content | echohl None
endfunction

function! s:GetFunctions(fun, fn_only)
    let s:res=[]
    let ftags=taglist('^'.escape(a:fun,'[\*~^').'$')
    if (type(ftags)==type(0) || ((type(ftags)==type([])) && ftags==[]))
        return
    endif
    let fil_tag=[]
    for i in ftags
        if !has_key(i,'name')
            continue
        endif
        if has_key(i,'language')
            if !has_key(g:EchoFuncLangsDict,&filetype)
                continue
            endif
            if eval('index(g:EchoFuncLangsDict.' . &filetype . ',i.language)')
                        \== -1
                continue
            endif
        endif
        if has_key(i,'kind')
            " p: prototype/procedure; f: function; m: member
            if (!a:fn_only || (i.kind=='p' || i.kind=='f') ||
                        \(i.kind == 'm' && has_key(i,'cmd') &&
                        \                  match(i.cmd,'(') != -1)) &&
                        \i.name==a:fun
                let fil_tag+=[i]
            endif
        else
            if !a:fn_only && i.name == a:fun
                let fil_tag+=[i]
            endif
        endif
    endfor
    if fil_tag==[]
        return
    endif
    let s:count=1
    for i in fil_tag
        if has_key(i,'kind') && has_key(i,'name') && has_key(i,'signature')
            let tmppat=escape(i.name,'[\*~^')
            if &filetype == 'cpp'
                let tmppat=substitute(tmppat,'\<operator ','operator\\s*','')
                let tmppat=substitute(tmppat,'^\(.*::\)','\\(\1\\)\\?','')
                let tmppat=tmppat . '\s*(.*'
            else
                let tmppat=tmppat . '\>.*'
            endif
            let name=substitute(i.cmd[2:-3],tmppat,'','').i.name.i.signature
        elseif has_key(i,'kind')
            if i.kind == 'd'
                let name='macro ' . i.name
            elseif i.kind == 'c'
                let name='class ' . i.name
            elseif i.kind == 's'
                let name='struct ' . i.name
            elseif i.kind == 'u'
                let name='union ' . i.name
            elseif (match('fpmvt',i.kind) != -1) &&
                        \(has_key(i,'cmd') && i.cmd[0] == '/')
                let tmppat='\(\<'.i.name.'\>.\{-}\)'
                if &filetype == 'c' ||
                            \&filetype == 'cpp' ||
                            \&filetype == 'cs' ||
                            \&filetype == 'java' ||
                            \&filetype == 'javascript'
                    let tmppat=tmppat . ';.*'
                elseif &filetype == 'python' &&
                            \(i.kind == 'm' || i.kind == 'f')
                    let tmppat=tmppat . ':.*'
                elseif &filetype == 'tcl' &&
                            \(i.kind == 'm' || i.kind == 'p')
                    let tmppat=tmppat . '\({\)\?$'
                endif
                if i.kind == 'm' && &filetype == 'cpp'
                    let tmppat=substitute(tmppat,'^\(.*::\)','\\(\1\\)\\?','')
                endif
                if match(i.cmd[2:-3],tmppat) != -1
                    let name=substitute(i.cmd[2:-3],tmppat,'\1','')
                    if i.kind == 't' && name !~ '^\s*typedef\>'
                        let name='typedef ' . i.name
                    endif
                elseif i.kind == 't'
                    let name='typedef ' . i.name
                elseif i.kind == 'v'
                    let name='var ' . i.name
                else
                    let name=i.name
                endif
                if i.kind == 'm'
                    if has_key(i,'class')
                        let name=name . ' <-- class ' . i.class
                    elseif has_key(i,'struct')
                        let name=name . ' <-- struct ' . i.struct
                    elseif has_key(i,'union')
                        let name=name . ' <-- union ' . i.union
                    endif
                endif
            else
                let name=i.name
            endif
        else
            let name=i.name
        endif
        let name=substitute(name,'^\s\+','','')
        let name=substitute(name,'\s\+$','','')
        let name=substitute(name,'\s\+',' ','g')
        let file_line=i.filename
        if i.cmd > 0
            let file_line=file_line . ':' . i.cmd
        endif
        let s:res+=[name.' ('.(index(fil_tag,i)+1).'/'.len(fil_tag).') '.file_line]
    endfor
endfunction

function! s:GetFuncName(text)
    let name=substitute(a:text,'.\{-}\(\(\k\+::\)*\(\~\?\k*\|'.
                \'operator\s\+new\(\[]\)\?\|'.
                \'operator\s\+delete\(\[]\)\?\|'.
                \'operator\s*[[\]()+\-*/%<>=!~\^&|]\+'.
                \'\)\)\s*$','\1','')
    if name =~ '\<operator\>'  " tags have exactly one space after 'operator'
        let name=substitute(name,'\<operator\s*','operator ','')
    endif
    return name
endfunction

function! EchoFunc()
    let name=s:GetFuncName(getline('.')[:(col('.')-3)])
    if name==''
        return ''
    endif
    call s:GetFunctions(name, 1)
    call s:EchoFuncDisplay()
    return ''
endfunction

function! EchoFuncN()
    if s:res==[]
        return ''
    endif
    if s:count==len(s:res)
        let s:count=1
    else
        let s:count+=1
    endif
    call s:EchoFuncDisplay()
    return ''
endfunction

function! EchoFuncP()
    if s:res==[]
        return ''
    endif
    if s:count==1
        let s:count=len(s:res)
    else
        let s:count-=1
    endif
    call s:EchoFuncDisplay()
    return ''
endfunction

function! EchoFuncStart()
    if exists('b:EchoFuncStarted')
        return
    endif
    let b:EchoFuncStarted=1
    let s:ShowMode=&showmode
    let s:CmdHeight=&cmdheight
    inoremap <silent> <buffer>  (   (<c-r>=EchoFunc()<cr>
    inoremap <silent> <buffer>  )    <c-r>=EchoFuncClear()<cr>)
    exec 'inoremap <silent> <buffer> ' . g:EchoFuncKeyNext . ' <c-r>=EchoFuncN()<cr>'
    exec 'inoremap <silent> <buffer> ' . g:EchoFuncKeyPrev . ' <c-r>=EchoFuncP()<cr>'
endfunction

function! EchoFuncClear()
    echo ''
    return ''
endfunction

function! EchoFuncStop()
    if !exists('b:EchoFuncStarted')
        return
    endif
    iunmap      <buffer>    (
    iunmap      <buffer>    )
    exec 'iunmap <buffer> ' . g:EchoFuncKeyNext
    exec 'iunmap <buffer> ' . g:EchoFuncKeyPrev
    unlet b:EchoFuncStarted
endfunction

function! s:RestoreSettings()
    if !exists('b:EchoFuncStarted')
        return
    endif
    if s:ShowMode
        set showmode
    endif
    exec "set cmdheight=".s:CmdHeight
    echo
endfunction

function! BalloonDeclaration()
    let line=getline(v:beval_lnum)
    let pos=v:beval_col - 1
    let endpos=match(line, '\W', pos)
    if endpos != -1 && &filetype == 'cpp'
        if v:beval_text == 'operator'
            if line[endpos :] =~ '^\s*\(new\(\[]\)\?\|delete\(\[]\)\?\|[[\]+\-*/%<>=!~\^&|]\+\|()\)'
                let endpos=matchend(line, '^\s*\(new\(\[]\)\?\|delete\(\[]\)\?\|[[\]+\-*/%<>=!~\^&|]\+\|()\)',endpos)
            endif
        elseif v:beval_text == 'new' || v:beval_text == 'delete'
            if line[:endpos+1] =~ 'operator\s\+\(new\|delete\)\[]$'
                let endpos=endpos+2
            endif
        endif
    endif
    if (endpos != -1)
        let endpos=endpos - 1
    endif
    let name=s:GetFuncName(line[0:endpos])
    if name==''
        return ''
    endif
    call s:GetFunctions(name, 0)
    let result = ""
    let cnt=0
    for item in s:res
        if cnt < g:EchoFuncMaxBalloonDeclarations
            let result = result . item . "\n"
        endif
        let cnt=cnt+1
    endfor
    return strpart(result, 0, len(result) - 1)
endfunction

function! BalloonDeclarationStart()
    set ballooneval
    set balloonexpr=BalloonDeclaration()
endfunction

function! BalloonDeclarationStop()
    set balloonexpr=
    set noballooneval
endfunction

if !exists('g:EchoFuncLangsDict')
    let g:EchoFuncLangsDict={
                \ 'asm':['Asm'],
                \ 'aspvbs':['Asp'],
                \ 'awk':['Awk'],
                \ 'basic':['Basic'],
                \ 'c':['C','C++'],
                \ 'cpp':['C','C++'],
                \ 'cs':['C#'],
                \ 'cobol':['Cobol'],
                \ 'eiffel':['Eiffel'],
                \ 'erlang':['Erlang'],
                \ 'fortran':['Fortran'],
                \ 'html':['HTML'],
                \ 'java':['Java'],
                \ 'javascript':['JavaScript'],
                \ 'lisp':['Lisp'],
                \ 'lua':['Lua'],
                \ 'make':['Make'],
                \ 'pascal':['Pascal'],
                \ 'perl':['Perl'],
                \ 'php':['PHP'],
                \ 'python':['Python'],
                \ 'rexx':['REXX'],
                \ 'ruby':['Ruby'],
                \ 'scheme':['Scheme'],
                \ 'sh':['Sh'],
                \ 'zsh':['Sh'],
                \ 'sql':['SQL'],
                \ 'slang':['SLang'],
                \ 'sml':['SML'],
                \ 'tcl':['Tcl'],
                \ 'vera':['Vera'],
                \ 'verilog':['verilog'],
                \ 'vim':['Vim'],
                \ 'yacc':['YACC']}
endif

if !exists("g:EchoFuncLangsUsed")
    let g:EchoFuncLangsUsed=sort(keys(g:EchoFuncLangsDict))
endif

if !exists("g:EchoFuncMaxBalloonDeclarations")
    let g:EchoFuncMaxBalloonDeclarations=20
endif

if !exists("g:EchoFuncKeyNext")
    let g:EchoFuncKeyNext='<M-=>'
endif

if !exists("g:EchoFuncKeyPrev")
    let g:EchoFuncKeyPrev='<M-->'
endif

function! s:CheckTagsLanguage(filetype)
    return index(g:EchoFuncLangsUsed, a:filetype) != -1
endfunction

function! CheckedEchoFuncStart()
    if s:CheckTagsLanguage(&filetype)
        call EchoFuncStart()
    endif
endfunction

function! CheckedBalloonDeclarationStart()
    if s:CheckTagsLanguage(&filetype)
        call BalloonDeclarationStart()
    endif
endfunction

function! s:EchoFuncInitialize()
    augroup EchoFunc
        autocmd!
        autocmd InsertLeave * call s:RestoreSettings()
        autocmd BufRead,BufNewFile * call CheckedEchoFuncStart()
        if has('gui_running')
            menu    &Tools.Echo\ F&unction.Echo\ F&unction\ Start   :call EchoFuncStart()<CR>
            menu    &Tools.Echo\ F&unction.Echo\ Function\ Sto&p    :call EchoFuncStop()<CR>
        endif

        if has("balloon_eval")
            autocmd BufRead,BufNewFile * call CheckedBalloonDeclarationStart()
            if has('gui_running')
                menu    &Tools.Echo\ Function.&Balloon\ Declaration\ Start  :call BalloonDeclarationStart()<CR>
                menu    &Tools.Echo\ Function.Balloon\ Declaration\ &Stop   :call BalloonDeclarationStop()<CR>
            endif
        endif
    augroup END

    call CheckedEchoFuncStart()
    if has("balloon_eval")
        call CheckedBalloonDeclarationStart()
    endif
endfunction

augroup EchoFunc
    autocmd BufRead,BufNewFile * call s:EchoFuncInitialize()
augroup END

" vim: set et sts=4 sw=4:
