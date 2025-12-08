-- Roblox Lua Script with PIN UI, Rayfield Integration, and Features
-- PIN: "しゅーくりむ" (shuukurimu)
-- Place this as a LocalScript in StarterPlayerScripts or use an executor

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Rayfield Library (Paste the full Rayfield source here or load via require)
-- For demo, assuming Rayfield is loaded as a module. Replace with actual loadstring if needed.
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() -- Example loadstring[web:1]

-- Global variables
local pinUI, mainUI, settingsOpen = nil, nil, false
local crosshairEnabled = false
local shiftLockEnabled = false
local flyEnabled = false
local bodyVelocity, bodyAngularVelocity = nil, nil
local connection = nil

-- Colors table (12 colors)
local colors = {
    Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
    Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,128,0), Color3.fromRGB(128,0,255), Color3.fromRGB(0,128,255),
    Color3.fromRGB(128,255,0), Color3.fromRGB(255,128,128), Color3.fromRGB(128,128,128)
}
local currentColorIndex = 1
local uiShape = "Square" -- Square, Round, Swastika, Custom

-- Draggable function[web:1][web:7]
local function makeDraggable(frame)
    local dragToggle = nil
    local dragSpeed = 0.25
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

-- Minimize function
local function createMinimize(frame, minimizeBtn)
    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 30)}):Play()
    end)
end

-- PIN UI Creation
local function createPinUI()
    pinUI = Instance.new("ScreenGui")
    pinUI.Name = "PinUI"
    pinUI.Parent = CoreGui
    pinUI.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.BackgroundColor3 = colors[currentColorIndex]
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = pinUI

    -- Shape corner (Square/Round/Swastika)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, uiShape == "Round" and 12 or 0)
    corner.Parent = mainFrame

    -- Draggable
    makeDraggable(mainFrame)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "PINを入力 (しゅーくりむ)"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local pinBox = Instance.new("TextBox")
    pinBox.Size = UDim2.new(0.8, 0, 0, 40)
    pinBox.Position = UDim2.new(0.1, 0, 0.3, 0)
    pinBox.BackgroundColor3 = Color3.new(1,1,1)
    pinBox.Text = ""
    pinBox.TextColor3 = Color3.new(0,0,0)
    pinBox.TextScaled = true
    pinBox.Font = Enum.Font.Gotham
    pinBox.Parent = mainFrame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.8, 0, 0, 40)
    submitBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    submitBtn.BackgroundColor3 = Color3.new(0,0.7,0)
    submitBtn.Text = "送信"
    submitBtn.TextColor3 = Color3.new(1,1,1)
    submitBtn.TextScaled = true
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = mainFrame

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -35, 0, 5)
    minBtn.BackgroundColor3 = Color3.new(1,0,0)
    minBtn.Text = "-"
    minBtn.TextScaled = true
    minBtn.Parent = mainFrame
    createMinimize(mainFrame, minBtn)

    submitBtn.MouseButton1Click:Connect(function()
        if pinBox.Text == "しゅーくりむ" then
            pinUI:Destroy()
            createMainUI()
        else
            pinUI:Destroy()
            return -- Script ends
        end
    end)
end

-- Confirmation Delete UI
local function showDeleteConfirm(callback)
    local confirmGui = Instance.new("ScreenGui")
    confirmGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = colors[currentColorIndex]
    frame.Parent = confirmGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0.5, 0)
    text.BackgroundTransparency = 1
    text.Text = "本当に削除しますか？"
    text.TextColor3 = Color3.new(1,1,1)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0.45, 0, 0.4, 0)
    yesBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
    yesBtn.BackgroundColor3 = Color3.new(1,0,0)
    yesBtn.Text = "はい"
    yesBtn.TextColor3 = Color3.new(1,1,1)
    yesBtn.TextScaled = true
    yesBtn.Parent = frame

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0.45, 0, 0.4, 0)
    noBtn.Position = UDim2.new(0.5, 0, 0.55, 0)
    noBtn.BackgroundColor3 = Color3.new(0,0.7,0)
    noBtn.Text = "いいえ"
    noBtn.TextColor3 = Color3.new(1,1,1)
    noBtn.TextScaled = true
    noBtn.Parent = frame

    yesBtn.MouseButton1Click:Connect(function()
        confirmGui:Destroy()
        if callback then callback() end
    end)

    noBtn.MouseButton1Click:Connect(function()
        confirmGui:Destroy()
    end)
end

