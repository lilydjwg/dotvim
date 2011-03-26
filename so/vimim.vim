" =====================================================
"               " VimIM —— Vim 中文輸入法 "
" -----------------------------------------------------
"   VimIM -- Input Method by Vim, of Vim, for Vimmers
" =====================================================
let $VimIM = "$Date: 2011-01-15 15:03:22 -0800 (Sat, 15 Jan 2011) $"
let $VimIM = "$Revision: 4758 $"
let  VimIM = string("VimIM 經典:") "|         vim<C-6><C-6>
let  VimIM = string("VimIM 環境:") "|       vimim<C-6><C-6>
let  VimIM = string("VimIM 幫助:") "|   vimimhelp<C-6><C-6>

let egg  = ["http://vim.sf.net/scripts/script.php?script_id=2506"]
let egg += ["http://vimim-data.googlecode.com"]
let egg += ["http://groups.google.com/group/vimim"]
let egg += ["http://vimim.googlecode.com/svn/vimim/vimim.html"]
let egg += ["http://vimim.googlecode.com/svn/vimim/vimim.vim.html"]
let egg += ["http://code.google.com/p/vimim/issues/list"]

let VimIM = " ====  Introduction      ==== {{{"
" ============================================
"       File: vimim.vim
"     Author: vimim <vimim@googlegroups.com>
"    License: GNU Lesser General Public License
"    Readme:  VimIM is a Vim plugin designed as an independent IM
"             (Input Method) to support the input of multi-byte.
" -----------------------------------------------------------
"  Features: * "Plug & Play": as a client to VimIM embedded backends
"            * "Plug & Play": as a client to "myCloud" and "Cloud"
"            * CJK can be searched without using popup menu
"            * CJK can be input without changing mode
"            * support "wubi", "erbi", "boshiamy", "cangjie", "taijima"
"            * support "pinyin" plus 6 "shuangpin" plus "digit filter"
"            * support direct internal code (UNICODE/GBK/Big5) input
" -----------------------------------------------------------
" "VimIM Design Goal"
"  (1) Chinese can be searched using Vim without menu
"  (2) Chinese can be input using Vim regardless of encoding and OS
"  (3) No negative impact to Vim when VimIM is not used
"  (4) No compromise for high speed and low memory usage
" -----------------------------------------------------------
" "VimIM Front End UI"
"  (1) VimIM OneKey: Chinese input without mode change.
"  (2) VimIM Chinese Input Mode: ['dynamic','static']
"  (3) VimIM auto Chinese input with zero configuration
" -----------------------------------------------------------
" "VimIM Back End Engine"
"  (1) [external] myCloud: http://pim-cloud.appspot.com
"  (2) [external]   Cloud: http://web.pinyin.sogou.com
"  (3) [embedded] VimIM:   http://vimim.googlecode.com
"      (3.1) a datafile:   $VIM/vimfiles/plugin/vimim.pinyin.txt
"      (3.2) a directory:  $VIM/vimfiles/plugin/vimim/pinyin/
"  -----------------------------------------------------------
" "VimIM Installation"
"  (1) drop this file to plugin/:  plugin/vimim.vim
"  (2) [option] drop a datafile:   plugin/vimim.pinyin.txt
"  (3) [option] drop a directory:  plugin/vimim/pinyin/
" -----------------------------------------------------------

let s:vimims = [VimIM]
" ======================================== }}}
let VimIM = " ====  Initialization    ==== {{{"
" ============================================
call add(s:vimims, VimIM)
if exists("b:loaded_vimim") || &cp || v:version<700
    finish
endif
scriptencoding utf-8
let b:loaded_vimim = 1
let s:vimimhelp = egg
let s:path = expand("<sfile>:p:h")."/"

" -----------------------------------------
function! s:vimim_frontend_initialization()
" -----------------------------------------
    sil!call s:vimim_force_scan_current_buffer()
    sil!call s:vimim_initialize_shuangpin()
    sil!call s:vimim_initialize_keycode()
    sil!call s:vimim_set_special_im_property()
    sil!call s:vimim_initialize_frontend_punctuation()
    sil!call s:vimim_build_digit_filter_cache()
    sil!call s:vimim_build_datafile_lines()
    sil!call s:vimim_localization()
    sil!call s:vimim_initialize_skin()
endfunction

" ---------------------------------------------
function! s:vimim_backend_initialization_once()
" ---------------------------------------------
    if empty(s:backend_loaded)
        let s:backend_loaded = 1
    else
        return
    endif
    " -----------------------------------------
    sil!call s:vimim_initialize_session()
    sil!call s:vimim_initialize_frontend()
    sil!call s:vimim_initialize_backend()
    sil!call s:vimim_initialize_i_setting()
    sil!call s:vimim_dictionary_chinese()
    sil!call s:vimim_dictionary_punctuation()
    sil!call s:vimim_dictionary_im_keycode()
    sil!call s:vimim_scan_backend_embedded_directory()
    sil!call s:vimim_scan_backend_embedded_datafile()
    sil!call s:vimim_dictionary_quantifiers()
    sil!call s:vimim_scan_backend_mycloud()
    sil!call s:vimim_scan_backend_cloud()
    sil!call s:vimim_initialize_keycode()
endfunction

" ------------------------------
function! s:vimim_set_encoding()
" ------------------------------
    let s:encoding = "utf8"
    if &encoding == "chinese"
    \|| &encoding == "cp936"
    \|| &encoding == "gb2312"
    \|| &encoding == "gbk"
    \|| &encoding == "euc-cn"
        let s:encoding = "chinese"
    elseif &encoding == "taiwan"
    \|| &encoding == "cp950"
    \|| &encoding == "big5"
    \|| &encoding == "euc-tw"
        let s:encoding = "taiwan"
    endif
endfunction

" ------------------------------------
function! s:vimim_initialize_session()
" ------------------------------------
    call s:vimim_start_omni()
    call s:vimim_super_reset()
    call s:vimim_set_encoding()
    " --------------------------------
    let s:www_executable = 0
    let s:www_libcall = 0
    let s:vimim_cloud_plugin = 0
    " --------------------------------
    let s:one_key_correction = 0
    let s:shuangpin_keycode_chinese = {}
    let s:shuangpin_table = {}
    let s:quanpin_table = {}
    let s:unihan_4corner_cache = {}
    let s:pinyin_4corner_filter = 0
    let s:xingma = ['wubi', 'erbi', '4corner']
    " --------------------------------
    let s:abcd = "'abcdefgz"
    let s:qwerty = range(10)
    let s:quantifiers = {}
    let s:localization = 0
    let s:tail = ""
    " --------------------------------
    let s:current_positions = [0,0,1,0]
    let s:smart_single_quotes = 1
    let s:smart_double_quotes = 1
    let s:seamless_positions = []
    let s:start_row_before = 0
    let s:start_column_before = 1
    let s:scriptnames_output = 0
    let s:popupmenu_list = []
    " --------------------------------
    let A = char2nr('A')
    let Z = char2nr('Z')
    let a = char2nr('a')
    let z = char2nr('z')
    let Az_nr_list = extend(range(A,Z), range(a,z))
    let s:Az_list = map(Az_nr_list,"nr2char(".'v:val'.")")
    let s:az_list = map(range(a,z),"nr2char(".'v:val'.")")
    let s:AZ_list = map(range(A,Z),"nr2char(".'v:val'.")")
    " --------------------------------
    let s:valid_key = 0
    let s:valid_keys = s:az_list
    let s:debug_count = 0
    let s:debugs = []
endfunction

" -------------------------------
function! s:vimim_chinese(english)
" -------------------------------
    let key = a:english
    let chinese = a:english
    if has_key(s:chinese, key)
        let chinese = get(s:chinese[key], 0)
        if v:lc_time !~ 'gb2312' && len(s:chinese[key]) > 1
            let chinese = get(s:chinese[key], 1)
        endif
    endif
    return chinese
endfunction

" ------------------------------------
function! s:vimim_dictionary_chinese()
" ------------------------------------
    let s:space = "　"
    let s:plus  = "＋"
    let s:colon = "："
    let s:left = "【"
    let s:right = "】"
    let s:chinese = {}
    let s:chinese['auto'] = ['自动','自動']
    let s:chinese['error'] = ['错误','錯誤']
    let s:chinese['digit'] = ['数码','數碼']
    let s:chinese['directory'] = ['目录','目錄']
    let s:chinese['datafile'] = ['词库','詞庫']
    let s:chinese['computer'] = ['电脑','電腦']
    let s:chinese['encoding'] = ['编码','編碼']
    let s:chinese['environment'] = ['环境','環境']
    let s:chinese['input'] = ['输入','輸入']
    let s:chinese['font'] = ['字体','字體']
    let s:chinese['myversion'] = ['版本']
    let s:chinese['classic'] = ['经典','經典']
    let s:chinese['static'] = ['静态','靜態']
    let s:chinese['dynamic'] = ['动态','動態']
    let s:chinese['style'] = ['风格','風格']
    let s:chinese['wubi'] = ['五笔','五筆']
    let s:chinese['english'] = ['英文']
    let s:chinese['hangul'] = ['韩文','韓文']
    let s:chinese['xinhua'] = ['新华','新華']
    let s:chinese['pinyin'] = ['拼音']
    let s:chinese['boshiamy'] = ['呒虾米','嘸蝦米']
    let s:chinese['zhengma'] = ['郑码','鄭碼']
    let s:chinese['cangjie'] = ['仓颉','倉頡']
    let s:chinese['taijima'] = ['太极码','太極碼']
    let s:chinese['yong'] = ['永码','永碼']
    let s:chinese['quick'] = ['速成']
    let s:chinese['wu'] = ['吴语','吳語']
    let s:chinese['phonetic'] = ['注音']
    let s:chinese['array30'] = ['行列']
    let s:chinese['erbi'] = ['二笔','二筆']
    let s:chinese['shezhi'] = ['设置','設置']
    let s:chinese['jidian'] = ['极点','極點']
    let s:chinese['newcentury'] = ['新世纪','新世紀']
    let s:chinese['shuangpin'] = ['双拼','雙拼']
    let s:chinese['abc'] = ['智能双打','智能雙打']
    let s:chinese['ms'] = ['微软','微軟']
    let s:chinese['nature'] = ['自然码','自然碼']
    let s:chinese['purple'] = ['紫光']
    let s:chinese['plusplus'] = ['加加']
    let s:chinese['flypy'] = ['小鹤','小鶴']
    let s:chinese['sogou'] = ['搜狗云','搜狗雲']
    let s:chinese['cloud_atwill'] = ['想云就云','想雲就雲']
    let s:chinese['mycloud'] = ['自己的云','自己的雲']
    let s:chinese['onekey'] = ['点石成金','點石成金']
endfunction

" ---------------------------------------
function! s:vimim_dictionary_im_keycode()
" ---------------------------------------
    let s:im_keycode = {}
    let s:im_keycode['sogou']    = "[0-9a-z.]"
    let s:im_keycode['mycloud']  = "[0-9a-z'.]"
    let s:im_keycode['pinyin']   = "[0-9a-z']"
    let s:im_keycode['wubi']     = "[0-9a-z']"
    let s:im_keycode['english']  = "[0-9a-z']"
    let s:im_keycode['hangul']   = "[0-9a-z']"
    let s:im_keycode['xinhua']   = "[0-9a-z']"
    let s:im_keycode['4corner']  = "[0-9a-z']"
    let s:im_keycode['zhengma']  = "[a-z']"
    let s:im_keycode['cangjie']  = "[a-z']"
    let s:im_keycode['taijima']  = "[a-z']"
    let s:im_keycode['quick']    = "[0-9a-z']"
    let s:im_keycode['erbi']     = "[a-z'.,;/]"
    let s:im_keycode['wu']       = "[a-z'.]"
    let s:im_keycode['yong']     = "[a-z'.;/]"
    let s:im_keycode['nature']   = "[a-z'.]"
    let s:im_keycode['boshiamy'] = "[][a-z'.,]"
    let s:im_keycode['phonetic'] = "[0-9a-z.,;/]"
    let s:im_keycode['array30']  = "[0-9a-z.,;/]"
    " -------------------------------------------
    let vimimkeys = copy(keys(s:im_keycode))
    call add(vimimkeys, 'pinyin_quote_sogou')
    call add(vimimkeys, 'pinyin_huge')
    call add(vimimkeys, 'pinyin_fcitx')
    call add(vimimkeys, 'pinyin_canton')
    call add(vimimkeys, 'pinyin_hongkong')
    call add(vimimkeys, 'wubijd')
    call add(vimimkeys, 'wubi98')
    call add(vimimkeys, 'wubi2000')
    call insert(vimimkeys, 'pinyin')
    let s:all_vimim_input_methods = copy(vimimkeys)
    " -------------------------------------------
endfunction

" -------------------------------------------------------
function! s:vimim_expand_character_class(character_class)
" -------------------------------------------------------
    let character_string = ""
    let i = 0
    while i < 256
        let char = nr2char(i)
        if char =~# a:character_class
            let character_string .= char
        endif
        let i += 1
    endwhile
    return character_string
endfunction

" ------------------------------------
function! s:vimim_initialize_keycode()
" ------------------------------------
    let keycode = s:backend[s:ui.root][s:ui.im].keycode
    if !empty(s:vimim_shuangpin)
        let keycode = s:shuangpin_keycode_chinese.keycode
    endif
    let s:valid_key = copy(keycode)
    let keycode_real = s:vimim_expand_character_class(keycode)
    let s:valid_keys = split(keycode_real, '\zs')
endfunction

" ======================================== }}}
let VimIM = " ====  Customization     ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_initialize_global()
" -----------------------------------
    let s:global_defaults = []
    let s:global_customized = []
    " -------------------------------
    let G = []
    call add(G, "g:vimim_ctrl_space_to_toggle")
    call add(G, "g:vimim_tab_as_onekey")
    call add(G, "g:vimim_data_directory")
    call add(G, "g:vimim_private_data_directory")
    call add(G, "g:vimim_private_data_file")
    call add(G, "g:vimim_data_file")
    call add(G, "g:vimim_vimimdata")
    call add(G, "g:vimim_libvimdll")
    call add(G, "g:vimim_backslash_close_pinyin")
    call add(G, "g:vimim_english_punctuation")
    call add(G, "g:vimim_imode_pinyin")
    call add(G, "g:vimim_latex_suite")
    call add(G, "g:vimim_shuangpin")
    call add(G, "g:vimim_mycloud_url")
    call add(G, "g:vimim_cloud_sogou")
    call add(G, "g:vimim_chinese_input_mode")
    call add(G, "g:vimim_use_cache")
    call add(G, "g:vimimdebug")
    " -----------------------------------
    call s:vimim_set_global_default(G, 0)
    " -----------------------------------
    let G = []
    call add(G, "g:vimim_custom_skin")
    call add(G, "g:vimim_search_next")
    call add(G, "g:vimim_chinese_punctuation")
    " -----------------------------------
    call s:vimim_set_global_default(G, 1)
    " -----------------------------------
    let s:backend_loaded = 0
    let s:chinese_input_mode = "onekey"
    if empty(s:vimim_chinese_input_mode)
        let s:vimim_chinese_input_mode = "dynamic"
    endif
endfunction

" ----------------------------------------------------
function! s:vimim_set_global_default(options, default)
" ----------------------------------------------------
    for variable in a:options
        call add(s:global_defaults, variable .'='. a:default)
        let s_variable = substitute(variable,"g:","s:",'')
        if exists(variable)
            call add(s:global_customized, variable .'='. eval(variable))
            exe 'let '. s_variable .'='. variable
            exe 'unlet! ' . variable
        else
            exe 'let '. s_variable . '=' . a:default
        endif
    endfor
endfunction

" ======================================== }}}
let VimIM = " ====  Easter_Egg        ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ------------------------------
function! s:vimim_egg_vimimegg()
" ------------------------------
    let eggs = []
    call add(eggs, "經典　vim")
    call add(eggs, "環境　vimim")
    call add(eggs, "程式　vimimvim")
    call add(eggs, "幫助　vimimhelp")
    call add(eggs, "測試　vimimdebug")
    call add(eggs, "設置　vimimdefaults")
    return map(eggs,  '"VimIM 彩蛋" . s:colon . v:val . s:space')
endfunction

" -------------------------
function! s:vimim_egg_vim()
" -------------------------
    let eggs  = ["vi        文本編輯器"]
    let eggs += ["vim   最牛文本編輯器"]
    let eggs += ["vim   精力"]
    let eggs += ["vim   生氣"]
    let eggs += ["vimim 中文輸入法"]
    return eggs
endfunction

" ------------------------------
function! s:vimim_egg_vimimvim()
" ------------------------------
    let eggs = copy(s:vimims)
    let egg = "strpart(" . 'v:val' . ", 0, 28)"
    return map(eggs, egg)
endfunction

" -----------------------------------
function! s:vimim_egg_vimimdefaults()
" -----------------------------------
    let eggs = copy(s:global_defaults)
    let egg = '"VimIM  " . v:val . s:space'
    return map(eggs, egg)
endfunction

" -------------------------------
function! s:vimim_egg_vimimhelp()
" -------------------------------
    let eggs = []
    " ---------------------------------------------------
    call add(eggs, "官方网址" . s:colon . s:vimimhelp[0])
    call add(eggs, "民间词库" . s:colon . s:vimimhelp[1])
    call add(eggs, "新闻论坛" . s:colon . s:vimimhelp[2])
    call add(eggs, "最新主页" . s:colon . s:vimimhelp[3])
    call add(eggs, "最新程式" . s:colon . s:vimimhelp[4])
    call add(eggs, "错误报告" . s:colon . s:vimimhelp[5])
    " ---------------------------------------------------
    return map(eggs, '"VimIM " . v:val . s:space')
endfunction

" ---------------------------
function! s:vimim_egg_vimim()
" ---------------------------
    let eggs = []
    if has("win32unix")
        let option = "cygwin"
    elseif has("win32")
        let option = "Windows32"
    elseif has("win64")
        let option = "Windows64"
    elseif has("unix")
        let option = "unix"
    elseif has("macunix")
        let option = "macunix"
    endif
    " ----------------------------------
    let input = s:vimim_chinese('input')
    let myversion = s:vimim_chinese('myversion')
    let myversion = "\t " . myversion . s:colon
    let font = s:vimim_chinese('font') . s:colon
    let environment = s:vimim_chinese('environment') . s:colon
    let encoding = s:vimim_chinese('encoding') . s:colon
    " ----------------------------------
    let option .= "_" . &term
    let computer = s:vimim_chinese('computer')
    let option = "computer " . computer . s:colon . option
    call add(eggs, option)
    " ----------------------------------
    let option = v:progname . s:space
    let option = "Vim" . myversion  . option . v:version
    call add(eggs, option)
    " ----------------------------------
    let option = get(split($VimIM), 1)
    if empty(option)
        let msg = "not a SVN check out, revision number not available"
    else
        let option = "VimIM" . myversion . "vimim.vim" . s:space . option
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = "encoding " . encoding . &encoding
    call add(eggs, option)
    " ----------------------------------
    let option = "fencs\t "  . encoding . &fileencodings
    call add(eggs, option)
    " ----------------------------------
    if has("gui_running")
        let option = "fonts\t " . font . &guifontwide
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = "lc_time\t " . environment . v:lc_time
    call add(eggs, option)
    " ----------------------------------
    let toggle = "i_CTRL-Bslash"
    let buffer = expand("%:p:t")
    if buffer =~# '.vimim\>'
        let auto = s:vimim_chinese('auto')
        let toggle = auto . s:space . buffer
    elseif s:vimim_ctrl_space_to_toggle == 1
        let toggle = "toggle_with_CTRL-Space"
    elseif s:vimim_tab_as_onekey == 1
        let toggle = "Tab_as_OneKey"
    elseif s:vimim_tab_as_onekey == 2
        let toggle = "Tab_as_OneKey_with_NonStop_hjkl"
    endif
    let toggle .= s:space
    let style = s:vimim_chinese('style')
    let option = "mode\t " . style . s:colon . toggle
    call add(eggs, option)
    " ----------------------------------
    let im = s:vimim_statusline()
    if !empty(im)
        let option = "im\t " . input . s:colon . im
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = s:backend[s:ui.root][s:ui.im].datafile
    let ciku = s:vimim_chinese('datafile') . s:colon
    if !empty(option)
        if s:ui.root == 'directory'
            let directory  = s:vimim_chinese('directory')
            let ciku .= directory . ciku
            let option .= "/"
        endif
        let ciku = "database " . ciku
        let option = ciku . option
        call add(eggs, option)
    endif
    " ----------------------------------
    let option = 0
    if s:pinyin_4corner_filter == 2
        if !empty(s:vimim_data_directory)
            let option = ciku . s:vimim_data_directory . "unihan/"
        endif
    elseif s:pinyin_4corner_filter == 1
        let ciku = "database " . s:vimim_chinese('digit') . s:colon
        let option = ciku . s:path . "vimim.unihan_4corner.txt"
    endif
    if !empty(option)
        call add(eggs, option)
    endif
    " ----------------------------------
    if s:vimim_cloud_sogou == 888
        let CLOUD = s:vimim_chinese('cloud_atwill')
        let sogou = s:vimim_chinese('sogou')
        let option = "cloud\t " . sogou . s:colon
        let option .= CLOUD
        call add(eggs, option)
    endif
    " ----------------------------------
    if empty(s:global_customized)
        let msg = "no global variable is set"
    else
        for item in s:global_customized
            let shezhi = s:vimim_chinese('shezhi')
            let option = "VimIM\t " . shezhi . s:colon . item
            call add(eggs, option)
        endfor
    endif
    " ----------------------------------
    if !empty(v:exception)
        let error = s:vimim_chinese('error')
        let option = "error\t " . error . s:colon . v:exception
        call add(eggs, option)
    endif
    " ----------------------------------
    return map(eggs, 'v:val . s:space')
