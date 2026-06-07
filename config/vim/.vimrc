" simple_vimrc — nvim 設定からプラグイン依存を排除して持ち運び用にしたvimrc
" 使い方: vim -u /path/to/.vimrc <file>
"         または ~/.vimrc にコピーして使う

" ===== シンタックスハイライト =====
syntax on
filetype plugin indent on

" ===== エンコーディング =====
set encoding=utf-8
set fileencoding=utf-8

" ===== 基本設定 =====
set noswapfile          " スワップファイルを作らない
set hidden              " 未保存バッファのまま他バッファへ切り替え可
set autoread            " 外部で変更されたファイルを自動再読込
set background=dark
set mouse=a             " 全モードでマウス有効
set virtualedit=block   " ビジュアルブロックでカーソルを範囲外に置ける

" ===== 検索 =====
set hlsearch            " 検索結果をハイライト
set incsearch           " インクリメンタル検索
set ignorecase          " 大文字小文字を区別しない
set smartcase           " 大文字を含む場合は区別する

" ===== インデント =====
set shiftwidth=4
set tabstop=4
set expandtab           " タブをスペースに展開
set autoindent

" ===== 表示 =====
set number              " 行番号
set relativenumber      " 相対行番号
set cursorline          " カーソル行ハイライト
if has('patch-8.1.1564')
  set signcolumn=yes    " サインカラムを常に表示 (vim 8.1.1564+)
endif
set wrap                " 折り返し表示
set showmatch           " 対応括弧をハイライト
set matchtime=1         " 括弧ハイライトの時間 (100ms)
set laststatus=2        " ステータスラインを常に表示
set wildmenu            " コマンドライン補完メニュー
set wildignorecase      " 補完で大文字小文字を区別しない
if has('patch-9.0.181')
  set wildoptions=pum,fuzzy   " ポップアップ表示 + ファジーマッチ (Telescope 風)
elseif has('patch-8.2.4325')
  set wildoptions=pum