-- Main Rayfield UI Creation
function createMainUI()
    local Window = Rayfield:CreateWindow({
        Name = "メインUI",
        LoadingTitle = "しゅーくりむUI",
        LoadingSubtitle = "by User",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "ShuukurimuUI",
            FileName = "Config"
        }
    })

    -- Main Tab
    local MainTab = Window:CreateTab("Main", nil)
    local MainSection = MainTab:CreateSection("Movement")

    MainTab:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 16,
        Flag = "WalkSpeed",
        Callback = function(Value)
            player.Character.Humanoid.WalkSpeed = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Jump Power",
        Range = {50, 500},
        Increment = 1,
        CurrentValue = 50,
        Flag = "JumpPower",
        Callback = function(Value)
            player.Character.Humanoid.JumpPower = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Float Power",
        Range = {0, 100},
        Increment = 0.1,
        CurrentValue = 0,
        Flag = "FloatPower",
        Callback = function(Value)
            -- Simple float effect
            if player.Character then
                local humanoidRootPart = player.Character.HumanoidRootPart
                if Value > 0 then
                    if not connection then
                        connection = RunService.Heartbeat:Connect(function()
                            humanoidRootPart.Velocity = humanoidRootPart.Velocity + Vector3.new(0, Value, 0)
                        end)
                    end
                else
                    if connection then connection:Disconnect() end
                end
            end
        end,
    })

    -- Full Fly implementation
    MainTab:CreateToggle({
        Name = "Fly (Full)",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            flyEnabled = Value
            if flyEnabled and player.Character then
                local char = player.Character
                local root = char:WaitForChild("HumanoidRootPart")
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = root

                bodyAngularVelocity = Instance.new("BodyAngularVelocity")
                bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
                bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                bodyAngularVelocity.Parent = root

                local speed = 50
                connection = RunService.Heartbeat:Connect(function()
                    if flyEnabled then
                        local cam = workspace.CurrentCamera
                        local vel = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
                        bodyVelocity.Velocity = vel * speed
                    end
                end)
            else
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
                if connection then connection:Disconnect() end
            end
        end,
    })

    -- Settings Tab
    local SettingsTab = Window:CreateTab("設定", nil)
    local SettingsSection = SettingsTab:CreateSection("UI Settings")

    SettingsTab:CreateDropdown({
        Name = "UI Color (12 colors)",
        Options = {"Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Sky", "Lime", "Pink", "Gray"},
        CurrentOption = "Red",
        Flag = "UIColor",
        Callback = function(Option)
            currentColorIndex = table.find({"Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Sky", "Lime", "Pink", "Gray"}, Option)
            -- Apply to all UI elements if needed
        end,
    })

    SettingsTab:CreateDropdown({
        Name = "UI Shape",
        Options = {"Square", "Round", "Swastika", "Custom"},
        CurrentOption = "Square",
        Flag = "UIShape",
        Callback = function(Option)
            uiShape = Option
            -- Update corners dynamically
        end,
    })

    SettingsTab:CreateToggle({
        Name = "Shift Lock",
        CurrentValue = false,
        Flag = "ShiftLock",
        Callback = function(Value)
            shiftLockEnabled = Value
            UserInputService.MouseBehavior = Value and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
        end,
    })

    -- Crosshair Settings
    local CrosshairSection = SettingsTab:CreateSection("Crosshair")
    SettingsTab:CreateToggle({
        Name = "Enable Crosshair",
        CurrentValue = false,
        Flag = "Crosshair",
        Callback = function(Value)
            crosshairEnabled = Value
            if Value then createCrosshair() else destroyCrosshair() end
        end,
    })

    SettingsTab:CreateSlider({
        Name = "Crosshair Size",
        Range = {1, 50},
        Increment = 1,
        CurrentValue = 10,
        Flag = "CrossSize",
    })

    SettingsTab:CreateDropdown({
        Name = "Crosshair Shape",
        Options = {"Dot", "Circle", "Cross", "Square"},
        CurrentOption = "Cross",
        Flag = "CrossShape",
    })

    SettingsTab:CreateDropdown({
        Name = "Crosshair Color",
        Options = {"Red", "Green", "Blue", "Yellow", "Magenta", "Cyan", "Orange", "Purple", "Sky", "Lime", "Pink", "Gray"},
        CurrentOption = "Red",
        Flag = "CrossColor",
    })

    -- Delete Button with Confirmation
    SettingsTab:CreateButton({
        Name = "UI削除 (確認付き)",
        Callback = function()
            showDeleteConfirm(function()
                Rayfield:Destroy()
                -- Additional cleanup
            end)
        end,
    })
end

-- Crosshair functions
local crosshairGui = nil
function createCrosshair()
    crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "CustomCrosshair"
    crosshairGui.Parent = CoreGui

    local crossFrame = Instance.new("Frame")
    crossFrame.Size = UDim2.new(0, 20, 0, 20)
    crossFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
    crossFrame.BackgroundTransparency = 1
    crossFrame.Parent = crosshairGui

    -- Dynamic shape/color based on settings (simplified)
    local line1 = Instance.new("Frame") -- Horizontal
    line1.Size = UDim2.new(1, 0, 0.2, 0)
    line1.Position = UDim2.new(0, 0, 0.4, 0)
    line1.BackgroundColor3 = colors[1]
    line1.BorderSizePixel = 0
    line1.Parent = crossFrame

    local line2 = Instance.new("Frame") -- Vertical
    line2.Size = UDim2.new(0.2, 0, 1, 0)
    line2.Position = UDim2.new(0.4, 0, 0, 0)
    line2.BackgroundColor3 = colors[1]
    line2.BorderSizePixel = 0
    line2.Parent = crossFrame
end

function destroyCrosshair()
    if crosshairGui then crosshairGui:Destroy() end
end

-- Initialize
createPinUI()

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
        if connection then connection:Disconnect() end
    end
end)
