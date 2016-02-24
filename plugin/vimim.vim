" ===========================================================
"                   VimIM —— Vim 中文輸入法
" ===========================================================
let s:egg = ' vimim easter egg:' " vim i vimim CTRL-^ CTRL-^
let s:url = ' http://vimim.googlecode.com/svn/vimim/vimim.vim.html'
let s:url = ' http://code.google.com/p/vimim/source/list'
let s:url = ' http://vim.sf.net/scripts/script.php?script_id=2506'

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin as an Input Method for i_CTRL-^ in Vim
"    (1) do Chinese input without mode change: Midas touch
"    (2) do Chinese search without typing Chinese: slash search
"    (3) support Google/Baidu/Sogou/QQ cloud input
"    (4) support bsd database with python interface to Vim
"  PnP: Plug and Play
"    (1) drop the vimim.vim to the plugin folder: plugin/vimim.vim
"    (2) [option] drop supported datafiles, like: plugin/vimim.txt
"  Usage: VimIM takes advantage of the definition from Vim
"    (1) :help gi        Insert text                     ...
"    (2) :help n         Repeat the latest '/' or '?'    ...
"    (3) :help i_CTRL-^  Toggle the use of language      ...
"    (4) :help i_CTRL-_  Switch between languages        ...
"    (5) :help i_CTRL-U  Delete all entered characters   ... (internal)
"    (6) :help i_CTRL-L  When ... is set: Go to ... mode ... (internal)

" ============================================= }}}
let s:VimIM += [" ====  initialization   ==== {{{"]
" =================================================

function! s:vimim_bare_bones_vimrc()
    set cpoptions=Bce$ go=cirMehf shm=aoOstTAI noloadplugins
    set gcr=a:blinkon0 shellslash noswapfile hlsearch viminfo=
    set fencs=ucs-bom,utf8,chinese,gb18030 gfn=Courier_New:h12:w7
    set enc=utf8 gfw=YaHei_Consolas_Hybrid,NSimSun-18030
    let unix = '/usr/local/bin:/usr/bin:/bin:.'
    let windows = '/bin/;/Python27;/Python31;/Windows/system32;.'
    let $PATH = has("unix") ? unix : windows
endfunction

if exists("g:Vimim_profile") || &iminsert == 1 || v:version < 700
    finish
elseif &compatible
    call s:vimim_bare_bones_vimrc()
endif
scriptencoding utf-8
let g:Vimim_profile = reltime()
let s:plugin = expand("<sfile>:p:h")

function! s:vimim_initialize_debug()
    " gvim -u /var/mobile/vim/vimfiles/plugin/vimim.vim
    " gvim -u /home/vimim/svn/vimim/trunk/plugin/vimim.vim
    let s:plugon = simplify(s:plugin . '/../../../hjkl/')
    if empty(&cp) && exists('s:plugon') && isdirectory(s:plugon)
        let g:Vimim_map = 'tab_as_gi'
    endif
endfunction

function! s:vimim_initialize_backdoor()
    let s:titlestring = &titlestring
    let s:cjk = { 'lines' : [] }
    let s:english = { 'lines' : [], 'line' : "" }
    let s:cjk.filename     = s:vimim_filereadable("vimim.cjk.txt")
    let s:english.filename = s:vimim_filereadable("vimim.txt")
    let s:mandarin = len(s:english.filename) ? 0 : 1 " s/t chinese style
    let s:hit_and_run = len(s:cjk.filename) ? 0 : 1 " onekey continuity
    if len(s:cjk.filename)
        highlight! PmenuSbar  NONE
        highlight! PmenuThumb NONE
        highlight! Pmenu      NONE
        highlight! link PmenuSel NonText
    endif
endfunction

function! s:vimim_debug(...)
    " [.vimrc] :redir @+>>
    " [client] :sil!call s:vimim_debug(s:vimim_egg_vimim())
    sil!echo "\n::::::::::::::::::::::::"
    if len(a:000) > 1
        sil!echo join(a:000, " :: ")
    elseif type(a:1) == type({})
        for key in keys(a:1)
            sil!echo key . '::' . a:1[key]
        endfor
    elseif type(a:1) == type([])
        for line in a:1
            sil!echo line
        endfor
    else
        sil!echo string(a:1)
    endif
    sil!echo "::::::::::::::::::::::::\n"
endfunction

function! s:vimim_initialize_global()
    highlight  default lCursorIM guifg=NONE guibg=green gui=NONE
    highlight! link lCursor lCursorIM
    let s:space = '　'
    let s:colon = '：'
    let g:Vimim = "VimIM　中文輸入法"
    let s:windowless_title = "VimIM"
    let s:today = s:vimim_imode_today_now('itoday')
    let s:multibyte    = &encoding =~ "utf-8" ? 3 : 2
    let s:localization = &encoding =~ "utf-8" ? 0 : 2
    let s:seamless_positions = []
    let s:starts = { 'row' : 0, 'column' : 1 }
    let s:quanpin_table = {}
    let s:http_exe = ""
    let s:abcd = split("'abcdvfgxz", '\zs')
    let s:qwer = split("pqwertyuio", '\zs')
    let s:az_list = map(range(97,122),"nr2char(".'v:val'.")")
    let s:valid_keys = s:az_list
    let s:valid_keyboard = "[0-9a-z']"
    let s:valid_wubi_keyboard = "[0-9a-z]"
    let s:shengmu_list = split('b p m f d t l n g k h j q x r z c s y w')
    let s:pumheights = { 'current' : &pumheight, 'saved' : &pumheight }
    let s:smart_quotes = { 'single' : 1, 'double' : 1 }
    let s:backend = { 'datafile' : {}, 'directory' : {} }
    let s:ui = { 'root' : '', 'im' : '', 'quote' : 0, 'frontends' : [] }
    let s:rc = {}
    let s:rc["g:Vimim_mode"] = 'dynamic'
    let s:rc["g:Vimim_map"] = ''
    let s:rc["g:Vimim_toggle"] = 0
    let s:rc["g:Vimim_plugin"] = s:plugin
    let s:rc["g:Vimim_punctuation"] = 2
    call s:vimim_set_global_default()
    let s:plugin = isdirectory(g:Vimim_plugin) ? g:Vimim_plugin : s:plugin
    let s:plugin = s:plugin[-1:] != "/" ? s:plugin."/" : s:plugin
    let s:dynamic    = {'onekey':0,'windowless':0,'dynamic':1,'static':0}
    let s:static     = {'onekey':0,'windowless':0,'dynamic':0,'static':1}
    let s:onekey     = {'onekey':1,'windowless':0,'dynamic':0,'static':0}
    let s:windowless = {'onekey':0,'windowless':1,'dynamic':0,'static':0}
endfunction

function! s:vimim_dictionary_keycodes()
    let s:keycodes = {}
    for key in split( ' pinyin ')
        let s:keycodes[key] = "['a-z0-9]"
    endfor
    let ime  = ' pinyin_sogou pinyin_quote_sogou pinyin_huge'
    let ime .= ' pinyin_fcitx pinyin_canton pinyin_hongkong'
    let s:all_vimim_input_methods = keys(s:keycodes) + split(ime)
endfunction

function! s:vimim_set_frontend()
    let quote = 'erbi wu nature yong boshiamy'   " quote in datafile
    let s:valid_keyboard = "[0-9a-z']"
    if !empty(s:ui.root)
        let s:valid_keyboard = s:backend[s:ui.root][s:ui.im].keycode
    endif
    let i = 0
    let keycode_string = ""
    while i < 16*16
        if nr2char(i) =~# s:valid_keyboard
            let keycode_string .= nr2char(i)
        endif
        let i += 1
    endwhile
    let s:valid_keys = split(keycode_string, '\zs')
    let s:wubi = 0
    let s:ui.quote = match(split(quote),s:ui.im) < 0 ? 0 : 1
    let s:gi_dynamic = s:ui.im =~ 'pinyin' || s:ui.root =~ 'cloud' ? 0 : 1
    let logo = s:chinese('dscj')
    let tail = s:mode.windowless ? s:today : ''
    if s:mode.dynamic || s:mode.static
        let logo = s:chinese('chinese',s:mode.static?'static':'dynamic')
        let tail = s:chinese('halfwidth')
        if g:Vimim_punctuation > 0 && s:toggle_punctuation > 0
            let tail = s:chinese('fullwidth')
        endif
    endif
    let g:Vimim = "VimIM".s:space.logo.' '.s:vimim_im_chinese().' '.tail
    call s:vimim_set_title(g:Vimim)
endfunction

function! s:vimim_set_global_default()
    let s:vimimrc = []
    let s:vimimdefaults = []
    for variable in keys(s:rc)
        if exists(variable)
            let value = string(eval(variable))
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimrc, '    ' . vimimrc)
        else
            let value = string(s:rc[variable])
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimdefaults, '  " ' . vimimrc)
        endif
        exe 'let '. variable .'='. value
    endfor
endfunction

