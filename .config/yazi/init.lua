-- ~/.config/yazi/init.lua

-- プラグイン初期化
require("git"):setup({ order = 1500 }) -- ファイル一覧に git 状態を表示
require("full-border"):setup()         -- 各ペインに枠線を表示

function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%b %d %H:%M", time)
    else
        time = os.date("%b %d  %Y", time)
    end

    local size = self._file:size()
    return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
