-- サービスとライブラリの取得
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ローカルプレイヤー
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Rayfield UI ライブラリ風の実装
local Rayfield = {}

-- 暗証番号UI
local PasswordUI = Instance.new("ScreenGui")
PasswordUI.Name = "PasswordUI"
PasswordUI.ResetOnSpawn = false
PasswordUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = PasswordUI

-- 角丸にする
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "認証が必要です"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Gotham
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- 最小化ボタン
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.Parent = TitleBar

-- 閉じるボタン
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

-- コンテンツエリア
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- パスワード入力
local PasswordLabel = Instance.new("TextLabel")
PasswordLabel.Name = "PasswordLabel"
PasswordLabel.Size = UDim2.new(1, 0, 0, 30)
PasswordLabel.BackgroundTransparency = 1
PasswordLabel.Text = "暗証番号を入力してください:"
PasswordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PasswordLabel.Font = Enum.Font.Gotham
PasswordLabel.TextSize = 14
PasswordLabel.TextXAlignment = Enum.TextXAlignment.Left
PasswordLabel.Parent = Content

local PasswordBox = Instance.new("TextBox")
PasswordBox.Name = "PasswordBox"
PasswordBox.Size = UDim2.new(1, 0, 0, 40)
PasswordBox.Position = UDim2.new(0, 0, 0, 30)
PasswordBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PasswordBox.BorderSizePixel = 0
PasswordBox.Text = ""
PasswordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PasswordBox.Font = Enum.Font.Gotham
PasswordBox.TextSize = 16
PasswordBox.PlaceholderText = "パスワードを入力..."
PasswordBox.Parent = Content

local PasswordCorner = Instance.new("UICorner")
PasswordCorner.CornerRadius = UDim.new(0, 4)
PasswordCorner.Parent = PasswordBox

local SubmitButton = Instance.new("TextButton")
SubmitButton.Name = "SubmitButton"
SubmitButton.Size = UDim2.new(1, 0, 0, 40)
SubmitButton.Position = UDim2.new(0, 0, 0, 80)
SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SubmitButton.BorderSizePixel = 0
SubmitButton.Text = "認証"
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.TextSize = 16
SubmitButton.Parent = Content

local SubmitCorner = Instance.new("UICorner")
SubmitCorner.CornerRadius = UDim.new(0, 4)
SubmitCorner.Parent = SubmitButton

-- 状態表示
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 130)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = Content

-- 最小化状態を追跡
local isMinimized = false
local originalSize = MainFrame.Size
local minimizedSize = UDim2.new(0, 350, 0, 30)

-- 最小化機能
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Content.Visible = false
        MainFrame.Size = minimizedSize
        MinimizeButton.Text = "+"
    else
        Content.Visible = true
        MainFrame.Size = originalSize
        MinimizeButton.Text = "_"
    end
end)

-- 閉じるボタンの機能
CloseButton.MouseButton1Click:Connect(function()
    PasswordUI:Destroy()
end)

-- パスワード確認
SubmitButton.MouseButton1Click:Connect(function()
    local password = PasswordBox.Text
    local correctPassword = "しゅーくりむ"
    
    if password == correctPassword then
        StatusLabel.Text = "認証成功！"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Rayfield UIを読み込む
        wait(1)
        PasswordUI:Destroy()
        Rayfield:Init()
    else
        StatusLabel.Text = "パスワードが間違っています"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        -- 3秒後にUIを削除
        wait(3)
        PasswordUI:Destroy()
    end
end)

-- Rayfield UI 機能
Rayfield.Window = nil
Rayfield.CurrentTab = nil
Rayfield.Elements = {}
Rayfield.Settings = {
    UI = {
        Shape = "Square",
        Color = "Blue"
    },
    Crosshair = {
        Enabled = false,
        Shape = "Dot",
        Color = Color3.fromRGB(255, 255, 255),
        Size = 10,
        Thickness = 1
    },
    ShiftLock = {
        Enabled = false
    }
}

-- 色の定義
Rayfield.Colors = {
    "Blue", "Red", "Green", "Yellow", "Purple", "Pink",
    "Orange", "Cyan", "White", "Black", "Gray", "Brown"
}

-- UI形状の定義
Rayfield.Shapes = {
    "Square", "Round", "Swastika", "Circle", "Triangle", "Diamond"
}

-- クロスヘア形状の定義
Rayfield.CrosshairShapes = {
    "Dot", "Cross", "Circle", "Square", "Triangle", "Swastika"
}

