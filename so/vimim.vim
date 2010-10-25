" ==================================================
"              " VimIM —— Vim 中文輸入法 "
" --------------------------------------------------
"  VimIM -- Input Method by Vim, of Vim, for Vimmers
" ==================================================
let $VimIM = "$Date: 2010-02-04 13:42:45 -0800 (Thu, 04 Feb 2010) $"
let $VimIM = "$Revision: 2803 $"

let egg  = ["http://code.google.com/p/vimim/issues/entry           "]
let egg += ["http://vimim-data.googlecode.com                      "]
let egg += ["http://vimim.googlecode.com/svn/vimim/vimim.html      "]
let egg += ["http://vimim.googlecode.com/svn/vimim/vimim.vim.html  "]
let egg += ["http://vimim.googlecode.com/svn/trunk/plugin/vimim.vim"]
let egg += ["http://vim.sf.net/scripts/script.php?script_id=2506   "]
let egg += ["http://pim-cloud.appspot.com                          "]
let egg += ["http://groups.google.com/group/vimim                  "]

let VimIM = " ====  Introduction     ==== {{{"
" ===========================================
"       File: vimim.vim
"     Author: vimim <vimim@googlegroups.com>
"    License: GNU Lesser General Public License
" -----------------------------------------------------------
"    Readme: VimIM is a Vim plugin designed as an independent IM
"            (Input Method) to support the input of multi-byte.
"            VimIM aims to complete the Vim as the greatest editor.
" -----------------------------------------------------------
"  Features: * "Plug & Play"
"            * "Plug & Play": "Cloud Input at will" for all
"            * "Plug & Play": "Cloud Input" with five Shuangpin
"            * "Plug & Play": "Cloud" from Sogou or from MyCloud
"            * "Plug & Play": "Wubi and Pinyin" dynamic switch
"            * "Plug & Play": "Pinyin and 4Corner" in harmony
"            * Support direct "UNICODE input" using integer or hex
"            * Support direct "GBK input" and "Big5 input"
"            * Support "Pin Yin", "Wu Bi", "Cang Jie", "4Corner", etc
"            * Support "modeless" whole sentence input
"            * Support "Chinese search" using search key '/' or '?'.
"            * Support "fuzzy search" and "wildcard search"
"            * Support popup menu navigation using "vi key" (hjkl)
"            * Support "non-stop-typing" for Wubi, 4Corner & Telegraph
"            * Support "Do It Yourself" input method defined by users
"            * The "OneKey" can input Chinese without mode change.
"            * The "static"  Chinese Input Mode smooths mixture input.
"            * The "dynamic" Chinese Input Mode uses sexy input style.
"            * It is independent of the Operating System.
"            * It is independent of Vim mbyte-XIM/mbyte-IME API.
" -----------------------------------------------------------
"   Install: (1) [optional] download a datafile from code.google.com
"            (2) drop vimim.vim and the datafile to the plugin directory
" -----------------------------------------------------------
" EasterEgg: (in Vim Insert Mode, type 4 chars:) vim<C-6>
" -----------------------------------------------------------
" Usage (1): [in Insert Mode] "to insert/search Chinese ad hoc":
"            # to insert: type keycode and hit <C-6> to trigger
"            # to search: hit '/' or '?' from popup menu
" -----------------------------------------------------------
" Usage (2): [in Insert Mode] "to type Chinese continuously":
"            # hit <C-Bslash> to toggle to Chinese Input Mode:
"            # type any valid keycode and enjoy
" -----------------------------------------------------------

let s:vimims = [VimIM]
" ======================================= }}}
let VimIM = " ====  Instruction      ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------
" "Design Goal"
" -------------
" # Chinese can be input using Vim regardless of encoding
" # Chinese can be input using Vim without local datafile
" # Without negative impact to Vim when VimIM is not used
" # No compromise for high speed and low memory usage
" # Making the best use of Vim for popular input methods
" # Most VimIM options are activated based on input methods
" # All  VimIM options can be explicitly disabled at will

" ---------------
" "VimIM Options"
" ---------------
" Comprehensive usages of all options can be found from vimim.html.

"   VimIM "OneKey", without mode change
"    - use OneKey to insert multi-byte candidates
"    - use OneKey to search multi-byte using "/" or "?"
"   The default key is <C-6> (Vim Insert Mode)

"   VimIM "Chinese Input Mode"
"   - [dynamic_mode] show omni popup menu as one types
"   - [static_mode]  <Space>=>Chinese  <Enter>=>English
"   The default key is <Ctrl-Bslash> (Vim Insert Mode)

" ----------------
" "VimIM Datafile"
" ----------------
" The datafile is assumed to be in order, otherwise, it is auto sorted.
" The format of datafile is simple and flexible:
"             +------+--+-------+
"             |<key> |  |<value>|
"             |======|==|=======|
"             | mali |  |  馬力 |
"             +------+--+-------+

" ======================================= }}}
let VimIM = " ====  Initialization   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)
if exists("b:loaded_vimim") || &cp || v:version<700
    finish
endif
let b:loaded_vimim=1
let s:vimimhelp = egg
let s:path=expand("<sfile>:p:h")."/"
scriptencoding utf-8

" -------------------------------------
function! s:vimim_initialization_once()
" -------------------------------------
    if empty(s:initialization_loaded)
        let s:initialization_loaded=1
    else
        return
    endif
    " -----------------------------------------
    call s:vimim_initialize_i_setting()
    call s:vimim_initialize_session()
    call s:vimim_initialize_encoding()
    call s:vimim_dictionary_chinese()
    call s:vimim_dictionary_im()
    call s:vimim_initialize_datafile_in_vimrc()
    " -----------------------------------------
    call s:vimim_scan_plugin_to_invoke_im()
    call s:vimim_scan_plugin_for_more_im()
    " -----------------------------------------
    call s:vimim_initialize_erbi()
    call s:vimim_initialize_pinyin()
    call s:vimim_initialize_shuangpin()
    " -----------------------------------------
    call s:vimim_initialize_cloud()
    call s:vimim_initialize_mycloud_plugin()
    " -----------------------------------------
    call s:vimim_initialize_keycode()
    call s:vimim_initialize_punctuation()
    call s:vimim_initialize_quantifiers()
    call s:vimim_finalize_session()
    " -----------------------------------------
endfunction

" ------------------------------------
function! s:vimim_initialize_session()
" ------------------------------------
    sil!call s:vimim_start_omni()
    sil!call s:vimim_super_reset()
    " --------------------------------
    let s:vimim_cloud_plugin = 0
    let s:smart_single_quotes = 1
    let s:smart_double_quotes = 1
    " --------------------------------
    let s:chinese_frequency = 0
    let s:toggle_xiangma_pinyin = 0
    let s:xingma_sleep_with_pinyin = 0
    " --------------------------------
    let s:only_4corner_or_12345 = 0
    let s:pinyin_and_4corner = 0
    let s:four_corner_lines = []
    " --------------------------------
    let s:im_primary = 0
    let s:im_secondary = 0
    " --------------------------------
    let s:datafile_has_dot = 0
    let s:sentence_with_space_input = 0
    let s:start_row_before = 0
    let s:start_column_before = 1
    let s:www_executable = 0
    " --------------------------------
    let s:im = {}
    let s:inputs = {}
    let s:inputs_all = {}
    let s:ecdict = {}
    let s:shuangpin_table = {}
    let s:debugs = []
    let s:lines = []
    let s:lines_primary = []
    let s:lines_secondary = []
    let s:seamless_positions = []
    " --------------------------------
    let s:current_positions = [0,0,1,0]
    let s:alphabet_lines = []
    let s:datafile = 0
    let s:debug_count = 0
    let s:keyboard_count = 0
    let s:chinese_mode_count = 1
    let s:abcdefghi = "'abcdefghi"
    let s:show_me_not_pattern = "^ii\\|^oo"
    " --------------------------------
endfunction

" ----------------------------------
function! s:vimim_finalize_session()
" ----------------------------------
    let s:chinese_frequency = s:vimim_chinese_frequency
    " ------------------------------
    if s:pinyin_and_4corner == 1
    \&& s:chinese_frequency > 1
        let s:chinese_frequency = 1
    endif
    " ------------------------------
    if empty(s:vimim_cloud_sogou)
        let s:vimim_cloud_sogou = 888
    elseif s:vimim_cloud_sogou == 1
        let s:chinese_frequency = -1
    endif
    " ----------------------------------------
    if empty(s:datafile)
        let s:datafile = copy(s:datafile_primary)
    endif
    " --------------------------------
    if s:datafile_primary =~# "chinese"
        let s:vimim_datafile_is_not_utf8 = 1
    endif
    " ------------------------------
    if s:datafile_primary =~# "quote"
    \|| s:datafile_secondary =~# "quote"
        let s:vimim_datafile_has_apostrophe = 1
    endif
    " ------------------------------
    if s:shuangpin_flag > 0
        let s:im_primary = 'pinyin'
        let s:im['pinyin'][0] = 1
    endif
    " ------------------------------
    if s:im_primary =~# '^\d\w\+'
    \&& empty(get(s:im['pinyin'],0))
        let s:only_4corner_or_12345 = 1
        let s:vimim_fuzzy_search = 0
        let s:vimim_static_input_style = 2
    endif
    " ------------------------------
    if empty(get(s:im['wubi'],0))
        let s:vimim_wubi_non_stop = 0
    endif
    " ------------------------------
    if s:vimimdebug > 0
        call s:debugs('im_1st', s:im_primary)
        call s:debugs('im_2nd', s:im_secondary)
        call s:debugs('datafile_1st', s:datafile_primary)
        call s:debugs('datafile_2nd', s:datafile_secondary)
        call s:debugs('xingma_pinyin', s:xingma_sleep_with_pinyin)
        call s:debugs('pinyin_4corner', s:pinyin_and_4corner)
    endif
    " ------------------------------
endfunction

" ------------------------------------
function! s:vimim_get_chinese(english)
" ------------------------------------
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
    let s:chinese = {}
    let s:chinese['vim1'] = ['文本编辑器','文本編輯器']
    let s:chinese['vim2'] = ['最牛']
    let s:chinese['vim3'] = ['精力']
    let s:chinese['vim4'] = ['生气','生氣']
    let s:chinese['vim5'] = ['中文输入法','中文輸入法']
    let s:chinese['cloud'] = ['云输入','雲輸入']
    let s:chinese['mycloud'] = ['自己的云','自己的雲']
    let s:chinese['wubi'] = ['五笔','五筆']
    let s:chinese['4corner'] = ['四角号码','四角號碼']
    let s:chinese['12345'] = ['五笔划','五筆劃']
    let s:chinese['ctc'] = ['中文电码','中文電碼']
    let s:chinese['cns11643'] = ['交换码','交換碼']
    let s:chinese['english'] = ['英文']
    let s:chinese['hangul'] = ['韩文','韓文']
    let s:chinese['xinhua'] = ['新华','新華']
    let s:chinese['pinyin'] = ['拼音']
    let s:chinese['cangjie'] = ['仓颉','倉頡']
    let s:chinese['zhengma'] = ['郑码','鄭碼']
    let s:chinese['yong'] = ['永码','永碼']
    let s:chinese['nature'] = ['自然']
    let s:chinese['quick'] = ['速成']
    let s:chinese['yong'] = ['永码','永碼']
    let s:chinese['wu'] = ['吴语','吳語']
    let s:chinese['array30'] = ['行列']
    let s:chinese['phonetic'] = ['注音']
    let s:chinese['erbi'] = ['二笔','二筆']
    let s:chinese['input'] = ['输入','輸入']
    let s:chinese['ciku'] = ['词库','詞庫']
    let s:chinese['myversion'] = ['版本','版本']
    let s:chinese['encoding'] = ['编码','編碼']
    let s:chinese['computer'] = ['电脑','電腦']
    let s:chinese['classic'] = ['经典','經典']
    let s:chinese['static'] = ['静态','靜態']
    let s:chinese['dynamic'] = ['动态','動態']
    let s:chinese['internal'] = ['内码','內碼']
    let s:chinese['onekey'] = ['点石成金','點石成金']
    let s:chinese['style'] = ['风格','風格']
    let s:chinese['scheme'] = ['方案','方案']
    let s:chinese['sogou'] = ['搜狗']
    let s:chinese['cloud_no'] = ['晴天无云','晴天無雲']
    let s:chinese['all'] = ['全']
    let s:chinese['cloud_atwill'] = ['想云想云','想雲就雲']
    let s:chinese['shezhi'] = ['设置','設置']
    let s:chinese['test'] = ['测试','測試']
    let s:chinese['jidian'] = ['极点','極點']
    let s:chinese['shuangpin'] = ['双拼','雙拼']
    let s:chinese['abc'] = ['智能双打','智能雙打']
    let s:chinese['microsoft'] = ['微软','微軟']
    let s:chinese['nature'] = ['自然']
    let s:chinese['plusplus'] = ['拼音加加']
    let s:chinese['purple'] = ['紫光']
    let s:chinese['bracket_l'] = ['《','【']
    let s:chinese['bracket_r'] = ['》','】']
endfunction

" -------------------------------
function! s:vimim_dictionary_im()
" -------------------------------
    let key_keycode = []
    call add(key_keycode, ['cloud', "[0-9a-z'.]"])
    call add(key_keycode, ['mycloud', "[0-9a-z'.]"])
    call add(key_keycode, ['wubi', "[0-9a-z'.]"])
    call add(key_keycode, ['4corner', "[0-9a-z'.]"])
    call add(key_keycode, ['12345', "[0-9a-z'.]"])
    call add(key_keycode, ['ctc', "[0-9a-z'.]"])
    call add(key_keycode, ['cns11643', "[0-9a-z'.]"])
    call add(key_keycode, ['english', "[0-9a-z'.]"])
    call add(key_keycode, ['hangul', "[0-9a-z'.]"])
    call add(key_keycode, ['xinhua', "[0-9a-z'.]"])
    call add(key_keycode, ['pinyin', "[0-9a-z'.]"])
    call add(key_keycode, ['cangjie', "[a-z'.]"])
    call add(key_keycode, ['zhengma', "[a-z'.]"])
    call add(key_keycode, ['yong', "[a-z'.;/]"])
    call add(key_keycode, ['nature', "[a-z'.]"])
    call add(key_keycode, ['quick', "[0-9a-z'.]"])
    call add(key_keycode, ['wu', "[a-z'.]"])
    call add(key_keycode, ['array30', "[a-z.,;/]"])
    call add(key_keycode, ['phonetic', "[0-9a-z.,;/]"])
    call add(key_keycode, ['erbi', "[a-z'.,;/]"])
    " ------------------------------------
    let loaded = 0
    for pairs in key_keycode
        let key = get(pairs, 0)
        let keycode = get(pairs, 1)
        let im = s:vimim_get_chinese(key)
        let s:im[key]=[loaded, im, keycode]
    endfor
    " ------------------------------------
endfunction

" -----------------------------------------
function! s:vimim_add_im_if_empty(ims, key)
" -----------------------------------------
    let input_methods = a:ims
    let key = a:key
    if empty(get(s:im[key],0))
        call add(input_methods, key)
    endif
endfunction

" ------------------------------------------
function! s:vimim_scan_plugin_to_invoke_im()
" ------------------------------------------
    if s:vimimdebug > 0
    \|| s:pinyin_and_4corner > 1
        return 0
    endif
    " ----------------------------------------
    if len(s:datafile_primary) > 1
    \&& len(s:datafile_secondary) > 1
        return 0
    endif
    " ----------------------------------------
    let input_methods = []
    " ----------------------------------------
    call s:vimim_add_im_if_empty(input_methods, 'cangjie')
    call s:vimim_add_im_if_empty(input_methods, 'zhengma')
    call s:vimim_add_im_if_empty(input_methods, 'quick')
    call s:vimim_add_im_if_empty(input_methods, 'array30')
    call s:vimim_add_im_if_empty(input_methods, 'xinhua')
    call s:vimim_add_im_if_empty(input_methods, 'erbi')
    " ----------------------------------------
    if empty(get(s:im['wubi'],0))
        call add(input_methods, "wubi")
        call add(input_methods, "wubi98")
        call add(input_methods, "wubijd")
    endif
    " ----------------------------------------
    if empty(get(s:im['4corner'],0))
        call add(input_methods, "4corner")
        call add(input_methods, "12345")
    endif
    " ----------------------------------------
    if empty(get(s:im['pinyin'],0))
        call add(input_methods, "pinyin")
        call add(input_methods, "pinyin_quote_sogou")
        call add(input_methods, "pinyin_huge")
        call add(input_methods, "pinyin_fcitx")
        call add(input_methods, "pinyin_canton")
        call add(input_methods, "pinyin_hongkong")
    endif
    " ----------------------------------------
    call add(input_methods, "phonetic")
    call add(input_methods, "wu")
    call add(input_methods, "yong")
    call add(input_methods, "nature")
    call add(input_methods, "hangul")
    call add(input_methods, "cns11643")
    call add(input_methods, "ctc")
    call add(input_methods, "english")
    " ----------------------------------------
    for im in input_methods
        let file = "vimim." . im . ".txt"
        let datafile = s:path . file
        if filereadable(datafile)
            break
        else
            continue
        endif
    endfor
    " ----------------------------------------
    if filereadable(datafile)
        let msg = "plugin datafile was found"
    else
        return 0
    endif
    " ----------------------------------------
    let msg = " [setter] for im-loaded-flag "
    if im =~# '^wubi'
        let im = 'wubi'
    elseif im =~# '^pinyin'
        let im = 'pinyin'
    elseif im =~# '^\d'
        let im = '4corner'
    endif
    let s:im[im][0] = 1
    " ----------------------------------------
    if empty(s:datafile_primary)
        let s:datafile_primary = datafile
        let s:im_primary = im
    elseif empty(s:datafile_secondary)
        let s:datafile_secondary = datafile
        let s:im_secondary = im
    endif
    " ----------------------------------------
    return im
endfunction

" -----------------------------------------
function! s:vimim_scan_plugin_for_more_im()
" -----------------------------------------
    if empty(s:datafile_primary)
        return
    endif
    " -------------------------------------
    if s:vimimdebug < 9
        let msg = "always scan the 2nd plugin ciku"
    elseif get(s:im['4corner'],0) > 0
        let msg = "pinyin and 4corner are in harmony"
    else
        return
    endif
    " -------------------------------------
    let im = 0
    if get(s:im['4corner'],0) > 0
    \|| get(s:im['cangjie'],0) > 0
    \|| get(s:im['erbi'],0) > 0
    \|| get(s:im['wubi'],0) > 0
    \|| get(s:im['quick'],0) > 0
    \|| get(s:im['array30'],0) > 0
    \|| get(s:im['xinhua'],0) > 0
    \|| get(s:im['zhengma'],0) > 0
        let msg = "plug and play <=> xingma and pinyin"
        let im = s:vimim_scan_plugin_to_invoke_im()
    endif
    " -------------------------------------
    if empty(im) || s:pinyin_and_4corner > 1
        let msg = "only play with one plugin datafile"
    elseif get(s:im['4corner'],0) > 0
        let s:pinyin_and_4corner = 1
    else
        let s:xingma_sleep_with_pinyin = 1
    endif
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
    let keycode = s:vimim_get_keycode()
    if empty(keycode)
        let keycode = "[0-9a-z'.]"
    endif
    " --------------------------------
    if s:shuangpin_flag > 0
        let keycode = s:im['shuangpin'][2]
    endif
    " --------------------------------
    let s:valid_key = copy(keycode)
    let keycode = s:vimim_expand_character_class(keycode)
    let s:valid_keys = split(keycode, '\zs')
    " --------------------------------
    if get(s:im['erbi'],0) > 0
    \|| get(s:im['wu'],0) > 0
    \|| get(s:im['yong'],0) > 0
    \|| get(s:im['nature'],0) > 0
    \|| get(s:im['array30'],0) > 0
    \|| get(s:im['phonetic'],0) > 0
        let msg = "need to find a better way to handle real valid keycode"
        let s:datafile_has_dot = 1
    endif
    " --------------------------------
endfunction

" -----------------------------
function! s:vimim_get_keycode()
" -----------------------------
    if empty(s:im_primary)
        return 0
    endif
    let keycode = get(s:im[s:im_primary],2)
    if s:vimim_wildcard_search > 0
    \&& empty(get(s:im['wubi'],0))
    \&& len(keycode) > 1
        let wildcard = '[*]'
        let key_valid = strpart(keycode, 1, len(keycode)-2)
        let key_wildcard = strpart(wildcard, 1, len(wildcard)-2)
        let keycode = '[' . key_valid . key_wildcard . ']'
    endif
    return keycode