endfunction

" ----------------------------------------
function! s:vimim_easter_chicken(keyboard)
" ----------------------------------------
    let egg = a:keyboard
    if egg =~# s:valid_key
        let msg = "hunt easter egg ... vim<C-6>"
    else
        return []
    endif
    try
        return eval("<SID>vimim_egg_".egg."()")
    catch
        call s:debugs('egg::exception=', v:exception)
        return []
    endtry
endfunction

" ======================================== }}}
let VimIM = " ====  /Search           ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" -----------------------------
function! g:vimim_search_next()
" -----------------------------
    let english = @/
    if english =~ '\<' && english =~ '\>'
        let english = substitute(english,'[<>\\]','','g')
    endif
    if !empty(v:errmsg) && !empty(english)
    \&& len(english) < 24 && len(english) > 1
    \&& english =~ '\w' && english != '\W' && english !~ '_'
    \&& v:errmsg =~# '^E486: ' && v:errmsg =~# english
        try
            sil!call s:vimim_get_chinese_from_english(english)
            echon "/" . english
        catch
            echon "/" . english . " error:" .  v:exception
        endtry
        let s:menu_digit_as_filter = ""
    endif
endfunction

" -------------------------------------------------
function! s:vimim_get_chinese_from_english(english)
" -------------------------------------------------
    let results = []
    let english = tolower(a:english)
    let ddddd = s:vimim_get_unicode_ddddd(english)
    let results = s:vimim_get_unicodes([ddddd], 0)
    if empty(results)
        sil!call s:vimim_backend_initialization_once()
        if !empty(s:vimim_shuangpin)
            sil!call s:vimim_initialize_shuangpin()
            let english = s:vimim_get_pinyin_from_shuangpin(english)
        endif
        if s:vimim_cloud_sogou == 1
            let results = s:vimim_get_cloud_sogou(english, 1)
        endif
    endif
    if empty(results)
        if empty(s:backend.datafile) && empty(s:backend.directory)
            if empty(s:vimim_cloud_plugin)
                let results = s:vimim_get_cloud_sogou(english, 1)
            else
                let results = s:vimim_get_mycloud_plugin(english)
            endif
        else
            let blocks = [english]
            "  search by multiple 4corner: /77124002 for 马力
            if english =~ '\d' && english != '\l' && len(english)%4<1
                let blocks = s:vimim_break_digit_every_four(english)
            endif
            for block in copy(blocks)
                let blocks = s:vimim_embedded_backend_engine(block)
                let results += blocks
            endfor
        endif
    endif
    call s:vimim_register_search_pattern(english, results)
endfunction

" ---------------------------------------------------------
function! s:vimim_register_search_pattern(english, results)
" ---------------------------------------------------------
    if empty(a:results)
        return
    endif
    let results = []
    let english = a:english
    if english =~ '^\l\+\d\+'
        let english = join(split(english,'\d'),'')
    elseif english =~ '^\d\d\d\+'
        let english = english[:3]
    endif
    for pair in a:results
        let pairs = split(pair)
        let menu = get(pairs, 0)
        let chinese = get(pairs, 1)
        if chinese =~ '\w'
            continue
        elseif english != menu
            continue
        else
            call add(results, chinese)
        endif
    endfor
    if !empty(results)
        let slash = join(results, '\|')
        if empty(search(slash,'nw'))
            let @/ = a:english
        else
            let @/ = slash
        endif
        echon "/" . a:english
    endif
endfunction

" --------------------------------------------
function! s:vimim_get_unicodes(unicodes, more)
" --------------------------------------------
    let unicodes = a:unicodes
    if empty(unicodes) || empty(get(unicodes,0))
        return []
    endif
    let results = []
    for ddddd in unicodes
        let menu = s:vimim_unicode_4corner_pinyin(ddddd, a:more)
        let menu_chinese = menu .' '. nr2char(ddddd)
        call add(results, menu_chinese)
    endfor
    return results
endfunction

" ---------------------------------------------------
function! s:vimim_unicode_4corner_pinyin(ddddd, more)
" ---------------------------------------------------
    let menu = printf('u%04x',a:ddddd) . s:space . a:ddddd
    if a:more > 0 && s:pinyin_4corner_filter > 0
        let chinese = nr2char(a:ddddd)
        call s:vimim_build_unihan_reverse_cache(chinese)
        let unihan = get(s:vimim_reverse_one_entry(chinese,'unihan'),0)
        let pinyin = get(s:vimim_reverse_one_entry(chinese,'pinyin'),0)
        if empty(unihan) && empty(pinyin)
            let msg = 'no need to print out sparse matrix'
        else
            let menu .= s:space . unihan
            let menu .= s:space . pinyin
        endif
    endif
    return menu
endfunction

" -----------------------------------
function! g:vimim_search_pumvisible()
" -----------------------------------
    let word = s:vimim_popup_word()
    if empty(word)
        let @/ = @_
    else
        let @/ = word
    endif
    let repeat_times = len(word)/s:multibyte
    let row_start = s:start_row_before
    let row_end = line('.')
    let delete_chars = ""
    if repeat_times > 0 && row_end == row_start
        let delete_chars = repeat("\<BS>", repeat_times)
    endif
    let slash = delete_chars . "\<Esc>"
    sil!call s:vimim_stop()
    sil!exe 'sil!return "' . slash . '"'
endfunction

" ======================================== }}}
let VimIM = " ====  OneKey            ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" input method english:    i'have'a'dream
" input method pinyin:     wo'you'yige'meng
" input method wubi:       trde'ggwh'ssqu
" input method wubi2000:   q'e'ggwh'ssq
" input method cantonese:  ngoh'yau'yat'goh'mung
" input method wu:         ngu'qyoe'iq'qku'qmon
" input method zhengma:    m'gq'avov'ffrs
" input method cangjie:    hqi'kb'm'ol'ddni
" input method taijima:    tlt'fm't'e'vvi
" input method nature:     wop'yb'yg''mgx
" input method boshiamy:   ix'x'e'bii'rfnc
" --------------------------------------------
function! s:vimim_break_word_by_word(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    let blocks = []
    if s:chinese_input_mode == 'onekey'
    \&& s:ui.has_dot != 2
    \&& keyboard =~ "[']"
    \&& keyboard[0:0] != "'"
    \&& keyboard[-1:-1] != "'"
        let blocks = split(keyboard, "[']")
        if !empty(blocks)
            let head = get(blocks, 0)
            let blocks = s:vimim_break_pinyin_digit(head)
            if empty(blocks)
                let blocks = [head]
            endif
        endif
    endif
    return blocks
endfunction

" ---------------------
function! <SID>OneKey()
" ---------------------
" (1) <OneKey> => start OneKey as "hit and run"
" (2) <OneKey> => stop  OneKey and print out menu
" -----------------------------------------------
    let onekey = -1
    let byte_before = getline(".")[col(".")-2]
    if empty(byte_before) || byte_before =~ '\s'
        if s:vimim_tab_as_onekey > 0
            let onekey = "\t"
        else
            let onekey = ""
        endif
    endif
    if onekey < 0
        sil!call s:vimim_start_onekey()
        let onekey = s:vimim_onekey_action("")
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" ------------------------------
function! s:vimim_start_onekey()
" ------------------------------
    sil!call s:vimim_backend_initialization_once()
    sil!call s:vimim_frontend_initialization()
    sil!call s:vimim_start()
    sil!call s:vimim_onekey_label_navigation_on()
    sil!call s:vimim_onekey_pumvisible_capital_on()
    sil!call s:vimim_onekey_1234567890_filter_on()
    sil!call s:vimim_punctuation_navigation_on()
endfunction

" --------------------------
function! s:vimim_space_on()
" --------------------------
    inoremap <Space> <C-R>=g:vimim_space()<CR>
                    \<C-R>=g:vimim_reset_after_insert()<CR>
endfunction

" -----------------------
function! g:vimim_space()
" -----------------------
    let space = " "
    if pumvisible()
        let space = "\<C-Y>"
        let s:pumvisible_yes = 1
    elseif s:chinese_input_mode == 'static'
        let space = s:vimim_static_action(space)
    elseif s:chinese_input_mode == 'onekey'
        let space = s:vimim_onekey_action(space)
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" <Space> multiple play in OneKey:
"   (1) after English (valid keys) => trigger keycode menu
"   (2) after omni popup menu      => insert Chinese
"   (3) after English punctuation  => Chinese punctuation
"   (4) after Chinese              => <Space>
" -------------------------------------
function! s:vimim_onekey_action(onekey)
" -------------------------------------
    let onekey = ""
    if pumvisible()
        if s:pattern_not_found > 0
            let s:pattern_not_found = 0
            let onekey = " "
        else
            let onekey  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
            let onekey .= '\<C-R>=g:vimim_pumvisible_dump()\<CR>'
        endif
        sil!exe 'sil!return "' . onekey . '"'
    endif
    if s:insert_without_popup > 0
        let s:insert_without_popup = 0
    endif
    " ---------------------------------------------------
    let before = getline(".")[col(".")-2]
    let char_before_before = getline(".")[col(".")-3]
    if char_before_before !~# "[0-9A-z]"
    \&& has_key(s:punctuations, before)
    \&& empty(s:ui.has_dot)
        for char in keys(s:punctuations_all)
            if char_before_before ==# char
                let onekey = a:onekey
                break
            else
                continue
            endif
        endfor
        if empty(onekey)
            let msg = "transform punctuation from english to chinese"
            let replacement = s:punctuations[before]
            let onekey = "\<BS>" . replacement
            sil!exe 'sil!return "' . onekey . '"'
        endif
    endif
    " -------------------------------------------------
    if before !~# s:valid_key && empty(a:onekey)
        return s:vimim_get_unicode_menu()
    endif
    " ---------------------------------------------------
    if before ==# "'" && empty(s:ui.has_dot)
        let s:pattern_not_found = 0
    endif
    " ---------------------------------------------------
    if s:seamless_positions != getpos(".")
    \&& s:pattern_not_found < 1
        let onekey = '\<C-R>=g:vimim()\<CR>'
    else
        let onekey = ""
    endif
    " ---------------------------------------------------
    if empty(before) || before =~ '\s' || before !~# s:valid_key
        let onekey = a:onekey
    endif
    " ---------------------------------------------------
    let s:smart_enter = 0
    let s:pattern_not_found = 0
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" -----------------------------------------
function! s:vimim_get_unicode_char_before()
" -----------------------------------------
" [unicode] OneKey to trigger Chinese with omni menu"
    let byte_before = getline(".")[col(".")-2]
    if empty(byte_before) || byte_before =~# s:valid_key
        return 0
    endif
    let start = s:multibyte + 1
    let char_before = getline(".")[col(".")-start : col(".")-2]
    let ddddd = char2nr(char_before)
    let xxxx = 0
    if ddddd > 127
        let xxxx = printf('u%04x', ddddd)
    endif
    return xxxx
endfunction

" ======================================== }}}
let VimIM = " ====  Chinese_Mode      ==== {{{"
" ============================================
call add(s:vimims, VimIM)
" ----------------------------------------------------------------------
" s:chinese_input_mode='onekey'  => (default) OneKey: hjkl and hit-and-run
" s:chinese_input_mode='dynamic' => (default) classic dynamic mode
" s:chinese_input_mode='static'  =>   <Space> triggers menu, auto
" ----------------------------------------------------------------------

" --------------------------
function! <SID>ChineseMode()
" --------------------------
    call s:vimim_backend_initialization_once()
    call s:vimim_frontend_initialization()
    call s:vimim_initialize_statusline()
    call s:vimim_build_datafile_cache()
    let s:chinese_input_mode = s:vimim_chinese_input_mode
    let action = ""
    if !empty(s:ui.root) && !empty(s:ui.im)
        let action = <SID>vimim_chinesemode_action()
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

" ---------------------------------------
function! <SID>vimim_chinesemode_action()
" ---------------------------------------
    let action = ""
    let s:backend[s:ui.root][s:ui.im].chinese_mode_switch += 1
    let switch=s:backend[s:ui.root][s:ui.im].chinese_mode_switch % 2
    if empty(switch)
        sil!call s:vimim_start()
        sil!call <SID>vimim_toggle_punctuation()
        if s:chinese_input_mode == 'dynamic'
            sil!call <SID>vimim_set_seamless()
            sil!call s:vimim_dynamic_alphabet_trigger()
        elseif s:chinese_input_mode == 'static'
            sil!call s:vimim_static_alphabet_auto_select()
            if pumvisible()
                let msg = "<C-\> does nothing on omni menu"
            else
                let action = s:vimim_static_action("")
            endif
        endif
    else
        call s:vimim_stop()
        if mode() == 'i'
            let action = "\<C-O>:redraw\<CR>"
        elseif mode() == 'n'
            :redraw!
        endif
    endif
    sil!exe 'sil!return "' . action . '"'
endfunction

" ------------------------------------
function! s:vimim_static_action(space)
" ------------------------------------
    let space = a:space
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~# s:valid_key
        if s:pattern_not_found < 1
            let space = '\<C-R>=g:vimim()\<CR>'
        else
            let s:pattern_not_found = 0
        endif
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ---------------------------------------------
function! s:vimim_static_alphabet_auto_select()
" ---------------------------------------------
    for char in s:Az_list
        sil!exe 'inoremap <silent> ' . char . '
        \ <C-R>=g:vimim_pumvisible_ctrl_y()<CR>'. char .
        \'<C-R>=g:vimim_reset_after_auto_insert()<CR>'
    endfor
endfunction

" ------------------------------------------
function! s:vimim_dynamic_alphabet_trigger()
" ------------------------------------------
    if s:chinese_input_mode !~ 'dynamic'
        return
    endif
    let not_used_valid_keys = "[0-9.']"
    if s:ui.has_dot == 1
        let not_used_valid_keys = "[0-9]"
    endif
    " --------------------------------------
    for char in s:valid_keys
        if char !~# not_used_valid_keys
            sil!exe 'inoremap <silent> ' . char . '
            \ <C-R>=g:vimim_pumvisible_ctrl_e_ctrl_y()<CR>'. char .
            \'<C-R>=g:vimim()<CR>'
        endif
    endfor
endfunction

" ------------------------------------------
function! g:vimim_pumvisible_ctrl_e_ctrl_y()
" ------------------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        if s:ui.im =~ 'wubi'
        \&& empty(len(s:keyboard_leading_zero)%4)
            let key = "\<C-Y>"
            let s:pumvisible_yes = 1
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ---------------------------------
function! <SID>vimim_set_seamless()
" ---------------------------------
    let s:seamless_positions = getpos(".")
    let s:keyboard_leading_zero = ""
    return ""
endfunction

" -----------------------------------------------
function! s:vimim_get_seamless(current_positions)
" -----------------------------------------------
    if empty(s:seamless_positions)
    \|| empty(a:current_positions)
        return -1
    endif
    let seamless_bufnum = s:seamless_positions[0]
    let seamless_lnum = s:seamless_positions[1]
    let seamless_off = s:seamless_positions[3]
    if seamless_bufnum != a:current_positions[0]
    \|| seamless_lnum != a:current_positions[1]
    \|| seamless_off != a:current_positions[3]
        let s:seamless_positions = []
        return -1
    endif
    let seamless_column = s:seamless_positions[2]-1
    let start_column = a:current_positions[2]-1
    let len = start_column - seamless_column
    let start_row = a:current_positions[1]
    let current_line = getline(start_row)
    let snip = strpart(current_line, seamless_column, len)
    if empty(len(snip))
        return -1
    endif
    if snip =~# 'u\x\x\x\x'
        let meg = 'support onekey after CJK'
    else
        let snips = split(snip, '\zs')
        for char in snips
            if char !~# s:valid_key
                return -1
            endif
        endfor
    endif
    let s:start_row_before = seamless_lnum
    let s:smart_enter = 0
    return seamless_column
endfunction

" ======================================== }}}
let VimIM = " ====  User_Interface    ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ---------------------------------
function! s:vimim_initialize_skin()
" ---------------------------------
    if s:vimim_custom_skin > 1
        highlight! link PmenuSel   Title
        highlight! link StatusLine Title
        highlight!      Pmenu      NONE
        highlight!      PmenuSbar  NONE
        highlight!      PmenuThumb NONE
    endif
endfunction

" ---------------------------------------
function! s:vimim_initialize_statusline()
" ---------------------------------------
    if s:vimim_custom_skin < 0
        return
    endif
    if s:vimim_custom_skin < 3
        sil!call s:vimim_set_statusline()
    else
        echoh NonText | echo s:vimim_statusline() | echohl None
    endif
endfunction

" --------------------------------
function! s:vimim_set_statusline()
" --------------------------------
    set laststatus=2
    if empty(&statusline)
        set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P%{IMName()}
    elseif &statusline =~ 'IMName'
        " nothing, because it is already in the statusline
    elseif &statusline =~ '\V\^%!'
        let &statusline .= '.IMName()'
    else
        let &statusline .= '%{IMName()}'
    endif
endfunction

" ------------------------------------
function! s:vimim_cursor_color(switch)
" ------------------------------------
    if empty(a:switch)
        set ruler
        highlight! Cursor  guifg=bg   guibg=fg
    else
        set noruler
        highlight! Cursor  guifg=bg   guibg=green
    endif
endfunction

" ----------------
function! IMName()
" ----------------
" This function is for user-defined 'stl' 'statusline'
    if s:chinese_input_mode == 'onekey'
        if pumvisible()
            return s:vimim_statusline()
        else
            return ""
        endif
    else
        return s:vimim_statusline()
    endif
    return ""
endfunction

" ----------------------------
function! s:vimim_statusline()
" ----------------------------
    if empty(s:ui.root) || empty(s:ui.im)
        return ""
    endif
    " ------------------------------------
    if has_key(s:im_keycode, s:ui.im)
        let s:ui.statusline = s:backend[s:ui.root][s:ui.im].chinese
    endif
    " ------------------------------------
    let datafile = s:backend[s:ui.root][s:ui.im].datafile
    if s:ui.im =~# 'wubi'
        if datafile =~# 'wubi98'
            let s:ui.statusline .= '98'
        elseif datafile =~# 'wubi2000'
            let newcentury = s:vimim_chinese('newcentury')
            let s:ui.statusline = newcentury . s:ui.statusline
        elseif datafile =~# 'wubijd'
            let jidian = s:vimim_chinese('jidian')
            let s:ui.statusline = jidian . s:ui.statusline
        endif
        return s:vimim_get_chinese_im()
    endif
    " ------------------------------------
    if s:pinyin_4corner_filter > 0 && s:ui.im =~ 'pinyin'
        let filter = s:vimim_chinese('digit')
        let pinyin = s:vimim_chinese('pinyin')
        let s:ui.statusline = pinyin . s:plus . filter
        return s:vimim_get_chinese_im()
    endif
    " ------------------------------------
    if s:vimim_cloud_sogou == 1
        let s:ui.statusline = s:backend.cloud.sogou.chinese
    elseif s:vimim_cloud_sogou == -777
        if !empty(s:vimim_cloud_plugin)
            let __getname = s:backend.cloud.mycloud.directory
            let s:ui.statusline .= s:space . __getname
        endif
    endif
    " ------------------------------------
    if !empty(s:vimim_shuangpin)
        let s:ui.statusline .= s:space
        let s:ui.statusline .= s:shuangpin_keycode_chinese.chinese
    endif
    " ------------------------------------
    return s:vimim_get_chinese_im()
endfunction

" --------------------------------
function! s:vimim_get_chinese_im()
" --------------------------------
    let input_style = s:vimim_chinese('classic')
    if s:chinese_input_mode =~ 'onekey' && s:vimim_tab_as_onekey > 0
        let input_style = s:vimim_chinese('onekey')
    elseif s:vimim_chinese_input_mode =~ 'dynamic'
        let input_style .= s:vimim_chinese('dynamic')
    elseif s:vimim_chinese_input_mode =~ 'static'
        let input_style .= s:vimim_chinese('static')
    endif
    let statusline = s:left . s:ui.statusline . s:right
    return statusline . input_style
endfunction

" --------------------------
function! s:vimim_label_on()
" --------------------------
    let labels = range(9)
    if &pumheight > 0
        let labels = range(1, &pumheight)
    endif
    if s:chinese_input_mode == 'onekey'
        let abcd_list = split(s:abcd, '\zs')
        let labels += abcd_list
    endif
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_12345678_label("'._.'")<CR>'
        \.'<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
endfunction

" ------------------------------------
function! <SID>vimim_12345678_label(n)
" ------------------------------------
    let label = a:n
    if pumvisible()
        let n = match(s:abcd, label)
        if label =~ '\d'
            let n = label - 1
        endif
        let down = repeat("\<Down>", n)
        let yes = "\<C-Y>"
        let s:pumvisible_yes = 1
        let label = down . yes
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" ----------------------------------------------
function! s:vimim_onekey_pumvisible_capital_on()
" ----------------------------------------------
    for _ in s:AZ_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_onkey_pumvisible_capital("'._.'")'
    endfor
endfunction

" ------------------------------------------------
function! <SID>vimim_onkey_pumvisible_capital(key)
" ------------------------------------------------
    let hjkl = a:key
    if pumvisible()
        let hjkl  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
        let hjkl .= tolower(a:key)
        let hjkl .= '\<C-R>=g:vimim()\<CR>'
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" --------------------------------------------
function! s:vimim_onekey_label_navigation_on()
" --------------------------------------------
    let hjkl = 'hjklmnsx'
    let hjkl_list = split(hjkl, '\zs')
    for _ in hjkl_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_onekey_label_navigation("'._.'")'
    endfor
endfunction

" --------------------------------
function! s:vimim_onekey_nonstop()
" --------------------------------
    if s:chinese_input_mode == 'onekey'
        let s:onekeynonstop = 1
        call s:vimim_cursor_color(1)
        call s:reset_matched_list()
    endif
endfunction

" -----------------------------------------------
function! <SID>vimim_onekey_label_navigation(key)
" -----------------------------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key == 'j'
            let hjkl  = '\<Down>'
        elseif a:key == 'k'
            let hjkl  = '\<Up>'
        elseif a:key == 'h'
            sil!call s:vimim_onekey_nonstop()
            let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        elseif a:key == 'l'
            sil!call s:vimim_onekey_nonstop()
            let hjkl  = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        elseif a:key == 'm'
            let hjkl  = '\<C-E>'
        elseif a:key == 'n'
            let hjkl  = '\<Down>\<Down>\<Down>'
        elseif a:key == 's'
            let hjkl  = '\<C-R>=g:vimim_space()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_pumvisible_to_clip()\<CR>'
        elseif a:key == 'x'
            let s:pumvisible_ctrl_e = 1
            let hjkl  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_backspace()\<CR>'
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" ------------------------------------
function! g:vimim_one_key_correction()
" ------------------------------------
    let key = '\<Esc>'
    call s:reset_matched_list()
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~# s:valid_key
        let s:one_key_correction = 1
        let key = '\<C-X>\<C-U>\<BS>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ---------------------
function! g:vimim_esc()
" ---------------------
    call s:reset_matched_list()
    if s:chinese_input_mode == 'onekey'
        call s:vimim_stop()
    endif
    sil!exe "sil!return '\<Esc>'"
endfunction

" ------------------------------------
function! g:vimim_pumvisible_to_clip()
" ------------------------------------
    let chinese = s:vimim_popup_word()
    if !empty(chinese)
        if has("gui_running") && has("win32")
            let @+ = chinese
        endif
    endif
    return g:vimim_esc()
endfunction

" ---------------------------------
function! g:vimim_pumvisible_dump()
" ---------------------------------
    if empty(s:popupmenu_list)
        return ""
    endif
    let line = ""
    let one_line = ""
    let results = []
    " -----------------------------
    for items in s:popupmenu_list
        if empty(items.menu)
            let line = printf('%s', items.word)
        else
            let format = '%-8s %s'
            if s:pinyin_4corner_filter > 0
            \&& items.menu =~ '^u\x\x\x\x'
            \&& len(split(items.menu)) > 2
                let format = '%-32s %s'
            endif
            let line = printf(format, items.menu, items.word)
        endif
        call add(results, line)
        let one_line .= line . "\n"
    endfor
    " -----------------------------
    if has("gui_running") && has("win32")
        let @+ = one_line
    endif
    " -----------------------------
    call setline(line("."), results)
    return g:vimim_esc()
endfunction

" ----------------------------
function! s:vimim_popup_word()
" ----------------------------
    if pumvisible()
        return ""
    endif
    let column_start = s:start_column_before
    let column_end = col('.') - 1
    let range = column_end - column_start
    let current_line = getline(".")
    let chinese = strpart(current_line, column_start, range)
    return substitute(chinese,'\w','','g')
endfunction

" --------------------------------------
function! s:vimim_ctrl_e_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-E>\<C-R>=g:vimim()\<CR>'
endfunction

" --------------------------------------
function! s:vimim_ctrl_y_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-Y>\<C-R>=g:vimim()\<CR>'
endfunction

" -------------------------------------
function! g:vimim_menu_search_forward()
" -------------------------------------
    return s:vimim_menu_search("/")
endfunction

" --------------------------------------
function! g:vimim_menu_search_backward()
" --------------------------------------
    return s:vimim_menu_search("?")
endfunction

" --------------------------------
function! s:vimim_menu_search(key)
" --------------------------------
    let slash = ""
    if pumvisible()
        let slash  = '\<C-R>=g:vimim_space()\<CR>'
        let slash .= '\<C-R>=g:vimim_search_pumvisible()\<CR>'
        let slash .= a:key . '\<CR>'
    endif
    sil!exe 'sil!return "' . slash . '"'
endfunction

" ------------------------------
function! g:vimim_left_bracket()
" ------------------------------
    return s:vimim_square_bracket("[")
endfunction

" -------------------------------
function! g:vimim_right_bracket()
" -------------------------------
    return s:vimim_square_bracket("]")
endfunction

" -----------------------------------
function! s:vimim_square_bracket(key)
" -----------------------------------
    let bracket = a:key
    if pumvisible()
        let i = -1
        let left = ""
        let right = ""
        if bracket == "]"
            let i = 0
            let left = "\<Left>"
            let right = "\<Right>"
        endif
        let backspace = '\<C-R>=g:vimim_bracket_backspace('.i.')\<CR>'
        let yes = '\<C-R>=g:vimim_space()\<CR>'
        let bracket = yes . left . backspace . right
    endif
    sil!exe 'sil!return "' . bracket . '"'
endfunction

" -----------------------------------------
function! g:vimim_bracket_backspace(offset)
" -----------------------------------------
    let column_end = col('.')-1
    let column_start = s:start_column_before
    let range = column_end - column_start
    let repeat_times = range/s:multibyte
    let repeat_times += a:offset
    let row_end = line('.')
    let row_start = s:start_row_before
    let delete_char = ""
    if repeat_times > 0 && row_end == row_start
        let delete_char = repeat("\<BS>", repeat_times)
    endif
    if repeat_times < 1
        let current_line = getline(".")
        let chinese = strpart(current_line, column_start, s:multibyte)
        let delete_char = chinese
        if empty(a:offset)
            let chinese = s:left . chinese . s:right
            let delete_char = "\<Right>\<BS>" . chinese . "\<Left>"
        endif
    endif
    return delete_char
endfunction

" --------------------------------
function! <SID>vimim_smart_enter()
" --------------------------------
    let key = ""
    let enter = "\<CR>"
    let byte_before = getline(".")[col(".")-2]
    sil!call s:vimim_onekey_nonstop()
    " -----------------------------------------------
    " <Enter> double play in Chinese Mode:
    "   (1) after English (valid keys)    => Seamless
    "   (2) after Chinese or double Enter => Enter
    " -----------------------------------------------
    if byte_before =~# "[*']"
        let s:smart_enter = 0
    elseif byte_before =~# s:valid_key
        let s:smart_enter += 1
    endif
    " -----------------------------------------------
    " <Enter> multiple play in OneKey Mode:
    " (1) after English (valid keys)    => Seamless
    " (2) after English punctuation     => <Space>
    " (3) after Chinese or double Enter => <Enter>
    " (4) after empty line              => <Enter> with invisible <Space>
    " -----------------------------------------------
    if s:chinese_input_mode == 'onekey'
        if has_key(s:punctuations, byte_before)
            let s:smart_enter += 1
            let key = ' '
        endif
        if byte_before =~ '\s'
            let key = enter
        endif
    endif
    if s:smart_enter == 1
        let msg = "do seamless for the first time <Enter>"
        let s:pattern_not_found = 0
        let s:seamless_positions = getpos(".")
        let s:keyboard_leading_zero = ""
    else
        if s:smart_enter == 2
            let key = " "
        else
            let key = enter
        endif
        let s:smart_enter = 0
    endif
    if s:chinese_input_mode == 'onekey'
        if empty(byte_before)
            let key = s:space . enter
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ----------------------------------
function! s:vimim_get_unicode_menu()
" ----------------------------------
    let trigger = '\<C-R>=g:vimim()\<CR>'
    let xxxx = s:vimim_get_unicode_char_before()
    if empty(xxxx)
        let trigger = ""
    else
        call <SID>vimim_set_seamless()
        let trigger = xxxx . trigger
    endif
    sil!exe 'sil!return "' . trigger . '"'
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_y()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-Y>"
        let s:pumvisible_yes = 1
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_e()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" --------------------------------------
function! g:vimim_pumvisible_ctrl_e_on()
" --------------------------------------
    if s:chinese_input_mode == 'dynamic'
        let s:pumvisible_ctrl_e = 1
    endif
    return g:vimim_pumvisible_ctrl_e()
endfunction

" ---------------------------
function! g:vimim_backspace()
" ---------------------------
    call s:reset_matched_list()
    let s:pattern_not_found = 0
    let key = '\<BS>'
    if s:pumvisible_ctrl_e > 0
        let s:pumvisible_ctrl_e = 0
        let key .= '\<C-R>=g:vimim()\<CR>'
        sil!exe 'sil!return "' . key . '"'
    endif
    if empty(s:onekeynonstop)
    \&& s:chinese_input_mode =~ 'onekey'
        call s:vimim_stop()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ======================================== }}}