function! s:vimim_cache()
    let results = []
    if !empty(s:pageup_pagedown)
        let length = len(s:match_list)
        if length > &pumheight
            let page = s:pageup_pagedown * &pumheight
            let partition = page ? page : length+page
            let B = s:match_list[partition :]
            let A = s:match_list[: partition-1]
            let results = B + A
        endif
    elseif s:touch_me_not
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  user interface   ==== {{{"]
" =================================================

function! s:vimim_dictionary_statusline()
    let one  = " dscj taijima 4corner boshiamy input cjk nature"
    let two  = " 点石成金,點石成金 新世纪,新世紀 太极码,太極碼"
    let two .= " 四角号码,四角號碼 呒虾米,嘸蝦米 输入,輸入"
    let two .= " 标准字库,標準字庫 自然码,自然碼"
    let one .= " computer database option flypy network env "
    let one .= " encoding ms static dynamic erbi hangul xinhua"
    let one .= " zhengma cangjie yong wu "
    let two .= " 电脑,電腦 词库,詞庫 选项,選項 小鹤,小鶴 联网,聯網 云,雲 "
    let two .= " 环境,環境 编码,編碼 微软,微軟 静态,靜態 动态,動態"
    let two .= " 二笔,二筆 五笔,五筆 韩文,韓文 新华,新華 郑码,鄭碼"
    let two .= " 仓颉,倉頡 永码,永碼 吴语,吳語 极点,極點 双拼,雙拼"
    let one .= " hit fullwidth halfwidth english chinese purple plusplus"
    let one .= " quick pin pinyin phonetic array30"
    let one .= " abc revision date google baidu sogou qq "
    let two .= " 打 全角 半角 英文 中文 紫光 加加 速成 海峰 自己的 98"
    let two .= " 拼 拼音 注音 行列 智能 版本 日期 谷歌 百度 搜狗 ＱＱ"
    let s:chinese_statusline = s:vimim_key_value_hash(one, two)
endfunction

function! s:vimim_dictionary_punctuations()
    let s:antonym = " 〖〗 （） 《》 【】 ‘’ “”"
    let one =       " { }  ( )  < >  [  ] "
    let two = join(split(join(split(s:antonym)[:3],''),'\zs'))
    let antonyms = s:vimim_key_value_hash(one, two)
    let one = " ,  . "
    let two = " ， 。 "
    let mini_punctuations = s:vimim_key_value_hash(one, two)
    let one = " @  :  #  &  %  $  !  =  ;  ?  *  +  -  ~  ^    _    "
    let two = " 　 ： ＃ ＆ ％ ￥ ！ ＝ ； ？ ﹡ ＋ － ～ …… —— "
    let most_punctuations = s:vimim_key_value_hash(one, two)
    call extend(most_punctuations, antonyms)
    let s:key_evils = { '\' : "、", "'" : "‘’", '"' : "“”" }
    let s:all_evils = {}   " all punctuations for onekey_evils
    call extend(s:all_evils, mini_punctuations)
    call extend(s:all_evils, most_punctuations)
    let s:punctuations = {}
    if g:Vimim_punctuation > 0   " :let g:Vimim_punctuation = 1
        call extend(s:punctuations, mini_punctuations)
    endif
    if g:Vimim_punctuation > 1   " :let g:Vimim_punctuation = 2
        call extend(s:punctuations, most_punctuations)
    endif
endfunction

function! g:Vimim_bracket(offset)
    let cursor = ""
    let range = col(".") - 1 - s:starts.column
    let repeat_times = range / s:multibyte + a:offset
    if repeat_times
        let cursor = repeat("\<Left>\<Delete>", repeat_times)
    elseif repeat_times < 1
        let cursor = strpart(getline("."), s:starts.column, s:multibyte)
    endif
    return cursor
endfunction

function! s:vimim_get_label(label)
    let labeling = a:label == 10 ? "0" : a:label
    if s:mode.onekey && a:label < 11
        let label2 = a:label < 2 ? "_" : get(s:abcd,a:label-1)
        let labeling = empty(labeling) ? '10' : labeling . label2
    endif
    return labeling
endfunction

function! s:vimim_set_pumheight()
    let &completeopt = s:mode.windowless ? 'menu' : 'menuone'
    let &pumheight = s:pumheights.saved
    if empty(&pumheight)
        let &pumheight = 5
        if s:mode.onekey || len(s:valid_keys) > 28
            let &pumheight = 10
        endif
    endif
    let &pumheight = s:mode.windowless ? 1 : &pumheight
    let s:pumheights.current = copy(&pumheight)
    if s:touch_me_not
        let &pumheight = 0
    endif
endfunction

" ============================================= }}}
let s:VimIM += [" ====  statusline       ==== {{{"]
" =================================================

function! s:vimim_set_title(title)
    if &laststatus < 2
        let &titlestring = a:title
        redraw
    endif
    if &term == 'screen'
        if s:mode.windowless
           let &l:statusline = '%{"'. a:title .'"}%<'
        else
           let &l:statusline = g:Vimim .' %h%m%r%=%-14.(%l,%c%V%) %P %<%f'
        endif
    endif
endfunction

function! s:vimim_im_chinese()
    if empty(s:ui.im)
        return "==broken python interface to vim=="
    endif
    let backend = s:backend[s:ui.root][s:ui.im]
    let title = has_key(s:keycodes, s:ui.im) ? backend.chinese : ''
    return title
endfunction

function! s:vimim_windowless_titlestring(cursor)
    let logo = "VimIM"
    let west = s:all_evils['[']
    let east = s:all_evils[']']
    let title = substitute(s:windowless_title, west.'\|'.east, ' ', 'g')
    if title !~ '\s\+' . "'" . '\+\s\+'
        let title = substitute(title,"'",'','g')
    endif
    let title = substitute(title, '\s\*\=\d\=\s', ' ', '')
    let words = split(title)[1:]
    let cursor = s:cursor_at_windowless + a:cursor
    let hightlight = get(words, cursor)
    if !empty(hightlight) && len(words) > 1
        let west  = join(words[1 : cursor-1]) . west
        let east .= join(words[cursor+1 :])
        let s:cursor_at_windowless = cursor
        let keyboard = get(words,0)=='0' ? "" : get(words,0)
        let star = len(s:english.line) ? '*' : ''
        if empty(s:mode.windowless) || empty(s:cjk.filename)
            let logo .= s:space . s:vimim_im_chinese()
        endif
        let logo .= ' '. keyboard .' '. star . west . hightlight . east
    endif
    sil!call s:vimim_set_title(logo)
endfunction

function! g:Vimim_esc()
    let key = nr2char(27)  "  <Esc> is <Esc> if onekey or windowless
    if s:mode.windowless || s:mode.onekey
    elseif pumvisible()
        let key = g:Vimim_one_key_correction() " <Esc> as correction
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  lmap imap nmap   ==== {{{"]
" =================================================

function! g:Vimim_cycle_vimim()
    if len(s:cjk.filename)  " backdoor to cycle all 4 vimim modes
        let s:mode = s:mode.windowless ? s:onekey  :
                   \ s:mode.onekey     ? s:dynamic :
                   \ s:mode.dynamic    ? s:static  : s:windowless
    elseif s:mode.onekey || s:mode.windowless
        let s:mode = s:mode.onekey ? s:windowless : s:onekey
    elseif s:mode.static || s:mode.dynamic
        let s:toggle_punctuation = (s:toggle_punctuation + 1) % 2
    endif
    let s:hit_and_run = 0
    sil!call s:vimim_set_frontend()
    sil!call s:vimim_set_keyboard_maps()
    return ""
endfunction

function! g:Vimim_label(key)
    let key = a:key
    if pumvisible()
        let n = match(s:abcd, key)
        if key =~ '\d'
            let n = key < 1 ? 9 : key - 1
        endif
        let yes = repeat("\<Down>", n). '\<C-Y>'
        let omni = '\<C-R>=g:Vimim()\<CR>'
        if s:mode.onekey
            if s:vimim_cjk() && a:key =~ '\d'
                let yes = ''
            elseif s:hit_and_run || a:key =~ '\d'
                let omni = s:vimim_stop()
            endif
        endif
        if len(yes)
            sil!call s:vimim_reset_after_insert()
        endif
        let key = yes . omni
    elseif s:mode.windowless && key =~ '\d'
        let key = s:vimim_windowless(key)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_page(key)
    let key = a:key
    if pumvisible()
        let page = '\<C-E>\<C-R>=g:Vimim()\<CR>'
        if key =~ '[][]'
            let left  = key == "]" ? "\<Left>"  : ""
            let right = key == "]" ? "\<Right>" : ""
            let _ = key == "]" ? 0 : -1
            let backspace = '\<C-R>=g:Vimim_bracket('._.')\<CR>'
            let key = '\<C-Y>' . left . backspace . right
        elseif key =~ '[=.]'
            let s:pageup_pagedown = &pumheight ? 1 : 0
            let key = &pumheight ? page : '\<PageDown>'
        elseif key =~ '[-,]'
            let s:pageup_pagedown = &pumheight ? -1 : 0
            let key = &pumheight ? page : '\<PageUp>'
        endif
    elseif key =~ "[][=-]" && empty(s:mode.onekey)
        let key = g:Punctuation(key)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Wubi()
    if s:gi_dynamic_on
        let s:gi_dynamic_on = 0 | return ""
    endif
    let key = pumvisible() || s:mode.windowless && s:omni ? '\<C-E>' : ""
    if s:wubi && empty(len(get(split(s:keyboard),0))%4)
        let key = pumvisible() ? '\<C-Y>' : s:mode.windowless ? "" : key
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_punctuation_maps()
    for _ in keys(s:all_evils)
        if _ !~ s:valid_keyboard
            exe 'lnoremap<buffer><expr> '._.' g:Punctuation("'._.'")'
        endif
    endfor
    if empty(s:ui.quote)
        lnoremap<buffer> ' <C-R>=g:Vimim_single_quote()<CR>
    endif
    if g:Vimim_punctuation == 3
        lnoremap<buffer>    "     <C-R>=g:Vimim_double_quote()<CR>
        lnoremap<buffer> <Bslash> <C-R>=g:Vimim_bslash()<CR>
    endif
endfunction

function! g:Punctuation(key)
    let key = a:key
    if s:toggle_punctuation > 0
        if pumvisible() || getline(".")[col(".")-2] !~ '\w'
            if has_key(s:punctuations, a:key)
                let key = s:punctuations[a:key]
            endif
        endif
    endif
    if pumvisible()        " the 2nd choice
        let key = a:key == ";" ? '\<C-N>\<C-Y>' : '\<C-Y>' . key
    elseif s:mode.windowless && s:gi_dynamic
        let key = a:key == ";" ? '\<C-N>' : key
        call g:Vimim_space()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_single_quote()
    let key = "'"
    if pumvisible()       " the 3rd choice
        let key = '\<C-N>\<C-N>\<C-Y>'
    elseif s:mode.windowless && s:gi_dynamic
        let key = '\<C-N>\<C-N>'
        call g:Vimim_space()
    elseif g:Vimim_punctuation < 3
        return key
    elseif s:toggle_punctuation > 0
        let pairs = split(s:key_evils[key], '\zs')
        let s:smart_quotes.single += 1
        let key = get(pairs, s:smart_quotes.single % 2)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_double_quote()
    let key = '"'
    if s:toggle_punctuation > 0
        let pairs = split(s:key_evils[key], '\zs')
        let s:smart_quotes.double += 1
        let yes = pumvisible() ? '\<C-Y>' : ""
        let key = yes . get(pairs, s:smart_quotes.double % 2)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_bslash()
    let key = '\'
    if s:toggle_punctuation > 0
        let yes = pumvisible() ? '\<C-Y>' : ""
        let key = yes . s:key_evils[key]
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_tab(gi)
    " (1) Tab in insert mode => start Tab or windowless/onekey
    " (2) Tab in pumvisible  => print out menu
    let key = "\t"
    if empty(len(s:vimim_left()))
    elseif pumvisible() || s:ctrl6
        let @0 = getline(".")  " undo if dump out by accident
        let key = s:vimim_screenshot()
    else
        let s:mode = a:gi? s:windowless : s:onekey
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_windowless(key)
    " workaround to test if active completion
    let key = a:key          " gi \bslash space space
    if s:pattern_not_found   " gi ma space xj space ctrl+u space
    elseif s:vimim_left() && s:keyboard !~ ' ' " gi mmm.. space 7 space
    elseif s:omni " assume completion active
        let key = len(a:key) ? '\<C-E>\<C-R>=g:Vimim()\<CR>' : '\<C-N>'
        let cursor = empty(len(a:key)) ? 1 : a:key < 1 ? 9 : a:key-1
        if s:vimim_cjk()              " gi ma space isw8ql
        else                          "  234567890 for windowless choice
            let key = a:key =~ '[02-9]' ? repeat('\<C-N>', cursor) : key
        endif
        call s:vimim_windowless_titlestring(cursor)
    else
        call s:vimim_set_title(g:Vimim)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_pagedown()
    let key = ' '
    if pumvisible()
        let s:pageup_pagedown = &pumheight ? 1 : 0
        let key = &pumheight ? g:Vimim() : '\<PageDown>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_space()
    " (1) Space after English (valid keys)    => trigger keycode menu
    " (2) Space after omni popup menu         => insert Chinese
    " (3) Space after pattern not found       => Space
    " (4) Space after chinese windowless      => <C-N> for next match
    " (5) Space after chinese windowless wubi => deactive completion
    let key = " "
    if pumvisible()
        let key = '\<C-R>=g:Vimim()\<CR>'
        if s:mode.onekey && s:hit_and_run
             let key = s:vimim_stop()
        endif
        let cursor = s:mode.static ? '\<C-P>\<C-N>' : ''
        let key = cursor . '\<C-Y>' . key
    elseif s:pattern_not_found
    elseif s:mode.dynamic
    elseif s:mode.static
        let key = s:vimim_left() ? g:Vimim() : key
    elseif s:seamless_positions == getpos(".") " gi ma space enter space
        let s:smart_enter = 0              " Space is Space after Enter
    elseif s:mode.windowless && s:gi_dynamic
        let key = ''                       " gi m space (the 1st choice)
        let s:gi_dynamic_on = 1            " gi m ;     (the 2nd choice)
        call s:vimim_set_title(g:Vimim)     " gi m '     (the 3rd choice)
    endif
    call s:vimim_reset_after_insert()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_enter()
    let s:omni = 0
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        let s:smart_enter = 1  " single Enter after English => seamless
    elseif s:vimim_left() || s:mode.windowless
        let s:smart_enter = 1  " gi ma space enter space space
        if s:seamless_positions == getpos(".")
            let s:smart_enter += 1
        endif
    else
        let s:smart_enter = 0
    endif
    if s:smart_enter == 1
        let s:seamless_positions = getpos(".")
    else
        let key = "\<CR>"      " Enter is Enter after Enter
        let s:smart_enter = 0
    endif
    sil!call s:vimim_set_title(g:Vimim)
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_one_key_correction()
    " :help i_CTRL-U  Delete all entered characters ...
    let key = nr2char(21)
    if s:mode.windowless || s:mode.static && pumvisible()
    elseif pumvisible()
        let range = col(".") - 1 - s:starts.column
        let key = '\<C-E>' . repeat("\<Left>\<Delete>", range)
    endif
    sil!call s:vimim_reset_after_insert()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_backspace()
    " <BS> has special meaning in all 3 states of popupmenu-completion
    let s:omni = 0  " disable active omni completion state
    let key = pumvisible() ? '\<C-R>=g:Vimim()\<CR>' : ''
    let key = '\<Left>\<Delete>' . key
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_screenshot()
    let keyboard = get(split(s:keyboard),0)
    let space = repeat(" ", virtcol(".")-len(keyboard)-1)
    if s:keyboard =~ '^vim'
        let space = ""  " no need to format if it is egg
    elseif !empty(s:keyboard)
        call setline(".", keyboard)
    endif
    let saved_position = getpos(".")
    for items in s:popup_list
        let line = printf('%s', items.word)
        if has_key(items, "abbr")
            let line = printf('%s', items.abbr)
            if has_key(items, "menu")
                let line = printf('%s  %s', items.abbr, items.menu)
            endif
        endif
        put=space.line
    endfor
    call setpos(".", saved_position)
    let key = g:Vimim_esc()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_get_no_quote_head(keyboard)
    let keyboard = a:keyboard
    if keyboard =~ '\d' 
        return keyboard
    endif
    if keyboard =~ '^\l\l\+'."'''".'$'
        " [shoupin] hjkl_m || sssss..  =>  sssss'''  =>  s's's's's
        let keyboard = substitute(keyboard, "'", "", 'g')
        let keyboard = join(split(keyboard,'\zs'), "'")
    endif
    if keyboard =~ "'" && keyboard[-1:] != "'"
        " [quote_by_quote] wo'you'yi'ge'meng
        let keyboards = split(keyboard,"'")
        let keyboard = get(keyboards,0)
        let tail = join(keyboards[1:],"'")
        let tail = len(tail) == 1 ? "'" . tail : tail
        let s:keyboard = keyboard . " " . tail
    endif
    return keyboard
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: chinese    ==== {{{"]
" =================================================

function! g:Vimim_chinese()
    let s:mode = g:Vimim_mode =~ 'static' ? s:static : s:dynamic
    let s:switch = empty(s:ui.frontends) ? -1 : s:switch ? 0 : 1
    return s:switch<0 ? "" : s:switch ? s:vimim_start() : s:vimim_stop()
endfunction

function! s:vimim_set_keyboard_maps()
    let common_punctuations = split("] [ = -")
    let common_labels = s:ui.im =~ 'phonetic' ? [] : range(10)
    let s:gi_dynamic = s:mode.windowless ? s:gi_dynamic : 0
    let both_dynamic = s:mode.dynamic || s:gi_dynamic ? 1 : 0
    if both_dynamic
        for char in s:valid_keys
            sil!exe 'lnoremap<silent><buffer> ' . char . ' ' .
            \ '<C-R>=g:Wubi()<CR>' . char . '<C-R>=g:Vimim()<CR>'
        endfor
    elseif s:mode.static
        for char in s:valid_keys
            sil!exe 'lnoremap<silent><buffer> ' . char . ' ' .  char
        endfor
    else
        let common_punctuations += split(". ,")
        let common_labels += s:abcd[1:]
        let pqwertyuio = s:vimim_cjk() ?  s:qwer : []
        for _ in pqwertyuio + split("h j k l m n / ? s")
        endfor
    endif
    if g:Vimim_punctuation < 0
    elseif both_dynamic || s:mode.static
        sil!call s:vimim_punctuation_maps()
    endif
    for _ in s:mode.windowless ? [] : common_punctuations
        if _ !~ s:valid_keyboard
            sil!exe 'lnoremap<buffer><expr> '._.' g:Vimim_page("'._.'")'
        endif
    endfor
    for _ in common_labels
        sil!exe 'lnoremap<buffer><expr> '._.' g:Vimim_label("'._.'")'
    endfor
endfunction

function! s:vimim_set_im_toggle_list()
    let toggle_list = []
    if g:Vimim_toggle < 0
        let toggle_list = [get(s:ui.frontends,0)]
    elseif empty(g:Vimim_toggle)
        let toggle_list = s:ui.frontends
    else
        for toggle in split(g:Vimim_toggle, ",")
            for [root, im] in s:ui.frontends
                if toggle == im
                    call add(toggle_list, [root, im])
                endif
            endfor
        endfor
    endif
    if s:backend[s:ui.root][s:ui.im].name =~ "bsddb"
        let toggle_list = toggle_list[:2]  " one bsddb two clouds
    endif
    let s:frontends = copy(toggle_list)
    let s:ui.frontends = copy(toggle_list)
    let s:ui.root = get(get(s:ui.frontends,0), 0)
    let s:ui.im   = get(get(s:ui.frontends,0), 1)
endfunction

function! s:vimim_get_seamless(cursor_positions)
    if empty(s:seamless_positions)
    \|| s:seamless_positions[0] != a:cursor_positions[0]
    \|| s:seamless_positions[1] != a:cursor_positions[1]
    \|| s:seamless_positions[3] != a:cursor_positions[3]
        return -1
    endif
    let current_line = getline(a:cursor_positions[1])
    let seamless_column = s:seamless_positions[2]-1
    let len = a:cursor_positions[2]-1 - seamless_column
    let snip = strpart(current_line, seamless_column, len)
    if empty(len(snip))
        return -1
    endif
    for char in split(snip, '\zs')
        if char !~ s:valid_keyboard
            return -1
        endif
    endfor
    return seamless_column
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: number    ==== {{{"]
" =================================================

function! s:vimim_dictionary_numbers()
    let s:loops = {}
    let s:numbers = {}
    let s:numbers.1 = "一壹⑴①甲"
    let s:numbers.2 = "二贰⑵②乙"
    let s:numbers.3 = "三叁⑶③丙"
    let s:numbers.4 = "四肆⑷④丁"
    let s:numbers.5 = "五伍⑸⑤戊"
    let s:numbers.6 = "六陆⑹⑥己"
    let s:numbers.7 = "七柒⑺⑦庚"
    let s:numbers.8 = "八捌⑻⑧辛"
    let s:numbers.9 = "九玖⑼⑨壬"
    let s:numbers.0 = "〇零⑽⑩癸"
    let s:quantifiers = copy(s:numbers)
    let s:quantifiers.2 .= "两俩"
    let s:quantifiers.b = "百佰步把包杯本笔部班"
    let s:quantifiers.c = "次餐场串处床"
    let s:quantifiers.d = "第度点袋道滴碟顶栋堆对朵堵顿"
    let s:quantifiers.f = "分份发封付副幅峰方服"
    let s:quantifiers.g = "个根股管"
    let s:quantifiers.h = "行盒壶户回毫"
    let s:quantifiers.j = "斤家具架间件节剂具捲卷茎记"
    let s:quantifiers.k = "克口块棵颗捆孔"
    let s:quantifiers.l = "里粒类辆列轮厘领缕"
    let s:quantifiers.m = "米名枚面门秒"
    let s:quantifiers.n = "年"
    let s:quantifiers.p = "磅盆瓶排盘盆匹片篇撇喷"
    let s:quantifiers.q = "千仟群"
    let s:quantifiers.r = "日人"
    let s:quantifiers.s = "十拾时升艘扇首双所束手"
    let s:quantifiers.t = "天吨条头通堂趟台套桶筒贴"
    let s:quantifiers.w = "万位味碗窝晚微"
    let s:quantifiers.x = "席些项"
    let s:quantifiers.y = "月元叶亿"
    let s:quantifiers.z = "种只张株支总枝盏座阵桩尊则站幢宗兆"
endfunction

let s:translators = {}
function! s:translators.translate(english) dict
    let inputs = split(a:english)
    return join(map(inputs,'get(self.dict,tolower(v:val),v:val)'), '')
endfunction

function! s:vimim_imode_today_now(keyboard)
    let one  = " year sunday monday tuesday wednesday thursday"
    let one .= " friday saturday month day hour minute second"
    let two  = join(split("年 日 一 二 三 四 五 六"), " 星期")
    let two .= " 月 日 时 分 秒"
    let chinese = copy(s:translators)
    let chinese.dict = s:vimim_key_value_hash(one, two)
    let time  = '公元'
    let time .= strftime("%Y") . ' year  '
    let time .= strftime("%m") . ' month '
    let time .= strftime("%d") . ' day   '
    if a:keyboard ==# 'itoday'
        let time .= s:space .' '. strftime("%A")
    elseif a:keyboard ==# 'inow'
        let time .= strftime("%H") . ' hour   '
        let time .= strftime("%M") . ' minute '
        let time .= strftime("%S") . ' second '
    endif
    let filter = "substitute(" . 'v:val' . ",'^0','','')"
    return chinese.translate(join(map(split(time), filter)))
endfunction

function! s:vimim_imode_number(keyboard)
    let keyboard = a:keyboard
    let ii = keyboard[0:1]   " sample: i88 ii88 isw8ql iisw8ql
    let keyboard = ii==#'ii' ? keyboard[2:] : keyboard[1:]
    let dddl = keyboard=~#'^\d*\l\{1}$' ? keyboard[:-2] : keyboard
    let number = ""
    let keyboards = split(dddl, '\ze')
    for char in keyboards
        if has_key(s:quantifiers, char)
            let quantifier_list = split(s:quantifiers[char], '\zs')
            let chinese = get(quantifier_list, 0)
            if ii ==# 'ii' && char =~# '[0-9sbq]'
                let chinese = get(quantifier_list, 1)
            endif
            let number .= chinese
        endif
    endfor
    if empty(number) | return [] | endif
    let results = [number]
    let last_char = keyboard[-1:]
    if !empty(last_char) && has_key(s:quantifiers, last_char)
        let quantifier_list = split(s:quantifiers[last_char], '\zs')
        if keyboard =~# '^[ds]\=\d*\l\{1}$'
            if keyboard =~# '^[ds]'
                let number = strpart(number,0,len(number)-s:multibyte)
            endif
            let results = map(copy(quantifier_list), 'number . v:val')
        elseif keyboard =~# '^\d*$' && len(keyboards)<2 && ii != 'ii'
            let results = quantifier_list
        endif
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: unicode   ==== {{{"]
" =================================================

function! s:vimim_i18n(line)
    let line = a:line
    if s:localization == 1
        return iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        return iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

function! s:vimim_unicode_list(ddddd)
    let results = []
    for i in range(99)
        call add(results, nr2char(a:ddddd+i))
    endfor
    return results
endfunction

function! s:vimim_get_unicode_ddddd(keyboard)
    let ddddd = 0
    if a:keyboard =~# '^u\x\{4}$'        "  u9f9f => 40863
        let ddddd = str2nr(a:keyboard[1:],16)
    elseif a:keyboard =~# '^\d\{5}$'     "  39532 => 39532
        let ddddd = str2nr(a:keyboard, 10)
    endif
    let max = &encoding=="utf-8" ? 19968+20902 : 0xffff
    if ddddd < 8080 || ddddd > max
        let ddddd = 0
    endif
    return ddddd
endfunction

function! s:vimim_unicode_to_utf8(xxxx)
    let utf8 = ''       " u808f => 32911 => e8828f
    let ddddd = str2nr(a:xxxx, 16)
    if ddddd < 128
        let utf8 .= nr2char(ddddd)
    elseif ddddd < 2048
        let utf8 .= nr2char(192+((ddddd-(ddddd%64))/64))
        let utf8 .= nr2char(128+(ddddd%64))
    else
        let utf8 .= nr2char(224+((ddddd-(ddddd%4096))/4096))
        let utf8 .= nr2char(128+(((ddddd%4096)-(ddddd%64))/64))
        let utf8 .= nr2char(128+(ddddd%64))
    endif
    return utf8
endfunction

function! s:vimim_url_xx_to_chinese(xx)
    let output = a:xx   " %E9%A6%AC => \xE9\xA6\xAC => 馬 u99AC
    if s:http_exe =~ 'libvimim'
        let output = libcall(s:http_exe, "do_unquote", output)
    else
        let pat = '%\(\x\x\)'
        let sub = '\=eval(''"\x''.submatch(1).''"'')'
        let output = substitute(output, pat, sub, 'g')
    endif
    return output
endfunction

function! s:vimim_rot13(keyboard)
    let a = "12345abcdefghijklmABCDEFGHIJKLM"
    let z = "98760nopqrstuvwxyzNOPQRSTUVWXYZ"
    return tr(a:keyboard, a.z, z.a)
endfunction

function! s:vimim_left()
    let key = 0   " validate the character on the left of the cursor
    let one_byte_before = getline(".")[col(".")-2]
    if one_byte_before =~ '\s' || empty(one_byte_before)
        let key = ""
    elseif one_byte_before =~# s:valid_keyboard
        let key = 1
    endif
    return key
endfunction

function! s:vimim_key_value_hash(single, double)
    let hash = {}
    let singles = split(a:single)
    let doubles = split(a:double)
    for i in range(len(singles))
        let hash[get(singles,i)] = get(doubles,i)
    endfor
    return hash
endfunction

function! s:chinese(...)
    let chinese = ""
    for english in a:000
        let cjk = english
        if has_key(s:chinese_statusline, english)
            let twins = split(s:chinese_statusline[english], ",")
            let cjk = get(twins, 0)
            if len(twins) > 1 && s:mandarin
                let cjk = get(twins,1)
            endif
        endif
        let chinese .= cjk
    endfor
    return chinese
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: cjk       ==== {{{"]
" =================================================

function! s:vimim_cjk()
    if empty(s:cjk.filename)
        return 0
    elseif empty(s:cjk.lines)
        let s:cjk.lines = s:vimim_readfile(s:cjk.filename)
        if len(s:cjk.lines) != 20902 | return 0 | endif
    endif
    return 1
endfunction

function! s:vimim_cjk_in_4corner(chinese, info)
    let digit_head = ""  " gi ma   马　 =>   7712  <=>  mali 7 4
    let digit_tail = ""  " gi mali 马力 => 7 4002  <=>  mali74
    let chinese = substitute(a:chinese,'[\x00-\xff]','','g')
    for cjk in split(chinese, '\zs')
        let line = match(s:cjk.lines, "^" . cjk)
        if line > -1
            let values = split(get(s:cjk.lines, line))
            let digit_head .= get(values,1)[:0]
            let digit_tail  = get(values,1)[1:]
        endif
    endfor
    let key = digit_head . digit_tail
    return key
endfunction

function! s:vimim_cjk_property(chinese)
    let ddddd = char2nr(a:chinese)
    let xxxx  = printf('u%04x', ddddd)
    let unicode = ddddd . s:space . xxxx
    if s:vimim_cjk()
        let unicode = repeat(s:space,3) . xxxx . s:space . ddddd
        let line = match(s:cjk.lines, "^" . a:chinese)
        if line > -1
            let values  = split(get(s:cjk.lines, line))
            let digit   = get(values, 1) . s:space
            let frequency = get(values, -1) !~ '\D' ? 1 : 0
            let pinyin  = join(frequency ? values[2:-2] : values[2:])
            let unicode = digit . xxxx . s:space . pinyin
        endif
    endif
    return unicode
endfunction

function! s:vimim_cjk_match(key)
    let key = a:key
    if empty(key) || empty(s:vimim_cjk()) | return [] | endif
    let grep = ""
    let grep_frequency = '.*' . '\s\d\+$'
    if key =~ '\d'
        if key =~# '^\l\l\+[1-4]\>'
            let grep = key . '[a-z ]'  " cjk pinyin: huan2hai2 yi1
        else
            let digit = ""
            if key =~ '^\d\+' && key !~ '[^0-9]'
                let digit = key        " free style digit: 7 77 771 7712
            elseif key =~# '^\l\+\d\+' " free style: ma7 ma77 ma771 ma7712
                let digit = substitute(key,'\a','','g')
            endif
            if !empty(digit)
                let space = '\d\{' . string(4-len(digit)) . '}'
                let space = len(digit)==4 ? "" : space
                let grep = '\s\+' . digit . space . '\s'
                let alpha = substitute(key,'\d','','g')
                if len(alpha)
                    let grep .= '\(\l\+\d\)\=' . alpha " le|yue: le4yue4
                elseif len(key) == 1
                    let grep .= grep_frequency   " grep l|y: happy music
                endif
            endif
        endif
    elseif s:ui.im != 'mycloud'
        if len(key) == 1   " one cjk by frequency y72/yue72 l72/le72
            let grep = '[ 0-9]' . key . '\l*\d' . grep_frequency
            let grep = key == 'u' ? ' u\( \|$\)' : grep  " 214 unicode
        elseif key =~# '^\l\+'  " cjk list: /huan /hai /yet /huan2 /hai2
            let grep = '[ 0-9]' . key . '[0-9]'
        endif
    endif
    let results = []
    if !empty(grep)
        let line = match(s:cjk.lines, grep)
        while line > -1
            let fields = split(get(s:cjk.lines, line))
            let frequency = get(fields,-1)=~'\l' ? 9999 : get(fields,-1)
            call add(results, get(fields,0) . ' ' . frequency)
            let line = match(s:cjk.lines, grep, line+1)
        endwhile
    endif
    let results = sort(results, "s:vimim_sort_on_last")
    let filter = "strpart(" . 'v:val' . ", 0, s:multibyte)"
    return map(results, filter)
endfunction

function! s:vimim_get_cjk_head(key)
    let key = a:key
    if empty(s:cjk.filename) || key =~ "'" | return "" | endif
    if key =~# '^i' && empty (s:english.line) " iuuqwuqew => 77127132
        let key = s:vimim_qwertyuiop_1234567890(key[1:])
    endif
    let head = ""
    if s:touch_me_not || len(key) == 1
        let head = key
    elseif key =~ '\d'
        if key =~ '^\d' && key !~ '\D'
            let head = len(key) > 4 ? s:vimim_get_head(key, 4) : key
        elseif key =~# '^\l\+\d\+\>'         " 7712 in 77124002
            let partition = match(key,'\d')  " ma7 ma77 ma771
            let head = key[0 : partition-1]  " mali in mali74
            let tail = key[partition :]      "   74 in mali74
            if empty(s:vimim_get_pinyin(head)) && tail =~ '[1-4]'
                return key  " pinyin with tone: ma1/ma2/ma3/ma4
            endif
        elseif key =~# '^\l\+\d\+'  " wo23 for input wo23you40
            let partition = match(key, '\(\l\+\d\+\)\@<=\D')
            let head = s:vimim_get_head(key, partition)
        endif
    elseif empty(s:english.line) " muuqwxeyqpjeqqq => m7712x3610j3111
        if key =~# '^\l' && len(key)%5 < 1  " awwwr/a2224 arrow color
            let dddd = s:vimim_qwertyuiop_1234567890(key[1:4])
            if !empty(dddd)
                let key = key[0:0] . dddd . key[5:-1]
                let head = s:vimim_get_head(key, 5)
            endif
        else
            let head = key  " get single character from cjk
        endif
    endif
    return head
endfunction

function! s:vimim_get_head(keyboard, partition)
    if a:partition < 0 | return a:keyboard | endif
    let head = a:keyboard[0 : a:partition-1]
    if s:keyboard !~ '\S\s\S'
        let s:keyboard = head
        let tail = a:keyboard[a:partition : -1]
        if !empty(tail)
            let s:keyboard = head . " " . tail
        endif
    endif
    return head
endfunction

function! s:vimim_qwertyuiop_1234567890(keyboard)
    if a:keyboard =~ '\d' | return "" | endif
    let dddd = ""   " output is 7712 for input uuqw
    for char in split(a:keyboard, '\zs')
        let digit = match(s:qwer, char)
        if digit < 0
            return ""
        else
            let dddd .= digit
        endif
    endfor
    return dddd
endfunction

function! s:vimim_sort_on_last(line1, line2)
    let line1 = get(split(a:line1),-1) + 1
    let line2 = get(split(a:line2),-1) + 1
    if line1 < line2
        return -1
    elseif line1 > line2
        return 1
    endif
    return 0
endfunction

function! s:vimim_chinese_transfer() range abort
    " the quick and dirty way to transfer between Chinese
    if s:vimim_cjk()
        exe a:firstline.",".a:lastline.'s/./\=s:vimim_1to1(submatch(0))'
    endif
endfunction

function! s:vimim_1to1(char)
    if a:char =~ '[\x00-\xff]' | return a:char | endif
    let grep = '^' . a:char
    let line = match(s:cjk.lines, grep, 0)
    if line < 0 | return a:char | endif
    let values = split(get(s:cjk.lines, line))
    let traditional_chinese = get(split(get(values,0),'\zs'),1)
    return empty(traditional_chinese) ? a:char : traditional_chinese
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: english   ==== {{{"]
" =================================================

function! s:vimim_get_english(keyboard)
    if empty(s:english.filename)
        return ""     " english: obama/now/version/ice/o2
    elseif empty(s:english.lines)
        let s:english.lines = s:vimim_readfile(s:english.filename)
    endif             " [sql] select english from vimim.txt
    let grep = '^' . a:keyboard . '\s\+'
    let cursor = match(s:english.lines, grep)
    let keyboards = s:vimim_get_pinyin(a:keyboard)
    if cursor < 0 && len(a:keyboard) > 3 && len(keyboards)
        let grep = '^' . get(split(a:keyboard,'\d'),0) " mxj7 => mxj
        let cursor = match(s:english.lines, grep)
    endif
    let oneline = ""  " [pinyin]  cong  => cong
    if cursor > -1    " [english] congr => congratulation
        let oneline = get(s:english.lines, cursor)
        if a:keyboard != get(split(oneline),0)
            let pairs = split(oneline)   " haag haagendazs
            let oneline = join(pairs[1:] + pairs[:0])
            let oneline = a:keyboard . " " . oneline
        endif
    endif
    return oneline
endfunction

function! s:vimim_filereadable(filename)
    let datafile_1 = s:plugin . a:filename
    let datafile_2 = s:plugon . a:filename
    if filereadable(datafile_1)
        return datafile_1
    elseif filereadable(datafile_2)
        return datafile_2
    endif
    return ""
endfunction

function! s:vimim_readfile(datafile)
    let lines = []
    if filereadable(a:datafile)
        if s:localization
            for line in readfile(a:datafile)
                call add(lines, s:vimim_i18n(line))
            endfor
        else
            return readfile(a:datafile)
        endif
    endif
    return lines
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: pinyin    ==== {{{"]
" =================================================

function! s:vimim_get_all_valid_pinyin_list()
return split(" 'a 'ai 'an 'ang 'ao ba bai ban bang bao bei ben beng bi
\ bian biao bie bin bing bo bu ca cai can cang cao ce cen ceng cha chai
\ chan chang chao che chen cheng chi chong chou chu chua chuai chuan
\ chuang chui chun chuo ci cong cou cu cuan cui cun cuo da dai dan dang
\ dao de dei deng di dia dian diao die ding diu dong dou du duan dui dun
\ duo 'e 'ei 'en 'er fa fan fang fe fei fen feng fiao fo fou fu ga gai
\ gan gang gao ge gei gen geng gong gou gu gua guai guan guang gui gun
\ guo ha hai han hang hao he hei hen heng hong hou hu hua huai huan huang
\ hui hun huo 'i ji jia jian jiang jiao jie jin jing jiong jiu ju juan
\ jue jun ka kai kan kang kao ke ken keng kong kou ku kua kuai kuan kuang
\ kui kun kuo la lai lan lang lao le lei leng li lia lian liang liao lie
\ lin ling liu long lou lu luan lue lun luo lv ma mai man mang mao me mei
\ men meng mi mian miao mie min ming miu mo mou mu na nai nan nang nao ne
\ nei nen neng 'ng ni nian niang niao nie nin ning niu nong nou nu nuan
\ nue nuo nv 'o 'ou pa pai pan pang pao pei pen peng pi pian piao pie pin
\ ping po pou pu qi qia qian qiang qiao qie qin qing qiong qiu qu quan
\ que qun ran rang rao re ren reng ri rong rou ru ruan rui run ruo sa sai
\ san sang sao se sen seng sha shai shan shang shao she shei shen sheng
\ shi shou shu shua shuai shuan shuang shui shun shuo si song sou su suan
\ sui sun suo ta tai tan tang tao te teng ti tian tiao tie ting tong tou
\ tu tuan tui tun tuo 'u 'v wa wai wan wang wei wen weng wo wu xi xia
\ xian xiang xiao xie xin xing xiong xiu xu xuan xue xun ya yan yang yao
\ ye yi yin ying yo yong you yu yuan yue yun za zai zan zang zao ze zei
\ zen zeng zha zhai zhan zhang zhao zhe zhen zheng zhi zhong zhou zhu
\ zhua zhuai zhuan zhuang zhui zhun zhuo zi zong zou zu zuan zui zun zuo")
endfunction

function! s:vimim_quanpin_transform(pinyin)
    if empty(s:quanpin_table)
        for key in s:vimim_get_all_valid_pinyin_list()
            if key[0] == "'"
                let s:quanpin_table[key[1:]] = key[1:]
            else
                let s:quanpin_table[key] = key
            endif
        endfor
        for shengmu in s:shengmu_list + split("zh ch sh")
            let s:quanpin_table[shengmu] = shengmu
        endfor
    endif
    let item = a:pinyin
    let index = 0   " follow ibus rule, plus special case for fan'guo
    let pinyinstr = ""
    while index < len(item)
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(s:quanpin_table, matchstr)
                let tempstr  = item[end-1 : end]
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                \ || (tempstr == "ne" && tempstr3 != "ner")
                \ || (tempstr4 == "gong" || tempstr3 == "gou")
                \ || (tempstr4 == "nong" || tempstr3 == "nou")
                \ || (tempstr  == "ga"   || tempstr == "na")
                \ ||  tempstr2 == "ier"  || tempstr == "ni"
                \ ||  tempstr == "gu"    || tempstr == "nu"
                    if has_key(s:quanpin_table, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . s:quanpin_table[matchstr]
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
    return pinyinstr[0] == "'" ? pinyinstr[1:] : pinyinstr
endfunction

function! s:vimim_more_pinyin_datafile(keyboard, sentence)
    let results = []
    let backend = s:backend[s:ui.root][s:ui.im]
    for candidate in s:vimim_more_pinyin_candidates(a:keyboard)
        let pattern = '^' . candidate . '\>'
        let cursor = match(backend.lines, pattern, 0)
        if cursor < 0
            continue
        elseif a:sentence
            return [candidate]
        endif
        let oneline = get(backend.lines, cursor)
        call extend(results, s:vimim_make_pairs(oneline))
    endfor
    return results
endfunction

function! s:vimim_get_pinyin(keyboard)
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

function! s:vimim_more_pinyin_candidates(keyboard)
    " make standard menu layout:  mamahuhu => mamahu, mama
    if len(s:english.line) || s:ui.im !~ 'pinyin'
        return []
    endif
    let candidates = []
    let keyboards = s:vimim_get_pinyin(a:keyboard)
    if len(keyboards)
        for i in reverse(range(len(keyboards)-1))
            let candidate = join(keyboards[0 : i], "")
            if !empty(candidate)
                call add(candidates, candidate)
            endif
        endfor
        if len(candidates) > 2
            let candidates = candidates[0 : len(candidates)-2]
        endif
    endif
    return candidates
endfunction

" ============================================= }}}
let s:VimIM += [" ====  python2 python3  ==== {{{"]
" =================================================

function! s:vimim_initialize_bsddb(datafile)
:sil!python << EOF
import vim
encoding = vim.eval("&encoding")
datafile = vim.eval('a:datafile')
try:
    import bsddb3 as bsddb
except ImportError:
    import bsddb as bsddb
edw = bsddb.btopen(datafile,'r')
def getstone(stone):
    if stone not in edw:
        while stone and stone not in edw: stone = stone[:-1]
    return stone
def getgold(stone):
    gold = stone
    if stone and stone in edw:
         gold = edw.get(stone)
         if encoding == 'utf-8':
               if datafile.find("gbk"):
                   gold = unicode(gold,'gb18030','ignore')
                   gold = gold.encode(encoding,'ignore')
    gold = stone + ' ' + gold
    return gold
EOF
endfunction

function! s:vimim_get_stone_from_bsddb(stone)
:sil!python << EOF
try:
    stone = vim.eval('a:stone')
    marble = getstone(stone)
    vim.command("return '%s'" % marble)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
return ""
endfunction

function! s:vimim_get_gold_from_bsddb(stone)
:sil!python << EOF
try:
    gold = getgold(vim.eval('a:stone'))
    vim.command("return '%s'" % gold)
except vim.error:
    print("vim error: %s" % vim.error)
EOF
return ""
endfunction


" ============================================= }}}
let s:VimIM += [" ====  backend: file    ==== {{{"]
" =================================================

function! s:vimim_set_datafile(im, datafile)
    let im = a:im
    if isdirectory(a:datafile) | return
    elseif im =~ '^pinyin'     | let im = 'pinyin' | endif
    let s:ui.root = 'datafile'
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.datafile[im] = {}
    let s:backend.datafile[im].root = s:ui.root
    let s:backend.datafile[im].im = s:ui.im
    let s:backend.datafile[im].name = a:datafile
    let s:backend.datafile[im].keycode = s:keycodes[im]
    let s:backend.datafile[im].chinese = s:chinese(im)
    let s:backend.datafile[im].lines = []
endfunction

function! s:vimim_sentence_datafile(keyboard)
    let backend = s:backend[s:ui.root][s:ui.im]
    let fuzzy = s:ui.im =~ 'pinyin' ? ' ' : ""
    let pattern = '^\V' . a:keyboard . fuzzy
    let cursor = match(backend.lines, pattern)
    if cursor > -1 | return a:keyboard | endif
    let candidates = s:vimim_more_pinyin_datafile(a:keyboard,1)
    if !empty(candidates) | return get(candidates,0) | endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1
        let pattern = '^\V' . strpart(a:keyboard,0,max) . ' '
        let cursor = match(backend.lines, pattern)
        if cursor > -1 | break | endif
    endwhile
    return cursor < 0 ? "" : a:keyboard[: max-1]
endfunction

function! s:vimim_get_from_datafile(keyboard)
    let fuzzy = s:ui.im =~ 'pinyin' ? ' ' : ""
    let pattern = '^\V' . a:keyboard . fuzzy
    let backend = s:backend[s:ui.root][s:ui.im]
    let cursor = match(backend.lines, pattern)
    if cursor < 0 | return [] | endif
    let oneline = get(backend.lines, cursor)
    let results = split(oneline)[1:]
    if len(s:english.line) || len(results) > 10
        return results
    endif
    if s:ui.im =~ 'pinyin'
        let extras = s:vimim_more_pinyin_datafile(a:keyboard,0)
        let results = s:vimim_make_pairs(oneline) + extras
    else  " http://code.google.com/p/vimim/issues/detail?id=121
        let results = []
        let s:show_extra_menu = 1
        for i in range(10)
            let cursor += i      " get more if less
            let oneline = get(backend.lines, cursor)
            let results += s:vimim_make_pairs(oneline)
        endfor
    endif
    return results
endfunction

function! s:vimim_get_from_database(keyboard)
    let oneline = s:vimim_get_gold_from_bsddb(a:keyboard)
    if empty(oneline) | return [] | endif
    let results = s:vimim_make_pairs(oneline)
    if empty(s:english.line) && len(results) && len(results) < 20
        for candidate in s:vimim_more_pinyin_candidates(a:keyboard)
            let oneline = s:vimim_get_gold_from_bsddb(candidate)
            if empty(oneline) || match(oneline,' ')<0 | continue | endif
            let results += s:vimim_make_pairs(oneline)
            if len(results) > 20*2 | break | endif
        endfor
    endif
    return results
endfunction

function! s:vimim_make_pairs(oneline)
    if empty(a:oneline) || match(a:oneline,' ') < 0
        return []
    endif
    let oneline_list = split(a:oneline)
    let menu = remove(oneline_list, 0)
    let results = []
    for chinese in oneline_list
        call add(results, menu .' '. chinese)
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: dir     ==== {{{"]
" =================================================

function! s:vimim_set_directory(dir)
    let im = "pinyin"
    let s:ui.root = 'directory'
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.directory[im] = {}
    let s:backend.directory[im].root = s:ui.root
    let s:backend.directory[im].im = im
    let s:backend.directory[im].name = a:dir
    let s:backend.directory[im].keycode = s:keycodes[im]
    let s:backend.directory[im].chinese = s:chinese(im)
endfunction

function! s:vimim_sentence_directory(keyboard, directory)
    let filename = a:directory . a:keyboard
    if filereadable(filename) | return a:keyboard | endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1 " workaround: filereadable("/filename.") return true
        let head = strpart(a:keyboard, 0, max)
        let filename = a:directory . head
        if filereadable(filename) && head[-1:-1] != "." | break | endif
    endwhile
    return filereadable(filename) ? a:keyboard[: max-1] : ""
endfunction

function! s:vimim_set_backend_embedded()
    " (1/3) scan pinyin directory database
    let dir = s:plugin . "pinyin"  " always test ../plugin/pinyin/pinyin
    if isdirectory(dir)
        if filereadable(dir . "/pinyin")
            return s:vimim_set_directory(dir . "/")
        endif
    endif
    " (2/3) scan bsddb database as edw: enterprise data warehouse
    if has("python") " bsddb is from Python 2 only with 46,694,400 Bytes
        let datafile = s:vimim_filereadable("vimim.gbk.bsddb")
        if !empty(datafile)
            return s:vimim_set_datafile("pinyin", datafile)
        endif
    endif
    " (3/3) scan all supported data files, in order
    for im in s:all_vimim_input_methods
        let datafile = s:vimim_filereadable("vimim." . im . ".txt")
        if empty(datafile)
            let filename = "vimim." . im . "." . &encoding . ".txt"
            let datafile = s:vimim_filereadable(filename)
        endif
        if !empty(datafile)
            call s:vimim_set_datafile(im, datafile)
        endif
    endfor
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

function! s:vimim_start()
    sil!call s:vimim_save_vimrc()
    sil!call s:vimim_set_vimrc()
    sil!call s:vimim_set_frontend()
    sil!call s:vimim_set_keyboard_maps()
    lnoremap <silent><buffer> <expr> <BS>    g:Vimim_backspace()
    lnoremap <silent><buffer> <expr> <Esc>   g:Vimim_esc()
    lnoremap <silent><buffer> <expr> <C-U>   g:Vimim_one_key_correction()
    lnoremap <silent><buffer> <expr> <C-L>   g:Vimim_cycle_vimim()
    if s:ui.im =~ 'array'
        lnoremap <silent><buffer> <expr> <CR>    g:Vimim_space()
        lnoremap <silent><buffer> <expr> <Space> g:Vimim_pagedown()
    else
        lnoremap <silent><buffer> <expr> <CR>    g:Vimim_enter()
        lnoremap <silent><buffer> <expr> <Space> g:Vimim_space()
    endif
    let key = ''
    if empty(s:ctrl6)
        let s:ctrl6 = 32911
        let key = nr2char(30)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_stop()
    if has("gui_running")
        lmapclear
    endif
    let key = nr2char(30) " i_CTRL-^
    let s:ui.frontends = copy(s:frontends)
    sil!call s:vimim_restore_vimrc()
    sil!call s:vimim_super_reset()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_save_vimrc()
    let s:cpo         = &cpo
    let s:omnifunc    = &omnifunc
    let s:complete    = &complete
    let s:completeopt = &completeopt
    let s:statusline  = &statusline
    let s:lazyredraw  = &lazyredraw
endfunction

function! s:vimim_set_vimrc()
    set title noshowmatch shellslash
    set completeopt=menuone
    set complete=.
    set nolazyredraw
    set omnifunc=VimIM
endfunction

function! s:vimim_restore_vimrc()
    let &cpo         = s:cpo
    let &omnifunc    = s:omnifunc
    let &complete    = s:complete
    let &completeopt = s:completeopt
    let &statusline  = s:statusline
    let &lazyredraw  = s:lazyredraw
    let &titlestring = s:titlestring
    let &pumheight   = s:pumheights.saved
endfunction

function! s:vimim_super_reset()
    sil!call s:vimim_reset_before_anything()
    sil!call s:vimim_reset_before_omni()
    sil!call s:vimim_reset_after_insert()
endfunction

function! s:vimim_reset_before_anything()
    let s:mode = s:onekey
    let s:keyboard = ""
    let s:omni = 0
    let s:ctrl6 = 0
    let s:switch = 0
    let s:toggle_im = 0
    let s:smart_enter = 0
    let s:gi_dynamic_on = 0
    let s:toggle_punctuation = 1
    let s:popup_list = []
endfunction

function! s:vimim_reset_before_omni()
    let s:english.line = ""
    let s:touch_me_not = 0
    let s:show_extra_menu = 0
    let s:cursor_at_windowless = 0
endfunction

function! s:vimim_reset_after_insert()
    let s:match_list = []
    let s:pageup_pagedown = 0
    let s:pattern_not_found = 0

    " 缓存上次的坐标
    let s:cache_last_column = -1
    let s:cache_last_row = -1
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core engine      ==== {{{"]
" =================================================

function! VimIM(start, keyboard)
let valid_keyboard = s:valid_keyboard
if a:start
    let cursor_positions = getpos(".")
    let start_row = cursor_positions[1]
    let start_column = cursor_positions[2]-1
    " 如果在翻页后，光标位置没有改动，表示没有新的输入，
    " 否则，重置缓存
    let results = s:vimim_cache()
    "echom "c" . s:cache_last_row . " " . s:cache_last_column
    "echom "s" . start_row . " " . start_column
    if !empty(results) && s:cache_last_row == start_row && s:cache_last_column != start_column
        " 重置缓存
        "echom "reset cache"
        sil!call s:vimim_reset_before_omni()
        sil!call s:vimim_reset_after_insert()
    else
        let s:cache_last_row = start_row
        let s:cache_last_column = start_column
    endif
    let current_line = getline(start_row)
    let before = current_line[start_column-1]
    let seamless_column = s:vimim_get_seamless(cursor_positions)
    if seamless_column < 0
        let s:seamless_positions = []
        let last_seen_bslash_column = copy(start_column)
        let last_seen_nonsense_column = copy(start_column)
        let all_digit = 1
        while start_column
            if before =~# valid_keyboard
                let start_column -= 1
                if before !~# "[0-9']" || s:ui.im =~ 'phonetic'
                    let last_seen_nonsense_column = start_column
                    let all_digit = all_digit ? 0 : all_digit
                endif
            elseif before == '\' " do nothing if leading bslash found
                let s:pattern_not_found = 1
                return last_seen_bslash_column
            elseif before =~# '[A-Z]' " do nothing if found Abcd
                let s:pattern_not_found = 1
                return last_seen_bslash_column
            else
                break
            endif
            let before = current_line[start_column-1]
        endwhile
        if all_digit < 1 && current_line[start_column] =~ '\d'
            let start_column = last_seen_nonsense_column
        endif
    else
        let start_column = seamless_column
    endif
    let len = cursor_positions[2]-1 - start_column
    let keyboard = strpart(current_line, start_column, len)
    if s:keyboard !~ '\S\s\S'
        let s:keyboard = keyboard
    endif
    let s:starts.column = start_column
    return start_column
else
    if s:omni < 0  "  one_key_correction
        return [s:space]
    endif
    " 如果进入选词的模式，即进行翻页，cache 中就会有值
    " 但请注意，如果选词+翻页+输入新的字母，就会以后问题
    let results = s:vimim_cache()
    if empty(results)
        sil!call s:vimim_reset_before_omni()
    else
        return s:vimim_popupmenu_list(results)
    endif
    " 进到这里，说明要进行词语匹配，而不是翻页
    let keyboard = a:keyboard
    if !empty(str2nr(keyboard)) " for digit input: 23554022100080204420
        let keyboard = get(split(s:keyboard),0)
    endif
    if empty(keyboard) || keyboard !~ valid_keyboard
        return []
    else   " [english] first check if it is english or not
        let s:english.line = s:vimim_get_english(keyboard)
    endif
    "echom "s:english.line: " . s:english.line
    "echom "s:mode.onekey: " . s:mode.onekey
    "echom "s:mode.windowless: " . s:mode.windowless
    if s:mode.onekey || s:mode.windowless
        let results = []
        if empty(results) && s:vimim_cjk()
            let head = s:vimim_get_no_quote_head(keyboard)
            let head = s:vimim_get_cjk_head(head)
            let results = !empty(head) ? s:vimim_cjk_match(head) : []
        endif
        if len(results)
            return s:vimim_popupmenu_list(results)
        elseif get(split(s:keyboard),1) =~ "'"  " ssss.. for cloud
            let keyboard = s:vimim_get_no_quote_head(keyboard)
        endif
    endif
    "echom "results: " . len(results)
    " 首先查找内置的引擎
    if empty(results)
        let results = s:vimim_embedded_backend_engine(keyboard)
    endif
    "echom "results: " . len(results)
    " 如果有英文匹配，追加结果
    if len(s:english.line)
        let s:keyboard = s:keyboard !~ "'" ? keyboard : s:keyboard
        let results = s:vimim_make_pairs(s:english.line) + results
    endif
    if empty(results)  " [the_last_resort] force shoupin or force cloud
        if s:mode.onekey || s:mode.windowless
            if len(keyboard) > 1
                let shoupin = s:vimim_get_no_quote_head(keyboard."'''")
                let results = s:vimim_cjk_match(shoupin)
            else
                let results = [keyboard == 'i' ? "我" : s:space]
            endif
        elseif s:mode.static
            let s:pattern_not_found = 1
        endif
    endif
    "echom "最后要返回的 results " . string(results)
    return s:vimim_popupmenu_list(results)
endif
endfunction

function! s:vimim_popupmenu_list(lines)
    let s:match_list = a:lines
    "echom "进入函数 s:vimim_popupmenu_list: " 
    "echom "s:keyboard: " . string(s:keyboard)
    let keyboards = split(s:keyboard)  " mmmm => ['m',"m'm'm"]
    let keyboard = join(keyboards,"")
    let keyboard_left = get(keyboards,0)
    " 这个时候的 tail 应该只适合于当前所选的词条
    let tail = len(keyboards) < 2 ? "" : get(keyboards,1)
    if empty(a:lines) || type(a:lines) != type([])
        return []
    endif
    let label = 1
    let one_list = []
    let s:popup_list = []
    " 开始循环
    for chinese in s:match_list
        "echom "循环: " . chinese
        let complete_items = {}
        let titleline = s:vimim_get_label(label)
        "echom "  titleline: " . titleline
        if empty(s:touch_me_not)
            let menu = ""
            let pairs = split(chinese)
            " pair_left 应该是拼音部分，例如
            "     zhongwen 中文
            "     zhong 中
            let pair_left = get(pairs,0)
            if len(pairs) > 1 && pair_left !~ '[^\x00-\xff]'
                " 应该把 keyboard 中的 pair_left 扣除,
                " 这样就可以把剩下的字符添加到汉字尾部
                let temptail = substitute(keyboard_left, pair_left,'','g')
                "echom "    temptail: " . temptail 
                let chinese = get(pairs,1).temptail
                let menu = s:show_extra_menu ? pair_left : menu
            endif
            let label2 = s:english.line =~ chinese ? '*' : ' '
            let titleline = printf('%3s ', label2 . titleline)
            let chinese .= empty(tail) || tail == "'" ? '' : tail
            let complete_items["abbr"] = titleline . chinese
            let complete_items["menu"] = menu
            "echom "complete_items: ".string(complete_items)
        endif
        if s:mode.windowless
            if s:vimim_cjk() " display sexy english and dynamic 4corner
                let star = substitute(titleline,'[0-9a-z_ ]','','g')
                let digit = s:vimim_cjk_in_4corner(chinese,1) " ma7 712
            elseif label < 11   " 234567890 for windowless selection
                let titleline = label == 10 ? "0" : label
            endif
            call add(one_list, titleline . chinese)
        endif
        let label += 1
        let complete_items["dup"] = 1
        let complete_items["word"] = empty(chinese) ? s:space : chinese
        call add(s:popup_list, complete_items)
    endfor
    if s:mode.windowless
        let s:windowless_title = 'VimIM ' . keyboard .' '. join(one_list)
        call s:vimim_windowless_titlestring(1)
    endif
    call s:vimim_set_pumheight()
    Debug s:match_list[:1]
    return s:popup_list
endfunction

function! s:vimim_embedded_backend_engine(keyboard)
    let keyboard = a:keyboard
    if empty(s:ui.im) || empty(s:ui.root)
        return []
    endif
    "echom "核心代码"
    let head = 0
    let results = []
    let backend = s:backend[s:ui.root][s:ui.im]
    "echom string(backend)
    if backend.name =~ "quote" && keyboard !~ "[']" " has apostrophe
        let keyboard = s:vimim_quanpin_transform(keyboard)
    endif
    if s:ui.root =~# "directory"
        let head = s:vimim_sentence_directory(keyboard, backend.name)
        let results = s:vimim_readfile(backend.name . head)
        if keyboard ==# head && len(results) && len(results) < 20
            let extras = []
            for candidate in s:vimim_more_pinyin_candidates(keyboard)
                let lines = s:vimim_readfile(backend.name . candidate)
                let extras += map(lines, 'candidate." ".v:val')
            endfor
            let results = extras + map(results, 'keyboard." ".v:val')
        endif
    elseif s:ui.root =~# "datafile"
        if backend.name =~ "bsddb"
            if empty(backend.lines)
                let backend.lines = ["4MB_in_memory_46MB_on_disk"]
                sil!call s:vimim_initialize_bsddb(backend.name)
            endif
            " 这里返回的 head 要怎么用才好呢?
            let head = s:vimim_get_stone_from_bsddb(keyboard)
            "echom "head: " . head
            " head 与 results 中的开头不一定匹配
            if !empty(head)
                let results = s:vimim_get_from_database(head)
            endif
            "echom "results: " . string(results)
        else
            if empty(backend.lines)
                let backend.lines = s:vimim_readfile(backend.name)
            endif
            let head = s:vimim_sentence_datafile(keyboard)
            let results = s:vimim_get_from_datafile(head)
        endif
    endif
    if s:keyboard !~ '\S\s\S'
        "echom "这时的 s:keyboard 为: " . s:keyboard
        "echom "同时 head 为: " . head
        " 这时的 s:keyboard 为: zhongwenru
        " 同时 head 为: zhongwen
        "
        " 请注意，由数据库中可以返回的 head 其实应该不止一个
        " 这就导致吃单词了
        "
        " head 应该取决于当前所选的单词
        if empty(head)
            let s:keyboard = keyboard
        elseif len(head) < len(keyboard)
            let tail = strpart(keyboard,len(head))
            let s:keyboard = head . " " . tail
        endif
        "echom "更新后 s:keyboard 为: " . s:keyboard
        "echom "更新后 head 为: " . head
        " 更新后 s:keyboard 为: zhongwen ru
        " 更新后 head 为: zhongwen
        "
        " 我的想法是，这个时候不应该更新，而是应该等到选词的时候
    endif
    "echom "return results: " . string(results)
    return results
endfunction

function! g:Vimim()
    let s:omni = s:omni < 0 ? -1 : 0  " one_key_correction
    let s:keyboard = empty(s:pageup_pagedown) ? "" : s:keyboard
    let key = s:vimim_left() ? '\<C-X>\<C-O>\<C-R>=g:Omni()\<CR>' : ""
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Omni()
    let s:omni = s:omni < 0 ? 0 : 1 " as if omni completion pattern found
    let key = s:mode.static ? '\<C-N>\<C-P>' : '\<C-P>\<Down>'
    let key = pumvisible() ? key : ""
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

function! s:vimim_plug_and_play()
    nnoremap <silent> <C-_> i<C-R>=g:Vimim_chinese()<CR><Esc>
    inoremap <unique> <C-_>  <C-R>=g:Vimim_chinese()<CR>
    if g:Vimim_map =~ 'c-bslash'      " use Ctrl-\  ''
        imap <C-Bslash> <C-_>
        nmap <C-Bslash> <C-_>
    elseif g:Vimim_map =~ 'c-space'   " use Ctrl-Space
        if has("win32unix")
            nmap <C-@> <C-_>
            imap <C-@> <C-_>
        else
            imap <C-Space> <C-_>
            nmap <C-Space> <C-_>
        endif
    elseif g:Vimim_map =~ 'm-space'   " use Alt-Space
        imap <M-Space> <C-_>
        nmap <M-Space> <C-_>
    endif
    if g:Vimim_map =~ 'tab'           " use Tab
        xmap <silent> <Tab> <C-^>
        if g:Vimim_map =~ 'tab_as_gi'
            inoremap <silent> <Tab> <C-R>=g:Vimim_tab(1)<CR>
        elseif g:Vimim_map =~ 'tab_as_onekey'
            inoremap <silent> <Tab> <C-R>=g:Vimim_tab(0)<CR>
        endif
    endif
    :com! -range=% VimIM <line1>,<line2>call s:vimim_chinese_transfer()
    :com! -nargs=* Debug :sil!call s:vimim_debug(<args>)
endfunction

sil!call s:vimim_initialize_debug()
sil!call s:vimim_initialize_global()
sil!call s:vimim_initialize_backdoor()
sil!call s:vimim_dictionary_statusline()
sil!call s:vimim_dictionary_punctuations()
sil!call s:vimim_dictionary_numbers()
sil!call s:vimim_dictionary_keycodes()
sil!call s:vimim_super_reset()
sil!call s:vimim_set_backend_embedded()
sil!call s:vimim_set_im_toggle_list()
sil!call s:vimim_plug_and_play()
:let g:Vimim_profile = reltime(g:Vimim_profile)
" ============================================= }}}
