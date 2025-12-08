-- Arseus x Neo Style UI v3.0 - レスポンシブ対応
-- モバイルとPCで最適なサイズを自動調整

-- サービスの取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

-- プレイヤーとマウス
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- デバイス判定
local IS_MOBILE = UserInputService.TouchEnabled
local IS_CONSOLE = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled
local IS_DESKTOP = not IS_MOBILE and not IS_CONSOLE

-- 画面サイズに基づくUIサイズ計算
function GetUISize()
    if IS_MOBILE then
        -- モバイル: 画面の80%幅、適応的高さ
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local width = math.min(viewportSize.X * 0.9, 450)  -- 最大450px
        local height = math.min(viewportSize.Y * 0.7, 500) -- 最大500px
        return UDim2.new(0, width, 0, height)
    elseif IS_DESKTOP then
        -- PC: 固定サイズ
        return UDim2.new(0, 650, 0, 550)
    else
        -- コンソールなど
        return UDim2.new(0, 500, 0, 450)
    end
end

-- メインGUIの作成
local ArseusUI = Instance.new("ScreenGui")
ArseusUI.Name = "ArseusNeoUI"
ArseusUI.ResetOnSpawn = false
ArseusUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ArseusUI.IgnoreGuiInset = true
ArseusUI.Parent = player:WaitForChild("PlayerGui")

-- 認証パスワード
local SECURITY_PASSWORD = "しゅーくりーむ"
local authAttempts = 0
local MAX_AUTH_ATTEMPTS = 5

-- グローバル変数
local MainWindow = nil
local AuthWindow = nil
local CrosshairGui = nil

-- グローバル設定
local Settings = {
    UIColor = Color3.fromRGB(0, 170, 255),
    UIShape = "Rounded",
    Theme = "Dark",
    Transparency = 0.1,
    
    Crosshair = {
        Enabled = false,
        Type = "Cross",
        Color = Color3.fromRGB(255, 255, 255),
        Size = 20,
        Thickness = 2,
        Gap = 5,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Rotation = 0,
        Alpha = 1,
        Blinking = false,
        ShowDot = true,
        CustomShape = 1
    },
    
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        FlyEnabled = false,
        FlySpeed = 50,
        NoClip = false,
        Gravity = 196.2,
        HipHeight = 0,
        FloatForce = 0,
        InfiniteJump = false,
        AutoSprint = false
    },
    
    Visual = {
        ShiftLock = false,
        ThirdPerson = false,
        FOV = 70,
        CameraOffset = Vector3.new(0, 0, 5),
        Esp = false,
        Tracers = false,
        Chams = false
    },
    
    Misc = {
        AutoFarm = false,
        AntiAfk = true,
        ClickTP = false,
        TPKey = Enum.KeyCode.T,
        SpeedKey = Enum.KeyCode.LeftShift,
        JumpKey = Enum.KeyCode.Space
    }
}

-- カラーパレット (12色)
local ColorPalette = {
    Color3.fromRGB(0, 170, 255),    -- アクアブルー
    Color3.fromRGB(255, 50, 100),   -- ネオンピンク
    Color3.fromRGB(50, 255, 100),   -- ネオングリーン
    Color3.fromRGB(255, 200, 50),   -- ゴールデンイエロー
    Color3.fromRGB(180, 50, 255),   -- パープル
    Color3.fromRGB(255, 100, 50),   -- オレンジ
    Color3.fromRGB(50, 200, 255),   -- スカイブルー
    Color3.fromRGB(255, 50, 200),   -- マゼンタ
    Color3.fromRGB(100, 255, 200),  -- ターコイズ
    Color3.fromRGB(255, 150, 50),   -- アンバー
    Color3.fromRGB(150, 50, 255),   -- バイオレット
    Color3.fromRGB(255, 255, 255)   -- ホワイト
}

-- UI形状タイプと詳細設定
local ShapeTypes = {
    {Name = "Rounded", CornerRadius = 20, Description = "丸みを帯びた角"},
    {Name = "Square", CornerRadius = 0, Description = "鋭い角"},
    {Name = "Circle", CornerRadius = 1000, Description = "完全な円形"},
    {Name = "Swastika", CornerRadius = 15, Description = "卍型のデザイン"},
    {Name = "Diamond", CornerRadius = 5, Description = "ダイヤモンド型"},
    {Name = "Hexagon", CornerRadius = 10, Description = "六角形"},
    {Name = "Pill", CornerRadius = 100, Description = "カプセル型"},
    {Name = "RoundedX", CornerRadius = 15, Description = "X型丸み"},
    {Name = "RoundedPlus", CornerRadius = 15, Description = "+型丸み"},
    {Name = "Custom", CornerRadius = 25, Description = "カスタム形状"}
}

-- クロスヘアタイプと詳細設定
local CrosshairTypes = {
    {Name = "Cross", Parts = 4, Description = "基本の十字"},
    {Name = "Dot", Parts = 1, Description = "単純な点"},
    {Name = "Circle", Parts = 1, Description = "円形"},
    {Name = "Square", Parts = 1, Description = "四角形"},
    {Name = "Crosshair", Parts = 5, Description = "精密クロスヘア"},
    {Name = "Target", Parts = 3, Description = "ターゲット型"},
    {Name = "Arrow", Parts = 3, Description = "矢印型"},
    {Name = "Diamond", Parts = 1, Description = "ダイヤモンド型"},
    {Name = "Hexagon", Parts = 1, Description = "六角形"},
    {Name = "Star", Parts = 10, Description = "星型"},
    {Name = "Custom1", Parts = 4, Description = "カスタム1"},
    {Name = "Custom2", Parts = 6, Description = "カスタム2"}
}

-- スムーズなアニメーション設定
local AnimationConfig = {
    Duration = 0.3,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
    HoverScale = 1.05,
    ClickScale = 0.95
}

-- 関数: スムーズドラッグ
local function CreateSmoothDrag(frame, dragPart)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        
        -- 画面内に制限
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local frameSize = frame.AbsoluteSize
        
        newPos = UDim2.new(
            math.clamp(newPos.X.Scale, 0, 1 - (frameSize.X / viewportSize.X)),
            math.clamp(newPos.X.Offset, 0, viewportSize.X - frameSize.X),
            math.clamp(newPos.Y.Scale, 0, 1 - (frameSize.Y / viewportSize.Y)),
            math.clamp(newPos.Y.Offset, 0, viewportSize.Y - frameSize.Y)
        )
        
        -- スムーズな移動
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, {Position = newPos})
        tween:Play()
    end
    
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- 関数: ボタンアニメーション
local function CreateButtonAnimation(button)
    local originalSize = button.Size
    local originalColor = button.BackgroundColor3
    
    -- ホバーエフェクト
    button.MouseEnter:Connect(function()
        if not AnimationConfig then return end
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {
            Size = UDim2.new(
                originalSize.X.Scale * AnimationConfig.HoverScale,
                originalSize.X.Offset * AnimationConfig.HoverScale,
                originalSize.Y.Scale * AnimationConfig.HoverScale,
                originalSize.Y.Offset * AnimationConfig.HoverScale
            ),
            BackgroundColor3 = Color3.new(
                math.min(originalColor.R * 1.2, 1),
                math.min(originalColor.G * 1.2, 1),
                math.min(originalColor.B * 1.2, 1)
            )
        })
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if not AnimationConfig then return end
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {
            Size = originalSize,
            BackgroundColor3 = originalColor
        })
        tween:Play()
    end)
    
    -- クリックエフェクト
    button.MouseButton1Down:Connect(function()
        if not AnimationConfig then return end
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {
            Size = UDim2.new(
                originalSize.X.Scale * AnimationConfig.ClickScale,
                originalSize.X.Offset * AnimationConfig.ClickScale,
                originalSize.Y.Scale * AnimationConfig.ClickScale,
                originalSize.Y.Offset * AnimationConfig.ClickScale
            )
        })
        tween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if not AnimationConfig then return end
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {
            Size = UDim2.new(
                originalSize.X.Scale * AnimationConfig.HoverScale,
                originalSize.X.Offset * AnimationConfig.HoverScale,
                originalSize.Y.Scale * AnimationConfig.HoverScale,
                originalSize.Y.Offset * AnimationConfig.HoverScale
            )
        })
        tween:Play()
    end)
end