endif
" :find / :grep が重くならないよう、よくある無関係ディレクトリは除外
set wildignore+=*/.git/*,*/node_modules/*,*/dist/*,*/build/*,*/target/*
set wildignore+=*/__pycache__/*,*/.venv/*,*/.cache/*
set wildignore+=*.pyc,*.o,*.so,*.class,*.png,*.jpg,*.jpeg,*.gif,*.pdf
set cmdheight=1
set visualbell          " ビープ音の代わりに画面フラッシュ
set t_vb=               " 画面フラッシュも無効化 (完全無音)

" ===== カラースキーム =====
" colors/catppuccin_frappe.vim を vimrc と同じディレクトリに置く構成。
" シンボリックリンク経由でも実体の dotfiles リポジトリのパスを解決し、
" そのディレクトリを runtimepath に追加する (~/.config/vim の有無に依存しない)。
" カラースキームファイルは catppuccin/vim リポジトリから vendor (autoload 非依存)。
if has('termguicolors')
  set termguicolors
endif
let s:vimrc_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let &runtimepath = s:vimrc_dir . ',' . &runtimepath

" catppuccin_frappe が無い環境では desert (vim 全バージョン同梱) へフォールバック
silent! colorscheme catppuccin_frappe
if !exists('g:colors_name') || g:colors_name !=# 'catppuccin_frappe'
  silent! colorscheme desert
endif

" ターミナル背景の透過を維持するため、編集領域の塗りつぶしを無効化
" (Ghostty/Alacritty の background-opacity を活かすのが目的)
function! ClearBackgrounds() abort
  hi Normal       guibg=NONE ctermbg=NONE
  hi NormalNC     guibg=NONE ctermbg=NONE
  hi SignColumn   guibg=NONE ctermbg=NONE
  hi LineNr       guibg=NONE ctermbg=NONE
  hi EndOfBuffer  guibg=NONE ctermbg=NONE
endfunction
augroup TransparentBg
  autocmd!
  autocmd ColorScheme,VimEnter * call ClearBackgrounds()
augroup END
call ClearBackgrounds()

" ===== 不可視文字 (インデント・末尾空白を可視化) =====
set list
set listchars=tab:▏\ ,trail:·,nbsp:␣,extends:»,precedes:«

" クリップボード共有 (OS 対応時のみ)
if has('clipboard')
  set clipboard=unnamed,unnamedplus
endif

" ===== ファイラー (netrw — Oil 風に現在のウィンドウで開く) =====
let g:netrw_banner = 0       " 上部バナーを非表示
let g:netrw_liststyle = 0    " シンプルなリスト表示 (Oil 風)
let g:netrw_hide = 0         " 隠しファイルも表示
let g:netrw_list_hide = ''

" :find をサブディレクトリ対応にする
set path+=**

" ===== ステータスライン (lualine 相当 + モード別色付け) =====
function! StatuslineMode() abort
  let modes = {
    \ 'n':  'NORMAL', 'i':  'INSERT', 'v':  'VISUAL', 'V':  'V-LINE',
    \ "\<C-v>": 'V-BLOCK', 'c':  'COMMAND', 'R':  'REPLACE',
    \ 't':  'TERM',   's':  'SELECT'
    \ }
  return get(modes, mode(), mode())
endfunction

" モード別ハイライト (catppuccin Frappe パレットから採色)
function! SetupStatuslineColors() abort
  hi StatusModeNormal  guifg=#232634 guibg=#8caaee gui=bold
  hi StatusModeInsert  guifg=#232634 guibg=#a6d189 gui=bold
  hi StatusModeVisual  guifg=#232634 guibg=#ca9ee6 gui=bold
  hi StatusModeCommand guifg=#232634 guibg=#e78284 gui=bold
  hi StatusModeReplace guifg=#232634 guibg=#ef9f76 gui=bold
  hi StatusModeTerm    guifg=#232634 guibg=#e5c890 gui=bold
endfunction

" mode() の戻り値から対応する %#グループ名# を返す
function! ModeHL() abort
  let m = mode()
  if m ==# 'n'                 | return '%#StatusModeNormal#'
  elseif m ==# 'i'             | return '%#StatusModeInsert#'
  elseif m =~# "[vV\<C-v>]"    | return '%#StatusModeVisual#'
  elseif m ==# 'c'             | return '%#StatusModeCommand#'
  elseif m ==# 'R'             | return '%#StatusModeReplace#'
  elseif m ==# 't'             | return '%#StatusModeTerm#'
  else                         | return '%#StatusModeNormal#'
  endif
endfunction

" colorscheme 読み込み後に高ライト定義を上書き反映する
augroup StatuslineColors
  autocmd!
  autocmd ColorScheme,VimEnter * call SetupStatuslineColors()
augroup END
call SetupStatuslineColors()

" 左: [モードバッジ] / ファイル名 / 編集中マーク
" 右: ファイルタイプ / エンコーディング / 行:列
" %{% ... %} は評価結果を statusline 書式として再解釈させる構文
set statusline=%{%ModeHL()%}\ %{StatuslineMode()}\ %#StatusLine#\ %f\ %m%r
set statusline+=%=
set statusline+=%y\ │\ %{&fileencoding!=''?&fileencoding:&encoding}\ │\ %3l:%-2c

" ===== バッファ一覧をタブラインに常時表示 =====
set showtabline=2

function! MyTabLine()
  let s = ''
  for i in range(1, bufnr('$'))
    if !buflisted(i) | continue | endif
    let name = fnamemodify(bufname(i), ':t')
    if name == '' | let name = '[No Name]' | endif
    let modified = getbufvar(i, '&modified') ? ' +' : ''
    if i == bufnr('%')
      let s .= '%#TabLineSel# ' . name . modified . ' %#TabLineFill#'
    else
      let s .= '%#TabLine# ' . name . modified . ' %#TabLineFill#'
    endif
  endfor
  return s
endfunction

set tabline=%!MyTabLine()

" ===== キーマップ =====
let mapleader = " "

" Insert モードで jj → Esc, C-c も Esc 完全互換
inoremap jj <Esc>
inoremap <C-c> <Esc>

" Insert モードでのカーソル移動
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" x はレジスタを汚さずに削除
nnoremap x "_x

" ビジュアルでペーストしたとき、ヤンク履歴を汚さない
xnoremap p "_dP

" 折り返し行を1行として j/k 移動
nnoremap j gj
nnoremap k gk

" 半ページスクロール時にカーソルを画面中央に保つ
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" 検索の前後移動時にカーソルを中央に保ち、折りたたみを展開する
nnoremap n nzzzv
nnoremap N Nzzzv

" Shift-H/L で行頭・行末
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" ウィンドウ分割
nnoremap <silent> <Leader>s :split<CR><C-w>w
nnoremap <silent> <Leader>v :vsplit<CR><C-w>w

" ウィンドウ間の移動
nnoremap <silent> <Leader>h <C-w>h
nnoremap <silent> <Leader>j <C-w>j
nnoremap <silent> <Leader>k <C-w>k
nnoremap <silent> <Leader>l <C-w>l

" バッファ移動
nnoremap <silent> <Leader>p :bprevious<CR>
nnoremap <silent> <Leader>n :bnext<CR>
nnoremap <silent> <Leader>x :bdelete<CR>

" ===== ファインダ (vim 組み込みのみで Telescope 風) =====
" wildoptions=pum,fuzzy のおかげで Tab を押すとファジーマッチのポップアップが出る。
" <Leader>ff/fb/fh はコマンドを開いた状態で待機。すぐに Tab で候補が出る。
nnoremap <Leader>ff :find<Space>
nnoremap <Leader>fb :buffer<Space>
nnoremap <Leader>fh :help<Space>

" プロジェクト全文検索: 入力したパターンで vimgrep → quickfix に表示
nnoremap <Leader>fg :execute 'silent vimgrep /' . input('grep: ') . '/j **'<Bar>copen<CR>

" 検索ハイライトを消す (Esc 1回)
nnoremap <silent> <Esc> :nohlsearch<CR>

" カーソル下の単語をファイル全体で一括置換（入力待ち状態にする）
nnoremap <Leader>%s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" `-` で現在のディレクトリをカレントウィンドウに開く (Oil 風)
nnoremap <silent> - :Explore<CR>

" netrw 内では `-` を閉じる動作に上書き (デフォの "親ディレクトリへ" を ".." 選択に委譲)
augroup NetrwCloseKey
  autocmd!
  autocmd FileType netrw nnoremap <silent> <buffer> - :Rexplore<CR>
augroup END

" ターミナルをトグル開閉 (nvim の toggleterm.nvim と同じ <C-j>)
" バッファ状態を保持して再表示。vim には floating window で terminal を
" focus する手段が乏しいため、下部分割で代替する。
let s:term_bufnr = -1
function! ToggleTerm()
  " ターミナルバッファが既にウィンドウ表示中なら隠す
  if s:term_bufnr > 0 && bufwinid(s:term_bufnr) > 0
    call win_gotoid(bufwinid(s:term_bufnr))
    hide
    return
  endif
  " 既存バッファがあれば再利用、なければ新規作成
  if s:term_bufnr > 0 && bufexists(s:term_bufnr)
    execute 'botright sbuffer ' . s:term_bufnr
    " 再表示時は terminal-job mode に戻す
    normal! i
  else
    botright terminal
    let s:term_bufnr = bufnr('%')
  endif
endfunction

nnoremap <silent> <C-j> :call ToggleTerm()<CR>
tnoremap <silent> <C-j> <C-w>:call ToggleTerm()<CR>

" ターミナルモードからノーマルモードへ
tnoremap <C-\><C-n> <C-\><C-n>
tnoremap jj <C-\><C-n>
