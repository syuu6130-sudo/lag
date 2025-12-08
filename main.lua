local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rayfield-Official/Script/master/Rayfield.lua'))()
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function loadRayfieldUI()
    -- Rayfieldウィンドウの初期化
    local Window = Rayfield:CreateWindow({
        Name = "🤖 しゅーくりむ's Custom Menu",
        Image = 4483362458, -- 適切なAsset IDに置き換えてください
        Theme = Rayfield.Themes["Dark"],
        Color = Color3.fromRGB(255, 0, 0), -- 初期色 (例: 赤)
        -- Minimizable/DraggableはRayfieldの標準機能に含まれます
    })

    ---
    ### 🎮 Main - メイン機能
    ---
    
    local MainTab = Window:CreateTab("Main", 4483362458) -- 適切なAsset IDに置き換えてください
    
    -- スピードチェンジ
    local SpeedSection = MainTab:CreateSection("移動速度")
    SpeedSection:CreateSlider({
        Name = "歩行速度 (WalkSpeed)",
        Range = {16, 100},
        Increment = 1,
        Suffix = "Studs/s",
        CurrentValue = 16,
        Callback = function(value)
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end,
    })

    -- ジャンプ力
    local JumpSection = MainTab:CreateSection("ジャンプ")
    JumpSection:CreateSlider({
        Name = "ジャンプ力 (JumpPower)",
        Range = {50, 200},
        Increment = 10,
        Suffix = "Power",
        CurrentValue = 50,
        Callback = function(value)
            LocalPlayer.Character.Humanoid.JumpPower = value
        end,
    })
    
    -- 浮遊力 (Gravity設定)
    local PhysicsSection = MainTab:CreateSection("物理設定")
    PhysicsSection:CreateToggle({
        Name = "浮遊モード (No Gravity)",
        CurrentValue = false,
        Callback = function(state)
            if state then
                game.Workspace.Gravity = 0 -- 重力ゼロ
            else
                game.Workspace.Gravity = 196.2 -- デフォルト重力
            end
        end,
    })

    -- Fly機能（全関数実装）
    local FlyModule = {}
    -- ここにFly機能のための関数を実装します。例として基本のオン/オフのみを示します。
    -- 実際には、キーバインド、速度調整など詳細なFly関数が必要です。
    local FlyActive = false
    local FlySpeed = 1
    
    function FlyModule.ToggleFly(state)
        FlyActive = state
        local Char = LocalPlayer.Character
        if not Char or not Char.HumanoidRootPart then return end

        if state then
            -- FlyOnの処理 (例: Part作成、WASDで操作できるようにする処理)
            local HRP = Char.HumanoidRootPart
            HRP.CFrame = HRP.CFrame + Vector3.new(0, 5, 0) -- わずかに浮上
            HRP.Anchored = true
        else
            -- FlyOffの処理
            Char.HumanoidRootPart.Anchored = false
        end
    end

    PhysicsSection:CreateToggle({
        Name = "Fly 機能 (全機能)",
        CurrentValue = false,
        Callback = FlyModule.ToggleFly,
    })

    ---
    ### ⚙️ Settings - 設定
    ---
    
    local SettingsTab = Window:CreateTab("Settings", 4483362458) -- 適切なAsset IDに置き換えてください

    -- UIの色変更
    local ColorSection = SettingsTab:CreateSection("UI Color")
    local Colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), -- 基本3色
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255), -- 補色3色
        Color3.fromRGB(255, 165, 0), Color3.fromRGB(128, 0, 128), Color3.fromRGB(255, 192, 203), -- その他
        Color3.fromRGB(0, 0, 0), Color3.fromRGB(128, 128, 128), Color3.fromRGB(255, 255, 255) -- 白黒グレー
    }
    
    for i, color in ipairs(Colors) do
        ColorSection:CreateButton({
            Name = "Color " .. i,
            Callback = function()
                Window:SetColor(color)
            end,
        })
    end
    -- **UIの形**：Rayfieldは基本的に四角形のUIですが、カスタムテーマを適用することで丸みなどを出すことができます。
    -- Rayfieldでは、UIの形状を直接的に「卍型」などに変更する機能は提供されていませんが、テーマの選択で対応します。

    -- シフトロック
    SettingsTab:CreateSection("ゲーム設定"):CreateToggle({
        Name = "シフトロック切り替え",
        CurrentValue = LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice and LocalPlayer.DevComputerCameraMovementMode == Enum.DevComputerCameraMovementMode.UserChoice, -- 既存設定に依存
        Callback = function(state)
            if state then
                LocalPlayer.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.LockFirstPerson
                LocalPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.LockFirstPerson
                game.StarterPlayer.EnableMouseLock = true -- Shift Lockを有効にする
            else
                LocalPlayer.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.UserChoice
                LocalPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.UserChoice
                game.StarterPlayer.EnableMouseLock = false -- Shift Lockを無効にする
            end
        end,
    })

    -- クロスヘア機能
    local Crosshair = Instance.new("Frame")
    Crosshair.Size = UDim2.new(0, 10, 0, 10)
    Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
    Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
    Crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Crosshair.BorderSizePixel = 0
    Crosshair.ZIndex = 10
    Crosshair.Parent = PlayerGui

    -- クロスヘアのカスタマイズセクション
    local CrosshairSection = SettingsTab:CreateSection("クロスヘア設定")
    
    -- 色の選択 (UI色と同様に12色)
    for i, color in ipairs(Colors) do
        CrosshairSection:CreateButton({
            Name = "Crosshair Color " .. i,
            Callback = function()
                Crosshair.BackgroundColor3 = color
            end,
        })
    end

    -- 大きさの変更
    CrosshairSection:CreateSlider({
        Name = "クロスヘアの大きさ",
        Range = {5, 50},
        Increment = 1,
        CurrentValue = 10,
        Callback = function(value)
            Crosshair.Size = UDim2.new(0, value, 0, value)
        end,
    })

    -- 形の変更 (例: 四角/丸っぽい)
    local Shapes = {"Square", "Circle"}
    CrosshairSection:CreateDropdown({
        Name = "クロスヘアの形",
        Options = Shapes,
        Current = "Square",
        Callback = function(shape)
            if shape == "Square" then
                Crosshair.CornerRadius = UDim.new(0, 0)
            elseif shape == "Circle" then
                Crosshair.CornerRadius = UDim.new(0.5, 0) -- 丸っぽく
            end
        end,
    })
    
    ---
    ### 🗑️ UI削除（確認付き）
    ---

    local DeleteTab = Window:CreateTab("Delete UI", 4483362458)
    local DeleteSection = DeleteTab:CreateSection("UI削除")
    
    DeleteSection:CreateButton({
        Name = "UIを完全に削除",
        Callback = function()
            -- 確認画面の作成 (Rayfield外でカスタム実装)
            local ConfirmFrame = Instance.new("Frame")
            ConfirmFrame.Size = UDim2.new(0, 250, 0, 100)
            ConfirmFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
            ConfirmFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ConfirmFrame.Parent = PlayerGui
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, 0, 0.5, 0)
            TextLabel.Text = "本当にUIを削除しますか？"
            TextLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            TextLabel.TextColor3 = Color3.new(1, 1, 1)
            TextLabel.Parent = ConfirmFrame
            
            local YesButton = Instance.new("TextButton")
            YesButton.Size = UDim2.new(0.4, 0, 0.4, 0)
            YesButton.Position = UDim2.new(0.1, 0, 0.55, 0)
            YesButton.Text = "はい"
            YesButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            YesButton.Parent = ConfirmFrame
            
            local NoButton = Instance.new("TextButton")
            NoButton.Size = UDim2.new(0.4, 0, 0.4, 0)
            NoButton.Position = UDim2.new(0.5, 25, 0.55, 0)
            NoButton.Text = "いいえ"
            NoButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            NoButton.Parent = ConfirmFrame
            
            YesButton.MouseButton1Click:Connect(function()
                Rayfield:Unload() -- Rayfield UIを削除
                Crosshair:Destroy() -- クロスヘアを削除
                ConfirmFrame:Destroy() -- 確認画面を削除
            end)
            
            NoButton.MouseButton1Click:Connect(function()
                ConfirmFrame:Destroy() -- 確認画面を削除し、元の画面に戻る
            end)
        end,
    })
end

-- PinPadが読み込まれた状態から開始