let VimIM = " ====  Omni_Popup_Menu   ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_get_previous_pair_list()
" ----------------------------------------
    let results = []
    let filter = s:menu_digit_as_filter
    let filter = strpart(filter, 0, len(filter)-1)
    if len(filter) > 0
        let s:menu_digit_as_filter = filter
        let results = s:vimim_pair_list(s:matched_list)
    endif
    return results
endfunction

" ---------------------------------------
function! s:vimim_pair_list(matched_list)
" ---------------------------------------
    let pair_matched_list = []
    if !empty(len(s:menu_digit_as_filter))
        let chinese = join(a:matched_list,'')
        let chinese = substitute(chinese,'\s\|\w','','g')
        call s:vimim_build_unihan_reverse_cache(chinese)
    endif
    for line in a:matched_list
        if len(line) < 2
            continue
        endif
        if empty(s:backend[s:ui.root][s:ui.im].cache)
            if s:localization > 0
                let line = s:vimim_i18n_read(line)
            endif
        endif
        let oneline_list = split(line)
        let menu = remove(oneline_list, 0)
        for chinese in oneline_list
            if s:pinyin_4corner_filter > 0
                let chinese = s:vimim_digit_filter(chinese)
            endif
            if !empty(chinese)
                call add(pair_matched_list, menu .' '. chinese)
            endif
        endfor
    endfor
    return pair_matched_list
endfunction

" -------------------------------------------------
function! s:vimim_popupmenu_list(pair_matched_list)
" -------------------------------------------------
    let pair_matched_list = a:pair_matched_list
    if empty(pair_matched_list)
        return []
    elseif empty(len(s:menu_digit_as_filter))
        let s:matched_list = copy(pair_matched_list)
    endif
    let menu = 0
    let label = 1
    let popupmenu_list = []
    let keyboard = s:keyboard_leading_zero
    " ---------------------------
    for pair in pair_matched_list
    " ---------------------------
        let complete_items = {}
        let pairs = split(pair)
        if len(pairs) < 2
            continue
        endif
        let menu = get(pairs, 0)
        let chinese = get(pairs, 1)
        let extra_text = menu
        " -------------------------------------------------
        if s:pinyin_4corner_filter > 0  && chinese !~ '\w'
            if len(s:menu_digit_as_filter) > 0
            \|| s:keyboard_leading_zero =~ "'"
            \|| menu =~ '^\d\d\d\d'
                let ddddd = char2nr(chinese)
                let extra_text = s:vimim_unicode_4corner_pinyin(ddddd, 1)
            endif
        endif
        if s:vimim_custom_skin == 3 && extra_text =~# '^ii\|^oo'
            let extra_text = ""
        endif
        let complete_items["menu"] = extra_text
        " -------------------------------------------------
        if empty(s:vimim_cloud_plugin)
            let s:tail = ""
            if keyboard =~ "[']"
                let word_by_word = match(keyboard, "[']")
                let s:tail = strpart(keyboard, word_by_word+1)
                let chinese .= s:tail
            elseif keyboard !~? '^vim'
                let s:tail = strpart(keyboard, len(menu))
                if keyboard =~ '\l\>' || keyboard =~ '^\d\+\>'
                    let chinese .= s:tail
                endif
            endif
            let s:keyboard_head = strpart(keyboard, 0, len(menu))
        else
            let menu = get(split(menu,"_"),0)
        endif
        " -------------------------------------------------
        let labeling = s:vimim_get_labeling(label)
        let abbr = printf('%2s',labeling)."\t".chinese
        let complete_items["abbr"] = abbr
        let complete_items["word"] = chinese
        let complete_items["dup"] = 1
        let label += 1
        call add(popupmenu_list, complete_items)
    endfor
    let s:popupmenu_list = copy(popupmenu_list)
    return popupmenu_list
endfunction

" -----------------------------------
function! s:vimim_get_labeling(label)
" -----------------------------------
    let label = a:label
    let labeling = label
    if s:chinese_input_mode =~ 'onekey'
    \&& label < &pumheight+1
        let label2 = s:abcd[label-1 : label-1]
        if label < 2
            let label2 = "_"
        endif
        if s:vimim_custom_skin == 3 || s:pinyin_4corner_filter > 0
            let labeling = label2
        else
            let labeling .= label2
        endif
    endif
    return labeling
endfunction

