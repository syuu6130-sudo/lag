-- Arseus x Neo風 超カスタムUI Roblox Script (LocalScript in StarterPlayerScripts)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = game.Workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- パスワード設定
local PASSWORD = "しゅーくりーむ"
local inputCode = ""

-- デバイス検出とレスポンシブ設定 [web:1]
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getScreenSize()
    local viewportSize = Camera.ViewportSize
    return viewportSize.X, viewportSize.Y
end

-- スムーズなTween情報 (Arseus x Neo風)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0)
local fastTween = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- パスワード入力画面作成 (スマホ/PC対応)
local function createPinScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PinAuth"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- 角丸 + グラデーション (最先端UI)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔐 認証が必要です"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- 入力フィールド
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(0.8, 0, 0.15, 0)
    inputBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    inputBox.Text = ""
    inputBox.PlaceholderText = "暗証番号を入力..."
    inputBox.TextColor3 = Color3.fromRGB(200, 200, 220)
    inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    inputBox.TextScaled = true
    inputBox.Font = Enum.Font.Gotham
    inputBox.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 12)
    inputCorner.Parent = inputBox
    
    -- 確認ボタン
    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "SubmitBtn"
    submitBtn.Size = UDim2.new(0.6, 0, 0.12, 0)
    submitBtn.Position = UDim2.new(0.2, 0, 0.6, 0)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    submitBtn.Text = "送信しますか？"
    submitBtn.TextColor3 = Color3.new(1,1,1)
    submitBtn.TextScaled = true
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = mainFrame
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 10)
    submitCorner.Parent = submitBtn
    
    -- レスポンシブ調整 [web:1]
    local width, height = getScreenSize()
    if isMobile() or width < 800 then
        mainFrame.Size = UDim2.new(0.85, 0, 0.7, 0)
        mainFrame.Position = UDim2.new(0.075, 0, 0.15, 0)
        inputBox.Size = UDim2.new(0.9, 0, 0.18, 0)
    end
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            inputCode = inputBox.Text
            submitBtn.Text = "送信中..."
            wait(0.5)
            if inputCode:lower() == PASSWORD:lower() then
                screenGui:Destroy()
                createMainUI()
            else
                inputBox.Text = ""
                inputBox.PlaceholderText = "✖ 暗証番号が違います"
                submitBtn.Text = "再試行"
                wait(1)
                inputBox.PlaceholderText = "暗証番号を入力..."
                submitBtn.Text = "送信しますか？"
            end
        end
    end)
    
    submitBtn.MouseButton1Click:Connect(function()
        inputCode = inputBox.Text
        submitBtn.Text = "送信中..."
        wait(0.5)
        if inputCode:lower() == PASSWORD:lower() then
            screenGui:Destroy()
            createMainUI()
        else
            inputBox.Text = ""
            inputBox.PlaceholderText = "✖ 暗証番号が違います"
            submitBtn.Text = "再試行"
            wait(1)
            inputBox.PlaceholderText = "暗証番号を入力..."
            submitBtn.Text = "送信しますか？"
        end
    end)
    
    -- アニメーション
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, fastTween, {Size = mainFrame.Size}):Play()
end

-- 超カスタムMain UI作成 (Arseus x Neo風)
local mainGui, mainFrame
local isDragging = false
local dragStart, startPos
local currentShape = "RoundedRect" -- 四角, Circle, Swastika, etc.
local currentColor = 1
local colors = {
    Color3.fromRGB(0,170,255), Color3.fromRGB(255,100,100), Color3.fromRGB(100,255,100),
    Color3.fromRGB(255,255,100), Color3.fromRGB(255,100,255), Color3.fromRGB(100,100,255),
    Color3.fromRGB(255,200,100), Color3.fromRGB(100,255,255), Color3.fromRGB(255,150,200),
    Color3.fromRGB(150,255,150), Color3.fromRGB(200,150,255), Color3.fromRGB(255,255,150)
}

