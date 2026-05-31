return {
  -- 現在のコードチャンクをハイライト
  {
    "shellRaining/hlchunk.nvim",
    event = "VeryLazy",
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          style = {
            -- 背景色を少しだけ暗くしてチャンクを強調
            -- 色はお使いのテーマに合わせて調整してください
            -- { bg = "#282a36" },
          },
        },
        indent = {
          -- インデントガイドの文字
          chars = { "│", "¦", "┆", "┊" },
          style = {
            -- インデントガイドの色を少し明るく
            -- { "gray" },
          },
        },
        blank = {
          enable = false,
        },
      })
    end,
  },
}
