return {
    "coder/claudecode.nvim",
    opts = {
        auto_start = true,
        -- ターミナル統合は tmux ペインで運用するため無効
        -- 有効にしたい場合はコメントを外す:
        terminal = {
            provider = "none",
        },
        diff_opts = {
            open_in_new_tab = true,
        },
    },
    keys = {
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",      desc = "Add current buffer to Claude Code" },
        -- 選択範囲を Claude Code へ送信
        { "<leader>as", "<cmd>ClaudeCodeSend<cr>",       mode = "v",                                desc = "Claude Code: Send Selection" },
        -- diff レビュー
        { "<leader>ad", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code: Accept Diff" },
        { "<leader>aD", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude Code: Deny Diff" },
        -- ターミナルトグル（tmux運用中は不要、必要なら有効化）
        -- { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code: Toggle Terminal" },
    },
}