local function createShape(frame, shapeType)
    if frame:FindFirstChild("Shape") then frame.Shape:Destroy() end
    
    if shapeType == "Circle" then
        local circle = Instance.new("ImageLabel")
        circle.Name = "Shape"
        circle.Size = UDim2.new(1, 0, 1, 0)
        circle.BackgroundTransparency = 1
        circle.Image = "rbxassetid://4996891970"
        circle.ImageColor3 = colors[currentColor]
        circle.ScaleType = Enum.ScaleType.Stretch
        circle.Parent = frame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame
    elseif shapeType == "Swastika" then
        -- 卍型 (カスタムデザイン)
        local swastika = Instance.new("Frame")
        swastika.Name = "Shape"
        swastika.Size = UDim2.new(1, 0, 1, 0)
        swastika.BackgroundColor3 = colors[currentColor]
        swastika.ZIndex = frame.ZIndex - 1
        swastika.Parent = frame
        -- 卍の各腕を作成 (簡略版)
        for i = 1, 4 do
            local arm = Instance.new("Frame")
            arm.Size = UDim2.new(0.3, 0, 0.15, 0)
            arm.BorderSizePixel = 0
            arm.BackgroundColor3 = colors[currentColor]
            arm.Parent = swastika
            arm.Position = (i == 1 and UDim2.new(0.05, 0, 0.425, 0)) or
                          (i == 2 and UDim2.new(0.425, 0, 0.05, 0)) or
                          (i == 3 and UDim2.new(0.65, 0, 0.425, 0)) or
                          UDim2.new(0.425, 0, 0.65, 0)
        end
    else
        -- デフォルト角丸四角
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = frame
        frame.BackgroundColor3 = colors[currentColor]
    end
end

-- ドラッグ機能
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
end

-- 確認ダイアログ
local function createConfirmDialog(message, onYes)
    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0.3, 0, 0.25, 0)
    dialog.Position = UDim2.new(0.35, 0, 0.375, 0)
    dialog.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    dialog.Parent = mainGui
    dialog.Active = true
    dialog.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialog
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 0.5, 0)
    text.Position = UDim2.new(0, 10, 0.1, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.new(1,1,1)
    text.TextScaled = true
    text.Font = Enum.Font.Gotham
    text.Parent = dialog
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0.45, 0, 0.3, 0)
    yesBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
    yesBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    yesBtn.Text = "はい"
    yesBtn.TextColor3 = Color3.new(1,1,1)
    yesBtn.TextScaled = true
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.Parent = dialog
    
    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0.45, 0, 0.3, 0)
    noBtn.Position = UDim2.new(0.5, 0, 0.65, 0)
    noBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    noBtn.Text = "いいえ"
    noBtn.TextColor3 = Color3.new(1,1,1)
    noBtn.TextScaled = true
    noBtn.Font = Enum.Font.GothamBold
    noBtn.Parent = dialog
    
    yesBtn.MouseButton1Click:Connect(function()
        onYes()
        dialog:Destroy()
    end)
    
    noBtn.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Main UI作成