endfunction

" ======================================= }}}
let VimIM = " ====  Customization    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_initialize_global()
" -----------------------------------
    let s:global_defaults = []
    let s:global_customized = []
    " -------------------------------
    let G = []
    call add(G, "g:vimim_ctrl_space_to_toggle")
    call add(G, "g:vimim_custom_skin")
    call add(G, "g:vimim_datafile")
    call add(G, "g:vimim_datafile_digital")
    call add(G, "g:vimim_datafile_has_4corner")
    call add(G, "g:vimim_datafile_has_apostrophe")
    call add(G, "g:vimim_datafile_has_english")
    call add(G, "g:vimim_datafile_has_pinyin")
    call add(G, "g:vimim_datafile_is_not_utf8")
    call add(G, "g:vimim_english_punctuation")
    call add(G, "g:vimim_frequency_first_fix")
    call add(G, "g:vimim_fuzzy_search")
    call add(G, "g:vimim_imode_universal")
    call add(G, "g:vimim_imode_pinyin")
    call add(G, "g:vimim_insert_without_popup")
    call add(G, "g:vimim_latex_suite")
    call add(G, "g:vimim_reverse_pageup_pagedown")
    call add(G, "g:vimim_sexy_input_style")
    call add(G, "g:vimim_shuangpin_abc")
    call add(G, "g:vimim_shuangpin_microsoft")
    call add(G, "g:vimim_shuangpin_nature")
    call add(G, "g:vimim_shuangpin_plusplus")
    call add(G, "g:vimim_shuangpin_purple")
    call add(G, "g:vimim_static_input_style")
    call add(G, "g:vimim_tab_as_onekey")
    call add(G, "g:vimim_unicode_lookup")
    call add(G, "g:vimim_wildcard_search")
    call add(G, "g:vimim_wget_dll")
    call add(G, "g:vimim_mycloud_url")
    call add(G, "g:vimim_cloud_sogou")
    call add(G, "g:vimimdebug")
    " -----------------------------------
    call s:vimim_set_global_default(G, 0)
    " -----------------------------------
    let G = []
    call add(G, "g:vimim_auto_copy_clipboard")
    call add(G, "g:vimim_chinese_frequency")
    call add(G, "g:vimim_chinese_punctuation")
    call add(G, "g:vimim_custom_laststatus")
    call add(G, "g:vimim_custom_menu_label")
    call add(G, "g:vimim_internal_code_input")
    call add(G, "g:vimim_onekey_double_ctrl6")
    call add(G, "g:vimim_punctuation_navigation")
    call add(G, "g:vimim_wubi_non_stop")
    " -----------------------------------
    call s:vimim_set_global_default(G, 1)
    " -----------------------------------
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

" ======================================= }}}
let VimIM = " ====  Easter_Egg       ==== {{{"
" ===========================================
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
    call add(eggs, "統計　vimimstat")
    call add(eggs, "內碼　vimimunicode")
    call add(eggs, "設置　vimimdefaults")
    return map(eggs,  '"VimIM 彩蛋：" . v:val . "　"')
endfunction

" -------------------------
function! s:vimim_egg_vim()
" -------------------------
    let vim1 = s:vimim_get_chinese('vim1')
    let vim2 = s:vimim_get_chinese('vim2') . vim1
    let vim3 = s:vimim_get_chinese('vim3')
    let vim4 = s:vimim_get_chinese('vim4')
    let vim5 = s:vimim_get_chinese('vim5')
    " ------------------------------------
    let eggs  = ["vi　  " . vim1 ]
    let eggs += ["vim   " . vim2 ]
    let eggs += ["vim   " . vim3 ]
    let eggs += ["vim   " . vim4 ]
    let eggs += ["vimim " . vim5 ]
    return eggs
endfunction

" -------------------------------
function! s:vimim_egg_vimimstat()
" -------------------------------
    let eggs = []
    let stone = get(g:vimim,1)
    let gold = get(g:vimim,2)
    " ------------------------
    let stat = "总计输入：". gold ." 个汉字"
    call add(eggs, stat)
    " ------------------------
    if gold > 0
        let stat = "平均码长：". string(stone*1.0/gold)
        call add(eggs, stat)
    endif
    " ------------------------
    let duration = get(g:vimim,3)
    let rate = gold*60/duration
    let stat = "打字速度：". string(rate) ." 汉字/分钟"
    call add(eggs, stat)
    " ------------------------
    let egg = '"stat  " . v:val . "　"'
    call map(eggs, egg)
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
    let egg = '"VimIM  " . v:val . "　"'
    return map(eggs, egg)
endfunction

" -------------------------------
function! s:vimim_egg_vimimhelp()
" -------------------------------
    let eggs = []
    " -------------------------------------------
    call add(eggs, "错误报告：" . s:vimimhelp[0])
    call add(eggs, "民间词库：" . s:vimimhelp[1])
    call add(eggs, "最新主页：" . s:vimimhelp[2])
    call add(eggs, "最新程式：" . s:vimimhelp[3])
    call add(eggs, "试用版本：" . s:vimimhelp[4])
    call add(eggs, "官方网址：" . s:vimimhelp[5])
    call add(eggs, "自己的云：" . s:vimimhelp[6])
    call add(eggs, "新闻论坛：" . s:vimimhelp[7])
    " -------------------------------------------
    return map(eggs, '"VimIM " .v:val . "　"')
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
    let input = s:vimim_get_chinese('input') . "："
    let ciku = s:vimim_get_chinese('ciku')
    let ciku = "datafile " . ciku .  "："
    let myversion = s:vimim_get_chinese('myversion')
    let myversion = "\t " . myversion . "："
    let encoding = s:vimim_get_chinese('encoding') . "："
" ----------------------------------
    let option .= "_" . &term
    let computer = s:vimim_get_chinese('computer')
    let option = "computer " . computer . "：" . option
    call add(eggs, option)
" ----------------------------------
    let option = v:progname . "　"
    let option = "Vim" . myversion  . option . v:version
    call add(eggs, option)
" ----------------------------------
    let option = get(split($VimIM), 1)
    if empty(option)
        let msg = "not a SVN check out, revision number not available"
    else
        let option = "VimIM" . myversion . "vimim.vim　" . option
        call add(eggs, option)
    endif
" ----------------------------------
    let option = "encoding " . encoding . &encoding
    call add(eggs, option)
" ----------------------------------
    let option = "fencs\t "  . encoding . &fencs
    call add(eggs, option)
" ----------------------------------
    let option = "lc_time\t " . encoding . v:lc_time
    call add(eggs, option)
" ----------------------------------
    let option = s:vimim_static_input_style
    let classic = s:vimim_get_chinese('classic')
    let dynamic = s:vimim_get_chinese('dynamic')
    let static = s:vimim_get_chinese('static')
    let toggle = "i_CTRL-Bslash"
    if option < 1
        let classic .= dynamic
    elseif option == 1
        let classic .= static
    elseif option == 2
        let classic = "Sexy" . static
    endif
    let toggle .= "　"
    let style = s:vimim_get_chinese('style')
    let option = "mode\t " . style . "：" . toggle . classic
    call add(eggs, option)
" ----------------------------------
    let im = s:vimim_statusline()
    if !empty(im)
        let option = "im\t " . input . im
        call add(eggs, option)
    endif
" ----------------------------------
    let option = s:shuangpin_flag
    if empty(option)
        let msg = "no shuangpin is used"
    else
        let scheme = s:vimim_get_chinese('scheme')
        let option = "scheme\t " . scheme . '：' . get(s:im['shuangpin'],1)
        call add(eggs, option)
    endif
" ----------------------------------
    let option = s:datafile_primary
    if empty(option)
        let msg = "no primary datafile, might play cloud"
    else
        let option = ciku . option
        call add(eggs, option)
    endif
" ----------------------------------
    let option = s:datafile_secondary
    if empty(option)
        let msg = "no secondary pinyin to sleep with"
    else
        let option = ciku . s:datafile_secondary
        call add(eggs, option)
    endif
" ----------------------------------
    let cloud = s:vimim_cloud_sogou
    let sogou = s:vimim_get_chinese('sogou')
    let option = "cloud\t " . sogou ."："
    let CLOUD = "start_to_use_cloud_after_" .  cloud . "_characters"
    if cloud == -777
        let CLOUD = s:vimim_get_chinese('mycloud')
    elseif cloud < 0
        let CLOUD = s:vimim_get_chinese('cloud_no')
    elseif cloud == 888
        let CLOUD = s:vimim_get_chinese('cloud_atwill')
    elseif cloud == 1
        let CLOUD = s:vimim_get_chinese('all')
        let CLOUD .= s:vimim_get_chinese('cloud')
    endif
    let option .= CLOUD
    call add(eggs, option)
" ----------------------------------
    if empty(s:global_customized)
        let msg = "no global variable is set"
    else
        for item in s:global_customized
            let shezhi = s:vimim_get_chinese('shezhi')
            let option = "VimIM\t " . shezhi . "：" . item
            call add(eggs, option)
        endfor
    endif
" ----------------------------------
    let option = s:vimimdebug
    if option > 0
        let option = "g:vimimdebug=" . option
        let test = s:vimim_get_chinese('test')
        let option = "debug\t " . test . "：" . option
        call add(eggs, option)
    endif
" ----------------------------------
    return map(eggs, 'v:val . "　"')
endfunction

" ----------------------------------------
function! s:vimim_easter_chicken(keyboard)
" ----------------------------------------
    if empty(s:chinese_input_mode)
    \|| s:chinese_input_mode =~ 'sexy'
        let msg = "easter eggs hidden in OneKey only"
    else
        return
    endif
    " ------------------------------------
    let egg = a:keyboard
    if egg =~# s:valid_key
        let msg = "hunt easter egg ... vim<C-6>"
    else
        return []
    endif
    " ------------------------------------
    try
        return eval("<SID>vimim_egg_".egg."()")
    catch
        if s:vimimdebug > 0
            call s:debugs('egg::exception=', v:exception)
        endif
        return []
    endtry
endfunction

" ======================================= }}}
let VimIM = " ====  Encoding_Unicode ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------------------------
function! s:vimim_initialize_encoding()
" -------------------------------------
    call s:vimim_set_encoding()
    let s:localization = s:vimim_localization()
    let s:multibyte = 2
    let s:max_ddddd = 64928
    if &encoding == "utf-8"
        let s:multibyte = 3
        let s:max_ddddd = 40869
    endif
    if s:localization > 0
        let warning = 'performance hit if &encoding & datafile differs!'
    endif
endfunction

" ------------------------------
function! s:vimim_set_encoding()
" ------------------------------
    let s:encoding = "utf8"
    if  &encoding == "chinese"
    \|| &encoding == "cp936"
    \|| &encoding == "gb2312"
    \|| &encoding == "gbk"
    \|| &encoding == "euc-cn"
        let s:encoding = "chinese"
    elseif  &encoding == "taiwan"
    \|| &encoding == "cp950"
    \|| &encoding == "big5"
    \|| &encoding == "euc-tw"
        let s:encoding = "taiwan"
    endif
endfunction

" ------------------------------
function! s:vimim_localization()
" ------------------------------
    let localization = 0
    let datafile_fenc_chinese = 0
    if empty(s:vimim_datafile_is_not_utf8)
        let msg = 'current datafile is chinese encoding'
    else
        let datafile_fenc_chinese = 1
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
            let localization = 1
        endif
    elseif empty(datafile_fenc_chinese)
        let localization = 2
    endif
    return localization
endfunction

" -------------------------------------
function! s:vimim_i18n_read_list(lines)
" -------------------------------------
    if empty(a:lines)
        return []
    endif
    let results = []
    if empty(s:localization)
        return a:lines
    else
        for line in a:lines
            let line = s:vimim_i18n_read(line)
            call add(results, line)
        endfor
    endif
    return results
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

" --------------------------------
function! s:vimim_i18n_iconv(line)
" --------------------------------
    let line = a:line
    if s:localization == 1
        let line = iconv(line, "utf-8", &enc)
    elseif s:localization == 2
        let line = iconv(line, &enc, "utf-8")
    endif
    return line
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
    return ''
endfunction

" ----------------------------------
function! s:vimim_egg_vimimunicode()
" ----------------------------------
    if s:encoding != "utf8"
        return []
    endif
    let msg = "Unicode 中文部首起始碼位表【康熙字典】"
    let unicode  = "一丨丶丿乙亅二亠人儿入八冂冖冫几凵刀力勹匕匚匸十"
    let unicode .= "卜卩厂厶又口囗土士夂夊夕大女子宀寸小尢尸屮山巛工"
    let unicode .= "己巾干幺广廴廾弋弓彐彡彳心戈戶手支攴文斗斤方无日"
    let unicode .= "曰月木欠止歹殳毋比毛氏气水火爪父爻爿片牙牛犬玄玉"
    let unicode .= "瓜瓦甘生用田疋疒癶白皮皿目矛矢石示禸禾穴立竹米糸"
    let unicode .= "缶网羊羽老而耒耳聿肉臣自至臼舌舛舟艮色艸虍虫血行"
    let unicode .= "衣襾見角言谷豆豕豸貝赤走足身車辛辰辵邑酉釆里金長"
    let unicode .= "門阜隶隹雨靑非面革韋韭音頁風飛食首香馬骨高髟鬥鬯"
    let unicode .= "鬲鬼魚鳥鹵鹿麥麻黃黍黑黹黽鼎鼓鼠鼻齊齒龍龜龠"
    let unicodes = split(unicode, '\zs')
    let eggs = []
    for char in unicodes
        let ddddd = char2nr(char)
        let xxxx = s:vimim_decimal2hex(ddddd)
        let display = "U+" .  xxxx . " " . char
        call add(eggs, display)
    endfor
    return eggs
endfunction

" ======================================= }}}
let VimIM = " ====  Encoding_GBK     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------
function! GBK()
" -------------
" This function outputs GBK as:
" ----------------------------- gb=6763
"   decimal  hex    GBK
"   49901    c2ed    馬
" ----------------------------- gbk=883+21003=21886
    if  s:encoding ==# "chinese"
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
    return ''
endfunction

" ---------------------------------------
function! s:vimim_internal_code(keyboard)
" ---------------------------------------
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
    \|| strlen(keyboard) != 5
        return []
    else
        let msg = " support <C-6> to trigger multibyte "
    endif
    let numbers = []
    " -------------------------
    if keyboard =~# '^u\x\{4}$'
    " -------------------------
        let msg = "do hex internal-code popup menu, eg, u808f"
        let pumheight = 16*16*2
        let xxxx = keyboard[1:]
        let ddddd = str2nr(xxxx, 16)
        if ddddd > 0xffff
            return []
        else
            let numbers = []
            for i in range(pumheight)
                let digit = str2nr(ddddd+i)
                call add(numbers, digit)
            endfor
        endif
    " ----------------------------
    elseif keyboard =~# '^\d\{5}$'
    " ----------------------------
        let last_char = keyboard[-1:-1]
        if last_char ==# '0'
            let msg = " do decimal internal-code popup menu, eg, 22220"
            let dddd = keyboard[:-2]
            for i in range(10)
                let digit = str2nr(dddd.i)
                call add(numbers, digit)
            endfor
        else
            let msg = "do direct decimal internal-code insert, eg, 22221"
            let ddddd = str2nr(keyboard, 10)
            let numbers = [ddddd]
        endif
    endif
    return s:vimim_internal_codes(numbers)
endfunction

" ---------------------------------------
function! s:vimim_internal_codes(numbers)
" ---------------------------------------
    if empty(a:numbers)
        return []
    endif
    let internal_codes = []
    for digit in a:numbers
        let hex = printf('%04x', digit)
        let menu = '　' . hex .'　'. digit
        let internal_code = menu.' '.nr2char(digit)
        call add(internal_codes, internal_code)
    endfor
    return internal_codes
endfunction

" ------------------------------------------
function! s:vimim_without_datafile(keyboard)
" ------------------------------------------
    let keyboard = a:keyboard
    if  keyboard =~ '\l' && len(keyboard) == 1
        let msg = "make abcdefghijklmnopqrst alive"
    else
        return []
    endif
    let numbers = []
    let gbk = {}
    let a = char2nr('a')
    let z = char2nr('z')
    let az_list = range(a, z)
    " ---------------------------------------
    let start = 19968
    if  s:encoding ==# "chinese"
        let start = 0xb0a1
        let az  = " b0a1 b0c5 b2c1 b4ee b6ea b7a2 b8c1 baa1 bbf7 "
        let az .= " bbf7 bfa6 c0ac c2e8 c4c3 c5b6 c5be c6da c8bb "
        let az .= " c8f6 cbfa cdda cdda cdda cef4 d1b9 d4d1"
        let gb_code_orders = split(az)
        for xxxx in az_list
            let gbk[nr2char(xxxx)] = "0x" . get(gb_code_orders, xxxx-a)
        endfor
    elseif  s:encoding ==# "taiwan"
        let start = 42048
    endif
    " ----------------------------------------------------------
    " [purpose] to input Chinese without datafile nor internet
    "  (1) every abcdefghijklmnopqrstuvwxy shows different menu
    "  (2) every char displays 16*16*3=768 glyph in omni menu
    "  (3) the total number of glyphs is 16*16*3*26=19968
    " ----------------------------------------------------------
    let label = char2nr(keyboard) - a
    let block = 16*16*3
    let start += label*block
    if  s:encoding ==# "chinese" && has_key(gbk, keyboard)
        let start = gbk[keyboard]
    endif
    let end = start + block
    for i in range(start, end)
        call add(numbers, str2nr(i,10))
    endfor
    " ------------------------------------
    return s:vimim_internal_codes(numbers)
    " ------------------------------------
endfunction

" ======================================= }}}
let VimIM = " ====  Encoding_BIG5    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------
function! BIG5()
" --------------
" This function outputs BIG5 as:
" -----------------------------
"   decimal  hex    BIG5
"   45224    b0a8    馬
" ----------------------------- big5=408+5401+7652=13461
    if  s:encoding ==# "taiwan"
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
    return ''
endfunction

" ======================================= }}}
let VimIM = " ====  OneKey           ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------
function! s:vimim_start_onekey()
" ------------------------------
    sil!call s:vimim_start()
    sil!call s:vimim_1234567890_filter_on()
    sil!call s:vimim_navigation_label_on()
    sil!call s:vimim_action_label_on()
    sil!call s:vimim_punctuation_navigation_on()
    sil!call s:vimim_helper_mapping_on()
    sil!call s:vimim_sexy_autocmd()
    " ----------------------------------------------------------
    " default <OneKey> triple play
    "   (1) after English (valid keys)   => trigger omni popup
    "   (2) after omni popup window      => <Space> or nothing
    "   (3) after Chinese (invalid keys) => <Tab> or nothing
    " ----------------------------------------------------------
    inoremap <Space> <C-R>=<SID>vimim_space_onekey()<CR>
                    \<C-R>=g:vimim_reset_after_insert()<CR>
    " ----------------------------------------------------------
endfunction

" ------------------------------
function! s:vimim_sexy_autocmd()
" ------------------------------
    if s:vimim_static_input_style==2 && has("autocmd")
        augroup onekey_mode_autocmd
            autocmd!
            if hasmapto('<Space>', 'i')
                sil!autocmd InsertLeave * sil!call s:vimim_stop()
            endif
        augroup END
    endif
endfunction

" --------------------------------
function! s:vimim_stop_sexy_mode()
" --------------------------------
    if s:chinese_input_mode =~ 'sexy'
        set ruler
        let s:chinese_mode_switch = 1
        if s:vimim_auto_copy_clipboard>0 && has("gui_running")
            let @+ = getline(".")
        endif
    endif
endfunction

" -----------------------
function! <SID>Sexymode()
" -----------------------
" sexy <OneKey> double play
"  (1) <OneKey> => start sexy OneKey mode and start to play
"  (2) <OneKey> => stop  sexy OneKey mode and stop to play
" ----------------------------------------------------------
    if pumvisible()
        let msg = "<C-\> does nothing over omni menu"
    else
        let s:chinese_mode_switch += 1
        if empty(s:chinese_mode_switch%2)
            sil!call s:vimim_start_onekey()
            set noruler
            let s:chinese_input_mode = 'sexy'
            sil!return s:vimim_onekey_action("")
        else
            call s:vimim_stop()
        endif
    endif
    return ""
