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
set cmdheight=1
set visualbell          " ビープ音の代わりに画面フラッシュ
set t_vb=               " 画面フラッシュも無効化 (完全無音)

" True Color (ターミナルが対応している場合)
if has('termguicolors')
  set termguicolors
endif

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

" 検索ハイライトを消す (Esc 1回)
nnoremap <silent> <Esc> :nohlsearch<CR>

" カーソル下の単語をファイル全体で一括置換（入力待ち状態にする）
nnoremap <Leader>%s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" `-` で現在のディレクトリをカレントウィンドウに開く (Oil 風)
" 戻るときは netrw 内で `-` (親ディレクトリへ) を使う
nnoremap <silent> - :Explore<CR>

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
