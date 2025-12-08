-- Roblox高度カスタムUIシステム by Shucriimu
-- モバイル/PC対応、パスコード認証付き

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 設定データ保存用
local DataStoreService = game:GetService("DataStoreService")
local settingsDataStore = DataStoreService:GetDataStore("UI_Settings_" .. player.UserId)

-- デバイス判定
local isMobile = UserInputService.TouchEnabled
local isGamepad = UserInputService.GamepadEnabled

-- パスコード
local PASSWORD = "しゅーくりーむ"
local uiSettings = {
    color = Color3.fromRGB(45, 45, 45),
    shape = "Rounded",
    transparency = 0.1,
    size = UDim2.new(0, 400, 0, 500),
    position = UDim2.new(0.5, -200, 0.5, -250)
}

-- クロスヘア設定
local crosshairSettings = {
    enabled = false,
    color = Color3.fromRGB(255, 255, 255),
    shape = "Cross",
    size = 20,
    thickness = 2,
    gap = 5
}

-- 設定データ読み込み
local function loadSettings()
    local success, data = pcall(function()
        return settingsDataStore:GetAsync("settings")
    end)
    
    if success and data then
        uiSettings = data.uiSettings or uiSettings
        crosshairSettings = data.crosshairSettings or crosshairSettings
    end
end

-- 設定データ保存
local function saveSettings()
    local data = {
        uiSettings = uiSettings,
        crosshairSettings = crosshairSettings
    }
    
    pcall(function()
        settingsDataStore:SetAsync("settings", data)
    end)
end

-- スムーズなTween作成
local function createTween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

