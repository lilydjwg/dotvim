# ZFVimDirDiff

vim plugin to diff two directories like BeyondCompare by using `diff`

inspired by [will133/vim-dirdiff](https://github.com/will133/vim-dirdiff)

* why another directory diffing plugin?

    * format the `diff` result as vertical split file tree view,
        which should be more human-readable
    * more friendly file sync operation using the same mappings as builtin `vimdiff`
    * automatically backup before destructive actions
        (by [ZFVimBackup](https://github.com/ZSaberLv0/ZFVimBackup))
    * better file or directory exclude logic
        (by [ZFVimIgnore](https://github.com/ZSaberLv0/ZFVimIgnore))

![](https://raw.githubusercontent.com/ZSaberLv0/ZFVimDirDiff/master/preview.png)

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)


# how to use

1. install by [vim-plug](https://github.com/junegunn/vim-plug) or any other plugin manager:

    ```
    Plug 'ZSaberLv0/ZFVimDirDiff'
    Plug 'ZSaberLv0/ZFVimIgnore' " required only if you want to use default g:ZFDirDiffFileExclude settings
    Plug 'ZSaberLv0/ZFVimBackup' " required only if you want to enable auto backup
    ```

1. use `:ZFDirDiff` command to start diff

    ```
    :ZFDirDiff pathA pathB
    ```

    if path contains spaces:

    ```
    :ZFDirDiff path\ A path\ B
    :call ZF_DirDiff("path A", "path B")
    ```

1. use `:ZFDirDiffMark` to mark two directories to start diff

    Open a file and `:ZFDirDiffMark` and the containing directory will be stored as
    a diff candidate. Then repeat with another file and you'll be asked to
    diff the two.

    ```
    :edit pathA/file.vim
    :ZFDirDiffMark
    :edit pathB/file.vim
    :ZFDirDiffMark
    ```

    Or integrate with your file manager. For vim-dirvish, add
    ~/.vim/ftplugin/dirvish.vim:

        nnoremap <buffer> X :<C-u>ZFDirDiffMark <C-r><C-l><CR>

    Or for netrw, add ~/.vim/ftplugin/netrw.vim:

        nnoremap <buffer> X :<C-u>ZFDirDiffMark <C-r>=b:netrw_curdir<CR>/<C-r><C-l><CR>

    Then X on two directories.

1. you can also start diff from [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree):
    inside nerdtree window, press `m` to popup menu,
    press `z` to choose `mark to diff`,
    and mark another node again to start diff

1. you may also use it as command line diff tool

    ```
    vim -c 'call ZF_DirDiff("path A", "path B")'
    sh ZFDirDiff.sh "path A" "path B"
    ```

1. within the diff window:

    * use `DD` to update the diff result
    * use `o` or `<cr>` to diff current file, or fold/unfold current dir
    * use `O` to unfold all contents under current dir,
        `x` to fold to parent, `X` to fold to root
    * use `cd` to make current dir as diff root dir,
        `u` to go up for current side,
        and `U` to go up for both side
    * use `DM` to mark current file,
        and `DM` again on another file to diff these two files
    * use `]c` or `DJ` to move to next diff, `[c` or `DK` to prev diff
    * use `do` or `DH` to sync from another side to current side,
        `dp` or `DL` to sync from current side to another side
    * use `dd` to delete node under cursor
    * use `DN` to mark mutiple files,
        when done, use `do/DH/dp/DL/dd` to sync or delete marked files
    * use `p` to copy the node's path, and `P` for the node's full path
    * use `q` to exit diff
    * you may also want to use [ZSaberLv0/ZFVimIndentMove](https://github.com/ZSaberLv0/ZFVimIndentMove)
        or [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion)
        to quickly move between file tree node


# autocmds and buffer local vars

* `ZFDirDiff_DirDiffEnter`

    called when enter dir diff buffer (each time for left and right window buffer)

    buffer local vars:

    * `t:ZFDirDiff_ownerTab` : `tabpagenr()` that open the diff task
    * `t:ZFDirDiff_fileLeft` : abs path of left dir
    * `t:ZFDirDiff_fileRight` : abs path of right dir
    * `t:ZFDirDiff_fileLeftOrig` : original path passed from param
    * `t:ZFDirDiff_fileRightOrig` : original path passed from param
    * `t:ZFDirDiff_hasDiff` : whether has diff
    * `t:ZFDirDiff_data` : data return from `ZF_DirDiffCore()`

        ```
        [
            {
                'level' : 'depth of tree node, 0 for top most ones',
                'path' : 'path relative to fileLeft/fileRight',
                'name' : 'file or dir name, empty if fileLeft and fileRight is file',
                'type' : '',
                    // T_DIR: current node is dir
                    // T_SAME: current node is file and has no diff
                    // T_DIFF: current node is file and has diff
                    // T_DIR_LEFT: only left exists and it is dir
                    // T_DIR_RIGHT: only right exists and it is dir
                    // T_FILE_LEFT: only left exists and it is dir
                    // T_FILE_RIGHT: only right exists and it is dir
                    // T_CONFLICT_DIR_LEFT: left is dir and right is file
                    // T_CONFLICT_DIR_RIGHT: left is file and right is dir
                'diff' : '0/1, whether this node or children node contains diff',
                'children' : [
                    ...
                ],
            },
            ...
        ]
        ```

    * `t:ZFDirDiff_dataUI` : list of each line for building UI

        this is a plain list including folded item,
        you may also use `t:ZFDirDiff_dataUIVisible` for visible item list

        ```
        [{
            'index' : 'index in t:ZFDirDiff_dataUI',
            'indexVisible' : 'index in t:ZFDirDiff_dataUIVisible, -1 when not visible',
            'folded' : 'true when this item is dir and folded',
            'data' : {
                // original data of t:ZFDirDiff_data
                ...
            },
        }]
        ```

    * `b:ZFDirDiff_isLeft` : true if cur buffer is left
    * `b:ZFDirDiff_iLineOffset` : first item's offset accorrding to header lines

* `ZFDirDiff_FileDiffEnter`

    called when enter file diff buffer (each time for left and right window buffer)

    buffer local vars:

    * `t:ZFDirDiff_ownerDiffTab` : `tabpagenr()` of owner diff buffer that open this file diff task


# configs

* for core logic:
    * `let g:ZFDirDiffShowSameFile = 1` : whether to show files that are same
    * `let g:ZFDirDiffFileExclude = ''` : file name exclude pattern, e.g. `*.class,*.o`

        it's recommended to use `Plug 'ZSaberLv0/ZFVimIgnore'` for ignore settings,
        you may disable this by `let g:ZFDirDiffFileExcludeUseDefault=0`

    * `function! ZFDirDiffCustomFilter(path, type)`

        if you want to supply custom filter logic,
        define a function named `ZFDirDiffCustomFilter`
        before `:ZFDirDiff`

        ```
        function! ZFDirDiffCustomFilter(path, type)
            if match(path, 'xxx') >= 0
                " return 1 to ignore this item
                return 1
            else
                return 0
            endif
        endfunction
        ```

        NOTE: the filter function affects all `:ZFDirDiff` after defined,
        you may want to `delfunction! ZFDirDiffCustomFilter` after `:ZFDirDiff` call

    * `let g:ZFDirDiffContentExclude = ''` : file content exclude pattern, e.g. `log:,id:`
    * `let g:ZFDirDiffFileIgnoreCase = 0` : whether ignore file name case
    * `let g:ZFDirDiffCustomDiffArg = ''` : additional diff args passed to `diff`
    * `let g:ZFDirDiffSortFunc = 'ZF_DirDiffSortFunc'` : sort function
* for builtin UI impl:
    * `let g:ZFDirDiffUI_filetypeLeft = 'ZFDirDiffLeft'` : `filetype` for left diff buffer
    * `let g:ZFDirDiffUI_filetypeRight = 'ZFDirDiffRight'` : `filetype` for right diff buffer
    * `let g:ZFDirDiffUI_tabstop = 2` : `tabstop` for diff buffer
    * `let g:ZFDirDiffUI_headerTextFunc = 'YourFunc'` : function name to get the header text

        ```
        " return a list of strings - one per line
        function! YourFunc()
            if b:ZFDirDiff_isLeft
                return [t:ZFDirDiff_fileLeft, '']
            else
                return [t:ZFDirDiff_fileRight, '']
            endif
        endfunction
        ```

    * `let g:ZFDirDiffUI_confirmHintHeaderFunc = 'YourFunc'` : function name to get the header text for confirmation prompts
        * type:
            * 'l2r' : sync left to right
            * 'r2l' : sync right to left
            * 'dl' : delete left
            * 'dr' : delete right
            * 'diff' : diff two path

        ```
        " return a list of strings - one per line
        function! YourFunc(fileLeft, fileRight, type)
            return ['LEFT: ' . a:fileLeft, 'RIGHT: ' . a:fileRight]
        endfunction
        ```

    * `let g:ZFDirDiffUI_autoBackup = 1` or `let t:ZFDirDiffUI_autoBackup = 1` :
        whether backup before write or delete files,
        require `ZSaberLv0/ZFVimBackup` installed
    * `let g:ZFDirDiffUI_syncSameFile = 0` : whether need to sync same file,
        can be local to tab `t:ZFDirDiffUI_syncSameFile`
    * whether confirm before sync (can be local to tab `t:xxx`)
        * `let g:ZFDirDiffConfirmSyncDir = 1`
        * `let g:ZFDirDiffConfirmSyncFile = 1`
        * `let g:ZFDirDiffConfirmCopyDir = 1`
        * `let g:ZFDirDiffConfirmCopyFile = 0`
        * `let g:ZFDirDiffConfirmRemoveDir = 1`
        * `let g:ZFDirDiffConfirmRemoveFile = 1`
    * keymaps
        * `let g:ZFDirDiffKeymap_update = ['DD']`
        * `let g:ZFDirDiffKeymap_open = ['<cr>', 'o']`
        * `let g:ZFDirDiffKeymap_foldOpenAll = ['O']`
        * `let g:ZFDirDiffKeymap_foldClose = ['x']`
        * `let g:ZFDirDiffKeymap_foldCloseAll = ['X']`
        * `let g:ZFDirDiffKeymap_goParent = ['U']`
        * `let g:ZFDirDiffKeymap_diffThisDir = ['cd']`
        * `let g:ZFDirDiffKeymap_diffParentDir = ['u']`
        * `let g:ZFDirDiffKeymap_markToDiff = ['DM']`
        * `let g:ZFDirDiffKeymap_markToSync = ['DN']`
        * `let g:ZFDirDiffKeymap_quit = ['q']`
        * `let g:ZFDirDiffKeymap_quitFileDiff = ['q']`
        * `let g:ZFDirDiffKeymap_nextDiff = [']c', 'DJ']`
        * `let g:ZFDirDiffKeymap_prevDiff = ['[c', 'DK']`
        * `let g:ZFDirDiffKeymap_syncToHere = ['do', 'DH']`
        * `let g:ZFDirDiffKeymap_syncToThere = ['dp', 'DL']`
        * `let g:ZFDirDiffKeymap_deleteFile = ['dd']`
        * `let g:ZFDirDiffKeymap_getPath = ['p']`
        * `let g:ZFDirDiffKeymap_getFullPath = ['P']`
    * highlight

        ```
        highlight link ZFDirDiffHL_Title Title
        highlight link ZFDirDiffHL_Dir Directory
        highlight link ZFDirDiffHL_DirContainDiff Directory
        highlight link ZFDirDiffHL_Same Folded
        highlight link ZFDirDiffHL_Diff DiffText
        highlight link ZFDirDiffHL_DirOnlyHere DiffAdd
        highlight link ZFDirDiffHL_DirOnlyThere Normal
        highlight link ZFDirDiffHL_FileOnlyHere DiffAdd
        highlight link ZFDirDiffHL_FileOnlyThere Normal
        highlight link ZFDirDiffHL_ConflictDir ErrorMsg
        highlight link ZFDirDiffHL_ConflictFile WarningMsg
        highlight link ZFDirDiffHL_MarkToDiff Cursor
        ```


# FAQ

* Q: how to use under special shell config

    A: when used under special shell config,
    especially `sh` under Windows,
    here's a list of configs you should concern:

    * `let g:ZFDirDiffLangString = 'LANG= '`

        by default, this value is set to `set LAND= && ` on Windows to suit `cmd.exe`

        you may want to set this to suit your shell, e.g.

        ```
        let g:ZFDirDiffLangString = 'LANG= '
        ```

    * `ZF_DirDiffTempname()`

        by default, this function use vim's builtin `tempname()`

        however, it may result to `C:\xxx\tmp` on Windows,
        which can not be read by `bash`,
        you may want to supply your own function to suit your shell, e.g.

        ```
        function! ZF_DirDiffTempname()
            return '/xxx/tmp'
        endfunction
        ```

    * `ZF_DirDiffShellEnv_pathFormat(path)`

        by default, this function use `fnamemodify(path, ':.')`
        to make the path relative to `getcwd()`

        if your shell can't read with it,
        you may supply your own, e.g.

        ```
        function! ZF_DirDiffShellEnv_pathFormat(path)
            return substitute(system('cygpath -m "' . a:path . '"'), '[\r\n]', '', 'g')
        endfunction
        ```

