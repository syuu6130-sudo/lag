--!native
--!optimize 2

-- Arseus x Neo風 Roblox UI
-- 作成者: AI Assistant
-- バージョン: 2.0

-- サービス
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- 変数
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui")
gui.Name = "ArseusNeoUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- 暗証番号
local CORRECT_PASSWORD = "しゅーくりーむ"
local attempts = 0
local MAX_ATTEMPTS = 5

-- 設定
local settings = {
    uiColor = Color3.fromRGB(0, 170, 255),
    uiShape = "Rounded",
    crosshair = {
        enabled = false,
        type = "Cross",
        color = Color3.fromRGB(255, 255, 255),
        size = 20,
        thickness = 2,
        gap = 5
    },
    shiftLock = false,
    flyEnabled = false,
    walkSpeed = 16,
    jumpPower = 50,
    noclip = false
}

-- カラーパレット (12色)
local colorPalette = {
    Color3.fromRGB(0, 170, 255),    -- 青 (デフォルト)
    Color3.fromRGB(255, 50, 50),    -- 赤
    Color3.fromRGB(50, 255, 50),    -- 緑
    Color3.fromRGB(255, 255, 50),   -- 黄
    Color3.fromRGB(255, 50, 255),   -- マゼンタ
    Color3.fromRGB(50, 255, 255),   -- シアン
    Color3.fromRGB(255, 150, 50),   -- オレンジ
    Color3.fromRGB(150, 50, 255),   -- 紫
    Color3.fromRGB(50, 150, 255),   -- ライトブルー
    Color3.fromRGB(255, 100, 100),  -- ピンク
    Color3.fromRGB(100, 255, 100),  -- ライトグリーン
    Color3.fromRGB(255, 255, 255)   -- 白
}

-- 形状設定
local shapeTypes = {"Rounded", "Square", "Circle", "Swastika", "Hexagon", "Diamond"}

-- クロスヘアタイプ
local crosshairTypes = {"Cross", "Dot", "Circle", "Square", "Crosshair", "Target"}

