
[中文用户请戳我](https://github.com/ZSaberLv0/ZFVimIM/blob/master/README.CN.md)

[中文用户请戳我](https://github.com/ZSaberLv0/ZFVimIM/blob/master/README.CN.md)

[中文用户请戳我](https://github.com/ZSaberLv0/ZFVimIM/blob/master/README.CN.md)

<!-- vim-markdown-toc GFM -->

* [introduction](#introduction)
* [how to use](#how-to-use)
    * [minimal config (local db)](#minimal-config-local-db)
    * [recommend config (cloud db)](#recommend-config-cloud-db)
    * [how to use](#how-to-use-1)
    * [some tips](#some-tips)
* [detailed](#detailed)
    * [configs](#configs)
    * [functions](#functions)
    * [functions (for db repo)](#functions-for-db-repo)
    * [make your own db](#make-your-own-db)
        * [db samples](#db-samples)
    * [FAQ](#faq)
    * [known issue](#known-issue)

<!-- vim-markdown-toc -->

# introduction

Input Method by pure vim script, inspired by [VimIM](https://github.com/vim-scripts/VimIM)

Outstanding features / why another remake:

* more friendly long sentence match and better predict logic
* predict from multiple db without switching dbs
* auto create user word and re-order word priority according to your input history
* cloud input, auto pull and push your db file from/to Github
* fetch words from 3rd openapi, asynchronously
* solve many VimIM's issues:
    * better txt db load performance if `executable('python')`
    * auto disable and re-enable complete engines when using input method
    * sync input method state acrossing buffers

![](https://raw.githubusercontent.com/ZSaberLv0/ZFVimIM/master/preview.gif)

![](https://raw.githubusercontent.com/ZSaberLv0/ZFVimIM/master/preview_crossdb.gif)

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)


# how to use

## minimal config (local db)

1. recommend env:

    * (optional) `vim8` with `job` or `neovim`, for better db load performance
    * (optional) `executable('python')` or `executable('python3')`, for better db load performance

1. use [Vundle](https://github.com/VundleVim/Vundle.vim) or any other plugin manager you like to install

    ```
    Plugin 'ZSaberLv0/ZFVimIM'
    Plugin 'ZSaberLv0/ZFVimJob' " optional, for better db load performance
    ```

1. prepare your db files,
    you may copy the txt db files from [db samples](https://github.com/ZSaberLv0/ZFVimIM#db-samples)
    to any location
1. config

    ```
    function! s:myLocalDb()
        let db = ZFVimIM_dbInit({
                    \   'name' : 'YourDb',
                    \ })
        call ZFVimIM_cloudRegister({
                    \   'mode' : 'local',
                    \   'dbId' : db['dbId'],
                    \   'repoPath' : '/path/to/repo', " path to the db
                    \   'dbFile' : '/YourDbFile', " db file, relative to repoPath
                    \   'dbCountFile' : '/YourDbCountFile', " optional, db count file, relative to repoPath
                    \ })
    endfunction
    autocmd User ZFVimIM_event_OnDbInit call s:myLocalDb()
    ```

## recommend config (cloud db)

1. recommend env:

    * (optional) `git`, for db update
    * (optional) `vim8` with `job` or `neovim`, for better db load performance
    * (optional) `executable('python')` or `executable('python3')`, for better db load performance

1. prepare your db repo according to [db samples](https://github.com/ZSaberLv0/ZFVimIM#db-samples),
    or simply fork one of the db samples
1. go to [access tokens](https://github.com/settings/tokens) to generate your Github access token,
    and make sure it has push permission to your db repo
    (check `repo` in `Select scopes`)
1. config your access token according to your db repo, for example,
    for the [db samples](https://github.com/ZSaberLv0/ZFVimIM#db-samples):

    ```
    let g:zf_git_user_email='YourEmail'
    let g:zf_git_user_name='YourUserName'
    let g:zf_git_user_token='YourGithubAccessToken'
    ```

    please check the README of each db repo for detail

1. use [Vundle](https://github.com/VundleVim/Vundle.vim) or any other plugin manager you like to install

    ```
    Plugin 'ZSaberLv0/ZFVimIM'
    Plugin 'ZSaberLv0/ZFVimJob' " optional, for better db load performance
    Plugin 'ZSaberLv0/ZFVimGitUtil' " optional, cleanup your db commit history when necessary
    Plugin 'YourUserName/ZFVimIM_pinyin_base' " your db repo
    Plugin 'ZSaberLv0/ZFVimIM_openapi' " optional, 3rd IME using Baidu
    ```


## how to use

* use `;;` to toggle input method, and `;:` to switch db
* scroll page by `-` or `=`
* input and choose word by `<space>` or `0~9`
* choose head or tail word by `[` or `]`
* your input history would be recorded locally or
    push to github automatically,
    you may use `;,` or `:IMAdd` to add user word,
    `;.` or `:IMRemove` to remove user word


## some tips

* you may want to add a IME status tip to your `:h 'statusline'`

    ```
    let &statusline='%{ZFVimIME_IMEStatusline()}'.&statusline
    ```

* if it's hard to support async mode, you may also:

    * pull and push manually by `:call ZFVimIM_download()` and `:call ZFVimIM_upload()`
    * automatically ask you to input git info to push before exit vim,
        by `let g:ZFVimIM_cloudSync_enable=1`

* since db files are pretty personal,
    the default db only contains single word,
    words would be created during your usage,
    if you prefer other choices, see [db samples](https://github.com/ZSaberLv0/ZFVimIM#db-samples)
* your db repo may contain many commits after long time usage,
    which may cause a huge `.git` dir,
    it's recommended to clean up it occasionally, by:

    * delete and re-create the repo
    * if you have `push --force` permission,
        search and see the `g:ZFVimIM_cloudAsync_autoCleanup` detail config below


# detailed

## configs

* `let g:ZFVimIM_autoAddWordLen=3*4`

    when you choose word and the word's byte length less than this value,
    we would add the word to db file automatically
    (ignored when `g:ZFVimIM_autoAddWordChecker` is set)

* `let g:ZFVimIM_autoAddWordChecker=[]`

    list of function to check whether need to add user word

    ```
    function! MyChecker(userWord)
        let needAdd = ...
        return needAdd
    endfunction
    let g:ZFVimIM_autoAddWordChecker=[function('MyChecker')]
    ```

    when any of checker returned `0`, we won't add user word

* `let g:ZFVimIM_symbolMap = {}`

    used to transform unicode symbols during input

    it's empty by default, typical config for Chinese:

    ```
    let g:ZFVimIM_symbolMap = {
                \   ' ' : [''],
                \   '`' : ['·'],
                \   '!' : ['！'],
                \   '$' : ['￥'],
                \   '^' : ['……'],
                \   '-' : [''],
                \   '_' : ['——'],
                \   '(' : ['（'],
                \   ')' : ['）'],
                \   '[' : ['【'],
                \   ']' : ['】'],
                \   '<' : ['《'],
                \   '>' : ['》'],
                \   '\' : ['、'],
                \   '/' : ['、'],
                \   ';' : ['；'],
                \   ':' : ['：'],
                \   ',' : ['，'],
                \   '.' : ['。'],
                \   '?' : ['？'],
                \   "'" : ['‘', '’'],
                \   '"' : ['“', '”'],
                \   '0' : [''],
                \   '1' : [''],
                \   '2' : [''],
                \   '3' : [''],
                \   '4' : [''],
                \   '5' : [''],
                \   '6' : [''],
                \   '7' : [''],
                \   '8' : [''],
                \   '9' : [''],
                \ }
    ```

    * if you want to change this setting at runtime,
        you should use `call ZFVimIME_stop() | call ZFVimIME_start()`
        to restart to take effect,
        or, add autocmd to `ZFVimIM_event_OnEnable`
        to setup this value

    * it's recommended to add these configs to make vim recognize chinese chars

        ```
        set encoding=utf-8
        set fileencoding=utf-8
        set fileencodings=utf-8,ucs-bom,chinese
        ```

* keymaps:

    * `let g:ZFVimIM_key_pageUp = ['-']`
    * `let g:ZFVimIM_key_pageDown = ['=']`
    * `let g:ZFVimIM_key_chooseL = ['[']`
    * `let g:ZFVimIM_key_chooseR = [']']`

* `let g:ZFVimIM_showKeyHint = 1`

    whether show key hint after word

* `let g:ZFVimIM_cachePath=$HOME.'/.vim_cache/ZFVimIM'`

    cache path for temp files

* `let g:ZFVimIM_cloudAsync_outputTo={...}`

    for async cloud input, output log to where
    (see [ZFJobOutput](https://github.com/ZSaberLv0/ZFVimJob)), default:

    ```
    let g:ZFVimIM_cloudAsync_outputTo = {
                \   'outputType' : 'statusline',
                \   'outputId' : 'ZFVimIM_cloud_async',
                \ }
    ```

* `let g:ZFVimIM_cloudAsync_autoCleanup=30`

    your db repo may contain many commits after long time usage,
    we would try to remove all history commits if:

    * have these optional plugins installed:

        ```
        Plugin 'ZSaberLv0/ZFVimJob'
        Plugin 'ZSaberLv0/ZFVimGitUtil'
        ```

    * `ZFJobAvailable()` returned 1 (i.e. async mode available)
    * `g:ZFVimIM_cloudAsync_autoCleanup` greater than 0
    * your `git rev-list --count HEAD` exceeds `g:ZFVimIM_cloudAsync_autoCleanup`

    NOTE:

    * this require you have `git push --force` permission,
        if not, please disable this feature,
        otherwise your commits may lost occasionally
        (each time when commits exceeds `g:ZFVimIM_cloudAsync_autoCleanup`)

* `let g:ZFVimIM_cloudAsync_autoInit=1`

    for async cloud input only,
    when on, we would load db when `VimEnter`,
    to reduce the time you first `ZFVimIME_start()`


## functions

* `ZFVimIME_start()` `ZFVimIME_stop()` `ZFVimIME_toggle()` `ZFVimIME_next()`

    start or stop, must called during Insert Mode, as
    `<c-r>=ZFVimIME_start()<cr>`

* `:IMAdd word key` or `ZFVimIM_wordAdd(db, word, key)`

    manually add word

* `:IMRemove word [key]` or `ZFVimIM_wordRemove(db, word [, key])`

    manually remove word

* `:IMReorder word [key]` or `ZFVimIM_wordReorder(db, word [, key])`

    manually reorder word priority,
    by reducing it's input history count to a proper value

* `ZFVimIM_complete(key [, option])`

    * option

        ```
        {
          'sentence' : '0/1, default to g:ZFVimIM_sentence',
          'crossDb' : 'maxNum, default to g:ZFVimIM_crossDbLimit',
          'predict' : 'maxNum, default to g:ZFVimIM_predictLimit',
          'match' : '', // > 0 : limit to this num, allow sub match
                        // = 0 : disable match
                        // < 0 : limit to (0-match) num, disallow sub match
                        // default to g:ZFVimIM_matchLimit
          'db' : {...}, // which db to use, empty for current
        }
        ```

    * return

        ```
        [
          {
            'dbId' : 'match from which db',
            'len' : 'match count in key',
            'key' : 'matched full key',
            'word' : 'matched word',
            'type' : 'type of completion: sentence/match/predict/subMatch',
            'sentenceList' : [ // (optional) for sentence type only, list of word that complete as sentence
              {
                'key' : '',
                'word' : '',
              },
            ],
          },
          ...
        ]
        ```

    note, you may supply your own function named `ZFVimIM_complete`
    to override the default one,
    and use `ZFVimIM_completeDefault(key, option)` to achieve custom IME complete


## functions (for db repo)

* `ZFVimIM_dbInit(option)`

    to register a db, option:

    ```
    {
      'name' : '(required) name of your db',
      'priority' : '(optional) priority of the db, smaller value has higher priority, 100 by default',
      'switchable' : '(optional) 1 by default, when off, won't be enabled by ZFVimIME_keymap_next_n() series',
      'editable' : '(optional) 1 by default, when off, no dbEdit would applied',
      'crossable' : '(optional) g:ZFVimIM_crossable by default, whether to show result when inputing in other db',
                    // 0 : disable
                    // 1 : show only when full match
                    // 2 : show and allow predict
                    // 3 : show and allow predict and sub match
      'crossDbLimit' : '(optional) g:ZFVimIM_crossDbLimit by default, when crossable, limit max result to this num',
      'dbCallback' : '(optional) func(key, option), see ZFVimIM_complete',
                     // when dbCallback supplied, words would be fetched from this callback instead
      'menuLabel' : '(optional) string or function(item), when not empty, show label after key hint',
                    // when not set, or set to number `0`, we would show db name if it's completed from crossDb
      'implData' : { // extra data for impl
      },
    }
    ```

    return db object which would stored in `g:ZFVimIM_db`

* `ZFVimIM_cloudRegister(cloudOption)`

    register cloud info, when registered,
    we would try to pull/push from/to remote repo

    cloudOption:

    ```
    {
      'mode' : '(optional) git/local',
      'cloudInitMode' : '(optional) forceAsync/forceSync/preferAsync/preferSync',
      'dbId' : '(required) dbId generated by ZFVimIM_dbInit()'
      'repoPath' : '(required) git/local repo path',
      'dbFile' : '(required) db file path relative to repoPath, must start with /',
      'dbCountFile' : '(optional) db count file path relative to repoPath, must start with /',
      'gitUserEmail' : '(optional) git user email',
      'gitUserName' : '(optional) git user name',
      'gitUserToken' : '(optional) git access token or password',
    }
    ```


## make your own db

1. supply your db file with this format:

    ```
    a 啊 阿
    a 锕
    ai 爱 唉
    ohayou お早う おはようございます
    tang _(:з」∠)_
    haha ^\ ^
    ```

    key can be `a-z`, word can be any string
    (if word contain space, you may escape it by `\ `)

    save it as `utf-8` encoding

1. format the db file to ensure it's valid

    ```
    call ZFVimIM_dbNormalize('/path/to/dbFile')
    ```

    this may take a long time, but for only once

1. put the db file to your git repo,
    according to the db samples below


### db samples

* [ZSaberLv0/ZFVimIM_openapi](https://github.com/ZSaberLv0/ZFVimIM_openapi) :
    pinyin repo using thirdparty's openapi,
    recommended to install as default,
    and it shows the way to achieve complex async db logic
* [ZSaberLv0/ZFVimIM_pinyin_base](https://github.com/ZSaberLv0/ZFVimIM_pinyin_base) :
    base pinyin repo that only contain single word,
    recommended if you care about performance
    or want to create personal user word during usage
* [ZSaberLv0/ZFVimIM_wubi_base](https://github.com/ZSaberLv0/ZFVimIM_wubi_base) :
    wubi converted from [ywvim](https://github.com/vim-scripts/ywvim),
    I'm not familiar with wubi,
    just put it here in case you want to try
* [ZSaberLv0/ZFVimIM_english_base](https://github.com/ZSaberLv0/ZFVimIM_english_base) :
    english repo that contain common words
* [ZSaberLv0/ZFVimIM_japanese_base](https://github.com/ZSaberLv0/ZFVimIM_japanese_base) :
    japanese repo that contain common words

* [ZSaberLv0/ZFVimIM_pinyin](https://github.com/ZSaberLv0/ZFVimIM_pinyin) :
    pinyin repo which I personally used,
    update frequently
* [ZSaberLv0/ZFVimIM_pinyin_huge](https://github.com/ZSaberLv0/ZFVimIM_pinyin_huge) :
    huge pinyin repo that contains many words,
    it's converted from other IME and haven't been daily used,
    which may contain many useless words,
    I put it here just in case you prefer huge db or want to test huge db's performance


## FAQ

* Q: strange complete popup?

    A: we use `omnifunc` to achieve IM popup,
    which would conflict with most of complete engines,
    by default, we would automatically disable complete engines when IM started,
    if your other plugins conflict with IM,
    you may disable it manually
    ([see this](https://github.com/ZSaberLv0/ZFVimIM/blob/master/plugin/ZFVimIM_autoDisable.vim))

    also, if any strange behaviors occurred,
    `:verbose set omnifunc?` to check whether it's changed by other plugins

* Q: meet some weird problem, how to check log?

    A: use `:IMCloudLog` to check first, if not enough:

    1. put this in your vimrc: `let g:ZFJobVerboseLogEnable = 1`
    1. restart vim and reproduce your problem
    1. write log file by: `:call writefile(g:ZFJobVerboseLog, 'log.txt')`

    **WARNING** : the verbose log may contain your git access token or password,
    please verify before posting the log file to public

* Q: How to use in `Command-line` (search or command) ?

    A: ZFVimIM can be used inside `command-line-window`, you may:

    * (in normal mode) use `q:` or `q/` to enter `command-line-window`
    * (inside command line) use these keymaps to edit in `command-line-window`:

        ```
        function! ZF_Setting_cmdEdit()
            let cmdtype = getcmdtype()
            if cmdtype != ':' && cmdtype != '/'
                return ''
            endif
            call feedkeys("\<c-c>q" . cmdtype . 'k0' . (getcmdpos() - 1) . 'li', 'nt')
            return ''
        endfunction
        cnoremap <silent><expr> ;; ZF_Setting_cmdEdit()
        ```

        to use it: press `;;` while editing in `Command-line`

* Q: How to use in `:terminal`?

    A: since `terminal` does not support `omnifunc`,
    there's no direct way to support in it

    a workaround by `command-line-window`:

    ```
    if has('terminal') || has('nvim')
        function! PassToTerm(text)
            let @t = a:text
            if has('nvim')
                call feedkeys('"tpa', 'nt')
            else
                call feedkeys("a\<c-w>\"t", 'nt')
            endif
            redraw!
        endfunction
        command! -nargs=* PassToTerm :call PassToTerm(<q-args>)
        tnoremap ;; <c-\><c-n>q:a:PassToTerm<space>
    endif
    ```

    to use it: press `;;` while inside `:terminal` window's `Insert-mode`

* Q: external db source?

    A: the [ZSaberLv0/ZFVimIM_openapi](https://github.com/ZSaberLv0/ZFVimIM_openapi)
    is a good example, which achieves:

    * using external source to supply db contents
    * async mode

* Q: lazy db load?

    A: you may manually use these methods to achieve lazy load:

    * register:
        * `ZFVimIM_dbInit(...)` : register a empty db that can be toggle by
            `ZFVimIME_keymap_toggle_n()` or `ZFVimIME_keymap_next_n()`
    * db load:
        * `ZFVimIM_cloudRegister(...)` : (recommended) register cloud setting, and would load db content when called
        * `ZFVimIM_dbLoad(...)` : to load actual db content,
            can be called separately for split db,
            new data would be merged to old data
        * `g:ZFVimIM_db` : (not recommended) manually modify internal db data

* Q: arrow keys not work?

    A: [see this](https://vim.fandom.com/wiki/Fix_arrow_keys_that_display_A_B_C_D_on_remote_shell)


## known issue

* too slow

    check first: `executable('python')` or `executable('python3')`
    and `ZFVimJob` is installed and available
    (you may check them by `call ZFVimIM_DEBUG_checkHealth()`),
    without them, the pure vim script fallback is always very slow
    (about 2 seconds for 200KB db file)

    if your db file is very large,
    it's slow to save and load db even if `executable('python')`,
    because reading and processing large files also takes a long time

    this plugin is designed lightweight that can fallback to pure vimscript,
    so, there's no plan to completely move db data to python side
    (further more, async complete popup would break `:lmap` logic,
    and require features like LSP plugins,
    no plan to achieve this too)

    PS: you may want to check [ZSaberLv0/ZFVimIM_openapi](https://github.com/ZSaberLv0/ZFVimIM_openapi)
    for how to use external tool to supply db contents

    if you want to benchmark:

    1. `let g:ZFVimIM_DEBUG_profile = 1`
    1. input freely
    1. `call ZFVimIM_DEBUG_profileInfo()` to check which step consumed most time

    if issue still occurs, please supply log file before opening issue:

    1. `call ZFVimIM_DEBUG_start('/path/to/log')`
    1. input freely
    1. `call ZFVimIM_DEBUG_stop()`
    1. [open issue](https://github.com/ZSaberLv0/ZFVimIM/issues/new/choose)
        and supply the log file


* use with LSP plugins

    it's possible,
    but it's a better design to make a external executable for LSP plugins,
    not some vimscript like this plugin,
    so, no plan on this

    if you really want to hack, there's two idea:

    * use `ZFVimIM_complete()` to get word completion,
        and supply things like `omnifunc` for LSP plugins
    * use python or other tools to parse db files and supply LSP plugins

* can not use in `input()`

    unfortunately, I've no idea how to make `lmap` work in `input()`,
    and there's no plan to make complex `cmap` to achieve this

    of course, if you have better solution, PR is always welcomed