function createMainUI()
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "ArseusXNeoUI"
    mainGui.ResetOnSpawn = false
    mainGui.Parent = playerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    mainFrame.BackgroundTransparency = 1
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = mainGui
    makeDraggable(mainFrame)
    
    -- タイトルバー
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Arseus x Neo UI"
    titleText.TextColor3 = Color3.new(1,1,1)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextScaled = true
    titleText.Parent = titleBar
    
    -- 最小化ボタン
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -65, 0.15, 0)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1,1,1)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextScaled = true
    minimizeBtn.Parent = titleBar
    
    -- 削除ボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0.15, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    closeBtn.Parent = titleBar
    
    createShape(mainFrame, currentShape)
    
    -- コンテナフレーム
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -20, 1, -60)
    container.Position = UDim2.new(0, 10, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame
    
    -- タブシステム
    local tabs = {"Main", "設定", "Crosshair"}
    local currentTab = "Main"
    local tabButtons = {}
    local tabFrames = {}
    
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Size = UDim2.new(0, 100, 0, 30)
        tabBtn.Position = UDim2.new(0, (i-1)*110, 0, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.new(1,1,1)
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextScaled = true
        tabBtn.Parent = container
        tabButtons[tabName] = tabBtn
        
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabName .. "Frame"
        tabFrame.Size = UDim2.new(1, 0, 1, -40)
        tabFrame.Position = UDim2.new(0, 0, 0, 40)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = (tabName == "Main")
        tabFrame.Parent = container
        tabFrames[tabName] = tabFrame
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, frame in pairs(tabFrames) do
                frame.Visible = false
            end
            tabFrames[tabName].Visible = true
            currentTab = tabName
        end)
    end
    
    -- Mainタブ内容 (スピード、ジャンプ、Flyなど)
    local mainFrameContent = tabFrames.Main
    local speedSlider = createSlider(mainFrameContent, "Speed", 16, 500, player.Character.Humanoid.WalkSpeed)
    local jumpSlider = createSlider(mainFrameContent, "JumpPower", 50, 200, player.Character.Humanoid.JumpPower)
    
    -- Fly機能 (全方位対応)
    local flyToggle = createToggle(mainFrameContent, "Fly", false)
    local flySpeedSlider = createSlider(mainFrameContent, "Fly Speed", 1, 100, 50)
    local bodyVelocity, bodyAngularVelocity
    
    flyToggle.MouseButton1Click:Connect(function()
        local flying = flyToggle.Text == "Fly: ON"
        toggleFly(flying, flySpeedSlider.Value)
    end)
    
    -- 設定タブ
    local settingsFrame = tabFrames.設定
    createColorPicker(settingsFrame)
    createShapePicker(settingsFrame)
    createToggle(settingsFrame, "ShiftLock", false)
    
    -- Crosshairタブ (後述)
    
    -- ボタン機能
    minimizeBtn.MouseButton1Click:Connect(function()
        container.Visible = not container.Visible
        minimizeBtn.Text = container.Visible and "−" or "+"
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        createConfirmDialog("本当にUIを削除しますか？", function()
            mainGui:Destroy()
        end)
    end)
end

-- ユーティリティ関数群
function createSlider(parent, name, min, max, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.55, 0, 0, 8)
    slider.Position = UDim2.new(0.45, 0, 0.45, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.Text = ""
    slider.Parent = frame
    
    local value = default
    slider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = player:GetMouse()
            local relativeX = math.clamp((mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * relativeX
            slider.Size = UDim2.new(relativeX, 0, 0, 8)
            label.Text = name .. ": " .. math.floor(value)
            if name == "Speed" then
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = value
                end
            elseif name == "JumpPower" then
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.JumpPower = value
                end
            end
        end)
        slider.MouseButton1Up:Connect(function()
            connection:Disconnect()
        end)
    end)
    
    return {Value = function() return value end}
end

function createToggle(parent, name, default)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, -20, 0, 40)
    toggle.Position = UDim2.new(0, 10, 0, 10)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamSemibold
    toggle.TextScaled = true
    toggle.Parent = parent
    
    toggle.MouseButton1Click:Connect(function()
        local isOn = toggle.Text == name .. ": ON"
        toggle.Text = name .. ": " .. (isOn and "OFF" or "ON")
        toggle.BackgroundColor3 = isOn and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(0, 200, 100)
    end)
    
    return toggle
end

function toggleFly(enabled, speed)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    if enabled then
        local rootPart = player.Character.HumanoidRootPart
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = rootPart
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if bodyVelocity and bodyVelocity.Parent then
                local camera = workspace.CurrentCamera
                local vel = camera.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and speed or 0)
                vel = vel + camera.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.D) and speed or 0)
                vel = vel + camera.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.A) and -speed or 0)
                vel = vel + Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.Space) and speed or 0, 0)
                vel = vel + Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -speed or 0, 0)
                bodyVelocity.Velocity = vel
            else
                connection:Disconnect()
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
    end
end

-- 初期化
createPinScreen()
