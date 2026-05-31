return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- Neovim起動完了後に遅延ロード
  config = function()
    require("which-key").setup({
      -- 設定はとりあえずデフォルトでOK
      -- 表示されるまでの時間など、細かくカスタマイズも可能
    })
  end,
}