function Rayfield:CreateWindow(name)
    local RayfieldUI = Instance.new("ScreenGui")
    RayfieldUI.Name = "RayfieldUI"
    RayfieldUI.ResetOnSpawn = false
    RayfieldUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, 600, 0, 400)
    MainWindow.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Draggable = true
    MainWindow.Parent = RayfieldUI
    
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 8)
    WindowCorner.Parent = MainWindow
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    
    -- タブボタンエリア
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainWindow
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer
    
    -- コンテンツエリア
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -160, 1, -40)
    ContentContainer.Position = UDim2.new(0, 160, 0, 30)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainWindow
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer
    
    -- 削除確認ダイアログ
    local DeleteDialog = Instance.new("Frame")
    DeleteDialog.Name = "DeleteDialog"
    DeleteDialog.Size = UDim2.new(0, 300, 0, 150)
    DeleteDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    DeleteDialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DeleteDialog.BorderSizePixel = 0
    DeleteDialog.Visible = false
    DeleteDialog.Parent = RayfieldUI
    
    local DeleteCorner = Instance.new("UICorner")
    DeleteCorner.CornerRadius = UDim.new(0, 8)
    DeleteCorner.Parent = DeleteDialog
    
    local DeleteLabel = Instance.new("TextLabel")
    DeleteLabel.Name = "DeleteLabel"
    DeleteLabel.Size = UDim2.new(1, -20, 0, 60)
    DeleteLabel.Position = UDim2.new(0, 10, 0, 10)
    DeleteLabel.BackgroundTransparency = 1
    DeleteLabel.Text = "本当にUIを削除しますか？"
    DeleteLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeleteLabel.Font = Enum.Font.Gotham
    DeleteLabel.TextSize = 16
    DeleteLabel.TextWrapped = true
    DeleteLabel.Parent = DeleteDialog
    
    local YesButton = Instance.new("TextButton")
    YesButton.Name = "YesButton"
    YesButton.Size = UDim2.new(0, 120, 0, 40)
    YesButton.Position = UDim2.new(0, 20, 1, -60)
    YesButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    YesButton.BorderSizePixel = 0
    YesButton.Text = "はい"
    YesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesButton.Font = Enum.Font.GothamBold
    YesButton.TextSize = 16
    YesButton.Parent = DeleteDialog
    
    local YesCorner = Instance.new("UICorner")
    YesCorner.CornerRadius = UDim.new(0, 4)
    YesCorner.Parent = YesButton
    
    local NoButton = Instance.new("TextButton")
    NoButton.Name = "NoButton"
    NoButton.Size = UDim2.new(0, 120, 0, 40)
    NoButton.Position = UDim2.new(1, -140, 1, -60)
    NoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    NoButton.BorderSizePixel = 0
    NoButton.Text = "いいえ"
    NoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoButton.Font = Enum.Font.GothamBold
    NoButton.TextSize = 16
    NoButton.Parent = DeleteDialog
    
    local NoCorner = Instance.new("UICorner")
    NoCorner.CornerRadius = UDim.new(0, 4)
    NoCorner.Parent = NoButton
    
    -- クロスヘア表示用
    local CrosshairFrame = Instance.new("Frame")
    CrosshairFrame.Name = "CrosshairFrame"
    CrosshairFrame.Size = UDim2.new(0, 100, 0, 100)
    CrosshairFrame.Position = UDim2.new(0.5, -50, 0.5, -50)
    CrosshairFrame.BackgroundTransparency = 1
    CrosshairFrame.Visible = false
    CrosshairFrame.Parent = RayfieldUI
    
    local Crosshair = Instance.new("Frame")
    Crosshair.Name = "Crosshair"
    Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
    Crosshair.Size = UDim2.new(0, 10, 0, 10)
    Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
    Crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Crosshair.BorderSizePixel = 0
    Crosshair.Parent = CrosshairFrame
    
    -- 閉じるボタンの機能
    CloseButton.MouseButton1Click:Connect(function()
        DeleteDialog.Visible = true
    end)
    
    YesButton.MouseButton1Click:Connect(function()
        RayfieldUI:Destroy()
    end)
    
    NoButton.MouseButton1Click:Connect(function()
        DeleteDialog.Visible = false
    end)
    
    -- クロスヘア更新関数
    local function UpdateCrosshair()
        CrosshairFrame.Visible = Rayfield.Settings.Crosshair.Enabled
        
        if Rayfield.Settings.Crosshair.Enabled then
            local shape = Rayfield.Settings.Crosshair.Shape
            local color = Rayfield.Settings.Crosshair.Color
            local size = Rayfield.Settings.Crosshair.Size
            local thickness = Rayfield.Settings.Crosshair.Thickness
            
            Crosshair.BackgroundColor3 = color
            
            if shape == "Dot" then
                Crosshair.Size = UDim2.new(0, size, 0, size)
                Crosshair.BackgroundTransparency = 0
            elseif shape == "Cross" then
                Crosshair.Size = UDim2.new(0, thickness, 0, size)
                Crosshair.BackgroundTransparency = 0
            end
        end
    end
    
    -- シフトロック機能
    local function UpdateShiftLock()
        if Rayfield.Settings.ShiftLock.Enabled then
            -- シフトロックの実装
            -- 注意: 実際の実装はRobloxの制限により制限される場合があります
        end
    end
    
    self.Window = {
        GUI = RayfieldUI,
        MainWindow = MainWindow,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        DeleteDialog = DeleteDialog,
        CrosshairFrame = CrosshairFrame,
        Crosshair = Crosshair
    }
    
    RayfieldUI.Parent = player:WaitForChild("PlayerGui")
    
    return self.Window