-- パスコード入力画面作成
local function createPasswordScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PasswordScreen"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- 背景
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    background.BackgroundTransparency = 0.3
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BorderSizePixel = 0
    
    -- メインフレーム
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.Size = isMobile and UDim2.new(0, 350, 0, 450) or UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BorderSizePixel = 0
    
    -- 角丸効果
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- ドロップシャドウ
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 2
    shadow.Transparency = 0.7
    shadow.Parent = mainFrame
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "認証が必要です"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    -- パスコード入力
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.Size = UDim2.new(1, -40, 0, 50)
    inputFrame.Position = UDim2.new(0, 20, 0, 90)
    inputFrame.BorderSizePixel = 0
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.PlaceholderText = "パスコードを入力..."
    passwordBox.Font = Enum.Font.Gotham
    passwordBox.TextSize = 18
    passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordBox.BackgroundTransparency = 1
    passwordBox.Size = UDim2.new(1, -20, 1, 0)
    passwordBox.Position = UDim2.new(0, 10, 0, 0)
    passwordBox.Text = ""
    passwordBox.ClearTextOnFocus = false
    
    -- キーパッド（モバイル用）
    local keypadGrid = Instance.new("UIGridLayout")
    keypadGrid.CellSize = UDim2.new(0, 70, 0, 70)
    keypadGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    keypadGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    keypadGrid.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "←", "0", "✓"}
    
    -- 送信確認画面
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Name = "ConfirmFrame"
    confirmFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    confirmFrame.Size = UDim2.new(1, -80, 0, 150)
    confirmFrame.Position = UDim2.new(0, 40, 0.5, -75)
    confirmFrame.Visible = false
    confirmFrame.BorderSizePixel = 0
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 12)
    confirmCorner.Parent = confirmFrame
    
    local confirmTitle = Instance.new("TextLabel")
    confirmTitle.Text = "送信しますか？"
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 20
    confirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmTitle.BackgroundTransparency = 1
    confirmTitle.Size = UDim2.new(1, 0, 0, 40)
    confirmTitle.Position = UDim2.new(0, 0, 0, 10)
    confirmTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(1, -40, 0, 50)
    buttonContainer.Position = UDim2.new(0, 20, 0, 70)
    
    local buttonLayout = Instance.new("UIGridLayout")
    buttonLayout.CellSize = UDim2.new(0.45, 0, 1, 0)
    buttonLayout.CellPadding = UDim2.new(0, 10, 0, 0)
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local yesButton = Instance.new("TextButton")
    yesButton.Text = "はい"
    yesButton.Font = Enum.Font.GothamBold
    yesButton.TextSize = 18
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    yesButton.Size = UDim2.new(1, 0, 1, 0)
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = yesButton
    
    local noButton = Instance.new("TextButton")
    noButton.Text = "いいえ"
    noButton.Font = Enum.Font.GothamBold
    noButton.TextSize = 18
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    noButton.Size = UDim2.new(1, 0, 1, 0)
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noButton
    
    -- エラーメッセージ
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorLabel"
    errorLabel.Text = ""
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextSize = 14
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Size = UDim2.new(1, -40, 0, 30)
    errorLabel.Position = UDim2.new(0, 20, 0, 150)
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Visible = false
    
    -- 親子関係設定
    buttonLayout.Parent = buttonContainer
    yesButton.Parent = buttonContainer
    noButton.Parent = buttonContainer
    confirmTitle.Parent = confirmFrame
    buttonContainer.Parent = confirmFrame
    
    inputCorner.Parent = inputFrame
    passwordBox.Parent = inputFrame
    
    confirmFrame.Parent = mainFrame
    title.Parent = mainFrame
    inputFrame.Parent = mainFrame
    errorLabel.Parent = mainFrame
    mainFrame.Parent = background
    background.Parent = screenGui
    
    -- アニメーション表示
    mainFrame.BackgroundTransparency = 1
    createTween(mainFrame, {BackgroundTransparency = 0}, 0.5):Play()
    
    -- 関数定義
    local function showError(message)
        errorLabel.Text = message
        errorLabel.Visible = true
        task.wait(2)
        createTween(errorLabel, {TextTransparency = 1}, 0.3):Play()
        task.wait(0.3)
        errorLabel.Visible = false
        errorLabel.TextTransparency = 0
    end
    
    local function checkPassword()
        if passwordBox.Text == PASSWORD then
            confirmFrame.Visible = true
            createTween(confirmFrame, {BackgroundTransparency = 0}, 0.3):Play()
        else
            showError("パスコードが違います")
            passwordBox.Text = ""
        end
    end
    
    local function submitPassword()
        confirmFrame.Visible = false
        createTween(mainFrame, {BackgroundTransparency = 1}, 0.5):Play()
        task.wait(0.5)
        screenGui:Destroy()
        createMainUI()
    end
    
    -- イベント接続
    passwordBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            checkPassword()
        end
    end)
    
    yesButton.MouseButton1Click:Connect(submitPassword)
    
    noButton.MouseButton1Click:Connect(function()
        confirmFrame.Visible = false
        passwordBox.Text = ""
        passwordBox:CaptureFocus()
    end)
    
    -- モバイル用キーパッド
    if isMobile then
        local keypadFrame = Instance.new("Frame")
        keypadFrame.BackgroundTransparency = 1
        keypadFrame.Size = UDim2.new(1, -40, 0, 250)
        keypadFrame.Position = UDim2.new(0, 20, 0, 180)
        
        keypadGrid.Parent = keypadFrame
        
        for _, number in ipairs(numbers) do
            local button = Instance.new("TextButton")
            button.Text = number
            button.Font = Enum.Font.GothamBold
            button.TextSize = 24
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 8)
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                if number == "←" then
                    passwordBox.Text = passwordBox.Text:sub(1, -2)
                elseif number == "✓" then
                    checkPassword()
                else
                    passwordBox.Text = passwordBox.Text .. number
                end
            end)
            
            button.Parent = keypadFrame
        end
        
        keypadFrame.Parent = mainFrame
    end
    
    screenGui.Parent = playerGui
    passwordBox:CaptureFocus()
    
    return screenGui
end

