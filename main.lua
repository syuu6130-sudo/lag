-- LocalScript: PIN + Rayfield-like UI
-- Place this LocalScript in StarterGui (one copy)
-- Author: ChatGPT (adapt for your needs)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "PinAndRayfieldGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ====== 設定 ======
local CORRECT_PIN = "しゅーくりむ"
local GUI_ZINDEX = 50

local COLORS = {
    Color3.fromRGB(255, 255, 255), -- 白
    Color3.fromRGB(0,   0,   0),   -- 黒
    Color3.fromRGB(255, 0,   0),   -- 赤
    Color3.fromRGB(0,   255, 0),   -- 緑
    Color3.fromRGB(0,   0,   255), -- 青
    Color3.fromRGB(255, 165, 0),   -- 橙
    Color3.fromRGB(128, 0,   128), -- 紫
    Color3.fromRGB(255, 192, 203), -- ピンク
    Color3.fromRGB(255, 255, 0),   -- 黄
    Color3.fromRGB(0,   255, 255), -- 水色
    Color3.fromRGB(128, 128, 128), -- 灰
    Color3.fromRGB(34,  139, 34)   -- 深緑
}

local UI_SHAPES = {"四角", "丸っぽい", "通常(角丸)", "卍型", "その他"} -- ユーザ選択肢

-- ====== ヘルパー ======
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
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
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function round(n) return math.floor(n+0.5) end

-- ====== PIN UI ======
local pinGui = Instance.new("Frame")
pinGui.Name = "PinFrame"
pinGui.AnchorPoint = Vector2.new(0.5,0.5)
pinGui.Position = UDim2.new(0.5,0,0.5,0)
pinGui.Size = UDim2.new(0,350,0,180)
pinGui.BackgroundColor3 = Color3.fromRGB(20,20,20)
pinGui.BackgroundTransparency = 0
pinGui.BorderSizePixel = 0
pinGui.ZIndex = GUI_ZINDEX
pinGui.Parent = gui

local pinTitle = Instance.new("TextLabel", pinGui)
pinTitle.Size = UDim2.new(1,0,0,36)
pinTitle.BackgroundTransparency = 1
pinTitle.Text = "暗証番号を入力してください"
pinTitle.TextColor3 = Color3.fromRGB(255,255,255)
pinTitle.Font = Enum.Font.GothamBold
pinTitle.TextSize = 20
pinTitle.ZIndex = GUI_ZINDEX

local pinBox = Instance.new("TextBox", pinGui)
pinBox.PlaceholderText = "暗証番号"
pinBox.Size = UDim2.new(0.95,0,0,36)
pinBox.Position = UDim2.new(0.025,0,0,46)
pinBox.ClearTextOnFocus = false
pinBox.Text = ""
pinBox.TextSize = 18
pinBox.TextColor3 = Color3.fromRGB(255,255,255)
pinBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
pinBox.BorderSizePixel = 0
pinBox.ClipsDescendants = true
pinBox.ZIndex = GUI_ZINDEX

local submitBtn = Instance.new("TextButton", pinGui)
submitBtn.Size = UDim2.new(0.45, -8, 0,36)
submitBtn.Position = UDim2.new(0.025,0,0,92)
submitBtn.Text = "送信"
submitBtn.Font = Enum.Font.Gotham
submitBtn.TextSize = 18
submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
submitBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
submitBtn.BorderSizePixel = 0
submitBtn.ZIndex = GUI_ZINDEX

local cancelBtn = Instance.new("TextButton", pinGui)
cancelBtn.Size = UDim2.new(0.45, -8, 0,36)
cancelBtn.Position = UDim2.new(0.525,0,0,92)
cancelBtn.Text = "キャンセル"
cancelBtn.Font = Enum.Font.Gotham
cancelBtn.TextSize = 18
cancelBtn.TextColor3 = Color3.fromRGB(255,255,255)
cancelBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
cancelBtn.BorderSizePixel = 0
cancelBtn.ZIndex = GUI_ZINDEX

local pinMinBtn = Instance.new("TextButton", pinGui)
pinMinBtn.Size = UDim2.new(0,28,0,28)
pinMinBtn.Position = UDim2.new(1,-36,0,4)
pinMinBtn.Text = "—"
pinMinBtn.Font = Enum.Font.Gotham
pinMinBtn.TextSize = 20
pinMinBtn.TextColor3 = Color3.fromRGB(255,255,255)
pinMinBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
pinMinBtn.BorderSizePixel = 0
pinMinBtn.ZIndex = GUI_ZINDEX

makeDraggable(pinGui, pinTitle)

local function destroyAll()
    pcall(function() gui:Destroy() end)
end

