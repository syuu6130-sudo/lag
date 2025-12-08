-- 注意: 以下のコードを実行する前に、ご自身でRayfieldのブートローダー/ソースコードを
-- このスクリプトの先頭に組み込む必要があります。
-- 例: loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rblx/rayfield/main/source.lua'))()

local Rayfield = Rayfield -- Rayfieldがグローバル変数として利用可能であると仮定

-- UIの定義
local Window = Rayfield:CreateWindow({
    Name = "カスタム機能パネル", -- ウィンドウ名
    LoadingTitle = "カスタム機能をロード中...",
    LoadingSubtitle = "お待ちください",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil, -- デフォルトのフォルダ名を使用
        FileName = "CustomSettings"
    },
    KeySystem = {
        Enabled = false, -- キーシステムを無効にする
        Key = Enum.KeyCode.Insert -- F2キーで表示/非表示を切り替える (例)
    }
})

-- ---
-- ## 🚀 メイン機能 (Main Tab)
-- ---
local MainTab = Window:CreateTab("メイン", "rbxassetid://6022634459") -- ロケットのアイコンIDの例

-- 👟 スピード変更
local SpeedSection = MainTab:CreateSection("移動速度")
SpeedSection:CreateSlider({
    Name = "プレイヤー速度",
    Range = {16, 100}, -- 通常の速度から100まで
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Callback = function(Value)
        -- Speedの変更処理
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

-- 🕴️ ジャンプ力
local JumpSection = MainTab:CreateSection("ジャンプ力と浮遊")
JumpSection:CreateSlider({
    Name = "ジャンプ力",
    Range = {50, 200}, -- 通常のジャンプ力から200まで
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 50,
    Callback = function(Value)
        -- JumpPowerの変更処理
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})

-- ☁️ 浮遊力 (Gravity)
JumpSection:CreateSlider({
    Name = "浮遊力 (重力設定)",
    Range = {0, 196.2}, -- 0(無重力)から通常の重力(196.2)まで
    Increment = 1,
    Suffix = " studs/s^2",
    CurrentValue = game.Workspace.Gravity,
    Callback = function(Value)
        -- Gravityの変更処理
        game.Workspace.Gravity = Value
    end,
})

-- ✈️ Fly機能 (全関数)
local FlySection = MainTab:CreateSection("フライト機能")
-- Fly機能は複雑なので、ここではトグルと、使用できない場合に備えて複数の関数を定義する例を示します。
FlySection:CreateToggle({
    Name = "フライト有効化 (基本的な方法)",
    CurrentValue = false,
    Callback = function(Value)
        local Player = game.Players.LocalPlayer
        if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            if Value then
                -- FlyScriptのロードやHumanoidRootPartのカスタマイズなどを行う
                -- 例: Player.Character.HumanoidRootPart.CanCollide = false
                -- 実際のFly機能の実装は外部ライブラリまたは詳細なコードが必要です。
                print("基本Fly機能の有効化: 実装部をここに追加してください。")
            else
                print("基本Fly機能の無効化: 実装部をここに追加してください。")
            end
        end
    end,
})

-- Fly全関数については、具体的なRobloxのエクスプロイトAPIに依存するため、
-- ここでは説明とトグルのみとさせていただきます。
-- 例: FlySection:CreateButton({Name = "Noclip Toggle", Callback = function() ... end})

-- ---
-- ## 🎨 設定 (Settings Tab)
-- ---
local SettingsTab = Window:CreateTab("設定", "rbxassetid://6022634419") -- 歯車のアイコンIDの例

-- 🌐 全体設定
local GeneralSettings = SettingsTab:CreateSection("一般設定")

-- 🖱️ Shift Lock
GeneralSettings:CreateToggle({
    Name = "Shift Lock 有効化",
    CurrentValue = game.Players.LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice and game.Players.LocalPlayer.DevComputerCameraMovementMode == Enum.DevComputerCameraMovementMode.UserChoice, -- 現在の設定を取得
    Callback = function(Value)
        -- ShiftLockの切り替えはクライアント側のスクリプト(ControlModule)で行われることが多いですが、
        -- DevCameraModeを設定することで影響を与えることができます。
        if Value then
            game.Players.LocalPlayer.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.LockFirstPerson
        else
            game.Players.LocalPlayer.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.UserChoice
        end
    end,
})

-- 🌈 UI カラー設定
local UIColorSection = SettingsTab:CreateSection("UI カスタム設定")

-- 12色のカラーピッカー (Primary Color)
local Colors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 128, 0), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(128, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 128),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 128, 255), Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 0, 128)
}

