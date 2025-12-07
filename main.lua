-- このスクリプトはLocalScriptとしてStarterGuiの下に配置することを想定

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = script.Parent -- ScreenGuiを想定

-- 暗証番号
local correctPassword = "しゅーくりーむ"

-- 認証画面の作成
local authFrame = Instance.new("Frame")
authFrame.Name = "AuthFrame"
authFrame.Size = UDim2.new(0, 400, 0, 300)
authFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
authFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
authFrame.BorderSizePixel = 0
authFrame.ClipsDescendants = true
authFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = authFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "セキュリティチェック"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = authFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local inputBox = Instance.new("TextBox")
inputBox.Name = "PasswordInput"
inputBox.Size = UDim2.new(0.8, 0, 0, 50)
inputBox.Position = UDim2.new(0.1, 0, 0.3, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
inputBox.BorderSizePixel = 0
inputBox.Text = ""
inputBox.PlaceholderText = "暗証番号を入力"
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextSize = 20
inputBox.Font = Enum.Font.Gotham
inputBox.Parent = authFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputBox

local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(0.8, 0, 0, 50)
submitButton.Position = UDim2.new(0.1, 0, 0.6, 0)
submitButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
submitButton.BorderSizePixel = 0
submitButton.Text = "認証"
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.TextSize = 20
submitButton.Font = Enum.Font.GothamBold
submitButton.Parent = authFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = submitButton

local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "Message"
messageLabel.Size = UDim2.new(0.8, 0, 0, 30)
messageLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = ""
messageLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
messageLabel.TextSize = 16
messageLabel.Font = Enum.Font.Gotham
messageLabel.Parent = authFrame

-- 認証処理
local attempts = 0
local maxAttempts = 5

submitButton.MouseButton1Click:Connect(function()
    local enteredPassword = inputBox.Text
    attempts = attempts + 1
    
    if enteredPassword == correctPassword then
        messageLabel.Text = "認証成功！"
        messageLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        -- 認証後にメインUIを表示
        wait(1)
        authFrame.Visible = false
        createMainUI() -- メインUIを作成する関数
    else
        messageLabel.Text = "暗証番号が違います。試行回数: " .. attempts .. "/" .. maxAttempts
        if attempts >= maxAttempts then
            submitButton.Visible = false
            messageLabel.Text = "試行回数制限を超えました。"
        end
    end
end)

-- メインUIを作成する関数
function createMainUI()
    -- メインUIのフレーム
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui

    -- 角を丸く
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame

    -- タイトルバー（ドラッグ可能）
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 16)
    titleBarCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0.6, 0, 1, 0)
    titleText.Position = UDim2.new(0.05, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Arseus x Neo UI"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- 最小化ボタン
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(0.85, 0, 0.05, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = 24
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = titleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeButton

    -- 削除ボタン
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(0.92, 0, 0.05, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- タブボタン
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local mainTab = Instance.new("TextButton")
    mainTab.Name = "MainTab"
    mainTab.Size = UDim2.new(0.3, 0, 0.8, 0)
    mainTab.Position = UDim2.new(0.05, 0, 0.1, 0)
    mainTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    mainTab.BorderSizePixel = 0
    mainTab.Text = "Main"
    mainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainTab.TextSize = 18
    mainTab.Font = Enum.Font.GothamBold
    mainTab.Parent = tabContainer

    local mainTabCorner = Instance.new("UICorner")
    mainTabCorner.CornerRadius = UDim.new(0, 8)
    mainTabCorner.Parent = mainTab

    local settingsTab = Instance.new("TextButton")
    settingsTab.Name = "SettingsTab"
    settingsTab.Size = UDim2.new(0.3, 0, 0.8, 0)
    settingsTab.Position = UDim2.new(0.4, 0, 0.1, 0)
    settingsTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    settingsTab.BorderSizePixel = 0
    settingsTab.Text = "Settings"
    settingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTab.TextSize = 18
    settingsTab.Font = Enum.Font.GothamBold
    settingsTab.Parent = tabContainer

    local settingsTabCorner = Instance.new("UICorner")
    settingsTabCorner.CornerRadius = UDim.new(0, 8)
    settingsTabCorner.Parent = settingsTab

    -- コンテンツフレーム
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -80)
    contentFrame.Position = UDim2.new(0, 0, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    -- Mainコンテンツ
    local mainContent = Instance.new("Frame")
    mainContent.Name = "MainContent"
    mainContent.Size = UDim2.new(1, 0, 1, 0)
    mainContent.Position = UDim2.new(0, 0, 0, 0)
    mainContent.BackgroundTransparency = 1
    mainContent.Visible = true
    mainContent.Parent = contentFrame

    -- Settingsコンテンツ
    local settingsContent = Instance.new("Frame")
    settingsContent.Name = "SettingsContent"
    settingsContent.Size = UDim2.new(1, 0, 1, 0)
    settingsContent.Position = UDim2.new(0, 0, 0, 0)
    settingsContent.BackgroundTransparency = 1
    settingsContent.Visible = false
    settingsContent.Parent = contentFrame

    -- タブ切り替え
    mainTab.MouseButton1Click:Connect(function()
        mainContent.Visible = true
        settingsContent.Visible = false
        mainTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        settingsTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)

    settingsTab.MouseButton1Click:Connect(function()
        mainContent.Visible = false
        settingsContent.Visible = true
        mainTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        settingsTab.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    end)

    -- Mainコンテンツの内容を追加（例：スピードチェンジ）
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0.8, 0, 0, 30)
    speedLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "スピード倍率: 1"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 18
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainContent

    local speedSlider = Instance.new("TextBox")
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(0.8, 0, 0, 30)
    speedSlider.Position = UDim2.new(0.1, 0, 0.2, 0)
    speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedSlider.BorderSizePixel = 0
    speedSlider.Text = "1"
    speedSlider.PlaceholderText = "数値を入力"
    speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedSlider.TextSize = 16
    speedSlider.Font = Enum.Font.Gotham
    speedSlider.Parent = mainContent

    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedSlider

    local speedButton = Instance.new("TextButton")
    speedButton.Name = "SpeedButton"
    speedButton.Size = UDim2.new(0.4, 0, 0, 30)
    speedButton.Position = UDim2.new(0.3, 0, 0.3, 0)
    speedButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    speedButton.BorderSizePixel = 0
    speedButton.Text = "適用"
    speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedButton.TextSize = 18
    speedButton.Font = Enum.Font.GothamBold
    speedButton.Parent = mainContent

    local speedButtonCorner = Instance.new("UICorner")
    speedButtonCorner.CornerRadius = UDim.new(0, 8)
    speedButtonCorner.Parent = speedButton

    speedButton.MouseButton1Click:Connect(function()
        local speedValue = tonumber(speedSlider.Text)
        if speedValue then
            -- ここでプレイヤーのスピードを変更する処理を追加
            -- 例: player.Character.Humanoid.WalkSpeed = 16 * speedValue
            speedLabel.Text = "スピード倍率: " .. speedValue
        else
            speedLabel.Text = "無効な数値です"
        end
    end)

    -- ジャンプ力や浮遊力なども同様に追加可能

    -- Settingsコンテンツの内容を追加（例：UIの色変更）
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Name = "ColorLabel"
    colorLabel.Size = UDim2.new(0.8, 0, 0, 30)
    colorLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "UIの色を選択:"
    colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorLabel.TextSize = 18
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = settingsContent

    -- 色の選択ボタンを12色分作成
    local colors = {
        Color3.fromRGB(255, 0, 0),      -- 赤
        Color3.fromRGB(0, 255, 0),      -- 緑
        Color3.fromRGB(0, 0, 255),      -- 青
        Color3.fromRGB(255, 255, 0),    -- 黄
        Color3.fromRGB(255, 0, 255),    -- マゼンタ
        Color3.fromRGB(0, 255, 255),    -- シアン
        Color3.fromRGB(255, 165, 0),    -- オレンジ
        Color3.fromRGB(128, 0, 128),    -- 紫
        Color3.fromRGB(0, 128, 0),      -- 深緑
        Color3.fromRGB(128, 128, 128),  -- 灰
        Color3.fromRGB(0, 0, 0),        -- 黒
        Color3.fromRGB(255, 255, 255)   -- 白
    }

    for i, color in ipairs(colors) do
        local colorButton = Instance.new("TextButton")
        colorButton.Name = "ColorButton" .. i
        colorButton.Size = UDim2.new(0, 30, 0, 30)
        colorButton.Position = UDim2.new(0.1 + ((i-1) % 6) * 0.12, 0, 0.2 + math.floor((i-1)/6) * 0.1, 0)
        colorButton.BackgroundColor3 = color
        colorButton.BorderSizePixel = 0
        colorButton.Text = ""
        colorButton.Parent = settingsContent

        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 8)
        colorCorner.Parent = colorButton

        colorButton.MouseButton1Click:Connect(function()
            mainFrame.BackgroundColor3 = color
            titleBar.BackgroundColor3 = color:lerp(Color3.new(0,0,0), 0.2) -- 少し暗く
        end)
    end

    -- シフトロックの設定を追加（例：チェックボックス）
    local shiftLockLabel = Instance.new("TextLabel")
    shiftLockLabel.Name = "ShiftLockLabel"
    shiftLockLabel.Size = UDim2.new(0.8, 0, 0, 30)
    shiftLockLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
    shiftLockLabel.BackgroundTransparency = 1
    shiftLockLabel.Text = "シフトロック: オフ"
    shiftLockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    shiftLockLabel.TextSize = 18
    shiftLockLabel.Font = Enum.Font.Gotham
    shiftLockLabel.TextXAlignment = Enum.TextXAlignment.Left
    shiftLockLabel.Parent = settingsContent

    local shiftLockButton = Instance.new("TextButton")
    shiftLockButton.Name = "ShiftLockButton"
    shiftLockButton.Size = UDim2.new(0, 50, 0, 30)
    shiftLockButton.Position = UDim2.new(0.7, 0, 0.5, 0)
    shiftLockButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    shiftLockButton.BorderSizePixel = 0
    shiftLockButton.Text = "切り替え"
    shiftLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shiftLockButton.TextSize = 16
    shiftLockButton.Font = Enum.Font.Gotham
    shiftLockButton.Parent = settingsContent

    local shiftLockCorner = Instance.new("UICorner")
    shiftLockCorner.CornerRadius = UDim.new(0, 8)
    shiftLockCorner.Parent = shiftLockButton

    local shiftLockEnabled = false
    shiftLockButton.MouseButton1Click:Connect(function()
        shiftLockEnabled = not shiftLockEnabled
        if shiftLockEnabled then
            shiftLockLabel.Text = "シフトロック: オン"
            -- ここでシフトロックを有効にする処理を追加（RobloxのShiftLockはデフォルトであるが、カスタム実装が必要かもしれない）
        else
            shiftLockLabel.Text = "シフトロック: オフ"
        end
    end)

    -- クロスヘアの設定も同様に追加可能（省略）

    -- ドラッグ機能
    local dragging = false
    local dragInput, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 最小化機能
    local isMinimized = false
    local originalSize = mainFrame.Size
    local minimizedSize = UDim2.new(0, 500, 0, 40) -- タイトルバーのみ表示

    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame.Size = minimizedSize
            contentFrame.Visible = false
            tabContainer.Visible = false
        else
            mainFrame.Size = originalSize
            contentFrame.Visible = true
            tabContainer.Visible = true
        end
    end)

    -- 削除機能（確認付き）
    closeButton.MouseButton1Click:Connect(function()
        -- 確認画面を作成
        local confirmFrame = Instance.new("Frame")
        confirmFrame.Name = "ConfirmFrame"
        confirmFrame.Size = UDim2.new(0, 300, 0, 150)
        confirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        confirmFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        confirmFrame.BorderSizePixel = 0
        confirmFrame.Parent = mainFrame

        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 12)
        confirmCorner.Parent = confirmFrame

        local confirmText = Instance.new("TextLabel")
        confirmText.Name = "ConfirmText"
        confirmText.Size = UDim2.new(0.8, 0, 0, 60)
        confirmText.Position = UDim2.new(0.1, 0, 0.1, 0)
        confirmText.BackgroundTransparency = 1
        confirmText.Text = "本当にUIを削除しますか？"
        confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmText.TextSize = 20
        confirmText.Font = Enum.Font.GothamBold
        confirmText.Parent = confirmFrame

        local yesButton = Instance.new("TextButton")
        yesButton.Name = "YesButton"
        yesButton.Size = UDim2.new(0.3, 0, 0, 40)
        yesButton.Position = UDim2.new(0.2, 0, 0.6, 0)
        yesButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        yesButton.BorderSizePixel = 0
        yesButton.Text = "はい"
        yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesButton.TextSize = 18
        yesButton.Font = Enum.Font.GothamBold
        yesButton.Parent = confirmFrame

        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 8)
        yesCorner.Parent = yesButton

        local noButton = Instance.new("TextButton")
        noButton.Name = "NoButton"
        noButton.Size = UDim2.new(0.3, 0, 0, 40)
        noButton.Position = UDim2.new(0.6, 0, 0.6, 0)
        noButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        noButton.BorderSizePixel = 0
        noButton.Text = "いいえ"
        noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        noButton.TextSize = 18
        noButton.Font = Enum.Font.GothamBold
        noButton.Parent = confirmFrame

        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, 8)
        noCorner.Parent = noButton

        yesButton.MouseButton1Click:Connect(function()
            mainFrame:Destroy()
        end)

        noButton.MouseButton1Click:Connect(function()
            confirmFrame:Destroy()
        end)
    end)
end
