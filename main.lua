-- Rayfield UI Libraryの読み込み
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()

-- UIの作成
local Window = Rayfield:CreateWindow({
   Name = "カスタムUI",
   LoadingTitle = "読み込み中...",
   LoadingSubtitle = "Rayfield UI Library",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "設定ファイル"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "キーシステム",
      Subtitle = "キーを入力してください",
      Note = "キーを購入するには...",
      FileName = "キー",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- メインタブ
local MainTab = Window:CreateTab("Main", 4483362458)

-- スピードチェンジ
local SpeedSection = MainTab:CreateSection("移動設定")
local SpeedSlider = MainTab:CreateSlider({
   Name = "スピード倍率",
   Range = {1, 50},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 1,
   Flag = "SpeedMultiplier",
   Callback = function(Value)
       local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
       if humanoid then
           humanoid.WalkSpeed = 16 * Value
       end
   end,
})

-- ジャンプ力
local JumpPowerSlider = MainTab:CreateSlider({
   Name = "ジャンプ力",
   Range = {50, 200},
   Increment = 5,
   Suffix = "パワー",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
       local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
       if humanoid then
           humanoid.JumpPower = Value
       end
   end,
})

-- 浮遊力
local FloatToggle = MainTab:CreateToggle({
   Name = "浮遊",
   CurrentValue = false,
   Flag = "FloatEnabled",
   Callback = function(Value)
       _G.FloatEnabled = Value
       if Value then
           spawn(function()
               while _G.FloatEnabled do
                   wait()
                   local character = game.Players.LocalPlayer.Character
                   if character then
                       local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                       if humanoidRootPart then
                           humanoidRootPart.Velocity = Vector3.new(humanoidRootPart.Velocity.X, 0, humanoidRootPart.Velocity.Z)
                       end
                   end
               end
           end)
       end
   end,
})

-- Fly機能
local FlySection = MainTab:CreateSection("Fly設定")
local FlyToggle = MainTab:CreateToggle({
   Name = "Fly有効化",
   CurrentValue = false,
   Flag = "FlyEnabled",
   Callback = function(Value)
       _G.FLY_TOGGLE = Value
       local player = game.Players.LocalPlayer
       local character = player.Character or player.CharacterAdded:Wait()
       local humanoid = character:WaitForChild("Humanoid")
       
       if Value then
           -- 飛行機能の初期化
           local bodyVelocity = Instance.new("BodyVelocity")
           bodyVelocity.Name = "FlyBodyVelocity"
           bodyVelocity.Parent = character.HumanoidRootPart
           bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
           
           spawn(function()
               while _G.FLY_TOGGLE do
                   wait()
                   if character and character.HumanoidRootPart then
                       local cam = workspace.CurrentCamera.CFrame
                       local moveDirection = Vector3.new()
                       
                       if userinputservice:IsKeyDown(Enum.KeyCode.W) then
                           moveDirection = moveDirection + cam.LookVector
                       end
                       if userinputservice:IsKeyDown(Enum.KeyCode.S) then
                           moveDirection = moveDirection - cam.LookVector
                       end
                       if userinputservice:IsKeyDown(Enum.KeyCode.A) then
                           moveDirection = moveDirection - cam.RightVector
                       end
                       if userinputservice:IsKeyDown(Enum.KeyCode.D) then
                           moveDirection = moveDirection + cam.RightVector
                       end
                       
                       moveDirection = moveDirection.Unit * 100
                       bodyVelocity.Velocity = moveDirection
                   end
               end
           end)
       else
           -- 飛行機能の無効化
           if character and character.HumanoidRootPart:FindFirstChild("FlyBodyVelocity") then
               character.HumanoidRootPart.FlyBodyVelocity:Destroy()
           end
       end
   end,
})

local FlySpeedSlider = MainTab:CreateSlider({
   Name = "Fly速度",
   Range = {50, 500},
   Increment = 10,
   Suffix = "速度",
   CurrentValue = 100,
   Flag = "FlySpeed",
   Callback = function(Value)
       _G.FLY_SPEED = Value
   end,
})

-- その他の機能をここに追加可能

-- 設定タブ
local SettingsTab = Window:CreateTab("設定", 4483362458)

-- UI形状設定
local UIShapeSection = SettingsTab:CreateSection("UI形状設定")

local UIShapeDropdown = SettingsTab:CreateDropdown({
   Name = "UI形状",
   Options = {"四角", "丸", "通常", "卍型", "六角形", "星型"},
   CurrentOption = "通常",
   Flag = "UIShape",
   Callback = function(Option)
       -- UI形状変更の実装
       Rayfield:Notify({
           Title = "UI形状変更",
           Content = "形状を " .. Option .. " に変更しました",
           Duration = 2,
           Image = 4483362458
       })
   end,
})

-- UIカラー設定
local UIColorSection = SettingsTab:CreateSection("UIカラー設定")

local UIColorPalette = SettingsTab:CreateColorPicker({
   Name = "UIメインカラー",
   Color = Color3.fromRGB(0, 85, 255),
   Flag = "UIColor1",
   Callback = function(Color)
       -- UIカラー変更の実装
   end,
})

-- 12色のカラーピッカーを追加
for i = 2, 12 do
   SettingsTab:CreateColorPicker({
       Name = "UIカラー " .. i,
       Color = Color3.fromRGB(
           math.random(0, 255),
           math.random(0, 255),
           math.random(0, 255)
       ),
       Flag = "UIColor" .. i,
       Callback = function(Color)
           -- 各カラー変更の実装
       end,
   })
end

-- シフトロック設定
local ShiftLockSection = SettingsTab:CreateSection("シフトロック設定")

local ShiftLockToggle = SettingsTab:CreateToggle({
   Name = "シフトロック有効",
   CurrentValue = false,
   Flag = "ShiftLockEnabled",
   Callback = function(Value)
       _G.ShiftLockEnabled = Value
       if Value then
           -- シフトロック有効化の実装
           game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
               if input.KeyCode == Enum.KeyCode.LeftShift then
                   game:GetService("Players").LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
               end
           end)
           
           game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
               if input.KeyCode == Enum.KeyCode.LeftShift then
                   game:GetService("Players").LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
               end
           end)
       end
   end,
})