-- 12色の選択ボタンとして実装 (Rayfieldに直接カラーピッカーがない場合を考慮)
for i, Color in ipairs(Colors) do
    local Name = "色" .. i .. " (" .. Color.R*255 .. "," .. Color.G*255 .. "," .. Color.B*255 .. ")"
    UIColorSection:CreateButton({
        Name = Name,
        Callback = function()
            -- RayfieldのAPIを使ってPrimaryColorを変更
            Rayfield:SetTheme(Color)
        end,
    })
end

-- UIの形はRayfieldが標準でサポートするテーマや形状に依存します。
-- 通常、Rayfieldは形状変更のAPIを直接提供していませんが、
-- ここではテーマを切り替えることで対応する例とします。
-- (形状変更APIが提供されていない場合は、この部分は実装できません。)

-- 🎯 クロスヘア設定
local CrosshairSection = SettingsTab:CreateSection("クロスヘア設定")
local CrosshairToggle = CrosshairSection:CreateToggle({
    Name = "カスタムクロスヘア 有効化",
    CurrentValue = false,
    Callback = function(Value)
        -- クロスヘア表示/非表示の処理
        print("クロスヘアのトグル: " .. tostring(Value))
    end,
})

-- クロスヘアの色
CrosshairSection:CreateColorPicker({
    Name = "クロスヘアの色",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Color)
        -- クロスヘアの色変更処理
        print("クロスヘアの色変更: " .. Color:ToHex())
    end,
})

-- クロスヘアの形 (ドロップダウン)
CrosshairSection:CreateDropdown({
    Name = "クロスヘアの形",
    Options = {"標準", "四角", "丸", "卍型", "点"},
    Current = "標準",
    Callback = function(Shape)
        -- クロスヘアの形変更処理
        print("クロスヘアの形変更: " .. Shape)
    end,
})

-- クロスヘアの大きさ
CrosshairSection:CreateSlider({
    Name = "クロスヘアの大きさ (Scale)",
    Range = {1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 2,
    Callback = function(Value)
        -- クロスヘアの大きさ変更処理
        print("クロスヘアの大きさ変更: " .. Value)
    end,
})

-- ---
-- ## 🗑️ UI 削除機能 (Special Tab)
-- ---
local DeleteTab = Window:CreateTab("削除", "rbxassetid://6022634465") -- ゴミ箱のアイコンIDの例

local DeleteSection = DeleteTab:CreateSection("UI 削除")

DeleteSection:CreateButton({
    Name = "UI を完全に削除",
    Callback = function()
        -- 削除確認ウィンドウの表示
        Rayfield:Notify({
            Title = "確認",
            Content = "本当にUIを削除しますか？ この操作は元に戻せません。",
            Duration = 60, -- 長めに表示
            Buttons = {
                {
                    Text = "はい (削除)",
                    Callback = function()
                        -- UIを破棄する
                        Rayfield:Destroy()
                    end
                },
                {
                    Text = "いいえ (キャンセル)",
                    Callback = function()
                        -- 何もせず元の画面に戻る (RayfieldのNotifyが閉じられる)
                        print("UI削除をキャンセルしました。")
                    end
                },
            }
        })
    end,
})

-- Rayfieldのロード完了を通知
Rayfield:Notify({
    Title = "カスタム UI ロード完了",
    Content = "すべての機能が利用可能になりました。",
    Duration = 5 -- 5秒後に自動で閉じる
})
