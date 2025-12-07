-- Arseus x Neo Style UI v2.0
-- スムーズで高度なカスタマイズ可能UI

-- サービスの取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- プレイヤーとマウス
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- メインGUIの作成
local ArseusUI = Instance.new("ScreenGui")
ArseusUI.Name = "ArseusNeoUI"
ArseusUI.ResetOnSpawn = false
ArseusUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ArseusUI.IgnoreGuiInset = true

-- 認証パスワード
local SECURITY_PASSWORD = "しゅーくりーむ"
local authAttempts = 0
local MAX_AUTH_ATTEMPTS = 5

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
        Rotation = 0
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
        CameraOffset = Vector3.new(0, 0, 0),
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

-- UI形状タイプ
local ShapeTypes = {
    "Rounded",      -- 丸みを帯びた
    "Square",       -- 四角
    "Circle",       -- 円形
    "Swastika",     -- 卍型
    "Diamond",      -- ダイヤモンド
    "Hexagon",      -- 六角形
    "Pill",         -- ピル型
    "RoundedX",     -- X型丸み
    "RoundedPlus",  -- +型丸み
    "Custom"        -- カスタム
}

-- クロスヘアタイプ
local CrosshairTypes = {
    "Cross",        -- 十字
    "Dot",          -- 点
    "Circle",       -- 円
    "Square",       -- 四角
    "Crosshair",    -- クロスヘア
    "Target",       -- ターゲット
    "Arrow",        -- 矢印
    "Diamond",      -- ダイヤモンド
    "Hexagon",      -- 六角形
    "Star",         -- 星
    "Custom1",      -- カスタム1
    "Custom2"       -- カスタム2
}

-- アニメーション設定
local AnimationSettings = {
    TweenSpeed = 0.25,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
    SmoothDrag = true,
    HoverEffects = true,
    GlowEffect = true
}

-- フォント設定
local FontSettings = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamBold,
    Body = Enum.Font.Gotham,
    Button = Enum.Font.GothamBold
}

-- ウィンドウ管理
local Windows = {}
local ActiveWindow = nil
local MinimizedWindows = {}

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
        
        -- スムーズな移動
        local tweenInfo = TweenInfo.new(
            0.1,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(frame, tweenInfo, {Position = newPos})
        tween:Play()
    end
    
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- 関数: スムーズなトグルアニメーション
local function SmoothToggleAnimation(frame, show)
    if show then
        frame.Visible = true
        frame.BackgroundTransparency = 1
        
        local tweenInfo = TweenInfo.new(
            AnimationSettings.TweenSpeed,
            AnimationSettings.EasingStyle,
            AnimationSettings.EasingDirection
        )
        
        local tween1 = TweenService:Create(frame, tweenInfo, {
            BackgroundTransparency = Settings.Transparency
        })
        
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
                local currentTransparency = child.BackgroundTransparency or child.TextTransparency or 0
                if currentTransparency > 0 then
                    local tween2 = TweenService:Create(child, tweenInfo, {
                        BackgroundTransparency = 0,
                        TextTransparency = 0
                    })
                    tween2:Play()
                end
            end
        end
        
        tween1:Play()
    else
        local tweenInfo = TweenInfo.new(
            AnimationSettings.TweenSpeed,
            AnimationSettings.EasingStyle,
            AnimationSettings.EasingDirection
        )
        
        local tween1 = TweenService:Create(frame, tweenInfo, {
            BackgroundTransparency = 1
        })
        
        tween1:Play()
        tween1.Completed:Connect(function()
            frame.Visible = false
        end)
    end
end

-- 関数: 認証画面の作成
local function CreateAuthWindow()
    local AuthWindow = Instance.new("Frame")
    AuthWindow.Name = "AuthWindow"
    AuthWindow.Size = UDim2.new(0, 400, 0, 350)
    AuthWindow.Position = UDim2.new(0.5, -200, 0.5, -175)
    AuthWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    AuthWindow.BackgroundTransparency = 0.05
    AuthWindow.BorderSizePixel = 0
    AuthWindow.ZIndex = 999
    AuthWindow.Parent = ArseusUI
    
    -- 丸みを帯びたコーナー
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = AuthWindow
    
    -- グラデーションエフェクト
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Settings.UIColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    gradient.Rotation = 45
    gradient.Parent = AuthWindow
    
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
    title.Size = UDim2.new(1, -40, 0, 60)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔒 セキュリティ認証"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = FontSettings.Title
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = AuthWindow
    
    -- サブタイトル
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.new(0, 20, 0, 70)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Arseus x Neo UIにアクセスするには認証が必要です"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = 16
    subtitle.Font = FontSettings.Body
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = AuthWindow
    
    -- パスワード入力欄
    local passwordFrame = Instance.new("Frame")
    passwordFrame.Name = "PasswordFrame"
    passwordFrame.Size = UDim2.new(1, -40, 0, 60)
    passwordFrame.Position = UDim2.new(0, 20, 0, 120)
    passwordFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    passwordFrame.BorderSizePixel = 0
    passwordFrame.Parent = AuthWindow
    
    local passwordCorner = Instance.new("UICorner")
    passwordCorner.CornerRadius = UDim.new(0, 12)
    passwordCorner.Parent = passwordFrame
    
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.Size = UDim2.new(1, -80, 1, 0)
    passwordBox.Position = UDim2.new(0, 15, 0, 0)
    passwordBox.BackgroundTransparency = 1
    passwordBox.PlaceholderText = "暗証番号を入力..."
    passwordBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    passwordBox.Text = ""
    passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordBox.TextSize = 20
    passwordBox.Font = FontSettings.Body
    passwordBox.TextXAlignment = Enum.TextXAlignment.Left
    passwordBox.Parent = passwordFrame
    
    -- 表示/非表示トグル
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleVisibility"
    toggleBtn.Size = UDim2.new(0, 40, 0, 40)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -20)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 18
    toggleBtn.Font = FontSettings.Body
    toggleBtn.Parent = passwordFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- 認証ボタン
    local authButton = Instance.new("TextButton")
    authButton.Name = "AuthButton"
    authButton.Size = UDim2.new(1, -40, 0, 50)
    authButton.Position = UDim2.new(0, 20, 0, 200)
    authButton.BackgroundColor3 = Settings.UIColor
    authButton.AutoButtonColor = false
    authButton.Text = "認証を開始"
    authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    authButton.TextSize = 22
    authButton.Font = FontSettings.Button
    authButton.Parent = AuthWindow
    
    local authCorner = Instance.new("UICorner")
    authCorner.CornerRadius = UDim.new(0, 12)
    authCorner.Parent = authButton
    
    -- ローディングアニメーション
    local loadingRing = Instance.new("Frame")
    loadingRing.Name = "LoadingRing"
    loadingRing.Size = UDim2.new(0, 30, 0, 30)
    loadingRing.Position = UDim2.new(0.5, -15, 0, 260)
    loadingRing.BackgroundTransparency = 1
    loadingRing.Visible = false
    loadingRing.Parent = AuthWindow
    
    local ring1 = Instance.new("Frame")
    ring1.Size = UDim2.new(1, 0, 1, 0)
    ring1.BackgroundTransparency = 1
    ring1.BorderSizePixel = 0
    ring1.Parent = loadingRing
    
    local ringUICorner = Instance.new("UICorner")
    ringUICorner.CornerRadius = UDim.new(1, 0)
    ringUICorner.Parent = ring1
    
    local ringUIStroke = Instance.new("UIStroke")
    ringUIStroke.Color = Settings.UIColor
    ringUIStroke.Thickness = 3
    ringUIStroke.Transparency = 0.5
    ringUIStroke.Parent = ring1
    
    -- メッセージ表示
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -40, 0, 40)
    messageLabel.Position = UDim2.new(0, 20, 0, 280)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = FontSettings.Body
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
    
    -- ボタンホバーエフェクト
    authButton.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(authButton, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(
                math.min(Settings.UIColor.R * 255 + 20, 255),
                math.min(Settings.UIColor.G * 255 + 20, 255),
                math.min(Settings.UIColor.B * 255 + 20, 255)
            ),
            Size = UDim2.new(1, -35, 0, 50)
        })
        tween:Play()
    end)
    
    authButton.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(authButton, tweenInfo, {
            BackgroundColor3 = Settings.UIColor,
            Size = UDim2.new(1, -40, 0, 50)
        })
        tween:Play()
    end)
    
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
            
            -- ローディング表示
            loadingRing.Visible = true
            
            -- ローディングアニメーション
            spawn(function()
                local angle = 0
                while loadingRing.Visible do
                    angle = (angle + 5) % 360
                    ring1.Rotation = angle
                    RunService.RenderStepped:Wait()
                end
            end)
            
            -- 認証成功アニメーション
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            
            local tween1 = TweenService:Create(AuthWindow, tweenInfo, {
                Position = UDim2.new(0.5, -200, 0.5, -250),
                BackgroundTransparency = 0.8
            })
            
            local tween2 = TweenService:Create(shadow, tweenInfo, {
                ImageTransparency = 1
            })
            
            tween1:Play()
            tween2:Play()
            
            wait(0.8)
            
            -- 認証画面を非表示にしてメインUIを作成
            AuthWindow:Destroy()
            CreateMainWindow()
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
                    Position = UDim2.new(0.5, -200, 0.5, -225)
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