-- 認証画面を作成
local function createAuthScreen()
    local authFrame = Instance.new("Frame")
    authFrame.Name = "AuthFrame"
    authFrame.Size = UDim2.new(0, 450, 0, 350)
    authFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    authFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    authFrame.BackgroundTransparency = 0.1
    authFrame.BorderSizePixel = 0
    authFrame.Parent = gui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 15)
    uiCorner.Parent = authFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = settings.uiColor
    uiStroke.Thickness = 2
    uiStroke.Parent = authFrame
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "セキュリティチェック"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = authFrame
    
    local titleDivider = Instance.new("Frame")
    titleDivider.Name = "TitleDivider"
    titleDivider.Size = UDim2.new(0.8, 0, 0, 2)
    titleDivider.Position = UDim2.new(0.1, 0, 0, 60)
    titleDivider.BackgroundColor3 = settings.uiColor
    titleDivider.BorderSizePixel = 0
    titleDivider.Parent = authFrame
    
    -- 説明文
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(0.8, 0, 0, 40)
    description.Position = UDim2.new(0.1, 0, 0, 80)
    description.BackgroundTransparency = 1
    description.Text = "暗証番号を入力してアクセスしてください"
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.TextSize = 18
    description.Font = Enum.Font.Gotham
    description.Parent = authFrame
    
    -- パスワード入力欄
    local passwordFrame = Instance.new("Frame")
    passwordFrame.Name = "PasswordFrame"
    passwordFrame.Size = UDim2.new(0.8, 0, 0, 50)
    passwordFrame.Position = UDim2.new(0.1, 0, 0, 140)
    passwordFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    passwordFrame.BorderSizePixel = 0
    passwordFrame.Parent = authFrame
    
    local passwordCorner = Instance.new("UICorner")
    passwordCorner.CornerRadius = UDim.new(0, 10)
    passwordCorner.Parent = passwordFrame
    
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.Size = UDim2.new(1, -50, 1, 0)
    passwordBox.Position = UDim2.new(0, 0, 0, 0)
    passwordBox.BackgroundTransparency = 1
    passwordBox.Text = ""
    passwordBox.PlaceholderText = "暗証番号を入力"
    passwordBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordBox.TextSize = 20
    passwordBox.Font = Enum.Font.Gotham
    passwordBox.TextXAlignment = Enum.TextXAlignment.Left
    passwordBox.Parent = passwordFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = passwordBox
    
    -- 表示/非表示ボタン
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 50, 1, 0)
    toggleBtn.Position = UDim2.new(1, -50, 0, 0)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBtn.TextSize = 20
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Parent = passwordFrame
    
    -- 認証ボタン
    local authButton = Instance.new("TextButton")
    authButton.Name = "AuthButton"
    authButton.Size = UDim2.new(0.8, 0, 0, 50)
    authButton.Position = UDim2.new(0.1, 0, 0, 210)
    authButton.BackgroundColor3 = settings.uiColor
    authButton.Text = "認証"
    authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    authButton.TextSize = 22
    authButton.Font = Enum.Font.GothamBold
    authButton.Parent = authFrame
    
    local authCorner = Instance.new("UICorner")
    authCorner.CornerRadius = UDim.new(0, 10)
    authCorner.Parent = authButton
    
    -- メッセージ表示
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(0.8, 0, 0, 30)
    messageLabel.Position = UDim2.new(0.1, 0, 0, 280)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = authFrame
    
    -- 機能
    local passwordVisible = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        passwordVisible = not passwordVisible
        if passwordVisible then
            passwordBox.TextTransparency = 0
            passwordBox.Text = string.gsub(passwordBox.Text, ".", "•")
            toggleBtn.Text = "👁‍🗨"
        else
            passwordBox.TextTransparency = 0
            passwordBox.Text = string.gsub(passwordBox.Text, ".", "•")
            toggleBtn.Text = "👁"
        end
    end)
    
    authButton.MouseButton1Click:Connect(function()
        local input = passwordBox.Text
        if input == "" then
            messageLabel.Text = "暗証番号を入力してください"
            return
        end
        
        attempts = attempts + 1
        
        if input == CORRECT_PASSWORD then
            -- 認証成功
            messageLabel.Text = "認証成功！"
            messageLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            
            -- アニメーション
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(authFrame, tweenInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -225, 0.5, -200)})
            tween:Play()
            
            tween.Completed:Connect(function()
                authFrame:Destroy()
                createMainUI()
            end)
        else
            -- 認証失敗
            messageLabel.Text = string.format("暗証番号が違います (%d/%d)", attempts, MAX_ATTEMPTS)
            messageLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            
            -- シェイクアニメーション
            local originalPos = authFrame.Position
            for i = 1, 5 do
                authFrame.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + math.random(-5, 5), originalPos.Y.Scale, originalPos.Y.Offset)
                RunService.RenderStepped:Wait()
            end
            authFrame.Position = originalPos
            
            if attempts >= MAX_ATTEMPTS then
                messageLabel.Text = "試行回数制限に達しました"
                authButton.Visible = false
            end
        end
    end)
    
    -- Enterキーで認証
    passwordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            authButton:Fire("MouseButton1Click")
        end
    end)
end

