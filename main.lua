-- Rayfield UI Library をロード (Executor経由で実行)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- メインWindow作成
local Window = Rayfield:CreateWindow({
   Name = "カスタムハブ",
   LoadingTitle = "Rayfield UI 読み込み中",
   LoadingSubtitle = "高度な機能搭載",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CustomHub",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- 設定タブ
local SettingsTab = Window:CreateTab("設定", 4483362458)

-- UIカスタマイズセクション
local UiSection = SettingsTab:CreateSection("UI デザイン")

-- UI形状選択
local UiShapeDropdown = SettingsTab:CreateDropdown({
   Name = "UI形状",
   Options = {"四角形", "丸型", "通常", "卍型", "六芒星", "ハート"},
   CurrentOption = "四角形",
   Flag = "UiShape",
   Callback = function(Option)
      -- UI形状変更処理 (CornerRadiusなど)
      local shape = Option
      -- ここでWindow.Frame.CornerRadiusなどを変更
      print("UI形状変更: " .. shape)
   end,
})

-- UI色選択 (12色)
local Colors = {
   "赤", "青", "緑", "黄", "紫", "オレンジ", "ピンク", "白", "黒", "灰色", "水色", "金色"
}

local UiColorDropdown = SettingsTab:CreateDropdown({
   Name = "UI色 (12色)",
   Options = Colors,
   CurrentOption = "白",
   Flag = "UiColor",
   Callback = function(Color)
      local colorMap = {
         ["赤"] = Color3.fromRGB(255,0,0),
         ["青"] = Color3.fromRGB(0,0,255),
         ["緑"] = Color3.fromRGB(0,255,0),
         ["黄"] = Color3.fromRGB(255,255,0),
         ["紫"] = Color3.fromRGB(128,0,255),
         ["オレンジ"] = Color3.fromRGB(255,165,0),
         ["ピンク"] = Color3.fromRGB(255,192,203),
         ["白"] = Color3.fromRGB(255,255,255),
         ["黒"] = Color3.fromRGB(0,0,0),
         ["灰色"] = Color3.fromRGB(128,128,128),
         ["水色"] = Color3.fromRGB(0,191,255),
         ["金色"] = Color3.fromRGB(255,215,0)
      }
      Window.Frame.BackgroundColor3 = colorMap[Color] [web:6]
      print("UI色変更: " .. Color)
   end,
})

-- シフトロック
local ShiftLockToggle = SettingsTab:CreateToggle({
   Name = "シフトロック",
   CurrentValue = false,
   Flag = "ShiftLock",
   Callback = function(Value)
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")
      humanoid.PlatformStand = Value
   end,
})

-- クロスヘアセクション
local CrosshairSection = SettingsTab:CreateSection("クロスヘア設定")

local CrosshairShape = SettingsTab:CreateDropdown({
   Name = "クロスヘア形状",
   Options = {"標準", "卍型", "点", "円", "三角"},
   CurrentOption = "標準",
   Callback = function(Shape)
      print("クロスヘア形状: " .. Shape)
      -- クロスヘアGUI作成/更新
   end,
})

local CrosshairSizeSlider = SettingsTab:CreateSlider({
   Name = "クロスヘアサイズ",
   Range = {1, 50},
   Increment = 1,
   CurrentValue = 10,
   Flag = "CrosshairSize",
   Callback = function(Value)
      print("クロスヘアサイズ: " .. Value)
   end,
})

local CrosshairColor = SettingsTab:CreateDropdown({
   Name = "クロスヘア色",
   Options = Colors,
   CurrentOption = "白",
   Callback = function(Color)
      print("クロスヘア色: " .. Color)
   end,
})

-- Main機能タブ
local MainTab = Window:CreateTab("Main", 4483362458)
local MainSection = MainTab:CreateSection("プレイヤー強化")

-- スピード
local SpeedSlider = MainTab:CreateSlider({
   Name = "移動速度",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "PlayerSpeed",
   Callback = function(Value)
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")
      humanoid.WalkSpeed = Value [web:2]
   end,
})

-- ジャンプ力
local JumpSlider = MainTab:CreateSlider({
   Name = "ジャンプ力",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")
      humanoid.JumpPower = Value
   end,
})

-- 浮遊力
local FloatSlider = MainTab:CreateSlider({
   Name = "浮遊力",
   Range = {0, 100},
   Increment = 1,
   CurrentValue = 0,
   Flag = "BodyVelocity",
   Callback = function(Value)
      -- BodyVelocityで浮遊効果
   end,
})

-- Fly機能 (複数方法)
local FlyToggle = MainTab:CreateToggle({
   Name = "Fly (全機能)",
   CurrentValue = false,
   Flag = "FlyEnabled",
   Callback = function(Value)
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")
      
      if Value then
         -- 方法1: BodyVelocity
         local bv = Instance.new("BodyVelocity")
         bv.MaxForce = Vector3.new(4000,4000,4000)
         bv.Velocity = Vector3.new(0,0,0)
         bv.Parent = character.HumanoidRootPart
         
         -- 方法2: BodyPosition
         local bp = Instance.new("BodyPosition")
         bp.MaxForce = Vector3.new(4000,4000,4000)
         bp.Position = character.HumanoidRootPart.Position
         bp.Parent = character.HumanoidRootPart
         
         -- キー入力で制御
         game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
               bp.Position = bp.Position + Vector3.new(0,5,0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
               bp.Position = bp.Position + Vector3.new(0,-5,0)
            end
         end)
      else
         -- Fly停止
         for _, obj in pairs(character.HumanoidRootPart:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") then
               obj:Destroy() [web:3]
            end
         end
      end
   end,
})

-- UI削除確認ダイアログ
local DeleteSection = SettingsTab:CreateSection("UI管理")

local DeleteButton = SettingsTab:CreateButton({
   Name = "UI削除 (確認付き)",
   Callback = function()
      -- 確認ダイアログ表示
      Rayfield:Notify({
         Title = "確認",
         Content = "本当にUIを削除しますか？",
         Duration = 5,
         Image = 4483362458,
      })
      
      -- 確認ボタン作成（簡易版）
      spawn(function()
         wait(1)
         local ConfirmToggle = SettingsTab:CreateToggle({
            Name = "削除実行",
            CurrentValue = false,
            Callback = function(Value)
               if Value then
                  Rayfield:Destroy() -- UI完全削除 [web:3]
                  print("UIが削除されました")
               end
            end,
         })
      end)
   end,
})

-- 通知
Rayfield:Notify({
   Title = "ロード完了",
   Content = "全ての機能が利用可能になりました！",
   Duration = 3,
   Image = 4483362458,
})