end

function Rayfield:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.Position = UDim2.new(0, 5, 0, #self.Window.TabContainer:GetChildren() * 45)
    TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = self.Window.TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.Visible = false
    TabContent.Parent = self.Window.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        -- すべてのタブコンテンツを非表示
        for _, child in pairs(self.Window.ContentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        
        -- すべてのタブボタンの色をリセット
        for _, child in pairs(self.Window.TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                child.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        
        -- 選択したタブを表示
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        self.CurrentTab = TabContent
    end)
    
    return TabContent
end

function Rayfield:CreateSection(tab, name)
    local Section = Instance.new("Frame")
    Section.Name = name .. "Section"
    Section.Size = UDim2.new(1, -20, 0, 40)
    Section.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 50)
    Section.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Section.BorderSizePixel = 0
    Section.Parent = tab
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 4)
    SectionCorner.Parent = Section
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "Label"
    SectionLabel.Size = UDim2.new(1, -20, 1, 0)
    SectionLabel.Position = UDim2.new(0, 10, 0, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = name
    SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = Section
    
    return Section
end

function Rayfield:CreateButton(tab, name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Button"
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 50)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = tab
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function Rayfield:CreateSlider(tab, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "Slider"
    SliderFrame.Size = UDim2.new(1, -20, 0, 60)
    SliderFrame.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 70)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = tab
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, 0, 0, 10)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 5)
    TrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "Button"
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = SliderButton
    
    local value = default
    local dragging = false
    
    local function updateValue(newValue)
        value = math.clamp(newValue, min, max)
        SliderLabel.Text = name .. ": " .. math.floor(value * 100) / 100
        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        SliderButton.Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)
        callback(value)
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local trackPos = SliderTrack.AbsolutePosition.X
            local trackSize = SliderTrack.AbsoluteSize.X
            
            local relativePos = math.clamp(mousePos.X - trackPos, 0, trackSize)
            local newValue = min + (relativePos / trackSize) * (max - min)
            
            updateValue(newValue)
        end
    end)
    
    return {Update = updateValue, Value = value}
end

function Rayfield:CreateDropdown(tab, name, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = name .. "Dropdown"
    DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    DropdownFrame.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 50)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = tab
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 4)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "Button"
    DropdownButton.Size = UDim2.new(1, 0, 0, 40)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = name .. ": " .. default
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 14
    DropdownButton.Parent = DropdownFrame
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Name = "List"
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 40)
    DropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = DropdownList
    
    local isOpen = false
    local selected = default
    
    local function updateList()
        DropdownList:ClearAllChildren()
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = option
            OptionButton.Size = UDim2.new(1, 0, 0, 30)
            OptionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            OptionButton.BorderSizePixel = 0
            OptionButton.Text = option
            OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.TextSize = 12
            OptionButton.Parent = DropdownList
            
            OptionButton.MouseButton1Click:Connect(function()
                selected = option
                DropdownButton.Text = name .. ": " .. selected
                callback(selected)
                isOpen = false
                DropdownList.Visible = false
                DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
            end)
        end
        
        local itemCount = #options
        DropdownList.Size = UDim2.new(1, 0, 0, itemCount * 30)
    end
    
    updateList()
    
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownList.Visible = isOpen
        
        if isOpen then
            DropdownFrame.Size = UDim2.new(1, -20, 0, 40 + (#options * 30))
        else
            DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
        end
    end)
    
    return {Update = updateList, Selected = selected}
end

function Rayfield:CreateToggle(tab, name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 50)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = tab
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 50, 0, 30)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -15)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 15)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Name = "Indicator"
    ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    ToggleIndicator.Position = default and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 5, 0.5, -10)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 10)
    IndicatorCorner.Parent = ToggleIndicator
    
    local isToggled = default
    
    ToggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        if isToggled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -25, 0.5, -10)
            }):Play()
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 5, 0.5, -10)
            }):Play()
        end
        
        callback(isToggled)
    end)
    
    return {Toggle = function() ToggleButton:Click() end, Value = isToggled}