local function loadRayfield()
    -- PIN UI を消して Rayfield 風 UI を生成
    if pinGui and pinGui.Parent then
        pinGui:Destroy()
    end

    -- Root frame
    local rf = Instance.new("Frame")
    rf.Name = "RayRoot"
    rf.Size = UDim2.new(0,420,0,520)
    rf.Position = UDim2.new(0.02,0,0.15,0)
    rf.BackgroundColor3 = Color3.fromRGB(24,24,24)
    rf.BorderSizePixel = 0
    rf.ZIndex = GUI_ZINDEX
    rf.Parent = gui

    -- TitleBar
    local titleBar = Instance.new("Frame", rf)
    titleBar.Size = UDim2.new(1,0,0,36)
    titleBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", titleBar)
    title.Text = "Rayfield - Custom UI"
    title.Size = UDim2.new(0.7,0,1,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.ZIndex = GUI_ZINDEX

    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Text = "—"
    minBtn.Size = UDim2.new(0,28,0,28)
    minBtn.Position = UDim2.new(1,-36,0,4)
    minBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    minBtn.BorderSizePixel = 0
    minBtn.Font = Enum.Font.Gotham
    minBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minBtn.ZIndex = GUI_ZINDEX

    local delBtn = Instance.new("TextButton", titleBar)
    delBtn.Text = "×"
    delBtn.Size = UDim2.new(0,28,0,28)
    delBtn.Position = UDim2.new(1,-72,0,4)
    delBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    delBtn.BorderSizePixel = 0
    delBtn.Font = Enum.Font.Gotham
    delBtn.TextColor3 = Color3.fromRGB(255,255,255)
    delBtn.ZIndex = GUI_ZINDEX

    -- Body (Left: menu, Right: content)
    local left = Instance.new("Frame", rf)
    left.Size = UDim2.new(0,140,1,-36)
    left.Position = UDim2.new(0,0,0,36)
    left.BackgroundTransparency = 1

    local right = Instance.new("Frame", rf)
    right.Size = UDim2.new(1,-140,1,-36)
    right.Position = UDim2.new(0,140,0,36)
    right.BackgroundTransparency = 1

    -- Menu buttons
    local menuNames = {"Main","設定","Crosshair"}
    local menuButtons = {}
    for i,name in ipairs(menuNames) do
        local b = Instance.new("TextButton", left)
        b.Size = UDim2.new(1, -8, 0, 44)
        b.Position = UDim2.new(0,4,0,(i-1)*50 + 8)
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 16
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        b.BorderSizePixel = 0
        b.ZIndex = GUI_ZINDEX
        menuButtons[name] = b
    end

    -- content frames
    local contents = {}
    for _,name in ipairs(menuNames) do
        local f = Instance.new("Frame", right)
        f.Size = UDim2.new(1,0,1,0)
        f.BackgroundTransparency = 1
        f.Visible = false
        contents[name] = f
    end
    contents["Main"].Visible = true

    -- ドラッグ設定
    makeDraggable(rf, titleBar)

    -- 最小化
    local minimized = false
    local prevSize = rf.Size
    minBtn.MouseButton1Click:Connect(function()
        if not minimized then
            prevSize = rf.Size
            rf.Size = UDim2.new(0,220,0,36)
            for _,v in pairs(rf:GetChildren()) do
                if v ~= titleBar then v.Visible = false end
            end
            minimized = true
        else
            rf.Size = prevSize
            for _,v in pairs(rf:GetChildren()) do
                v.Visible = true
            end
            minimized = false
        end
    end)

    -- 削除ボタン（確認画面）
    local confirmFrame = Instance.new("Frame", gui)
    confirmFrame.Size = UDim2.new(0,300,0,140)
    confirmFrame.AnchorPoint = Vector2.new(0.5,0.5)
    confirmFrame.Position = UDim2.new(0.5,0.5)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    confirmFrame.BorderSizePixel = 0
    confirmFrame.Visible = false
    confirmFrame.ZIndex = GUI_ZINDEX+5

    local cfText = Instance.new("TextLabel", confirmFrame)
    cfText.Size = UDim2.new(1,0,0,60)
    cfText.Position = UDim2.new(0,0,0,10)
    cfText.BackgroundTransparency = 1
    cfText.Text = "本当にUIを削除しますか？"
    cfText.TextColor3 = Color3.fromRGB(255,255,255)
    cfText.Font = Enum.Font.GothamBold
    cfText.TextSize = 18

    local yesBtn = Instance.new("TextButton", confirmFrame)
    yesBtn.Size = UDim2.new(0.45,-8,0,40)
    yesBtn.Position = UDim2.new(0.025,0,0,80)
    yesBtn.Text = "はい"
    yesBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    yesBtn.Font = Enum.Font.Gotham
    yesBtn.TextColor3 = Color3.fromRGB(255,255,255)
    yesBtn.BorderSizePixel = 0

    local noBtn = Instance.new("TextButton", confirmFrame)
    noBtn.Size = UDim2.new(0.45,-8,0,40)
    noBtn.Position = UDim2.new(0.525,0,0,80)
    noBtn.Text = "いいえ"
    noBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    noBtn.Font = Enum.Font.Gotham
    noBtn.TextColor3 = Color3.fromRGB(255,255,255)
    noBtn.BorderSizePixel = 0

    delBtn.MouseButton1Click:Connect(function()
        confirmFrame.Visible = true
    end)
    noBtn.MouseButton1Click:Connect(function()
        confirmFrame.Visible = false
    end)
    yesBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- ====== 設定画面作成 ======
    local settingsFrame = contents["設定"]

    -- Shape dropdown
    local shapeLabel = Instance.new("TextLabel", settingsFrame)
    shapeLabel.Text = "UIの形状:"
    shapeLabel.Position = UDim2.new(0,6,0,6)
    shapeLabel.Size = UDim2.new(0,200,0,24)
    shapeLabel.BackgroundTransparency = 1
    shapeLabel.Font = Enum.Font.Gotham
    shapeLabel.TextSize = 14
    shapeLabel.TextColor3 = Color3.fromRGB(255,255,255)

    local shapeDropdown = Instance.new("TextButton", settingsFrame)
    shapeDropdown.Text = "四角 ▾"
    shapeDropdown.Position = UDim2.new(0,6,0,36)
    shapeDropdown.Size = UDim2.new(0,160,0,28)
    shapeDropdown.Font = Enum.Font.Gotham
    shapeDropdown.TextSize = 14
    shapeDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    shapeDropdown.BackgroundColor3 = Color3.fromRGB(45,45,45)
    shapeDropdown.BorderSizePixel = 0

    local shapeList = Instance.new("Frame", settingsFrame)
    shapeList.Visible = false
    shapeList.Position = UDim2.new(0,6,0,66)
    shapeList.Size = UDim2.new(0,160,0,#UI_SHAPES*28)
    shapeList.BackgroundColor3 = Color3.fromRGB(30,30,30)
    shapeList.BorderSizePixel = 0

    for i,option in ipairs(UI_SHAPES) do
        local opt = Instance.new("TextButton", shapeList)
        opt.Size = UDim2.new(1,0,0,28)
        opt.Position = UDim2.new(0,0,0,(i-1)*28)
        opt.Text = option
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 14
        opt.TextColor3 = Color3.fromRGB(255,255,255)
        opt.BackgroundTransparency = 1
        opt.BorderSizePixel = 0
        opt.ZIndex = GUI_ZINDEX
        opt.MouseButton1Click:Connect(function()
            shapeDropdown.Text = option.." ▾"
            shapeList.Visible = false
            applyShape(option, rf)
        end)
    end

    shapeDropdown.MouseButton1Click:Connect(function()
        shapeList.Visible = not shapeList.Visible
    end)

    -- Color palette: 12色
    local colorLabel = Instance.new("TextLabel", settingsFrame)
    colorLabel.Text = "UIカラー (12色):"
    colorLabel.Position = UDim2.new(0,6,0,66 + #UI_SHAPES*28 + 8)
    colorLabel.Size = UDim2.new(0,200,0,20)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextSize = 14
    colorLabel.TextColor3 = Color3.fromRGB(255,255,255)

    local colorContainer = Instance.new("Frame", settingsFrame)
    colorContainer.Position = UDim2.new(0,6,0,96 + #UI_SHAPES*28)
    colorContainer.Size = UDim2.new(0,160,0,60)
    colorContainer.BackgroundTransparency = 1

    for i,c in ipairs(COLORS) do
        local sw = Instance.new("TextButton", colorContainer)
        sw.Size = UDim2.new(0,28,0,28)
        sw.Position = UDim2.new(0, (i-1)%4 * 34, 0, math.floor((i-1)/4)*32)
        sw.BackgroundColor3 = c
        sw.Text = ""
        sw.BorderSizePixel = 1
        sw.MouseButton1Click:Connect(function()
            applyColor(c, rf)
        end)
    end

    -- ShiftLock toggle
    local slabel = Instance.new("TextLabel", settingsFrame)
    slabel.Text = "ShiftLock:"
    slabel.Position = UDim2.new(0,6,0,170)
    slabel.Size = UDim2.new(0,80,0,20)
    slabel.BackgroundTransparency = 1
    slabel.Font = Enum.Font.Gotham
    slabel.TextSize = 14
    slabel.TextColor3 = Color3.fromRGB(255,255,255)

    local sToggle = Instance.new("TextButton", settingsFrame)
    sToggle.Text = "OFF"
    sToggle.Position = UDim2.new(0,90,0,170)
    sToggle.Size = UDim2.new(0,56,0,22)
    sToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    sToggle.Font = Enum.Font.Gotham
    sToggle.TextColor3 = Color3.fromRGB(255,255,255)
    sToggle.BorderSizePixel = 0

    local shiftLockEnabled = false
    sToggle.MouseButton1Click:Connect(function()
        shiftLockEnabled = not shiftLockEnabled
        sToggle.Text = shiftLockEnabled and "ON" or "OFF"
        -- クライアント側で疑似ShiftLock: マウス挙動をロックしたり、代替処理を入れられます
        if shiftLockEnabled then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)

    -- ====== Crosshair 設定画面 ======
    local crossFrame = contents["Crosshair"]

    local chLabel = Instance.new("TextLabel", crossFrame)
    chLabel.Text = "クロスヘア設定"
    chLabel.Position = UDim2.new(0,6,0,6)
    chLabel.Size = UDim2.new(0,200,0,26)
    chLabel.BackgroundTransparency = 1
    chLabel.Font = Enum.Font.GothamBold
    chLabel.TextColor3 = Color3.fromRGB(255,255,255)
    chLabel.TextSize = 18

    local chShapeLabel = Instance.new("TextLabel", crossFrame)
    chShapeLabel.Text = "形状:"
    chShapeLabel.Position = UDim2.new(0,6,0,36)
    chShapeLabel.Size = UDim2.new(0,80,0,20)
    chShapeLabel.BackgroundTransparency = 1
    chShapeLabel.Font = Enum.Font.Gotham
    chShapeLabel.TextColor3 = Color3.fromRGB(255,255,255)

    local chShapeDrop = Instance.new("TextButton", crossFrame)
    chShapeDrop.Text = "十字 ▾"
    chShapeDrop.Position = UDim2.new(0,90,0,36)
    chShapeDrop.Size = UDim2.new(0,120,0,22)
    chShapeDrop.Font = Enum.Font.Gotham
    chShapeDrop.TextColor3 = Color3.fromRGB(255,255,255)
    chShapeDrop.BackgroundColor3 = Color3.fromRGB(45,45,45)
    chShapeDrop.BorderSizePixel = 0

    local chShapes = {"十字","点","輪っか","矢印","カスタム"}
    local chList = Instance.new("Frame", crossFrame)
    chList.Visible = false
    chList.Position = UDim2.new(0,90,0,58)
    chList.Size = UDim2.new(0,120,0,#chShapes*24)
    chList.BackgroundColor3 = Color3.fromRGB(30,30,30)
    chList.BorderSizePixel = 0

    for i,opt in ipairs(chShapes) do
        local b = Instance.new("TextButton", chList)
        b.Size = UDim2.new(1,0,0,24)
        b.Position = UDim2.new(0,0,0,(i-1)*24)
        b.Text = opt
        b.BackgroundTransparency = 1
        b.Font = Enum.Font.Gotham
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.MouseButton1Click:Connect(function()
            chShapeDrop.Text = opt.." ▾"
            chList.Visible = false
            applyCrosshairShape(opt)
        end)
    end
    chShapeDrop.MouseButton1Click:Connect(function() chList.Visible = not chList.Visible end)

    -- Crosshair color/size
    local chColorLabel = Instance.new("TextLabel", crossFrame)
    chColorLabel.Text = "色:"
    chColorLabel.Position = UDim2.new(0,6,0,58 + #chShapes*0)
    chColorLabel.Size = UDim2.new(0,40,0,20)
    chColorLabel.BackgroundTransparency = 1
    chColorLabel.Font = Enum.Font.Gotham
    chColorLabel.TextColor3 = Color3.fromRGB(255,255,255)

    local chColorPick = Instance.new("Frame", crossFrame)
    chColorPick.Position = UDim2.new(0,50,0,58)
    chColorPick.Size = UDim2.new(0,220,0,40)
    chColorPick.BackgroundTransparency = 1

    for i,c in ipairs(COLORS) do
        local btn = Instance.new("TextButton", chColorPick)
        btn.Size = UDim2.new(0,28,0,28)
        btn.Position = UDim2.new(0,(i-1)%6 * 34,0, math.floor((i-1)/6)*32)
        btn.BackgroundColor3 = c
        btn.Text = ""
        btn.BorderSizePixel = 1
        btn.MouseButton1Click:Connect(function()
            applyCrosshairColor(c)
        end)
    end

    local chSizeLabel = Instance.new("TextLabel", crossFrame)
    chSizeLabel.Text = "サイズ:"
    chSizeLabel.Position = UDim2.new(0,6,0,120)
    chSizeLabel.Size = UDim2.new(0,60,0,20)
    chSizeLabel.BackgroundTransparency = 1
    chSizeLabel.Font = Enum.Font.Gotham
    chSizeLabel.TextColor3 = Color3.fromRGB(255,255,255)

    local chSizeSlider = Instance.new("TextBox", crossFrame)
    chSizeSlider.Position = UDim2.new(0,72,0,120)
    chSizeSlider.Size = UDim2.new(0,60,0,22)
    chSizeSlider.Text = "20"
    chSizeSlider.ClearTextOnFocus = false

    local applyChBtn = Instance.new("TextButton", crossFrame)
    applyChBtn.Position = UDim2.new(0,144,0,120)
    applyChBtn.Size = UDim2.new(0,70,0,22)
    applyChBtn.Text = "適用"
    applyChBtn.Font = Enum.Font.Gotham
    applyChBtn.TextColor3 = Color3.fromRGB(255,255,255)
    applyChBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    applyChBtn.BorderSizePixel = 0

    -- ====== Main メニュー（速度、ジャンプ、Float, Fly） ======
    local main = contents["Main"]

    local wsLabel = Instance.new("TextLabel", main)
    wsLabel.Text = "WalkSpeed:"
    wsLabel.Font = Enum.Font.Gotham
    wsLabel.TextColor3 = Color3.fromRGB(255,255,255)
    wsLabel.Position = UDim2.new(0,6,0,6)
    wsLabel.Size = UDim2.new(0,100,0,20)

    local wsBox = Instance.new("TextBox", main)
    wsBox.Text = tostring(player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16)
    wsBox.Position = UDim2.new(0,110,0,6)
    wsBox.Size = UDim2.new(0,80,0,20)
    wsBox.ClearTextOnFocus = false

    local applyWS = Instance.new("TextButton", main)
    applyWS.Text = "適用"
    applyWS.Position = UDim2.new(0,200,0,6)
    applyWS.Size = UDim2.new(0,70,0,20)
    applyWS.BackgroundColor3 = Color3.fromRGB(60,60,60)
    applyWS.TextColor3 = Color3.fromRGB(255,255,255)
    applyWS.Font = Enum.Font.Gotham

    local jpLabel = Instance.new("TextLabel", main)
    jpLabel.Text = "JumpPower:"
    jpLabel.Font = Enum.Font.Gotham
    jpLabel.TextColor3 = Color3.fromRGB(255,255,255)
    jpLabel.Position = UDim2.new(0,6,0,36)
    jpLabel.Size = UDim2.new(0,100,0,20)

    local jpBox = Instance.new("TextBox", main)
    jpBox.Text = tostring(player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").JumpPower or 50)
    jpBox.Position = UDim2.new(0,110,0,36)
    jpBox.Size = UDim2.new(0,80,0,20)
    jpBox.ClearTextOnFocus = false

    local applyJP = Instance.new("TextButton", main)
    applyJP.Text = "適用"
    applyJP.Position = UDim2.new(0,200,0,36)
    applyJP.Size = UDim2.new(0,70,0,20)
    applyJP.BackgroundColor3 = Color3.fromRGB(60,60,60)
    applyJP.TextColor3 = Color3.fromRGB(255,255,255)
    applyJP.Font = Enum.Font.Gotham

    -- Float（重力調整的な）
    local floatLabel = Instance.new("TextLabel", main)
    floatLabel.Text = "Float (gravity scale):"
    floatLabel.Font = Enum.Font.Gotham
    floatLabel.TextColor3 = Color3.fromRGB(255,255,255)
    floatLabel.Position = UDim2.new(0,6,0,66)
    floatLabel.Size = UDim2.new(0,150,0,20)

    local floatBox = Instance.new("TextBox", main)
    floatBox.Text = "1" -- 1 = normal
    floatBox.Position = UDim2.new(0,160,0,66)
    floatBox.Size = UDim2.new(0,60,0,20)
    floatBox.ClearTextOnFocus = false

    local applyFloat = Instance.new("TextButton", main)
    applyFloat.Text = "適用"
    applyFloat.Position = UDim2.new(0,230,0,66)
    applyFloat.Size = UDim2.new(0,70,0,20)
    applyFloat.BackgroundColor3 = Color3.fromRGB(60,60,60)
    applyFloat.TextColor3 = Color3.fromRGB(255,255,255)
    applyFloat.Font = Enum.Font.Gotham

    -- Fly controls
    local flyLabel = Instance.new("TextLabel", main)
    flyLabel.Text = "Fly (モード):"
    flyLabel.Font = Enum.Font.Gotham
    flyLabel.TextColor3 = Color3.fromRGB(255,255,255)
    flyLabel.Position = UDim2.new(0,6,0,96)
    flyLabel.Size = UDim2.new(0,120,0,20)

    local flyModeDrop = Instance.new("TextButton", main)
    flyModeDrop.Text = "BodyVelocity ▾"
    flyModeDrop.Position = UDim2.new(0,120,0,96)
    flyModeDrop.Size = UDim2.new(0,150,0,20)
    flyModeDrop.BackgroundColor3 = Color3.fromRGB(45,45,45)
    flyModeDrop.TextColor3 = Color3.fromRGB(255,255,255)
    flyModeDrop.Font = Enum.Font.Gotham

    local flyModes = {"BodyVelocity","PlatformStand","BodyGyro+Velocity","VectorForce"}
    local flyMenu = Instance.new("Frame", main)
    flyMenu.Visible = false
    flyMenu.Size = UDim2.new(0,150,0,#flyModes*22)
    flyMenu.Position = UDim2.new(0,120,0,118)
    flyMenu.BackgroundColor3 = Color3.fromRGB(30,30,30)

    for i,m in ipairs(flyModes) do
        local b = Instance.new("TextButton", flyMenu)
        b.Size = UDim2.new(1,0,0,22)
        b.Position = UDim2.new(0,0,0,(i-1)*22)
        b.Text = m
        b.BackgroundTransparency = 1
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.Gotham
        b.MouseButton1Click:Connect(function()
            flyModeDrop.Text = m.." ▾"
            flyMenu.Visible = false
            currentFlyMode = m
        end)
    end
    flyModeDrop.MouseButton1Click:Connect(function() flyMenu.Visible = not flyMenu.Visible end)

    local flySpeedLabel = Instance.new("TextLabel", main)
    flySpeedLabel.Text = "Fly speed:"
    flySpeedLabel.Position = UDim2.new(0,6,0,150)
    flySpeedLabel.Size = UDim2.new(0,90,0,18)
    flySpeedLabel.BackgroundTransparency = 1
    flySpeedLabel.Font = Enum.Font.Gotham
    flySpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)

    local flySpeedBox = Instance.new("TextBox", main)
    flySpeedBox.Text = "50"
    flySpeedBox.Position = UDim2.new(0,100,0,150)
    flySpeedBox.Size = UDim2.new(0,70,0,18)
    flySpeedBox.ClearTextOnFocus = false

    local flyToggle = Instance.new("TextButton", main)
    flyToggle.Text = "Fly OFF"
    flyToggle.Position = UDim2.new(0,180,0,150)
    flyToggle.Size = UDim2.new(0,80,0,18)
    flyToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    flyToggle.Font = Enum.Font.Gotham
    flyToggle.TextColor3 = Color3.fromRGB(255,255,255)

    -- ====== Crosshair 表示部 ======
    local crossGui = Instance.new("ScreenGui", player.PlayerGui)
    crossGui.Name = "CrosshairGui"
    crossGui.ResetOnSpawn = false

    local crossContainer = Instance.new("Frame", crossGui)
    crossContainer.AnchorPoint = Vector2.new(0.5,0.5)
    crossContainer.Position = UDim2.new(0.5,0,0.5,0)
    crossContainer.Size = UDim2.new(0,0,0,0)
    crossContainer.BackgroundTransparency = 1
    crossContainer.ZIndex = GUI_ZINDEX+1

    local crossElements = {} -- 表示用のパーツたち

    local function clearCross()
        for _,v in pairs(crossElements) do
            if v and v.Parent then v:Destroy() end
        end
        crossElements = {}
    end

    local function applyCrosshairShape(shape)
        clearCross()
        local size = tonumber(chSizeSlider.Text) or 20
        local color = Color3.fromRGB(255,255,255)
        -- 初期色は白にしておく（applyCrosshairColorで変更可能）
        if shape == "十字" then
            local h = Instance.new("Frame", crossContainer)
            h.Size = UDim2.new(0,2,0,size*2)
            h.AnchorPoint = Vector2.new(0.5,0.5)
            h.Position = UDim2.new(0.5,0.5)
            h.BackgroundColor3 = color
            h.BorderSizePixel = 0
            table.insert(crossElements,h)
            local v = Instance.new("Frame", crossContainer)
            v.Size = UDim2.new(0,size*2,0,2)
            v.AnchorPoint = Vector2.new(0.5,0.5)
            v.Position = UDim2.new(0.5,0.5)
            v.BackgroundColor3 = color
            v.BorderSizePixel = 0
            table.insert(crossElements,v)
        elseif shape == "点" then
            local d = Instance.new("Frame", crossContainer)
            d.Size = UDim2.new(0,size/3,0,size/3)
            d.AnchorPoint = Vector2.new(0.5,0.5)
            d.Position = UDim2.new(0.5,0.5)
            d.BackgroundColor3 = color
            d.BorderSizePixel = 0
            d.ZIndex = GUI_ZINDEX+2
            table.insert(crossElements,d)
        elseif shape == "輪っか" then
            local ring = Instance.new("ImageLabel", crossContainer)
            ring.Size = UDim2.new(0,size*2,0,size*2)
            ring.AnchorPoint = Vector2.new(0.5,0.5)
            ring.Position = UDim2.new(0.5,0.5)
            ring.Image = "rbxassetid://3926305904" -- Roblox 丸枠風（built-in）
            ring.ImageColor3 = color
            ring.BackgroundTransparency = 1
            table.insert(crossElements,ring)
        elseif shape == "矢印" then
            local up = Instance.new("Frame", crossContainer)
            up.Size = UDim2.new(0,2,0,size)
            up.AnchorPoint = Vector2.new(0.5,0.5)
            up.Position = UDim2.new(0.5,0.5,0.5,-size)
            up.BackgroundColor3 = color
            up.BorderSizePixel = 0
            table.insert(crossElements,up)
            -- 簡易的な矢印頭は省略（必要なら追加）
        else
            -- カスタム: 十字にしておく
            applyCrosshairShape("十字")
        end
    end

    local function applyCrosshairColor(color)
        for _,v in pairs(crossElements) do
            if v:IsA("ImageLabel") then
                v.ImageColor3 = color
            else
                v.BackgroundColor3 = color
            end
        end
    end

    local function applyShape(shape, rootFrame)
        -- UI の見た目変更。簡易的に角丸・背景・回転などを変える
        if not rootFrame then return end
        if shape == "四角" then
            rootFrame.BackgroundTransparency = 0
            TweenService:Create(rootFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,420,0,520)}):Play()
            rootFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
            -- 角丸を取る
            for _,c in pairs(rootFrame:GetChildren()) do
                if c:IsA("UICorner") then c:Destroy() end
            end
        elseif shape == "丸っぽい" then
            for _,c in pairs(rootFrame:GetChildren()) do if c:IsA("UICorner") then c:Destroy() end end
            local corner = Instance.new("UICorner", rootFrame)
            corner.CornerRadius = UDim.new(0,24)
            rootFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
        elseif shape == "通常(角丸)" then
            for _,c in pairs(rootFrame:GetChildren()) do if c:IsA("UICorner") then c:Destroy() end end
            local corner = Instance.new("UICorner", rootFrame)
            corner.CornerRadius = UDim.new(0,8)
            rootFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
        elseif shape == "卍型" then
            -- 単純な回転装飾を追加（実際のシンボル描画は避け、回転した装飾で代用）
            for _,c in pairs(rootFrame:GetChildren()) do if c:IsA("UICorner") then c:Destroy() end end
            local corner = Instance.new("UICorner", rootFrame)
            corner.CornerRadius = UDim.new(0,4)
            -- 目立つ色を一時的に適用
            rootFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
            -- 上にアクセントを足す
            local deco = Instance.new("Frame", rootFrame)
            deco.Name = "ManjiDeco"
            deco.Size = UDim2.new(0,80,0,80)
            deco.Position = UDim2.new(0.5,-40,0,50)
            deco.BackgroundColor3 = Color3.fromRGB(200,160,30)
            deco.Rotation = 45
            deco.BorderSizePixel = 0
            -- 一応後で削除できるように
            task.delay(8, function() if deco and deco.Parent then deco:Destroy() end end)
        else
            -- その他: ちょっと細工
            for _,c in pairs(rootFrame:GetChildren()) do if c:IsA("UICorner") then c:Destroy() end end
            rootFrame.BackgroundColor3 = Color3.fromRGB(28,28,34)
        end
    end

    local function applyColor(color, rootFrame)
        if rootFrame and rootFrame:IsA("Instance") then
            rootFrame.BackgroundColor3 = color
        end
    end

    -- ====== Fly 実装 ======
    local flying = false
    local currentFlyMode = "BodyVelocity"
    local flyObj = nil
    local flyConnection = nil
    local flyMove = {Forward=0,Right=0,Up=0}
    local function stopFly()
        flying = false
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if flyObj and flyObj.Parent then flyObj:Destroy(); flyObj = nil end
        -- restore PlatformStand if used
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end

    local function startFly()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChildOfClass("Humanoid")

        local speed = tonumber(flySpeedBox.Text) or 50
        currentFlyMode = currentFlyMode or "BodyVelocity"

        if currentFlyMode == "BodyVelocity" then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.P = 1250
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = hrp
            flyObj = bv

            flyConnection = RunService.RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                local dir = Vector3.new(0,0,0)
                local look = workspace.CurrentCamera.CFrame
                local forward = look.LookVector
                local right = look.RightVector
                dir = forward*flyMove.Forward + right*flyMove.Right + Vector3.new(0,flyMove.Up,0)
                bv.Velocity = dir.Unit * (speed) -- if dir==0, Unit will error; guard:
                if dir.Magnitude == 0 then
                    bv.Velocity = Vector3.new(0,0,0)
                end
            end)
            flying = true

        elseif currentFlyMode == "PlatformStand" then
            if hum then hum.PlatformStand = true end
            flyConnection = RunService.RenderStepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local move = Vector3.new(flyMove.Right, flyMove.Up, flyMove.Forward)
                    hrp.CFrame = hrp.CFrame + (workspace.CurrentCamera.CFrame:VectorToWorldSpace(Vector3.new(flyMove.Right,0,flyMove.Forward)) * (tonumber(flySpeedBox.Text) or 50) * RunService.RenderStepped:Wait())
                end
            end)
            flying = true

        elseif currentFlyMode == "BodyGyro+Velocity" then
            local bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.CFrame = hrp.CFrame
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.P = 1250
            flyObj = {bg=bg, bv=bv}
            flyConnection = RunService.RenderStepped:Connect(function(dt)
                local cam = workspace.CurrentCamera
                local forward = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local dir = forward*flyMove.Forward + right*flyMove.Right + Vector3.new(0,flyMove.Up,0)
                if dir.Magnitude > 0 then
                    flyObj.bv.Velocity = dir.Unit * (tonumber(flySpeedBox.Text) or 50)
                    flyObj.bg.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
                else
                    flyObj.bv.Velocity = Vector3.new(0,0,0)
                end
            end)
            flying = true

        elseif currentFlyMode == "VectorForce" then
            -- Requires Attachment
            local attachment = Instance.new("Attachment", hrp)
            local vf = Instance.new("VectorForce", hrp)
            vf.Attachment0 = attachment
            vf.Force = Vector3.new(0,0,0)
            vf.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            vf.Attachment0 = attachment
            flyObj = {vf=vf, att=attachment}
            flyConnection = RunService.RenderStepped:Connect(function(dt)
                local cam = workspace.CurrentCamera
                local forward = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local dir = forward*flyMove.Forward + right*flyMove.Right + Vector3.new(0,flyMove.Up,0)
                flyObj.vf.Force = dir * (tonumber(flySpeedBox.Text) or 50) * hrp:GetMass()
            end)
            flying = true
        end
    end

    -- WASD/space control for fly
    local keysDown = {}
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keysDown[input.KeyCode.Value] = true
            -- map keys
            if keysDown[Enum.KeyCode.W.Value] then flyMove.Forward = 1 end
            if keysDown[Enum.KeyCode.S.Value] then flyMove.Forward = -1 end
            if keysDown[Enum.KeyCode.A.Value] then flyMove.Right = -1 end
            if keysDown[Enum.KeyCode.D.Value] then flyMove.Right = 1 end
            if keysDown[Enum.KeyCode.Space.Value] then flyMove.Up = 1 end
            if keysDown[Enum.KeyCode.LeftControl.Value] or keysDown[Enum.KeyCode.LeftShift.Value] then flyMove.Up = -1 end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            keysDown[input.KeyCode.Value] = nil
            -- recompute
            flyMove.Forward = 0; flyMove.Right = 0; flyMove.Up = 0
            if keysDown[Enum.KeyCode.W.Value] then flyMove.Forward = 1 end
            if keysDown[Enum.KeyCode.S.Value] then flyMove.Forward = -1 end
            if keysDown[Enum.KeyCode.A.Value] then flyMove.Right = -1 end
            if keysDown[Enum.KeyCode.D.Value] then flyMove.Right = 1 end
            if keysDown[Enum.KeyCode.Space.Value] then flyMove.Up = 1 end
            if keysDown[Enum.KeyCode.LeftControl.Value] or keysDown[Enum.KeyCode.LeftShift.Value] then flyMove.Up = -1 end
        end
    end)

    -- apply buttons functionality
    applyWS.MouseButton1Click:Connect(function()
        local v = tonumber(wsBox.Text)
        if v and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end)

    applyJP.MouseButton1Click:Connect(function()
        local v = tonumber(jpBox.Text)
        if v and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").JumpPower = v
        end
    end)

    applyFloat.MouseButton1Click:Connect(function()
        local scale = tonumber(floatBox.Text) or 1
        -- 重力を直接弄るのはサーバーのWorkspace.Gravityに影響するため推奨されない
        -- ここではローカルで浮遊効果: HumanoidRootPart に BodyForce をつけて重力を相殺する実装
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            -- remove existing
            for _,c in pairs(hrp:GetChildren()) do
                if c.Name == "LocalFloatForce" then c:Destroy() end
            end
            if math.abs(scale - 1) < 0.01 then return end
            local bf = Instance.new("BodyForce", hrp)
            bf.Name = "LocalFloatForce"
            local mass = hrp:GetMass()
            local g = workspace.Gravity
            bf.Force = Vector3.new(0, mass * g * (1 - scale), 0) -- scale<1 => 上昇補助
        end
    end)

    flyToggle.MouseButton1Click:Connect(function()
        if not flying then
            startFly()
            flyToggle.Text = "Fly ON"
        else
            stopFly()
            flyToggle.Text = "Fly OFF"
        end
    end)

    -- apply crosshair apply btn
    applyChBtn.MouseButton1Click:Connect(function()
        local shape = chShapeDrop.Text:gsub(" ▾","")
        local size = tonumber(chSizeSlider.Text) or 20
        applyCrosshairShape(shape)
        -- 色は既存設定を維持
        applyCrosshairColor(Color3.fromRGB(255,255,255))
    end)

    -- applyColor / applyShape are already used above

    -- Menu switching
    for name,btn in pairs(menuButtons) do
        btn.MouseButton1Click:Connect(function()
            for _,f in pairs(contents) do f.Visible = false end
            contents[name].Visible = true
        end)
    end

    -- 初期 crosshair
    applyCrosshairShape("十字")
    applyCrosshairColor(Color3.fromRGB(255,255,255))

    -- Clean up if player dies/respawns (rebind)
    player.CharacterAdded:Connect(function(char)
        task.delay(1, function()
            -- 保持したい設定は残す（例: WalkSpeed/JumpPowerは手動で再適用するか自動）
            -- ここでは自動でWalkSpeed/JumpPowerを再適用
            local hum = char:WaitForChild("Humanoid")
            local ws = tonumber(wsBox.Text)
            local jp = tonumber(jpBox.Text)
            if ws then hum.WalkSpeed = ws end
            if jp then hum.JumpPower = jp end
        end)
    end)

    -- UI 初期色/形状
    applyShape("通常(角丸)", rf)
    applyColor(Color3.fromRGB(24,24,24), rf)
    -- 終わり: Rayfield風UI をロード完了
end

-- PIN submit
submitBtn.MouseButton1Click:Connect(function()
    local val = pinBox.Text or ""
    if val == CORRECT_PIN then
        -- 正解
        loadRayfield()
    else
        -- 誤り: UI を消して終了
        destroyAll()
        -- 終了
        return
    end
end)

cancelBtn.MouseButton1Click:Connect(function()
    destroyAll()
end)

pinMinBtn.MouseButton1Click:Connect(function()
    if pinGui.Size.Y.Offset > 40 then
        pinGui.Size = UDim2.new(0,200,0,36)
        for _,obj in pairs(pinGui:GetChildren()) do
            if obj ~= pinTitle and obj ~= pinMinBtn then obj.Visible = false end
        end
    else
        pinGui.Size = UDim2.new(0,350,0,180)
        for _,obj in pairs(pinGui:GetChildren()) do obj.Visible = true end
    end
end)

-- Enterキーでも送信
pinBox.FocusLost:Connect(function(enter)
    if enter then submitBtn:MouseButton1Click() end
end)

-- スクリプトの最後に (安全用)
-- もしプレイヤーがGUI無しでスクリプトを止めたい場合は、GUIを破棄してください。
-- 例: gui:Destroy()