-- クロスヘア設定
local CrosshairSection = SettingsTab:CreateSection("クロスヘア設定")

local CrosshairToggle = SettingsTab:CreateToggle({
   Name = "クロスヘア表示",
   CurrentValue = false,
   Flag = "CrosshairEnabled",
   Callback = function(Value)
       _G.CrosshairEnabled = Value
       if Value then
           -- クロスヘア作成
           createCrosshair()
       else
           -- クロスヘア削除
           if _G.CrosshairFrame then
               _G.CrosshairFrame:Destroy()
           end
       end
   end,
})

local CrosshairShapeDropdown = SettingsTab:CreateDropdown({
   Name = "クロスヘア形状",
   Options = {"十字", "丸", "四角", "卍型", "点", "X型"},
   CurrentOption = "十字",
   Flag = "CrosshairShape",
   Callback = function(Option)
       _G.CrosshairShape = Option
       updateCrosshair()
   end,
})

local CrosshairSizeSlider = SettingsTab:CreateSlider({
   Name = "クロスヘアサイズ",
   Range = {10, 100},
   Increment = 5,
   Suffix = "px",
   CurrentValue = 20,
   Flag = "CrosshairSize",
   Callback = function(Value)
       _G.CrosshairSize = Value
       updateCrosshair()
   end,
})

local CrosshairColorPicker = SettingsTab:CreateColorPicker({
   Name = "クロスヘアカラー",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "CrosshairColor",
   Callback = function(Color)
       _G.CrosshairColor = Color
       updateCrosshair()
   end,
})

local CrosshairThicknessSlider = SettingsTab:CreateSlider({
   Name = "クロスヘア太さ",
   Range = {1, 10},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 2,
   Flag = "CrosshairThickness",
   Callback = function(Value)
       _G.CrosshairThickness = Value
       updateCrosshair()
   end,
})