end

function Rayfield:CreateColorPicker(tab, name, colors, default, callback)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Name = name .. "ColorPicker"
    ColorFrame.Size = UDim2.new(1, -20, 0, 40)
    ColorFrame.Position = UDim2.new(0, 10, 0, #tab:GetChildren() * 50)
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Parent = tab
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Name = "Label"
    ColorLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = name
    ColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 14
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorFrame
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = "Button"
    ColorButton.Size = UDim2.new(0, 30, 0, 30)
    ColorButton.Position = UDim2.new(1, -30, 0.5, -15)
    ColorButton.BackgroundColor3 = default
    ColorButton.BorderSizePixel = 0
    ColorButton.Text = ""
    ColorButton.Parent = ColorFrame
    
    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 4)
    ColorCorner.Parent = ColorButton
    
    local ColorGrid = Instance.new("Frame")
    ColorGrid.Name = "Grid"
    ColorGrid.Size = UDim2.new(0, 150, 0, 100)
    ColorGrid.Position = UDim2.new(1, -150, 1, 5)
    ColorGrid.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ColorGrid.BorderSizePixel = 0
    ColorGrid.Visible = false
    ColorGrid.Parent = ColorFrame
    
    local GridCorner = Instance.new("UICorner")
    GridCorner.CornerRadius = UDim.new(0, 4)
    GridCorner.Parent = ColorGrid
    
    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    GridLayout.CellSize = UDim2.new(0, 30, 0, 30)
    GridLayout.Parent = ColorGrid
    
    local isOpen = false
    local selected = default
    
    local function updateGrid()
        ColorGrid:ClearAllChildren()
        
        for i, color in ipairs(colors) do
            local ColorOption = Instance.new("TextButton")
            ColorOption.Name = "Color" .. i
            ColorOption.BackgroundColor3 = color
            ColorOption.BorderSizePixel = 0
            ColorOption.Text = ""
            ColorOption.Parent = ColorGrid
            
            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 4)
            OptionCorner.Parent = ColorOption
            
            ColorOption.MouseButton1Click:Connect(function()
                selected = color
                ColorButton.BackgroundColor3 = color
                callback(color)
                isOpen = false
                ColorGrid.Visible = false
            end)
        end
    end
    
    updateGrid()
    
    ColorButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ColorGrid.Visible = isOpen
    end)
    
    return {Update = updateGrid, Selected = selected}
end