" ======================================== }}}
let VimIM = " ====  Punctuations      ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_dictionary_punctuation()
" ----------------------------------------
    let s:punctuations = {}
    let s:punctuations['@'] = s:space
    let s:punctuations['+'] = s:plus
    let s:punctuations[':'] = s:colon
    let s:punctuations['['] = s:left
    let s:punctuations[']'] = s:right
    let s:punctuations['#'] = '＃'
    let s:punctuations['&'] = '＆'
    let s:punctuations['%'] = '％'
    let s:punctuations['$'] = '￥'
    let s:punctuations['!'] = '！'
    let s:punctuations['~'] = '～'
    let s:punctuations['('] = '（'
    let s:punctuations[')'] = '）'
    let s:punctuations['{'] = '〖'
    let s:punctuations['}'] = '〗'
    let s:punctuations['^'] = '……'
    let s:punctuations['_'] = '——'
    let s:punctuations['<'] = '《'
    let s:punctuations['>'] = '》'
    let s:punctuations['-'] = '－'
    let s:punctuations['='] = '＝'
    let s:punctuations[';'] = '；'
    let s:punctuations[','] = '，'
    let s:punctuations['.'] = '。'
    let s:punctuations['?'] = '？'
    let s:punctuations['*'] = '﹡'
    if empty(s:vimim_backslash_close_pinyin)
        let s:punctuations['\'] = '、'
    endif
    if empty(s:vimim_latex_suite)
        let s:punctuations["'"] = '‘’'
        let s:punctuations['"'] = '“”'
    endif
    let s:punctuations_all = copy(s:punctuations)
endfunction

" -------------------------------------------------
function! s:vimim_initialize_frontend_punctuation()
" -------------------------------------------------
    for char in s:valid_keys
        if has_key(s:punctuations, char)
            if !empty(s:vimim_cloud_plugin) || s:ui.has_dot == 1
                unlet s:punctuations[char]
            elseif char !~# "[*.']"
                unlet s:punctuations[char]
            endif
        endif
    endfor
endfunction

" ----------------------------------
function! s:vimim_get_single_quote()
" ----------------------------------
    let pair = "‘’"
    let pairs = split(pair,'\zs')
    let s:smart_single_quotes += 1
    return get(pairs, s:smart_single_quotes % 2)
endfunction

" ----------------------------------
function! s:vimim_get_double_quote()
" ----------------------------------
    let pair = "“”"
    let pairs = split(pair,'\zs')
    let s:smart_double_quotes += 1
    return get(pairs, s:smart_double_quotes % 2)
endfunction

" ---------------------------------------
function! <SID>vimim_toggle_punctuation()
" ---------------------------------------
    if s:vimim_chinese_punctuation > -1
        let s:chinese_punctuation = (s:chinese_punctuation+1)%2
        sil!call s:vimim_punctuation_on()
    endif
    return ""
endfunction

" -----------------------------------
function! <SID>vimim_punctuation_on()
" -----------------------------------
    if s:chinese_input_mode !~ 'onekey'
        unlet s:punctuations['\']
        unlet s:punctuations['"']
        unlet s:punctuations["'"]
    endif
    " ----------------------------
    if s:chinese_punctuation > 0
        if empty(s:vimim_latex_suite)
            if s:ui.im == 'pinyin' || s:ui.im == 'erbi'
                let msg = "apostrophe is over-loaded for cloud at will"
            else
                inoremap ' <C-R>=<SID>vimim_get_single_quote()<CR>
            endif
            if index(s:valid_keys, '"') < 0
                inoremap " <C-R>=<SID>vimim_get_double_quote()<CR>
            endif
        endif
        if empty(s:vimim_backslash_close_pinyin)
            if index(s:valid_keys, '\') < 0
                inoremap <Bslash> 、
            endif
        endif
    else
        iunmap '
        iunmap "
        iunmap <Bslash>
    endif
    " --------------------------------------
    for _ in keys(s:punctuations)
        sil!exe 'inoremap <silent> '._.'
        \    <C-R>=<SID>vimim_punctuation_mapping("'._.'")<CR>'
        \ . '<C-R>=g:vimim_reset_after_auto_insert()<CR>'
    endfor
    " --------------------------------------
    call s:vimim_punctuation_navigation_on()
endfunction

" -------------------------------------------
function! <SID>vimim_punctuation_mapping(key)
" -------------------------------------------
    let value = s:vimim_get_chinese_punctuation(a:key)
    if pumvisible()
        let value = "\<C-Y>" . value
        let s:pumvisible_yes = 1
    endif
    sil!exe 'sil!return "' . value . '"'
endfunction

" -------------------------------------------
function! s:vimim_punctuation_navigation_on()
" -------------------------------------------
    if s:vimim_chinese_punctuation < 0
        return
    endif
    let dot = "."
    let punctuation = "=-[]<"
    if s:chinese_input_mode =~ 'onekey'
        let punctuation .= dot . ",/?"
    endif
    let hjkl_list = split(punctuation,'\zs')
    " ---------------------------------------
    " note: we should never map valid keycode
    for char in s:valid_keys
        let i = index(hjkl_list, char)
        if i > -1 && char != dot
            unlet hjkl_list[i]
        endif
    endfor
    " ---------------------------------------
    for _ in hjkl_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_punctuations_navigation("'._.'")'
    endfor
endfunction

" -----------------------------------------------
function! <SID>vimim_punctuations_navigation(key)
" -----------------------------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key == "["
            let hjkl  = '\<C-R>=g:vimim_left_bracket()\<CR>'
        elseif a:key == "]"
            let hjkl  = '\<C-R>=g:vimim_right_bracket()\<CR>'
        elseif a:key == "/"
            let hjkl  = '\<C-R>=g:vimim_menu_search_forward()\<CR>'
        elseif a:key == "?"
            let hjkl  = '\<C-R>=g:vimim_menu_search_backward()\<CR>'
        elseif a:key =~ "[-,=.]"
            let hjkl = s:vimim_pageup_pagedown(a:key)
        elseif a:key == '<'
            let s:pumvisible_hjkl_2nd_match = 1
            let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        endif
    else
        if s:chinese_input_mode !~ 'onekey'
            let hjkl = s:vimim_get_chinese_punctuation(hjkl)
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" ------------------------------------
function! s:vimim_pageup_pagedown(key)
" ------------------------------------
    let key = a:key
    if key == ',' || key == '-'
        let key = '\<PageUp>'
    elseif key == '.' || key == '='
        let key = '\<PageDown>'
    endif
    return key
endfunction

" ------------------------------------------------------------
function! s:vimim_get_chinese_punctuation(english_punctuation)
" ------------------------------------------------------------
    let value = a:english_punctuation
    if s:chinese_punctuation > 0
    \&& has_key(s:punctuations, value)
        let byte_before = getline(".")[col(".")-2]
        let filter = '\w'     |" english_punctuation_after_english
        if empty(s:vimim_english_punctuation)
            let filter = '\d' |" english_punctuation_after_digit
        endif
        if byte_before !~ filter
            let value = s:punctuations[value]
        endif
    endif
    return value
endfunction

" ======================================== }}}
let VimIM = " ====  Chinese_Number    ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_dictionary_quantifiers()
" ----------------------------------------
    if s:vimim_imode_pinyin < 1
        return
    endif
    let s:quantifiers['1'] = '一壹甲①⒈⑴'
    let s:quantifiers['2'] = '二贰乙②⒉⑵'
    let s:quantifiers['3'] = '三叁丙③⒊⑶'
    let s:quantifiers['4'] = '四肆丁④⒋⑷'
    let s:quantifiers['5'] = '五伍戊⑤⒌⑸'
    let s:quantifiers['6'] = '六陆己⑥⒍⑹'
    let s:quantifiers['7'] = '七柒庚⑦⒎⑺'
    let s:quantifiers['8'] = '八捌辛⑧⒏⑻'
    let s:quantifiers['9'] = '九玖壬⑨⒐⑼'
    let s:quantifiers['0'] = '〇零癸⑩⒑⑽十拾'
    let s:quantifiers['a'] = '秒'
    let s:quantifiers['b'] = '百佰步把包杯本笔部班'
    let s:quantifiers['c'] = '厘次餐场串处床'
    let s:quantifiers['d'] = '第度点袋道滴碟顶栋堆对朵堵顿'
    let s:quantifiers['e'] = '亿'
    let s:quantifiers['f'] = '分份发封付副幅峰方服'
    let s:quantifiers['g'] = '个根股管'
    let s:quantifiers['h'] = '时毫行盒壶户回'
    let s:quantifiers['i'] = '毫'
    let s:quantifiers['j'] = '斤家具架间件节剂具捲卷茎记'
    let s:quantifiers['k'] = '克口块棵颗捆孔'
    let s:quantifiers['l'] = '里粒类辆列轮厘升领缕'
    let s:quantifiers['m'] = '米名枚面门秒'
    let s:quantifiers['n'] = '年'
    let s:quantifiers['o'] = '度'
    let s:quantifiers['p'] = '磅盆瓶排盘盆匹片篇撇喷'
    let s:quantifiers['q'] = '千仟群'
    let s:quantifiers['r'] = '日'
    let s:quantifiers['s'] = '十拾时升艘扇首双所束手'
    let s:quantifiers['t'] = '吨条头通堂趟台套桶筒贴'
    let s:quantifiers['u'] = '微'
    let s:quantifiers['w'] = '万位味碗窝'
    let s:quantifiers['x'] = '升席些项'
    let s:quantifiers['y'] = '月亿叶'
    let s:quantifiers['z'] = '种只张株支枝盏座阵桩尊则站幢宗兆'
endfunction

" ----------------------------------------------
function! s:vimim_imode_number(keyboard, prefix)
" ----------------------------------------------
    let keyboard = a:keyboard
    if strpart(keyboard,0,2) ==# 'ii'
        let keyboard = 'I' . strpart(keyboard,2)
    endif
    let ii_keyboard = keyboard
    let keyboard = strpart(keyboard,1)
    if keyboard !~ '^\d\+' && keyboard !~# '^[ds]'
    \&& len(substitute(keyboard,'\d','','')) > 1
        return []
    endif
    " ------------------------------------------
    let digit_alpha = keyboard
    if keyboard =~# '^\d*\l\{1}$'
        let digit_alpha = keyboard[:-2]
    endif
    let keyboards = split(digit_alpha, '\ze')
    let i = ii_keyboard[:0]
    let number = s:vimim_get_chinese_number(keyboards, i)
    if empty(number)
        return []
    endif
    let numbers = [number]
    let last_char = keyboard[-1:]
    if !empty(last_char) && has_key(s:quantifiers, last_char)
        let quantifier = s:quantifiers[last_char]
        let quantifiers = split(quantifier, '\zs')
        if keyboard =~# '^[ds]\=\d*\l\{1}$'
            if keyboard =~# '^[ds]'
                let number = strpart(number,0,len(number)-s:multibyte)
            endif
            let numbers = map(copy(quantifiers), 'number . v:val')
        elseif keyboard =~# '^\d*$' && len(keyboards)<2 && i ==# 'i'
            let numbers = quantifiers
        endif
    endif
    if len(numbers) == 1
        let s:insert_without_popup = 1
    endif
    if len(numbers) > 0
        call map(numbers, 'a:keyboard ." ". v:val')
    endif
    return numbers
endfunction

" ------------------------------------------------
function! s:vimim_get_chinese_number(keyboards, i)
" ------------------------------------------------
    if empty(a:keyboards) && a:i !~? 'i'
        return 0
    endif
    let chinese_number = ""
    for char in a:keyboards
        if has_key(s:quantifiers, char)
            let quantifier = s:quantifiers[char]
            let quantifiers = split(quantifier,'\zs')
            if a:i ==# 'i'
                let chinese_number .= get(quantifiers,0)
            elseif a:i ==# 'I'
                let chinese_number .= get(quantifiers,1)
            endif
        else
            let chinese_number .= char
        endif
    endfor
    return chinese_number
endfunction

" ======================================== }}}
let VimIM = " ====  Input_Digit       ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ------------------------------------------
function! s:vimim_build_digit_filter_cache()
" ------------------------------------------
" Digit code such as four corner can be used as independent filter.
" It works for both cloud and VimIM embedded backends.
" http://vimim-data.googlecode.com/svn/trunk/data/vimim.unihan_4corner.txt
" -----------------------------------------------------------------
    let buffer = expand("%:p:t")
    if s:chinese_input_mode !~ 'onekey'
    \|| buffer =~ 'dynamic' || buffer =~ 'static'
        let msg = 'digit filter is used for onekey only'
        return
    endif
    let unihan_4corner_file = s:path . "vimim.unihan_4corner.txt"
    if filereadable(unihan_4corner_file)
    \&& empty(s:unihan_4corner_cache)
    \&& empty(s:vimim_data_directory)
        " in:  ['u808f 8022', 'u808f cao4']
        " out: {'u808f': ['8022', 'cao4']}
        for line in readfile(unihan_4corner_file)
            let oneline_list = split(line)
            let menu = remove(oneline_list, 0)
            let s:unihan_4corner_cache[menu] = oneline_list
        endfor
        let s:pinyin_4corner_filter = 1
    endif
endfunction

" ------------------------------------------
function! <SID>vimim_visual_ctrl_6(keyboard)
" ------------------------------------------
" [input]     马力 (visual mode)
" [output]    7712 4002  --  four corner
"             9a6c 529b  --  unicode
"             ma3  li4   --  pinyin
"             ml 马力    --  cjjp
" ------------------------------------------
    let keyboard = a:keyboard
    let range = line("'>") - line("'<")
    if empty(range)
        call s:vimim_backend_initialization_once()
        if keyboard =~ '\s'
            if !empty(s:vimim_data_directory)
                call s:vimim_visual_ctrl_6_update()
            endif
        else
            let results = s:vimim_reverse_lookup(keyboard)
            if !empty(results)
                call s:vimim_visual_ctrl_6_output(results)
            endif
        endif
    elseif s:vimim_tab_as_onekey > 0
        call s:vimim_numberList()
    endif
endfunction

" ----------------------------------
function! s:vimim_numberList() range
" ----------------------------------
    let a=line("'<")|let z=line("'>")|let x=z-a+1|let pre=' '
    while (a<=z)
        if match(x,'^9*$')==0|let pre=pre . ' '|endif
        call setline(z, pre . x . "\t" . getline(z))
        let z=z-1|let x=x-1
    endwhile
endfunction

" --------------------------------------
function! s:vimim_visual_ctrl_6_update()
" --------------------------------------
" purpose: update one entry to the directory database
" input example (one line, within vim): cjjp 超级简拼
" action: (1) cursor on space (2) v (3) ctrl_6
" result: (1) confirm or create new file based on the "left": cjjp
"         (2) update content, with the "right" as the first line
    let current_line = getline(".")
    let fields = split(current_line)
    let left = get(fields,0)
    let right = get(fields,1)
    if left =~# '\l' && left !~ '\W' && right =~# '\W' && right !~ '\l'
        let dir = s:vimim_data_directory . "pinyin"
        let lines = [current_line]
        call s:vimim_mkdir('prepend', dir, lines)
        call s:vimim_append_to_datafile()
    endif
endfunction

" ------------------------------------
function! s:vimim_append_to_datafile()
" ------------------------------------
    let datafile = s:vimim_private_data_file
    if empty(datafile)
        return
    endif
    if filereadable(datafile)
        let lines = readfile(datafile)
        call add(lines, getline("."))
        call writefile(lines, s:vimim_private_data_file)
    endif
endfunction

" ---------------------------------------------
function! s:vimim_visual_ctrl_6_output(results)
" ---------------------------------------------
    let results = a:results
    let line = line(".")
    call setline(line, results)
    let new_positions = getpos(".")
    let new_positions[1] = line + len(results) - 1
    let new_positions[2] = len(get(split(get(results,-1)),0))+1
    call setpos(".", new_positions)
endfunction

" ---------------------------------------
function! s:vimim_reverse_lookup(chinese)
" ---------------------------------------
    let chinese = substitute(a:chinese,'\s\+\|\w\|\n','','g')
    if empty(chinese)
        return []
    endif
    let results_unicode = []  |" 马力 => u9a6c u529b
    let results_digit = []    |" 马力 => 7712 4002
    let results_pinyin = []   |" 马力 => ma3 li2
    let result_cjjp = ""      |" 马力 => ml
    let items = s:vimim_reverse_one_entry(chinese, 'unicode')
    call add(results_unicode, get(items,0))
    call add(results_unicode, get(items,1))
    if s:pinyin_4corner_filter > 0
        call s:vimim_build_unihan_reverse_cache(chinese)
    endif
    if len(s:unihan_4corner_cache) > 1
        let items = s:vimim_reverse_one_entry(chinese, 'unihan')
        call add(results_digit, get(items,0))
        call add(results_digit, get(items,1))
        let items = s:vimim_reverse_one_entry(chinese, 'pinyin')
        if len(items) > 0
            let pinyin_head = get(items,0)
            if !empty(pinyin_head)
                call add(results_pinyin, pinyin_head)
                call add(results_pinyin, get(items,1))
                for pinyin in split(pinyin_head)
                    let result_cjjp .= pinyin[0:0]
                endfor
                let result_cjjp .= " ".chinese
            endif
        endif
    endif
    " -----------------------------------
    let results = []
    if !empty(results_digit)
        call extend(results, results_digit)
    endif
    if !empty(results_unicode)
        call extend(results, results_unicode)
    endif
    if !empty(results_pinyin)
        call extend(results, results_pinyin)
        if result_cjjp =~ '\a'
            call add(results, result_cjjp)
        endif
    endif
    return results
endfunction

" ---------------------------------------------------
function! s:vimim_build_unihan_reverse_cache(chinese)
" ---------------------------------------------------
" [input]  馬力     [unihan] u808f => 8022 cao4 copulate
" [output] {'u99ac':['7132','ma3'],'u529b':['4002','li2']}
" ---------------------------------------------------
    if s:pinyin_4corner_filter < 2
        return
    endif
    for char in split(a:chinese, '\zs')
        let key = printf('u%x',char2nr(char))
        if !has_key(s:unihan_4corner_cache, key)
            let results = s:vimim_get_data_from_directory(key, 'unihan')
            if !empty(results)
                let s:unihan_4corner_cache[key] = results
            endif
        endif
    endfor
endfunction

" ----------------------------------------------
function! s:vimim_reverse_one_entry(chinese, im)
" ----------------------------------------------
    let im = a:im
    let headers = []  "|  ma3 li4
    let bodies = []   "|  马  力
    let head = ''
    for chinese in split(a:chinese, '\zs')
        let ddddd = char2nr(chinese)
        let unicode = printf('u%x', ddddd)
        let head = ''
        if im == 'unicode'
            let head = unicode
        elseif has_key(s:unihan_4corner_cache, unicode)
            let values = s:unihan_4corner_cache[unicode]
            let head = get(values, 0)
            if im == 'unihan'
                if head =~ '\D'
                    let head = '....' |" four corner not available
                endif
            elseif im == 'pinyin'
                let head = get(values, 1)
                if empty(head)
                    continue
                elseif head !~ '^\l\+\d$'
                    let head = get(values, 0)
                endif
            endif
        endif
        if empty(head)
            continue
        endif
        call add(headers, head)
        let spaces = ""
        let number_of_space = len(head)-2
        if number_of_space > 0
            let space = ' '
            for i in range(number_of_space)
                let spaces .= space
            endfor
        endif
        call add(bodies, chinese . spaces)
    endfor
    if empty(head)
        return []
    endif
    let results = [join(headers), join(bodies)]
    return results
endfunction

" ---------------------------------------------
function! s:vimim_onekey_1234567890_filter_on()
" ---------------------------------------------
    if s:pinyin_4corner_filter > 0
        for _ in s:qwerty
            sil!exe'inoremap <silent>  '._.'
            \  <C-R>=<SID>vimim_onekey_1234567890_filter("'._.'")<CR>'
        endfor
    endif
endfunction

" ----------------------------------------------
function! <SID>vimim_onekey_1234567890_filter(n)
" ----------------------------------------------
    let label = a:n
    if pumvisible()
        if s:pinyin_4corner_filter < 1
            let msg = "use 1234567890 as pinyin filter"
        else
            let label_alpha = join(s:qwerty,'')
            let label = match(label_alpha, a:n)
        endif
        if empty(len(s:menu_digit_as_filter))
        \|| s:menu_digit_as_filter[-1:-1] == "_"
            let s:menu_digit_as_filter = label
        else
            let s:menu_digit_as_filter .= label
        endif
        let label = s:vimim_ctrl_e_ctrl_x_ctrl_u()
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" -------------------------------------
function! s:vimim_digit_filter(chinese)
" -------------------------------------
    let chinese = a:chinese
    let number = s:vimim_get_filter_number(chinese)
    let pattern = "^" . substitute(s:menu_digit_as_filter,'\D','','g')
    let matched = match(number, pattern)
    if matched < 0
        let chinese = 0
    endif
    return chinese
endfunction

" ------------------------------------------
function! s:vimim_get_filter_number(chinese)
" ------------------------------------------
" smart digit filter:  马力 7712 4002
"   (1) ma<C-6>        马   => filter with 7712
"   (2) mali<C-6>      马力 => filter with 7 4002
"   (2) mali4<C-6>     马力 => 4 for last char then filter with 7 4002
" -------------------------------------------
    let head = ""
    let tail = ""
    let words = split(a:chinese, '\zs')
    if s:menu_digit_as_filter[-1:-1] == "_"
        let words = copy(words[-1:-1])
    endif
    for chinese in words
        if chinese =~ '\w'
            continue
        else
            let key = printf('u%x',char2nr(chinese))
            if has_key(s:unihan_4corner_cache, key)
                let digit = get(s:unihan_4corner_cache[key],0)
                let head .= digit[:0]
                let tail = digit[1:]
            endif
        endif
    endfor
    let expected_filtering_number = head . tail
    return expected_filtering_number
endfunction

" ======================================== }}}
let VimIM = " ====  Input_Pinyin      ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ------------------------------------
function! s:vimim_apostrophe(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if keyboard =~ "[']"
    \&& keyboard[0:0] != "'"
    \&& keyboard[-1:-1] != "'"
        let msg = "valid apostrophe is typed"
    else
      " let zero_or_one = "'\\="
      " let keyboard = join(split(keyboard,'\ze'), zero_or_one)
        let keyboards = s:vimim_get_pinyin_from_pinyin(keyboard)
        if len(keyboards) > 1
            let keyboard = join(keyboards,"'")
        endif
    endif
    return keyboard
endfunction

" ------------------------------------------------
function! s:vimim_get_pinyin_from_pinyin(keyboard)
" ------------------------------------------------
    if empty(s:vimim_shuangpin)
        let msg = "pinyin breakdown: pinyin=>pin'yin"
    else
        return []
    endif
    let keyboard2 = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard2,"'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

" -------------------------------------------
function! s:vimim_quanpin_transform(keyboard)
" -------------------------------------------
    let qptable = s:quanpin_table
    let item = a:keyboard
    let pinyinstr = ""     |" output string
    let index = 0
    let lenitem = len(item)
    while index < lenitem
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            " NOTE: remove the space after index will cause syntax error
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(qptable, matchstr)
                let tempstr = item[end-1 : end]
                " special case for fanguo, which should be fan'guo
                if tempstr == "gu" || tempstr == "nu" || tempstr == "ni"
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                " follow ibus' rule
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                    \ || (tempstr == "ne" && tempstr3 != "ner")
                    \ || (tempstr4 == "gong" || tempstr3 == "gou")
                    \ || (tempstr4 == "nong" || tempstr3 == "nou")
                    \ || (tempstr == "ga" || tempstr == "na")
                    \ || tempstr2 == "ier"
                    if has_key(qptable, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . qptable[matchstr]
                let index += i
                break
            elseif i == 1
                let pinyinstr .= "'" . item[index]
                let index += 1
                break
            else
                continue
            endif
        endfor
    endwhile
    if pinyinstr[0] == "'"
        return pinyinstr[1:]
    else
        return pinyinstr
    endif
endfunction

" --------------------------------------
function! s:vimim_create_quanpin_table()
" --------------------------------------
    let pinyin_list = s:vimim_get_pinyin_table()
    let table = {}
    for key in pinyin_list
        if key[0] == "'"
            let table[key[1:]] = key[1:]
        else
            let table[key] = key
        endif
    endfor
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g", "k", "h",
        \"j", "q", "x", "zh", "ch", "sh", "r", "z", "c", "s", "y", "w"]
        let table[shengmu] = shengmu
    endfor
    return table
endfunction

" ======================================== }}}
let VimIM = " ====  Input_Shuangpin   ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_initialize_shuangpin()
" --------------------------------------
    if empty(s:vimim_shuangpin)
        return
    endif
    " ----------------------------------
    if !empty(s:shuangpin_table)
        return
    endif
    " ----------------------------------
    let s:vimim_imode_pinyin = 0
    let rules = s:vimim_shuangpin_generic()
    let chinese = ""
    let shuangpin = s:vimim_chinese('shuangpin')
    let keycode = "[0-9a-z'.]"
    " ----------------------------------
    if s:vimim_shuangpin == 'abc'
        let rules = s:vimim_shuangpin_abc(rules)
        let s:vimim_imode_pinyin = 1
        let chinese = s:vimim_chinese('abc')
        let shuangpin = ""
    elseif s:vimim_shuangpin == 'ms'
        let rules = s:vimim_shuangpin_ms(rules)
        let chinese = s:vimim_chinese('ms')
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin == 'nature'
        let rules = s:vimim_shuangpin_nature(rules)
        let chinese = s:vimim_chinese('nature')
    elseif s:vimim_shuangpin == 'plusplus'
        let rules = s:vimim_shuangpin_plusplus(rules)
        let chinese = s:vimim_chinese('plusplus')
    elseif s:vimim_shuangpin == 'purple'
        let rules = s:vimim_shuangpin_purple(rules)
        let chinese = s:vimim_chinese('purple')
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin == 'flypy'
        let rules = s:vimim_shuangpin_flypy(rules)
        let chinese = s:vimim_chinese('flypy')
    endif
    " ----------------------------------
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
    let s:shuangpin_keycode_chinese.chinese = chinese . shuangpin
    let s:shuangpin_keycode_chinese.keycode = keycode
endfunction

" ---------------------------------------------------
function! s:vimim_get_pinyin_from_shuangpin(keyboard)
" ---------------------------------------------------
    let keyboard = a:keyboard
    let keyboard2 = s:vimim_shuangpin_transform(keyboard)
    call s:debugs('shuangpin_in', keyboard)
    call s:debugs('shuangpin_out', keyboard2)
    if keyboard2 ==# keyboard
        let msg = "no point to do transform"
    else
        let s:keyboard_shuangpin = keyboard
        let s:keyboard_leading_zero = keyboard2
        let keyboard = keyboard2
    endif
    return keyboard
endfunction

" ---------------------------------------------
function! s:vimim_shuangpin_transform(keyboard)
" ---------------------------------------------
    let keyboard = a:keyboard
    let size = strlen(keyboard)
    let ptr = 0
    let output = ""
    let bchar = "" |" work-around for sogou
    while ptr < size
        if keyboard[ptr] !~ "[a-z;]"
            " bypass all non-characters, i.e. 0-9 and A-Z are bypassed
            let output .= keyboard[ptr]
            let ptr += 1
        else
            if keyboard[ptr+1] =~ "[a-z;]"
                let sp1 = keyboard[ptr].keyboard[ptr+1]
            else
                let sp1 = keyboard[ptr]
            endif
            if has_key(s:shuangpin_table, sp1)
                " the last odd shuangpin code are output as only shengmu
                let output .= bchar . s:shuangpin_table[sp1]
            else
                " invalid shuangpin code are preserved
                let output .= sp1
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    if output[0] == "'"
        return output[1:]
    else
        return output
    endif
endfunction

"-----------------------------------
function! s:vimim_get_pinyin_table()
"-----------------------------------
" List of all valid pinyin
" NOTE: Don't change this function or remove the spaces after commas.
return [
\"'a", "'ai", "'an", "'ang", "'ao", 'ba', 'bai', 'ban', 'bang', 'bao',
\'bei', 'ben', 'beng', 'bi', 'bian', 'biao', 'bie', 'bin', 'bing', 'bo',
\'bu', 'ca', 'cai', 'can', 'cang', 'cao', 'ce', 'cen', 'ceng', 'cha',
\'chai', 'chan', 'chang', 'chao', 'che', 'chen', 'cheng', 'chi', 'chong',
\'chou', 'chu', 'chua', 'chuai', 'chuan', 'chuang', 'chui', 'chun', 'chuo',
\'ci', 'cong', 'cou', 'cu', 'cuan', 'cui', 'cun', 'cuo', 'da', 'dai',
\'dan', 'dang', 'dao', 'de', 'dei', 'deng', 'di', 'dia', 'dian', 'diao',
\'die', 'ding', 'diu', 'dong', 'dou', 'du', 'duan', 'dui', 'dun', 'duo',
\"'e", "'ei", "'en", "'er", 'fa', 'fan', 'fang', 'fe', 'fei', 'fen',
\'feng', 'fiao', 'fo', 'fou', 'fu', 'ga', 'gai', 'gan', 'gang', 'gao',
\'ge', 'gei', 'gen', 'geng', 'gong', 'gou', 'gu', 'gua', 'guai', 'guan',
\'guang', 'gui', 'gun', 'guo', 'ha', 'hai', 'han', 'hang', 'hao', 'he',
\'hei', 'hen', 'heng', 'hong', 'hou', 'hu', 'hua', 'huai', 'huan', 'huang',
\'hui', 'hun', 'huo', "'i", 'ji', 'jia', 'jian', 'jiang', 'jiao', 'jie',
\'jin', 'jing', 'jiong', 'jiu', 'ju', 'juan', 'jue', 'jun', 'ka', 'kai',
\'kan', 'kang', 'kao', 'ke', 'ken', 'keng', 'kong', 'kou', 'ku', 'kua',
\'kuai', 'kuan', 'kuang', 'kui', 'kun', 'kuo', 'la', 'lai', 'lan', 'lang',
\'lao', 'le', 'lei', 'leng', 'li', 'lia', 'lian', 'liang', 'liao', 'lie',
\'lin', 'ling', 'liu', 'long', 'lou', 'lu', 'luan', 'lue', 'lun', 'luo',
\'lv', 'ma', 'mai', 'man', 'mang', 'mao', 'me', 'mei', 'men', 'meng', 'mi',
\'mian', 'miao', 'mie', 'min', 'ming', 'miu', 'mo', 'mou', 'mu', 'na',
\'nai', 'nan', 'nang', 'nao', 'ne', 'nei', 'nen', 'neng', "'ng", 'ni',
\'nian', 'niang', 'niao', 'nie', 'nin', 'ning', 'niu', 'nong', 'nou', 'nu',
\'nuan', 'nue', 'nuo', 'nv', "'o", "'ou", 'pa', 'pai', 'pan', 'pang',
\'pao', 'pei', 'pen', 'peng', 'pi', 'pian', 'piao', 'pie', 'pin', 'ping',
\'po', 'pou', 'pu', 'qi', 'qia', 'qian', 'qiang', 'qiao', 'qie', 'qin',
\'qing', 'qiong', 'qiu', 'qu', 'quan', 'que', 'qun', 'ran', 'rang', 'rao',
\'re', 'ren', 'reng', 'ri', 'rong', 'rou', 'ru', 'ruan', 'rui', 'run',
\'ruo', 'sa', 'sai', 'san', 'sang', 'sao', 'se', 'sen', 'seng', 'sha',
\'shai', 'shan', 'shang', 'shao', 'she', 'shei', 'shen', 'sheng', 'shi',
\'shou', 'shu', 'shua', 'shuai', 'shuan', 'shuang', 'shui', 'shun', 'shuo',
\'si', 'song', 'sou', 'su', 'suan', 'sui', 'sun', 'suo', 'ta', 'tai',
\'tan', 'tang', 'tao', 'te', 'teng', 'ti', 'tian', 'tiao', 'tie', 'ting',
\'tong', 'tou', 'tu', 'tuan', 'tui', 'tun', 'tuo', "'u", "'v", 'wa', 'wai',
\'wan', 'wang', 'wei', 'wen', 'weng', 'wo', 'wu', 'xi', 'xia', 'xian',
\'xiang', 'xiao', 'xie', 'xin', 'xing', 'xiong', 'xiu', 'xu', 'xuan',
\'xue', 'xun', 'ya', 'yan', 'yang', 'yao', 'ye', 'yi', 'yin', 'ying', 'yo',
\'yong', 'you', 'yu', 'yuan', 'yue', 'yun', 'za', 'zai', 'zan', 'zang',
\'zao', 'ze', 'zei', 'zen', 'zeng', 'zha', 'zhai', 'zhan', 'zhang', 'zhao',
\'zhe', 'zhen', 'zheng', 'zhi', 'zhong', 'zhou', 'zhu', 'zhua', 'zhuai',
\'zhuan', 'zhuang', 'zhui', 'zhun', 'zhuo', 'zi', 'zong', 'zou', 'zu',
\'zuan', 'zui', 'zun', 'zuo']
endfunction

" --------------------------------------------
function! s:vimim_create_shuangpin_table(rule)
" --------------------------------------------
    let pinyin_list = s:vimim_get_pinyin_table()
    let rules = a:rule
    let sptable = {}
    " generate table for shengmu-yunmu pairs match
    for key in pinyin_list
        if key !~ "['a-z]*"
            continue
        endif
        if key[1] == "h"
            let shengmu = key[:1]
            let yunmu = key[2:]
        else
            let shengmu = key[0]
            let yunmu = key[1:]
        endif
        if has_key(rules[0], shengmu)
            let shuangpin_shengmu = rules[0][shengmu]
        else
            continue
        endif
        if has_key(rules[1], yunmu)
            let shuangpin_yunmu = rules[1][yunmu]
        else
            continue
        endif
        let sp1 = shuangpin_shengmu.shuangpin_yunmu
        if !has_key(sptable, sp1)
            if key[0] == "'"
                let key = key[1:]
            end
            let sptable[sp1] = key
        endif
    endfor
    " the jxqy+v special case handling
    if s:vimim_shuangpin == 'abc'
    \|| s:vimim_shuangpin == 'purple'
    \|| s:vimim_shuangpin == 'nature'
    \|| s:vimim_shuangpin == 'flypy'
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin == 'ms'
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
    endif
    " the flypy shuangpin special case handling
    if s:vimim_shuangpin == 'flypy'
        let flypy = {"aa" : "a", "oo" : "o", "ee" : "e",
                    \"an" : "an", "ao" : "ao", "ai" : "ai", "ah": "ang",
                    \"os" : "ong","ou" : "ou",
                    \"en" : "en", "er" : "er", "ei" : "ei", "eg": "eng" }
        call extend(sptable, flypy)
    endif
    " the nature shuangpin special case handling
    if s:vimim_shuangpin == 'nature'
        let nature = {"aa" : "a", "oo" : "o", "ee" : "e" }
        call extend(sptable, nature)
    endif
    " generate table for shengmu-only match
    for [key, value] in items(rules[0])
        if key[0] == "'"
            let sptable[value] = ""
        else
            let sptable[value] = key
        end
    endfor
    " finished init sptable, will use in s:vimim_shuangpin_transform
    return sptable
endfunction

" -----------------------------------
function! s:vimim_shuangpin_generic()
" -----------------------------------
" generate the default value of shuangpin table
    let shengmu_list = {}
    for shengmu in ["b", "p", "m", "f", "d", "t", "l", "n", "g",
                \"k", "h", "j", "q", "x", "r", "z", "c", "s", "y", "w"]
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in ["a", "o", "e", "i", "u", "v"]
        let yunmu_list[yunmu] = yunmu
    endfor
    let s:shuangpin_rule = [shengmu_list, yunmu_list]
    return s:shuangpin_rule
endfunction

" -----------------------------------
function! s:vimim_shuangpin_abc(rule)
" -----------------------------------
" [auto cloud test] vim sogou.shuangpin_abc.vimim
" vtpc => shuang pin => double pinyin
    call extend(a:rule[0],{ "zh" : "a", "ch" : "e", "sh" : "v" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "q", "eng": "g", "ng" : "g",
        \"ia" : "d", "iu" : "r", "ie" : "x", "in" : "c", "ing": "y",
        \"iao": "z", "ian": "w", "iang": "t", "iong" : "s",
        \"un" : "n", "ua" : "d", "uo" : "o", "ue" : "m", "ui" : "m",
        \"uai": "c", "uan": "p", "uang": "t" } )
    return a:rule
endfunction

" ----------------------------------
function! s:vimim_shuangpin_ms(rule)
" ----------------------------------
" [auto cloud test] vim sogou.shuangpin_ms.vimim
" vi=>zhi ii=>chi ui=>shi keng=>keneng
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": ";",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" ,
        \"v" : "y"} )
    return a:rule
endfunction

" --------------------------------------
function! s:vimim_shuangpin_nature(rule)
" --------------------------------------
" [auto cloud test] vim sogou.shuangpin_nature.vimim
" goal: 'woui' => wo shi => i am
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "k", "ai" : "l", "ang": "h",
        \"ong": "s", "ou" : "b",
        \"en" : "f", "er" : "r", "ei" : "z", "eng": "g", "ng" : "g",
        \"ia" : "w", "iu" : "q", "ie" : "x", "in" : "n", "ing": "y",
        \"iao": "c", "ian": "m", "iang" : "d", "iong" : "s",
        \"un" : "p", "ua" : "w", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "y", "uan": "r", "uang" : "d" } )
    return a:rule
endfunction

" ----------------------------------------
function! s:vimim_shuangpin_plusplus(rule)
" ----------------------------------------
" [auto cloud test] vim sogou.shuangpin_plusplus.vimim
    call extend(a:rule[0],{ "zh" : "v", "ch" : "u", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "f", "ao" : "d", "ai" : "s", "ang": "g",
        \"ong": "y", "ou" : "p",
        \"en" : "r", "er" : "q", "ei" : "w", "eng": "t", "ng" : "t",
        \"ia" : "b", "iu" : "n", "ie" : "m", "in" : "l", "ing": "q",
        \"iao": "k", "ian": "j", "iang" : "h", "iong" : "y",
        \"un" : "z", "ua" : "b", "uo" : "o", "ue" : "x", "ui" : "v",
        \"uai": "x", "uan": "c", "uang" : "h" } )
    return a:rule
endfunction

" --------------------------------------
function! s:vimim_shuangpin_purple(rule)
" --------------------------------------
" [auto cloud test] vim sogou.shuangpin_purple.vimim
    call extend(a:rule[0],{ "zh" : "u", "ch" : "a", "sh" : "i" })
    call extend(a:rule[1],{
        \"an" : "r", "ao" : "q", "ai" : "p", "ang": "s",
        \"ong": "h", "ou" : "z",
        \"en" : "w", "er" : "j", "ei" : "k", "eng": "t", "ng" : "t",
        \"ia" : "x", "iu" : "j", "ie" : "d", "in" : "y", "ing": ";",
        \"iao": "b", "ian": "f", "iang" : "g", "iong" : "h",
        \"un" : "m", "ua" : "x", "uo" : "o", "ue" : "n", "ui" : "n",
        \"uai": "y", "uan": "l", "uang" : "g"} )
    return a:rule
endfunction

" -------------------------------------
function! s:vimim_shuangpin_flypy(rule)
" -------------------------------------
" [auto cloud test] vim sogou.shuangpin_flypy.vimim
    call extend(a:rule[0],{ "zh" : "v", "ch" : "i", "sh" : "u" })
    call extend(a:rule[1],{
        \"an" : "j", "ao" : "c", "ai" : "d", "ang": "h",
        \"ong": "s", "ou" : "z",
        \"en" : "f", "er" : "r", "ei" : "w", "eng": "g", "ng" : "g",
        \"ia" : "x", "iu" : "q", "ie" : "p", "in" : "b", "ing": "k",
        \"iao": "n", "ian": "m", "iang" : "l", "iong" : "s",
        \"un" : "y", "ua" : "x", "uo" : "o", "ue" : "t", "ui" : "v",
        \"uai": "k", "uan": "r", "uang" : "l" } )
    return a:rule
endfunction

" ======================================== }}}
let VimIM = " ====  Input_Misc        ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" -------------------------------------
function! s:vimim_get_valid_im_name(im)
" -------------------------------------
    let im = a:im
    if im =~# '^wubi'
        let im = 'wubi'
    elseif im =~# '^pinyin'
        let im = 'pinyin'
        let s:vimim_imode_pinyin = 1
    endif
    return im
endfunction

" -----------------------------------------
function! s:vimim_set_special_im_property()
" -----------------------------------------
    if empty(s:vimim_shuangpin) && s:ui.im == 'pinyin'
        let s:quanpin_table = s:vimim_create_quanpin_table()
    endif
    " -------------------------------------
    if s:ui.im == 'wu'
    \|| s:ui.im == 'erbi'
    \|| s:ui.im == 'yong'
    \|| s:ui.im == 'nature'
    \|| s:ui.im == 'boshiamy'
    \|| s:ui.im == 'phonetic'
    \|| s:ui.im == 'array30'
        let s:ui.has_dot = 1  "| dot in datafile
        let s:vimim_chinese_punctuation = -9
    endif
endfunction

" -----------------------------------------------
function! s:vimim_wubi_4char_auto_input(keyboard)
" -----------------------------------------------
    let keyboard = a:keyboard
    if s:chinese_input_mode == 'dynamic'
        if len(keyboard) > 4
            " support wubi non-stop typing
            let start = 4*((len(keyboard)-1)/4)
            let keyboard = strpart(keyboard, start)
        endif
        let s:keyboard_leading_zero = keyboard
    endif
    return keyboard
endfunction

" ------------------------------------------------
function! s:vimim_erbi_first_punctuation(keyboard)
" ------------------------------------------------
    let keyboard = a:keyboard
    let chinese_punctuation = 0
    if len(keyboard) == 1
    \&& keyboard =~ "[.,/;]"
    \&& has_key(s:punctuations_all, keyboard)
        let chinese_punctuation = s:punctuations_all[keyboard]
    endif
    return chinese_punctuation
endfunction

" http://www.vim.org/scripts/script.php?script_id=2006
" --------------------
let s:progressbar = {}
" --------------------
func! NewSimpleProgressBar(title, max_value, ...)
  if !has("statusline")
    return {}
  endif
  let winnr = a:0 ? a:1 : winnr()
  let b = copy(s:progressbar)
  let b.title = a:title
  let b.max_value = a:max_value
  let b.cur_value = 0
  let b.winnr = winnr
  let b.items = {
      \ 'title' : { 'color' : 'Statusline' },
      \ 'bar' : { 'fillchar' : ' ', 'color' : 'Statusline' ,
      \           'fillcolor' : 'DiffDelete' , 'bg' : 'Statusline' },
      \ 'counter' : { 'color' : 'Statusline' } }
  let b.stl_save = getwinvar(winnr,"&statusline")
  let b.lst_save = &laststatus"
  return b
endfun
func! s:progressbar.paint()
  let max_len = winwidth(self.winnr)-1
  let t_len = strlen(self.title)+1+1
  let c_len = 2*strlen(self.max_value)+1+1+1
  let pb_len = max_len - t_len - c_len - 2
  let cur_pb_len = (pb_len*self.cur_value)/self.max_value
  let t_color = self.items.title.color
  let b_fcolor = self.items.bar.fillcolor
  let b_color = self.items.bar.color
  let c_color = self.items.counter.color
  let fc= strpart(self.items.bar.fillchar." ",0,1)
  let stl = "%#".t_color."#%-( ".self.title." %)".
      \"%#".b_color."#|".
      \"%#".b_fcolor."#%-(".repeat(fc,cur_pb_len)."%)".
      \"%#".b_color."#".repeat(" ",pb_len-cur_pb_len)."|".
      \"%=%#".c_color."#%( ".repeat(" ",(strlen(self.max_value)-
      \strlen(self.cur_value))).self.cur_value."/".self.max_value."  %)"
  set laststatus=2
  call setwinvar(self.winnr,"&stl",stl)
  redraw
endfun
func! s:progressbar.incr( ... )
  let i = a:0 ? a:1 : 1
  let i+=self.cur_value
  let i = i < 0 ? 0 : i > self.max_value ? self.max_value : i
  let self.cur_value = i
  call self.paint()
  return self.cur_value
endfun
func! s:progressbar.restore()
  call setwinvar(self.winnr,"&stl",self.stl_save)
  let &laststatus=self.lst_save
  redraw
endfun

" ======================================== }}}
let VimIM = " ====  Backend==Unicode  ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ------------------------------
function! s:vimim_localization()
" ------------------------------
    if empty(s:vimim_cloud_sogou)
        let s:vimim_cloud_sogou = 888
    endif
    " ---------------------------------------------
    if s:pinyin_4corner_filter > 0
        let s:abcd = "'abcdvfgz"
        let s:qwerty = split('pqwertyuio', '\zs')
    endif
    " ---------------------------------------------
    let datafile_fenc_chinese = 0
    if s:ui.root =~ 'datafile' || s:ui.root =~ 'directory'
        if s:backend[s:ui.root][s:ui.im].datafile =~# "chinese"
            let datafile_fenc_chinese = 1
        endif
        if s:backend[s:ui.root][s:ui.im].datafile =~# "quote"
            let s:ui.has_dot = 2  "| has_apostrophe_in_datafile
        endif
    endif
    " ------------ ----------------- --------------
    " vim encoding datafile encoding s:localization
    " ------------ ----------------- --------------
    "   utf-8          utf-8                0
    "   utf-8          chinese              1
    "   chinese        utf-8                2
    "   chinese        chinese              8
    " ------------ ----------------- --------------
    if &encoding == "utf-8"
        if datafile_fenc_chinese > 0
            let s:localization = 1
        endif
    elseif empty(datafile_fenc_chinese)
        let s:localization = 2
    endif
    if s:localization > 0
        let warning = "performance hit if &encoding & datafile differs!"
    endif
    let s:multibyte = 2
    if &encoding == "utf-8"
        let s:multibyte = 3
    endif
endfunction

" -------------------------------
function! s:vimim_i18n_read(line)
" -------------------------------
    let line = a:line
    if s:localization == 1
        let line = iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        let line = iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

" -------------------------------------------
function! s:vimim_get_unicode_ddddd(keyboard)
" -------------------------------------------
    let keyboard = a:keyboard
    if strlen(keyboard) != 5
        return 0
    endif
    let ddddd = 0
    if keyboard =~# '^u\x\{4}$'
        " show hex unicode popup menu: u808f
        let xxxx = keyboard[1:]
        let ddddd = str2nr(xxxx, 16)
    elseif keyboard =~# '^\d\{5}$'
        " show decimal unicode popup menu: 32911
        let ddddd = str2nr(keyboard, 10)
    else
        return 0
    endif
    if empty(ddddd) || ddddd>0xffff
        return 0
    endif
    return ddddd
endfunction

" ---------------------------------------------
function! s:vimim_get_unicode(keyboard, height)
" ---------------------------------------------
    let keyboard = a:keyboard
    let ddddd = s:vimim_get_unicode_ddddd(keyboard)
    if empty(ddddd)
        return []
    endif
    let numbers = []
    let height = &pumheight * a:height
    for i in range(height)
        let digit = str2nr(ddddd+i)
        call add(numbers, digit)
    endfor
    return s:vimim_get_unicodes(numbers,1)
endfunction

" ------------------
function! CJK16(...)
" ------------------
" This function outputs unicode block by block as:
" ----------------------------------------------------
"      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
" 4E00 #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
" ----------------------------------------------------
    if &encoding != "utf-8"
        $put='Your Vim encoding has to be set as utf-8.'
        $put='[usage]'
        $put='(in .vimrc):      :set encoding=utf-8'
        $put='(in Vim Command): :call CJK16()<CR>'
        $put='(in Vim Command): :call CJK16(0x8000,16)<CR>'
    else
        let a = 0x4E00| let n = 112-24| let block = 0x00F0
        if (a:0>=1)| let a = a:1| let n = 1| endif
        if (a:0==2)| let n = a:2| endif
        let z = a + n*block - 128
        while a <= z
            if empty(a%(16*16))
                $put='----------------------------------------------------'
                $put='     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F '
                $put='----------------------------------------------------'
            endif
            let c = printf('%04X ',a)
            for j in range(16)|let c.=nr2char(a).' '|let a+=1|endfor
            $put=c
        endwhile
    endif
endfunction

" -------------
function! CJK()
" -------------
" This function outputs unicode as:
" ---------------------------------
"   decimal  hex    CJK
"   39340    99ac    馬
" ---------------------------------
    if &encoding != "utf-8"
        $put='Your Vim encoding has to be set as utf-8.'
        $put='[usage]    :call CJK()<CR>'
    else
        let unicode_start = 19968  "| 一
        let unicode_end   = 40869  "| 龥
        for i in range(unicode_start, unicode_end)
            $put=printf('%d %x ',i,i).nr2char(i)
        endfor
    endif
    return ""
endfunction

" -------------
function! GBK()
" -------------
" This function outputs GBK as:
" ----------------------------- gb=6763
"   decimal  hex    GBK
"   49901    c2ed    馬
" ----------------------------- gbk=883+21003=21886
    if s:encoding ==# "chinese"
        let start = str2nr('8140',16) "| 33088 丂
        for i in range(125)
            for j in range(start, start+190)
                if j <= 64928 && j != start+63
                    $put=printf('%d %x ',j,j).nr2char(j)
                endif
            endfor
            let start += 16*16
        endfor
    else
        $put='Your Vim encoding has to be set as chinese.'
        $put='[usage]    :call GBK()<CR>'
    endif
    return ""
endfunction

" --------------
function! BIG5()
" --------------
" This function outputs BIG5 as:
" -----------------------------
"   decimal  hex    BIG5
"   45224    b0a8    馬
" ----------------------------- big5=408+5401+7652=13461
    if s:encoding ==# "taiwan"
        let start = str2nr('A440',16) "| 42048  一
        for i in range(86)
            for j in range(start, start+(4*16)-2)
                $put=printf('%d %x ',j,j).nr2char(j)
            endfor
            let start2 = start + 6*16+1
            for j in range(start2, start2+93)
                $put=printf('%d %x ',j,j).nr2char(j)
            endfor
            let start += 16*16
        endfor
    else
        $put='Your Vim encoding has to be set as taiwan.'
        $put='[usage]    :call BIG5()<CR>'
    endif
    return ""
endfunction

" ======================================== }}}
let VimIM = " ====  Backend==File     ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ------------------------------------------------
function! s:vimim_scan_backend_embedded_datafile()
" ------------------------------------------------
    if empty(s:vimim_data_directory)
        let msg = "no need datafile when directory exists"
    else
        return
    endif
    call s:vimim_set_datafile(0)
endfunction

" -------------------------------------
function! s:vimim_do_force_datafile(im)
" -------------------------------------
    let s:vimim_data_directory = 0
    let s:vimim_cloud_sogou = 0
    let s:vimim_cloud_plugin = 0
    if match(s:xingma, a:im) < 0
        let msg = "no need digit filter for wubil"
    else
        let s:pinyin_4corner_filter = 0
    endif
    call s:vimim_set_datafile(a:im)
endfunction

" --------------------------------
function! s:vimim_set_datafile(im)
" --------------------------------
    let datafile = 0
    if empty(a:im)
        for im in s:all_vimim_input_methods
            let datafile = s:vimim_data_file
            if !empty(datafile) && filereadable(datafile)
                if datafile =~ '\<' . im . '\>'
                    break
                endif
            endif
            let file = "vimim." . im . ".txt"
            let datafile = s:path . file
            if filereadable(datafile)
                break
            else
                continue
            endif
        endfor
    else
        let im = a:im
        let file = "vimim." . im . ".txt"
        let datafile = s:path . file
        if !filereadable(datafile)
            let s:path = s:vimim_vimimdata
            let datafile = s:path . file
        endif
    endif
    " ----------------------------------------
    if !filereadable(datafile) || isdirectory(datafile)
        return
    endif
    " ----------------------------------------
    let im = s:vimim_get_valid_im_name(im)
    let s:ui.root = "datafile"
    let s:ui.im = im
    call add(s:ui.frontends, [s:ui.root, s:ui.im])
    if empty(s:backend.datafile)
        let s:backend.datafile[im] = s:vimim_one_backend_hash()
        let s:backend.datafile[im].root = "datafile"
        let s:backend.datafile[im].im = im
        let s:backend.datafile[im].datafile = datafile
        let s:backend.datafile[im].keycode = s:im_keycode[im]
        let s:backend.datafile[im].chinese = s:vimim_chinese(im)
    endif
    " ----------------------------------------
    if im =~ '^\d'
        let s:vimim_chinese_input_mode = 'static'
    endif
endfunction

" --------------------------------------
function! s:vimim_build_datafile_lines()
" --------------------------------------
    let im = s:ui.im
    if s:backend[s:ui.root][im].root != "datafile"
        return
    endif
    let datafile = s:backend.datafile[im].datafile
    if len(datafile) > 1 && filereadable(datafile)
        if empty(s:backend.datafile[im].lines)
            let s:backend.datafile[im].lines = readfile(datafile)
            if im == 'pinyin'
                let digit = s:path . "vimim.4corner.txt"
                if filereadable(digit)
                    let digit_lines = readfile(digit)
                    let s:backend.datafile[im].lines += digit_lines
                endif
            endif
        endif
    endif
endfunction

" ---------------------------------------------------------
function! s:vimim_smart_match(lines, keyboard, match_start)
" ---------------------------------------------------------
    let match_start = a:match_start
    if empty(a:lines) || match_start < 0
        return []
    endif
    let keyboard = a:keyboard
    " ----------------------------------------
    let pattern = '\M^\(' . keyboard
    if len(keyboard) < 2
        let pattern .= '\>'
    else
        let pinyin_tone = '\d\='
        let pattern .= pinyin_tone . '\>'
    endif
    let pattern .= '\)\@!'
    " ----------------------------------------
    let matched = match(a:lines, pattern, match_start)-1
    let match_end = match_start
    if matched > 0 && matched > match_start
        let match_end = matched
    endif
    " ----------------------------------------
    " always do popup as one-to-many translation
    let menu_maximum = 20
    let range = match_end - match_start
    if range > menu_maximum || range < 1
        let match_end = match_start + menu_maximum
    endif
    " --------------------------------------------
    let results = a:lines[match_start : match_end]
    " --------------------------------------------
    if len(results) < 10 && s:ui.im == 'pinyin'
       let extras = s:vimim_pinyin_more_match(a:lines, keyboard, results)
       if len(extras) > 0
           call extend(results, extras)
       endif
    endif
    return results
endfunction

" -----------------------------------------------------------
function! s:vimim_pinyin_more_match(lines, keyboard, results)
" -----------------------------------------------------------
    let filter = "vim\\|#\\|　"
    if match(a:results, filter) > -1
        return []
    endif
    " -----------------------------------------
    " [purpose] make standard popup menu layout
    " in  => chao'ji'jian'pin
    " out => chaojijian, chaoji, chao
    " -----------------------------------------
    let keyboards = s:vimim_get_pinyin_from_pinyin(a:keyboard)
    if empty(keyboards)
        return []
    endif
    let candidates = []
    for i in reverse(range(len(keyboards)-1))
        let candidate = join(keyboards[0 : i], "")
        call add(candidates, candidate)
    endfor
    let matched_list = []
    for keyboard in candidates
        let results = s:vimim_fixed_match(a:lines, keyboard, 1)
        call extend(matched_list, results)
    endfor
    return matched_list
endfunction

" ---------------------------------------------
function! s:vimim_get_data_from_cache(keyboard)
" ---------------------------------------------
    let keyboard = a:keyboard
    if empty(s:backend[s:ui.root][s:ui.im].cache)
        return []
    endif
    let results = []
    if has_key(s:backend[s:ui.root][s:ui.im].cache, keyboard)
        let results = s:backend[s:ui.root][s:ui.im].cache[keyboard]
    endif
    return results
endfunction

" -----------------------------------------------------
function! s:vimim_get_sentence_datafile_cache(keyboard)
" -----------------------------------------------------
    let msg = "use cache to speed up search after initial load"
    let keyboard = a:keyboard
    if empty(s:backend[s:ui.root][s:ui.im].cache)
        return []
    endif
    let results = []
    let keyboards = s:vimim_sentence_match_cache(keyboard)
    if !empty(keyboards)
        let keyboard = get(keyboards, 0)
        let results = s:vimim_get_data_from_cache(keyboard)
    endif
    return results
endfunction

" ----------------------------------------------
function! s:vimim_sentence_match_cache(keyboard)
" ----------------------------------------------
    let keyboard = a:keyboard
    let results = s:vimim_get_data_from_cache(keyboard)
    if !empty(results)
        return [keyboard]
    endif
    let im = s:ui.im
    let blocks = s:vimim_break_sentence_into_block(keyboard)
    if !empty(blocks)
        return blocks
    endif
    let max = s:vimim_hjkl_redo_pinyin_match(keyboard)
    " -----------------------------------------
    while max > 0
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let results = s:vimim_get_data_from_cache(head)
        if !empty(results)
            break
        else
            continue
        endif
    endwhile
    " -----------------------------------------
    if len(results) > 0
        return s:vimim_break_string_at(keyboard, max)
    else
        return []
    endif
endfunction

" -----------------------------------------------------
function! s:vimim_get_sentence_datafile_lines(keyboard)
" -----------------------------------------------------
    call s:vimim_build_datafile_lines()
    let keyboard = a:keyboard
    let results = []
    let keyboards = s:vimim_sentence_match_datafile(keyboard)
    if len(keyboards) > 0
        let keyboard = get(keyboards, 0)
        let results = s:vimim_get_data_from_datafile(keyboard)
    endif
    return results
endfunction

" -------------------------------------------------
function! s:vimim_sentence_match_datafile(keyboard)
" -------------------------------------------------
    let lines = s:backend[s:ui.root][s:ui.im].lines
    if empty(lines)
        return []
    endif
    let keyboard = a:keyboard
    let pattern = '^' . keyboard
    let match_start = match(lines, pattern)
    if match_start > -1
        return [keyboard]
    endif
    let blocks = s:vimim_break_sentence_into_block(keyboard)
    if !empty(blocks)
        return blocks
    endif
    let max = s:vimim_hjkl_redo_pinyin_match(keyboard)
    while max > 0
        let head = strpart(keyboard, 0, max)
        let pattern = '^' . head . '\>'
        let match_start = match(lines, pattern)
        let max -= 1
        if match_start < 0
            continue
        else
            break
        endif
    endwhile
    if match_start < 0
        return []
    else
        return s:vimim_break_string_at(a:keyboard, max)
    endif
endfunction

" ------------------------------------------------
function! s:vimim_get_data_from_datafile(keyboard)
" ------------------------------------------------
    let keyboard = a:keyboard
    let lines = s:backend[s:ui.root][s:ui.im].lines
    if empty(lines)
        return []
    endif
    let results = []
    let pattern = "^" . keyboard
    let match_start = match(lines, pattern)
    if match_start < 0
        let msg = "fuzzy search could be done here, if needed"
    else
        if s:ui.has_dot == 2
            let results = s:vimim_fixed_match(lines, keyboard, 1)
        elseif s:ui.im == 'test'
            let pumheight = &pumheight - 1
            let results = s:vimim_fixed_match(lines, keyboard, pumheight)
        else
            let results = s:vimim_smart_match(lines, keyboard, match_start)
        endif
    endif
    return results
endfunction

" ---------------------------------------------------
function! s:vimim_fixed_match(lines, keyboard, fixed)
" ---------------------------------------------------
    if empty(a:lines) || empty(a:keyboard)
        return []
    endif
    let pattern = '^' . a:keyboard
    let matched = match(a:lines, pattern)
    let match_end = matched + a:fixed
    let results = []
    if matched >= 0
        let results = a:lines[matched : match_end]
    endif
    return results
endfunction

" ---------------------------------------------------
function! s:vimim_break_sentence_into_block(keyboard)
" ---------------------------------------------------
    let blocks = s:vimim_break_word_by_word(a:keyboard)
    if empty(blocks)
        let blocks = s:vimim_break_pinyin_digit(a:keyboard)
        if empty(blocks)
            let blocks = s:vimim_break_digit_every_four(a:keyboard)
        endif
    endif
    if empty(blocks)
        return []
    else
        return blocks
    endif
endfunction

" --------------------------------------------
function! s:vimim_break_pinyin_digit(keyboard)
" --------------------------------------------
    let blocks = []
    let keyboard = a:keyboard
    if s:pinyin_4corner_filter < 1
        return []
    endif
    let pinyin_digit_pattern = '\d\+\l\='
    let digit = match(keyboard, pinyin_digit_pattern)
    if digit > 0
        let blocks = s:vimim_break_string_at(keyboard, digit)
        if empty(len(s:menu_digit_as_filter))
            let menu = get(blocks, 0)
            let filter = get(blocks, 1)
            if menu =~ '\D' && filter =~ '^\d\+$'
                let s:menu_digit_as_filter = filter . "_"
            endif
        endif
    endif
    return blocks
endfunction

" --------------------------------------
function! s:vimim_build_datafile_cache()
" --------------------------------------
    if s:vimim_use_cache < 1
        return
    endif
    if s:backend[s:ui.root][s:ui.im].root == "datafile"
        if empty(s:backend[s:ui.root][s:ui.im].lines)
            let msg = " no way to build datafile cache "
        elseif empty(s:backend[s:ui.root][s:ui.im].cache)
            call s:vimim_cache_loading_progressbar()
        endif
    endif
endfunction

" -------------------------------------------
function! s:vimim_cache_loading_progressbar()
" -------------------------------------------
    let title = s:vimim_chinese(s:ui.im)
    let total = len(s:backend[s:ui.root][s:ui.im].lines)
    let title .= s:vimim_chinese("datafile")
    let progress = "VimIM loading " . title
    let progressbar = NewSimpleProgressBar(progress, total)
    try
        sil!call s:vimim_loading_datafile_cache(progressbar)
    finally
        call progressbar.restore()
    endtry
endfunction

" ---------------------------------------------------
function! s:vimim_loading_datafile_cache(progressbar)
" ---------------------------------------------------
    if empty(s:backend[s:ui.root][s:ui.im].cache)
        let msg = " cache only needs to be loaded once "
    else
        return
    endif
    for line in s:backend[s:ui.root][s:ui.im].lines
        call a:progressbar.incr(1)
        if s:localization > 0
            let line = s:vimim_i18n_read(line)
        endif
        let oneline_list = split(line)
        let menu = remove(oneline_list, 0)
        if has_key(s:backend[s:ui.root][s:ui.im].cache, menu)
            let line_list = s:backend[s:ui.root][s:ui.im].cache[menu]
            call extend(line_list, oneline_list)
            let line = join(line_list)
        endif
        let s:backend[s:ui.root][s:ui.im].cache[menu] = [line]
    endfor
endfunction

" ======================================== }}}
let VimIM = " ====  Backend==Dir      ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" -------------------------------------------------
function! s:vimim_scan_backend_embedded_directory()
" -------------------------------------------------
    if empty(s:vimim_data_directory)
         let s:vimim_data_directory = s:path . "vimim/"
    endif
    " -----------------------------------
    if isdirectory(s:vimim_data_directory)
        let msg = " use directory as backend database "
    else
        let s:vimim_data_directory = 0
        let return
    endif
    " -----------------------------------
    for im in s:all_vimim_input_methods
        let dir = s:vimim_get_valid_directory(im)
        if empty(dir)
            continue
        else
            break
        endif
    endfor
    " -----------------------------------
    if empty(dir)
        return
    else
        let buffer = expand("%:p:t")
        if s:chinese_input_mode !~ 'onekey'
        \|| buffer =~ 'dynamic' || buffer =~ 'static'
            let msg = 'digit filter for onekey only'
        elseif isdirectory(s:vimim_data_directory . "unihan")
            let s:pinyin_4corner_filter = 2
        endif
    endif
    " -----------------------------------
    let im = s:vimim_get_valid_im_name(im)
    let s:ui.root = "directory"
    let s:ui.im = im
    let datafile = s:vimim_data_directory . im
    call add(s:ui.frontends, [s:ui.root, s:ui.im])
    if empty(s:backend.directory)
        let s:backend.directory[im] = s:vimim_one_backend_hash()
        let s:backend.directory[im].root = "directory"
        let s:backend.directory[im].datafile = dir
        let s:backend.directory[im].im = im
        let s:backend.directory[im].keycode = s:im_keycode[im]
        let s:backend.directory[im].chinese = s:vimim_chinese(im)
    endif
endfunction

" -------------------------------------------
function! s:vimim_force_scan_current_buffer()
" -------------------------------------------
" auto enter chinese input mode => vim vimim
" auto mycloud input            => vim mycloud.vimim
" auto cloud input              => vim sogou.vimim
" auto cloud onekey             => vim sogou.onekey.vimim
" auto wubi dynamic input mode  => vim wubi.dynamic.vimim
" -------------------------------------------
    let buffer = expand("%:p:t")
    if buffer =~# '.vimim\>'
        if s:vimim_custom_skin != 2
            let s:vimim_custom_skin = 2
        endif
    else
        return
    endif
    " ---------------------------------
    if buffer =~ 'dynamic'
        let s:vimim_chinese_input_mode = 'dynamic'
    elseif buffer =~ 'static'
        let s:vimim_chinese_input_mode = 'static'
    elseif buffer =~ 'onekey'
        let s:vimim_chinese_input_mode = 'onekey'
    endif
    " ---------------------------------
    if buffer =~ 'shuangpin_abc'
        let s:vimim_shuangpin = 'abc'
    elseif buffer =~ 'shuangpin_ms'
        let s:vimim_shuangpin = 'ms'
    elseif buffer =~ 'shuangpin_nature'
        let s:vimim_shuangpin = 'nature'
    elseif buffer =~ 'shuangpin_plusplus'
        let s:vimim_shuangpin = 'plusplus'
    elseif buffer =~ 'shuangpin_purple'
        let s:vimim_shuangpin = 'purple'
    elseif buffer =~ 'shuangpin_flypy'
        let s:vimim_shuangpin = 'flypy'
    endif
    " ---------------------------------
    if buffer =~# 'sogou'
        call s:vimim_do_force_sogou()
    elseif buffer =~# 'mycloud'
        call s:vimim_do_force_mycloud()
    else
    " ---------------------------------
        for input_method in s:all_vimim_input_methods
            if buffer =~ input_method . '\>'
                break
            else
                continue
            endif
        endfor
        if buffer =~ input_method
            if buffer =~# 'cache'
                let s:vimim_use_cache = 1
            endif
            call s:vimim_do_force_datafile(input_method)
        endif
    " ---------------------------------
    endif
endfunction

" -------------------------------------------------
function! s:vimim_get_im_from_buffer_name(filename)
" -------------------------------------------------
    let im = 0
    for key in copy(keys(s:im_keycode))
        let pattern = '\<' . key . '\>'
        let matched = match(a:filename, pattern)
        if matched < 0
            continue
        else
            let im = key
            break
        endif
    endfor
    return im
endfunction

" ---------------------------------------
function! s:vimim_get_valid_directory(im)
" ---------------------------------------
    let im = a:im
    if empty(im) || empty(s:vimim_data_directory)
        return 0
    endif
    let dir = s:vimim_data_directory . im
    if isdirectory(dir)
        return dir
    else
        return 0
    endif
endfunction

" --------------------------------------
function! s:vimim_set_data_directory(im)
" --------------------------------------
    let im = a:im
    let dir = s:vimim_get_valid_directory(im)
    if empty(dir)
        return 0
    else
        let s:ui.im = im
        return dir
    endif
endfunction

" -----------------------------------------------------
function! s:vimim_get_data_from_directory(keyboard, im)
" -----------------------------------------------------
    let dir = s:vimim_get_valid_directory(a:im)
    if empty(dir) && empty(s:vimim_private_data_directory)
        return []
    endif
    let lines = []
    let filename = s:vimim_private_data_directory . a:keyboard
    if filereadable(filename)
        let lines = readfile(filename)
    endif
    if empty(lines)
        let filename = dir . '/' . a:keyboard
        if filereadable(filename)
            if a:im == 'unihan'
                let lines = readfile(filename, '', 2)
            else
                let lines = readfile(filename)
            endif
        endif
    endif
    return lines
endfunction

" -----------------------------------------------------
function! s:vimim_get_pair_from_directory(keyboard, im)
" -----------------------------------------------------
    let lines = s:vimim_get_data_from_directory(a:keyboard, a:im)
    if empty(lines)
        return []
    endif
    let results = []
    for line in lines
        for chinese in split(line)
            let pair = a:keyboard . " " . chinese
            call add(results, pair)
        endfor
    endfor
    return results
endfunction

" ----------------------------------------------
function! s:vimim_break_string_at(keyboard, max)
" ----------------------------------------------
    let max = a:max
    let keyboard = a:keyboard
    let blocks = [keyboard]
    if max > 0
        let blocks = [ keyboard[0 : max-1], keyboard[max : -1] ]
    endif
    return blocks
endfunction

" ------------------------------------------------
function! s:vimim_break_digit_every_four(keyboard)
" ------------------------------------------------
    let keyboard = a:keyboard
    if len(keyboard) < 4 || s:chinese_input_mode == 'dynamic'
        return []
    endif
    let blocks = []
    " 4corner showcase:  6021272260021762
    if keyboard =~ '\d\d\d\d'
        let blocks = split(a:keyboard, '\(.\{4}\)\zs')
    elseif keyboard =~ '\d\+$'
        let blocks = [keyboard]
    endif
    return blocks
endfunction

" ------------------------------------------------
function! s:vimim_get_sentence_directory(keyboard)
" ------------------------------------------------
    let msg = "Directory data is natural to text editor like vi."
    let keyboard = a:keyboard
    let results = []
    let keyboards = s:vimim_sentence_match_directory(keyboard, s:ui.im)
    if len(keyboards) > 0
        let keyboard = get(keyboards, 0)
        let results = s:vimim_get_pair_from_directory(keyboard, s:ui.im)
    endif
    return results
endfunction

" ------------------------------------------------------
function! s:vimim_sentence_match_directory(keyboard, im)
" ------------------------------------------------------
    let keyboard = a:keyboard
    let dir = s:vimim_get_valid_directory(a:im)
    let filename = dir . '/' . keyboard
    if filereadable(filename) || keyboard =~ '^oo'
        return [keyboard]
    endif
    " --------------------------------------------------
    let blocks = s:vimim_break_sentence_into_block(keyboard)
    if !empty(blocks)
        return blocks
    endif
    " --------------------------------------------------
    let max = s:vimim_hjkl_redo_pinyin_match(keyboard)
    while max > 1
        let max -= 1
        let head = strpart(keyboard, 0, max)
        let filename = dir . '/' . head
        if filereadable(filename)
            break
        else
            continue
        endif
    endwhile
    " --------------------------------------------------
    if filereadable(filename)
        return s:vimim_break_string_at(keyboard, max)
    else
        return []
    endif
endfunction

" ------------------------------------------------
function! s:vimim_hjkl_redo_pinyin_match(keyboard)
" ------------------------------------------------
" dummy word matching algorithm for pinyin segmentation
    let keyboard = a:keyboard
    if empty(keyboard)
        return 0
    endif
    let max = len(keyboard)
    if s:ui.im != 'pinyin' || s:chinese_input_mode == 'dynamic'
        return max
    endif
    " --------------------------------------------
    if !empty(s:keyboard_head)
        if s:pumvisible_hjkl_2nd_match > 0
            let s:pumvisible_hjkl_2nd_match = 0
            let length = len(s:keyboard_head)-1
            let keyboard = strpart(s:keyboard_head, 0, length)
        endif
    endif
    " --------------------------------------------
    let msg = " yeyeqifangcao  <C-6> <Space> <Space> < <Space> "
    let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
    if len(pinyins) > 1
        let last = pinyins[-1:-1]
        let max = len(keyboard)-len(last)-1
    endif
    return max
endfunction

" ------------------------
function! g:vimim_mkdir1()
" ------------------------
" within one line, new item is appeneded
" (1) existed order:  key  value_1 value_2
" (2) new items:      key  value_2 value_3
" (3) new order:      key  value_1 value_2 value_3
    call s:vimim_mkdir('append', 0, [])
endfunction

" ------------------------
function! g:vimim_mkdir2()
" ------------------------
" within one line, new item is inserted first
" (1) existed order:  key  value_1 value_2
" (2) new items:      key  value_2 value_3
" (3) new order:      key  value_2 value_3 value_1
    call s:vimim_mkdir('prepend', 0, [])
endfunction

" ------------------------
function! g:vimim_mkdir3()
" ------------------------
" replace the existed content with new items
" (1) existed order:  key  value_1 value_2
" (2) new items:      key  value_2 value_3
" (3) new order:      key  value_2 value_3
    call s:vimim_mkdir('replace', 0, [])
endfunction

" -----------------------------------------
function! s:vimim_mkdir(option, dir, lines)
" -----------------------------------------
" Goal: create one file per entry based on vimim.xxx.txt
" Sample file A: /home/vimim/pinyin/jjjj
" Sample file B: /home/vimim/unihan/u808f
" (1) $cd $VIM/vimfiles/plugin/vimim/
" (2) $vi vimim.pinyin.txt => :call g:vimim_mkdir1()
" --------------------------------------------------
    let dir = a:dir
    let lines = a:lines
    if empty(dir)
        let root = expand("%:p:h")
        let dir = root . "/" . expand("%:e:e:r")
        if !exists(dir) && !isdirectory(dir)
            call mkdir(dir, "p")
        endif
    endif
    if empty(lines)
        let lines = readfile(bufname("%"))
    endif
    let option = a:option
    for line in lines
        if line =~# '^\W'
            continue
        endif
        let entries = split(line)
        let key = get(entries, 0)
        if match(key, "'") > -1
            let key = substitute(key,"'",'','g')
        endif
        let key_as_filename = dir . "/" . key
        let chinese_list = entries[1:]
        " ----------------------------------------
        " u99ac 7132
        " u99ac ma3
        " u99ac 馬 horse; surname; KangXi radical 187
        " ----------------------------------------
        let first_list = []
        let second_list = []
        if filereadable(key_as_filename)
            let contents = split(join(readfile(key_as_filename)))
            if option =~ 'append'
                let first_list = contents
                let second_list = chinese_list
            elseif option =~ 'prepend'
                let first_list = chinese_list
                let second_list = contents
            elseif option =~ 'replace'
                let first_list = chinese_list
                let option = 'append'
            endif
            call extend(first_list, second_list)
            let chinese_list = copy(first_list)
        endif
        let results = s:vimim_remove_duplication(chinese_list)
        if !empty(results)
            call writefile(results, key_as_filename)
        endif
    endfor
endfunction

" -------------------------------------------
function! s:vimim_remove_duplication(chinese)
" -------------------------------------------
    let chinese = a:chinese
    if empty(chinese)
        return []
    endif
    let cache = {}
    let results = []
    for line in chinese
        let characters = split(line)
        for char in characters
            if has_key(cache, char) || empty(char)
                continue
            else
                let cache[char] = char
                call add(results, char)
            endif
        endfor
    endfor
    return results
endfunction

" ======================================== }}}
let VimIM = " ====  Backend=>Cloud    ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_has_embedded_backend()
" --------------------------------------
    if empty(s:backend.datafile) && empty(s:backend.directory)
        let msg = "try cloud if no vimim embedded backends"
        return 0
    endif
    return 1
endfunction

" ------------------------------------
function! s:vimim_scan_backend_cloud()
" ------------------------------------
" s:vimim_cloud_sogou=0  : default, auto open when no datafile
" s:vimim_cloud_sogou=-1 : cloud is shut down without condition
" -------------------------------------------------------------
    let embedded_backend = s:vimim_has_embedded_backend()
    if empty(embedded_backend) && empty(s:vimim_cloud_plugin)
        call s:vimim_set_sogou()
    endif
endfunction

" --------------------------------
function! s:vimim_do_force_sogou()
" --------------------------------
    let s:vimim_cloud_sogou = 1
    call s:vimim_set_sogou()
endfunction

" ---------------------------
function! s:vimim_set_sogou()
" ---------------------------
    if s:ui.root == "cloud" && s:ui.im == "sogou"
        return
    endif
    let cloud = s:vimim_set_cloud_backend_if_www_executable('sogou')
    if empty(cloud)
        let s:vimim_cloud_sogou = 0
        let s:backend.cloud = {}
    else
        let s:ui.root = "cloud"
        let s:ui.im = "sogou"
        let s:vimim_cloud_plugin = 0
    endif
endfunction

" -------------------------------------------------------
function! s:vimim_set_cloud_backend_if_www_executable(im)
" -------------------------------------------------------
    let im = a:im
    if empty(s:backend.cloud)
        let s:backend.cloud[im] = s:vimim_one_backend_hash()
    endif
    let cloud = s:vimim_check_http_executable(im)
    if empty(cloud)
        return 0
    else
        let s:backend.cloud[im].root = "cloud"
        let s:backend.cloud[im].im = im
        let s:backend.cloud[im].keycode = s:im_keycode[im]
        let s:backend.cloud[im].chinese = s:vimim_chinese(im)
        return cloud
    endif
endfunction

" -----------------------------------------
function! s:vimim_check_http_executable(im)
" -----------------------------------------
    if s:vimim_cloud_sogou < 0
        return {}
    endif
    " step #1 of 3: try to find libvimim
    let cloud = s:vimim_get_libvimim()
    if !empty(cloud) && filereadable(cloud)
        " in win32, strip the .dll suffix
        if has("win32") && cloud[-4:] ==? ".dll"
            let cloud = cloud[:-5]
        endif
        let ret = libcall(cloud, "do_geturl", "__isvalid")
        if ret ==# "True"
            let s:www_executable = cloud
            let s:www_libcall = 1
            call s:vimim_do_cloud_if_no_embedded_backend()
        else
            return {}
        endif
    endif
    " step #2 of 3: try to find wget
    if empty(s:www_executable)
        let wget = 0
        if executable(s:path .  "wget.exe")
            let wget = s:path . "wget.exe"
        elseif executable('wget')
            let wget = "wget"
        endif
        if empty(wget)
            let msg = "wget is not available"
        else
            let wget_option = " -qO - --timeout 20 -t 10 "
            let s:www_executable = wget . wget_option
        endif
    endif
    " step #3 of 3: try to find curl if no wget
    if empty(s:www_executable)
        if executable('curl')
            let s:www_executable = "curl -s "
        endif
    endif
    if empty(s:www_executable)
        return {}
    else
        call s:vimim_do_cloud_if_no_embedded_backend()
    endif
    return s:backend.cloud[a:im]
endfunction

" -------------------------------------------------
function! s:vimim_do_cloud_if_no_embedded_backend()
" -------------------------------------------------
    if empty(s:backend.directory) && empty(s:backend.datafile)
        if empty(s:vimim_cloud_sogou)
            let s:vimim_cloud_sogou = 1
        endif
    endif
endfunction

" ------------------------------------
function! s:vimim_magic_tail(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if keyboard =~ '\d\d\d\d'
        return []
    endif
    let magic_tail = keyboard[-1:]
    let last_but_one = keyboard[-2:-2]
    if magic_tail =~ "[.']" && last_but_one =~ "[0-9a-z]"
        let msg = "play with magic trailing char"
    else
        return []
    endif
    let keyboards = []
    " ----------------------------------------------------
    " <dot> double play in OneKey:
    "   (1) magic trailing dot => forced-non-cloud
    "   (2) as word partition  => match dot by dot
    " ----------------------------------------------------
    if magic_tail ==# "."
        let msg = "trailing dot => forced-non-cloud"
        let s:no_internet_connection = 2
        call add(keyboards, -1)
    elseif magic_tail ==# "'"
        let msg = "trailing apostrophe => forced-cloud"
        let s:no_internet_connection = -1
        let cloud = s:vimim_set_cloud_backend_if_www_executable('sogou')
        if empty(cloud)
            return []
        endif
        call add(keyboards, 1)
    endif
    " ----------------------------------------------------
    " <apostrophe> double play in OneKey:
    "   (1) magic trailing apostrophe => cloud at will
    "   (2) magic leading  apostrophe => universal imode
    " ----------------------------------------------------
    let keyboard = keyboard[:-2]
    call insert(keyboards, keyboard)
    return keyboards
endfunction

" -------------------------------------------------
function! s:vimim_to_cloud_or_not(keyboard, clouds)
" -------------------------------------------------
    let do_cloud = get(a:clouds, 1)
    if do_cloud > 0
        return 1
    endif
    if s:no_internet_connection > 1
        let msg = "oops, there is no internet connection"
        return 0
    elseif s:no_internet_connection < 0
        return 1
    endif
    if s:vimim_cloud_sogou < 1
        return 0
    endif
    let keyboard = a:keyboard
    if s:chinese_input_mode == 'onekey' && keyboard =~ '[.]'
        return 0
    endif
    if keyboard =~# "[^a-z']"
        let msg = "cloud limits to valid cloud keycodes only"
        return 0
    endif
    let msg = "auto cloud if number of zi is greater than threshold"
    let threshold = len(keyboard)
    if s:chinese_input_mode == 'static'
        let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
        let threshold = len(pinyins)
    endif
    if threshold < s:vimim_cloud_sogou
        return 0
    else
        return 1
    endif
endfunction

" -------------------------------
function! s:vimim_get_sogou_key()
" -------------------------------
    let executable = s:www_executable
    if empty(executable)
        return 0
    endif
    let cloud = 'http://web.pinyin.sogou.com/web_ime/patch.php'
    let output = 0
    try
        if s:www_libcall
            let input = cloud
            let output = libcall(executable, "do_geturl", input)
        else
            let input = cloud
            let output = system(executable . input)
        endif
    catch
        let msg = "It looks like sogou has trouble with its cloud?"
        call s:debugs('sogou::exception=', v:exception)
        let output = 0
    endtry
    if empty(output)
        return 0
    endif
    return get(split(output, '"'), 1)
endfunction

" ------------------------------------------------
function! s:vimim_get_cloud_sogou(keyboard, force)
" ------------------------------------------------
" http://web.pinyin.sogou.com/web_ime/get_ajax/woyouyigemeng.key
    let keyboard = a:keyboard
    let executable = s:www_executable
    if empty(executable) || empty(keyboard)
        return []
    endif
    if s:vimim_cloud_sogou < 1 && a:force < 1
        return []
    endif
    " only use sogou when we get a valid key
    if empty(s:backend.cloud.sogou.sogou_key)
        let s:backend.cloud.sogou.sogou_key = s:vimim_get_sogou_key()
    endif
    let cloud = 'http://web.pinyin.sogou.com/api/py?key='
    let cloud = cloud . s:backend.cloud.sogou.sogou_key .'&query='
    " sogou stopped supporting apostrophe as delimiter
    let output = 0
    try
        if s:www_libcall > 0
            let input = cloud . keyboard
            let output = libcall(executable, "do_geturl", input)
        else
            let input = '"' . cloud . keyboard . '"'
            let output = system(executable . input)
        endif
    catch
        let msg = "it looks like sogou has trouble with its cloud?"
        call s:debugs('sogou::exception=', v:exception)
        let output = 0
    endtry
    call s:debugs('sogou::outputquery=', output)
    if empty(output)
        return []
    endif
    let first = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first > 0 && second > 0
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if empty(output)
        return []
    endif
    if empty(s:localization)
        let msg = "support gb and big5 in addition to utf8"
    else
        let output = s:vimim_i18n_read(output)
    endif
    " output => '我有一個夢：13    +
    let menu = []
    for item in split(output, '\t+')
        let item_list = split(item, '：')
        if len(item_list) > 1
            let chinese = get(item_list,0)
            let english = strpart(keyboard, 0, get(item_list,1))
            let new_item = english . " " . chinese
            call add(menu, new_item)
        endif
    endfor
    " output => ['woyouyigemeng 我有一個夢']
    return menu
endfunction

" ======================================== }}}
let VimIM = " ====  Backend=>myCloud  ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_scan_backend_mycloud()
" --------------------------------------
" let g:vimim_mycloud_url = "app:python d:/mycloud/mycloud.py"
" let g:vimim_mycloud_url = "app:".$VIM."/src/mycloud/mycloud"
" let g:vimim_mycloud_url = "dll:".$HOME."/plugin/cygvimim.dll"
" let g:vimim_mycloud_url = "dll:".$HOME."/plugin/libvimim.so"
" let g:vimim_mycloud_url = "dll:/home/im/plugin/libmyplugin.so:arg:func"
" let g:vimim_mycloud_url = "dll:/data/libvimim.so:192.168.0.1"
" let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/abc/"
" let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/ms/"
" -----------------------------------------------------------------------
    let embedded_backend = s:vimim_has_embedded_backend()
    if empty(embedded_backend)
        call s:vimim_set_mycloud()
    endif
endfunction

" ----------------------------------
function! s:vimim_do_force_mycloud()
" ----------------------------------
" [quick test] vim mycloud.vimim
" ----------------------------------
    if s:vimim_mycloud_url =~ '^http\|^dll\|^app'
        return
    endif
    let s:vimim_mycloud_url = "http://pim-cloud.appspot.com/qp/"
    call s:vimim_set_mycloud()
endfunction

" -----------------------------
function! s:vimim_set_mycloud()
" -----------------------------
    if s:ui.root == "cloud" && s:ui.im == "mycloud"
        return
    endif
    let mycloud = s:vimim_set_mycloud_backend()
    if empty(mycloud)
        let msg = " mycloud is not available"
    else
        let s:ui.root = "cloud"
        let s:ui.im = "mycloud"
    endif
endfunction

" -------------------------------------
function! s:vimim_set_mycloud_backend()
" -------------------------------------
    let cloud = s:vimim_set_cloud_backend_if_www_executable('mycloud')
    if empty(cloud)
        return {}
    endif
    let mycloud = s:vimim_check_mycloud_availability()
    if empty(mycloud)
        let s:backend.cloud = {}
        return {}
    else
        let s:vimim_cloud_sogou = -777
        let s:vimim_cloud_plugin = mycloud
        return s:backend.cloud.mycloud
    endif
endfunction

" --------------------------------------------
function! s:vimim_check_mycloud_availability()
" --------------------------------------------
" note: this variable should not be used after initialization
"       unlet s:vimim_mycloud_url
" note: reuse it to support forced buffer scan: vim mycloud.vimim
" --------------------------------------------
    let cloud = 0
    if empty(s:vimim_mycloud_url)
        let cloud = s:vimim_check_mycloud_plugin_libcall()
    else
        let cloud = s:vimim_check_mycloud_plugin_url()
    endif
    if empty(cloud)
        let s:vimim_cloud_plugin = 0
        return 0
    endif
    " ----------------------------------------
    " note: how to avoid *Not Responding*?
    let ret = s:vimim_access_mycloud(cloud, "__getname")
    let directory = split(ret, "\t")[0]
    let ret = s:vimim_access_mycloud(cloud, "__getkeychars")
    let keycode = split(ret, "\t")[0]
    if empty(keycode)
        let s:vimim_cloud_plugin = 0
        return 0
    else
        let s:backend.cloud.mycloud.directory = directory
        let s:backend.cloud.mycloud.keycode = s:im_keycode["mycloud"]
        return cloud
    endif
endfunction

" ------------------------------------------
function! s:vimim_access_mycloud(cloud, cmd)
" ------------------------------------------
"  use the same function to access mycloud by libcall() or system()
    let executable = s:www_executable
    call s:debugs("cloud", a:cloud)
    call s:debugs("cmd", a:cmd)
    if s:cloud_plugin_mode == "libcall"
        let arg = s:cloud_plugin_arg
        if empty(arg)
            return libcall(a:cloud, s:cloud_plugin_func, a:cmd)
        else
            return libcall(a:cloud, s:cloud_plugin_func, arg." ".a:cmd)
        endif
    elseif s:cloud_plugin_mode == "system"
        return system(a:cloud." ".shellescape(a:cmd))
    elseif s:cloud_plugin_mode == "www"
        let input = s:vimim_rot13(a:cmd)
        if s:www_libcall
            let ret = libcall(executable, "do_geturl", a:cloud.input)
        else
            let ret = system(executable . shellescape(a:cloud.input))
        endif
        let output = s:vimim_rot13(ret)
        let ret = s:vimim_url_xx_to_chinese(output)
        return ret
    endif
    return ""
endfunction

" ------------------------------
function! s:vimim_get_libvimim()
" ------------------------------
    let cloud = 0
    if has("win32") || has("win32unix")
        let cloud = s:path . "libvimim.dll"
    elseif has("unix")
        let cloud = s:path . "libvimim.so"
    else
        return 0
    endif
    if filereadable(cloud)
        return cloud
    elseif filereadable(s:vimim_libvimdll)
        if has("win32") || has("win32unix")
            return s:vimim_libvimdll
        endif
    endif
    return 0
endfunction

" ----------------------------------------------
function! s:vimim_check_mycloud_plugin_libcall()
" ----------------------------------------------
    " we do plug-n-play for libcall(), not for system()
    let cloud = s:vimim_get_libvimim()
    if empty(cloud)
        return 0
    endif
    let s:cloud_plugin_mode = "libcall"
    let s:cloud_plugin_arg = ""
    let s:cloud_plugin_func = 'do_getlocal'
    if filereadable(cloud)
        if has("win32")
            " we don't need to strip ".dll" for "win32unix".
            let cloud = cloud[:-5]
        endif
        try
            let ret = s:vimim_access_mycloud(cloud, "__isvalid")
            if split(ret, "\t")[0] == "True"
                return cloud
            endif
        catch
            call s:debugs('libcall_mycloud2::error=',v:exception)
        endtry
    endif
    " libcall check failed, we now check system()
    if has("gui_win32")
        return 0
    endif
    let mes = "on linux, we do plug-n-play"
    let cloud = s:path . "mycloud/mycloud"
    if !executable(cloud)
        if !executable("python")
            return 0
        endif
        let cloud = "python " . cloud
    endif
    " in POSIX system, we can use system() for mycloud
    let s:cloud_plugin_mode = "system"
    let ret = s:vimim_access_mycloud(cloud, "__isvalid")
    if split(ret, "\t")[0] == "True"
        return cloud
    endif
    return 0
endfunction

" ------------------------------------------
function! s:vimim_check_mycloud_plugin_url()
" ------------------------------------------
    " we do set-and-play on all systems
    let part = split(s:vimim_mycloud_url, ':')
    let lenpart = len(part)
    if lenpart <= 1
        call s:debugs("invalid_cloud_plugin_url","")
    elseif part[0] ==# 'app'
        if !has("gui_win32")
            " strip the first root if contains ":"
            if lenpart == 3
                if part[1][0] == '/'
                    let cloud = part[1][1:] . ':' .  part[2]
                else
                    let cloud = part[1] . ':' . part[2]
                endif
            elseif lenpart == 2
                let cloud = part[1]
            endif
            " in POSIX system, we can use system() for mycloud
            if executable(split(cloud, " ")[0])
                let s:cloud_plugin_mode = "system"
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            endif
        endif
    elseif part[0] ==# "dll"
        if len(part[1]) == 1
            let base = 1
        else
            let base = 0
        endif
        " provide function name
        if lenpart >= base+4
            let s:cloud_plugin_func = part[base+3]
        else
            let s:cloud_plugin_func = 'do_getlocal'
        endif
        " provide argument
        if lenpart >= base+3
            let s:cloud_plugin_arg = part[base+2]
        else
            let s:cloud_plugin_arg = ""
        endif
        " provide the dll
        if base == 1
            let cloud = part[1] . ':' . part[2]
        else
            let cloud = part[1]
        endif
        if filereadable(cloud)
            let s:cloud_plugin_mode = "libcall"
            " strip off the .dll suffix, only required for win32
            if has("win32") && cloud[-4:] ==? ".dll"
                let cloud = cloud[:-5]
            endif
            try
                let ret = s:vimim_access_mycloud(cloud, "__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                let key = 'libcall_mycloud1::error='
                call s:debugs(key, v:exception)
            endtry
        endif
    elseif part[0] ==# "http" || part[0] ==# "https"
        let cloud = s:vimim_mycloud_url
        if !empty(s:www_executable)
            let s:cloud_plugin_mode = "www"
            let ret = s:vimim_access_mycloud(cloud, "__isvalid")
            if split(ret, "\t")[0] == "True"
                return cloud
            endif
        endif
    else
        call s:debugs("invalid_cloud_plugin_url","")
    endif
    return 0
endfunction

" --------------------------------------------
function! s:vimim_get_mycloud_plugin(keyboard)
" --------------------------------------------
    if empty(s:vimim_cloud_plugin)
        return []
    endif
    let cloud = s:vimim_cloud_plugin
    let input = a:keyboard
    let output = 0
    try
        let output = s:vimim_access_mycloud(cloud, input)
    catch
        let output = 0
        call s:debugs('mycloud::error=',v:exception)
    endtry
    if empty(output)
        return []
    endif
    return s:vimim_process_mycloud_output(a:keyboard, output)
endfunction

" --------------------------------------------------------
function! s:vimim_process_mycloud_output(keyboard, output)
" --------------------------------------------------------
" one line output example:  春夢      8       4420
    let output = a:output
    if empty(output) || empty(a:keyboard)
        return []
    endif
    let menu = []
    for item in split(output, '\n')
        let item_list = split(item, '\t')
        let chinese = get(item_list,0)
        if s:localization > 0
            let chinese = s:vimim_i18n_read(chinese)
        endif
        if empty(chinese) || get(item_list,1,-1)<0
            " bypass the debug line which have -1
            continue
        endif
        let extra_text = get(item_list,2)
        let english = a:keyboard[get(item_list,1):]
        let new_item = extra_text . " " . chinese . english
        call add(menu, new_item)
    endfor
    return menu
endfunction

" -------------------------------------
function! s:vimim_url_xx_to_chinese(xx)
" -------------------------------------
    let input = a:xx
    let output = a:xx
    if s:www_libcall > 0
        let output = libcall(s:www_executable, "do_unquote", a:xx)
    else
        let output = substitute(input, '%\(\x\x\)',
                    \ '\=eval(''"\x''.submatch(1).''"'')','g')
    endif
    return output
endfunction

" -------------------------------
function! s:vimim_rot13(keyboard)
" -------------------------------
    let rot13 = a:keyboard
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    let rot13 = tr(rot13, a.z, z.a)
    return rot13
endfunction

" ======================================== }}}
let VimIM = " ====  Debug_Framework   ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ----------------------------------
function! s:vimim_initialize_debug()
" ----------------------------------
    if !isdirectory("/home/xma/vim")
        return
    endif
    let s:vimim_private_data_directory = "/home/xma/oo/"
    let s:vimim_private_data_file =      "/home/xma/oo/io"
    let s:vimim_data_directory =         "/home/vimim/"
    let svn = s:vimim_data_directory . "svn"
    let s:vimim_vimimdata = svn . "/vimim-data/trunk/data/"
    let s:vimim_libvimdll = svn . "/mycloud/vimim-mycloud/libvimim.dll"
    let s:vimim_custom_skin = 3
    let s:vimim_tab_as_onekey = 2
endfunction

" ------------------------------------
function! s:vimim_initialize_frontend()
" ------------------------------------
    let s:ui = {}
    let s:ui.im  = ''
    let s:ui.root = ''
    let s:ui.keycode = ''
    let s:ui.statusline = ''
    let s:ui.has_dot = 0
    let s:ui.frontends = []
endfunction

" ------------------------------------
function! s:vimim_initialize_backend()
" ------------------------------------
    let s:backend = {}
    let s:backend.directory = {}
    let s:backend.datafile  = {}
    let s:backend.cloud     = {}
endfunction

" ---------------------------------
function! s:vimim_one_backend_hash()
" ----------------------------------
    let one_backend_hash = {}
    let one_backend_hash.root = 0
    let one_backend_hash.im = 0
    let one_backend_hash.executable = 0
    let one_backend_hash.libcall = 0
    let one_backend_hash.sogou_key = 0
    let one_backend_hash.chinese = 0
    let one_backend_hash.directory = 0
    let one_backend_hash.datafile = 0
    let one_backend_hash.lines = []
    let one_backend_hash.cache = {}
    let one_backend_hash.keycode = "[0-9a-z'.]"
    let one_backend_hash.chinese_mode_switch = 1
    return one_backend_hash
endfunction

" --------------------------------
function! s:vimim_egg_vimimdebug()
" --------------------------------
    let eggs = []
    for item in s:debugs
        let egg = "> "
        let egg .= item
        let egg .= s:space
        call add(eggs, egg)
    endfor
    if empty(eggs)
        let eggs = s:vimim_egg_vimimdefaults()
    endif
    return eggs
endfunction

" ----------------------------
function! s:debugs(key, value)
" ----------------------------
    if s:vimimdebug > 0
        let item = '['
        let item .= s:debug_count
        let item .= ']'
        let item .= a:key
        let item .= '='
        let item .= a:value
        call add(s:debugs, item)
    endif
endfunction

" -----------------------------
function! s:debug_list(results)
" -----------------------------
    let string_in = string(a:results)
    let length = 5
    let delimiter = ":"
    let string_out = join(split(string_in)[0 : length], delimiter)
    return string_out
endfunction

" -----------------------------
function! s:vimim_debug_reset()
" -----------------------------
    if s:vimimdebug > 0
        let max = 512
        if s:debug_count > max
            let begin = len(s:debugs) - max
            if begin < 0
                let begin = 0
            endif
            let end = len(s:debugs) - 1
            let s:debugs = s:debugs[begin : end]
        endif
    endif
endfunction

" ======================================== }}}
let VimIM = " ====  Plugin_Conflict   ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ----------------------------------
function! s:vimim_getsid(scriptname)
" ----------------------------------
" frederick.zou fixed these conflicting plugins:
" supertab      http://www.vim.org/scripts/script.php?script_id=1643
" autocomplpop  http://www.vim.org/scripts/script.php?script_id=1879
" word_complete http://www.vim.org/scripts/script.php?script_id=73
" -----------------------------------
    " use s:getsid to get script sid, translate <SID> to <SNR>N_ style
    let l:scriptname = a:scriptname
    " get output of ":scriptnames" in scriptnames_output variable
    if empty(s:scriptnames_output)
        let saved_shellslash=&shellslash
        set shellslash
        redir => s:scriptnames_output
        silent scriptnames
        redir END
        let &shellslash = saved_shellslash
    endif
    for line in split(s:scriptnames_output, "\n")
        " only do non-blank lines
        if line =~ l:scriptname
            " get the first number in the line.
            let nr = matchstr(line, '\d\+')
            return nr
        endif
    endfor
    return 0
endfunction

" -----------------------------------
function! s:vimim_plugins_fix_start()
" -----------------------------------
    if !exists('s:acp_sid')
        let s:acp_sid = s:vimim_getsid('autoload/acp.vim')
        if !empty(s:acp_sid)
            AcpDisable
        endif
    endif
    if !exists('s:supertab_sid')
        let s:supertab_sid = s:vimim_getsid('plugin/supertab.vim')
    endif
    if !exists('s:word_complete')
        let s:word_complete = s:vimim_getsid('plugin/word_complete.vim')
        if !empty(s:word_complete)
            call EndWordComplete()
        endif
    endif
endfunction

" ----------------------------------
function! s:vimim_plugins_fix_stop()
" ----------------------------------
    if !empty(s:acp_sid)
        let ACPMappingDrivenkeys = [
            \ '-','_','~','^','.',',',':','!','#','=','%','$','@',
            \ '<','>','/','\','<Space>','<C-H>','<BS>','<Enter>',]
        call extend(ACPMappingDrivenkeys, range(10))
        call extend(ACPMappingDrivenkeys, s:Az_list)
        for key in ACPMappingDrivenkeys
            exe printf('iu <silent> %s', key)
            exe printf('im <silent> %s
            \ %s<C-r>=<SNR>%s_feedPopup()<CR>', key, key, s:acp_sid)
        endfor
        AcpEnable
    endif
    " -------------------------------------------------------------
    if !empty(s:supertab_sid)
        let tab = s:supertab_sid
        if g:SuperTabMappingForward =~ '^<tab>$'
            exe printf("im <tab> <C-R>=<SNR>%s_SuperTab('p')<CR>", tab)
        endif
        if g:SuperTabMappingBackward =~ '^<s-tab>$'
            exe printf("im <s-tab> <C-R>=<SNR>%s_SuperTab('n')<CR>", tab)
            " inoremap <silent> <Tab>   <C-N>
            " inoremap <silent> <S-Tab> <C-P>
        endif
    endif
    " -------------------------------------------------------------
    if !empty(s:word_complete)
    "   call DoWordComplete()
    endif
endfunction

" ======================================== }}}
let VimIM = " ====  Core_Workflow     ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_initialize_i_setting()
" --------------------------------------
    let s:saved_cpo=&cpo
    let s:saved_iminsert=&iminsert
    let s:completefunc=&completefunc
    let s:completeopt=&completeopt
    let s:saved_lazyredraw=&lazyredraw
    let s:saved_pumheight=&pumheight
    let s:saved_laststatus=&laststatus
    let s:saved_hlsearch=&hlsearch
    let s:saved_smartcase=&smartcase
endfunction

" ------------------------------
function! s:vimim_i_setting_on()
" ------------------------------
    set nolazyredraw
    if empty(&pumheight)
        let &pumheight=9
    endif
    set hlsearch
    set smartcase
    set iminsert=1
endfunction

" -------------------------------
function! s:vimim_i_setting_off()
" -------------------------------
    let &cpo=s:saved_cpo
    let &iminsert=s:saved_iminsert
    let &completefunc=s:completefunc
    let &completeopt=s:completeopt
    let &lazyredraw=s:saved_lazyredraw
    let &pumheight=s:saved_pumheight
    let &laststatus=s:saved_laststatus
    let &hlsearch=s:saved_hlsearch
    let &smartcase=s:saved_smartcase
endfunction

" ----------------------------
function! s:vimim_start_omni()
" ----------------------------
    let s:insert_without_popup = 0
endfunction

" -----------------------------
function! s:vimim_super_reset()
" -----------------------------
    sil!call s:reset_before_anything()
    sil!call g:vimim_reset_after_auto_insert()
    sil!call s:vimim_reset_before_stop()
endfunction

" -----------------------
function! s:vimim_start()
" -----------------------
    sil!call s:vimim_plugins_fix_start()
    sil!call s:vimim_i_setting_on()
    sil!call s:vimim_cursor_color(1)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_label_on()
    sil!call s:vimim_space_on()
    sil!call s:vimim_helper_mapping_on()
endfunction

" ----------------------
function! s:vimim_stop()
" ----------------------
    sil!call s:vimim_i_setting_off()
    sil!call s:vimim_cursor_color(0)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_debug_reset()
    sil!call s:vimim_i_map_off()
    sil!call s:vimim_initialize_mapping()
    sil!call s:vimim_plugins_fix_stop()
endfunction

" -----------------------------------
function! s:vimim_reset_before_stop()
" -----------------------------------
    let s:onekeynonstop = 0
    let s:smart_enter = 0
    let s:pumvisible_ctrl_e = 0
endfunction

" ---------------------------------
function! s:reset_before_anything()
" ---------------------------------
    call s:reset_matched_list()
    let s:no_internet_connection = 0
    let s:pattern_not_found = 0
    let s:chinese_punctuation = (s:vimim_chinese_punctuation+1)%2
endfunction

" ------------------------------
function! s:reset_matched_list()
" ------------------------------
    let s:pumvisible_yes = 0
    let s:keyboard_head = 0
    let s:pumvisible_hjkl_2nd_match = 0
    let s:menu_digit_as_filter = ""
    let s:matched_list = []
endfunction

" -----------------------------------------
function! g:vimim_reset_after_auto_insert()
" -----------------------------------------
    let s:keyboard_leading_zero = ""
    let s:keyboard_shuangpin = 0
    return ""
endfunction

" ------------------------------------
function! g:vimim_reset_after_insert()
" ------------------------------------
    if empty(s:onekeynonstop)
    \&& s:chinese_input_mode == 'onekey'
    \&& empty(s:tail)
        call s:vimim_stop()
    endif
    let key = ""
    if s:pumvisible_yes > 0
        let key = g:vimim()
    endif
    call s:reset_matched_list()
    call g:vimim_reset_after_auto_insert()
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------
function! g:vimim()
" -----------------
    if empty(&completefunc) || &completefunc != 'VimIM'
        set completefunc=VimIM
        set completeopt=menuone
    endif
" -----------------------------------------------------
    let key = ""
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~ s:valid_key
        let key = '\<C-X>\<C-U>'
    endif
    if empty(key) && s:chinese_input_mode != 'dynamic'
        let five_byte_before = getline(".")[col(".")-6]
        if byte_before =~ '\x' && five_byte_before ==# 'u'
            let key = '\<C-X>\<C-U>'
        endif
    endif
    if empty(key)
        call g:vimim_reset_after_auto_insert()
    else
        if s:chinese_input_mode == 'dynamic'
            call g:vimim_reset_after_auto_insert()
        endif
        let key .= '\<C-R>=g:vimim_menu_select()\<CR>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------
function! g:vimim_menu_select()
" -----------------------------
    let key = ""
    if pumvisible()
        let key = '\<C-P>\<Down>'
        if s:insert_without_popup > 0
            let key = '\<C-Y>'
            if s:insert_without_popup > 1
                let key .= '\<Esc>'
            endif
            call s:reset_matched_list()
            let s:insert_without_popup = 0
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ---------------------------
function! s:vimim_i_map_off()
" ---------------------------
    let s:chinese_input_mode = "onekey"
    let unmap_list = range(0,9)
    call extend(unmap_list, s:valid_keys)
    call extend(unmap_list, s:AZ_list)
    call extend(unmap_list, keys(s:punctuations))
    call extend(unmap_list, ['<Esc>','<CR>','<BS>','<Space>'])
    " -----------------------
    for _ in unmap_list
        sil!exe 'iunmap '. _
    endfor
    " -----------------------
    iunmap <Bslash>
    iunmap '
    iunmap "
endfunction

" -----------------------------------
function! s:vimim_helper_mapping_on()
" -----------------------------------
    inoremap <CR>  <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                  \<C-R>=<SID>vimim_smart_enter()<CR>
    " ----------------------------------------------------------
    inoremap <BS>  <C-R>=g:vimim_pumvisible_ctrl_e_on()<CR>
                  \<C-R>=g:vimim_backspace()<CR>
    " ----------------------------------------------------------
    if s:chinese_input_mode == 'onekey'
        inoremap <Esc> <C-R>=g:vimim_esc()<CR>
    elseif s:chinese_input_mode == 'static'
        inoremap <Esc> <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                      \<C-R>=g:vimim_one_key_correction()<CR>
    endif
    " ----------------------------------------------------------
    if s:chinese_input_mode !~ 'onekey'
        inoremap <expr> <C-^> <SID>vimim_toggle_punctuation()
    endif
    " ----------------------------------------------------------
endfunction

" ======================================== }}}
let VimIM = " ====  Core_Engine       ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" -------------------------------------------------
function! s:vimim_embedded_backend_engine(keyboard)
" -------------------------------------------------
    let im = s:ui.im
    let root = s:ui.root
    if empty(root) || empty(im)
        return []
    endif
    let keyboard = a:keyboard
    if keyboard !~# s:valid_key
        return []
    endif
    let results = []
    if root =~# "directory"
        let results = s:vimim_get_sentence_directory(keyboard)
    elseif root =~# "datafile"
        if empty(s:backend[root][im].cache)
            let results = s:vimim_get_sentence_datafile_lines(keyboard)
        else
            let results = s:vimim_get_sentence_datafile_cache(keyboard)
        endif
    endif
    if !empty(results)
        let results = s:vimim_pair_list(results)
    endif
    return results
endfunction

" ------------------------------
function! VimIM(start, keyboard)
" ------------------------------
if a:start

    call s:vimim_start_omni()
    let current_positions = getpos(".")
    let start_column = current_positions[2]-1
    let start_column_save = start_column
    let start_row = current_positions[1]
    let current_line = getline(start_row)
    let byte_before = current_line[start_column-1]
    let char_before_before = current_line[start_column-2]

    " take care of seamless English/Chinese input
    " -------------------------------------------
    let seamless_column = s:vimim_get_seamless(current_positions)
    if seamless_column < 0
        let msg = "no need to set seamless"
    else
        let s:start_column_before = seamless_column
        return seamless_column
    endif

    let last_seen_nonsense_column = start_column
    let last_seen_backslash_column = start_column
    let nonsense_pattern = "[0-9.']"
    if s:ui.im == 'pinyin'
        let nonsense_pattern = "[0-9.]"
    elseif s:ui.has_dot == 1
        let nonsense_pattern = "[.]"
    endif

    while start_column > 0
        if byte_before =~# s:valid_key
            let start_column -= 1
            if byte_before !~# nonsense_pattern
                let last_seen_nonsense_column = start_column
            endif
        elseif byte_before=='\' && s:vimim_backslash_close_pinyin>0
            " do nothing for pinyin with leading backslash
            return last_seen_backslash_column
        else
            break
        endif
        let byte_before = current_line[start_column-1]
    endwhile

    let s:start_row_before = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let s:keyboard_leading_zero = strpart(current_line,start_column,len)
    let s:start_column_before = start_column
    return start_column

else

    let keyboard = s:vimim_get_valid_keyboard(a:keyboard)
    if empty(keyboard)
        return
    endif

    " [one_key_correction] for static mode using Esc
    " ----------------------------------------------
    if s:one_key_correction > 0
        let s:one_key_correction = 0
        return [' ']
    endif

    " [filter] use cache for all vimim backends
    " -----------------------------------------
    if len(s:menu_digit_as_filter) > 0
        if len(s:matched_list) > 1
            let results = s:vimim_pair_list(s:matched_list)
            if empty(len(results))
                let results = s:vimim_get_previous_pair_list()
            endif
            if !empty(len(results))
                return s:vimim_popupmenu_list(results)
            endif
        endif
    endif

    " [eggs] hunt classic easter egg ... vim<C-6>
    " -------------------------------------------
    if s:chinese_input_mode =~ 'onekey'
        if keyboard ==# "vim" || keyboard =~# "^vimim"
            let results = s:vimim_easter_chicken(keyboard)
            if !empty(len(results))
                return s:vimim_popupmenu_list(results)
            endif
        endif
    endif

    " [unicode] support direct unicode/gb/big5 input
    " ----------------------------------------------
    if s:chinese_input_mode =~ 'onekey'
        let results = s:vimim_get_unicode(keyboard, 108/9)
        if !empty(len(results))
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [imode] magic 'i': English number => Chinese number
    " ---------------------------------------------------
    if s:chinese_input_mode != 'dynamic' && s:ui.has_dot < 1
    \&& s:vimim_imode_pinyin > 0 && keyboard =~# '^i'
        let msg = " usage: i88<C-6> ii88<C-6> i1g<C-6> isw8ql "
        let chinese_numbers = s:vimim_imode_number(keyboard, 'i')
        if !empty(len(chinese_numbers))
            return s:vimim_popupmenu_list(chinese_numbers)
        endif
    endif

    " [mycloud] get chunmeng from mycloud local or www
    " ------------------------------------------------
    if empty(s:vimim_cloud_plugin)
        let msg = "keep local mycloud code for the future"
    else
        let results = s:vimim_get_mycloud_plugin(keyboard)
        if empty(len(results))
            return []
        else
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [cloud] magic trailing apostrophe to control cloud
    " --------------------------------------------------
    let clouds = s:vimim_magic_tail(keyboard)
    if !empty(len(clouds))
        let msg = " usage: woyouyigemeng'<C-6> "
        let keyboard = get(clouds, 0)
    endif

    " [shuangpin] support 6 major shuangpin with various rules
    " --------------------------------------------------------
    if !empty(s:vimim_shuangpin) && empty(s:keyboard_shuangpin)
        let keyboard = s:vimim_get_pinyin_from_shuangpin(keyboard)
    endif

    let s:keyboard_leading_zero = keyboard
    " ------------------------------------
    if s:ui.has_dot == 2
        let keyboard = s:vimim_apostrophe(keyboard)
    endif

    " [sogou] to make cloud come true for woyouyigemeng
    " -------------------------------------------------
    let cloud = s:vimim_to_cloud_or_not(keyboard, clouds)
    if cloud > 0
        let results = s:vimim_get_cloud_sogou(keyboard, cloud)
        if empty(len(results))
            if s:vimim_cloud_sogou > 2
                let s:no_internet_connection += 1
            endif
        else
            let s:no_internet_connection = 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [wubi] support wubi auto input
    " ------------------------------
    if s:ui.im == 'wubi' || s:ui.im == 'erbi'
        let keyboard = s:vimim_wubi_4char_auto_input(keyboard)
        if s:ui.im =~ 'erbi'
            let punctuation = s:vimim_erbi_first_punctuation(keyboard)
            if !empty(punctuation)
                return [punctuation]
            endif
        endif
    endif

    " [backend] plug-n-play embedded backend engine
    " ---------------------------------------------
    let results = s:vimim_embedded_backend_engine(keyboard)
    if empty(results)
        if s:chinese_input_mode =~ 'dynamic'
            let s:keyboard_leading_zero = ""
        endif
    else
        return s:vimim_popupmenu_list(results)
    endif

    " [sogou] last try cloud before giving up
    " ---------------------------------------
    if s:vimim_cloud_sogou == 1
        let results = s:vimim_get_cloud_sogou(keyboard, 1)
        if !empty(len(results))
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [seamless] support seamless English input
    " -----------------------------------------
    let s:pattern_not_found += 1
    let results = []
    if s:chinese_input_mode == 'onekey'
        let results = [keyboard ." ". keyboard]
    else
        call <SID>vimim_set_seamless()
    endif
    return s:vimim_popupmenu_list(results)

endif
endfunction

" --------------------------------------------
function! s:vimim_get_valid_keyboard(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    if s:vimimdebug > 0
        let s:debug_count += 1
        call s:debugs('keyboard', s:keyboard_leading_zero)
    endif
    if empty(s:keyboard_leading_zero)
        let s:keyboard_leading_zero = keyboard
    endif
    if empty(str2nr(keyboard))
        let msg = "keyboard input is alphabet only"
    else
        let keyboard = s:keyboard_leading_zero
    endif
    " [unicode] support direct unicode/gb/big5 input
    if keyboard =~# 'u\x\x\x\x' && len(keyboard)==5
        return keyboard
    endif
    " ignore all-zeroes keyboard inputs
    if empty(s:keyboard_leading_zero)
        return 0
    endif
    if keyboard !~# s:valid_key
        return 0
    endif
    " ignore multiple non-sense dots
    if keyboard =~# '^[\.\.\+]' && empty(s:ui.has_dot)
        let s:pattern_not_found += 1
        return 0
    endif
    return keyboard
endfunction

" ======================================== }}}
let VimIM = " ====  Core_Driver       ==== {{{"
" ============================================
call add(s:vimims, VimIM)

" ------------------------------------
function! s:vimim_initialize_mapping()
" ------------------------------------
    sil!call s:vimim_chinesemode_mapping_on()
    sil!call s:vimim_onekey_mapping_on()
    imap <C-@> <C-Bslash>
endfunction

" ----------------------------------------
function! s:vimim_chinesemode_mapping_on()
" ----------------------------------------
    if s:vimim_tab_as_onekey < 2
        inoremap <unique> <expr>     <Plug>VimimTrigger <SID>ChineseMode()
            imap <silent> <C-Bslash> <Plug>VimimTrigger
         noremap <silent> <C-Bslash> :call <SID>ChineseMode()<CR>
    endif
    " ------------------------------------
    if s:vimim_ctrl_space_to_toggle == 1
        if has("gui_running")
             map <C-Space> <C-Bslash>
            imap <C-Space> <C-Bslash>
        elseif has("win32unix")
             map <C-@> <C-Bslash>
            imap <C-@> <C-Bslash>
        endif
    endif
endfunction

" -----------------------------------
function! s:vimim_onekey_mapping_on()
" -----------------------------------
    if !hasmapto('<Plug>VimimOneKey', 'i')
        inoremap <unique> <expr> <Plug>VimimOneKey <SID>OneKey()
    endif
    " -------------------------------
    if s:vimim_tab_as_onekey < 2 && !hasmapto('<C-^>', 'i')
        imap <silent> <C-^> <Plug>VimimOneKey
    endif
    if s:vimim_tab_as_onekey > 0
        imap <silent> <Tab> <Plug>VimimOneKey
    endif
    " -------------------------------
    if s:vimim_tab_as_onekey == 2
        xnoremap <silent> <Tab> y:call <SID>vimim_visual_ctrl_6(@0)<CR>
    elseif !hasmapto('<C-^>', 'v')
        xnoremap <silent> <C-^> y:call <SID>vimim_visual_ctrl_6(@0)<CR>
    endif
    " -------------------------------
    if s:vimim_search_next > 0
        noremap <silent> n :call g:vimim_search_next()<CR>n
    endif
endfunction

" ------------------------------------
function! s:vimim_initialize_autocmd()
" ------------------------------------
" [egg] promote any dot vimim file to be our first-class citizen
    if has("autocmd")
        augroup vimim_auto_chinese_mode
            autocmd BufNewFile *.vimim startinsert
            autocmd BufEnter   *.vimim sil!call <SID>ChineseMode()
        augroup END
    endif
endfunction

sil!call s:vimim_initialize_global()
sil!call s:vimim_initialize_debug()
sil!call s:vimim_initialize_mapping()
sil!call s:vimim_initialize_autocmd()
" ======================================= }}}