-- クロスヘア作成関数
function createCrosshair()
   if _G.CrosshairFrame then
       _G.CrosshairFrame:Destroy()
   end
  
   local player = game.Players.LocalPlayer
   local playerGui = player:WaitForChild("PlayerGui")
  
   _G.CrosshairFrame = Instance.new("ScreenGui")
   _G.CrosshairFrame.Name = "CrosshairGui"
   _G.CrosshairFrame.Parent = playerGui
   _G.CrosshairFrame.ResetOnSpawn = false
  
   updateCrosshair()
end

function updateCrosshair()
   if not _G.CrosshairFrame or not _G.CrosshairEnabled then return end
  
   -- 既存のクロスヘアをクリア
   for _, v in pairs(_G.CrosshairFrame:GetChildren()) do
       v:Destroy()
   end
  
   local centerX = UDim.new(0.5, 0)
   local centerY = UDim.new(0.5, 0)
   local size = _G.CrosshairSize or 20
   local color = _G.CrosshairColor or Color3.fromRGB(255, 255, 255)
   local thickness = _G.CrosshairThickness or 2
   local shape = _G.CrosshairShape or "十字"
  
   if shape == "十字" then
       -- 横線
       local horizontal = Instance.new("Frame")
       horizontal.Size = UDim2.new(0, size, 0, thickness)
       horizontal.Position = UDim2.new(0.5, -size/2, 0.5, -thickness/2)
       horizontal.BackgroundColor3 = color
       horizontal.BorderSizePixel = 0
       horizontal.Parent = _G.CrosshairFrame
      
       -- 縦線
       local vertical = Instance.new("Frame")
       vertical.Size = UDim2.new(0, thickness, 0, size)
       vertical.Position = UDim2.new(0.5, -thickness/2, 0.5, -size/2)
       vertical.BackgroundColor3 = color
       vertical.BorderSizePixel = 0
       vertical.Parent = _G.CrosshairFrame
      
   elseif shape == "卍型" then
       -- 卍型の実装（簡易版）
       local swastika = Instance.new("Frame")
       swastika.Size = UDim2.new(0, size, 0, size)
       swastika.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
       swastika.BackgroundColor3 = color
       swastika.BackgroundTransparency = 0.5
       swastika.BorderSizePixel = 0
       swastika.Parent = _G.CrosshairFrame
      
       -- ここに卍型の詳細な描画を追加
   elseif shape == "丸" then
       local circle = Instance.new("Frame")
       circle.Size = UDim2.new(0, size, 0, size)
       circle.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
       circle.BackgroundColor3 = color
       circle.BorderSizePixel = 0
       circle.Parent = _G.CrosshairFrame
   end
end

-- UI削除確認システム
local DeleteSection = SettingsTab:CreateSection("UI削除")

local DeleteButton = SettingsTab:CreateButton({
   Name = "UIを削除",
   Callback = function()
       -- 確認用の新しいウィンドウを作成
       local ConfirmWindow = Rayfield:CreateWindow({
           Name = "削除確認",
           LoadingTitle = "確認中...",
           LoadingSubtitle = "UI削除の確認",
           ConfigurationSaving = {
               Enabled = false,
           },
           Discord = {
               Enabled = false,
           },
           KeySystem = false,
       })
      
       local ConfirmTab = ConfirmWindow:CreateTab("確認", 4483362458)
      
       ConfirmTab:CreateLabel({
           Name = "本当にUIを削除しますか？",
           Text = "この操作は元に戻せません"
       })
      
       -- はいボタン
       ConfirmTab:CreateButton({
           Name = "はい - 削除する",
           Callback = function()
               Rayfield:Destroy()
               ConfirmWindow:Destroy()
           end,
       })
      
       -- いいえボタン
       ConfirmTab:CreateButton({
           Name = "いいえ - キャンセル",
           Callback = function()
               ConfirmWindow:Destroy()
               Rayfield:Notify({
                   Title = "削除キャンセル",
                   Content = "UI削除をキャンセルしました",
                   Duration = 2,
                   Image = 4483362458
               })
           end,
       })
   end,
})

-- サービス参照
local userinputservice = game:GetService("UserInputService")

-- 初期化完了通知
Rayfield:Notify({
   Title = "UI読み込み完了",
   Content = "すべての機能が読み込まれました",
   Duration = 3,
   Image = 4483362458
})

-- UIの表示
Rayfield:LoadConfiguration()