endfunction

" ---------------------
function! <SID>Onekey()
" ---------------------
    let onekey = ""
    sil!call s:vimim_start_onekey()
    let onekey = s:vimim_onekey_action("")
    if pumvisible() && s:vimim_onekey_double_ctrl6
        let onekey  = "\<C-E>\<C-X>\<C-U>\<C-E>"
        let onekey .= "\<C-R>=g:vimim_pumvisible_p_paste()\<CR>"
    endif
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" ---------------------------------
function! <SID>vimim_space_onekey()
" ---------------------------------
    let onekey = " "
    sil!return s:vimim_onekey_action(onekey)
endfunction

" -------------------------------------
function! s:vimim_onekey_action(onekey)
" -------------------------------------
    let onekey = ''
    " -----------------------------------------------
    " <Space> multiple play in OneKey Mode:
    "   (1) after English (valid keys) => trigger keycode menu
    "   (2) after omni popup menu      => insert Chinese
    "   (3) after English punctuation  => Chinese punctuation
    "   (4) after Chinese              => trigger unicode menu
    " -----------------------------------------------
    if pumvisible()
        if s:pattern_not_found > 0
            let s:pattern_not_found = 0
            let onekey = " "
        elseif a:onekey == " " || s:vimim_static_input_style < 2
            let onekey = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        else
            let onekey = "\<C-E>"
        endif
        sil!exe 'sil!return "' . onekey . '"'
    endif
    if s:insert_without_popup > 0
        let s:insert_without_popup = 0
        let onekey = ""
    endif
    " ---------------------------------------------------
    let byte_before = getline(".")[col(".")-2]
    let char_before_before = getline(".")[col(".")-3]
    " ---------------------------------------------------
    if char_before_before !~# "[0-9a-z]"
    \&& has_key(s:punctuations, byte_before)
        let onekey = ""
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
            let replacement = s:punctuations[byte_before]
            if s:vimim_static_input_style == 2
                let msg = " play sexy quote in sexy mode "
                if byte_before ==# "'"
                    let replacement = <SID>vimim_get_single_quote()
                elseif byte_before ==# '"'
                    let replacement = <SID>vimim_get_double_quote()
                endif
            endif
            let onekey = "\<BS>" . replacement
            sil!exe 'sil!return "' . onekey . '"'
        endif
    endif
    " -------------------------------------------------
    let trigger = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
    " -------------------------------------------------
    let onekey = a:onekey
    if empty(s:chinese_input_mode)
    \&& !empty(byte_before)
    \&& byte_before !~# s:valid_key
        if empty(a:onekey)
            let xxxx = s:vimim_get_char_before_internal_code()
            if empty(xxxx)
                let msg = "char-before is not multibyte"
            else
                let onekey = xxxx . trigger
                sil!exe 'sil!return "' . onekey . '"'
            endif
        endif
    endif
    " ---------------------------------------------------
    if byte_before ==# "'"
        let s:pattern_not_found = 0
    endif
    " ---------------------------------------------------
    if s:seamless_positions != getpos(".")
    \&& s:pattern_not_found < 1
        let onekey = trigger
    else
        let onekey = ""
    endif
    " ---------------------------------------------------
    if !empty(byte_before)
    \&& byte_before !~# s:valid_key
        let onekey = a:onekey
    endif
    " ---------------------------------------------------
    let s:smart_enter = 0
    let s:pattern_not_found = 0
    sil!exe 'sil!return "' . onekey . '"'
endfunction

" -----------------------------------------------
function! s:vimim_get_char_before_internal_code()
" -----------------------------------------------
     let xxxx = 0
     let byte_before = getline(".")[col(".")-2]
     if empty(byte_before) || byte_before =~# s:valid_key
         return 0
     endif
     let msg = "[unicode] OneKey to trigger Chinese with omni menu"
     let start = s:multibyte + 1
     let char_before = getline(".")[col(".")-start : col(".")-2]
     let ddddd = char2nr(char_before)
     if ddddd > 127
         let xxxx = s:vimim_decimal2hex(ddddd)
         let xxxx = 'u' . xxxx
     endif
     return xxxx
endfunction

" ------------------------------------
function! s:vimim_decimal2hex(decimal)
" ------------------------------------
    let n = a:decimal
    let hex = ""
    while n
        let hex = '0123456789abcdef'[n%16].hex
        let n = n/16
    endwhile
    return hex
endfunction

" ======================================= }}}
let VimIM = " ====  Chinese_Mode     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------------------------------
" s:chinese_input_mode=0         => (default) OneKey: hit-and-run
" s:chinese_input_mode='dynamic' => (default) classic dynamic mode
" s:chinese_input_mode='static'  => let g:vimim_static_input_style = 1
" s:chinese_input_mode='sexy'    => let g:vimim_static_input_style = 2
" -------------------------------------------

" --------------------------
function! <SID>Chinesemode()
" --------------------------
    let space = ""
    let s:chinese_mode_switch += 1
    if s:chinese_mode_switch > 2
        call s:vimim_stop_chinese_mode()
        let space = "\<C-O>:redraw\<CR>"
    endif
    if empty(s:chinese_mode_switch%2)
        call s:vimim_start_chinese_mode()
        if s:vimim_static_input_style > 0
            if pumvisible()
                let msg = "<C-\> does nothing over omni menu"
            else
                let space = s:vimim_static_action("")
            endif
        endif
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ------------------------------------
function! s:vimim_start_chinese_mode()
" ------------------------------------
    sil!call s:vimim_start()
    sil!call s:vimim_i_chinese_mode_on()
    sil!call s:vimim_i_chinese_mode_autocmd_on()
    " ------------------------------------------
    if s:vimim_static_input_style < 1
        let s:chinese_input_mode = 'dynamic'
        call <SID>vimim_set_seamless()
        call s:vimim_dynamic_alphabet_trigger()
        " ---------------------------------------------------
        inoremap <Space> <C-R>=<SID>vimim_space_dynamic()<CR>
                      \<C-R>=g:vimim_reset_after_insert()<CR>
        " ---------------------------------------------------
    elseif s:vimim_static_input_style == 1
        let s:chinese_input_mode = 'static'
        sil!call s:vimim_static_alphabet_auto_select()
        " ------------------------------------------------------
        inoremap  <Space> <C-R>=<SID>vimim_space_static()<CR>
                         \<C-R>=g:vimim_reset_after_insert()<CR>
        " ------------------------------------------------------
    endif
    " ----------------------------------
    sil!call s:vimim_helper_mapping_on()
    " ---------------------------------------------------
    inoremap <expr> <C-^> <SID>vimim_toggle_punctuation()
    " ---------------------------------------------------
    return <SID>vimim_toggle_punctuation()
endfunction

" -----------------------------------
function! s:vimim_stop_chinese_mode()
" -----------------------------------
    if s:vimim_auto_copy_clipboard>0 && has("gui_running")
        sil!exe ':%y +'
    endif
    " ------------------------------
    if exists('*Fixcp')
        sil!call FixAcp()
    endif
    " ------------------------------
    sil!call s:vimim_stop()
endfunction

" ----------------------------------
function! <SID>vimim_space_dynamic()
" ----------------------------------
    let space = ' '
    if pumvisible()
        let space = "\<C-Y>"
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ---------------------------------
function! <SID>vimim_space_static()
" ---------------------------------
    let space = " "
    sil!return s:vimim_static_action(space)
endfunction

" ------------------------------------
function! s:vimim_static_action(space)
" ------------------------------------
    let space = a:space
    if pumvisible()
        let space = s:vimim_ctrl_y_ctrl_x_ctrl_u()
    else
        let byte_before = getline(".")[col(".")-2]
        if byte_before =~# s:valid_key
            if s:pattern_not_found < 1
                let space = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
            else
                let s:pattern_not_found = 0
            endif
        endif
    endif
    sil!exe 'sil!return "' . space . '"'
endfunction

" ---------------------------------------------
function! s:vimim_static_alphabet_auto_select()
" ---------------------------------------------
    if s:chinese_input_mode !~ 'static'
        return
    endif
    " always do alphabet auto selection for static mode
    let A = char2nr('A')
    let Z = char2nr('Z')
    let a = char2nr('a')
    let z = char2nr('z')
    let az_nr_list = extend(range(A,Z), range(a,z))
    let az_char_list = map(az_nr_list,"nr2char(".'v:val'.")")
    " -----------------------------------------
    for _ in az_char_list
        sil!exe 'inoremap <silent> ' ._. '
        \ <C-R>=pumvisible()?"\<lt>C-Y>":""<CR>'. _
        \ . '<C-R>=g:reset_after_auto_insert()<CR>'
    endfor
endfunction

" ------------------------------------------
function! s:vimim_dynamic_alphabet_trigger()
" ------------------------------------------
    if s:chinese_input_mode !~ 'dynamic'
        return
    endif
    let not_used_valid_keys = "[0-9.']"
    if s:datafile_has_dot > 0
        let not_used_valid_keys = "[0-9]"
    endif
    " --------------------------------------
    for char in s:valid_keys
        if char !~# not_used_valid_keys
            sil!exe 'inoremap <silent>  ' . char . '
            \ <C-R>=g:vimim_pumvisible_ctrl_e()<CR>'. char .
            \'<C-R>=g:vimim_ctrl_x_ctrl_u()<CR>'
        endif
    endfor
endfunction

" ======================================= }}}
let VimIM = " ====  Seamless         ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

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
    let snips = split(snip, '\zs')
    for char in snips
        if char !~# s:valid_key
            return -1
        endif
    endfor
    let s:start_row_before = seamless_lnum
    let s:smart_enter = 0
    return seamless_column
endfunction

" ---------------------------------
function! <SID>vimim_set_seamless()
" ---------------------------------
    let s:seamless_positions = getpos(".")
    let s:keyboard_leading_zero = 0
    return ""
endfunction

