-- Arseus x Neo Style UI v3.1 - スマホ対応認証
-- 認証画面をモバイルとPCの両方に対応

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
        -- モバイル: 画面の85%幅、適応的高さ
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local width = math.min(viewportSize.X * 0.85, 400)
        local height = math.min(viewportSize.Y * 0.7, 400)
        return UDim2.new(0, width, 0, height)
    elseif IS_DESKTOP then
        -- PC: 固定サイズ
        return UDim2.new(0, 450, 0, 400)
    else
        -- コンソールなど
        return UDim2.new(0, 400, 0, 350)
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

-- 関数: スマホ対応認証画面の作成
local function CreateAuthWindow()
    AuthWindow = Instance.new("Frame")
    AuthWindow.Name = "AuthWindow"
    
    -- デバイスに応じたサイズ設定
    local uiSize = GetUISize()
    AuthWindow.Size = uiSize
    AuthWindow.Position = UDim2.new(0.5, -uiSize.X.Offset/2, 0.5, -uiSize.Y.Offset/2)
    
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
    subtitle.Size = UDim2.new(1, -40, 0, IS_MOBILE and 40 or 50)
    subtitle.Position = UDim2.new(0, 20, 0, IS_MOBILE and 65 or 75)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Arseus x Neo UIにアクセスするには\n暗証番号を入力してください"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = IS_MOBILE and 14 or 16
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextWrapped = true
    subtitle.Parent = AuthWindow
    
    -- パスワード入力欄
    local passwordFrame = Instance.new("Frame")
    passwordFrame.Name = "PasswordFrame"
    passwordFrame.Size = UDim2.new(1, -40, 0, IS_MOBILE and 50 or 60)
    passwordFrame.Position = UDim2.new(0, 20, 0, IS_MOBILE and 120 or 140)
    passwordFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    passwordFrame.BorderSizePixel = 0
    passwordFrame.Parent = AuthWindow
    
    local passwordCorner = Instance.new("UICorner")
    passwordCorner.CornerRadius = UDim.new(0, IS_MOBILE and 10 or 12)
    passwordCorner.Parent = passwordFrame
    
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.Size = UDim2.new(1, -IS_MOBILE and 60 or 80, 1, 0)
    passwordBox.Position = UDim2.new(0, IS_MOBILE and 10 or 15, 0, 0)
    passwordBox.BackgroundTransparency = 1
    passwordBox.PlaceholderText = IS_MOBILE and "暗証番号..." or "暗証番号を入力..."
    passwordBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    passwordBox.Text = ""
    passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordBox.TextSize = IS_MOBILE and 20 or 22
    passwordBox.Font = IS_MOBILE and Enum.Font.GothamSemibold or Enum.Font.Gotham
    passwordBox.TextXAlignment = Enum.TextXAlignment.Left
    passwordBox.Parent = passwordFrame
    
    -- 表示/非表示トグル（モバイルでは大きめに）
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleVisibility"
    toggleBtn.Size = UDim2.new(0, IS_MOBILE and 45 or 40, 0, IS_MOBILE and 45 or 40)
    toggleBtn.Position = UDim2.new(1, -IS_MOBILE and 50 or 55, 0.5, -IS_MOBILE and 22.5 or 20)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = IS_MOBILE and 18 or 16
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Parent = passwordFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, IS_MOBILE and 8 or 6)
    toggleCorner.Parent = toggleBtn
    
    -- 送信ボタンコンテナ（モバイルでは横並び）
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    if IS_MOBILE then
        buttonContainer.Size = UDim2.new(1, -40, 0, IS_MOBILE and 50 or 50)
        buttonContainer.Position = UDim2.new(0, 20, 0, IS_MOBILE and 185 or 215)
    else
        buttonContainer.Size = UDim2.new(1, -40, 0, 50)
        buttonContainer.Position = UDim2.new(0, 20, 0, 215)
    end
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = AuthWindow
    
    -- キャンセルボタン（モバイル用）
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Name = "CancelButton"
    
    if IS_MOBILE then
        cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
        cancelBtn.Position = UDim2.new(0, 0, 0, 0)
    else
        cancelBtn.Size = UDim2.new(0, 120, 1, 0)
        cancelBtn.Position = UDim2.new(0, 0, 0, 0)
    end
    
    cancelBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    cancelBtn.AutoButtonColor = false
    cancelBtn.Text = "キャンセル"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.TextSize = IS_MOBILE and 18 or 20
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Parent = buttonContainer
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, IS_MOBILE and 10 or 12)
    cancelCorner.Parent = cancelBtn
    
    -- 送信ボタン
    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "SubmitButton"
    
    if IS_MOBILE then
        submitBtn.Size = UDim2.new(0.48, 0, 1, 0)
        submitBtn.Position = UDim2.new(1, -0.48, 0, 0)
    else
        submitBtn.Size = UDim2.new(0, 120, 1, 0)
        submitBtn.Position = UDim2.new(1, -120, 0, 0)
    end
    
    submitBtn.BackgroundColor3 = Settings.UIColor
    submitBtn.AutoButtonColor = false
    submitBtn.Text = "送信"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = IS_MOBILE and 18 or 20
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = buttonContainer
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, IS_MOBILE and 10 or 12)
    submitCorner.Parent = submitBtn
    
    -- 認証ボタン（従来の大きいボタン - モバイルでは非表示）
    local authButton = Instance.new("TextButton")
    authButton.Name = "AuthButton"
    if IS_MOBILE then
        authButton.Visible = false
        authButton.Size = UDim2.new(0, 0, 0, 0)
    else
        authButton.Size = UDim2.new(1, -40, 0, 50)
        authButton.Position = UDim2.new(0, 20, 0, 215)
        authButton.BackgroundColor3 = Settings.UIColor
        authButton.AutoButtonColor = false
        authButton.Text = "認証を開始"
        authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        authButton.TextSize = 22
        authButton.Font = Enum.Font.GothamBold
        authButton.Parent = AuthWindow
    end
    
    if not IS_MOBILE then
        local authCorner = Instance.new("UICorner")
        authCorner.CornerRadius = UDim.new(0, 12)
        authCorner.Parent = authButton
    end
    
    -- メッセージ表示
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -40, 0, IS_MOBILE and 40 or 50)
    if IS_MOBILE then
        messageLabel.Position = UDim2.new(0, 20, 0, 250)
    else
        messageLabel.Position = UDim2.new(0, 20, 0, 280)
    end
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = IS_MOBILE and 14 or 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.Parent = AuthWindow
    
    -- 機能
    local passwordVisible = false
    local isProcessing = false
    
    -- パスワード表示/非表示
    local function TogglePasswordVisibility()
        if isProcessing then return end
        
        passwordVisible = not passwordVisible
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if passwordVisible then
            passwordBox.TextTransparency = 0
            -- パスワードを平文で表示
            toggleBtn.Text = "👁‍🗨"
            
            local tween = TweenService:Create(toggleBtn, tweenInfo, {
                BackgroundColor3 = Settings.UIColor,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            tween:Play()
        else
            passwordBox.TextTransparency = 0
            -- パスワードを●●●で表示
            if passwordBox.Text ~= "" then
                passwordBox.Text = string.rep("●", #passwordBox.Text)
            end
            
            local tween = TweenService:Create(toggleBtn, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })
            tween:Play()
            
            toggleBtn.Text = "👁"
        end
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        TogglePasswordVisibility()
    end)
    
    -- タッチ対応: タップで表示/非表示切り替え
    if IS_MOBILE then
        toggleBtn.TouchTap:Connect(function()
            TogglePasswordVisibility()
        end)
    end
    
    -- パスワード入力時の処理
    passwordBox.Focused:Connect(function()
        if passwordVisible and passwordBox.Text ~= "" then
            -- フォーカス時に元のテキストを表示
            passwordBox.Text = SECURITY_PASSWORD
        end
    end)
    
    passwordBox.FocusLost:Connect(function()
        if passwordVisible and passwordBox.Text ~= "" then
            -- フォーカスを失った時に●●●で表示
            passwordBox.Text = string.rep("●", #passwordBox.Text)
        end
    end)
    
    -- ボタンアニメーションを適用
    CreateButtonAnimation(toggleBtn)
    CreateButtonAnimation(cancelBtn)
    CreateButtonAnimation(submitBtn)
    if not IS_MOBILE then
        CreateButtonAnimation(authButton)
    end
    
    -- 認証処理関数
    local function ProcessAuthentication()
        if isProcessing then return end
        
        local input = passwordBox.Text
        
        -- 表示モードの場合は●●●になっているので、実際のパスワードを使う
        local actualInput = input
        if not passwordVisible and input:find("●") then
            -- ●●●表示の場合は実際の入力値を使う
            actualInput = SECURITY_PASSWORD
        end
        
        if actualInput == "" then
            messageLabel.Text = "暗証番号を入力してください"
            messageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            -- モバイル用振動フィードバック
            if IS_MOBILE then
                local originalPos = AuthWindow.Position
                for i = 1, 3 do
                    AuthWindow.Position = UDim2.new(
                        originalPos.X.Scale,
                        originalPos.X.Offset + math.random(-3, 3),
                        originalPos.Y.Scale,
                        originalPos.Y.Offset + math.random(-2, 2)
                    )
                    RunService.RenderStepped:Wait()
                end
                AuthWindow.Position = originalPos
            end
            return
        end
        
        isProcessing = true
        authAttempts = authAttempts + 1
        
        -- 処理中表示
        if IS_MOBILE then
            submitBtn.Text = "処理中..."
            submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        else
            authButton.Text = "処理中..."
            authButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
        
        -- 少し待機してから認証処理（UX向上のため）
        wait(0.3)
        
        if actualInput == SECURITY_PASSWORD then
            -- 認証成功
            messageLabel.Text = "✅ 認証成功！"
            messageLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- 成功アニメーション
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            
            local tween1 = TweenService:Create(AuthWindow, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -uiSize.X.Offset/2, 0.5, -uiSize.Y.Offset/2 - 50)
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
            
            -- シェイクアニメーション（デバイスに応じて強度調整）
            local originalPos = AuthWindow.Position
            local shakeIntensity = IS_MOBILE and 5 or 8
            
            for i = 1, 10 do
                AuthWindow.Position = UDim2.new(
                    originalPos.X.Scale,
                    originalPos.X.Offset + math.random(-shakeIntensity, shakeIntensity),
                    originalPos.Y.Scale,
                    originalPos.Y.Offset + math.random(-shakeIntensity/2, shakeIntensity/2)
                )
                RunService.RenderStepped:Wait()
            end
            AuthWindow.Position = originalPos
            
            -- ボタンを元に戻す
            if IS_MOBILE then
                submitBtn.Text = "送信"
                submitBtn.BackgroundColor3 = Settings.UIColor
            else
                authButton.Text = "認証を開始"
                authButton.BackgroundColor3 = Settings.UIColor
            end
            
            -- 試行回数制限
            if authAttempts >= MAX_AUTH_ATTEMPTS then
                messageLabel.Text = "🚫 試行回数制限に達しました"
                
                if IS_MOBILE then
                    submitBtn.Text = "ロックアウト"
                    submitBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                else
                    authButton.Text = "ロックアウト"
                    authButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
                
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(AuthWindow, tweenInfo, {
                    BackgroundColor3 = Color3.fromRGB(30, 15, 15),
                    Position = UDim2.new(0.5, -uiSize.X.Offset/2, 0.5, -uiSize.Y.Offset/2 - 25)
                })
                tween:Play()
            end
        end
        
        isProcessing = false
    end
    
    -- キャンセルボタン機能
    cancelBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(AuthWindow, tweenInfo, {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -uiSize.X.Offset/2, 0.5, -uiSize.Y.Offset/2 - 30)
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            if AuthWindow then
                AuthWindow:Destroy()
                AuthWindow = nil
            end
        end)
    end)
    
    -- 送信ボタン機能
    submitBtn.MouseButton1Click:Connect(function()
        ProcessAuthentication()
    end)
    
    -- 認証ボタン機能（PC用）
    if not IS_MOBILE then
        authButton.MouseButton1Click:Connect(function()
            ProcessAuthentication()
        end)
    end
    
    -- タッチ対応
    if IS_MOBILE then
        cancelBtn.TouchTap:Connect(function()
            cancelBtn:Fire("MouseButton1Click")
        end)
        
        submitBtn.TouchTap:Connect(function()
            submitBtn:Fire("MouseButton1Click")
        end)
        
        -- モバイル用キーボード設定
        passwordBox.TextInputType = Enum.TextInputType.Default
        passwordBox.ClearTextOnFocus = false
    end
    
    -- Enterキーで認証（PC用）
    if not IS_MOBILE then
        passwordBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                ProcessAuthentication()
            end
        end)
    end
    
    -- モバイル用追加機能：キーボードの完了ボタン
    if IS_MOBILE then
        passwordBox.FocusLost:Connect(function()
            -- モバイルではフォーカスを失った時に自動送信しない
        end)
    end
    
    -- 初期フォーカス設定
    spawn(function()
        wait(0.5)
        if passwordBox then
            passwordBox:CaptureFocus()
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

-- メインウィンドウ関数（前回のコードから継続）
-- 注意: 以下の関数は前回のコードから引用する必要があります
-- CreateMainWindow() と関連する関数

-- メインウィンドウの作成（簡易版）
function CreateMainWindow()
    print("メインウィンドウを作成します...")
    
    -- メインウィンドウが既にある場合は削除
    if MainWindow and MainWindow.Parent then
        MainWindow:Destroy()
    end
    
    MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    
    -- デバイスに応じたサイズ設定
    local uiSize
    if IS_MOBILE then
        local viewportSize = workspace.CurrentCamera.ViewportSize
        uiSize = UDim2.new(0, math.min(viewportSize.X * 0.9, 450), 0, math.min(viewportSize.Y * 0.8, 500))
    else
        uiSize = UDim2.new(0, 650, 0, 550)
    end
    
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
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, IS_MOBILE and 40 or 50)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Arseus x Neo UI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = IS_MOBILE and 22 or 26
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = MainWindow
    
    -- 閉じるボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, IS_MOBILE and 35 or 40, 0, IS_MOBILE and 35 or 40)
    closeBtn.Position = UDim2.new(1, -IS_MOBILE and 45 or 50, 0, 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = IS_MOBILE and 20 or 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = MainWindow
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, IS_MOBILE and 6 or 8)
    closeCorner.Parent = closeBtn
    
    CreateButtonAnimation(closeBtn)
    
    -- タブコンテナ
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, IS_MOBILE and 40 or 50)
    tabContainer.Position = UDim2.new(0, 0, 0, IS_MOBILE and 70 or 80)
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
        CreateButtonAnimation(tabButton)
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
    contentFrame.Size = UDim2.new(1, IS_MOBILE and -10 or -20, 1, IS_MOBILE and -120 or -140)
    contentFrame.Position = UDim2.new(0, IS_MOBILE and 5 or 10, 0, IS_MOBILE and 115 or 135)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = IS_MOBILE and 4 or 6
    contentFrame.ScrollBarImageColor3 = Settings.UIColor
    contentFrame.ScrollBarImageTransparency = 0.5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.Parent = MainWindow
    
    -- 閉じるボタン機能（削除確認付き）
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
            confirmDialog:Destroy()
        end)
    end)
    
    -- タブ切り替え機能
    for name, tabButton in pairs(tabButtons) do
        tabButton.MouseButton1Click:Connect(function()
            if activeTab == name then return end
            
            activeTab = name
            
            -- タブの色を更新
            for tabName, btn in pairs(tabButtons) do
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(btn, tweenInfo, {
                    TextColor3 = tabName == name and Settings.UIColor or Color3.fromRGB(150, 150, 150)
                })
                tween:Play()
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
                Position = UDim2.new(indicatorPositions[name], IS_MOBILE and 7.5 or 10, 1, -3)
            })
            tween:Play()
            
            -- タブコンテンツを更新
            UpdateTabContent(name)
        end)
    end
    
    -- タブコンテンツ更新関数
    local function UpdateTabContent(tabName)
        -- コンテンツをクリア
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                child:Destroy()
            end
        end
        
        -- 簡易コンテンツ
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1, 0, 0, 100)
        contentLabel.Position = UDim2.new(0, 0, 0, 20)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Text = tabName .. " タブの内容"
        contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        contentLabel.TextSize = IS_MOBILE and 18 or 24
        contentLabel.Font = Enum.Font.GothamBold
        contentLabel.TextWrapped = true
        contentLabel.Parent = contentFrame
    end
    
    -- 初期タブを設定
    UpdateTabContent("Main")
    
    print("メインウィンドウの作成が完了しました！")
end

-- 初期化
CreateAuthWindow()

-- デバッグメッセージ
print("⚡ Arseus x Neo UI v3.1 loaded successfully!")
print("🔒 Security Password: しゅーくりーむ")
print("📱 Device: " .. (IS_MOBILE and "Mobile" or IS_DESKTOP and "Desktop" or "Console"))
print("✅ スマホ対応認証システムを実装しました")
print("🎮 送信ボタンとキャンセルボタンを追加")