function Rayfield:Init()
    -- Rayfield UIの作成
    local window = self:CreateWindow("Rayfield UI")
    
    -- メインタブの作成
    local MainTab = self:CreateTab("Main")
    local SettingsTab = self:CreateTab("Settings")
    
    -- メインタブのセクション
    local MovementSection = self:CreateSection(MainTab, "Movement")
    
    -- スピードチェンジ
    local speedSlider = self:CreateSlider(MainTab, "Walk Speed", 16, 100, 16, function(value)
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
    end)
    
    -- ジャンプ力
    local jumpSlider = self:CreateSlider(MainTab, "Jump Power", 50, 200, 50, function(value)
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = value
        end
    end)
    
    -- 浮遊力
    local floatToggle = self:CreateToggle(MainTab, "Float", false, function(value)
        if value then
            -- 浮遊機能の実装
            local floatConnection
            floatConnection = RunService.Heartbeat:Connect(function()
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.Velocity = Vector3.new(
                        character.HumanoidRootPart.Velocity.X,
                        0,
                        character.HumanoidRootPart.Velocity.Z
                    )
                end
            end)
            
            floatToggle.Disconnect = function()
                floatConnection:Disconnect()
            end
        else
            if floatToggle.Disconnect then
                floatToggle.Disconnect()
            end
        end
    end)
    
    -- Fly機能
    local flyToggle = self:CreateToggle(MainTab, "Fly", false, function(value)
        if value then
            -- Fly機能の実装
            local flySpeed = 50
            local flying = true
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            if not humanoid then return end
            
            -- 飛行状態の保存
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 1000
            bodyGyro.D = 100
            bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            bodyGyro.CFrame = humanoid.RootPart.CFrame
            bodyGyro.Parent = humanoid.RootPart
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Parent = humanoid.RootPart
            
            local function fly()
                while flying and humanoid and humanoid.Parent do
                    local direction = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + humanoid.RootPart.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - humanoid.RootPart.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - humanoid.RootPart.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + humanoid.RootPart.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        direction = direction - Vector3.new(0, 1, 0)
                    end
                    
                    if direction.Magnitude > 0 then
                        direction = direction.Unit * flySpeed
                    end
                    
                    bodyVelocity.Velocity = direction
                    bodyGyro.CFrame = CFrame.new(humanoid.RootPart.Position, humanoid.RootPart.Position + humanoid.RootPart.CFrame.LookVector)
                    
                    RunService.RenderStepped:Wait()
                end
            end
            
            task.spawn(fly)
            
            flyToggle.Disconnect = function()
                flying = false
                if bodyGyro then bodyGyro:Destroy() end
                if bodyVelocity then bodyVelocity:Destroy() end
            end
        else
            if flyToggle.Disconnect then
                flyToggle.Disconnect()
            end
        end
    end)
    
    -- 設定タブ
    local UISection = self:CreateSection(SettingsTab, "UI Settings")
    
    -- UI形状の選択
    local shapeDropdown = self:CreateDropdown(SettingsTab, "UI Shape", self.Shapes, "Square", function(selected)
        self.Settings.UI.Shape = selected
        -- ここでUI形状を変更する実装を追加
    end)
    
    -- UI色の選択
    local colorDropdown = self:CreateDropdown(SettingsTab, "UI Color", self.Colors, "Blue", function(selected)
        self.Settings.UI.Color = selected
        -- ここでUI色を変更する実装を追加
    end)
    
    -- クロスヘア設定セクション
    local CrosshairSection = self:CreateSection(SettingsTab, "Crosshair Settings")
    
    -- クロスヘアの有効/無効
    local crosshairToggle = self:CreateToggle(SettingsTab, "Enable Crosshair", false, function(value)
        self.Settings.Crosshair.Enabled = value
        UpdateCrosshair()
    end)
    
    -- クロスヘア形状
    local crosshairShape = self:CreateDropdown(SettingsTab, "Crosshair Shape", self.CrosshairShapes, "Dot", function(selected)
        self.Settings.Crosshair.Shape = selected
        UpdateCrosshair()
    end)
    
    -- クロスヘア色
    local crosshairColors = {
        Color3.fromRGB(255, 255, 255),  -- White
        Color3.fromRGB(255, 0, 0),      -- Red
        Color3.fromRGB(0, 255, 0),      -- Green
        Color3.fromRGB(0, 0, 255),      -- Blue
        Color3.fromRGB(255, 255, 0),    -- Yellow
        Color3.fromRGB(255, 0, 255),    -- Pink
        Color3.fromRGB(0, 255, 255),    -- Cyan
        Color3.fromRGB(255, 165, 0),    -- Orange
        Color3.fromRGB(128, 0, 128),    -- Purple
        Color3.fromRGB(0, 0, 0),        -- Black
        Color3.fromRGB(128, 128, 128),  -- Gray
        Color3.fromRGB(165, 42, 42)     -- Brown
    }
    
    local crosshairColor = self:CreateColorPicker(SettingsTab, "Crosshair Color", crosshairColors, Color3.fromRGB(255, 255, 255), function(color)
        self.Settings.Crosshair.Color = color
        UpdateCrosshair()
    end)
    
    -- クロスヘアサイズ
    local crosshairSize = self:CreateSlider(SettingsTab, "Crosshair Size", 5, 30, 10, function(value)
        self.Settings.Crosshair.Size = value
        UpdateCrosshair()
    end)
    
    -- クロスヘア太さ
    local crosshairThickness = self:CreateSlider(SettingsTab, "Crosshair Thickness", 1, 10, 1, function(value)
        self.Settings.Crosshair.Thickness = value
        UpdateCrosshair()
    end)
    
    -- シフトロック設定
    local ShiftLockSection = self:CreateSection(SettingsTab, "Shift Lock")
    
    local shiftLockToggle = self:CreateToggle(SettingsTab, "Enable Shift Lock", false, function(value)
        self.Settings.ShiftLock.Enabled = value
        UpdateShiftLock()
    end)
    
    -- 最初のタブを選択
    for _, child in pairs(window.TabContainer:GetChildren()) do
        if child:IsA("TextButton") and child.Name == "MainTab" then
            child:Click()
            break
        end
    end
    
    print("Rayfield UI loaded successfully!")
end

-- 暗証番号UIを起動
PasswordUI.Parent = player:WaitForChild("PlayerGui")