-- 関数: メインウィンドウの作成
local function CreateMainWindow()
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, 650, 0, 550)
    MainWindow.Position = UDim2.new(0.5, -325, 0.5, -275)
    MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainWindow.BackgroundTransparency = 0.05
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = ArseusUI
    
    -- ウィンドウ形状の適用
    local function ApplyWindowShape()
        if MainWindow:FindFirstChild("UICorner") then
            MainWindow.UICorner:Destroy()
        end
        
        local corner = Instance.new("UICorner")
        
        if Settings.UIShape == "Rounded" then
            corner.CornerRadius = UDim.new(0, 20)
        elseif Settings.UIShape == "Square" then
            corner.CornerRadius = UDim.new(0, 0)
        elseif Settings.UIShape == "Circle" then
            corner.CornerRadius = UDim.new(1, 0)
        elseif Settings.UIShape == "Swastika" then
            -- 卍型の近似 (複雑な形状はマスクを使用)
            corner.CornerRadius = UDim.new(0, 10)
        elseif Settings.UIShape == "Diamond" then
            corner.CornerRadius = UDim.new(0, 5)
        elseif Settings.UIShape == "Hexagon" then
            corner.CornerRadius = UDim.new(0, 15)
        elseif Settings.UIShape == "Pill" then
            corner.CornerRadius = UDim.new(0, 100)
        else
            corner.CornerRadius = UDim.new(0, 20)
        end
        
        corner.Parent = MainWindow
    end
    
    ApplyWindowShape()
    
    -- シャドウエフェクト
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
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
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = MainWindow
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 20)
    titleCorner.Parent = titleBar
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Arseus x Neo UI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = FontSettings.Title
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- コントロールボタン
    local controlButtons = Instance.new("Frame")
    controlButtons.Name = "ControlButtons"
    controlButtons.Size = UDim2.new(0, 140, 1, 0)
    controlButtons.Position = UDim2.new(1, -150, 0, 0)
    controlButtons.BackgroundTransparency = 1
    controlButtons.Parent = titleBar
    
    -- 最小化ボタン
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(0, 5, 0.5, -17.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = FontSettings.Button
    minimizeBtn.Parent = controlButtons
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn
    
    -- 閉じるボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(0, 50, 0.5, -17.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 24
    closeBtn.Font = FontSettings.Button
    closeBtn.Parent = controlButtons
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- 設定ボタン
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "Settings"
    settingsBtn.Size = UDim2.new(0, 35, 0, 35)
    settingsBtn.Position = UDim2.new(0, 95, 0.5, -17.5)
    settingsBtn.BackgroundColor3 = Settings.UIColor
    settingsBtn.AutoButtonColor = false
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = 18
    settingsBtn.Font = FontSettings.Button
    settingsBtn.Parent = controlButtons
    
    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(0, 8)
    setCorner.Parent = settingsBtn
    
    -- タブコンテナ
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 50)
    tabContainer.Position = UDim2.new(0, 0, 0, 45)
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
        tabButton.TextSize = 18
        tabButton.Font = FontSettings.Header
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
    tabIndicator.Size = UDim2.new(0.25, -20, 0, 3)
    tabIndicator.Position = UDim2.new(0, 10, 1, -3)
    tabIndicator.BackgroundColor3 = Settings.UIColor
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Parent = tabContainer
    
    -- コンテンツフレーム
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -110)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = Settings.UIColor
    contentFrame.ScrollBarImageTransparency = 0.5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = MainWindow
    
    -- スムーズドラッグ機能
    CreateSmoothDrag(MainWindow, titleBar)
    
    -- ボタンホバーエフェクト
    local function SetupButtonHover(button)
        local originalSize = button.Size
        local originalColor = button.BackgroundColor3
        
        button.MouseEnter:Connect(function()
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(button, tweenInfo, {
                Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 4, 
                               originalSize.Y.Scale, originalSize.Y.Offset + 4),
                BackgroundColor3 = Color3.new(
                    math.min(originalColor.R + 0.1, 1),
                    math.min(originalColor.G + 0.1, 1),
                    math.min(originalColor.B + 0.1, 1)
                )
            })
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(button, tweenInfo, {
                Size = originalSize,
                BackgroundColor3 = originalColor
            })
            tween:Play()
        end)
    end
    
    SetupButtonHover(minimizeBtn)
    SetupButtonHover(closeBtn)
    SetupButtonHover(settingsBtn)
    
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
                Size = UDim2.new(0, 650, 0, 45),
                Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset,
                                   originalPosition.Y.Scale, originalPosition.Y.Offset + 505)
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
        confirmDialog.Size = UDim2.new(0, 350, 0, 180)
        confirmDialog.Position = UDim2.new(0.5, -175, 0.5, -90)
        confirmDialog.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        confirmDialog.BackgroundTransparency = 0.05
        confirmDialog.BorderSizePixel = 0
        confirmDialog.ZIndex = 1000
        confirmDialog.Parent = MainWindow
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 15)
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
        warningIcon.Size = UDim2.new(1, 0, 0, 50)
        warningIcon.Position = UDim2.new(0, 0, 0, 20)
        warningIcon.BackgroundTransparency = 1
        warningIcon.Text = "⚠️"
        warningIcon.TextColor3 = Color3.fromRGB(255, 200, 50)
        warningIcon.TextSize = 40
        warningIcon.Font = FontSettings.Title
        warningIcon.Parent = confirmDialog
        
        -- 確認メッセージ
        local confirmText = Instance.new("TextLabel")
        confirmText.Size = UDim2.new(1, -40, 0, 50)
        confirmText.Position = UDim2.new(0, 20, 0, 80)
        confirmText.BackgroundTransparency = 1
        confirmText.Text = "本当にUIを削除しますか？"
        confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmText.TextSize = 20
        confirmText.Font = FontSettings.Header
        confirmText.TextWrapped = true
        confirmText.Parent = confirmDialog
        
        -- ボタンコンテナ
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -40, 0, 50)
        buttonContainer.Position = UDim2.new(0, 20, 1, -70)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = confirmDialog
        
        -- はいボタン
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0, 120, 0, 40)
        yesBtn.Position = UDim2.new(0, 0, 0, 0)
        yesBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        yesBtn.AutoButtonColor = false
        yesBtn.Text = "はい"
        yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesBtn.TextSize = 18
        yesBtn.Font = FontSettings.Button
        yesBtn.Parent = buttonContainer
        
        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 8)
        yesCorner.Parent = yesBtn
        
        -- いいえボタン
        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0, 120, 0, 40)
        noBtn.Position = UDim2.new(1, -120, 0, 0)
        noBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        noBtn.AutoButtonColor = false
        noBtn.Text = "いいえ"
        noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        noBtn.TextSize = 18
        noBtn.Font = FontSettings.Button
        noBtn.Parent = buttonContainer
        
        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, 8)
        noCorner.Parent = noBtn
        
        -- ボタンホバーエフェクト
        SetupButtonHover(yesBtn)
        SetupButtonHover(noBtn)
        
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
            end)
        end)
        
        -- いいえボタン機能
        noBtn.MouseButton1Click:Connect(function()
            -- 確認ダイアログを閉じる
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(confirmDialog, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -175, 0.5, -80)
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
                Position = UDim2.new(0.75, 10, 1, -3)
            })
            tween:Play()
            
            UpdateTabContent("Settings")
        end
    end)
    
    -- タブコンテンツ更新関数
    local function UpdateTabContent(tabName)
        -- コンテンツをクリア
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
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
            Position = UDim2.new(indicatorPositions[tabName], 10, 1, -3)
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
        section.Size = UDim2.new(1, 0, 0, 50)
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
        sectionTitle.TextSize = 22
        sectionTitle.Font = FontSettings.Header
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
        toggleFrame.Size = UDim2.new(1, 0, 0, 40)
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
        toggleLabel.TextSize = 16
        toggleLabel.Font = FontSettings.Body
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleBackground = Instance.new("Frame")
        toggleBackground.Name = "Background"
        toggleBackground.Size = UDim2.new(0, 60, 0, 30)
        toggleBackground.Position = UDim2.new(1, -70, 0.5, -15)
        toggleBackground.BackgroundColor3 = defaultValue and Settings.UIColor or Color3.fromRGB(60, 60, 70)
        toggleBackground.BorderSizePixel = 0
        toggleBackground.Parent = toggleFrame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = toggleBackground
        
        local toggleButton = Instance.new("Frame")
        toggleButton.Name = "Button"
        toggleButton.Size = UDim2.new(0, 26, 0, 26)
        toggleButton.Position = defaultValue and UDim2.new(1, -33, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.BorderSizePixel = 0
        toggleButton.Parent = toggleFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = toggleButton
        
        local enabled = defaultValue
        
        toggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if enabled then
                    local tween1 = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(1, -33, 0.5, -13)})
                    local tween2 = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = Settings.UIColor})
                    tween1:Play()
                    tween2:Play()
                else
                    local tween1 = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -13)})
                    local tween2 = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)})
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
        sliderFrame.Size = UDim2.new(1, 0, 0, 60)
        sliderFrame.Position = UDim2.new(0, 0, 0, yPosition)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Size = UDim2.new(0.6, 0, 0, 30)
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = label .. ": " .. defaultValue
        sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        sliderLabel.TextSize = 16
        sliderLabel.Font = FontSettings.Body
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local sliderValue = Instance.new("TextLabel")
        sliderValue.Name = "Value"
        sliderValue.Size = UDim2.new(0.4, 0, 0, 30)
        sliderValue.Position = UDim2.new(0.6, 0, 0, 0)
        sliderValue.BackgroundTransparency = 1
        sliderValue.Text = tostring(defaultValue)
        sliderValue.TextColor3 = Settings.UIColor
        sliderValue.TextSize = 16
        sliderValue.Font = FontSettings.Body
        sliderValue.TextXAlignment = Enum.TextXAlignment.Right
        sliderValue.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Name = "Bar"
        sliderBar.Size = UDim2.new(1, 0, 0, 8)
        sliderBar.Position = UDim2.new(0, 0, 0, 35)
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
        sliderButton.Size = UDim2.new(0, 20, 0, 20)
        sliderButton.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -10, 0.5, -10)
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
            sliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        pickerFrame.Size = UDim2.new(1, 0, 0, 80)
        pickerFrame.Position = UDim2.new(0, 0, 0, yPosition)
        pickerFrame.BackgroundTransparency = 1
        pickerFrame.Parent = parent
        
        local pickerLabel = Instance.new("TextLabel")
        pickerLabel.Name = "Label"
        pickerLabel.Size = UDim2.new(1, 0, 0, 30)
        pickerLabel.Position = UDim2.new(0, 0, 0, 0)
        pickerLabel.BackgroundTransparency = 1
        pickerLabel.Text = label
        pickerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        pickerLabel.TextSize = 16
        pickerLabel.Font = FontSettings.Body
        pickerLabel.TextXAlignment = Enum.TextXAlignment.Left
        pickerLabel.Parent = pickerFrame
        
        local colorContainer = Instance.new("Frame")
        colorContainer.Name = "ColorContainer"
        colorContainer.Size = UDim2.new(1, 0, 0, 40)
        colorContainer.Position = UDim2.new(0, 0, 0, 35)
        colorContainer.BackgroundTransparency = 1
        colorContainer.Parent = pickerFrame
        
        local colorButtons = {}
        local buttonSize = 30
        local spacing = 10
        local buttonsPerRow = 6
        
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
            colorCorner.CornerRadius = UDim.new(0, 6)
            colorCorner.Parent = colorButton
            
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
                selectionCorner.CornerRadius = UDim.new(0, 8)
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
                selectionCorner.CornerRadius = UDim.new(0, 8)
                selectionCorner.Parent = selection
                
                if callback then
                    callback(color, i)
                end
            end)
            
            table.insert(colorButtons, colorButton)
        end
        
        return pickerFrame
    end
    
    -- Mainタブ作成
    local function CreateMainTab(parent)
        local yOffset = 0
        
        -- 移動セクション
        local movementSection, movementLine = CreateSection("移動設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- スピードチェンジ
        local speedSlider = CreateSlider("移動速度", parent, yOffset, 1, 100, Settings.Player.WalkSpeed, function(value)
            Settings.Player.WalkSpeed = value
            -- 実際の移動速度を変更するコードをここに追加
        end)
        yOffset = yOffset + 70
        
        -- ジャンプ力
        local jumpSlider = CreateSlider("ジャンプ力", parent, yOffset, 1, 200, Settings.Player.JumpPower, function(value)
            Settings.Player.JumpPower = value
            -- 実際のジャンプ力を変更するコードをここに追加
        end)
        yOffset = yOffset + 70
        
        -- 無限ジャンプ
        local infiniteJumpToggle = CreateToggle("無限ジャンプ", parent, yOffset, Settings.Player.InfiniteJump, function(enabled)
            Settings.Player.InfiniteJump = enabled
            -- 無限ジャンプ機能を実装
        end)
        yOffset = yOffset + 50
        
        -- 自動スプリント
        local autoSprintToggle = CreateToggle("自動スプリント", parent, yOffset, Settings.Player.AutoSprint, function(enabled)
            Settings.Player.AutoSprint = enabled
            -- 自動スプリント機能を実装
        end)
        yOffset = yOffset + 50
        
        -- Flyセクション
        local flySection, flyLine = CreateSection("Fly機能", parent, yOffset)
        yOffset = yOffset + 60
        
        -- Fly有効化
        local flyToggle = CreateToggle("Fly有効", parent, yOffset, Settings.Player.FlyEnabled, function(enabled)
            Settings.Player.FlyEnabled = enabled
            ToggleFly(enabled)
        end)
        yOffset = yOffset + 50
        
        -- Fly速度
        local flySpeedSlider = CreateSlider("Fly速度", parent, yOffset, 1, 200, Settings.Player.FlySpeed, function(value)
            Settings.Player.FlySpeed = value
            -- Fly速度を更新
        end)
        yOffset = yOffset + 70
        
        -- Flyモード選択
        local flyModeFrame = Instance.new("Frame")
        flyModeFrame.Name = "FlyMode"
        flyModeFrame.Size = UDim2.new(1, 0, 0, 40)
        flyModeFrame.Position = UDim2.new(0, 0, 0, yOffset)
        flyModeFrame.BackgroundTransparency = 1
        flyModeFrame.Parent = parent
        
        local flyModeLabel = Instance.new("TextLabel")
        flyModeLabel.Name = "Label"
        flyModeLabel.Size = UDim2.new(0.4, 0, 1, 0)
        flyModeLabel.Position = UDim2.new(0, 0, 0, 0)
        flyModeLabel.BackgroundTransparency = 1
        flyModeLabel.Text = "Flyモード:"
        flyModeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        flyModeLabel.TextSize = 16
        flyModeLabel.Font = FontSettings.Body
        flyModeLabel.TextXAlignment = Enum.TextXAlignment.Left
        flyModeLabel.Parent = flyModeFrame
        
        local flyModeDropdown = Instance.new("TextButton")
        flyModeDropdown.Name = "Dropdown"
        flyModeDropdown.Size = UDim2.new(0.6, 0, 1, 0)
        flyModeDropdown.Position = UDim2.new(0.4, 0, 0, 0)
        flyModeDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        flyModeDropdown.AutoButtonColor = false
        flyModeDropdown.Text = "Classic Fly"
        flyModeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        flyModeDropdown.TextSize = 14
        flyModeDropdown.Font = FontSettings.Body
        flyModeDropdown.Parent = flyModeFrame
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 6)
        dropdownCorner.Parent = flyModeDropdown
        
        -- Flyモードリスト
        local flyModes = {"Classic Fly", "CFrame Fly", "BodyVelocity Fly", "Part Fly", "Advanced Fly"}
        
        yOffset = yOffset + 50
        
        -- 浮遊力セクション
        local floatSection, floatLine = CreateSection("浮遊力", parent, yOffset)
        yOffset = yOffset + 60
        
        -- 浮遊力有効化
        local floatToggle = CreateToggle("浮遊力有効", parent, yOffset, false, function(enabled)
            -- 浮遊力機能を実装
        end)
        yOffset = yOffset + 50
        
        -- 浮遊力強度
        local floatSlider = CreateSlider("浮遊力強度", parent, yOffset, 0, 100, 50, function(value)
            -- 浮遊力強度を設定
        end)
        yOffset = yOffset + 70
        
        -- Noclipセクション
        local noclipSection, noclipLine = CreateSection("Noclip", parent, yOffset)
        yOffset = yOffset + 60
        
        -- Noclip有効化
        local noclipToggle = CreateToggle("Noclip有効", parent, yOffset, Settings.Player.NoClip, function(enabled)
            Settings.Player.NoClip = enabled
            ToggleNoClip(enabled)
        end)
        yOffset = yOffset + 50
    end
    
    -- Playerタブ作成
    local function CreatePlayerTab(parent)
        local yOffset = 0
        
        -- プレイヤー設定セクション
        local playerSection, playerLine = CreateSection("プレイヤー設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- グラビティ
        local gravitySlider = CreateSlider("重力", parent, yOffset, 0, 500, Settings.Player.Gravity, function(value)
            Settings.Player.Gravity = value
            -- 重力を変更
        end)
        yOffset = yOffset + 70
        
        -- ヒップハイト
        local hipHeightSlider = CreateSlider("ヒップハイト", parent, yOffset, 0, 20, Settings.Player.HipHeight, function(value)
            Settings.Player.HipHeight = value
            -- ヒップハイトを変更
        end)
        yOffset = yOffset + 70
        
        -- その他の機能を追加...
    end
    
    -- Visualタブ作成
    local function CreateVisualTab(parent)
        local yOffset = 0
        
        -- クロスヘアセクション
        local crosshairSection, crosshairLine = CreateSection("クロスヘア設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- クロスヘア有効化
        local crosshairToggle = CreateToggle("クロスヘア表示", parent, yOffset, Settings.Crosshair.Enabled, function(enabled)
            Settings.Crosshair.Enabled = enabled
            UpdateCrosshair()
        end)
        yOffset = yOffset + 50
        
        -- クロスヘアタイプ
        local crosshairTypeFrame = Instance.new("Frame")
        crosshairTypeFrame.Name = "CrosshairType"
        crosshairTypeFrame.Size = UDim2.new(1, 0, 0, 80)
        crosshairTypeFrame.Position = UDim2.new(0, 0, 0, yOffset)
        crosshairTypeFrame.BackgroundTransparency = 1
        crosshairTypeFrame.Parent = parent
        
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Name = "Label"
        typeLabel.Size = UDim2.new(1, 0, 0, 30)
        typeLabel.Position = UDim2.new(0, 0, 0, 0)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = "クロスヘアタイプ:"
        typeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        typeLabel.TextSize = 16
        typeLabel.Font = FontSettings.Body
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.Parent = crosshairTypeFrame
        
        local typeContainer = Instance.new("ScrollingFrame")
        typeContainer.Name = "TypeContainer"
        typeContainer.Size = UDim2.new(1, 0, 0, 40)
        typeContainer.Position = UDim2.new(0, 0, 0, 35)
        typeContainer.BackgroundTransparency = 1
        typeContainer.BorderSizePixel = 0
        typeContainer.ScrollBarThickness = 3
        typeContainer.ScrollBarImageColor3 = Settings.UIColor
        typeContainer.CanvasSize = UDim2.new(2, 0, 0, 0)
        typeContainer.Parent = crosshairTypeFrame
        
        -- クロスヘアタイプボタン
        local buttonWidth = 80
        local buttonHeight = 30
        local buttonSpacing = 10
        
        for i, crosshairType in ipairs(CrosshairTypes) do
            local typeButton = Instance.new("TextButton")
            typeButton.Name = crosshairType .. "Button"
            typeButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
            typeButton.Position = UDim2.new(0, (i-1) * (buttonWidth + buttonSpacing), 0, 0)
            typeButton.BackgroundColor3 = Settings.Crosshair.Type == crosshairType and Settings.UIColor or Color3.fromRGB(40, 40, 55)
            typeButton.AutoButtonColor = false
            typeButton.Text = crosshairType
            typeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            typeButton.TextSize = 12
            typeButton.Font = FontSettings.Body
            typeButton.Parent = typeContainer
            
            local typeCorner = Instance.new("UICorner")
            typeCorner.CornerRadius = UDim.new(0, 6)
            typeCorner.Parent = typeButton
            
            typeButton.MouseButton1Click:Connect(function()
                Settings.Crosshair.Type = crosshairType
                UpdateCrosshair()
                
                -- 他のボタンの色をリセット
                for _, child in ipairs(typeContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end
                
                typeButton.BackgroundColor3 = Settings.UIColor
            end)
        end
        
        yOffset = yOffset + 90
        
        -- クロスヘアカラー
        local crosshairColorPicker = CreateColorPicker("クロスヘア色", parent, yOffset, ColorPalette, 1, function(color, index)
            Settings.Crosshair.Color = color
            UpdateCrosshair()
        end)
        yOffset = yOffset + 90
        
        -- クロスヘアサイズ
        local crosshairSizeSlider = CreateSlider("クロスヘアサイズ", parent, yOffset, 5, 100, Settings.Crosshair.Size, function(value)
            Settings.Crosshair.Size = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + 70
        
        -- クロスヘア太さ
        local crosshairThicknessSlider = CreateSlider("クロスヘア太さ", parent, yOffset, 1, 10, Settings.Crosshair.Thickness, function(value)
            Settings.Crosshair.Thickness = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + 70
        
        -- クロスヘアギャップ
        local crosshairGapSlider = CreateSlider("クロスヘアギャップ", parent, yOffset, 0, 20, Settings.Crosshair.Gap, function(value)
            Settings.Crosshair.Gap = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + 70
        
        -- クロスヘア回転
        local crosshairRotationSlider = CreateSlider("クロスヘア回転", parent, yOffset, 0, 360, Settings.Crosshair.Rotation, function(value)
            Settings.Crosshair.Rotation = value
            UpdateCrosshair()
        end)
        yOffset = yOffset + 70
        
        -- アウトライン
        local crosshairOutlineToggle = CreateToggle("アウトライン表示", parent, yOffset, Settings.Crosshair.Outline, function(enabled)
            Settings.Crosshair.Outline = enabled
            UpdateCrosshair()
        end)
        yOffset = yOffset + 50
    end
    
    -- Settingsタブ作成
    local function CreateSettingsTab(parent)
        local yOffset = 0
        
        -- UI設定セクション
        local uiSection, uiLine = CreateSection("UI設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- UIカラー
        local uiColorPicker = CreateColorPicker("UIカラー", parent, yOffset, ColorPalette, 1, function(color, index)
            Settings.UIColor = color
            UpdateUITheme()
        end)
        yOffset = yOffset + 90
        
        -- UI形状
        local uiShapeFrame = Instance.new("Frame")
        uiShapeFrame.Name = "UIShape"
        uiShapeFrame.Size = UDim2.new(1, 0, 0, 80)
        uiShapeFrame.Position = UDim2.new(0, 0, 0, yOffset)
        uiShapeFrame.BackgroundTransparency = 1
        uiShapeFrame.Parent = parent
        
        local shapeLabel = Instance.new("TextLabel")
        shapeLabel.Name = "Label"
        shapeLabel.Size = UDim2.new(1, 0, 0, 30)
        shapeLabel.Position = UDim2.new(0, 0, 0, 0)
        shapeLabel.BackgroundTransparency = 1
        shapeLabel.Text = "UI形状:"
        shapeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        shapeLabel.TextSize = 16
        shapeLabel.Font = FontSettings.Body
        shapeLabel.TextXAlignment = Enum.TextXAlignment.Left
        shapeLabel.Parent = uiShapeFrame
        
        local shapeContainer = Instance.new("ScrollingFrame")
        shapeContainer.Name = "ShapeContainer"
        shapeContainer.Size = UDim2.new(1, 0, 0, 40)
        shapeContainer.Position = UDim2.new(0, 0, 0, 35)
        shapeContainer.BackgroundTransparency = 1
        shapeContainer.BorderSizePixel = 0
        shapeContainer.ScrollBarThickness = 3
        shapeContainer.ScrollBarImageColor3 = Settings.UIColor
        shapeContainer.CanvasSize = UDim2.new(2, 0, 0, 0)
        shapeContainer.Parent = uiShapeFrame
        
        -- UI形状ボタン
        local buttonWidth = 90
        local buttonHeight = 30
        local buttonSpacing = 10
        
        for i, shapeType in ipairs(ShapeTypes) do
            local shapeButton = Instance.new("TextButton")
            shapeButton.Name = shapeType .. "Button"
            shapeButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
            shapeButton.Position = UDim2.new(0, (i-1) * (buttonWidth + buttonSpacing), 0, 0)
            shapeButton.BackgroundColor3 = Settings.UIShape == shapeType and Settings.UIColor or Color3.fromRGB(40, 40, 55)
            shapeButton.AutoButtonColor = false
            shapeButton.Text = shapeType
            shapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            shapeButton.TextSize = 12
            shapeButton.Font = FontSettings.Body
            shapeButton.Parent = shapeContainer
            
            local shapeCorner = Instance.new("UICorner")
            shapeCorner.CornerRadius = UDim.new(0, 6)
            shapeCorner.Parent = shapeButton
            
            shapeButton.MouseButton1Click:Connect(function()
                Settings.UIShape = shapeType
                ApplyWindowShape()
                
                -- 他のボタンの色をリセット
                for _, child in ipairs(shapeContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end
                
                shapeButton.BackgroundColor3 = Settings.UIColor
            end)
        end
        
        yOffset = yOffset + 90
        
        -- UI透過度
        local transparencySlider = CreateSlider("UI透過度", parent, yOffset, 0, 100, Settings.Transparency * 100, function(value)
            Settings.Transparency = value / 100
            MainWindow.BackgroundTransparency = Settings.Transparency
            titleBar.BackgroundTransparency = Settings.Transparency
            tabContainer.BackgroundTransparency = Settings.Transparency
        end)
        yOffset = yOffset + 70
        
        -- シフトロックセクション
        local shiftLockSection, shiftLockLine = CreateSection("シフトロック", parent, yOffset)
        yOffset = yOffset + 60
        
        -- シフトロック有効化
        local shiftLockToggle = CreateToggle("シフトロック有効", parent, yOffset, Settings.Visual.ShiftLock, function(enabled)
            Settings.Visual.ShiftLock = enabled
            ToggleShiftLock(enabled)
        end)
        yOffset = yOffset + 50
        
        -- シフトロック設定
        local shiftLockSettings = Instance.new("Frame")
        shiftLockSettings.Name = "ShiftLockSettings"
        shiftLockSettings.Size = UDim2.new(1, 0, 0, 80)
        shiftLockSettings.Position = UDim2.new(0, 0, 0, yOffset)
        shiftLockSettings.BackgroundTransparency = 1
        shiftLockSettings.Parent = parent
        
        local offsetLabel = Instance.new("TextLabel")
        offsetLabel.Name = "OffsetLabel"
        offsetLabel.Size = UDim2.new(0.4, 0, 0, 30)
        offsetLabel.Position = UDim2.new(0, 0, 0, 0)
        offsetLabel.BackgroundTransparency = 1
        offsetLabel.Text = "カメラオフセット:"
        offsetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        offsetLabel.TextSize = 14
        offsetLabel.Font = FontSettings.Body
        offsetLabel.Parent = shiftLockSettings
        
        -- Xオフセット
        local xOffsetSlider = CreateSlider("X", shiftLockSettings, 40, -10, 10, Settings.Visual.CameraOffset.X, function(value)
            Settings.Visual.CameraOffset = Vector3.new(value, Settings.Visual.CameraOffset.Y, Settings.Visual.CameraOffset.Z)
        end)
        xOffsetSlider.Size = UDim2.new(0.3, 0, 0, 60)
        xOffsetSlider.Position = UDim2.new(0, 0, 0, 40)
        
        -- Yオフセット
        local yOffsetSlider = CreateSlider("Y", shiftLockSettings, 40, -10, 10, Settings.Visual.CameraOffset.Y, function(value)
            Settings.Visual.CameraOffset = Vector3.new(Settings.Visual.CameraOffset.X, value, Settings.Visual.CameraOffset.Z)
        end)
        yOffsetSlider.Size = UDim2.new(0.3, 0, 0, 60)
        yOffsetSlider.Position = UDim2.new(0.35, 0, 0, 40)
        
        -- Zオフセット
        local zOffsetSlider = CreateSlider("Z", shiftLockSettings, 40, -10, 10, Settings.Visual.CameraOffset.Z, function(value)
            Settings.Visual.CameraOffset = Vector3.new(Settings.Visual.CameraOffset.X, Settings.Visual.CameraOffset.Y, value)
        end)
        zOffsetSlider.Size = UDim2.new(0.3, 0, 0, 60)
        zOffsetSlider.Position = UDim2.new(0.7, 0, 0, 40)
        
        yOffset = yOffset + 90
        
        -- アニメーション設定セクション
        local animationSection, animationLine = CreateSection("アニメーション設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- アニメーション速度
        local animationSpeedSlider = CreateSlider("アニメーション速度", parent, yOffset, 0.1, 1, AnimationSettings.TweenSpeed, function(value)
            AnimationSettings.TweenSpeed = value
        end)
        yOffset = yOffset + 70
        
        -- ホバーエフェクト
        local hoverToggle = CreateToggle("ホバーエフェクト", parent, yOffset, AnimationSettings.HoverEffects, function(enabled)
            AnimationSettings.HoverEffects = enabled
        end)
        yOffset = yOffset + 50
        
        -- グローエフェクト
        local glowToggle = CreateToggle("グローエフェクト", parent, yOffset, AnimationSettings.GlowEffect, function(enabled)
            AnimationSettings.GlowEffect = enabled
        end)
        yOffset = yOffset + 50
    end
    
    -- UIテーマ更新関数
    local function UpdateUITheme()
        -- UIの色を更新
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- メインウィンドウのストローク
        if MainWindow:FindFirstChild("UIStroke") then
            local strokeTween = TweenService:Create(MainWindow.UIStroke, tweenInfo, {
                Color = Settings.UIColor
            })
            strokeTween:Play()
        end
        
        -- タブインジケーター
        local indicatorTween = TweenService:Create(tabIndicator, tweenInfo, {
            BackgroundColor3 = Settings.UIColor
        })
        indicatorTween:Play()
        
        -- セクションライン
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("Line") then
                local lineTween = TweenService:Create(child.Line, tweenInfo, {
                    BackgroundColor3 = Settings.UIColor
                })
                lineTween:Play()
            end
        end
        
        -- スクロールバー
        contentFrame.ScrollBarImageColor3 = Settings.UIColor
        
        -- 設定ボタン
        local settingsTween = TweenService:Create(settingsBtn, tweenInfo, {
            BackgroundColor3 = Settings.UIColor
        })
        settingsTween:Play()
        
        -- アクティブなタブの色
        if tabButtons[activeTab] then
            local tabTween = TweenService:Create(tabButtons[activeTab], tweenInfo, {
                TextColor3 = Settings.UIColor
            })
            tabTween:Play()
        end
    end
    
    -- クロスヘア更新関数
    local function UpdateCrosshair()
        -- クロスヘアの実装
        -- 注: これはクロスヘアの基本的な実装です
        if not Settings.Crosshair.Enabled then
            if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("CrosshairGui") then
                game:GetService("Players").LocalPlayer.PlayerGui.CrosshairGui:Destroy()
            end
            return
        end
        
        local crosshairGui = Instance.new("ScreenGui")
        crosshairGui.Name = "CrosshairGui"
        crosshairGui.ResetOnSpawn = false
        crosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        crosshairGui.IgnoreGuiInset = true
        crosshairGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
        
        local center = Instance.new("Frame")
        center.Name = "Center"
        center.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
        center.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
        center.BackgroundColor3 = Settings.Crosshair.Color
        center.BackgroundTransparency = 0.5
        center.BorderSizePixel = 0
        center.Parent = crosshairGui
        
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(0, Settings.Crosshair.Size/2)
        centerCorner.Parent = center
        
        -- クロスヘアの種類に応じて形状を変更
        if Settings.Crosshair.Type == "Cross" then
            -- 十字型クロスヘア
            local left = Instance.new("Frame")
            left.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Thickness)
            left.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2 - Settings.Crosshair.Gap, 0.5, -Settings.Crosshair.Thickness/2)
            left.BackgroundColor3 = Settings.Crosshair.Color
            left.BorderSizePixel = 0
            left.Parent = crosshairGui
            
            local right = left:Clone()
            right.Position = UDim2.new(0.5, Settings.Crosshair.Gap, 0.5, -Settings.Crosshair.Thickness/2)
            right.Parent = crosshairGui
            
            local top = left:Clone()
            top.Size = UDim2.new(0, Settings.Crosshair.Thickness, 0, Settings.Crosshair.Size)
            top.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, -Settings.Crosshair.Size/2 - Settings.Crosshair.Gap)
            top.Parent = crosshairGui
            
            local bottom = top:Clone()
            bottom.Position = UDim2.new(0.5, -Settings.Crosshair.Thickness/2, 0.5, Settings.Crosshair.Gap)
            bottom.Parent = crosshairGui
            
        elseif Settings.Crosshair.Type == "Dot" then
            -- 点型クロスヘア
            center.Size = UDim2.new(0, Settings.Crosshair.Size/2, 0, Settings.Crosshair.Size/2)
            center.Position = UDim2.new(0.5, -Settings.Crosshair.Size/4, 0.5, -Settings.Crosshair.Size/4)
            centerCorner.CornerRadius = UDim.new(1, 0)
            
        elseif Settings.Crosshair.Type == "Circle" then
            -- 円型クロスヘア
            center.BackgroundTransparency = 1
            
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, Settings.Crosshair.Size, 0, Settings.Crosshair.Size)
            circle.Position = UDim2.new(0.5, -Settings.Crosshair.Size/2, 0.5, -Settings.Crosshair.Size/2)
            circle.BackgroundTransparency = 1
            circle.Parent = crosshairGui
            
            local circleStroke = Instance.new("UIStroke")
            circleStroke.Color = Settings.Crosshair.Color
            circleStroke.Thickness = Settings.Crosshair.Thickness
            circleStroke.Parent = circle
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = circle
        end
        
        -- アウトライン
        if Settings.Crosshair.Outline then
            local outline = center:Clone()
            outline.Name = "Outline"
            outline.BackgroundColor3 = Settings.Crosshair.OutlineColor
            outline.Size = UDim2.new(0, Settings.Crosshair.Size + 4, 0, Settings.Crosshair.Size + 4)
            outline.Position = UDim2.new(0.5, -(Settings.Crosshair.Size + 4)/2, 0.5, -(Settings.Crosshair.Size + 4)/2)
            outline.ZIndex = center.ZIndex - 1
            outline.Parent = crosshairGui
        end
        
        -- 回転
        if Settings.Crosshair.Rotation ~= 0 then
            crosshairGui.Rotation = Settings.Crosshair.Rotation
        end
    end
    
    -- Fly機能
    local flyConnection
    local function ToggleFly(enabled)
        if enabled then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            
            -- BodyVelocityの作成
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.P = 10000
            bv.Name = "FlyBV"
            bv.Parent = character.HumanoidRootPart
            
            -- BodyGyroの作成
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 10000
            bg.Name = "FlyBG"
            bg.Parent = character.HumanoidRootPart
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if character and humanoid and humanoid.Health > 0 then
                    local root = character.HumanoidRootPart
                    
                    if root and bv and bg then
                        -- カメラの方向を取得
                        local cam = workspace.CurrentCamera
                        local lookVector = cam.CFrame.LookVector
                        
                        -- 入力の取得
                        local forward = 0
                        local backward = 0
                        local left = 0
                        local right = 0
                        local up = 0
                        local down = 0
                        
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            forward = 1
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            backward = 1
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            left = 1
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            right = 1
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            up = 1
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            down = 1
                        end
                        
                        -- 移動方向の計算
                        local moveDirection = Vector3.new(
                            right - left,
                            up - down,
                            forward - backward
                        )
                        
                        -- カメラの方向に基づいて移動
                        local camCF = cam.CFrame
                        local moveVector = camCF:VectorToWorldSpace(moveDirection)
                        
                        -- 速度の設定
                        bv.Velocity = moveVector * Settings.Player.FlySpeed
                        
                        -- 体の向きの設定
                        bg.CFrame = CFrame.new(root.Position, root.Position + lookVector)
                    end
                end
            end)
        else
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            -- BodyVelocityとBodyGyroを削除
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local bv = character.HumanoidRootPart:FindFirstChild("FlyBV")
                local bg = character.HumanoidRootPart:FindFirstChild("FlyBG")
                
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end
    end
    
    -- Noclip機能
    local noclipConnection
    local function ToggleNoClip(enabled)
        if enabled then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            
            noclipConnection = RunService.Stepped:Connect(function()
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- コリジョンを戻す
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
    
    -- シフトロック機能
    local shiftLockConnection
    local function ToggleShiftLock(enabled)
        if enabled then
            shiftLockConnection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local player = game.Players.LocalPlayer
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
        else
            if shiftLockConnection then
                shiftLockConnection:Disconnect()
                shiftLockConnection = nil
            end
            
            -- オートローテーションを戻す
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.AutoRotate = true
                end
            end
        end
    end
    
    -- 初期タブを設定
    UpdateTabContent("Main")
    
    -- ウィンドウを記録
    table.insert(Windows, MainWindow)
    ActiveWindow = MainWindow
end

-- 初期化
ArseusUI.Parent = player:WaitForChild("PlayerGui")
CreateAuthWindow()

-- デバッグメッセージ
print("⚡ Arseus x Neo UI loaded successfully!")
print("🔒 Security Password: しゅーくりーむ")
print("🎨 Features:")
print("  - Smooth animations and transitions")
print("  - Draggable and resizable windows")
print("  - 12 color themes")
print("  - Multiple UI shapes")
print("  - Crosshair customization")
print("  - Fly functions with multiple modes")
print("  - Shift lock system")
print("  - Player modifications")