-- メインUI作成
local function createMainUI()
    loadSettings()
    
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "ArseusNeoUI"
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGui.ResetOnSpawn = false
    
    -- メインコンテナ
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.BackgroundColor3 = uiSettings.color
    mainContainer.BackgroundTransparency = uiSettings.transparency
    mainContainer.Size = uiSettings.size
    mainContainer.Position = uiSettings.position
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.BorderSizePixel = 0
    mainContainer.ClipsDescendants = true
    
    -- 形状適用
    local corner = Instance.new("UICorner")
    if uiSettings.shape == "Rounded" then
        corner.CornerRadius = UDim.new(0, 12)
    elseif uiSettings.shape == "Circle" then
        corner.CornerRadius = UDim.new(1, 0)
    elseif uiSettings.shape == "Swastika" then
        -- 卍型用のカスタム形状（簡易実装）
        mainContainer.BackgroundTransparency = 1
    else
        corner.CornerRadius = UDim.new(0, 0)
    end
    corner.Parent = mainContainer
    
    -- ドラッグ機能
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    mainContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainContainer.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- タイトルバー
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = "Arseus Neo UI"
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 最小化ボタン
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Text = "_"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 20
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0, 5)
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeButton
    
    -- 削除ボタン
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- 削除確認画面
    local deleteConfirm = Instance.new("Frame")
    deleteConfirm.Name = "DeleteConfirm"
    deleteConfirm.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    deleteConfirm.Size = UDim2.new(1, -40, 0, 120)
    deleteConfirm.Position = UDim2.new(0, 20, 0.5, -60)
    deleteConfirm.Visible = false
    deleteConfirm.BorderSizePixel = 0
    
    local deleteCorner = Instance.new("UICorner")
    deleteCorner.CornerRadius = UDim.new(0, 12)
    deleteCorner.Parent = deleteConfirm
    
    local deleteTitle = Instance.new("TextLabel")
    deleteTitle.Text = "本当に削除しますか？"
    deleteTitle.Font = Enum.Font.GothamBold
    deleteTitle.TextSize = 18
    deleteTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteTitle.BackgroundTransparency = 1
    deleteTitle.Size = UDim2.new(1, 0, 0, 40)
    deleteTitle.Position = UDim2.new(0, 0, 0, 10)
    deleteTitle.TextXAlignment = Enum.TextXAlignment.Center
    
    local deleteButtonContainer = Instance.new("Frame")
    deleteButtonContainer.BackgroundTransparency = 1
    deleteButtonContainer.Size = UDim2.new(1, -40, 0, 40)
    deleteButtonContainer.Position = UDim2.new(0, 20, 0, 60)
    
    local deleteButtonLayout = Instance.new("UIGridLayout")
    deleteButtonLayout.CellSize = UDim2.new(0.45, 0, 1, 0)
    deleteButtonLayout.CellPadding = UDim2.new(0, 10, 0, 0)
    deleteButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    deleteButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local deleteYesButton = Instance.new("TextButton")
    deleteYesButton.Text = "はい"
    deleteYesButton.Font = Enum.Font.GothamBold
    deleteYesButton.TextSize = 16
    deleteYesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteYesButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    deleteYesButton.Size = UDim2.new(1, 0, 1, 0)
    
    local deleteYesCorner = Instance.new("UICorner")
    deleteYesCorner.CornerRadius = UDim.new(0, 8)
    deleteYesCorner.Parent = deleteYesButton
    
    local deleteNoButton = Instance.new("TextButton")
    deleteNoButton.Text = "いいえ"
    deleteNoButton.Font = Enum.Font.GothamBold
    deleteNoButton.TextSize = 16
    deleteNoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteNoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    deleteNoButton.Size = UDim2.new(1, 0, 1, 0)
    
    local deleteNoCorner = Instance.new("UICorner")
    deleteNoCorner.CornerRadius = UDim.new(0, 8)
    deleteNoCorner.Parent = deleteNoButton
    
    -- タブシステム
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BorderSizePixel = 0
    
    local tabs = {"Main", "Settings"}
    local tabButtons = {}
    local contentFrames = {}
    
    -- コンテンツエリア
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Size = UDim2.new(1, 0, 1, -80)
    contentArea.Position = UDim2.new(0, 0, 0, 80)
    contentArea.ClipsDescendants = true
    
    -- タブ作成
    local tabLayout = Instance.new("UIGridLayout")
    tabLayout.CellSize = UDim2.new(0.5, 0, 1, 0)
    tabLayout.CellPadding = UDim2.new(0, 0, 0, 0)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Parent = tabContainer
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Text = tabName
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 16
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
        tabButton.BorderSizePixel = 0
        
        tabButton.MouseButton1Click:Connect(function()
            for _, btn in ipairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            
            for _, frame in ipairs(contentFrames) do
                frame.Visible = false
            end
            contentFrames[i].Visible = true
        end)
        
        tabButton.Parent = tabContainer
        table.insert(tabButtons, tabButton)
        
        -- コンテンツフレーム
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = tabName .. "Content"
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 0)
        contentFrame.Visible = i == 1
        contentFrame.ScrollingEnabled = true
        contentFrame.ScrollBarThickness = 6
        contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        contentFrame.Parent = contentArea
        table.insert(contentFrames, contentFrame)
    end
    
    -- Mainタブコンテンツ
    local mainContent = contentFrames[1]
    
    -- スピードチェンジ
    local speedFrame = createSettingFrame("スピード変更", mainContent)
    local speedSlider = createSlider(speedFrame, 16, 50, 1, 100, function(value)
        player.Character.Humanoid.WalkSpeed = value
    end)
    
    -- ジャンプ力
    local jumpFrame = createSettingFrame("ジャンプ力", mainContent)
    local jumpSlider = createSlider(jumpFrame, 50, 50, 1, 200, function(value)
        player.Character.Humanoid.JumpPower = value
    end)
    
    -- 浮遊力
    local floatFrame = createSettingFrame("浮遊力", mainContent)
    local floatToggle = createToggle(floatFrame, "有効化", false, function(enabled)
        -- 浮遊機能実装
    end)
    
    -- Fly機能
    local flyFrame = createSettingFrame("Fly機能", mainContent)
    local flyToggle = createToggle(flyFrame, "Fly ON/OFF", false, function(enabled)
        if enabled then
            activateFly()
        else
            deactivateFly()
        end
    end)
    
    -- 無重力
    local noclipFrame = createSettingFrame("無重力", mainContent)
    local noclipToggle = createToggle(noclipFrame, "Noclip ON/OFF", false, function(enabled)
        if enabled then
            activateNoclip()
        else
            deactivateNoclip()
        end
    end)
    
    -- Settingsタブコンテンツ
    local settingsContent = contentFrames[2]
    
    -- UI色設定
    local colorFrame = createSettingFrame("UIカラー", settingsContent)
    
    local colors = {
        Color3.fromRGB(45, 45, 45),    -- ダークグレー
        Color3.fromRGB(30, 60, 90),    -- ブルー
        Color3.fromRGB(90, 30, 60),    -- パープル
        Color3.fromRGB(60, 90, 30),    -- グリーン
        Color3.fromRGB(90, 60, 30),    -- ブラウン
        Color3.fromRGB(30, 90, 90),    -- シアン
        Color3.fromRGB(90, 30, 30),    -- レッド
        Color3.fromRGB(30, 30, 60),    -- ダークブルー
        Color3.fromRGB(60, 30, 90),    -- バイオレット
        Color3.fromRGB(90, 90, 30),    -- イエロー
        Color3.fromRGB(30, 60, 30),    -- ダークグリーン
        Color3.fromRGB(60, 30, 30)     -- ダークレッド
    }
    
    local colorGrid = Instance.new("UIGridLayout")
    colorGrid.CellSize = UDim2.new(0, 30, 0, 30)
    colorGrid.CellPadding = UDim2.new(0, 5, 0, 5)
    colorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    colorGrid.Parent = colorFrame
    
    for i, color in ipairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.BackgroundColor3 = color
        colorButton.Size = UDim2.new(0, 30, 0, 30)
        colorButton.BorderSizePixel = 0
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 6)
        colorCorner.Parent = colorButton
        
        colorButton.MouseButton1Click:Connect(function()
            uiSettings.color = color
            mainContainer.BackgroundColor3 = color
            saveSettings()
        end)
        
        colorButton.Parent = colorFrame
    end
    
    -- UI形状設定
    local shapeFrame = createSettingFrame("UI形状", settingsContent)
    local shapes = {"Rectangle", "Rounded", "Circle", "Swastika"}
    
    local shapeDropdown = Instance.new("TextButton")
    shapeDropdown.Text = uiSettings.shape
    shapeDropdown.Font = Enum.Font.Gotham
    shapeDropdown.TextSize = 14
    shapeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    shapeDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    shapeDropdown.Size = UDim2.new(1, -20, 0, 30)
    shapeDropdown.Position = UDim2.new(0, 10, 0, 40)
    
    local shapeCorner = Instance.new("UICorner")
    shapeCorner.CornerRadius = UDim.new(0, 6)
    shapeCorner.Parent = shapeDropdown
    
    shapeDropdown.MouseButton1Click:Connect(function()
        -- 形状変更実装
    end)
    
    shapeDropdown.Parent = shapeFrame
    
    -- シフトロック
    local shiftlockFrame = createSettingFrame("シフトロック", settingsContent)
    local shiftlockToggle = createToggle(shiftlockFrame, "シフトロック有効", false, function(enabled)
        -- シフトロック実装
    end)
    
    -- クロスヘア設定
    local crosshairFrame = createSettingFrame("クロスヘア設定", settingsContent)
    local crosshairToggle = createToggle(crosshairFrame, "クロスヘア表示", crosshairSettings.enabled, function(enabled)
        crosshairSettings.enabled = enabled
        updateCrosshair()
        saveSettings()
    end)
    
    -- クロスヘア色
    local crosshairColorFrame = createSettingFrame("クロスヘア色", settingsContent)
    
    local crosshairColorGrid = Instance.new("UIGridLayout")
    crosshairColorGrid.CellSize = UDim2.new(0, 25, 0, 25)
    crosshairColorGrid.CellPadding = UDim2.new(0, 3, 0, 3)
    crosshairColorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    crosshairColorGrid.Parent = crosshairColorFrame
    
    for i, color in ipairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.BackgroundColor3 = color
        colorButton.Size = UDim2.new(0, 25, 0, 25)
        colorButton.BorderSizePixel = 0
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 4)
        colorCorner.Parent = colorButton
        
        colorButton.MouseButton1Click:Connect(function()
            crosshairSettings.color = color
            updateCrosshair()
            saveSettings()
        end)
        
        colorButton.Parent = crosshairColorFrame
    end
    
    -- クロスヘア形状
    local crosshairShapeFrame = createSettingFrame("クロスヘア形状", settingsContent)
    local crosshairShapes = {"Cross", "Dot", "Circle", "Square", "Triangle"}
    
    local crosshairShapeLayout = Instance.new("UIGridLayout")
    crosshairShapeLayout.CellSize = UDim2.new(0, 60, 0, 30)
    crosshairShapeLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    crosshairShapeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    crosshairShapeLayout.Parent = crosshairShapeFrame
    
    for _, shape in ipairs(crosshairShapes) do
        local shapeButton = Instance.new("TextButton")
        shapeButton.Text = shape
        shapeButton.Font = Enum.Font.Gotham
        shapeButton.TextSize = 12
        shapeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        shapeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        local shapeCorner = Instance.new("UICorner")
        shapeCorner.CornerRadius = UDim.new(0, 4)
        shapeCorner.Parent = shapeButton
        
        shapeButton.MouseButton1Click:Connect(function()
            crosshairSettings.shape = shape
            updateCrosshair()
            saveSettings()
        end)
        
        shapeButton.Parent = crosshairShapeFrame
    end
    
    -- クロスヘアサイズ
    local crosshairSizeFrame = createSettingFrame("クロスヘアサイズ", settingsContent)
    local crosshairSizeSlider = createSlider(crosshairSizeFrame, crosshairSettings.size, 10, 5, 50, function(value)
        crosshairSettings.size = value
        updateCrosshair()
        saveSettings()
    end)
    
    -- 親子関係設定
    deleteButtonLayout.Parent = deleteButtonContainer
    deleteYesButton.Parent = deleteButtonContainer
    deleteNoButton.Parent = deleteButtonContainer
    deleteTitle.Parent = deleteConfirm
    deleteButtonContainer.Parent = deleteConfirm
    deleteConfirm.Parent = mainContainer
    
    titleCorner.Parent = titleBar
    titleText.Parent = titleBar
    minimizeButton.Parent = titleBar
    closeButton.Parent = titleBar
    minimizeCorner.Parent = minimizeButton
    closeCorner.Parent = closeButton
    titleBar.Parent = mainContainer
    tabContainer.Parent = mainContainer
    contentArea.Parent = mainContainer
    mainContainer.Parent = mainGui
    
    -- クロスヘア表示用
    local crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "CrosshairGui"
    crosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    crosshairGui.ResetOnSpawn = false
    
    local crosshairFrame = Instance.new("Frame")
    crosshairFrame.Name = "Crosshair"
    crosshairFrame.BackgroundTransparency = 1
    crosshairFrame.Size = UDim2.new(1, 0, 1, 0)
    crosshairFrame.Visible = crosshairSettings.enabled
    
    -- イベント接続
    minimizeButton.MouseButton1Click:Connect(function()
        local isMinimized = contentArea.Visible
        contentArea.Visible = not isMinimized
        tabContainer.Visible = not isMinimized
        mainContainer.Size = isMinimized and uiSettings.size or UDim2.new(uiSettings.size.X, UDim.new(0, 80))
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        deleteConfirm.Visible = true
    end)
    
    deleteYesButton.MouseButton1Click:Connect(function()
        createTween(mainContainer, {BackgroundTransparency = 1}, 0.3):Play()
        createTween(titleBar, {BackgroundTransparency = 1}, 0.3):Play()
        task.wait(0.3)
        mainGui:Destroy()
        crosshairGui:Destroy()
    end)
    
    deleteNoButton.MouseButton1Click:Connect(function()
        deleteConfirm.Visible = false
    end)
    
    -- クロスヘア更新関数
    local function updateCrosshair()
        crosshairFrame:ClearAllChildren()
        
        if not crosshairSettings.enabled then
            crosshairFrame.Visible = false
            return
        end
        
        crosshairFrame.Visible = true
        local center = Vector2.new(0.5, 0.5)
        
        if crosshairSettings.shape == "Cross" then
            -- 水平線
            local horizontal = Instance.new("Frame")
            horizontal.BackgroundColor3 = crosshairSettings.color
            horizontal.Size = UDim2.new(0, crosshairSettings.size, 0, crosshairSettings.thickness)
            horizontal.Position = UDim2.new(center.X, -crosshairSettings.size/2, center.Y, -crosshairSettings.thickness/2)
            horizontal.BorderSizePixel = 0
            
            -- 垂直線
            local vertical = Instance.new("Frame")
            vertical.BackgroundColor3 = crosshairSettings.color
            vertical.Size = UDim2.new(0, crosshairSettings.thickness, 0, crosshairSettings.size)
            vertical.Position = UDim2.new(center.X, -crosshairSettings.thickness/2, center.Y, -crosshairSettings.size/2)
            vertical.BorderSizePixel = 0
            
            horizontal.Parent = crosshairFrame
            vertical.Parent = crosshairFrame
            
        elseif crosshairSettings.shape == "Dot" then
            local dot = Instance.new("Frame")
            dot.BackgroundColor3 = crosshairSettings.color
            dot.Size = UDim2.new(0, crosshairSettings.thickness * 2, 0, crosshairSettings.thickness * 2)
            dot.Position = UDim2.new(center.X, -crosshairSettings.thickness, center.Y, -crosshairSettings.thickness)
            dot.BorderSizePixel = 0
            
            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = dot
            
            dot.Parent = crosshairFrame
        end
    end
    
    crosshairFrame.Parent = crosshairGui
    crosshairGui.Parent = playerGui
    updateCrosshair()
    
    -- アニメーション表示
    mainContainer.BackgroundTransparency = 1
    titleBar.BackgroundTransparency = 1
    
    createTween(mainContainer, {BackgroundTransparency = uiSettings.transparency}, 0.5):Play()
    createTween(titleBar, {BackgroundTransparency = 0}, 0.5):Play()
    
    mainGui.Parent = playerGui
    
    return mainGui