-- メインUIを作成
local function createMainUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- UI形状適用
    local uiCorner = Instance.new("UICorner")
    if settings.uiShape == "Rounded" then
        uiCorner.CornerRadius = UDim.new(0, 15)
    elseif settings.uiShape == "Circle" then
        uiCorner.CornerRadius = UDim.new(1, 0)
    else
        uiCorner.CornerRadius = UDim.new(0, 0)
    end
    uiCorner.Parent = mainFrame
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = settings.uiColor
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame
    
    -- タイトルバー（ドラッグ用）
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Arseus x Neo UI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- コントロールボタン
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(0, 120, 1, 0)
    buttonContainer.Position = UDim2.new(1, -125, 0, 0)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = titleBar
    
    -- 最小化ボタン
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(0, 0, 0.5, -15)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = buttonContainer
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 5)
    minCorner.Parent = minimizeBtn
    
    -- 削除ボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0, 40, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = buttonContainer
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeBtn
    
    -- 設定ボタン
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name = "SettingsBtn"
    settingsBtn.Size = UDim2.new(0, 30, 0, 30)
    settingsBtn.Position = UDim2.new(0, 80, 0.5, -15)
    settingsBtn.BackgroundColor3 = settings.uiColor
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsBtn.TextSize = 18
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.Parent = buttonContainer
    
    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(0, 5)
    setCorner.Parent = settingsBtn
    
    -- タブコンテナ
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 50)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- タブボタン
    local tabs = {"Main", "Player", "Visual", "Settings"}
    local currentTab = "Main"
    
    local tabButtons = {}
    
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
        
        if tabName == "Main" then
            tabButton.TextColor3 = settings.uiColor
        end
        
        tabButtons[tabName] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            currentTab = tabName
            for name, btn in pairs(tabButtons) do
                if name == tabName then
                    btn.TextColor3 = settings.uiColor
                else
                    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            updateTabContent(tabName)
        end)
    end
    
    -- タブ下線
    local tabLine = Instance.new("Frame")
    tabLine.Name = "TabLine"
    tabLine.Size = UDim2.new(0.25, 0, 0, 3)
    tabLine.Position = UDim2.new(0, 0, 1, -3)
    tabLine.BackgroundColor3 = settings.uiColor
    tabLine.BorderSizePixel = 0
    tabLine.Parent = tabContainer
    
    -- コンテンツフレーム
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 5
    contentFrame.ScrollBarImageColor3 = settings.uiColor
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    contentFrame.Parent = mainFrame
    
    -- ドラッグ機能
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale, 
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, 
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- 最小化機能
    local minimized = false
    local originalSize = mainFrame.Size
    local minimizedSize = UDim2.new(0, 600, 0, 40)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            -- 最小化アニメーション
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(mainFrame, tweenInfo, {Size = minimizedSize})
            tween:Play()
            
            tween.Completed:Connect(function()
                tabContainer.Visible = false
                contentFrame.Visible = false
            end)
        else
            tabContainer.Visible = true
            contentFrame.Visible = true
            
            -- 元に戻すアニメーション
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(mainFrame, tweenInfo, {Size = originalSize})
            tween:Play()
        end
    end)
    
    -- 削除確認機能
    closeBtn.MouseButton1Click:Connect(function()
        local confirmFrame = Instance.new("Frame")
        confirmFrame.Name = "ConfirmFrame"
        confirmFrame.Size = UDim2.new(0, 300, 0, 150)
        confirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        confirmFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        confirmFrame.BackgroundTransparency = 0.1
        confirmFrame.BorderSizePixel = 0
        confirmFrame.Parent = mainFrame
        confirmFrame.ZIndex = 10
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 10)
        confirmCorner.Parent = confirmFrame
        
        local confirmStroke = Instance.new("UIStroke")
        confirmStroke.Color = settings.uiColor
        confirmStroke.Thickness = 2
        confirmStroke.Parent = confirmFrame
        
        -- 確認メッセージ
        local confirmText = Instance.new("TextLabel")
        confirmText.Name = "ConfirmText"
        confirmText.Size = UDim2.new(1, 0, 0, 60)
        confirmText.Position = UDim2.new(0, 0, 0, 20)
        confirmText.BackgroundTransparency = 1
        confirmText.Text = "本当にUIを削除しますか？"
        confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmText.TextSize = 20
        confirmText.Font = Enum.Font.GothamBold
        confirmText.Parent = confirmFrame
        
        -- はいボタン
        local yesBtn = Instance.new("TextButton")
        yesBtn.Name = "YesBtn"
        yesBtn.Size = UDim2.new(0, 100, 0, 40)
        yesBtn.Position = UDim2.new(0.5, -110, 1, -60)
        yesBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        yesBtn.Text = "はい"
        yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesBtn.TextSize = 18
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.Parent = confirmFrame
        
        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 5)
        yesCorner.Parent = yesBtn
        
        -- いいえボタン
        local noBtn = Instance.new("TextButton")
        noBtn.Name = "NoBtn"
        noBtn.Size = UDim2.new(0, 100, 0, 40)
        noBtn.Position = UDim2.new(0.5, 10, 1, -60)
        noBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        noBtn.Text = "いいえ"
        noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        noBtn.TextSize = 18
        noBtn.Font = Enum.Font.GothamBold
        noBtn.Parent = confirmFrame
        
        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, 5)
        noCorner.Parent = noBtn
        
        -- ボタン機能
        yesBtn.MouseButton1Click:Connect(function()
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -300, 0.5, -300)})
            tween:Play()
            
            tween.Completed:Connect(function()
                mainFrame:Destroy()
            end)
        end)
        
        noBtn.MouseButton1Click:Connect(function()
            confirmFrame:Destroy()
        end)
    end)
    
    -- 設定ボタン
    settingsBtn.MouseButton1Click:Connect(function()
        currentTab = "Settings"
        for name, btn in pairs(tabButtons) do
            if name == "Settings" then
                btn.TextColor3 = settings.uiColor
            else
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        
        -- タブラインを移動
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(tabLine, tweenInfo, {Position = UDim2.new(0.75, 0, 1, -3)})
        tween:Play()
        
        updateTabContent("Settings")
    end)
    
    -- タブコンテンツ更新関数
    local function updateTabContent(tabName)
        -- コンテンツをクリア
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- タブラインを移動
        local linePosition
        if tabName == "Main" then
            linePosition = 0
        elseif tabName == "Player" then
            linePosition = 0.25
        elseif tabName == "Visual" then
            linePosition = 0.5
        elseif tabName == "Settings" then
            linePosition = 0.75
        end
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(tabLine, tweenInfo, {Position = UDim2.new(linePosition, 0, 1, -3)})
        tween:Play()
        
        -- タブに応じたコンテンツを作成
        if tabName == "Main" then
            createMainContent(contentFrame)
        elseif tabName == "Player" then
            createPlayerContent(contentFrame)
        elseif tabName == "Visual" then
            createVisualContent(contentFrame)
        elseif tabName == "Settings" then
            createSettingsContent(contentFrame)
        end
    end
    
    -- タブコンテンツ作成関数
    local function createSection(title, position, parent)
        local section = Instance.new("Frame")
        section.Name = title .. "Section"
        section.Size = UDim2.new(1, 0, 0, 40)
        section.Position = position
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
        sectionLine.BackgroundColor3 = settings.uiColor
        sectionLine.BorderSizePixel = 0
        sectionLine.Parent = section
        
        return section
    end
    
    -- Mainタブコンテンツ
    local function createMainContent(parent)
        local yOffset = 0
        
        -- 速度変更
        local speedSection = createSection("速度変更", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local speedSlider = createSlider("速度倍率", UDim2.new(0, 0, 0, yOffset), parent, 1, 10, 1, function(value)
            settings.walkSpeed = 16 * value
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = settings.walkSpeed
            end
        end)
        yOffset = yOffset + 60
        
        -- ジャンプ力変更
        local jumpSection = createSection("ジャンプ力変更", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local jumpSlider = createSlider("ジャンプ力倍率", UDim2.new(0, 0, 0, yOffset), parent, 1, 5, 1, function(value)
            settings.jumpPower = 50 * value
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = settings.jumpPower
            end
        end)
        yOffset = yOffset + 60
        
        -- 浮遊力
        local floatSection = createSection("浮遊力", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local floatToggle = createToggle("浮遊力有効", UDim2.new(0, 0, 0, yOffset), parent, false, function(enabled)
            -- 浮遊力実装
        end)
        yOffset = yOffset + 40
        
        local floatSlider = createSlider("浮遊力強度", UDim2.new(0, 0, 0, yOffset), parent, 0, 10, 1, function(value)
            -- 浮遊力強度設定
        end)
        yOffset = yOffset + 60
        
        -- Fly機能
        local flySection = createSection("Fly機能", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local flyToggle = createToggle("Fly有効", UDim2.new(0, 0, 0, yOffset), parent, settings.flyEnabled, function(enabled)
            settings.flyEnabled = enabled
            toggleFly(enabled)
        end)
        yOffset = yOffset + 40
        
        local flySpeedSlider = createSlider("Fly速度", UDim2.new(0, 0, 0, yOffset), parent, 1, 100, 50, function(value)
            -- Fly速度設定
        end)
        yOffset = yOffset + 60
        
        -- Noclip
        local noclipSection = createSection("Noclip", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local noclipToggle = createToggle("Noclip有効", UDim2.new(0, 0, 0, yOffset), parent, settings.noclip, function(enabled)
            settings.noclip = enabled
            toggleNoclip(enabled)
        end)
        yOffset = yOffset + 40
        
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Playerタブコンテンツ
    local function createPlayerContent(parent)
        local yOffset = 0
        
        -- プレイヤー情報
        local infoSection = createSection("プレイヤー情報", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        -- その他機能を追加...
        
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Visualタブコンテンツ
    local function createVisualContent(parent)
        local yOffset = 0
        
        -- クロスヘア設定
        local crosshairSection = createSection("クロスヘア設定", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local crosshairToggle = createToggle("クロスヘア表示", UDim2.new(0, 0, 0, yOffset), parent, settings.crosshair.enabled, function(enabled)
            settings.crosshair.enabled = enabled
            updateCrosshair()
        end)
        yOffset = yOffset + 40
        
        -- クロスヘアタイプ選択
        local typeSection = createSection("クロスヘアタイプ", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local buttonWidth = 80
        local buttonHeight = 30
        local buttonSpacing = 10
        local buttonsPerRow = 3
        
        for i, cType in ipairs(crosshairTypes) do
            local row = math.floor((i-1) / buttonsPerRow)
            local col = (i-1) % buttonsPerRow
            
            local typeButton = Instance.new("TextButton")
            typeButton.Name = cType .. "Button"
            typeButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
            typeButton.Position = UDim2.new(0, col * (buttonWidth + buttonSpacing), 0, row * (buttonHeight + buttonSpacing))
            typeButton.BackgroundColor3 = settings.crosshair.type == cType and settings.uiColor or Color3.fromRGB(40, 40, 50)
            typeButton.Text = cType
            typeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            typeButton.TextSize = 14
            typeButton.Font = Enum.Font.Gotham
            typeButton.Parent = parent
            
            local typeCorner = Instance.new("UICorner")
            typeCorner.CornerRadius = UDim.new(0, 5)
            typeCorner.Parent = typeButton
            
            typeButton.MouseButton1Click:Connect(function()
                settings.crosshair.type = cType
                updateCrosshair()
                
                -- すべてのボタンの色をリセット
                for _, btn in ipairs(parent:GetChildren()) do
                    if btn:IsA("TextButton") and btn.Name:find("Button") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    end
                end
                
                typeButton.BackgroundColor3 = settings.uiColor
            end)
        end
        
        yOffset = yOffset + 90
        
        -- クロスヘア色選択
        local colorSection = createSection("クロスヘア色", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local colorButtonSize = 30
        local colorSpacing = 10
        local colorsPerRow = 6
        
        for i, color in ipairs(colorPalette) do
            local row = math.floor((i-1) / colorsPerRow)
            local col = (i-1) % colorsPerRow
            
            local colorButton = Instance.new("TextButton")
            colorButton.Name = "ColorButton" .. i
            colorButton.Size = UDim2.new(0, colorButtonSize, 0, colorButtonSize)
            colorButton.Position = UDim2.new(0, col * (colorButtonSize + colorSpacing), 0, row * (colorButtonSize + colorSpacing))
            colorButton.BackgroundColor3 = color
            colorButton.BorderSizePixel = 0
            colorButton.Text = ""
            colorButton.Parent = parent
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 5)
            colorCorner.Parent = colorButton
            
            if settings.crosshair.color == color then
                local selection = Instance.new("Frame")
                selection.Name = "Selection"
                selection.Size = UDim2.new(1, 4, 1, 4)
                selection.Position = UDim2.new(0, -2, 0, -2)
                selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                selection.BorderSizePixel = 0
                selection.Parent = colorButton
                
                local selectionCorner = Instance.new("UICorner")
                selectionCorner.CornerRadius = UDim.new(0, 7)
                selectionCorner.Parent = selection
            end
            
            colorButton.MouseButton1Click:Connect(function()
                settings.crosshair.color = color
                updateCrosshair()
                updateColorSelection(parent, color)
            end)
        end
        
        yOffset = yOffset + 80
        
        -- クロスヘアサイズ
        local sizeSlider = createSlider("クロスヘアサイズ", UDim2.new(0, 0, 0, yOffset), parent, 5, 50, settings.crosshair.size, function(value)
            settings.crosshair.size = value
            updateCrosshair()
        end)
        yOffset = yOffset + 60
        
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Settingsタブコンテンツ
    local function createSettingsContent(parent)
        local yOffset = 0
        
        -- UIカラー設定
        local uiColorSection = createSection("UIカラー設定", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local colorButtonSize = 35
        local colorSpacing = 10
        local colorsPerRow = 6
        
        for i, color in ipairs(colorPalette) do
            local row = math.floor((i-1) / colorsPerRow)
            local col = (i-1) % colorsPerRow
            
            local colorButton = Instance.new("TextButton")
            colorButton.Name = "UIColorButton" .. i
            colorButton.Size = UDim2.new(0, colorButtonSize, 0, colorButtonSize)
            colorButton.Position = UDim2.new(0, col * (colorButtonSize + colorSpacing), 0, row * (colorButtonSize + colorSpacing))
            colorButton.BackgroundColor3 = color
            colorButton.BorderSizePixel = 0
            colorButton.Text = ""
            colorButton.Parent = parent
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 5)
            colorCorner.Parent = colorButton
            
            if settings.uiColor == color then
                local selection = Instance.new("Frame")
                selection.Name = "Selection"
                selection.Size = UDim2.new(1, 4, 1, 4)
                selection.Position = UDim2.new(0, -2, 0, -2)
                selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                selection.BorderSizePixel = 0
                selection.Parent = colorButton
                
                local selectionCorner = Instance.new("UICorner")
                selectionCorner.CornerRadius = UDim.new(0, 7)
                selectionCorner.Parent = selection
            end
            
            colorButton.MouseButton1Click:Connect(function()
                settings.uiColor = color
                updateUIColor(color)
                updateUIColorSelection(parent, color)
            end)
        end
        
        yOffset = yOffset + 90
        
        -- UI形状設定
        local uiShapeSection = createSection("UI形状設定", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local shapeButtonWidth = 80
        local shapeButtonHeight = 30
        local shapeSpacing = 10
        local shapesPerRow = 3
        
        for i, shape in ipairs(shapeTypes) do
            local row = math.floor((i-1) / shapesPerRow)
            local col = (i-1) % shapesPerRow
            
            local shapeButton = Instance.new("TextButton")
            shapeButton.Name = shape .. "ShapeButton"
            shapeButton.Size = UDim2.new(0, shapeButtonWidth, 0, shapeButtonHeight)
            shapeButton.Position = UDim2.new(0, col * (shapeButtonWidth + shapeSpacing), 0, row * (shapeButtonHeight + shapeSpacing))
            shapeButton.BackgroundColor3 = settings.uiShape == shape and settings.uiColor or Color3.fromRGB(40, 40, 50)
            shapeButton.Text = shape
            shapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            shapeButton.TextSize = 14
            shapeButton.Font = Enum.Font.Gotham
            shapeButton.Parent = parent
            
            local shapeCorner = Instance.new("UICorner")
            shapeCorner.CornerRadius = UDim.new(0, 5)
            shapeCorner.Parent = shapeButton
            
            shapeButton.MouseButton1Click:Connect(function()
                settings.uiShape = shape
                updateUIShape(shape)
                
                -- すべての形状ボタンの色をリセット
                for _, btn in ipairs(parent:GetChildren()) do
                    if btn:IsA("TextButton") and btn.Name:find("ShapeButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    end
                end
                
                shapeButton.BackgroundColor3 = settings.uiColor
            end)
        end
        
        yOffset = yOffset + 100
        
        -- シフトロック設定
        local shiftLockSection = createSection("シフトロック設定", UDim2.new(0, 0, 0, yOffset), parent)
        yOffset = yOffset + 50
        
        local shiftLockToggle = createToggle("シフトロック有効", UDim2.new(0, 0, 0, yOffset), parent, settings.shiftLock, function(enabled)
            settings.shiftLock = enabled
            toggleShiftLock(enabled)
        end)
        yOffset = yOffset + 40
        
        parent.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- スライダー作成関数
    local function createSlider(label, position, parent, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = label .. "Slider"
        sliderFrame.Size = UDim2.new(1, 0, 0, 40)
        sliderFrame.Position = position
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Size = UDim2.new(0.5, 0, 1, 0)
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = label .. ": " .. default
        sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        sliderLabel.TextSize = 16
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Name = "Bar"
        sliderBar.Size = UDim2.new(0.5, 0, 0, 10)
        sliderBar.Position = UDim2.new(0.5, 0, 0.5, -5)
        sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = sliderFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = sliderBar
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.Position = UDim2.new(0, 0, 0, 0)
        sliderFill.BackgroundColor3 = settings.uiColor
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = sliderFill
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Name = "Button"
        sliderButton.Size = UDim2.new(0, 20, 0, 20)
        sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.Text = ""
        sliderButton.Parent = sliderFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = sliderButton
        
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider()
            end
        end)
        
        local function updateSlider()
            if not dragging then return end
            
            local mousePos = UserInputService:GetMouseLocation()
            local sliderAbsolutePos = sliderBar.AbsolutePosition
            local sliderAbsoluteSize = sliderBar.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderAbsolutePos.X, 0, sliderAbsoluteSize)
            local value = min + (relativeX / sliderAbsoluteSize) * (max - min)
            value = math.floor(value * 10) / 10
            
            sliderFill.Size = UDim2.new(relativeX / sliderAbsoluteSize, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativeX / sliderAbsoluteSize, -10, 0.5, -10)
            sliderLabel.Text = label .. ": " .. value
            
            if callback then
                callback(value)
            end
        end
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if dragging then
                updateSlider()
            end
        end)
        
        return sliderFrame
    end
    
    -- トグル作成関数
    local function createToggle(label, position, parent, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = label .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 30)
        toggleFrame.Position = position
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
        toggleBackground.Size = UDim2.new(0, 50, 0, 25)
        toggleBackground.Position = UDim2.new(1, -50, 0.5, -12.5)
        toggleBackground.BackgroundColor3 = default and settings.uiColor or Color3.fromRGB(60, 60, 70)
        toggleBackground.BorderSizePixel = 0
        toggleBackground.Parent = toggleFrame
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = toggleBackground
        
        local toggleButton = Instance.new("Frame")
        toggleButton.Name = "Button"
        toggleButton.Size = UDim2.new(0, 21, 0, 21)
        toggleButton.Position = default and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.BorderSizePixel = 0
        toggleButton.Parent = toggleFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = toggleButton
        
        local enabled = default
        
        toggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if enabled then
                    local tween1 = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(1, -23, 0.5, -10.5)})
                    local tween2 = TweenService:Create(toggleBackground, tweenInfo, {BackgroundColor3 = settings.uiColor})
                    tween1:Play()
                    tween2:Play()
                else
                    local tween1 = TweenService:Create(toggleButton, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -10.5)})
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
    
    -- UI色更新関数
    local function updateUIColor(color)
        settings.uiColor = color
        
        -- UIストロークを更新
        if mainFrame:FindFirstChild("UIStroke") then
            mainFrame.UIStroke.Color = color
        end
        
        -- タイトルバーラインを更新
        if tabLine then
            tabLine.BackgroundColor3 = color
        end
        
        -- ボタン色を更新
        if settingsBtn then
            settingsBtn.BackgroundColor3 = color
        end
        
        -- アクティブなタブの色を更新
        for name, btn in pairs(tabButtons) do
            if name == currentTab then
                btn.TextColor3 = color
            end
        end
        
        -- セクションラインを更新
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("Line") then
                child.Line.BackgroundColor3 = color
            end
        end
        
        -- スライダーを更新
        updateSlidersColor()
    end
    
    -- スライダー色更新関数
    local function updateSlidersColor()
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("Bar") then
                local bar = child.Bar
                if bar and bar:FindFirstChild("Fill") then
                    bar.Fill.BackgroundColor3 = settings.uiColor
                end
            end
        end
    end
    
    -- UI形状更新関数
    local function updateUIShape(shape)
        settings.uiShape = shape
        
        if mainFrame:FindFirstChild("UICorner") then
            local corner = mainFrame.UICorner
            
            if shape == "Rounded" then
                corner.CornerRadius = UDim.new(0, 15)
            elseif shape == "Square" then
                corner.CornerRadius = UDim.new(0, 0)
            elseif shape == "Circle" then
                corner.CornerRadius = UDim.new(1, 0)
            elseif shape == "Swastika" then
                -- 卍型の実装は複雑なので、角丸にしておく
                corner.CornerRadius = UDim.new(0, 15)
            elseif shape == "Hexagon" then
                corner.CornerRadius = UDim.new(0, 15)
            elseif shape == "Diamond" then
                corner.CornerRadius = UDim.new(0, 15)
            end
        end
    end
    
    -- 色選択更新関数
    local function updateUIColorSelection(parent, selectedColor)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") and child.Name:find("UIColorButton") then
                if child.Selection then
                    child.Selection:Destroy()
                end
                
                if child.BackgroundColor3 == selectedColor then
                    local selection = Instance.new("Frame")
                    selection.Name = "Selection"
                    selection.Size = UDim2.new(1, 4, 1, 4)
                    selection.Position = UDim2.new(0, -2, 0, -2)
                    selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    selection.BorderSizePixel = 0
                    selection.Parent = child
                    
                    local selectionCorner = Instance.new("UICorner")
                    selectionCorner.CornerRadius = UDim.new(0, 7)
                    selectionCorner.Parent = selection
                end
            end
        end
    end
    
    -- クロスヘア色選択更新関数
    local function updateColorSelection(parent, selectedColor)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") and child.Name:find("ColorButton") then
                if child.Selection then
                    child.Selection:Destroy()
                end
                
                if child.BackgroundColor3 == selectedColor then
                    local selection = Instance.new("Frame")
                    selection.Name = "Selection"
                    selection.Size = UDim2.new(1, 4, 1, 4)
                    selection.Position = UDim2.new(0, -2, 0, -2)
                    selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    selection.BorderSizePixel = 0
                    selection.Parent = child
                    
                    local selectionCorner = Instance.new("UICorner")
                    selectionCorner.CornerRadius = UDim.new(0, 7)
                    selectionCorner.Parent = selection
                end
            end
        end
    end
    
    -- クロスヘア更新関数
    local function updateCrosshair()
        -- クロスヘアの実装
        -- これはプレースホルダーです。実際のクロスヘア実装は別途必要です。
    end
    
    -- Fly機能トグル関数
    local function toggleFly(enabled)
        settings.flyEnabled = enabled
        
        if enabled then
            -- Fly機能を有効化
            -- 実際のFly実装は別途必要です
        else
            -- Fly機能を無効化
        end
    end
    
    -- Noclipトグル関数
    local function toggleNoclip(enabled)
        settings.noclip = enabled
        
        if enabled then
            -- Noclipを有効化
            -- 実際のNoclip実装は別途必要です
        else
            -- Noclipを無効化
        end
    end
    
    -- シフトロックトグル関数
    local function toggleShiftLock(enabled)
        settings.shiftLock = enabled
        
        if enabled then
            -- シフトロックを有効化
            -- 実際のシフトロック実装は別途必要です
        else
            -- シフトロックを無効化
        end
    end
    
    -- 初期タブを表示
    updateTabContent("Main")
end

-- 初期化
createAuthScreen()

-- 通知
print("Arseus x Neo UI loaded! Password: しゅーくりーむ")