-- 関数: 認証画面の作成
local function CreateAuthWindow()
    AuthWindow = Instance.new("Frame")
    AuthWindow.Name = "AuthWindow"
    
    -- デバイスに応じたサイズ設定
    local uiSize = GetUISize()
    AuthWindow.Size = UDim2.new(0, uiSize.X.Offset * 0.7, 0, uiSize.Y.Offset * 0.6)
    AuthWindow.Position = UDim2.new(0.5, -uiSize.X.Offset * 0.7 / 2, 0.5, -uiSize.Y.Offset * 0.6 / 2)
    
    AuthWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    AuthWindow.BackgroundTransparency = 0.05
    AuthWindow.BorderSizePixel = 0
    AuthWindow.ZIndex = 999
    AuthWindow.Parent = ArseusUI
    
    -- 丸みを帯びたコーナー
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = AuthWindow
    
    -- シャドウエフェクト
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = AuthWindow
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, IS_MOBILE and 50 or 60)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔒 セキュリティ認証"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = IS_MOBILE and 24 or 28
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = AuthWindow
    
    -- サブタイトル
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -40, 0, IS_MOBILE and 30 or 40)
    subtitle.Position = UDim2.new(0, 20, 0, IS_MOBILE and 65 or 80)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Arseus x Neo UIにアクセスするには認証が必要です"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = IS_MOBILE and 14 or 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextWrapped = true
    subtitle.Parent = AuthWindow
    
    -- パスワード入力欄
    local passwordFrame = Instance.new("Frame")
    passwordFrame.Name = "PasswordFrame"
    passwordFrame.Size = UDim2.new(1, -40, 0, IS_MOBILE and 45 or 50)
    passwordFrame.Position = UDim2.new(0, 20, 0, IS_MOBILE and 110 or 140)
    passwordFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    passwordFrame.BorderSizePixel = 0
    passwordFrame.Parent = AuthWindow
    
    local passwordCorner = Instance.new("UICorner")
    passwordCorner.CornerRadius = UDim.new(0, 10)
    passwordCorner.Parent = passwordFrame
    
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.Size = UDim2.new(1, -60, 1, 0)
    passwordBox.Position = UDim2.new(0, 10, 0, 0)
    passwordBox.BackgroundTransparency = 1
    passwordBox.PlaceholderText = "暗証番号を入力..."
    passwordBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    passwordBox.Text = ""
    passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordBox.TextSize = IS_MOBILE and 16 or 18
    passwordBox.Font = Enum.Font.Gotham
    passwordBox.TextXAlignment = Enum.TextXAlignment.Left
    passwordBox.Parent = passwordFrame
    
    -- 表示/非表示トグル
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleVisibility"
    toggleBtn.Size = UDim2.new(0, IS_MOBILE and 35 or 40, 0, IS_MOBILE and 35 or 40)
    toggleBtn.Position = UDim2.new(1, -IS_MOBILE and 45 or 50, 0.5, -IS_MOBILE and 17.5 or 20)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = IS_MOBILE and 14 or 16
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Parent = passwordFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- 認証ボタン
    local authButton = Instance.new("TextButton")
    authButton.Name = "AuthButton"
    authButton.Size = UDim2.new(1, -40, 0, IS_MOBILE and 45 or 50)
    authButton.Position = UDim2.new(0, 20, 0, IS_MOBILE and 170 or 210)
    authButton.BackgroundColor3 = Settings.UIColor
    authButton.AutoButtonColor = false
    authButton.Text = "認証を開始"
    authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    authButton.TextSize = IS_MOBILE and 18 or 20
    authButton.Font = Enum.Font.GothamBold
    authButton.Parent = AuthWindow
    
    local authCorner = Instance.new("UICorner")
    authCorner.CornerRadius = UDim.new(0, 10)
    authCorner.Parent = authButton
    
    -- メッセージ表示
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -40, 0, IS_MOBILE and 30 or 40)
    messageLabel.Position = UDim2.new(0, 20, 0, IS_MOBILE and 230 or 280)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = IS_MOBILE and 14 or 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.Parent = AuthWindow
    
    -- 機能
    local passwordVisible = false
    
    -- パスワード表示/非表示
    toggleBtn.MouseButton1Click:Connect(function()
        passwordVisible = not passwordVisible
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if passwordVisible then
            passwordBox.TextTransparency = 0
            passwordBox.Text = string.gsub(passwordBox.Text, ".", "•")
            
            local tween = TweenService:Create(toggleBtn, tweenInfo, {
                BackgroundColor3 = Settings.UIColor,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            tween:Play()
            
            toggleBtn.Text = "👁‍🗨"
        else
            passwordBox.TextTransparency = 0
            passwordBox.Text = string.gsub(passwordBox.Text, ".", "•")
            
            local tween = TweenService:Create(toggleBtn, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            tween:Play()
            
            toggleBtn.Text = "👁"
        end
    end)
    
    -- ボタンアニメーションを適用
    CreateButtonAnimation(authButton)
    CreateButtonAnimation(toggleBtn)
    
    -- 認証処理
    authButton.MouseButton1Click:Connect(function()
        local input = passwordBox.Text
        
        if input == "" then
            messageLabel.Text = "暗証番号を入力してください"
            messageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        authAttempts = authAttempts + 1
        
        if input == SECURITY_PASSWORD then
            -- 認証成功
            messageLabel.Text = "✅ 認証成功！"
            messageLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- 認証成功アニメーション
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            
            local tween1 = TweenService:Create(AuthWindow, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -uiSize.X.Offset * 0.7 / 2, 0.5, -uiSize.Y.Offset * 0.6 / 2 - 50)
            })
            
            local tween2 = TweenService:Create(shadow, tweenInfo, {
                ImageTransparency = 1
            })
            
            tween1:Play()
            tween2:Play()
            
            -- アニメーション完了後に認証画面を削除し、メインUIを作成
            tween1.Completed:Connect(function()
                -- 認証画面を完全に削除
                if AuthWindow then
                    AuthWindow:Destroy()
                    AuthWindow = nil
                end
                
                -- メインUIを作成
                CreateMainWindow()
            end)
        else
            -- 認証失敗
            messageLabel.Text = string.format("❌ 認証失敗 (%d/%d)", authAttempts, MAX_AUTH_ATTEMPTS)
            messageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            -- シェイクアニメーション
            local originalPos = AuthWindow.Position
            for i = 1, 10 do
                AuthWindow.Position = UDim2.new(
                    originalPos.X.Scale,
                    originalPos.X.Offset + math.random(-8, 8),
                    originalPos.Y.Scale,
                    originalPos.Y.Offset + math.random(-4, 4)
                )
                RunService.RenderStepped:Wait()
            end
            AuthWindow.Position = originalPos
            
            -- 試行回数制限
            if authAttempts >= MAX_AUTH_ATTEMPTS then
                messageLabel.Text = "🚫 試行回数制限に達しました"
                authButton.Text = "ロックアウト"
                authButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                authButton.AutoButtonColor = true
                
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(AuthWindow, tweenInfo, {
                    BackgroundColor3 = Color3.fromRGB(30, 15, 15),
                    Position = UDim2.new(0.5, -uiSize.X.Offset * 0.7 / 2, 0.5, -uiSize.Y.Offset * 0.6 / 2 - 25)
                })
                tween:Play()
            end
        end
    end)
    
    -- Enterキーで認証
    passwordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            authButton:Fire("MouseButton1Click")
        end
    end)
    
    return AuthWindow
end

-- 関数: UI形状を適用
local function ApplyUIShape(frame, shapeName)
    if not frame then return end
    
    -- 既存のUICornerを削除
    if frame:FindFirstChild("UICorner") then
        frame.UICorner:Destroy()
    end
    
    -- 既存のUIStrokeを削除
    if frame:FindFirstChild("UIStroke") then
        frame.UIStroke:Destroy()
    end
    
    local corner = Instance.new("UICorner")
    
    -- 形状に応じた設定
    for _, shape in ipairs(ShapeTypes) do
        if shape.Name == shapeName then
            if shapeName == "Circle" then
                corner.CornerRadius = UDim.new(1, 0)
            else
                corner.CornerRadius = UDim.new(0, shape.CornerRadius)
            end
            break
        end
    end
    
    corner.Parent = frame
    
    -- 卍型の場合は特別な処理（UIStrokeで表現）
    if shapeName == "Swastika" then
        local stroke = Instance.new("UIStroke")
        stroke.Color = Settings.UIColor
        stroke.Thickness = 4
        stroke.Parent = frame
        
        -- 卍マークを追加
        local swastikaFrame = Instance.new("Frame")
        swastikaFrame.Name = "SwastikaOverlay"
        swastikaFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
        swastikaFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
        swastikaFrame.BackgroundTransparency = 1
        swastikaFrame.Parent = frame
        
        -- 卍の描画（簡易版）
        local line1 = Instance.new("Frame")
        line1.Size = UDim2.new(0, 20, 0, 4)
        line1.Position = UDim2.new(0.5, -10, 0.5, -2)
        line1.BackgroundColor3 = Settings.UIColor
        line1.BorderSizePixel = 0
        line1.Parent = swastikaFrame
        
        local line2 = Instance.new("Frame")
        line2.Size = UDim2.new(0, 4, 0, 20)
        line2.Position = UDim2.new(0.5, -2, 0.5, -10)
        line2.BackgroundColor3 = Settings.UIColor
        line2.BorderSizePixel = 0
        line2.Parent = swastikaFrame
    end
