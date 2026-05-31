-- /lua/custom/snippets.lua
-- カスタムスニペットの定義
local ls = require("luasnip")
-- スニペットの各要素を短い変数に格納
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- コメントスニペットを生成するためのヘルパー関数
local function create_comment_snippet(opts, keyword)
	local trig = opts.trig

	-- 最終的なスニペットの構造を定義して返す
	return s(
		trig,
		fmt("{} {}: {}", {
			-- 1. 現在のファイルタイプに応じたコメント記号を取得
			f(function()
				return vim.split(vim.bo.commentstring, "%s")[1] or ""
			end),
			-- 2. キーワードのテキスト
			t(keyword),
			-- 3. スニペット展開後のカーソル位置
			i(1),
		})
	)
end
--[[
  各コメントプレフィックスの一般的な使い分け

  - TODO: 後でやること、未実装のタスク
    例: 機能追加、リファクタリングの予定など

  - FIX: 修正が必要なバグ、既知の問題
    例: 特定条件下でのクラッシュ、意図しない挙動など

  - HACK: 場当たり的・非理想的な解決策
    例: ライブラリのバグ回避、特殊な環境対応など

  - WARN: 注意喚起、潜在的な危険
    例: 使い方を誤ると問題が起きる関数、非推奨APIの使用など

  - PERF: パフォーマンスに関する懸念、最適化の余地
    例: 処理が遅いループ、アルゴリズムの改善案など

  - NOTE: 補足情報、設計意図の解説
    例: なぜこの実装を選んだのか、複雑なロジックの背景など

  - TEST: テストに関するメモ
    例: テストケースの不足、一時的に無効化しているテストなど
]]
-- 上記のヘルパー関数を使って、スニペットのリストを作成
-- todo-comments.nvimのキーワードに合わせて定義
return {
	create_comment_snippet({ trig = "todo" }, "TODO"),
	create_comment_snippet({ trig = "fix" }, "FIX"),
	create_comment_snippet({ trig = "hack" }, "HACK"),
	create_comment_snippet({ trig = "warn" }, "WARN"),
	create_comment_snippet({ trig = "perf" }, "PERF"),
	create_comment_snippet({ trig = "note" }, "NOTE"),
	create_comment_snippet({ trig = "test" }, "TEST"),
}
