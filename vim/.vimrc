" simple_vimrc — nvim config から移植した持ち運び用 vimrc
" 使い方: vim -u /path/to/simple_vimrc <file>
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
set background=dark
set mouse=a             " 全モードでマウス有効

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
set cursorline          " カーソル行ハイライト
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

" ===== ファイラー (netrw) =====
let g:netrw_liststyle = 3    " ツリー表示
let g:netrw_banner = 0       " 上部バナーを非表示
let g:netrw_winsize = 25     " Vex の幅を25%に
let g:netrw_browse_split = 4 " ファイルを前のウィンドウ(右側)で開く
let g:netrw_altv = 0         " Vex を左側に開く

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

" Insert モードで jj → Esc
inoremap jj <Esc>

" Insert モードでのカーソル移動
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" x はレジスタを汚さずに削除
nnoremap x "_x

" 折り返し行を1行として j/k 移動
nnoremap j gj
nnoremap k gk

" Shift-H/L で行頭・行末
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" +/- で数値のインクリメント・デクリメント
nnoremap + <C-a>
nnoremap - <C-x>

" ウィンドウ分割
nnoremap <Leader>s :split<CR><C-w>w
nnoremap <Leader>v :vsplit<CR><C-w>w

" ウィンドウ間の移動
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l

" バッファ移動
nnoremap <Leader>p :bprevious<CR>
nnoremap <Leader>n :bnext<CR>
nnoremap <Leader>x :bdelete<CR>

" 検索ハイライトを消す
nnoremap <Esc><Esc> :nohlsearch<CR>

" ファイラーをサイドバーで開く/閉じるトグル
function! ToggleNetrw()
  for i in range(1, winnr('$'))
    if getwinvar(i, '&filetype') ==# 'netrw'
      execute i . 'wincmd w'
      close
      return
    endif
  endfor
  Vexplore
endfunction
nnoremap <Leader>e :call ToggleNetrw()<CR>

" ターミナルを下部に開く
nnoremap <Leader>t :botright terminal<CR>

" ターミナルモードからノーマルモードへ
tnoremap <C-\><C-n> <C-\><C-n>
tnoremap jj <C-\><C-n>