end

-- 関数: クロスヘアを更新
local function UpdateCrosshair()
    -- 既存のクロスヘアを削除
    if CrosshairGui and CrosshairGui.Parent then
        CrosshairGui:Destroy()
    end
    
    if not Settings.Crosshair.Enabled then
        CrosshairGui = nil
        return
    end
    
    -- 新しいクロスヘアを作成
    CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "CrosshairGui"
    CrosshairGui.ResetOnSpawn = false
    CrosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    CrosshairGui.IgnoreGuiInset = true
    CrosshairGui.Parent = player.PlayerGui
    
    local center = Instance.new("Frame")
    center.Name = "Center"
    center.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
    center.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
    center.BackgroundColor3 = Settings.Crosshair.Color
    center.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
    center.BorderSizePixel = 0
    center.Parent = CrosshairGui
    
    -- クロスヘアの種類に応じて形状を作成
    local crosshairType = Settings.Crosshair.Type
    
    if crosshairType == "Cross" then
        -- 十字型クロスヘア
        local left = Instance.new("Frame")
        left.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Thickness)
        left.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2 - Settings.Crosshair.Gap, 0.5, -Settings.Crosshair.Thickness/2)
        left.BackgroundColor3 = Settings.Crosshair.Color
        left.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        left.BorderSizePixel = 0
        left.Parent = CrosshairGui
        
        local right = left:Clone()
        right.Position = UDim2.new(0.5, Settings.Crosshair.Gap, 0.5, -Settings.Crosshair.Thickness/2)
        right.Parent = CrosshairGui
        
        local top = Instance.new("Frame")
        top.Size = UDim2.new(0, Settings.Crosshair.Thickness, 0, Settings.Crosshair.Size)
        top.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, -Settings.Crosshair.Size/2 - Settings.Crosshair.Gap)
        top.BackgroundColor3 = Settings.Crosshair.Color
        top.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        top.BorderSizePixel = 0
        top.Parent = CrosshairGui
        
        local bottom = top:Clone()
        bottom.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, Settings.Crosshair.Gap)
        bottom.Parent = CrosshairGui
        
        -- 中心点
        if Settings.Crosshair.ShowDot then
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, Settings.Crosshair.Thickness * 1.5, 0, Settings.Crosshair.Thickness * 1.5)
            dot.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness * 0.75, 0.5, -Settings.Crosshair.Thickness * 0.75)
            dot.BackgroundColor3 = Settings.Crosshair.Color
            dot.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
            dot.BorderSizePixel = 0
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot
            dot.Parent = CrosshairGui
        end
        
    elseif crosshairType == "Dot" then
        -- 点型クロスヘア
        center.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        center.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1, 0)
        centerCorner.Parent = center
        
    elseif crosshairType == "Circle" then
        -- 円型クロスヘア
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        circle.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        circle.BackgroundTransparency = 1
        circle.Parent = CrosshairGui
        
        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = Settings.Crosshair.Color
        circleStroke.Thickness = Settings.Crosshair.Thickness
        circleStroke.Transparency = 1 - Settings.Crosshair.Alpha
        circleStroke.Parent = circle
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        -- 中心点
        if Settings.Crosshair.ShowDot then
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, Settings.Crosshair.Thickness, 0, Settings.Crosshair.Thickness)
            dot.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, -Settings.Crosshair.Thickness/2)
            dot.BackgroundColor3 = Settings.Crosshair.Color
            dot.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
            dot.BorderSizePixel = 0
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot
            dot.Parent = CrosshairGui
        end
        
    elseif crosshairType == "Square" then
        -- 四角形クロスヘア
        center.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        center.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        
    elseif crosshairType == "Crosshair" then
        -- 精密クロスヘア
        -- 外側の円
        local outerCircle = Instance.new("Frame")
        outerCircle.Size = UDim2.new(0, Settings.Crosshair.Size * 1.5, 0, Settings.Crosshair.Size * 1.5)
        outerCircle.Position = UDim2.new(0.5, -Settings.Crosshair.Size * 0.75, 0.5, -Settings.Crosshair.Size * 0.75)
        outerCircle.BackgroundTransparency = 1
        outerCircle.Parent = CrosshairGui
        
        local outerStroke = Instance.new("UIStroke")
        outerStroke.Color = Settings.Crosshair.Color
        outerStroke.Thickness = Settings.Crosshair.Thickness * 0.5
        outerStroke.Transparency = 1 - Settings.Crosshair.Alpha
        outerStroke.Parent = outerCircle
        
        local outerCorner = Instance.new("UICorner")
        outerCorner.CornerRadius = UDim.new(1, 0)
        outerCorner.Parent = outerCircle
        
        -- 内側の十字
        local innerLine = Instance.new("Frame")
        innerLine.Size = UDim2.new(0, Settings.Crosshair.Size * 0.7, 0, Settings.Crosshair.Thickness * 0.7)
        innerLine.Position = UDim2.new(0.5, -Settings.Crosshair.Size * 0.35, 0.5, -Settings.Crosshair.Thickness * 0.35)
        innerLine.BackgroundColor3 = Settings.Crosshair.Color
        innerLine.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        innerLine.BorderSizePixel = 0
        innerLine.Parent = CrosshairGui
        
        local innerLine2 = innerLine:Clone()
        innerLine2.Size = UDim2.new(0, Settings.Crosshair.Thickness * 0.7, 0, Settings.Crosshair.Size * 0.7)
        innerLine2.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness * 0.35, 0.5, -Settings.Crosshair.Size * 0.35)
        innerLine2.Parent = CrosshairGui
        
        -- 中心点
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, Settings.Crosshair.Thickness, 0, Settings.Crosshair.Thickness)
        dot.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, -Settings.Crosshair.Thickness/2)
        dot.BackgroundColor3 = Settings.Crosshair.Color
        dot.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        dot.BorderSizePixel = 0
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        dot.Parent = CrosshairGui
        
    elseif crosshairType == "Target" then
        -- ターゲット型クロスヘア
        -- 外側の円
        for i = 1, 3 do
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, Settings.Crosshair.Size * (i * 0.3), 0, Settings.Crosshair.Size * (i * 0.3))
            circle.Position = UDim2.new(0.5, -Settings.Crosshair.Size * (i * 0.15), 0.5, -Settings.Crosshair.Size * (i * 0.15))
            circle.BackgroundTransparency = 1
            circle.Parent = CrosshairGui
            
            local circleStroke = Instance.new("UIStroke")
            circleStroke.Color = Settings.Crosshair.Color
            circleStroke.Thickness = Settings.Crosshair.Thickness * 0.5
            circleStroke.Transparency = 1 - Settings.Crosshair.Alpha
            circleStroke.Parent = circle
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = circle
        end
        
        -- 中心点
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, Settings.Crosshair.Thickness * 2, 0, Settings.Crosshair.Thickness * 2)
        dot.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness, 0.5, -Settings.Crosshair.Thickness)
        dot.BackgroundColor3 = Settings.Crosshair.Color
        dot.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        dot.BorderSizePixel = 0
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        dot.Parent = CrosshairGui
        
    elseif crosshairType == "Diamond" then
        -- ダイヤモンド型
        local diamond = Instance.new("Frame")
        diamond.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        diamond.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        diamond.BackgroundColor3 = Settings.Crosshair.Color
        diamond.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        diamond.BorderSizePixel = 0
        diamond.Parent = CrosshairGui
        diamond.Rotation = 45
        
    elseif crosshairType == "Arrow" then
        -- 矢印型（簡易版）
        local arrowBody = Instance.new("Frame")
        arrowBody.Size = UDim2.new(0, Settings.Crosshair.Size * 0.5, 0, Settings.Crosshair.Thickness)
        arrowBody.Position = UDim2.new(0.5, -Settings.Crosshair.Size * 0.25, 0.5, -Settings.Crosshair.Thickness/2)
        arrowBody.BackgroundColor3 = Settings.Crosshair.Color
        arrowBody.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        arrowBody.BorderSizePixel = 0
        arrowBody.Parent = CrosshairGui
        
        local arrowHead = Instance.new("Frame")
        arrowHead.Size = UDim2.new(0, Settings.Crosshair.Thickness * 1.5, 0, Settings.Crosshair.Thickness * 1.5)
        arrowHead.Position = UDim2.new(0.5, Settings.Crosshair.Size * 0.25 - Settings.Crosshair.Thickness * 0.75, 0.5, -Settings.Crosshair.Thickness * 0.75)
        arrowHead.BackgroundColor3 = Settings.Crosshair.Color
        arrowHead.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        arrowHead.BorderSizePixel = 0
        arrowHead.Rotation = 45
        arrowHead.Parent = CrosshairGui
        
    elseif crosshairType == "Hexagon" then
        -- 六角形（画像を使用するのが理想だが、簡易版）
        local hexagon = Instance.new("Frame")
        hexagon.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        hexagon.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        hexagon.BackgroundColor3 = Settings.Crosshair.Color
        hexagon.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        hexagon.BorderSizePixel = 0
        hexagon.Parent = CrosshairGui
        -- 六角形の近似
        local hexCorner = Instance.new("UICorner")
        hexCorner.CornerRadius = UDim.new(0, 10)
        hexCorner.Parent = hexagon
        
    elseif crosshairType == "Star" then
        -- 星型（簡易版 - 十字+回転）
        for i = 0, 1 do
            local starLine1 = Instance.new("Frame")
            starLine1.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Thickness)
            starLine1.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Thickness/2)
            starLine1.BackgroundColor3 = Settings.Crosshair.Color
            starLine1.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
            starLine1.BorderSizePixel = 0
            starLine1.Rotation = i * 45
            starLine1.Parent = CrosshairGui
            
            local starLine2 = Instance.new("Frame")
            starLine2.Size = UDim2.new(0, Settings.Crosshair.Thickness, 0, Settings.Crosshair.Size)
            starLine2.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, -Settings.Crosshair.Size/2)
            starLine2.BackgroundColor3 = Settings.Crosshair.Color
            starLine2.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
            starLine2.BorderSizePixel = 0
            starLine2.Rotation = i * 45
            starLine2.Parent = CrosshairGui
        end
        
    elseif crosshairType == "Custom1" then
        -- カスタム1: ドット付き円
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        circle.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        circle.BackgroundTransparency = 1
        circle.Parent = CrosshairGui
        
        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = Settings.Crosshair.Color
        circleStroke.Thickness = Settings.Crosshair.Thickness
        circleStroke.Transparency = 1 - Settings.Crosshair.Alpha
        circleStroke.Parent = circle
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        -- 4つのドット
        local positions = {
            {x = 0.5, y = 0.2},
            {x = 0.8, y = 0.5},
            {x = 0.5, y = 0.8},
            {x = 0.2, y = 0.5}
        }
        
        for _, pos in ipairs(positions) do
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, Settings.Crosshair.Thickness * 1.5, 0, Settings.Crosshair.Thickness * 1.5)
            dot.Position = UDim2.new(pos.x, -Settings.Crosshair.Thickness * 0.75, pos.y, -Settings.Crosshair.Thickness * 0.75)
            dot.BackgroundColor3 = Settings.Crosshair.Color
            dot.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
            dot.BorderSizePixel = 0
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot
            dot.Parent = CrosshairGui
        end
        
    elseif crosshairType == "Custom2" then
        -- カスタム2: 3重円
        for i = 1, 3 do
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, Settings.Crosshair.Size * (i * 0.3), 0, Settings.Crosshair.Size * (i * 0.3))
            circle.Position = UDim2.new(0.5, -Settings.Crosshair.Size * (i * 0.15), 0.5, -Settings.Crosshair.Size * (i * 0.15))
            circle.BackgroundTransparency = 1
            circle.Parent = CrosshairGui
            
            local circleStroke = Instance.new("UIStroke")
            circleStroke.Color = Settings.Crosshair.Color
            circleStroke.Thickness = Settings.Crosshair.Thickness * 0.3
            circleStroke.Transparency = 1 - Settings.Crosshair.Alpha
            circleStroke.Parent = circle
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = circle
        end
        
        -- 中心十字
        local crossLine1 = Instance.new("Frame")
        crossLine1.Size = UDim2.new(0, Settings.Crosshair.Size * 0.6, 0, Settings.Crosshair.Thickness * 0.5)
        crossLine1.Position = UDim2.new(0.5, -Settings.Crosshair.Size * 0.3, 0.5, -Settings.Crosshair.Thickness * 0.25)
        crossLine1.BackgroundColor3 = Settings.Crosshair.Color
        crossLine1.BackgroundTransparency = 1 - Settings.Crosshair.Alpha
        crossLine1.BorderSizePixel = 0
        crossLine1.Parent = CrosshairGui
        
        local crossLine2 = crossLine1:Clone()
        crossLine2.Size = UDim2.new(0, Settings.Crosshair.Thickness * 0.5, 0, Settings.Crosshair.Size * 0.6)
        crossLine2.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness * 0.25, 0.5, -Settings.Crosshair.Size * 0.3)
        crossLine2.Parent = CrosshairGui
    end
    
    -- アウトライン
    if Settings.Crosshair.Outline then
        local children = CrosshairGui:GetChildren()
        for _, child in ipairs(children) do
            if child:IsA("Frame") and child.BackgroundTransparency < 1 then
                local outline = Instance.new("UIStroke")
                outline.Color = Settings.Crosshair.OutlineColor
                outline.Thickness = 1
                outline.Transparency = 1 - Settings.Crosshair.Alpha * 0.7
                outline.Parent = child
            end
        end
    end
    
    -- 回転
    if Settings.Crosshair.Rotation ~= 0 then
        CrosshairGui.Rotation = Settings.Crosshair.Rotation
    end
    
    -- 点滅効果
    if Settings.Crosshair.Blinking then
        spawn(function()
            while CrosshairGui and CrosshairGui.Parent and Settings.Crosshair.Enabled and Settings.Crosshair.Blinking do
                for _, child in ipairs(CrosshairGui:GetChildren()) do
                    if child:IsA("Frame") then
                        if child:FindFirstChild("UIStroke") then
                            local stroke = child.UIStroke
                            stroke.Transparency = stroke.Transparency == (1 - Settings.Crosshair.Alpha) and 1 or (1 - Settings.Crosshair.Alpha)
                        else
                            child.BackgroundTransparency = child.BackgroundTransparency == (1 - Settings.Crosshair.Alpha) and 1 or (1 - Settings.Crosshair.Alpha)
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
end

-- 関数: シフトロック機能
local function ToggleShiftLock(enabled)
    if enabled then
        -- シフトロックを有効化
        local shiftLockConnection
        shiftLockConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local character = player.Character
                if character and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.AutoRotate = false
                        
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root then
                            local cam = workspace.CurrentCamera
                            local lookVector = cam.CFrame.LookVector
                            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
                        end
                    end
                else
                    local humanoid = character and character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.AutoRotate = true
                    end
                end
            end
        end)
        
        -- 接続を保存
        Settings.Visual.ShiftLockConnection = shiftLockConnection
    else
        -- シフトロックを無効化
        if Settings.Visual.ShiftLockConnection then
            Settings.Visual.ShiftLockConnection:Disconnect()
            Settings.Visual.ShiftLockConnection = nil
        end
        
        -- オートローテーションを戻す
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
    end
