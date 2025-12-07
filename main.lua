-- Arseus x Neo Style UI v2.0 (修正版)
-- セキュリティ認証後にメインUIが正しく表示される

-- サービスの取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- プレイヤーとマウス
local player = Players.LocalPlayer
local mouse = player:GetMouse()

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

-- 関数: 認証画面の作成
local function CreateAuthWindow()
    AuthWindow = Instance.new("Frame")
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
    title.Font = Enum.Font.GothamBold
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
    subtitle.Font = Enum.Font.Gotham
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
    passwordBox.Font = Enum.Font.Gotham
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
    toggleBtn.Font = Enum.Font.Gotham
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
    authButton.Font = Enum.Font.GothamBold
    authButton.Parent = AuthWindow
    
    local authCorner = Instance.new("UICorner")
    authCorner.CornerRadius = UDim.new(0, 12)
    authCorner.Parent = authButton
    
    -- メッセージ表示
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -40, 0, 40)
    messageLabel.Position = UDim2.new(0, 20, 0, 280)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
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
            
            -- 認証成功アニメーション
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            
            local tween1 = TweenService:Create(AuthWindow, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -200, 0.5, -200)
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
function CreateMainWindow()
    print("メインウィンドウを作成します...")
    
    -- メインウィンドウが既にある場合は削除
    if MainWindow and MainWindow.Parent then
        MainWindow:Destroy()
    end
    
    MainWindow = Instance.new("Frame")
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
    title.Font = Enum.Font.GothamBold
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
    minimizeBtn.Font = Enum.Font.GothamBold
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
    closeBtn.Font = Enum.Font.GothamBold
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
    settingsBtn.Font = Enum.Font.GothamBold
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
        warningIcon.Font = Enum.Font.GothamBold
        warningIcon.Parent = confirmDialog
        
        -- 確認メッセージ
        local confirmText = Instance.new("TextLabel")
        confirmText.Size = UDim2.new(1, -40, 0, 50)
        confirmText.Position = UDim2.new(0, 20, 0, 80)
        confirmText.BackgroundTransparency = 1
        confirmText.Text = "本当にUIを削除しますか？"
        confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmText.TextSize = 20
        confirmText.Font = Enum.Font.GothamBold
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
        yesBtn.Font = Enum.Font.GothamBold
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
        noBtn.Font = Enum.Font.GothamBold
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
                MainWindow = nil
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
        toggleLabel.Font = Enum.Font.Gotham
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
        sliderLabel.Font = Enum.Font.Gotham
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
        sliderValue.Font = Enum.Font.Gotham
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
        pickerLabel.Font = Enum.Font.Gotham
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
    
    -- Mainタブ作成 (簡易版)
    local function CreateMainTab(parent)
        local yOffset = 0
        
        -- 移動セクション
        local movementSection, movementLine = CreateSection("移動設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- スピードチェンジ
        local speedSlider = CreateSlider("移動速度", parent, yOffset, 1, 100, Settings.Player.WalkSpeed, function(value)
            Settings.Player.WalkSpeed = value
            print("移動速度を" .. value .. "に設定しました")
        end)
        yOffset = yOffset + 70
        
        -- ジャンプ力
        local jumpSlider = CreateSlider("ジャンプ力", parent, yOffset, 1, 200, Settings.Player.JumpPower, function(value)
            Settings.Player.JumpPower = value
            print("ジャンプ力を" .. value .. "に設定しました")
        end)
        yOffset = yOffset + 70
        
        -- 無限ジャンプ
        local infiniteJumpToggle = CreateToggle("無限ジャンプ", parent, yOffset, Settings.Player.InfiniteJump, function(enabled)
            Settings.Player.InfiniteJump = enabled
            print("無限ジャンプ: " .. (enabled and "有効" or "無効"))
        end)
        yOffset = yOffset + 50
        
        -- 自動スプリント
        local autoSprintToggle = CreateToggle("自動スプリント", parent, yOffset, Settings.Player.AutoSprint, function(enabled)
            Settings.Player.AutoSprint = enabled
            print("自動スプリント: " .. (enabled and "有効" or "無効"))
        end)
        yOffset = yOffset + 50
        
        -- Flyセクション
        local flySection, flyLine = CreateSection("Fly機能", parent, yOffset)
        yOffset = yOffset + 60
        
        -- Fly有効化
        local flyToggle = CreateToggle("Fly有効", parent, yOffset, Settings.Player.FlyEnabled, function(enabled)
            Settings.Player.FlyEnabled = enabled
            print("Fly機能: " .. (enabled and "有効" or "無効"))
        end)
        yOffset = yOffset + 50
        
        -- Fly速度
        local flySpeedSlider = CreateSlider("Fly速度", parent, yOffset, 1, 200, Settings.Player.FlySpeed, function(value)
            Settings.Player.FlySpeed = value
            print("Fly速度を" .. value .. "に設定しました")
        end)
        yOffset = yOffset + 70
        
        -- Noclipセクション
        local noclipSection, noclipLine = CreateSection("Noclip", parent, yOffset)
        yOffset = yOffset + 60
        
        -- Noclip有効化
        local noclipToggle = CreateToggle("Noclip有効", parent, yOffset, Settings.Player.NoClip, function(enabled)
            Settings.Player.NoClip = enabled
            print("Noclip: " .. (enabled and "有効" or "無効"))
        end)
        yOffset = yOffset + 50
    end
    
    -- Playerタブ作成 (簡易版)
    local function CreatePlayerTab(parent)
        local yOffset = 0
        
        -- プレイヤー設定セクション
        local playerSection, playerLine = CreateSection("プレイヤー設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- グラビティ
        local gravitySlider = CreateSlider("重力", parent, yOffset, 0, 500, Settings.Player.Gravity, function(value)
            Settings.Player.Gravity = value
            print("重力を" .. value .. "に設定しました")
        end)
        yOffset = yOffset + 70
        
        -- ヒップハイト
        local hipHeightSlider = CreateSlider("ヒップハイト", parent, yOffset, 0, 20, Settings.Player.HipHeight, function(value)
            Settings.Player.HipHeight = value
            print("ヒップハイトを" .. value .. "に設定しました")
        end)
        yOffset = yOffset + 70
    end
    
    -- Visualタブ作成 (簡易版)
    local function CreateVisualTab(parent)
        local yOffset = 0
        
        -- クロスヘアセクション
        local crosshairSection, crosshairLine = CreateSection("クロスヘア設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- クロスヘア有効化
        local crosshairToggle = CreateToggle("クロスヘア表示", parent, yOffset, Settings.Crosshair.Enabled, function(enabled)
            Settings.Crosshair.Enabled = enabled
            print("クロスヘア: " .. (enabled and "有効" or "無効"))
        end)
        yOffset = yOffset + 50
        
        -- クロスヘアサイズ
        local crosshairSizeSlider = CreateSlider("クロスヘアサイズ", parent, yOffset, 5, 100, Settings.Crosshair.Size, function(value)
            Settings.Crosshair.Size = value
            print("クロスヘアサイズを" .. value .. "に設定しました")
        end)
        yOffset = yOffset + 70
        
        -- クロスヘアカラー
        local crosshairColorPicker = CreateColorPicker("クロスヘア色", parent, yOffset, ColorPalette, 1, function(color, index)
            Settings.Crosshair.Color = color
            print("クロスヘア色を変更しました")
        end)
        yOffset = yOffset + 90
    end
    
    -- Settingsタブ作成 (簡易版)
    local function CreateSettingsTab(parent)
        local yOffset = 0
        
        -- UI設定セクション
        local uiSection, uiLine = CreateSection("UI設定", parent, yOffset)
        yOffset = yOffset + 60
        
        -- UIカラー
        local uiColorPicker = CreateColorPicker("UIカラー", parent, yOffset, ColorPalette, 1, function(color, index)
            Settings.UIColor = color
            print("UIカラーを変更しました")
        end)
        yOffset = yOffset + 90
        
        -- UI透過度
        local transparencySlider = CreateSlider("UI透過度", parent, yOffset, 0, 100, Settings.Transparency * 100, function(value)
            Settings.Transparency = value / 100
            MainWindow.BackgroundTransparency = Settings.Transparency
            titleBar.BackgroundTransparency = Settings.Transparency
            tabContainer.BackgroundTransparency = Settings.Transparency
            print("UI透過度を" .. value .. "%に設定しました")
        end)
        yOffset = yOffset + 70
        
        -- シフトロックセクション
        local shiftLockSection, shiftLockLine = CreateSection("シフトロック", parent, yOffset)
        yOffset = yOffset + 60
        
        -- シフトロック有効化
        local shiftLockToggle = CreateToggle("シフトロック有効", parent, yOffset, Settings.Visual.ShiftLock, function(enabled)
            Settings.Visual.ShiftLock = enabled
            print("シフトロック: " .. (enabled and "有効" or "無効"))
        end)
        yOffset = yOffset + 50
    end
    
    -- 初期タブを設定
    UpdateTabContent("Main")
    
    print("メインウィンドウの作成が完了しました！")
end

-- 初期化
CreateAuthWindow()

-- デバッグメッセージ
print("⚡ Arseus x Neo UI loaded successfully!")
print("🔒 Security Password: しゅーくりーむ")
print("🎨 認証後にメインUIが表示されます")
