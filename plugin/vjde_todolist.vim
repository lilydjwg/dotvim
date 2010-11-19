if exists('loaded_todolist') || &cp
    finish
endif
let loaded_todolist='yes'	
let todo_list_title='__Todo_List__'
let todo_list_size=30
let todo_list_vertical=1
let todo_list_open_only=1
let todo_help_size=3
function! s:toggle_todo_list()
    "let l:curr_buf = bufnr('%')
    let l:todo_win = bufwinnr(g:todo_list_title)
    if l:todo_win!=-1
        if winnr() != l:todo_win
            exec l:todo_win.'wincmd w'
        end
        return
    end
    if g:todo_list_vertical
        let l:win_dir=' botright vertical '
    else
        let l:win_dir='botright' 
    endif
    let l:buf_num = bufnr(g:todo_list_title)
    if l:buf_num == -1
        let l:wcmd=g:todo_list_title
    else
        let l:wcmd='+buffer' . l:buf_num
    end
    exec 'silent! '. l:win_dir . ' '. g:todo_list_size.'split '.l:wcmd
    call s:todo_list_init()
endf
" 0 comeback to current window
" 1 not come back
function! s:todo_list_retrive(flags)
    let l:curr_win = winnr()
    let l:curr_buf = bufnr('%')
    let l:curr_line = line(".") 
    let l:curr_col = col(".")

    let l:out_name = expand('%:p')
    exec '1'
    let l:out_count=0
    while search('TODO','W')>0
        if matchend(synIDattr(synID(line("."),col("."),1),"name"),"Todo")
            let l:out_line_{l:out_count}=line(".").' '.strpart(getline(line(".")),col(".")+4)
            let l:out_count=l:out_count+1
        endif
    endwhile
    call s:toggle_todo_list()
    setlocal modifiable
    let l:total = line('$')
    if l:total>0
        exec '1,'.l:total.' delete _'
    endif
    call append(0,l:out_name)
    call s:todo_list_help()
    let l:i=0
    while l:i < l:out_count 
        call append(l:i+1+g:todo_help_size,'  '.l:out_line_{l:i})
        let l:i=l:i+1
    endwhile
    setlocal nomodifiable
    if  a:flags==0
        if l:curr_win!=winnr()
            exec l:curr_win.'wincmd w'
        endif
        exec l:curr_line
    endif
endfunction

function! s:todo_list() 
    "setlocal modifiable
    call s:todo_list_retrive(0)
endfunction
function! s:todo_list_jump()
    let l:buf_name = getline(1) 
    let l:sel_line = line(".")
    let l:sel_str = getline(l:sel_line) 
    if l:sel_line<=g:todo_help_size+1
        return 
    end
    if strlen(l:sel_str)==0 
        call confirm(l:sel_str)
        return 
    endif
    let l:target_line = matchstr(l:sel_str,'\s*[0-9]\+\s')
    if strlen(l:target_line)==0
        return
    endif
    call s:todo_list_openfile(l:buf_name)

    exec l:target_line
endfunction
function! s:todo_list_openfile(filename)
    let l:winnum = bufwinnr(a:filename)
    if l:winnum==-1
        return 
    endif
    exec winnum.'wincmd w'
endf
function! s:todo_list_refresh()
    call s:todo_list_openfile(getline(1))
    call s:todo_list_retrive(1)
endf
function! s:todo_list_help()
    call append(1,'  <CR>  open the task item')
    call append(2,'  r     refresh the task item for this file')
    call append(3,'  R     refresh the task list file for current file')
    call append(4,' ')
    let g:todo_help_size=4
endfunction 
function! s:todo_list_refresh_file()
    "exec 'bp'
    silent! wincmd p
    let l:buf_name=bufname('%')    
    call s:todo_list_openfile(l:buf_name)
    call s:todo_list_retrive(1)
endf
function! s:todo_list_init()
    "if has('syntax')
        syntax match TodoListFileName '^[^ ]*$'
        syntax match TodoListCmd '^\s*[r|R]' contained
        syntax match TodoListCmd '^\s*<CR>' contained
        syntax match TodoListHelp '^\s*[rR<].*$' contains=TodoListCmd
        syntax match TodoListLineNr '^\s*[0-9]\+\s' contained
        syntax match TodoListItem '^\s*[0-9]\+\s.*$' contains=TodoListLineNr
    "endif
    highlight def link TodoListCmd Identifier
    highlight def link TodoListHelp Comment
    highlight def link TodoListFileName Title
    highlight def link TodoListLineNr LineNr
    highlight def link TodoListItem String 

    
    silent! setlocal nowrap
    silent! setlocal buftype=nofile
    setlocal modifiable
    setlocal nobuflisted
    nnoremap <buffer> <silent> <CR> :call <SID>todo_list_jump()<CR>
    nnoremap <buffer> <silent> r :call <SID>todo_list_refresh()<CR>
    nnoremap <buffer> <silent> R :call <SID>todo_list_refresh_file()<CR>
    inoremap <buffer> <silent> <CR> <C-o>:call <SID>todo_list_jump()<CR>
endfunction    
command! -nargs=0 TDlist call s:todo_list()