end

-- 関数: メインウィンドウの作成
function CreateMainWindow()
    print("メインウィンドウを作成します...")
    
    -- メインウィンドウが既にある場合は削除
    if MainWindow and MainWindow.Parent then
        MainWindow:Destroy()
    end
    
    MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    
    -- デバイスに応じたサイズ設定
    local uiSize = GetUISize()
    MainWindow.Size = uiSize
    MainWindow.Position = UDim2.new(0.5, -uiSize.X.Offset/2, 0.5, -uiSize.Y.Offset/2)
    
    MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainWindow.BackgroundTransparency = 0.05
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = ArseusUI
    
    -- UI形状を適用
    ApplyUIShape(MainWindow, Settings.UIShape)
    
    -- シャドウエフェクト
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = MainWindow
    
    -- タイトルバー
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, IS_MOBILE and 35 or 45)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = MainWindow
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, IS_MOBILE and 10 or 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Arseus x Neo UI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = IS_MOBILE and 16 or 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = titleBar
    
    -- コントロールボタン
    local controlButtons = Instance.new("Frame")
    controlButtons.Name = "ControlButtons"
    controlButtons.Size = UDim2.new(0, IS_MOBILE and 105 or 140, 1, 0)
    controlButtons.Position = UDim2.new(1, -(IS_MOBILE and 110 or 150), 0, 0)
    controlButtons.BackgroundTransparency = 1
    controlButtons.Parent = titleBar
    
    -- 最小化ボタン
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, IS_MOBILE and 30 or 35, 0, IS_MOBILE and 30 or 35)
    minimizeBtn.Position = UDim2.new(0, 5, 0.5, -(IS_MOBILE and 15 or 17.5))
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = IS_MOBILE and 16 or 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = controlButtons
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
    minCorner.Parent = minimizeBtn
    
    -- 閉じるボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, IS_MOBILE and 30 or 35, 0, IS_MOBILE and 30 or 35)
    closeBtn.Position = UDim2.new(0, IS_MOBILE and 40 or 50, 0.5, -(IS_MOBILE and 15 or 17.5))
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = IS_MOBILE and 18 or 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = controlButtons
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
    closeCorner.Parent = closeBtn
    
    -- 設定ボタン
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "Settings"
    settingsBtn.Size = UDim2.new(0, IS_MOBILE and 30 or 35, 0, IS_MOBILE and 30 or 35)
    settingsBtn.Position = UDim2.new(0, IS_MOBILE and 75 or 95, 0.5, -(IS_MOBILE and 15 or 17.5))
    settingsBtn.BackgroundColor3 = Settings.UIColor
    settingsBtn.AutoButtonColor = false
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = IS_MOBILE and 14 or 16
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.Parent = controlButtons
    
    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
    setCorner.Parent = settingsBtn
    
    -- タブコンテナ
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, IS_MOBILE and 40 or 50)
    tabContainer.Position = UDim2.new(0, 0, 0, IS_MOBILE and 35 or 45)
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    tabContainer.BackgroundTransparency = 0.1
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = MainWindow
    
    -- タブボタン
    local tabs = {"Main", "Player", "Visual", "Settings"}
    local tabButtons = {}
    local activeTab = "Main"
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(0.25, 0, 1, 0)
        tabButton.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabButton.TextSize = IS_MOBILE and 14 or 16
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Parent = tabContainer
        
        -- アクティブなタブのハイライト
        if tabName == "Main" then
            tabButton.TextColor3 = Settings.UIColor
        end
        
        tabButtons[tabName] = tabButton
        
        -- タブ切り替え
        tabButton.MouseButton1Click:Connect(function()
            if activeTab == tabName then return end
            
            activeTab = tabName
            
            -- タブの色を更新
            for name, btn in pairs(tabButtons) do
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(btn, tweenInfo, {
                    TextColor3 = name == tabName and Settings.UIColor or Color3.fromRGB(150, 150, 150)
                })
                tween:Play()
            end
            
            -- タブコンテンツを更新
            UpdateTabContent(tabName)
        end)
    end
    
    -- タブインジケーター
    local tabIndicator = Instance.new("Frame")
    tabIndicator.Name = "TabIndicator"
    tabIndicator.Size = UDim2.new(0.25, IS_MOBILE and -15 or -20, 0, 3)
    tabIndicator.Position = UDim2.new(0, IS_MOBILE and 7.5 or 10, 1, -3)
    tabIndicator.BackgroundColor3 = Settings.UIColor
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Parent = tabContainer
    
    -- コンテンツフレーム
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, IS_MOBILE and -10 or -20, 1, IS_MOBILE and -85 or -110)
    contentFrame.Position = UDim2.new(0, IS_MOBILE and 5 or 10, 0, IS_MOBILE and 80 or 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = IS_MOBILE and 4 or 6
    contentFrame.ScrollBarImageColor3 = Settings.UIColor
    contentFrame.ScrollBarImageTransparency = 0.5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    contentFrame.Parent = MainWindow
    
    -- スムーズドラッグ機能
    CreateSmoothDrag(MainWindow, titleBar)
    
    -- ボタンアニメーションを適用
    CreateButtonAnimation(minimizeBtn)
    CreateButtonAnimation(closeBtn)
    CreateButtonAnimation(settingsBtn)
    
    for _, tabButton in pairs(tabButtons) do
        CreateButtonAnimation(tabButton)
    end
    
    -- 最小化機能
    local isMinimized = false
    local originalSize = MainWindow.Size
    local originalPosition = MainWindow.Position
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        if isMinimized then
            -- 最小化
            local tween = TweenService:Create(MainWindow, tweenInfo, {
                Size = UDim2.new(0, uiSize.X.Offset, 0, IS_MOBILE and 35 or 45),
                Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset,
                                   originalPosition.Y.Scale, originalPosition.Y.Offset + uiSize.Y.Offset - (IS_MOBILE and 35 or 45))
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                tabContainer.Visible = false
                contentFrame.Visible = false
            end)
        else
            -- 元に戻す
            tabContainer.Visible = true
            contentFrame.Visible = true
            
            local tween = TweenService:Create(MainWindow, tweenInfo, {
                Size = originalSize,
                Position = originalPosition
            })
            tween:Play()
        end
    end)
    
    -- 削除確認機能
    closeBtn.MouseButton1Click:Connect(function()
        -- 確認ダイアログの作成
        local confirmDialog = Instance.new("Frame")
        confirmDialog.Name = "ConfirmDialog"
        confirmDialog.Size = UDim2.new(0, IS_MOBILE and 280 or 350, 0, IS_MOBILE and 150 or 180)
        confirmDialog.Position = UDim2.new(0.5, -(IS_MOBILE and 140 or 175), 0.5, -(IS_MOBILE and 75 or 90))
        confirmDialog.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        confirmDialog.BackgroundTransparency = 0.05
        confirmDialog.BorderSizePixel = 0
        confirmDialog.ZIndex = 1000
        confirmDialog.Parent = MainWindow
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, IS_MOBILE and 12 or 15)
        confirmCorner.Parent = confirmDialog
        
        local confirmShadow = Instance.new("ImageLabel")
        confirmShadow.Size = UDim2.new(1, 20, 1, 20)
        confirmShadow.Position = UDim2.new(0, -10, 0, -10)
        confirmShadow.BackgroundTransparency = 1
        confirmShadow.Image = "rbxassetid://5554236805"
        confirmShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        confirmShadow.ImageTransparency = 0.8
        confirmShadow.ScaleType = Enum.ScaleType.Slice
        confirmShadow.SliceCenter = Rect.new(10, 10, 118, 118)
        confirmShadow.ZIndex = 999
        confirmShadow.Parent = confirmDialog
        
        -- 警告アイコン
        local warningIcon = Instance.new("TextLabel")
        warningIcon.Size = UDim2.new(1, 0, 0, IS_MOBILE and 40 or 50)
        warningIcon.Position = UDim2.new(0, 0, 0, IS_MOBILE and 15 or 20)
        warningIcon.BackgroundTransparency = 1
        warningIcon.Text = "⚠️"
        warningIcon.TextColor3 = Color3.fromRGB(255, 200, 50)
        warningIcon.TextSize = IS_MOBILE and 30 or 40
        warningIcon.Font = Enum.Font.GothamBold
        warningIcon.Parent = confirmDialog
        
        -- 確認メッセージ
        local confirmText = Instance.new("TextLabel")
        confirmText.Size = UDim2.new(1, IS_MOBILE and -30 or -40, 0, IS_MOBILE and 40 or 50)
        confirmText.Position = UDim2.new(0, IS_MOBILE and 15 or 20, 0, IS_MOBILE and 65 or 80)
        confirmText.BackgroundTransparency = 1
        confirmText.Text = "本当にUIを削除しますか？"
        confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmText.TextSize = IS_MOBILE and 16 or 20
        confirmText.Font = Enum.Font.GothamBold
        confirmText.TextWrapped = true
        confirmText.Parent = confirmDialog
        
        -- ボタンコンテナ
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, IS_MOBILE and -30 or -40, 0, IS_MOBILE and 40 or 50)
        buttonContainer.Position = UDim2.new(0, IS_MOBILE and 15 or 20, 1, IS_MOBILE and -55 or -70)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = confirmDialog
        
        -- はいボタン
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0, IS_MOBILE and 100 or 120, 0, IS_MOBILE and 35 or 40)
        yesBtn.Position = UDim2.new(0, 0, 0, 0)
        yesBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        yesBtn.AutoButtonColor = false
        yesBtn.Text = "はい"
        yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesBtn.TextSize = IS_MOBILE and 16 or 18
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.Parent = buttonContainer
        
        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
        yesCorner.Parent = yesBtn
        
        -- いいえボタン
        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0, IS_MOBILE and 100 or 120, 0, IS_MOBILE and 35 or 40)
        noBtn.Position = UDim2.new(1, IS_MOBILE and -100 or -120, 0, 0)
        noBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        noBtn.AutoButtonColor = false
        noBtn.Text = "いいえ"
        noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        noBtn.TextSize = IS_MOBILE and 16 or 18
        noBtn.Font = Enum.Font.GothamBold
        noBtn.Parent = buttonContainer
        
        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
        noCorner.Parent = noBtn
        
        -- ボタンアニメーションを適用
        CreateButtonAnimation(yesBtn)
        CreateButtonAnimation(noBtn)
        
        -- はいボタン機能
        yesBtn.MouseButton1Click:Connect(function()
            -- UIを閉じるアニメーション
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            
            local tween1 = TweenService:Create(MainWindow, tweenInfo, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            })
            
            local tween2 = TweenService:Create(shadow, tweenInfo, {
                ImageTransparency = 1
            })
            
            tween1:Play()
            tween2:Play()
            
            tween1.Completed:Connect(function()
                MainWindow:Destroy()
                MainWindow = nil
                
                -- クロスヘアも削除
                if CrosshairGui then
                    CrosshairGui:Destroy()
                    CrosshairGui = nil
                end
            end)
        end)
        
        -- いいえボタン機能
        noBtn.MouseButton1Click:Connect(function()
            -- 確認ダイアログを閉じる
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(confirmDialog, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -(IS_MOBILE and 140 or 175), 0.5, -(IS_MOBILE and 70 or 80))
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                confirmDialog:Destroy()
            end)
        end)
    end)
    
    -- 設定ボタン機能
    settingsBtn.MouseButton1Click:Connect(function()
        if activeTab ~= "Settings" then
            activeTab = "Settings"
            
            -- タブの色を更新
            for name, btn in pairs(tabButtons) do
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(btn, tweenInfo, {
                    TextColor3 = name == "Settings" and Settings.UIColor or Color3.fromRGB(150, 150, 150)
                })
                tween:Play()
            end
            
            -- タブインジケーターを移動
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(tabIndicator, tweenInfo, {
                Position = UDim2.new(0.75, IS_MOBILE and 7.5 or 10, 1, -3)
            })
            tween:Play()
            
            UpdateTabContent("Settings")
        end
    end)
    
    -- タブコンテンツ更新関数
    local function UpdateTabContent(tabName)
        -- コンテンツをクリア
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                child:Destroy()
            end
        end
        
        -- タブインジケーターを移動
        local indicatorPositions = {
            Main = 0,
            Player = 0.25,
            Visual = 0.5,
            Settings = 0.75
        }
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(tabIndicator, tweenInfo, {
            Position = UDim2.new(indicatorPositions[tabName], IS_MOBILE and 7.5 or 10, 1, -3)
        })
        tween:Play()
        
        -- タブに応じたコンテンツを作成
        if tabName == "Main" then
            CreateMainTab(contentFrame)
        elseif tabName == "Player" then
            CreatePlayerTab(contentFrame)
        elseif tabName == "Visual" then
            CreateVisualTab(contentFrame)
        elseif tabName == "Settings" then
            CreateSettingsTab(contentFrame)
        end
    end
    
    -- セクション作成関数
    local function CreateSection(title, parent, yPosition)
        local section = Instance.new("Frame")
        section.Name = title .. "Section"
        section.Size = UDim2.new(1, 0, 0, IS_MOBILE and 40 or 50)
        section.Position = UDim2.new(0, 0, 0, yPosition)
        section.BackgroundTransparency = 1
        section.Parent = parent
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "Title"
        sectionTitle.Size = UDim2.new(1, 0, 1, 0)
        sectionTitle.Position = UDim2.new(0, 0, 0, 0)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = title
        sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        sectionTitle.TextSize = IS_MOBILE and 18 or 22
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = section
        
        local sectionLine = Instance.new("Frame")
        sectionLine.Name = "Line"
        sectionLine.Size = UDim2.new(1, 0, 0, 2)
        sectionLine.Position = UDim2.new(0, 0, 1, -2)
        sectionLine.BackgroundColor3 = Settings.UIColor
        sectionLine.BackgroundTransparency = 0.5
        sectionLine.BorderSizePixel = 0
        sectionLine.Parent = section
        
        return section, sectionLine
    end
    
    -- トグルスイッチ作成関数
    local function CreateToggle(label, parent, yPosition, defaultValue, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = label .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, IS_MOBILE and 35 or 40)
        toggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        toggleLabel.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = label
        toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        toggleLabel.TextSize = IS_MOBILE and 14 or 16
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleBackground = Instance.new("Frame")
        toggleBackground.Name = "Background"
        toggleBackground.Size = UDim2.new(0, IS_MOBILE and 50 or 60, 0, IS_MOBILE and 25 or 30)
        toggleBackground.Position = UDim2.new(1, -(IS_MOBILE and 55 or 70), 0.5, -(IS_MOBILE and 12.5 or 15))
        toggleBackground.BackgroundColor3 = defaultValue and Settings.UIColor or Color3.fromRGB(60, 60, 70)
        toggleBackground.BorderSizePixel = 0
        toggleBackground.Parent = toggleFrame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = toggleBackground
        
        local toggleButton = Instance.new("Frame")
        toggleButton.Name = "Button"
        toggleButton.Size = UDim2.new(0, IS_MOBILE and 21 or 26, 0, IS_MOBILE and 21 or 26)
        toggleButton.Position = defaultValue and UDim2.new(1, -(IS_MOBILE and 28 or 33), 0.5, -(IS_MOBILE and 10.5 or 13)) 
                           or UDim2.new(0, 2, 0.5, -(IS_MOBILE and 10.5 or 13))
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.BorderSizePixel = 0
        toggleButton.Parent = toggleFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = toggleButton
        
        local enabled = defaultValue
        
        toggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if enabled then
                    local tween1 = TweenService:Create(toggleButton, tweenInfo, 
                        {Position = UDim2.new(1, -(IS_MOBILE and 28 or 33), 0.5, -(IS_MOBILE and 10.5 or 13))})
                    local tween2 = TweenService:Create(toggleBackground, tweenInfo, 
                        {BackgroundColor3 = Settings.UIColor})
                    tween1:Play()
                    tween2:Play()
                else
                    local tween1 = TweenService:Create(toggleButton, tweenInfo, 
                        {Position = UDim2.new(0, 2, 0.5, -(IS_MOBILE and 10.5 or 13))})
                    local tween2 = TweenService:Create(toggleBackground, tweenInfo, 
                        {BackgroundColor3 = Color3.fromRGB(60, 60, 70)})
                    tween1:Play()
                    tween2:Play()
                end
                
                if callback then
                    callback(enabled)
                end
            end
        end)
        
        return toggleFrame
    end
    
    -- スライダー作成関数
    local function CreateSlider(label, parent, yPosition, minValue, maxValue, defaultValue, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = label .. "Slider"
        sliderFrame.Size = UDim2.new(1, 0, 0, IS_MOBILE and 55 or 60)
        sliderFrame.Position = UDim2.new(0, 0, 0, yPosition)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Size = UDim2.new(0.6, 0, 0, IS_MOBILE and 25 or 30)
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = label .. ": " .. defaultValue
        sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        sliderLabel.TextSize = IS_MOBILE and 14 or 16
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local sliderValue = Instance.new("TextLabel")
        sliderValue.Name = "Value"
        sliderValue.Size = UDim2.new(0.4, 0, 0, IS_MOBILE and 25 or 30)
        sliderValue.Position = UDim2.new(0.6, 0, 0, 0)
        sliderValue.BackgroundTransparency = 1
        sliderValue.Text = tostring(defaultValue)
        sliderValue.TextColor3 = Settings.UIColor
        sliderValue.TextSize = IS_MOBILE and 14 or 16
        sliderValue.Font = Enum.Font.Gotham
        sliderValue.TextXAlignment = Enum.TextXAlignment.Right
        sliderValue.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Name = "Bar"
        sliderBar.Size = UDim2.new(1, 0, 0, IS_MOBILE and 6 or 8)
        sliderBar.Position = UDim2.new(0, 0, 0, IS_MOBILE and 30 or 35)
        sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = sliderFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = sliderBar
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
        sliderFill.Position = UDim2.new(0, 0, 0, 0)
        sliderFill.BackgroundColor3 = Settings.UIColor
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = sliderFill
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Name = "Button"
        sliderButton.Size = UDim2.new(0, IS_MOBILE and 16 or 20, 0, IS_MOBILE and 16 or 20)
        sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 
                                         -(IS_MOBILE and 8 or 10), 0.5, -(IS_MOBILE and 8 or 10))
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.AutoButtonColor = false
        sliderButton.Text = ""
        sliderButton.Parent = sliderFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = sliderButton
        
        local dragging = false
        
        local function UpdateSlider(value)
            value = math.clamp(value, minValue, maxValue)
            local percent = (value - minValue) / (maxValue - minValue)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -(IS_MOBILE and 8 or 10), 0.5, -(IS_MOBILE and 8 or 10))
            sliderValue.Text = tostring(value)
            sliderLabel.Text = label .. ": " .. value
            
            if callback then
                callback(value)
            end
        end
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local mousePos = UserInputService:GetMouseLocation()
                local barAbsolutePos = sliderBar.AbsolutePosition
                local barAbsoluteSize = sliderBar.AbsoluteSize.X
                
                local relativeX = math.clamp(mousePos.X - barAbsolutePos.X, 0, barAbsoluteSize)
                local value = minValue + (relativeX / barAbsoluteSize) * (maxValue - minValue)
                UpdateSlider(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local mousePos = UserInputService:GetMouseLocation()
                local barAbsolutePos = sliderBar.AbsolutePosition
                local barAbsoluteSize = sliderBar.AbsoluteSize.X
                
                local relativeX = math.clamp(mousePos.X - barAbsolutePos.X, 0, barAbsoluteSize)
                local value = minValue + (relativeX / barAbsoluteSize) * (maxValue - minValue)
                UpdateSlider(value)
            end
        end)
        
        return sliderFrame
    end
    
    -- カラーピッカー作成関数
    local function CreateColorPicker(label, parent, yPosition, colors, defaultIndex, callback)
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Name = label .. "ColorPicker"
        pickerFrame.Size = UDim2.new(1, 0, 0, IS_MOBILE and 70 or 80)
        pickerFrame.Position = UDim2.new(0, 0, 0, yPosition)
        pickerFrame.BackgroundTransparency = 1
        pickerFrame.Parent = parent
        
        local pickerLabel = Instance.new("TextLabel")
        pickerLabel.Name = "Label"
        pickerLabel.Size = UDim2.new(1, 0, 0, IS_MOBILE and 25 or 30)
        pickerLabel.Position = UDim2.new(0, 0, 0, 0)
        pickerLabel.BackgroundTransparency = 1
        pickerLabel.Text = label
        pickerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        pickerLabel.TextSize = IS_MOBILE and 14 or 16
        pickerLabel.Font = Enum.Font.Gotham
        pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
        pickerLabel.Parent = pickerFrame
        
        local colorContainer = Instance.new("Frame")
        colorContainer.Name = "ColorContainer"
        colorContainer.Size = UDim2.new(1, 0, 0, IS_MOBILE and 35 or 40)
        colorContainer.Position = UDim2.new(0, 0, 0, IS_MOBILE and 30 or 35)
        colorContainer.BackgroundTransparency = 1
        colorContainer.Parent = pickerFrame
        
        local colorButtons = {}
        local buttonSize = IS_MOBILE and 25 or 30
        local spacing = IS_MOBILE and 8 or 10
        local buttonsPerRow = IS_MOBILE and 5 or 6
        
        for i, color in ipairs(colors) do
            local row = math.floor((i-1) / buttonsPerRow)
            local col = (i-1) % buttonsPerRow
            
            local colorButton = Instance.new("TextButton")
            colorButton.Name = "Color" .. i
            colorButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
            colorButton.Position = UDim2.new(0, col * (buttonSize + spacing), 0, row * (buttonSize + spacing))
            colorButton.BackgroundColor3 = color
            colorButton.AutoButtonColor = false
            colorButton.Text = ""
            colorButton.Parent = colorContainer
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, IS_MOBILE and 4 or 6)
            colorCorner.Parent = colorButton
            
            CreateButtonAnimation(colorButton)
            
            -- 選択インジケーター
            if i == defaultIndex then
                local selection = Instance.new("Frame")
                selection.Name = "Selection"
                selection.Size = UDim2.new(1, 4, 1, 4)
                selection.Position = UDim2.new(0, -2, 0, -2)
                selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                selection.BorderSizePixel = 0
                selection.Parent = colorButton
                
                local selectionCorner = Instance.new("UICorner")
                selectionCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
                selectionCorner.Parent = selection
            end
            
            colorButton.MouseButton1Click:Connect(function()
                -- 他のボタンの選択を解除
                for _, btn in ipairs(colorButtons) do
                    if btn.Selection then
                        btn.Selection:Destroy()
                    end
                end
                
                -- 新しい選択を追加
                local selection = Instance.new("Frame")
                selection.Name = "Selection"
                selection.Size = UDim2.new(1, 4, 1, 4)
                selection.Position = UDim2.new(0, -2, 0, -2)
                selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                selection.BorderSizePixel = 0
                selection.Parent = colorButton
                
                local selectionCorner = Instance.new("UICorner")
                selectionCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
                selectionCorner.Parent = selection
                
                if callback then
                    callback(color, i)
                end
            end)
            
            table.insert(colorButtons, colorButton)
        end
        
        return pickerFrame
    end
    
    -- ドロップダウン作成関数
    local function CreateDropdown(label, parent, yPosition, options, defaultOption, callback)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = label .. "Dropdown"
        dropdownFrame.Size = UDim2.new(1, 0, 0, IS_MOBILE and 35 or 40)
        dropdownFrame.Position = UDim2.new(0, 0, 0, yPosition)
        dropdownFrame.BackgroundTransparency = 1
        dropdownFrame.Parent = parent
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Name = "Label"
        dropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
        dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = label .. ":"
        dropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        dropdownLabel.TextSize = IS_MOBILE and 14 or 16
        dropdownLabel.Font = Enum.Font.Gotham
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "Button"
        dropdownButton.Size = UDim2.new(0.6, 0, 1, 0)
        dropdownButton.Position = UDim2.new(0.4, 0, 0, 0)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        dropdownButton.AutoButtonColor = false
        dropdownButton.Text = defaultOption
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.TextSize = IS_MOBILE and 12 or 14
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.Parent = dropdownFrame
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
        dropdownCorner.Parent = dropdownButton
        
        CreateButtonAnimation(dropdownButton)
        
        local dropdownOpen = false
        local dropdownList
        
        local function CloseDropdown()
            if dropdownList then
                dropdownList:Destroy()
                dropdownList = nil
            end
            dropdownOpen = false
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            if dropdownOpen then
                CloseDropdown()
                return
            end
            
            dropdownOpen = true
            
            -- ドロップダウンリストを作成
            dropdownList = Instance.new("Frame")
            dropdownList.Name = "DropdownList"
            dropdownList.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, IS_MOBILE and 30 * #options or 35 * #options)
            dropdownList.Position = UDim2.new(0, dropdownButton.AbsolutePosition.X - dropdownFrame.AbsolutePosition.X,
                                            1, 5)
            dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            dropdownList.BorderSizePixel = 0
            dropdownList.ZIndex = 1000
            dropdownList.Parent = dropdownFrame
            
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
            listCorner.Parent = dropdownList
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = dropdownList
            
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option" .. i
                optionButton.Size = UDim2.new(1, 0, 0, IS_MOBILE and 28 or 33)
                optionButton.Position = UDim2.new(0, 0, 0, (i-1) * (IS_MOBILE and 30 or 35))
                optionButton.BackgroundColor3 = option == dropdownButton.Text and Settings.UIColor or Color3.fromRGB(40, 40, 55)
                optionButton.AutoButtonColor = false
                optionButton.Text = option
                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.TextSize = IS_MOBILE and 12 or 14
                optionButton.Font = Enum.Font.Gotham
                optionButton.LayoutOrder = i
                optionButton.Parent = dropdownList
                
                local optionCorner = Instance.new("UICorner")
                optionCorner.CornerRadius = UDim.new(0, IS_MOBILE and 4 or 6)
                optionCorner.Parent = optionButton
                
                CreateButtonAnimation(optionButton)
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = option
                    CloseDropdown()
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            -- クリックアウトで閉じる
            local clickOutConnection
            clickOutConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    local mousePos = UserInputService:GetMouseLocation()
                    local listAbsPos = dropdownList.AbsolutePosition
                    local listAbsSize = dropdownList.AbsoluteSize
                    
                    if not (mousePos.X >= listAbsPos.X and mousePos.X <= listAbsPos.X + listAbsSize.X and
                           mousePos.Y >= listAbsPos.Y and mousePos.Y <= listAbsPos.Y + listAbsSize.Y) then
                        CloseDropdown()
                        clickOutConnection:Disconnect()
                    end
                end
            end)
        end)
        
        return dropdownFrame
    end
    
    -- Mainタブ作成
    local function CreateMainTab(parent)
        local yOffset = 0
        
        -- 移動セクション
        local movementSection, movementLine = CreateSection("移動設定", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- スピードチェンジ
        local speedSlider = CreateSlider("移動速度", parent, yOffset, 1, 100, Settings.Player.WalkSpeed, function(value)
            Settings.Player.WalkSpeed = value
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = value
            end
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- ジャンプ力
        local jumpSlider = CreateSlider("ジャンプ力", parent, yOffset, 1, 200, Settings.Player.JumpPower, function(value)
            Settings.Player.JumpPower = value
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = value
            end
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- 無限ジャンプ
        local infiniteJumpToggle = CreateToggle("無限ジャンプ", parent, yOffset, Settings.Player.InfiniteJump, function(enabled)
            Settings.Player.InfiniteJump = enabled
            -- 無限ジャンプ機能の実装は別途必要
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- 自動スプリント
        local autoSprintToggle = CreateToggle("自動スプリント", parent, yOffset, Settings.Player.AutoSprint, function(enabled)
            Settings.Player.AutoSprint = enabled
            -- 自動スプリント機能の実装は別途必要
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- Flyセクション
        local flySection, flyLine = CreateSection("Fly機能", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- Fly有効化
        local flyToggle = CreateToggle("Fly有効", parent, yOffset, Settings.Player.FlyEnabled, function(enabled)
            Settings.Player.FlyEnabled = enabled
            -- Fly機能の実装は別途必要
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- Fly速度
        local flySpeedSlider = CreateSlider("Fly速度", parent, yOffset, 1, 200, Settings.Player.FlySpeed, function(value)
            Settings.Player.FlySpeed = value
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- Flyモード
        local flyModes = {"Classic", "CFrame", "BodyVelocity", "Advanced"}
        local flyModeDropdown = CreateDropdown("Flyモード", parent, yOffset, flyModes, "Classic", function(option)
            -- Flyモード変更の実装は別途必要
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- Noclipセクション
        local noclipSection, noclipLine = CreateSection("Noclip", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- Noclip有効化
        local noclipToggle = CreateToggle("Noclip有効", parent, yOffset, Settings.Player.NoClip, function(enabled)
            Settings.Player.NoClip = enabled
            -- Noclip機能の実装は別途必要
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- キャンバスサイズを更新
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    
    -- Playerタブ作成
    local function CreatePlayerTab(parent)
        local yOffset = 0
        
        -- プレイヤー設定セクション
        local playerSection, playerLine = CreateSection("プレイヤー設定", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- グラビティ
        local gravitySlider = CreateSlider("重力", parent, yOffset, 0, 500, Settings.Player.Gravity, function(value)
            Settings.Player.Gravity = value
            if workspace then
                workspace.Gravity = value
            end
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- ヒップハイト
        local hipHeightSlider = CreateSlider("ヒップハイト", parent, yOffset, 0, 20, Settings.Player.HipHeight, function(value)
            Settings.Player.HipHeight = value
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.HipHeight = value
            end
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- キャンバスサイズを更新
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    
    -- Visualタブ作成
    local function CreateVisualTab(parent)
        local yOffset = 0
        
        -- クロスヘアセクション
        local crosshairSection, crosshairLine = CreateSection("クロスヘア設定", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- クロスヘア有効化
        local crosshairToggle = CreateToggle("クロスヘア表示", parent, yOffset, Settings.Crosshair.Enabled, function(enabled)
            Settings.Crosshair.Enabled = enabled
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- クロスヘアタイプ
        local crosshairTypeOptions = {}
        for _, crosshairType in ipairs(CrosshairTypes) do
            table.insert(crosshairTypeOptions, crosshairType.Name)
        end
        
        local crosshairTypeDropdown = CreateDropdown("クロスヘアタイプ", parent, yOffset, crosshairTypeOptions, 
                                                    Settings.Crosshair.Type, function(option)
            Settings.Crosshair.Type = option
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- クロスヘアカラー
        local crosshairColorPicker = CreateColorPicker("クロスヘア色", parent, yOffset, ColorPalette, 1, function(color, index)
            Settings.Crosshair.Color = color
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 75 or 85)
        
        -- クロスヘアサイズ
        local crosshairSizeSlider = CreateSlider("クロスヘアサイズ", parent, yOffset, 5, 100, Settings.Crosshair.Size, function(value)
            Settings.Crosshair.Size = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- クロスヘア太さ
        local crosshairThicknessSlider = CreateSlider("クロスヘア太さ", parent, yOffset, 1, 10, Settings.Crosshair.Thickness, function(value)
            Settings.Crosshair.Thickness = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- クロスヘアギャップ
        local crosshairGapSlider = CreateSlider("クロスヘアギャップ", parent, yOffset, 0, 20, Settings.Crosshair.Gap, function(value)
            Settings.Crosshair.Gap = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- クロスヘア透明度
        local crosshairAlphaSlider = CreateSlider("透明度", parent, yOffset, 0, 100, Settings.Crosshair.Alpha * 100, function(value)
            Settings.Crosshair.Alpha = value / 100
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- クロスヘア回転
        local crosshairRotationSlider = CreateSlider("回転", parent, yOffset, 0, 360, Settings.Crosshair.Rotation, function(value)
            Settings.Crosshair.Rotation = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- アウトライン
        local crosshairOutlineToggle = CreateToggle("アウトライン表示", parent, yOffset, Settings.Crosshair.Outline, function(enabled)
            Settings.Crosshair.Outline = enabled
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- 点滅効果
        local crosshairBlinkingToggle = CreateToggle("点滅効果", parent, yOffset, Settings.Crosshair.Blinking, function(enabled)
            Settings.Crosshair.Blinking = enabled
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- 中心点表示
        local crosshairDotToggle = CreateToggle("中心点表示", parent, yOffset, Settings.Crosshair.ShowDot, function(enabled)
            Settings.Crosshair.ShowDot = enabled
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- キャンバスサイズを更新
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    
    -- Settingsタブ作成
    local function CreateSettingsTab(parent)
        local yOffset = 0
        
        -- UI設定セクション
        local uiSection, uiLine = CreateSection("UI設定", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- UIカラー
        local uiColorPicker = CreateColorPicker("UIカラー", parent, yOffset, ColorPalette, 1, function(color, index)
            Settings.UIColor = color
            -- UIの色を更新
            settingsBtn.BackgroundColor3 = color
            tabIndicator.BackgroundColor3 = color
            
            -- すべてのセクションラインを更新
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("Frame") and child:FindFirstChild("Line") then
                    child.Line.BackgroundColor3 = color
                end
            end
            
            -- アクティブなタブの色を更新
            if tabButtons[activeTab] then
                tabButtons[activeTab].TextColor3 = color
            end
            
            -- クロスヘアも更新
            UpdateCrosshair()
        end)
        yOffset = yOffset + (IS_MOBILE and 75 or 85)
        
        -- UI形状
        local uiShapeOptions = {}
        for _, shape in ipairs(ShapeTypes) do
            table.insert(uiShapeOptions, shape.Name)
        end
        
        local uiShapeDropdown = CreateDropdown("UI形状", parent, yOffset, uiShapeOptions, Settings.UIShape, function(option)
            Settings.UIShape = option
            ApplyUIShape(MainWindow, option)
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- UI透過度
        local transparencySlider = CreateSlider("UI透過度", parent, yOffset, 0, 100, Settings.Transparency * 100, function(value)
            Settings.Transparency = value / 100
            MainWindow.BackgroundTransparency = Settings.Transparency
            titleBar.BackgroundTransparency = Settings.Transparency
            tabContainer.BackgroundTransparency = Settings.Transparency
        end)
        yOffset = yOffset + (IS_MOBILE and 60 or 65)
        
        -- シフトロックセクション
        local shiftLockSection, shiftLockLine = CreateSection("シフトロック", parent, yOffset)
        yOffset = yOffset + (IS_MOBILE and 45 or 55)
        
        -- シフトロック有効化
        local shiftLockToggle = CreateToggle("シフトロック有効", parent, yOffset, Settings.Visual.ShiftLock, function(enabled)
            Settings.Visual.ShiftLock = enabled
            ToggleShiftLock(enabled)
        end)
        yOffset = yOffset + (IS_MOBILE and 40 or 45)
        
        -- キャンバスサイズを更新
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
    end
    
    -- 初期タブを設定
    UpdateTabContent("Main")
    
    print("メインウィンドウの作成が完了しました！")
end

-- 初期化
CreateAuthWindow()

-- デバッグメッセージ
print("⚡ Arseus x Neo UI v3.0 loaded successfully!")
print("🔒 Security Password: しゅーくりーむ")
print("📱 Device: " .. (IS_MOBILE and "Mobile" or IS_DESKTOP and "Desktop" or "Console"))
print("🎨 Features:")
print("  - Responsive design for Mobile/Desktop")
print("  - 12 color themes")
print("  - 10 UI shapes (Rounded, Square, Circle, Swastika, Diamond, etc.)")
print("  - 12 crosshair types with full customization")
print("  - Shift lock system")
print("  - Smooth animations and transitions")
print("  - Draggable, minimizable, and closable windows")
print("  - Two-step deletion confirmation")