end

-- 設定フレーム作成ヘルパー関数
local function createSettingFrame(title, parent)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Size = UDim2.new(1, -20, 0, 80)
    frame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 85)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    titleLabel.Parent = frame
    frame.Parent = parent
    
    return frame
end

-- スライダー作成ヘルパー関数
local function createSlider(parent, defaultValue, minValue, maxValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, 40)
    sliderFrame.BorderSizePixel = 0
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Text = ""
    sliderButton.BackgroundTransparency = 1
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    
    fill.Parent = sliderFrame
    sliderButton.Parent = sliderFrame
    sliderFrame.Parent = parent
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(defaultValue)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -45, 0, 40)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = parent
    
    sliderButton.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition
            local sliderSize = sliderFrame.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = math.floor(minValue + (maxValue - minValue) * relativeX)
            
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            valueLabel.Text = tostring(value)
            
            if callback then
                callback(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
    
    return {
        frame = sliderFrame,
        fill = fill,
        valueLabel = valueLabel
    }
end

-- トグル作成ヘルパー関数
local function createToggle(parent, label, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, 40)
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Text = ""
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(60, 60, 60)
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -55, 0, 0)
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Text = label
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Size = UDim2.new(1, -60, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Size = UDim2.new(0, 21, 0, 21)
    toggleCircle.Position = defaultState and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleCircle.BorderSizePixel = 0
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    toggleCircle.Parent = toggleButton
    toggleLabel.Parent = toggleFrame
    toggleButton.Parent = toggleFrame
    toggleFrame.Parent = parent
    
    local state = defaultState
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.BackgroundColor3 = state and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(60, 60, 60)
        
        createTween(toggleCircle, {
            Position = state and UDim2.new(1, -23, 0, 2) or UDim2.new(0, 2, 0, 2)
        }, 0.2):Play()
        
        if callback then
            callback(state)
        end
    end)
    
    return {
        button = toggleButton,
        circle = toggleCircle,
        state = state
    }
end

-- Fly機能実装
local flyEnabled = false
local flySpeed = 50
local bodyVelocity
local bodyGyro

local function activateFly()
    if flyEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    flyEnabled = true
    
    -- BodyVelocityとBodyGyroを作成
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    bodyGyro.P = 1000
    bodyGyro.Parent = rootPart
    
    -- Flyコントロール
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not bodyVelocity or not bodyGyro then
            connection:Disconnect()
            return
        end
        
        local camera = workspace.CurrentCamera
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)
        
        local direction = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + up
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - up
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * flySpeed
        end
        
        bodyVelocity.Velocity = direction
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function deactivateFly()
    flyEnabled = false
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- Noclip機能
local noclipEnabled = false
local noclipConnection

local function activateNoclip()
    if noclipEnabled then return end
    
    noclipEnabled = true
    local character = player.Character
    
    if not character then return end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled or not character then
            noclipConnection:Disconnect()
            return
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function deactivateNoclip()
    noclipEnabled = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

-- 初期化
local function init()
    createPasswordScreen()
end

-- スクリプト実行
init()