" ======================================= }}}
let VimIM = " ====  Punctuations     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_initialize_punctuation()
" ----------------------------------------
    let s:punctuations = {}
    let s:punctuations['#']='＃'
    let s:punctuations['&']='＆'
    let s:punctuations['%']='％'
    let s:punctuations['$']='￥'
    let s:punctuations['!']='！'
    let s:punctuations['~']='～'
    let s:punctuations['+']='＋'
    let s:punctuations['@']='・'
    let s:punctuations[':']='：'
    let s:punctuations['(']='（'
    let s:punctuations[')']='）'
    let s:punctuations['{']='〖'
    let s:punctuations['}']='〗'
    let s:punctuations['[']='【'
    let s:punctuations[']']='】'
    let s:punctuations['^']='……'
    let s:punctuations['_']='——'
    let s:punctuations['<']='《'
    let s:punctuations['>']='》'
    let s:punctuations['-']='－'
    let s:punctuations['=']='＝'
    let s:punctuations[';']='；'
    let s:punctuations[',']='，'
    let s:punctuations['.']='。'
    let s:punctuations['?']='？'
    let s:punctuations['`']='、'
    if empty(s:vimim_wildcard_search)
        let s:punctuations['*']='﹡'
    endif
    if empty(s:vimim_latex_suite)
        let s:punctuations['\']='、'
        let s:punctuations["'"]='‘’'
        let s:punctuations['"']='“”'
    endif
    let s:punctuations_all = copy(s:punctuations)
    for char in s:valid_keys
        if has_key(s:punctuations, char)
            " ----------------------------------
            if !empty(s:vimim_cloud_plugin)
            \|| s:datafile_has_dot > 0
                unlet s:punctuations[char]
            elseif char !~# "[*.']"
                unlet s:punctuations[char]
            endif
            " ----------------------------------
        endif
    endfor
endfunction

" ---------------------------------------
function! <SID>vimim_toggle_punctuation()
" ---------------------------------------
    if s:vimim_chinese_punctuation > -1
        let s:chinese_punctuation = (s:chinese_punctuation+1)%2
        sil!call s:vimim_punctuation_on()
    endif
    return ''
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

" -----------------------------------
function! <SID>vimim_punctuation_on()
" -----------------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \|| s:chinese_input_mode =~ 'static'
        unlet s:punctuations['\']
        unlet s:punctuations['"']
        unlet s:punctuations["'"]
    endif
    " ----------------------------
    if s:chinese_punctuation>0 && s:vimim_latex_suite>1
        if get(s:im['erbi'],0)>0 || get(s:im['pinyin'],0)>0
            let msg = " apostrophe is over-loaded for cloud at will "
        else
            inoremap ' <C-R>=<SID>vimim_get_single_quote()<CR>
        endif
        if index(s:valid_keys, '"') < 0
            inoremap " <C-R>=<SID>vimim_get_double_quote()<CR>
        endif
        if index(s:valid_keys, '\') < 0
            inoremap <Bslash> 、
        endif
    else
        iunmap '
        iunmap "
        iunmap <Bslash>
    endif
    " ----------------------------
    for _ in keys(s:punctuations)
        sil!exe 'inoremap <silent> '._.'
        \    <C-R>=<SID>vimim_punctuation_mapping("'._.'")<CR>'
        \ . '<C-R>=g:reset_after_auto_insert()<CR>'
    endfor
    " --------------------------------------
    call s:vimim_punctuation_navigation_on()
    " --------------------------------------
endfunction

" -------------------------------------------
function! <SID>vimim_punctuation_mapping(key)
" -------------------------------------------
    let value = s:vimim_get_chinese_punctuation(a:key)
    if pumvisible()
        let value = "\<C-Y>" . value
    endif
    sil!exe 'sil!return "' . value . '"'
endfunction

" -------------------------------------------
function! s:vimim_punctuation_navigation_on()
" -------------------------------------------
    let default = "=-[]"
    let semicolon = ";"
    let period = "."
    let comma = ","
    let slash = "/"
    let question_mark = "?"
    " ---------------------------------------
    let punctuation = default . semicolon . period . comma . slash
    if s:vimim_punctuation_navigation < 1
        let punctuation = default . semicolon
    endif
    if s:chinese_input_mode =~ 'static'
        let punctuation = default
    endif
    " ---------------------------------------
    let hjkl_list = split(punctuation,'\zs')
    if empty(s:chinese_input_mode)
        call add(hjkl_list, question_mark)
    endif
    " ---------------------------------------
    let msg = "we should never map valid keycode"
    for char in s:valid_keys
	let i = index(hjkl_list, char)
	if i > -1 && char != period
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
        if a:key == ";"
            let hjkl  = '\<Down>\<C-Y>'
            let hjkl .= '\<C-R>=g:vimim_reset_after_insert()\<CR>'
        elseif a:key == "["
            let hjkl  = '\<C-R>=g:vimim_left_bracket()\<CR>'
        elseif a:key == "]"
            let hjkl  = '\<C-R>=g:vimim_right_bracket()\<CR>'
        elseif a:key == "/"
            let hjkl  = '\<C-R>=g:vimim_search_forward()\<CR>'
        elseif a:key == "?"
            let hjkl  = '\<C-R>=g:vimim_search_backward()\<CR>'
        elseif a:key =~ "[-,=.]"
            if a:key == ',' || a:key == '-'
                if s:vimim_reverse_pageup_pagedown > 0
                    let s:pageup_pagedown += 1
                else
                    let s:pageup_pagedown -= 1
                endif
            elseif a:key == '.' || a:key == '='
                if s:vimim_reverse_pageup_pagedown > 0
                    let s:pageup_pagedown -= 1
                else
                    let s:pageup_pagedown += 1
                endif
            endif
            let hjkl = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        endif
    else
        if s:chinese_input_mode =~ 'dynamic'
        \|| s:chinese_input_mode =~ 'static'
            let hjkl = s:vimim_get_chinese_punctuation(hjkl)
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" --------------------------------------
function! s:vimim_ctrl_e_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-E>\<C-X>\<C-U>\<C-P>\<Down>'
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

" ======================================= }}}
let VimIM = " ====  Chinese_Number   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_initialize_quantifiers()
" ----------------------------------------
    let s:quantifiers = {}
    if s:vimim_imode_universal < 1
    \&& s:vimim_imode_pinyin < 1
        return
    endif
    let s:quantifiers['1'] = '一壹㈠①⒈⑴甲'
    let s:quantifiers['2'] = '二贰㈡②⒉⑵乙'
    let s:quantifiers['3'] = '三叁㈢③⒊⑶丙'
    let s:quantifiers['4'] = '四肆㈣④⒋⑷丁'
    let s:quantifiers['5'] = '五伍㈤⑤⒌⑸戊'
    let s:quantifiers['6'] = '六陆㈥⑥⒍⑹己'
    let s:quantifiers['7'] = '七柒㈦⑦⒎⑺庚'
    let s:quantifiers['8'] = '八捌㈧⑧⒏⑻辛'
    let s:quantifiers['9'] = '九玖㈨⑨⒐⑼壬'
    let s:quantifiers['0'] = '〇零㈩⑩⒑⑽癸十拾'
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
    let s:quantifiers['t'] = '吨条头通堂台套桶筒贴趟'
    let s:quantifiers['u'] = '微'
    let s:quantifiers['w'] = '万位味碗窝'
    let s:quantifiers['x'] = '升席些项'
    let s:quantifiers['y'] = '月亿叶'
    let s:quantifiers['z'] = '兆只张株支枝指盏座阵桩尊则种站幢宗'
endfunction

" ----------------------------------------------
function! s:vimim_imode_number(keyboard, prefix)
" ----------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
        return []
    endif
    let keyboard = a:keyboard
    " ------------------------------------------
    if a:prefix ==# "'"
        let keyboard = substitute(keyboard,"'",'i','g')
    endif
    " ------------------------------------------
    if strpart(keyboard,0,2) ==# 'ii'
        let keyboard = 'I' . strpart(keyboard,2)
    endif
    let ii_keyboard = keyboard
    let keyboard = strpart(keyboard,1)
    " ------------------------------------------
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
    let chinese_number = ''
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

" ======================================= }}}
let VimIM = " ====  English2Chinese  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

let s:translators = {}
" ------------------------------------------
function! s:translators.translate(line) dict
" ------------------------------------------
    return join(map(split(a:line),'get(self.dict,tolower(v:val),v:val)'))
endfunction

" -----------------------------------
function! s:vimim_translator(english)
" -----------------------------------
    if a:english !~ '\p'
        return ''
    endif
    if empty(s:ecdict)
        call s:vimim_initialize_e2c()
        if empty(s:ecdict)
            return ''
        endif
    endif
    let english = substitute(a:english, '\A', ' & ', 'g')
    let chinese = substitute(english, '.', '&\n', 'g')
    let chinese = s:ecdict.translate(english)
    let chinese = substitute(chinese, "[ ']", '', 'g')
    let chinese = substitute(chinese, '\a\+', ' & ', 'g')
    return chinese
endfunction

" --------------------------------
function! s:vimim_initialize_e2c()
" --------------------------------
    if empty(s:vimim_datafile_has_english)
    \|| len(s:ecdict) > 1
        return ''
    endif
    let lines = s:vimim_reload_datafile(0)
    if empty(lines)
        return ''
    endif
    " --------------------------------------------------
    " VimIM rule for entry of English Chinese dictionary
    " obama 奧巴馬 歐巴馬 #
    " --------------------------------------------------
    let english_pattern = " #$"
    let matched_english_lines = match(lines, english_pattern)
    if matched_english_lines < 0
        return ''
    endif
    let dictionary_lines = filter(copy(lines),'v:val=~english_pattern')
    if empty(dictionary_lines)
        return ''
    endif
    let s:ecdict = copy(s:translators)
    let s:ecdict.dict = {}
    for line in dictionary_lines
        if empty(line)
            continue
        endif
        let line = s:vimim_i18n_read(line)
        let words = split(line)
        if len(words) < 2
            continue
        endif
        let s:ecdict.dict[words[0]] = words[1]
    endfor
endfunction

" ======================================= }}}
let VimIM = " ====  Chinese2Pinyin   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------------
function! s:vimim_reverse_lookup(chinese)
" ---------------------------------------
    let chinese = substitute(a:chinese,'\s\+\|\w\|\n','','g')
    let chinese_characters = split(chinese,'\zs')
    let glyph = join(chinese_characters, '   ')
    let items = []
    " ------------------------------------------------
    let results_unicode = []
    if s:vimim_unicode_lookup > 0
        for char in chinese_characters
            let unicode = printf('%04x',char2nr(char))
            call add(items, unicode)
        endfor
        call add(results_unicode, join(items, ' '))
        call add(results_unicode, glyph)
    endif
    " ------------------------------------------------
    let results_4corner = []
    if get(s:im['4corner'],0) > 0
        let cache_4corner = s:vimim_build_reverse_4corner_cache(chinese)
        let items = s:vimim_make_one_entry(cache_4corner, chinese)
        call add(results_4corner, join(items,' '))
        call add(results_4corner, glyph)
    endif
    " ------------------------------------------------
    let cache_pinyin = s:vimim_build_reverse_pinyin_cache(chinese, 0)
    let items = s:vimim_make_one_entry(cache_pinyin, chinese)
    let result_pinyin = join(items,'')." ".chinese
    " ------------------------------------------------
    let results = []
    if len(results_unicode) > 0
        call extend(results, results_unicode)
    endif
    if len(results_4corner) > 0
        call extend(results, results_4corner)
    endif
    if result_pinyin =~ '\a'
        call add(results, result_pinyin)
    endif
    return results
endfunction

" ------------------------------------------------------------
function! s:vimim_build_reverse_pinyin_cache(chinese, one2one)
" ------------------------------------------------------------
    call s:vimim_reload_datafile(0)
    if empty(s:lines)
        return {}
    endif
    if empty(s:alphabet_lines)
        let first_line_index = 0
        let index = match(s:lines, '^a')
        if index > -1
            let first_line_index = index
        endif
        let last_line_index = len(s:lines) - 1
        let s:alphabet_lines = s:lines[first_line_index : last_line_index]
        if get(s:im['pinyin'],0) > 0 |" one to many relationship
            let pinyin_with_tone = '^\a\+\d\s\+'
            call filter(s:alphabet_lines, 'v:val =~ pinyin_with_tone')
        endif
    endif
    if empty(s:alphabet_lines)
        return {}
    endif
    " ----------------------------------------
    let alphabet_lines = []
    if &encoding == "utf-8"
        let alphabet_lines = copy(s:alphabet_lines)
    else
        for line in s:alphabet_lines
            if line !~ '^v\d\s\+'
                let line = s:vimim_i18n_read(line)
            endif
            call add(alphabet_lines, line)
        endfor
    endif
    " ----------------------------------------
    let characters = split(a:chinese,'\zs')
    let character = join(characters,'\|')
    call filter(alphabet_lines, 'v:val =~ character')
    " ----------------------------------------
    let cache = {}
    for line in alphabet_lines
        if empty(line)
            continue
        endif
        let words = split(line)
        if len(words) < 2
            continue
        endif
        let menu = remove(words, 0)
        if get(s:im['pinyin'],0) > 0
            let menu = substitute(menu,'\d','','g')
        endif
        for char in words
            if match(characters, char) < 0
                continue
            endif
            if has_key(cache,char) && menu!=cache[char]
                if empty(a:one2one)
                    let cache[char] = menu .'|'. cache[char]
                endif
            else
                let cache[char] = menu
            endif
        endfor
    endfor
    return cache
endfunction

" ----------------------------------------------
function! s:vimim_make_one_entry(cache, chinese)
" ----------------------------------------------
    if empty(a:chinese) || empty(a:cache)
        return []
    endif
    let characters = split(a:chinese, '\zs')
    let items = []
    for char in characters
        if has_key(a:cache, char)
            let menu = a:cache[char]
            call add(items, menu)
        endif
    endfor
    return items
endfunction

" ======================================= }}}
let VimIM = " ====  Omni_Popup_Menu  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------------
function! s:vimim_pair_list(matched_list)
" ---------------------------------------
    let s:matched_list = copy(a:matched_list)
    let matched_list = a:matched_list
    if empty(matched_list)
        return []
    endif
    " -----------------------------------
    let pair_matched_list = []
    let maximum_list = 288
    if len(matched_list) > maximum_list
        let matched_list = matched_list[0 : maximum_list]
    endif
    " ----------------------
    for line in matched_list
    " ----------------------
        if len(line) < 2
            continue
        endif
        if s:localization > 0
            let line = s:vimim_i18n_read(line)
        endif
        let oneline_list = split(line, '\s\+')
        let menu = remove(oneline_list, 0)
        for chinese in oneline_list
            call add(pair_matched_list, menu .' '. chinese)
        endfor
    endfor
    return pair_matched_list
endfunction

" -------------------------------------------------
function! s:vimim_menu_4corner_filter(matched_list)
" -------------------------------------------------
    if s:menu_4corner_filter > -1
        let msg = "make 4corner as a filter to omni menu"
    else
        return a:matched_list
    endif
    let keyboard = get(split(get(a:matched_list,0)),0)
    let keyboard = strpart(keyboard, match(keyboard,'\l'))
    let keyboards = [keyboard, s:menu_4corner_filter, "", ""]
    let results = s:vimim_diy_results(keyboards, a:matched_list)
    if empty(results)
        let results = a:matched_list
    endif
    return results
endfunction

" ---------------------------------------------
function! s:vimim_pageup_pagedown(matched_list)
" ---------------------------------------------
    let matched_list = a:matched_list
    let length = len(matched_list)
    if length > &pumheight
        let page = s:pageup_pagedown * &pumheight
        if page < 0
            let msg = "no more PageUp after the first page"
            let s:pageup_pagedown += 1
            let first_page = &pumheight-1
            let matched_list = matched_list[0 : first_page]
        elseif page >= length
            let msg = "no more PageDown after the last page"
            let s:pageup_pagedown -= 1
            let last_page = len(matched_list) / &pumheight
            if empty((len(matched_list) % &pumheight))
                let last_page -= 1
            endif
            let last_page = last_page * &pumheight
            let matched_list = matched_list[last_page : -1]
        else
            let matched_list = matched_list[page :]
        endif
    endif
    return matched_list
endfunction

" --------------------------------------------
function! s:vimim_popupmenu_list(matched_list)
" --------------------------------------------
    let matched_list = a:matched_list
    if empty(matched_list)
        return []
    endif
    let s:popupmenu_matched_list = copy(matched_list)
    let first_pair = split(get(matched_list,0))
    let first_stone = get(first_pair, 0)
    " ----------------------------------------
    if s:chinese_input_mode=~ 'sexy'
        let msg = " smart <C-N> and <C-P> "
        let key = first_stone[:0]
        let s:inputs[key] = matched_list
        let s:inputs_all[first_stone] = matched_list
    endif
    " ----------------------------------------
    if empty(s:vimim_cloud_plugin)
        let matched_list = s:vimim_menu_4corner_filter(matched_list)
    endif
    if s:pageup_pagedown > 0
        let matched_list = s:vimim_pageup_pagedown(matched_list)
    endif
    " ----------------------------------------
    let popupmenu_list = s:vimim_build_popupmenu(matched_list)
    " ----------------------------------------
    return popupmenu_list
endfunction

" ---------------------------------------------
function! s:vimim_build_popupmenu(matched_list)
" ---------------------------------------------
    let matched_list = a:matched_list
    let menu = 0
    let label = 1
    let popupmenu_list = []
    let keyboard = s:keyboard_leading_zero
    " ----------------------
    for pair in matched_list
    " ----------------------
        let complete_items = {}
        let pairs = split(pair)
        if len(pairs) < 2
            continue
        endif
        let menu = get(pairs, 0)
        if s:unicode_menu_display_flag > 0
            let complete_items["menu"] = menu
        endif
        let chinese = get(pairs, 1)
        if chinese =~ "#"
            continue
        endif
        " -------------------------------------------------
        if s:vimim_custom_skin < 2
            let extra_text = menu
            if s:pinyin_and_4corner > 1
            \&& empty(match(extra_text, '^\d\{4}$'))
                let unicode = printf('u%04x', char2nr(chinese))
                let extra_text = menu.'　'.unicode
            endif
            if extra_text =~ s:show_me_not_pattern
            \|| len(extra_text) < 2
                let extra_text = ''
            endif
            let complete_items["menu"] = extra_text
        endif
        " -------------------------------------------------
        if !empty(s:vimim_cloud_plugin)
            let menu = get(split(menu,"_"),0)
        endif
        " -------------------------------------------------
        if empty(s:vimim_cloud_plugin)
            let tail = ''
            if keyboard =~ '[.]' && s:datafile_has_dot < 1
                let dot = match(keyboard, '[.]')
                let tail = strpart(keyboard, dot+1)
            elseif keyboard !~? '^vim'
                let tail = strpart(keyboard, len(menu))
            endif
            if tail =~ '\w'
                let chinese .=  tail
            endif
        endif
        " -------------------------------------------------
        let labeling = label
        if s:vimim_custom_menu_label > 0
            if label == 10
                let labeling = 0
            endif
            if label < &pumheight+1
            \&& (empty(s:chinese_input_mode)
            \|| s:chinese_input_mode=~ 'sexy')
                " ----------------------------------------- todo
                let label2 = s:abcdefghi[label-1 : label-1]
                if label < 2
                    let label2 = "_"
                endif
                " -----------------------------------------
                if s:pinyin_and_4corner > 0 && empty(s:vimim_cloud_plugin)
                    let labeling = label2
                else
                    let labeling .= label2
                endif
                " -----------------------------------------
            endif
            let abbr = printf('%2s',labeling)."\t".chinese
            let complete_items["abbr"] = abbr
        endif
        " -------------------------------------------------
        let complete_items["word"] = chinese
        let complete_items["dup"] = 1
        let label += 1
        call add(popupmenu_list, complete_items)
        " -------------------------------------------------
    endfor
    return popupmenu_list
endfunction

" ======================================= }}}
let VimIM = " ====  Skin             ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------
function! s:vimim_initialize_skin()
" ---------------------------------
    highlight! link PmenuSel   Title
    highlight! link StatusLine Title
    highlight!      Pmenu      NONE
    highlight!      PmenuSbar  NONE
    highlight!      PmenuThumb NONE
endfunction

" -----------------------------------
function! s:vimim_i_chinese_mode_on()
" -----------------------------------
    if s:vimim_custom_laststatus > 0
        set laststatus=2
    endif
    let s:chinese_mode_count += 1
    let s:toggle_xiangma_pinyin = s:chinese_mode_count%2
    let b:keymap_name = s:vimim_statusline()
endfunction

" -------------------------------------------
function! s:vimim_i_chinese_mode_autocmd_on()
" -------------------------------------------
    if has("autocmd") && empty(&statusline)
        augroup chinese_mode_autocmd
            autocmd!
            autocmd BufEnter * let &statusline=s:vimim_statusline()
            autocmd BufLeave * let &statusline=s:saved_statusline
        augroup END
    endif
endfunction

" --------------------------------------
function! s:vimim_i_cursor_color(switch)
" --------------------------------------
    if empty(a:switch)
        highlight! Cursor guifg=bg guibg=fg
    else
        highlight! Cursor guifg=bg guibg=Green
    endif
endfunction

" ----------------
function! IMName()
" ----------------
" This function is for user-defined 'stl' 'statusline'
    call s:vimim_initialization_once()
    if empty(s:chinese_input_mode)
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
    let im = ''
    let bracket_l = s:vimim_get_chinese('bracket_l')
    let bracket_r = s:vimim_get_chinese('bracket_r')
    let plus = '＋'
    let plus = bracket_r . plus . bracket_l
    " ------------------------------------
    let key  = s:im_primary
    if has_key(s:im, key)
        let im = get(s:im[key],1)
    endif
    " ------------------------------------
    if key =~# 'wubi'
        if s:datafile_primary =~# 'wubi98'
            let im .= '98'
        elseif s:datafile_primary =~# 'wubijd'
            let jidian = s:vimim_get_chinese('jidian')
            let im = jidian . im
        endif
    endif
    " ------------------------------------
    let pinyin = get(s:im['pinyin'],1)
    if s:shuangpin_flag > 0
        let pinyin = get(s:im['shuangpin'],0)
        let im = pinyin
    endif
    " ------------------------------------
    if s:pinyin_and_4corner > 0
        let im_digit = get(s:im['4corner'],1)
        if s:datafile_primary =~ '12345'
            let im_digit = get(s:im['12345'],1)
            let s:im['12345'][0] = 1
        endif
        let im = pinyin . plus . im_digit
    endif
    " ------------------------------------
    if s:xingma_sleep_with_pinyin > 0
        let im_1 = get(s:im[s:im_primary],1)
        let im_2 = get(s:im[s:im_secondary],1)
        if empty(s:toggle_xiangma_pinyin)
            let im = im_1 . plus . im_2
        else
            let im = im_2 . plus . im_1
        endif
    endif
    " ------------------------------------
    if !empty(s:vimim_cloud_plugin)
        let im = get(s:im['mycloud'],0)
    endif
    " ------------------------------------
    if empty(im)
        if s:vimim_cloud_sogou > 0
            if s:vimim_cloud_sogou == 1
                let all = s:vimim_get_chinese('all')
                let cloud = get(s:im['cloud'],1)
                let im = all . cloud
            endif
        else
            let im = s:vimim_get_chinese('internal')
            let im .= s:vimim_get_chinese('input')
        endif
    endif
    " ----------------------------------
    let im  = bracket_l . im . bracket_r
    " ----------------------------------
    return im
endfunction

" ======================================= }}}
let VimIM = " ====  User_Interface   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------
function! s:vimim_label_on()
" --------------------------
    if s:vimim_custom_menu_label < 1
        return
    endif
    " ----------------------
    let labels = range(10)
    if &pumheight > 0 && &pumheight != 10
        let labels = range(1, &pumheight)
    endif
    " ----------------------
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_label("'._.'")<CR>'
        \.'<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
endfunction

" ---------------------------
function! <SID>vimim_label(n)
" ---------------------------
    let label = a:n
    let n = a:n
    if a:n !~ '\d'
        let n = char2nr(n) - char2nr('a') + 2
    endif
    if pumvisible()
        if n < 1
            let n = 10
        endif
        let mycount = repeat("\<Down>", n-1)
        let yes = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        let label = mycount . yes
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" ---------------------------------
function! s:vimim_action_label_on()
" ---------------------------------
    let labels = split(s:abcdefghi, '\zs')
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_action_label("'._.'")<CR>'
        \.'<C-R>=g:vimim_reset_after_insert()<CR>'
    endfor
endfunction

" ----------------------------------
function! <SID>vimim_action_label(n)
" ----------------------------------
    let label = a:n
    if pumvisible()
        let n = match(s:abcdefghi, label)
        let mycount = repeat("\<Down>", n)
        let yes = s:vimim_ctrl_y_ctrl_x_ctrl_u()
        let label = mycount . yes
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" -------------------------------------
function! s:vimim_navigation_label_on()
" -------------------------------------
    let hjkl_list = split('qrsujklpxyz', '\zs')
    for _ in hjkl_list
        sil!exe 'inoremap <silent> <expr> '._.'
        \ <SID>vimim_hjkl("'._.'")'
    endfor
endfunction

" ----------------------------
function! <SID>vimim_hjkl(key)
" ----------------------------
    let hjkl = a:key
    if pumvisible()
        if a:key == 'x'
            let hjkl  = '\<C-E>'
        elseif a:key == 'u'
            let hjkl  = '\<PageUp>'
        elseif a:key == 'j'
            let hjkl  = '\<Down>'
        elseif a:key == 'k'
            let hjkl  = '\<Up>'
        elseif a:key == 'l'
            let hjkl  = '\<PageDown>'
        elseif a:key == 'y'
            let hjkl  = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
        elseif a:key == 'z'
            let hjkl = '\<C-E>\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
        elseif a:key == 'r'
            let s:pumvisible_reverse += 1
            let hjkl  = s:vimim_ctrl_e_ctrl_x_ctrl_u()
        elseif a:key == 's'
            let hjkl  = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_pumvisible_putclip()\<CR>'
        elseif a:key == 'p'
            let hjkl  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_pumvisible_p_paste()\<CR>'
        elseif a:key == 'q'
            let hjkl  = '\<C-R>=g:vimim_pumvisible_ctrl_e()\<CR>'
            let hjkl .= '\<C-R>=g:vimim_one_key_correction()\<CR>'
        endif
    endif
    sil!exe 'sil!return "' . hjkl . '"'
endfunction

" --------------------------------------
function! s:vimim_1234567890_filter_on()
" --------------------------------------
    if s:vimim_custom_menu_label < 1
    \|| empty(s:pinyin_and_4corner)
        return
    endif
    let labels = range(0,9)
    if get(s:im['12345'],0) > 0
        let labels = range(1,5)
    endif
    for _ in labels
        sil!exe'inoremap <silent>  '._.'
        \  <C-R>=<SID>vimim_label_1234567890_filter("'._.'")<CR>'
    endfor
endfunction

" ---------------------------------------------
function! <SID>vimim_label_1234567890_filter(n)
" ---------------------------------------------
    let label = a:n
    if pumvisible()
        let msg = "give 1234567890 label new meaning"
        let s:menu_4corner_filter = a:n
        let label = s:vimim_ctrl_e_ctrl_x_ctrl_u()
    endif
    sil!exe 'sil!return "' . label . '"'
endfunction

" ------------------------------------
function! g:vimim_one_key_correction()
" ------------------------------------
    let key = '\<Esc>'
    call s:reset_matched_list()
    " --------------------------------
    if empty(s:chinese_input_mode)
    \|| s:chinese_input_mode=~ 'sexy'
        call s:vimim_stop()
    else
        let byte_before = getline(".")[col(".")-2]
        if byte_before =~# s:valid_key
            let s:one_key_correction = 1
            let key = '\<C-X>\<C-U>\<BS>'
        endif
    endif
    " --------------------------------
    sil!exe 'sil!return "' . key . '"'
endfunction

" ------------------------------------
function! g:vimim_pumvisible_p_paste()
" ------------------------------------
    if empty(s:popupmenu_matched_list)
        return "\<Esc>"
    endif
    let pastes = []
    let title = s:keyboard_leading_zero . " =>"
    let words = [title]
    let msg = "resever ii/oo/vv for pretty print "
    if title =~ s:show_me_not_pattern
        let words = []
    endif
    for item in s:popupmenu_matched_list
        let pairs = split(item)
        let yin = get(pairs, 0)
        let yang = get(pairs, 1)
        if yang =~ "#"
            continue
        endif
        call add(words, item)
        if yin =~ s:show_me_not_pattern
            call add(pastes, yang)
        endif
    endfor
    if len(pastes) == len(words)
        let words = copy(pastes)
    endif
    let cursor_positions = getpos(".")
    let cursor_positions[2] = 1
    if s:vimimdebug < 9
        put=words
    else
        call setline(line("."), words)
    endif
    call setpos(".", cursor_positions)
    sil!call s:vimim_stop()
    if s:vimim_auto_copy_clipboard>0 && has("gui_running")
        let string_words = ''
        for line in words
            let string_words .= line
            let string_words .= "\n"
        endfor
        let @+ = string_words
    endif
    return "\<Esc>"
endfunction

" ----------------------------------
function! g:vimim_pumvisible_y_yes()
" ----------------------------------
    let key = ''
    if pumvisible()
        let key = s:vimim_ctrl_y_ctrl_x_ctrl_u()
    else
        let key = ' '
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ------------------------------------
function! g:vimim_pumvisible_putclip()
" ------------------------------------
    let chinese = s:vimim_popup_word()
    sil!call s:vimim_stop()
    if len(chinese) > 0
        if s:vimim_auto_copy_clipboard>0 && has("gui_running")
            let @+ = chinese
        endif
    endif
    return "\<Esc>"
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
    let word = strpart(current_line, column_start, range)
    return word
endfunction

" --------------------------------------
function! s:vimim_ctrl_y_ctrl_x_ctrl_u()
" --------------------------------------
    return '\<C-Y>\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
endfunction

" -------------------------------
function! g:vimim_ctrl_x_ctrl_u()
" -------------------------------
    let key = ''
    call s:reset_popupmenu_matched_list()
    let byte_before = getline(".")[col(".")-2]
    if byte_before =~# s:valid_key
        let key = '\<C-X>\<C-U>'
        if s:chinese_input_mode =~ 'dynamic'
            call g:reset_after_auto_insert()
        endif
        if empty(s:vimim_sexy_input_style)
            let key .= '\<C-R>=g:vimim_menu_select()\<CR>'
        endif
    else
        call g:reset_after_auto_insert()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" -----------------------------
function! g:vimim_menu_select()
" -----------------------------
    let select_not_insert = ''
    if pumvisible()
        let select_not_insert = '\<C-P>\<Down>'
        if s:vimim_insert_without_popup > 0
        \&& s:insert_without_popup > 0
            let s:insert_without_popup = 0
            let select_not_insert = '\<C-Y>'
        endif
    endif
    sil!exe 'sil!return "' . select_not_insert . '"'
endfunction

" --------------------------------
function! g:vimim_search_forward()
" --------------------------------
    return s:vimim_search("/")
endfunction

" ---------------------------------
function! g:vimim_search_backward()
" ---------------------------------
    return s:vimim_search("?")
endfunction

" ---------------------------
function! s:vimim_search(key)
" ---------------------------
    let slash = ""
    if pumvisible()
        let slash  = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
        let slash .= '\<C-R>=g:vimim_slash_search()\<CR>'
        let slash .= a:key . '\<CR>'
    endif
    sil!exe 'sil!return "' . slash . '"'
endfunction

" ------------------------------
function! g:vimim_slash_search()
" ------------------------------
    let msg = "search from popup menu"
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
        let yes = '\<C-R>=g:vimim_pumvisible_y_yes()\<CR>'
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
            let delete_char = "\<Right>\<BS>【".chinese."】\<Left>"
        endif
    endif
    return delete_char
endfunction

" --------------------------------
function! <SID>vimim_smart_enter()
" --------------------------------
    let key = ''
    let enter = "\<CR>"
    let byte_before = getline(".")[col(".")-2]
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
    "   (1) after English (valid keys)    => Seamless
    "   (2) after English punctuation     => <Space>
    "   (3) after Chinese or double Enter => <Enter>
    "   (4) after empty line              => <Enter> with invisible <Space>
    " -----------------------------------------------
    if empty(s:chinese_input_mode)
        if has_key(s:punctuations, byte_before)
            let s:smart_enter += 1
            let key = ' '
        endif
        if byte_before =~ '\s'
            let key = enter
        endif
    endif
    " -----------------------------------------------
    if s:smart_enter == 1
        let msg = "do seamless for the first time <Enter>"
        let s:pattern_not_found = 0
        let s:seamless_positions = getpos(".")
        let s:keyboard_leading_zero = 0
    else
        if s:smart_enter == 2
            let key = " "
        else
            let key = enter
        endif
        let s:smart_enter = 0
    endif
    " -----------------------------------------------
    if empty(s:chinese_input_mode)
        if empty(byte_before)
            let key = "　" . enter
        endif
    endif
    " -----------------------------------------------
    sil!exe 'sil!return "' . key . '"'
endfunction

" ---------------------------------
function! <SID>vimim_smart_ctrl_n()
" ---------------------------------
    let trigger = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
    let xxxx = s:vimim_get_char_before_internal_code()
    if empty(xxxx)
        let s:smart_ctrl_n += 1
    else
        let trigger = xxxx . trigger
    endif
    sil!exe 'sil!return "' . trigger . '"'
endfunction

" ----------------------------------------------------
function! s:vimim_get_list_from_smart_ctrl_n(keyboard)
" ----------------------------------------------------
    let keyboard = a:keyboard
    if s:smart_ctrl_n < 1
        return []
    endif
    let s:smart_ctrl_n = 0
    if keyboard =~# s:valid_key && len(keyboard) == 1
        let msg = 'try to find from previous valid inputs'
    else
        return []
    endif
    let matched_list = []
    if has_key(s:inputs, keyboard)
        let matched_list = s:inputs[keyboard]
    endif
    return matched_list
endfunction

" ---------------------------------
function! <SID>vimim_smart_ctrl_p()
" ---------------------------------
    let s:smart_ctrl_p += 1
    let key = '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
    sil!exe 'sil!return "' . key . '"'
endfunction

" ----------------------------------------------------
function! s:vimim_get_list_from_smart_ctrl_p(keyboard)
" ----------------------------------------------------
    let keyboard = a:keyboard
    if s:smart_ctrl_p < 1
        return []
    endif
    let s:smart_ctrl_p = 0
    if keyboard =~# s:valid_key
        let msg = 'try to find from all previous valid inputs'
    else
        return []
    endif
    let pattern = s:vimim_free_fuzzy_pattern(keyboard)
    let matched = match(keys(s:inputs_all), pattern)
    if matched < 0
        let msg = "nothing matched previous user input"
        return []
    else
        let keyboard = get(keys(s:inputs_all), matched)
        let matched_list = s:inputs_all[keyboard]
        return matched_list
    endif
endfunction

" -----------------------------------
function! g:vimim_pumvisible_ctrl_e()
" -----------------------------------
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        if s:vimim_wubi_non_stop > 0
        \&& empty(get(s:im['pinyin'],0))
        \&& empty(len(s:keyboard_wubi)%4)
            let key = "\<C-Y>"
        endif
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" --------------------------------------
function! g:vimim_pumvisible_ctrl_e_on()
" --------------------------------------
    let s:pumvisible_ctrl_e = 1
    return g:vimim_pumvisible_ctrl_e()
endfunction

" -------------------------------------
function! <SID>vimim_ctrl_x_ctrl_u_bs()
" -------------------------------------
    call s:reset_matched_list()
    let key = '\<BS>'
    " ---------------------------------
    if s:pumvisible_ctrl_e > 0
    \&& s:chinese_input_mode =~ 'dynamic'
        let s:pumvisible_ctrl_e = 0
        let key .= '\<C-R>=g:vimim_ctrl_x_ctrl_u()\<CR>'
        sil!exe 'sil!return "' . key . '"'
    endif
    " ---------------------------------
    if empty(s:chinese_input_mode)
        call s:vimim_stop()
    endif
    " ---------------------------------
    sil!exe 'sil!return "' . key . '"'
endfunction

" ======================================= }}}
let VimIM = " ====  Datafile_Update  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------------
function! s:vimim_initialize_datafile_in_vimrc()
" ----------------------------------------------
    let datafile = s:vimim_datafile
    if !empty(datafile) && filereadable(datafile)
        let s:datafile_primary = copy(datafile)
    endif
    " ------------------------------------------
    let datafile = s:vimim_datafile_digital
    if !empty(datafile) && filereadable(datafile)
        if s:datafile_primary =~# 'pinyin'
            let s:datafile_secondary = copy(s:datafile_primary)
            let s:datafile_primary = copy(datafile)
            let s:pinyin_and_4corner = 1
        else
            let s:datafile_secondary = copy(datafile)
        endif
    endif
    " ------------------------------------------
    if s:vimim_datafile_has_pinyin > 0
    \&& s:vimim_datafile_has_4corner > 0
        let s:pinyin_and_4corner = 2
        let s:im_primary = 'pinyin'
        let s:im['4corner'][0] = 1
        let s:im['pinyin'][0] = 1
    endif
    " ------------------------------------------
endfunction

" -------------------------------------------
function! s:vimim_get_new_order_list(chinese)
" -------------------------------------------
    if empty(s:matched_list)
        return []
    endif
    " --------------------------------
    let chinese = a:chinese
    let one_line_list = split(get(s:matched_list,0))
    let keyboard = get(one_line_list,0)
    let first_fix_candidate = get(one_line_list,1)
    " --------------------------------
    if keyboard !~# s:valid_key
    \|| char2nr(chinese) < 127
    \|| char2nr(first_fix_candidate) < 127
        return []
    endif
    " --------------------------------
    if len(keyboard) == 1 && s:vimimdebug > 0
        return []
    endif
    " --------------------------------
    if first_fix_candidate ==# chinese
        return []
    endif
    let new_order_list = []
    let new_match_list = []
    for item in s:matched_list
        let one_line_list = split(item)
        if get(one_line_list,-1) == "#"
            continue
        endif
        let menu = get(one_line_list,0)
        if keyboard ==# menu
            let new_match_candidate = get(one_line_list,1)
            call add(new_match_list, new_match_candidate)
            call extend(new_order_list, one_line_list[1:])
        endif
    endfor
    if len(new_order_list) < 2
        let msg = "too short for new order list based on input"
        return []
    endif
    " --------------------------------
    let insert_index = 0
    if s:vimim_frequency_first_fix > 0
        let insert_index = 1
    endif
    " --------------------------------
    let used = match(new_order_list, chinese)
    if used < 0
        return []
    else
        let head = remove(new_order_list, used)
        call insert(new_order_list, head, insert_index)
    endif
    " -----------------------------------
    call insert(new_order_list, keyboard)
    " -----------------------------------
    return [new_order_list, new_match_list]
endfunction

" ---------------------------------------------------------
function! s:vimim_update_chinese_frequency_usage(both_list)
" ---------------------------------------------------------
    let new_list = get(a:both_list,0)
    if empty(new_list)
        let s:matched_list = []
        return
    endif
    " update data in memory based on past usage
    " (1/4) locate new order line based on user input
    " -----------------------------------------------
    let match_list = get(a:both_list,1)
    if empty(match_list) || empty(s:lines)
        return
    endif
    let keyboard = get(new_list,0)
    let pattern = '^' . keyboard . '\>'
    let insert_index = match(s:lines, pattern)
    if insert_index < 0
        return
    endif
    " (2/4) delete all but one matching lines
    " ---------------------------------------
    if len(match_list) < 2
        let msg = "only one matching line"
    else
        for item in match_list
            let pattern = '^' . keyboard . '\s\+' . item
            let remove_index = match(s:lines, pattern)
            if remove_index<0 || remove_index==insert_index
                let msg = "nothing to remove"
            else
                call remove(s:lines, remove_index)
            endif
        endfor
    endif
    " (3/4) insert new order list by replacement
    " ------------------------------------------
    let new_order_line = join(new_list)
    let s:lines[insert_index] = new_order_line
    " (4/4) sync datafile in memory to datafile on disk
    " -------------------------------------------------
    if s:chinese_frequency < 2
        return
    endif
    let auto_save = s:keyboard_count % s:chinese_frequency
    if auto_save > 0
        call s:vimim_save_to_disk(s:lines)
    endif
endfunction

" --------------------------------------------
function! s:vimim_reload_datafile(reload_flag)
" --------------------------------------------
    if empty(s:lines) || a:reload_flag > 0
        " ---------------------------------------------
        let s:lines = s:vimim_load_datafile(s:datafile)
        " ---------------------------------------------
        if s:pinyin_and_4corner == 1
            let pinyin = s:datafile_secondary
            let lines = s:vimim_load_datafile(pinyin)
            if empty(lines)
                let msg = "single digital ciku was used"
            else
                call extend(s:lines, lines, 0)
            endif
        endif
        " ---------------------------------------------
    endif
    return s:lines
endfunction

" ---------------------------------------
function! s:vimim_load_datafile(datafile)
" ---------------------------------------
    let lines = []
    if len(a:datafile) > 0
    \&& filereadable(a:datafile)
        let lines = readfile(a:datafile)
    endif
    return lines
endfunction

" -----------------------------------
function! s:vimim_save_to_disk(lines)
" -----------------------------------
    if empty(a:lines)
        return
    endif
    let s:lines = a:lines
    " -------------------------------
    if s:xingma_sleep_with_pinyin > 0
        if empty(s:toggle_xiangma_pinyin)
            let s:lines_primary = a:lines
        else
            let s:lines_secondary = a:lines
        endif
    endif
    " -------------------------------
    if filewritable(s:datafile)
        call writefile(a:lines, s:datafile)
    endif
endfunction

" ----------------------------------------
function! <SID>vimim_save_new_entry(entry)
" ----------------------------------------
    if empty(a:entry)
        return
    endif
    let entries = []
    let entry_split_list = split(a:entry,'\n')
    for entry in entry_split_list
        let has_space = match(entry, '\s')
        if has_space < 0
            continue
        endif
        let words = split(entry)
        if len(words) < 2
            continue
        endif
        let menu = remove(words, 0)
        if menu !~# "[0-9a-z]"
            continue
        endif
        if char2nr(get(words,0)) < 128
            continue
        endif
        let line = menu .' '. join(words, ' ')
        let line = s:vimim_i18n_iconv(line)
        call add(entries, line)
    endfor
    if empty(entries)
        return
    endif
    call s:vimim_save_to_disk(s:vimim_insert_entry(entries))
endfunction

" -------------------------------------
function! s:vimim_insert_entry(entries)
" -------------------------------------
    if empty(a:entries)
        return []
    endif
    " --------------------------------
    call s:vimim_initialization_once()
    let lines = s:vimim_reload_datafile(0)
    " --------------------------------
    if empty(lines)
        return []
    endif
    let len_lines = len(lines)
    let sort_before_save = 0
    let position = -1
    for entry in a:entries
        let pattern = '^' . entry . '$'
        let matched = match(lines, pattern)
        if matched > -1
            continue
        endif
        let menu = get(split(entry),0)
        let length = len(menu)
        while length > 0
            let one_less = strpart(menu, 0, length)
            let length -= 1
            let matched = match(lines, '^'.one_less)
            if matched < 0
                if length < 1
                    let only_char = one_less[:0]
                    let char = char2nr(only_char)
                    while (char >= char2nr('a') && char < char2nr('z'))
                        let patterns = '^' . nr2char(char)
                        let position = match(lines, patterns)
                        let char -= 1
                        if position > -1
                            let pattern = '^\('.nr2char(char+1).'\)\@!'
                            let matched = position
                            let position = match(lines, pattern, matched)
                            if position > -1
                                break
                            endif
                        endif
                    endwhile
                endif
                continue
            else
                if length+1 == len(menu)
                    let patterns = '^' . menu . '.\>'
                    let next = match(lines, patterns, matched)
                    if next > -1
                        for i in reverse(range(matched, next))
                            let position = i
                            if position<len_lines && entry<lines[position]
                                break
                            endif
                        endfor
                        if position > matched
                            break
                        endif
                    endif
                endif
                let patterns = '^\(' . one_less . '\)\@!'
                let position = match(lines, patterns, matched)
                if position > -1
                    break
                else
                    let position = matched+1
                    break
                endif
            endif
        endwhile
        if position < 0
        \|| (position-1<len_lines && lines[position-1]>entry)
        \|| (position-1<len_lines && entry>lines[position+1])
            let sort_before_save = 1
        endif
        call insert(lines, entry, position)
    endfor
    if len(lines) < len_lines
        return []
    endif
    if sort_before_save > 0
        call sort(lines)
    endif
    return lines
endfunction

" ======================================= }}}
let VimIM = " ====  Input_4Corner    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------------------
function! s:vimim_4corner_whole_match(keyboard)
" ---------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \|| a:keyboard !~ '\d'
    \|| len(a:keyboard)%4 != 0
        return []
    endif
    " -------------------------------
    " sijiaohaoma == 6021272260021762
    " -------------------------------
    let keyboards = split(a:keyboard, '\(.\{4}\)\zs')
    return keyboards
endfunction

" ----------------------------------------------------
function! s:vimim_build_reverse_4corner_cache(chinese)
" ----------------------------------------------------
    if s:only_4corner_or_12345 > 0
    \|| s:pinyin_and_4corner == 1
        let datafile = copy(s:datafile_primary)
        let s:four_corner_lines = s:vimim_load_datafile(datafile)
    elseif s:pinyin_and_4corner == 2
        let lines = s:vimim_reload_datafile(0)
        if empty(lines)
            return {}
        endif
        if empty(s:four_corner_lines)
            let first_digit = 0
            let line_index = match(lines, '^\d')
            if line_index > -1
                let first_digit = line_index
            endif
            let first_alpha = len(lines)-1
            let first_alpha = 0
            let line_index = match(lines, '^\D', first_digit)
            if line_index > -1
                let first_alpha = line_index
            endif
            if first_digit < first_alpha
                let s:four_corner_lines = lines[first_digit : first_alpha-1]
            else
                return {}
            endif
        endif
    endif
    if empty(s:four_corner_lines)
        return {}
    endif
    " ------------------------------------------------
    let cache = {}
    let characters = split(a:chinese, '\zs')
    for line in s:four_corner_lines
        let line = s:vimim_i18n_read(line)
        let words = split(line)
        let value = remove(words, 0)
        for key in words
            if match(characters, key) < 0
                continue
            endif
            let cache[key] = value
        endfor
    endfor
    return cache
endfunction

" ======================================= }}}
let VimIM = " ====  Input_Pinyin     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------
function! s:vimim_initialize_pinyin()
" -----------------------------------
    if empty(get(s:im['pinyin'],0))
        if s:vimim_datafile_has_pinyin > 0
            let s:im['pinyin'][0] = 1
        else
            return
        endif
    endif
    " -------------------------------
    let s:vimim_fuzzy_search = 1
    if empty(s:vimim_imode_pinyin)
    \&& empty(s:vimim_imode_universal)
        let s:vimim_imode_pinyin = 1
    endif
endfunction

" ------------------------------------
function! s:vimim_apostrophe(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if empty(s:vimim_datafile_has_apostrophe)
        let keyboard = substitute(keyboard,"'",'','g')
    else
        let msg = "apostrophe is in the datafile"
    endif
    return keyboard
endfunction

" -------------------------------------------------
function! s:vimim_pinyin_filter(results, keyboards)
" -------------------------------------------------
    if get(s:im['pinyin'],0) < 1
    \|| empty(a:results)
    \|| empty(a:keyboards)
        return a:results
    endif
    let new_results = []
    let pattern = s:vimim_apostrophe_fuzzy_pattern(a:keyboards)
    for item in a:results
        let keyboard = get(split(item), 0)
        let chinese = get(split(item), 1)
        let gold = len(chinese)/s:multibyte
        " filter out fake chinese phrase using pinyin theory
        let keyboards = s:vimim_get_pinyin_from_pinyin(keyboard)
        if match(join(keyboards,"'"), pattern) > -1
            call add(new_results, item)
        endif
    endfor
     if empty(new_results)
         let new_results = a:results
     endif
    return new_results
endfunction

" ----------------------------------------------
function! s:vimim_length_filter(results, length)
" ----------------------------------------------
    let results = a:results
    if a:length > 0
        let pattern = '^\w\+\s\+\S\{'. a:length .'}\>'
        call filter(results, 'v:val =~ pattern')
    endif
    return results
endfunction

" ------------------------------------------------
function! s:vimim_get_pinyin_from_pinyin(keyboard)
" ------------------------------------------------
    if s:shuangpin_flag > 0 || s:im['pinyin'][0] < 1
        return []
    else
        let msg = "pinyin breakdown: pinyin=>pin'yin "
    endif
    let keyboard2 = s:vimim_quanpin_transform(a:keyboard)
    if s:vimimdebug > 0
        call s:debugs('pinyin_in', a:keyboard)
        call s:debugs('pinyin_out', keyboard2)
    endif
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
    let pinyinstr = ""      " output string
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

" ======================================= }}}
let VimIM = " ====  Input_Shuangpin  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_dictionary_shuangpin()
" --------------------------------------
    let s:shuangpin_flag = 1
    let key = 'shuangpin'
    let loaded = s:vimim_get_chinese(key)
    let im = loaded
    let keycode = "[0-9a-z'.]"
    if s:vimim_shuangpin_abc > 0
        let im = s:vimim_get_chinese('abc')
    elseif s:vimim_shuangpin_microsoft > 0
        let microsoft = s:vimim_get_chinese('microsoft')
        let im = microsoft . im
        let keycode = "[0-9a-z'.;]"
    elseif s:vimim_shuangpin_nature > 0
        let nature = s:vimim_get_chinese('nature')
        let im = nature . im
    elseif s:vimim_shuangpin_plusplus > 0
        let plusplus = s:vimim_get_chinese('plusplus')
        let im = plusplus . im
    elseif s:vimim_shuangpin_purple > 0
        let purple = s:vimim_get_chinese('purple')
        let im = purple . im
        let keycode = "[0-9a-z'.;]"
    else
        let s:shuangpin_flag = 0
    endif
    let s:im[key] = [loaded, im, keycode]
endfunction

" --------------------------------------
function! s:vimim_initialize_shuangpin()
" --------------------------------------
    call s:vimim_dictionary_shuangpin()
    " ----------------------------------
    if empty(s:shuangpin_flag)
        let s:quanpin_table = s:vimim_create_quanpin_table()
        return
    endif
    " ----------------------------------
    let s:vimim_fuzzy_search = 0
    let s:vimim_imode_pinyin = -1
    let rules = s:vimim_shuangpin_generic()
    " ----------------------------------
    if s:vimim_shuangpin_abc > 0
        let rules = s:vimim_shuangpin_abc(rules)
        let s:vimim_imode_pinyin = 1
    elseif s:vimim_shuangpin_microsoft > 0
        let rules = s:vimim_shuangpin_microsoft(rules)
    elseif s:vimim_shuangpin_nature > 0
        let rules = s:vimim_shuangpin_nature(rules)
    elseif s:vimim_shuangpin_plusplus > 0
        let rules = s:vimim_shuangpin_plusplus(rules)
    elseif s:vimim_shuangpin_purple > 0
        let rules = s:vimim_shuangpin_purple(rules)
    endif
    let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
endfunction

" ---------------------------------------------------
function! s:vimim_get_pinyin_from_shuangpin(keyboard)
" ---------------------------------------------------
    let keyboard = a:keyboard
    if empty(s:shuangpin_flag)
        return keyboard
    endif
    if empty(s:keyboard_shuangpin)
        let msg = "it is here to resume shuangpin"
    else
        return keyboard
    endif
    let keyboard2 = s:vimim_shuangpin_transform(keyboard)
    if s:vimimdebug > 0
        call s:debugs('shuangpin_in', keyboard)
        call s:debugs('shuangpin_out', keyboard2)
    endif
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
                let output .= "'" . s:shuangpin_table[sp1]
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
    if (s:vimim_shuangpin_abc>0) || (s:vimim_shuangpin_purple>0)
        let jxqy = {"jv" : "ju", "qv" : "qu", "xv" : "xu", "yv" : "yu"}
        call extend(sptable, jxqy)
    elseif s:vimim_shuangpin_microsoft > 0
        let jxqy = {"jv" : "jue", "qv" : "que", "xv" : "xue", "yv" : "yue"}
        call extend(sptable, jxqy)
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
    " vtpc => shuang pin => double pinyin
    " -----------------------------------
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

" -----------------------------------------
function! s:vimim_shuangpin_microsoft(rule)
" -----------------------------------------
    " vi=>zhi ii=>chi ui=>shi keng=>keneng
    " ------------------------------------
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
    " goal: 'woui' => wo shi => i am
    " -------------------------------
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

" ======================================= }}}
let VimIM = " ====  Input_Erbi       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ---------------------------------
function! s:vimim_initialize_erbi()
" ---------------------------------
    if empty(get(s:im['erbi'],0))
        return
    endif
    let s:im['wubi'][0] = 1
    let s:vimim_punctuation_navigation = -1
    let s:vimim_wildcard_search = -1
endfunction

" ------------------------------------------------
function! s:vimim_first_punctuation_erbi(keyboard)
" ------------------------------------------------
    let keyboard = a:keyboard
    if empty(get(s:im['erbi'],0))
        return 0
    endif
    " [erbi] the first .,/;' is punctuation
    let chinese_punctuatoin = 0
    if len(keyboard) == 1
    \&& keyboard =~ "[.,/;]"
    \&& has_key(s:punctuations_all, keyboard)
        let chinese_punctuatoin = s:punctuations_all[keyboard]
    endif
    return chinese_punctuatoin
endfunction

" ======================================= }}}
let VimIM = " ====  Input_Wubi       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------------
function! s:vimim_wubi_z_as_wildcard(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
    \|| s:vimim_wildcard_search < 1
        return 0
    endif
    let fuzzy_search_pattern = 0
    if match(keyboard, 'z') > 0
        let fuzzies = keyboard
        if keyboard[:1] != 'zz'
            let fuzzies = substitute(keyboard,'z','.','g')
        endif
        let fuzzy_search_pattern = '^' . fuzzies . '\>'
    endif
    return fuzzy_search_pattern
endfunction

" ------------------------------------
function! s:vimim_toggle_wubi_pinyin()
" ------------------------------------
    if empty(s:toggle_xiangma_pinyin)
        let s:im['wubi'][0] = 1
        let s:im['pinyin'][0] = 0
        let s:datafile = copy(s:datafile_primary)
        if empty(s:lines_primary)
            let s:lines_primary = s:vimim_reload_datafile(1)
        endif
        let s:lines = s:lines_primary
    else
        let s:im['pinyin'][0] = 1
        let s:im['wubi'][0] = 0
        let s:datafile = copy(s:datafile_secondary)
        if empty(s:lines_secondary)
            let s:lines_secondary = s:vimim_reload_datafile(1)
        endif
        let s:lines = s:lines_secondary
    endif
endfunction

" ------------------------------
function! s:vimim_wubi(keyboard)
" ------------------------------
    let keyboard = a:keyboard
    if empty(keyboard)
    \|| get(s:im['wubi'],0) < 1
    \|| get(s:im['pinyin'],0) > 0
        return []
    endif
    " ----------------------------
    let lines = s:vimim_datafile_range(keyboard)
    if empty(lines)
        return []
    endif
    " ----------------------------
    let pattern = s:vimim_wubi_z_as_wildcard(keyboard)
    if !empty(pattern)
        call filter(lines, 'v:val =~ pattern')
        return lines
    endif
    " ----------------------------
    " support wubi non-stop typing
    " ----------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \&& s:vimim_wubi_non_stop > 0
    \&& empty(get(s:im['pinyin'],0))
        if len(keyboard) > 4
            let start = 4*((len(keyboard)-1)/4)
            let keyboard = strpart(keyboard, start)
        endif
        let s:keyboard_wubi = keyboard
    endif
    let results = []
    let pattern = '^' . keyboard
    let match_start = match(lines, pattern)
    if  match_start > -1
        let results = s:vimim_exact_match(lines, match_start)
    endif
    return results
endfunction

" ------------------------------------------
function! s:vimim_wubi_whole_match(keyboard)
" ------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
    \|| a:keyboard !~# '\l'
    \|| len(a:keyboard)%4 != 0
        return []
    endif
    let keyboards = split(a:keyboard,'\(.\{4}\)\zs')
    return keyboards
endfunction

" ======================================= }}}
let VimIM = " ====  Input_Cloud      ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -----------------------------------------
function! s:vimim_do_cloud_if_no_datafile()
" -----------------------------------------
    if empty(s:datafile_primary)
        if empty(s:vimim_cloud_sogou)
            let s:vimim_cloud_sogou = 1
        endif
    endif
endfunction

" ----------------------------------
function! s:vimim_initialize_cloud()
" ----------------------------------
    if s:vimim_cloud_sogou < 0
        return
    endif
    " step 1: try to find libvimim
    " ----------------------------
    let cloud = s:path . "libvimim.so"
    if has("win32") || has("win32unix")
        let cloud = s:vimim_wget_dll
        if empty(cloud)
            let cloud = s:path . "libvimim.dll"
        endif
    endif
    let s:www_libcall = 0
    if filereadable(cloud)
        " in win32, strip the .dll suffix
        if has("win32") && cloud[-4:] ==? ".dll"
            let cloud = cloud[:-5]
        endif
        let ret = libcall(cloud, "do_geturl", "__isvalid")
        if ret ==# "True"
            let s:www_executable = cloud
            let s:www_libcall = 1
            call s:vimim_do_cloud_if_no_datafile()
            return
        endif
    endif
    " step 2: try to find wget
    " ------------------------
    if empty(s:www_executable)
        let wget = 0
        if executable(s:path."wget.exe")
            let wget = s:path."wget.exe"
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
    " step 3: try to find curl if no wget
    " -----------------------------------
    if empty(s:www_executable)
        if executable('curl')
            let s:www_executable = "curl -s "
        endif
    endif
    if empty(s:www_executable)
        let s:vimim_cloud_sogou = 0
    else
        call s:vimim_do_cloud_if_no_datafile()
    endif
endfunction

" ------------------------------------
function! s:vimim_magic_tail(keyboard)
" ------------------------------------
    let keyboard = a:keyboard
    if s:chinese_input_mode =~ 'dynamic'
    \|| keyboard =~ '\d\d\d\d'
    \|| len(keyboard) < 3
        return []
    endif
    let magic_tail = keyboard[-1:]
    let last_but_one =  keyboard[-2:-2]
    if magic_tail =~ "[.']" && last_but_one =~ "[0-9a-z]"
        let msg = " play with magic trailing char "
    else
        return []
    endif
    let keyboards = []
    " ----------------------------------------------------
    " <dot> double play in OneKey mode:
    "   (1) magic trailing dot => forced-non-cloud
    "   (2) as word partition  => match dot by dot
    " ----------------------------------------------------
    if  magic_tail ==# "."
        let msg = " trailing dot => forced-non-cloud"
        let s:no_internet_connection = 2
        call add(keyboards, -1)
    elseif  magic_tail ==# "'"
        let msg = " trailing apostrophe => forced-cloud "
        let s:no_internet_connection = -1
        call add(keyboards, 1)
    endif
    " ----------------------------------------------------
    " <apostrophe> double play in OneKey Mode:
    "   (1) magic trailing apostrophe => cloud at will
    "   (2) magic leading  apostrophe => universal imode
    " ----------------------------------------------------
    let keyboard = keyboard[:-2]
    call insert(keyboards, keyboard)
    return keyboards
endfunction

" --------------------------------------------------
function! s:vimim_to_cloud_or_not(keyboards, clouds)
" --------------------------------------------------
    let do_cloud = get(a:clouds, 1)
    if do_cloud > 0
        return 1
    endif
    " --------------------------------------------
    if s:vimim_cloud_sogou < 1
        return 0
    endif
    " --------------------------------------------
    if s:no_internet_connection > 1
        let msg = "oops, there is no internet connection."
        return 0
    elseif s:no_internet_connection < 0
        return 1
    endif
    " --------------------------------------------
    let keyboard = join(a:keyboards,"")
    if empty(s:chinese_input_mode) && keyboard =~ '[.]'
        return 0
    endif
    if keyboard =~# "[^a-z']"
        let msg = "cloud limits to valid cloud keycodes only"
        return 0
    endif
    " --------------------------------------------
    let msg = "auto cloud if number of zi > threshold"
    let cloud_length = len(a:keyboards)
    if cloud_length < s:vimim_cloud_sogou
        return 0
    endif
    return 1
endfunction

" -----------------------------------------
function! s:vimim_get_cloud_sogou(keyboard)
" -----------------------------------------
    let keyboard = a:keyboard
    if s:vimim_cloud_sogou < 1
    \|| empty(s:www_executable)
    \|| empty(keyboard)
        return []
    endif
    let cloud = 'http://web.pinyin.sogou.com/web_ime/get_ajax/'
    " support apostrophe as delimiter to remove ambiguity
    " (1) examples: piao => pi'ao (cloth)  xian => xi'an (city)
    " (2) add double quotes between keyboard
    " (3) test: xi'anmeimeidepi'aosuifengpiaoyang
    let output = 0
    " --------------------------------------------------------------
    " http://web.pinyin.sogou.com/web_ime/get_ajax/woyouyigemeng.key
    " --------------------------------------------------------------
    try
        if s:www_libcall
            let input = cloud . keyboard . '".key'
            let output = libcall(s:www_executable, "do_geturl", input)
        else
            let input = cloud . '"' . keyboard . '".key'
            let output = system(s:www_executable . input)
        endif
    catch
        let msg = "it looks like sogou has trouble with its cloud?"
        if s:vimimdebug > 0
            call s:debugs('sogou::exception=', v:exception)
        endif
        let output = 0
    endtry
    if empty(output)
        return []
    endif
    " --------------------------------------------------------
    " ime_query_res="%E6%88%91";ime_query_key="woyouyigemeng";
    " --------------------------------------------------------
    let first = match(output, '"', 0)
    let second = match(output, '"', 0, 2)
    if first > 0 && second > 0
        let output = strpart(output, first+1, second-first-1)
        let output = s:vimim_url_xx_to_chinese(output)
    endif
    if empty(output)
        return []
    endif
    " now, let's support Cloud for gb and big5
    " ----------------------------------------
    if empty(s:localization)
        let msg = "both vim and datafile are UTF-8 encoding"
    else
        let output = s:vimim_i18n_read(output)
    endif
    " ---------------------------
    " output='我有一個夢：13	+
    " ---------------------------
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
    " ----------------------------
    " ['woyouyigemeng 我有一個夢']
    " ----------------------------
    return menu
endfunction

" ======================================= }}}
let VimIM = " ====  Input_my_Cloud   ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------------------------------------
function! s:vimim_access_mycloud_plugin(cloud, cmd)
" -------------------------------------------------
"  use the same function to access mycloud by libcall() or system()
    if s:vimimdebug > 0
        call s:debugs("cloud", a:cloud)
        call s:debugs("cmd", a:cmd)
    endif
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
            let ret = libcall(s:www_executable, "do_geturl", a:cloud . input)
        else
            let ret = system(s:www_executable . shellescape(a:cloud . input))
        endif
        let output = s:vimim_rot13(ret)
        let ret = s:vimim_url_xx_to_chinese(output)
        return ret
    endif
    return ""
endfunction

" --------------------------------------
function! s:vimim_check_mycloud_plugin()
" --------------------------------------
    if empty(s:vimim_mycloud_url)
        " we do plug-n-play for libcall(), not for system()
        if has("win32") || has("win32unix")
            let cloud = s:path . "libvimim.dll"
        elseif has("unix")
            let cloud = s:path . "libvimim.so"
        else
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
                let ret = s:vimim_access_mycloud_plugin(cloud,"__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            catch
                if s:vimimdebug > 0
                    call s:debugs('libcall_mycloud2::error=',v:exception)
                endif
            endtry
        endif
        " libcall check failed, we now check system()
        " -------------------------------------------
        if has("gui_win32")
            return 0
        endif
        let mes = "on linux, we do plug-n-play"
        " -------------------------------------
        let cloud = s:path . "mycloud/mycloud"
        if !executable(cloud)
            if !executable("python")
                return 0
            endif
            let cloud = "python " . cloud
        endif
        " in POSIX system, we can use system() for mycloud
        let s:cloud_plugin_mode = "system"
        let ret = s:vimim_access_mycloud_plugin(cloud,"__isvalid")
        if split(ret, "\t")[0] == "True"
            return cloud
        endif
    else
        " we do set-and-play on all systems
        " ---------------------------------
        let part = split(s:vimim_mycloud_url, ':')
        let lenpart = len(part)
        if lenpart <= 1
            call s:debugs("invalid_cloud_plugin_url","")
        elseif part[0] ==# 'app'
            if !has("gui_win32")
                " strip the first root if contains ":"
                if lenpart == 3
                    if part[1][0] == '/'
                        let cloud = part[1][1:] + ':' +  part[2]
                    else
                        let cloud = part[1] + ':' + part[2]
                    endif
                elseif lenpart == 2
                    let cloud = part[1]
                endif
                " in POSIX system, we can use system() for mycloud
                if executable(split(cloud, " ")[0])
                    let s:cloud_plugin_mode = "system"
                    let ret = s:vimim_access_mycloud_plugin(cloud,"__isvalid")
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
                let s:cloud_plugin_arg = ''
            endif
            " provide the dll
            if base == 1
                let cloud = part[1] + ':' + part[2]
            else
                let cloud = part[1]
            endif
            if filereadable(cloud)
                let s:cloud_plugin_mode = "libcall"
                " strip off the ending .dll suffix, only required for win32
                if has("win32") && cloud[-4:] ==? ".dll"
                    let cloud = cloud[:-5]
                endif
                try
                    let ret = s:vimim_access_mycloud_plugin(cloud,"__isvalid")
                    if split(ret, "\t")[0] == "True"
                        return cloud
                    endif
                catch
                    if s:vimimdebug > 0
                        call s:debugs('libcall_mycloud1::error=',v:exception)
                    endif
                endtry
            endif
        elseif part[0] ==# "http" || part[0] ==# "https"
            let cloud = s:vimim_mycloud_url
            if !empty(s:www_executable)
                let s:cloud_plugin_mode = "www"
                let ret = s:vimim_access_mycloud_plugin(cloud,"__isvalid")
                if split(ret, "\t")[0] == "True"
                    return cloud
                endif
            endif
        else
            call s:debugs("invalid_cloud_plugin_url","")
        endif
    endif
    return 0
endfunction

" -------------------------------------------
function! s:vimim_initialize_mycloud_plugin()
" -------------------------------------------
    " mycloud sample url:
    " let g:vimim_mycloud_url = "app:".$VIM."/src/mycloud/mycloud"
    " let g:vimim_mycloud_url = "app:python d:/mycloud/mycloud.py"
    " let g:vimim_mycloud_url = "dll:".$HOME."/plugin/libvimim.so"
    " let g:vimim_mycloud_url = "dll:/data/libvimim.so:192.168.0.1"
    " let g:vimim_mycloud_url = "dll:/home/im/plugin/libmyplugin.so:arg:func"
    " let g:vimim_mycloud_url = "dll:".$HOME."/plugin/cygvimim.dll"
    " let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/qp/"
    " let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/abc/"
    " let g:vimim_mycloud_url = "http://pim-cloud.appspot.com/ms/"
    " --------------------------------------------------------------
    let cloud = s:vimim_check_mycloud_plugin()
    " this variable should not be used after initialization
    unlet s:vimim_mycloud_url
    if empty(cloud)
        let s:vimim_cloud_plugin = 0
        return
    endif
    let ret = s:vimim_access_mycloud_plugin(cloud,"__getname")
    let loaded = split(ret, "\t")[0]
    let ret = s:vimim_access_mycloud_plugin(cloud,"__getkeychars")
    let keycode = split(ret, "\t")[0]
    if empty(keycode)
        let s:vimim_cloud_plugin = 0
    else
        let s:vimim_cloud_plugin = cloud
        let s:vimim_cloud_sogou = -777
        let s:shuangpin_flag = 0
        let s:im['mycloud'][0] = loaded
        let s:im['mycloud'][2] = keycode
        let s:im_primary = 'mycloud'
    endif
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
    " ---------------------------------------
    try
        let output = s:vimim_access_mycloud_plugin(cloud, input)
    catch
        let output = 0
        if s:vimimdebug > 0
            call s:debugs('mycloud::error=',v:exception)
        endif
    endtry
    if empty(output)
        return []
    endif
    return s:vimim_process_mycloud_output(a:keyboard, output)
endfunction

" --------------------------------------------------------
function! s:vimim_process_mycloud_output(keyboard, output)
" --------------------------------------------------------
    let output = a:output
    if empty(output) || empty(a:keyboard)
        return []
    endif
    " ----------------------
    " 春夢	8	4420
    " ----------------------
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
    if s:www_libcall
        let output = libcall(s:www_executable, "do_unquote", a:xx)
    else
        let input = a:xx
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

" ======================================= }}}
let VimIM = " ====  Back_End_Common  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------
function! s:vimim_datafile_range(keyboard)
" ----------------------------------------
    call s:vimim_reload_datafile(0)
    if empty(s:lines) || empty(a:keyboard)
        return []
    endif
    let ranges = s:vimim_search_boundary(s:lines, a:keyboard)
    if empty(ranges)
        return []
    elseif len(ranges) == 1
        let ranges = s:vimim_search_boundary(sort(s:lines), a:keyboard)
        if empty(ranges)
            return []
        else
            call s:vimim_save_to_disk(s:lines)
        endif
    endif
    return s:lines[get(ranges,0) : get(ranges,1)]
endfunction

" ------------------------------------------------
function! s:vimim_search_boundary(lines, keyboard)
" ------------------------------------------------
    if empty(a:lines) || empty(a:keyboard)
        return []
    endif
    let first_char_typed = a:keyboard[:0]
    if s:datafile_has_dot > 0 && first_char_typed == "."
        let first_char_typed = '\.'
    endif
    let patterns = '^' . first_char_typed
    let match_start = match(a:lines, patterns)
    if match_start < 0
        return []
    endif
    " add boundary to datafile search by exact one letter
    " ---------------------------------------------------
    let ranges = []
    call add(ranges, match_start)
    let match_next = match_start
    " allow empty lines at the end of datafile
    let last_line = a:lines[-1]
    let len_lines = len(a:lines)
    let solid_last_line = substitute(last_line,'\s','','g')
    while empty(solid_last_line)
        let len_lines -= 1
        let last_line = a:lines[len_lines]
        let solid_last_line = substitute(last_line,'\s','','g')
    endwhile
    let first_char_last_line = last_line[:0]
    if first_char_typed == first_char_last_line
        let match_next = len(a:lines)-1
    else
        let pattern_next = '^[^' . first_char_typed . ']'
        let result = match(a:lines, pattern_next, match_start)
        if result > 0
            let match_next = result-1
        endif
    endif
    call add(ranges, match_next)
    if match_start > match_next
        let ranges = ['datafile_is_not_sorted']
    endif
    return ranges
endfunction

" --------------------------------------------
function! s:vimim_whole_match(lines, keyboard)
" --------------------------------------------
    if empty(a:lines)
    \|| empty(a:keyboard)
    \|| get(s:im['pinyin'],0) < 1
        return []
    endif
    " [pinyin_quote_sogou] try exact one-line match
    " ---------------------------------------------
    let results = []
    let pattern = '^' . a:keyboard . '\>'
    let whole_match = match(a:lines, pattern)
    if  whole_match >= 0
        let results = a:lines[whole_match : whole_match]
    endif
    return results
endfunction

" -----------------------------------------------
function! s:vimim_exact_match(lines, match_start)
" -----------------------------------------------
    if empty(a:lines) || a:match_start < 0
        return []
    endif
    let match_start = a:match_start
    " ------------------------------------------
    let keyboard = get(split(get(a:lines,match_start)),0)
    if empty(keyboard) || keyboard !~ s:valid_key
        return []
    endif
    " ----------------------------------------
    let pinyin_tone = '\d\='
    let pattern = '^\(' . keyboard
    if len(keyboard) < 2
        let pattern .=  '\>'
    elseif get(s:im['pinyin'],0) > 0
        let pattern .=  pinyin_tone . '\>'
    else
        let pattern .=  '\>'
    endif
    let pattern .=  '\)\@!'
    " ----------------------------------------
    let matched = match(a:lines, pattern, match_start)-1
    if matched - match_start < 1
        let results = a:lines[match_start : match_start]
    endif
    " ----------------------------------------
    let match_end = match_start
    if matched > 0 && matched > match_start
        let match_end = matched
    endif
    " ----------------------------------------
    let words_limit = 20+10
    if match_end - match_start > words_limit
        let match_end = match_start + words_limit
    endif
    let results = a:lines[match_start : match_end]
    " ----------------------------------------
    if len(results) < 10
       let extras = s:vimim_pinyin_more_match_list(a:lines, keyboard, results)
       if len(extras) > 0
           call extend(results, extras)
       endif
    endif
    " ----------------------------------------
    return results
endfunction

" ----------------------------------------------------------------
function! s:vimim_pinyin_more_match_list(lines, keyboard, results)
" ----------------------------------------------------------------
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
    if empty(candidates)
        return []
    endif
    let matched_list = []
    for keyboard in candidates
        let results = s:vimim_whole_match(a:lines, keyboard)
        call extend(matched_list, results)
    endfor
    return matched_list
endfunction

" --------------------------------------------
function! s:vimim_fuzzy_match(lines, keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    let results = a:lines
    if s:vimim_fuzzy_search < 1
    \|| s:chinese_input_mode =~ 'dynamic'
    \|| empty(keyboard)
    \|| empty(results)
        return []
    endif
    if s:vimim_datafile_has_english > 0
        let results = filter(results, 'v:val !~ " #$"')
    endif
    let keyboards = split(keyboard, "'")
    let filter_length = len(keyboards)
    if len(keyboards) < 2
        let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
        if len(keyboard) - len(pinyins) < 2
            " make special rule for cjjp => c'j'j'p
            let filter_length = len(keyboard)
        else
            return []
        endif
    else
        " keyboard has apostrophe: ma'li from mali4
        let keyboard = join(keyboards,"")
    endif
    let pattern = s:vimim_free_fuzzy_pattern(keyboard)
    let results = filter(results, 'v:val =~ pattern')
    let results = s:vimim_length_filter(results, filter_length)
    let results = s:vimim_pinyin_filter(results, keyboards)
    return results
endfunction

" --------------------------------------------
function! s:vimim_free_fuzzy_pattern(keyboard)
" --------------------------------------------
    let fuzzy =  '.*'
    let fuzzies = join(split(a:keyboard,'\ze'), fuzzy)
    let pattern = fuzzies  . fuzzy
    let pattern = '^\<' . pattern . '\>'
    return pattern
endfunction

" ---------------------------------------------------
function! s:vimim_apostrophe_fuzzy_pattern(keyboards)
" ---------------------------------------------------
    let more = "*"
    let keyboards = a:keyboards
    if len(keyboards) == 1
        let more = "+"
        let keyboards = split(get(a:keyboards,0), '\ze')
    endif
    let lowercase = "\\l\\" . more
    let fuzzy = lowercase . "'"
    let fuzzies = join(keyboards, fuzzy)
    let pattern = '^\<' . fuzzies . lowercase . '\>'
    return pattern
endfunction

" --------------------------------------------------
function! s:vimim_keyboard_analysis(lines, keyboard)
" --------------------------------------------------
    let keyboard = a:keyboard
    if empty(a:lines)
    \|| s:chinese_input_mode =~ 'dynamic'
    \|| s:datafile_has_dot > 0
    \|| len(keyboard) < 2
        return []
    endif
    " --------------------------------------------------
    if keyboard =~ '^\l\+\d\+'
        let msg = "[diy] ma7712li4002 => [mali,7712,4002]"
        return []
    endif
    " --------------------------------------------------
    let keyboards = s:vimim_diy_keyboard2number(keyboard)
    if empty(keyboards)
        let msg = " mjads.xdhao.jdaaa "
    else
        return []
    endif
    " --------------------------------------------------
    let blocks = []
    if get(s:im['wubi'],0) > 0
        let blocks = s:vimim_wubi_whole_match(keyboard)
    elseif get(s:im['4corner'],0) > 0
        let blocks = s:vimim_4corner_whole_match(keyboard)
    endif
    " --------------------------------------------------
    if empty(blocks)
        " [pinyin] cjjp breakdown: pinyin => pin'yin "
        let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
        let cloud = s:vimim_to_cloud_or_not(pinyins, [])
        if empty(cloud)
            " [sentence input]: break up long whole sentence
            let blocks = s:vimim_sentence_match(a:lines, keyboard)
        endif
    endif
    " --------------------------------------------------
    return blocks
endfunction

" -----------------------------------------------
function! s:vimim_sentence_match(lines, keyboard)
" -----------------------------------------------
    let keyboard = a:keyboard
    if empty(a:lines)
    \|| keyboard =~ '\d'
    \|| len(keyboard) < 5
        return []
    endif
    let pattern = '^\<' . keyboard . '\>'
    let match_start = -1
    let max = len(keyboard)
    " -------------------------------------------
    while max > 2 && len(keyboard) > 1
        let max -= 1
        let position = max
        let block = strpart(keyboard, 0, position)
        let pattern = '^' . block . '\>'
        let match_start = match(a:lines, pattern)
        if  match_start < 0
            let msg = "continue until match is found"
        else
            break
        endif
    endwhile
    " -------------------------------------------
    let blocks = []
    if match_start > 0
        let matched_part = strpart(keyboard, 0, max)
        let trailing_part = strpart(keyboard, max)
        let blocks = [matched_part, trailing_part]
    endif
    return blocks
endfunction

" ======================================= }}}
let VimIM = " ====  Back_End_DIY     ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ----------------------------------------------
function! s:vimim_diy_lines_to_hash(fuzzy_lines)
" ----------------------------------------------
    if empty(a:fuzzy_lines)
        return {}
    endif
    let chinese_to_keyboard_hash = {}
    for line in a:fuzzy_lines
        let words = split(line)  |" shishi 事实 诗史
        let menu = get(words,0)  |" shishi
        for word in words
            if word != menu
                let chinese_to_keyboard_hash[word] = menu
            endif
        endfor
    endfor
    return chinese_to_keyboard_hash
endfunction

" -------------------------------------------------
function! s:vimim_diy_double_menu(h_ac, h_d1, h_d2)
" -------------------------------------------------
    if empty(a:h_ac) || (empty(a:h_d1) && empty(a:h_d2))
        return []
    endif
    let values = []
    for key in keys(a:h_ac)
        let menu_vary = ""
        let menu_fix  = ""
        let char_first = key
        let char_last = key
        if len(key) > 1
            let char_first = key[: s:multibyte-1]
            let char_last = key[-s:multibyte :]
        endif
       if empty(a:h_d2)
       \&& has_key(a:h_d1, char_first)
        " -----------------------------------------|" ma7li
           let menu_vary = a:h_ac[key]             |" mali
           let menu_fix  = a:h_d1[char_first]      |" 7132
       elseif empty(a:h_d1)
       \&& has_key(a:h_d2, char_last)
        " -----------------------------------------|" mali4   ggy1
           let menu_vary = a:h_ac[key]             |" mali    guigongyu
           let menu_fix  = a:h_d2[char_last]       |" 4002    1040
        elseif has_key(a:h_d1, char_first)
        \&& has_key(a:h_d2, char_last)
        " ------------------------------------------|" ma7li4
            let menu_vary = a:h_ac[key]             |" mali
            let menu_fix1 = a:h_d1[char_first]      |" 7132
            let menu_fix2 = a:h_d2[char_last]       |" 4002
            let menu_fix = menu_fix1.'　'.menu_fix2 |" 7132 4002
        endif
        if !empty(menu_fix) && !empty(menu_vary)
            let menu = menu_fix.'　'.menu_vary
            call add(values, menu." ".key)
        endif
    endfor
    return sort(values)
endfunction

" ------------------------------------------------
function! s:vimim_wildcard_search(keyboard, lines)
" ------------------------------------------------
    if s:chinese_input_mode =~ 'dynamic'
        return []
    endif
    let results = []
    let wildcard_pattern = "[*]"
    let wildcard = match(a:keyboard, wildcard_pattern)
    if wildcard > 0
        let star = substitute(a:keyboard,'[*]','.*','g')
        let fuzzy = '^' . star . '\>'
        let results = filter(a:lines, 'v:val =~ fuzzy')
    endif
    return results
endfunction

" ------------------------------------------
function! <SID>vimim_visual_ctrl_6(keyboard)
" ------------------------------------------
    let keyboard = a:keyboard
    if empty(keyboard)
        return
    endif
    " --------------------------------
    call s:vimim_initialization_once()
    " --------------------------------
    if keyboard =~ '\S'
        let msg = 'kill two birds with one stone'
    else
        let current_line = getline("'<")
        call <SID>vimim_save_new_entry(current_line)
        return
    endif
    " --------------------------------
    let results = []
    if keyboard !~ '\p'
        let results = s:vimim_reverse_lookup(keyboard)
    else
        call add(results, s:vimim_translator(keyboard))
    endif
    " --------------------------------
    let line = line(".")
    call setline(line, results)
    let new_positions = getpos(".")
    let new_positions[1] = line + len(results) - 1
    let new_positions[2] = len(get(split(get(results,-1)),0))+1
    call setpos(".", new_positions)
endfunction

" ---------------------------------------------
function! s:vimim_diy_keyboard2number(keyboard)
" ---------------------------------------------
    if s:vimimdebug < 9
    \|| empty(s:pinyin_and_4corner)
    \|| s:shuangpin_flag > 0
        return []
    endif
    let keyboard = a:keyboard
    " -----------------------------------------
    if keyboard =~ '\d' || keyboard !~ '\l'
        return []
    endif
    " -----------------------------------------
    if len(keyboard) < 5 || len(keyboard) > 6
        return []
    endif
    " -----------------------------------------
    let diy_keyboard_asdfghjklo = {}
    let diy_keyboard_asdfghjklo['a'] = 1
    let diy_keyboard_asdfghjklo['s'] = 2
    let diy_keyboard_asdfghjklo['d'] = 3
    let diy_keyboard_asdfghjklo['f'] = 4
    let diy_keyboard_asdfghjklo['g'] = 5
    let diy_keyboard_asdfghjklo['h'] = 6
    let diy_keyboard_asdfghjklo['j'] = 7
    let diy_keyboard_asdfghjklo['k'] = 8
    let diy_keyboard_asdfghjklo['l'] = 9
    let diy_keyboard_asdfghjklo['o'] = 0
    " -----------------------------------------
    let digits = []
    let alphabet_length = len(keyboard) - 4
    let four_corner = strpart(keyboard, alphabet_length)
    for char in split(four_corner, '\zs')
        if has_key(diy_keyboard_asdfghjklo, char)
            let digit = diy_keyboard_asdfghjklo[char]
            call add(digits, digit)
        else
            return []
        endif
    endfor
    if len(digits) < 4
        return []
    endif
    " -----------------------------------------
    let keyboards = ["", "", "", ""]
    let keyboards[0] = keyboard[0:0]
    if len(keyboard) == 5
        " zi: mjjas => m7712 => ['m', 7712]
        let keyboards[1] = join(digits,"")
    elseif len(keyboard) == 6
        " ci: mljjfo => ml7140 => ["m'l", 71'40]
        let keyboards[1] = join(digits[0:1],"")
        let keyboards[2] = keyboard[1:1]
        let keyboards[3] = join(digits[2:3],"")
    endif
    " -----------------------------------------
    return keyboards
endfunction

" --------------------------------------------
function! s:vimim_pinyin_and_4corner(keyboard)
" --------------------------------------------
    if empty(s:pinyin_and_4corner)
    \|| s:chinese_input_mode =~ 'dynamic'
        return []
    endif
    let keyboards = s:vimim_diy_keyboard2number(a:keyboard)
    if empty(keyboards)
        let keyboards = s:vimim_diy_keyboard(a:keyboard)
    endif
    return s:vimim_diy_results(keyboards, [])
endfunction

" --------------------------------------
function! s:vimim_diy_keyboard(keyboard)
" --------------------------------------
    let keyboard = a:keyboard
    if empty(s:pinyin_and_4corner)
    \|| len(keyboard) < 2
    \|| keyboard =~# '^\d'
    \|| keyboard !~# '\d'
    \|| keyboard !~# '\l'
        return []
    endif
    " ---------------------------------------
    " free style pinyin+4corner for zi and ci
    " let zi = "ma7712" li4002
    " let ci = "ma7712li4002 ma7712li mali4002"
    " let ci = "ggy1 => ['ggy', '', '', 1]
    " --------------------------------------------------------------
    let alpha_keyboards = ["", ""]
    let digit_keyboards = ["", ""]
    let alpha_keyboards = split(keyboard, '\d\+') |" => ['ma', 'li']
    let digit_keyboards = split(keyboard, '\D\+') |" => ['77', '40']
    " --------------------------------------------------------------
    if len(alpha_keyboards) < 2
        let alpha_string = get(alpha_keyboards,0)
        let pinyin_keyboards = s:vimim_get_pinyin_from_pinyin(alpha_string)
        if len(pinyin_keyboards) > 0
            call insert(digit_keyboards, "")
            if len(pinyin_keyboards) == 2
                let alpha_keyboards = copy(pinyin_keyboards)
            endif
        endif
    endif
    " --------------------------------------------------------------
    let keyboards = ["", "", "", ""]
    let keyboards[0] = get(alpha_keyboards,0)
    let keyboards[1] = get(digit_keyboards,0)
    if len(alpha_keyboards) > 1
        let keyboards[2] = get(alpha_keyboards,1)
    endif
    if len(digit_keyboards) > 1
        let keyboards[3] = get(digit_keyboards,1)
    endif
    " --------------------------------------------------------------
    return keyboards
endfunction

" --------------------------------------------------
function! s:vimim_diy_results(keyboards, cache_list)
" --------------------------------------------------
    let keyboards = a:keyboards
    if len(keyboards) != 4
        return []
    endif
    " ----------------------------------------------
    let a = get(keyboards, 0)  |" ma
    let b = get(keyboards, 1)  |" 7
    let c = get(keyboards, 2)  |" li
    let d = get(keyboards, 3)  |" 4
    if !empty(c)
        let a = a . "'" . c
    endif
    " ----------------------------------------------
    let fuzzy_lines = a:cache_list
    if empty(fuzzy_lines)
        let fuzzy_lines = s:vimim_quick_fuzzy_search(a)
    endif
    let h_ac = s:vimim_diy_lines_to_hash(fuzzy_lines)
    " ----------------------------------
    let fuzzy_lines = s:vimim_quick_fuzzy_search(b)
    let h_d1 = s:vimim_diy_lines_to_hash(fuzzy_lines)
    " ----------------------------------
    let fuzzy_lines = s:vimim_quick_fuzzy_search(d)
    let h_d2 = s:vimim_diy_lines_to_hash(fuzzy_lines)
    " ----------------------------------
    return s:vimim_diy_double_menu(h_ac, h_d1, h_d2)
endfunction

" --------------------------------------------
function! s:vimim_quick_fuzzy_search(keyboard)
" --------------------------------------------
    let keyboard = a:keyboard
    let lines = s:vimim_datafile_range(keyboard)
    if empty(keyboard) || empty(lines)
        return []
    endif
    let pattern = '^' .  keyboard
    let has_digit = match(keyboard, '^\d\+')
    let results = []
    if has_digit < 0
        let msg = "step 1/2: try whole exact match"
        " -----------------------------------------
        let pattern = '^' . keyboard . '\> '
        let whole_match = match(lines, pattern)
        if  whole_match > -1
            if s:vimim_datafile_has_apostrophe > 0
                let results = lines[whole_match : whole_match]
            else
                let results = s:vimim_exact_match(lines, whole_match)
            endif
            if len(results) > 0
                return s:vimim_pair_list(results)
            endif
        endif
        let msg = "step 2/2: try fuzzy match"
        " -----------------------------------
        let results = s:vimim_fuzzy_match(lines, keyboard)
    else
        let results = filter(lines, 'v:val =~ pattern')
    endif
    " -----------------------------------------------------------
    return s:vimim_i18n_read_list(results)
endfunction

" ======================================= }}}
let VimIM = " ====  Debug_Framework  ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" -------------------------------------
function! s:vimim_initialize_backdoor()
" -------------------------------------
    let g:vimim = ["",0,0,1,localtime()]
    let s:chinese_mode_switch = 1
    let s:initialization_loaded = 0
    let s:datafile_primary = 0
    let s:datafile_secondary = 0
    let datafile_backdoor = s:path . "vimim.txt"
    " -----------------------------------------
    if filereadable(datafile_backdoor)
        let s:vimim_custom_skin=1
        let s:datafile_primary = datafile_backdoor
        call s:vimim_initialize_backdoor_setting()
    endif
    " -----------------------------------------
    if s:vimim_custom_skin > 0
        call s:vimim_initialize_skin()
    endif
    " -----------------------------------------
endfunction

" ---------------------------------------------
function! s:vimim_initialize_backdoor_setting()
" ---------------------------------------------
    let s:vimimdebug=9
    let s:vimim_cloud_sogou=6
    let s:vimim_static_input_style=2
    let s:vimim_ctrl_space_to_toggle=2
    " ------------------------------ debug
    let s:vimim_chinese_frequency=14
    let s:vimim_custom_laststatus=0
    let s:vimim_wildcard_search=1
    let s:vimim_imode_universal=1
    let s:vimim_unicode_lookup=1
    let s:vimim_reverse_pageup_pagedown=1
    let s:vimim_english_punctuation=0
    let s:vimim_chinese_punctuation=1
    let s:vimim_datafile_has_english=1
    let s:vimim_datafile_has_pinyin=1
    let s:vimim_datafile_has_4corner=1
    " ------------------------------
endfunction

" --------------------------------
function! s:vimim_egg_vimimdebug()
" --------------------------------
    let eggs = []
    for item in s:debugs
        let egg = "> "
        let egg .= item
        let egg .= "　"
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
    let item = '['
    let item .= s:debug_count
    let item .= ']'
    let item .= a:key
    let item .= '='
    let item .= a:value
    call add(s:debugs, item)
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
            let s:debugs = s:debugs[0 : max]
        endif
    endif
endfunction

" ======================================= }}}
let VimIM = " ====  Core_Workflow    ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" --------------------------------------
function! s:vimim_initialize_i_setting()
" --------------------------------------
    let s:saved_cpo=&cpo
    let s:saved_iminsert=&iminsert
    let s:completefunc=&completefunc
    let s:completeopt=&completeopt
    let s:saved_lazyredraw=&lazyredraw
    let s:saved_hlsearch=&hlsearch
    let s:saved_pumheight=&pumheight
    let s:saved_statusline=&statusline
    let s:saved_laststatus=&laststatus
endfunction

" ------------------------------
function! s:vimim_i_setting_on()
" ------------------------------
    set completefunc=VimIM
    set completeopt=menuone
    set nolazyredraw
    if empty(&pumheight)
        let &pumheight=10
    endif
    set hlsearch
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
    let &hlsearch=s:saved_hlsearch
    let &pumheight=s:saved_pumheight
    let &statusline=s:saved_statusline
    let &laststatus=s:saved_laststatus
endfunction

" ----------------------------
function! s:vimim_start_omni()
" ----------------------------
    let s:unicode_menu_display_flag = 0
    let s:menu_from_cloud_flag = 0
    let s:insert_without_popup = 0
endfunction

" -----------------------------
function! s:vimim_super_reset()
" -----------------------------
    sil!call s:reset_before_anything()
    sil!call g:reset_after_auto_insert()
    sil!call s:vimim_reset_before_stop()
endfunction

" -----------------------
function! s:vimim_start()
" -----------------------
    sil!call s:vimim_initialization_once()
    sil!call s:vimim_i_setting_on()
    sil!call s:vimim_i_cursor_color(1)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_label_on()
    sil!call s:vimim_reload_datafile(1)
    let g:vimim[4] = localtime()
endfunction

" ----------------------
function! s:vimim_stop()
" ----------------------
    let duration = localtime() - get(g:vimim,4)
    let g:vimim[3] += duration
    sil!autocmd! onekey_mode_autocmd
    sil!autocmd! chinese_mode_autocmd
    sil!call s:vimim_stop_sexy_mode()
    sil!call s:vimim_i_setting_off()
    sil!call s:vimim_i_cursor_color(0)
    sil!call s:vimim_super_reset()
    sil!call s:vimim_debug_reset()
    sil!call s:vimim_i_map_off()
    sil!call s:vimim_initialize_mapping()
endfunction

" -----------------------------------
function! s:vimim_reset_before_stop()
" -----------------------------------
    let s:smart_enter = 0
    let s:pumvisible_ctrl_e = 0
endfunction

" ---------------------------------
function! s:reset_before_anything()
" ---------------------------------
    call s:reset_matched_list()
    let s:chinese_input_mode = 0
    let s:no_internet_connection = 0
    let s:pattern_not_found = 0
    let s:keyboard_count += 1
    let s:pumvisible_reverse = 0
    let s:chinese_punctuation = (s:vimim_chinese_punctuation+1)%2
endfunction

" ----------------------------------------
function! s:reset_popupmenu_matched_list()
" ----------------------------------------
    let s:menu_4corner_filter = -1
    let s:pageup_pagedown = 0
    let s:popupmenu_matched_list = []
endfunction

" ------------------------------
function! s:reset_matched_list()
" ------------------------------
    call s:reset_popupmenu_matched_list()
    let s:matched_list = []
endfunction

" -----------------------------------
function! g:reset_after_auto_insert()
" -----------------------------------
    let s:keyboard_leading_zero = 0
    let s:keyboard_shuangpin = 0
    let s:keyboard_wubi = ''
    let s:smart_ctrl_n = 0
    let s:smart_ctrl_p = 0
    let s:smart_backspace = 0
    let s:one_key_correction = 0
    return ''
endfunction

" ------------------------------------
function! g:vimim_reset_after_insert()
" ------------------------------------
    if pumvisible()
        return ''
    endif
    " --------------------------------
    let chinese = s:vimim_popup_word()
    let g:vimim[2] += (len(chinese)/s:multibyte)
    if s:chinese_frequency > 0
        let both_list = s:vimim_get_new_order_list(chinese)
        call s:vimim_update_chinese_frequency_usage(both_list)
    endif
    " --------------------------------
    call s:reset_matched_list()
    call g:reset_after_auto_insert()
    " --------------------------------
    if empty(s:chinese_input_mode)
        call s:vimim_stop()
    endif
    " --------------------------------
    return ''
endfunction

" ---------------------------
function! s:vimim_i_map_off()
" ---------------------------
    let unmap_list = range(0,9)
    call extend(unmap_list, s:valid_keys)
    call extend(unmap_list, keys(s:punctuations))
    call extend(unmap_list, ['<CR>', '<BS>', '<Space>'])
    call extend(unmap_list, ['<Esc>', '<C-N>', '<C-P>'])
    " -----------------------
    for _ in unmap_list
        sil!exe 'iunmap '. _
    endfor
    " -----------------------
    iunmap <Bslash>
    iunmap '
    iunmap "
    " -----------------------
endfunction

" -----------------------------------
function! s:vimim_helper_mapping_on()
" -----------------------------------
    if s:vimim_static_input_style == 2
        inoremap <C-N> <C-R>=<SID>vimim_smart_ctrl_n()<CR>
        inoremap <C-P> <C-R>=<SID>vimim_smart_ctrl_p()<CR>
    endif
    " ----------------------------------------------------------
    if s:vimim_static_input_style == 1
        inoremap  <Esc>  <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                        \<C-R>=g:vimim_one_key_correction()<CR>
    endif
    " ----------------------------------------------------------
    inoremap <CR>  <C-R>=g:vimim_pumvisible_ctrl_e()<CR>
                  \<C-R>=<SID>vimim_smart_enter()<CR>
    " ----------------------------------------------------------
    inoremap <BS>  <C-R>=g:vimim_pumvisible_ctrl_e_on()<CR>
                  \<C-R>=<SID>vimim_ctrl_x_ctrl_u_bs()<CR>
    " ----------------------------------------------------------
endfunction

" ======================================= }}}
let VimIM = " ====  Core_Engine      ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

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

    " get one char when input-memory is used
    " --------------------------------------
    if s:smart_ctrl_n > 0
        if start_column > 0
            let start_column -= 1
            let s:start_column_before = start_column
            return start_column
        endif
    endif

    " support natural sentence input with space
    " -----------------------------------------
    if empty(s:chinese_input_mode)
    \&& byte_before ==# "."
    \&& char_before_before =~# "[0-9a-z]"
        let match_start = match(current_line, '\w\+\s\+\p\+\.$')
        if match_start > -1
            let s:sentence_with_space_input = 1
            return match_start
        endif
    endif

    " take care of seamless english/chinese input
    " -------------------------------------------
    let seamless_column = s:vimim_get_seamless(current_positions)
    if seamless_column < 0
        let msg = "no need to set seamless"
    else
        let s:start_column_before = seamless_column
        return seamless_column
    endif

    let last_seen_nonsense_column = start_column
    let all_digit = 1

    let nonsense_pattern = "[0-9.']"
    if get(s:im['pinyin'],0) > 0
        let nonsense_pattern = "[0-9.]"
    endif
    while start_column > 0 && byte_before =~# s:valid_key
        let start_column -= 1
        if byte_before !~# nonsense_pattern
            let last_seen_nonsense_column = start_column
        endif
        if byte_before =~# '\l' && all_digit > 0
            let all_digit = 0
        endif
        let byte_before = current_line[start_column-1]
    endwhile

    if all_digit < 1
        let start_column = last_seen_nonsense_column
        let char_1st = current_line[start_column]
        let char_2nd = current_line[start_column+1]
        if char_1st ==# "'"
            if s:vimim_imode_universal > 0
            \&& char_2nd =~# "[0-9ds']"
                let msg = "sharing apostrophe as much as possible"
            else
                let start_column += 1
            endif
        endif
    endif

    let s:start_row_before = start_row
    let s:current_positions = current_positions
    let len = current_positions[2]-1 - start_column
    let s:keyboard_leading_zero = strpart(current_line,start_column,len)

    let s:start_column_before = start_column
    return start_column

else

    if s:vimimdebug > 0
        let s:debug_count += 1
        call s:debugs('keyboard', s:keyboard_leading_zero)
        if s:vimimdebug > 2
            call s:debugs('keyboard_a', a:keyboard)
        endif
    endif

    if s:one_key_correction > 0
        let d = 'delete in omni popup menu'
        let BS = 'delete in Chinese Mode'
        let s:one_key_correction = 0
        return [" "]
    endif

    let keyboard = a:keyboard
    if empty(s:keyboard_leading_zero)
        let s:keyboard_leading_zero = keyboard
    endif
    if empty(str2nr(keyboard))
        let msg = "the input is alphabet only"
    else
        let keyboard = s:keyboard_leading_zero
    endif

    " ignore all-zeroes keyboard inputs
    " ---------------------------------
    if empty(s:keyboard_leading_zero)
        return
    endif

    " ignore non-sense keyboard inputs
    " --------------------------------
    if keyboard !~# s:valid_key
        return
    endif

    " ignore multiple non-sense dots
    " ------------------------------
    if keyboard =~# '^[\.\.\+]'
        let s:pattern_not_found += 1
        return
    endif

    " [erbi] special meaning of the first punctuation
    " -----------------------------------------------
    if s:im['erbi'][0] > 0
        let punctuation = s:vimim_first_punctuation_erbi(keyboard)
        if !empty(punctuation)
            return [punctuation]
        endif
    endif

    " ignore non-sense one char input
    " -------------------------------
    if s:vimim_static_input_style < 2
    \&& len(keyboard) == 1
    \&& keyboard !~# '\w'
        return
    endif

    " use cached list when input-memory is used
    " -----------------------------------------
    if s:smart_ctrl_n > 0
        let results = s:vimim_get_list_from_smart_ctrl_n(keyboard)
        if !empty(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " use all cached list when input-memory is used
    " ---------------------------------------------
    if s:smart_ctrl_p > 0
        let results = s:vimim_get_list_from_smart_ctrl_p(keyboard)
        if !empty(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [record] keep track of all valid inputs
    " ---------------------------------------
    if keyboard !~ '\s'
        let g:vimim[0] .=  keyboard . "."
        let g:vimim[1] +=  len(keyboard)
    endif

    " [eggs] hunt classic easter egg ... vim<C-6>
    " -------------------------------------------
    if keyboard ==# "vim" || keyboard =~# "^vimim"
        let results = s:vimim_easter_chicken(keyboard)
        if len(results) > 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " only play with portion of datafile of interest
    " ----------------------------------------------
    let lines = s:vimim_datafile_range(keyboard)

    " use cached list when pageup/pagedown or 4corner is used
    " -------------------------------------------------------
    if s:vimim_punctuation_navigation > -1
        let results = s:popupmenu_matched_list
        if empty(results)
            let msg = "no popup matched list; let us build it"
        else
            if s:pumvisible_reverse > 0
                let s:pumvisible_reverse = 0
                let results = reverse(results)
            endif
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " try super-internal-code if no single datafile nor cloud
    " -------------------------------------------------------
    let use_virtual_datafile = 0
    if empty(lines) && empty(s:www_executable)
        let use_virtual_datafile = 1
    elseif s:vimimdebug == 9
    \&& len(keyboard) == 2
    \&& keyboard[0:0] ==# 'u'
        let keyboard = keyboard[-1:-1]
        let use_virtual_datafile = 1
    endif
    if use_virtual_datafile > 0
        let msg = " play with super light-weight internal-code "
        let results = s:vimim_without_datafile(keyboard)
        if len(results) > 0
            let s:unicode_menu_display_flag = 1
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [mycloud] get chunmeng from mycloud local or www
    " ------------------------------------------------
    if empty(s:vimim_cloud_plugin)
        let msg = "keep local mycloud code for the future."
    else
        let results = s:vimim_get_mycloud_plugin(keyboard)
        let s:menu_from_cloud_flag = 1
        if empty(len(results))
            " return empty list if the result is empty
            return []
        else
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " support direct internal code (unicode/gb/big5) input
    " ----------------------------------------------------
    if s:vimim_internal_code_input > 0
        let results = s:vimim_internal_code(keyboard)
        if len(results) > 0
            let s:unicode_menu_display_flag = 1
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [wubi][erbi] plays with pinyin in harmony
    " -----------------------------------------
    if s:xingma_sleep_with_pinyin > 0
        call s:vimim_toggle_wubi_pinyin()
    endif

    " escape literal dot if [array][phonetic][erbi]
    " ---------------------------------------------
    if s:datafile_has_dot > 0
        let keyboard = substitute(keyboard,'\.','\\.','g')
    endif

    " [wubi] support wubi non-stop input
    " ----------------------------------
    if get(s:im['wubi'],0) > 0
        let results = s:vimim_wubi(keyboard)
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [imode] magic 'i': English number => Chinese number
    " ---------------------------------------------------
    if s:vimim_imode_pinyin > 0 && keyboard =~# '^i'
        let chinese_numbers = s:vimim_imode_number(keyboard, 'i')
        if len(chinese_numbers) > 0
            return s:vimim_popupmenu_list(chinese_numbers)
        endif
    endif

    " [imode] magic leading apostrophe: universal imode
    " -------------------------------------------------
    if s:vimim_imode_universal > 0
    \&& keyboard =~# "^'"
    \&& (empty(s:chinese_input_mode) || s:chinese_input_mode=~ 'sexy')
        let chinese_numbers = s:vimim_imode_number(keyboard, "'")
        if len(chinese_numbers) > 0
            return s:vimim_popupmenu_list(chinese_numbers)
        endif
    endif

    " [wildcard search] explicit fuzzy search
    " ----------------------------------------
    if s:vimim_wildcard_search > 0
        let results = s:vimim_wildcard_search(keyboard, lines)
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [cloud] magic trailing apostrophe to control cloud or not cloud
    " ---------------------------------------------------------------
    let clouds = s:vimim_magic_tail(keyboard)
    if len(clouds) > 0
        let keyboard = get(clouds, 0)
    endif

    " [shuangpin] support 5 major shuangpin with various rules
    " --------------------------------------------------------
    let keyboard = s:vimim_get_pinyin_from_shuangpin(keyboard)

    " [modeless] english sentence input =>  i have a dream.
    " -----------------------------------------------------
    if empty(s:chinese_input_mode)
        if s:sentence_with_space_input > 0
            if keyboard =~ '\s'
            \&& empty(s:datafile_has_dot)
            \&& len(keyboard) > 3
                let keyboard = substitute(keyboard, '\s\+', '.', 'g')
            endif
            let s:sentence_with_space_input = 0
        endif
    endif

    " [apostrophe] in pinyin datafile
    " ------------------------------- todo
    let keyboard = s:vimim_apostrophe(keyboard)
    let s:keyboard_leading_zero = keyboard

    " break up dot-separated sentence
    " -------------------------------
    if keyboard =~ '[.]'
    \&& keyboard[0:0] != '.'
    \&& keyboard[-1:-1] != '.'
        let periods = split(keyboard, '[.]')
        if len(periods) > 0
            let msg = "enjoy.girl.1010.2523.4498.7429"
            let keyboard = get(periods, 0)
        endif
    endif

    " now it is time to do regular expression matching
    " ------------------------------------------------
    let pattern = "\\C" . "^" . keyboard
    let match_start = match(lines, pattern)

    " word matching algorithm for Chinese word segmentation
    " -----------------------------------------------------
    if match_start < 0 && empty(clouds)
        let keyboards = s:vimim_keyboard_analysis(lines, keyboard)
        if empty(keyboards)
            let msg = "sell the keyboard as is, without modification"
        else
            let keyboard = get(keyboards, 0)
            let pattern = "\\C" . "^" . keyboard
            let match_start = match(lines, pattern)
        endif
        " [DIY] "Do It Yourself" couple IM: pinyin+4corner
        " ------------------------------------------------
        let results = s:vimim_pinyin_and_4corner(keyboard)
        if len(results) > 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [cloud] to make cloud come true for woyouyigemeng
    " -------------------------------------------------
    if match_start < 0 || get(clouds,1) > 0
        let pinyins = s:vimim_get_pinyin_from_pinyin(keyboard)
        let cloud = s:vimim_to_cloud_or_not(pinyins, clouds)
        if cloud > 0
            if len(keyboard)-len(pinyins)<2 && len(keyboard)>4
                let msg = " do cjjp: laystbz=>l'a'y's't'b'z "
                let keyboard = join(split(keyboard,'\zs'),"'")
            endif
            let results = s:vimim_get_cloud_sogou(keyboard)
            if s:vimimdebug > 0
                call s:debugs('cloud_stone', keyboard)
                call s:debugs('cloud_gold', s:debug_list(results))
            endif
            if empty(len(results))
                if s:vimim_cloud_sogou > 2
                    let s:no_internet_connection += 1
                endif
            else
                let s:no_internet_connection = 0
                let s:menu_from_cloud_flag = 1
                return s:vimim_popupmenu_list(results)
            endif
        endif
    endif

    if match_start < 0
        " [fuzzy search] implicit wildcard search
        " ---------------------------------------
        let results = s:vimim_fuzzy_match(lines, keyboard)
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    else
        " [exact match] search on the sorted datafile
        " -------------------------------------------
        let results = s:vimim_whole_match(lines, keyboard)
        if s:vimim_datafile_has_apostrophe > 0
            let results = s:vimim_whole_match(lines, keyboard)
        else
            let results = s:vimim_exact_match(lines, match_start)
        endif
        if len(results) > 0
            let results = s:vimim_pair_list(results)
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [cloud] last try cloud before giving up
    " ---------------------------------------
    if s:vimim_cloud_sogou == 1
        let results = s:vimim_get_cloud_sogou(keyboard)
        if len(results) > 0
            return s:vimim_popupmenu_list(results)
        endif
    endif

    " [seamless] support seamless English input
    " -----------------------------------------
    if match_start < 0
        let s:pattern_not_found += 1
        let results = []
        if empty(s:chinese_input_mode)
            let results = [keyboard ." ". keyboard]
        else
            call <SID>vimim_set_seamless()
        endif
        return s:vimim_popupmenu_list(results)
    endif

endif
endfunction

" ======================================= }}}
let VimIM = " ====  Core_Drive       ==== {{{"
" ===========================================
call add(s:vimims, VimIM)

" ------------------------------------
function! s:vimim_initialize_mapping()
" ------------------------------------
    sil!call s:vimim_visual_mapping_on()
    sil!call s:vimim_chinese_mode_mapping_on()
    sil!call s:vimim_sexy_mode_mapping_on()
    sil!call s:vimim_ctrl_space_mapping_on()
    sil!call s:vimim_onekey_mapping_on()
endfunction

" -----------------------------------
function! s:vimim_visual_mapping_on()
" -----------------------------------
    if !hasmapto('<C-^>', 'v')
        xnoremap <C-^> y:call <SID>vimim_visual_ctrl_6(@0)<CR>
    endif
endfunction

" -----------------------------------------
function! s:vimim_chinese_mode_mapping_on()
" -----------------------------------------
    if s:vimim_static_input_style > 1
        return
    endif
    if !hasmapto('<Plug>VimimChinesemode', 'i')
        inoremap <unique> <expr> <Plug>VimimChinesemode <SID>Chinesemode()
    endif
       imap <silent> <C-Bslash> <Plug>VimimChinesemode
    noremap <silent> <C-Bslash> :call <SID>Chinesemode()<CR>
endfunction

" --------------------------------------
function! s:vimim_sexy_mode_mapping_on()
" --------------------------------------
    if s:vimim_static_input_style != 2
        return
    endif
    if !hasmapto('<Plug>VimimSexymode', 'i')
        inoremap <unique> <expr> <Plug>VimimSexymode <SID>Sexymode()
    endif
    if s:vimim_ctrl_space_to_toggle < 2
           imap <silent> <C-Bslash> <Plug>VimimSexymode
        noremap <silent> <C-Bslash> :call <SID>Sexymode()<CR>
    endif
endfunction

" ---------------------------------------
function! s:vimim_ctrl_space_mapping_on()
" ---------------------------------------
    if s:vimim_ctrl_space_to_toggle == 1
        if has("gui_running")
            nmap <C-Space> <C-Bslash>
            imap <C-Space> <C-Bslash>
        elseif has("win32unix")
            nmap <C-@> <C-Bslash>
            imap <C-@> <C-Bslash>
        endif
    elseif s:vimim_ctrl_space_to_toggle == 2
        if has("gui_running")
            imap <silent> <C-Space> <Plug>VimimSexymode
        elseif has("win32unix")
            imap <silent> <C-@> <Plug>VimimSexymode
        endif
    endif
endfunction

" -----------------------------------
function! s:vimim_onekey_mapping_on()
" -----------------------------------
    if !hasmapto('<Plug>VimimOnekey', 'i')
        inoremap <unique> <expr> <Plug>VimimOnekey <SID>Onekey()
    endif
    imap <silent> <C-^> <Plug>VimimOnekey
    if s:vimim_tab_as_onekey > 0
        imap <silent> <Tab> <Plug>VimimOnekey
    endif
endfunction

" ----------------------------
function! s:vimim_mini_vimrc()
" ----------------------------
    set nocompatible
    set encoding=utf-8
    set termencoding=utf8
    set fileencodings=ucs-bom,utf8,chinese,taiwan
    set guifontwide=NSimSun-18030,GulimChe,GungsuhChe,MS_Mincho,SimHei
    set noloadplugins
    runtime! plugin/vimim.vim
endfunction

sil!call s:vimim_initialize_global()
sil!call s:vimim_initialize_backdoor()
sil!call s:vimim_initialize_mapping()
" ====================================== }}}
