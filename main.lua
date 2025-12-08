local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UIを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PasswordUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- 背景白
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)

-- 昔の感じを出すために、シンプルなデザインにする
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.Text = "パスワードを入力してください"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 200, 0, 40)
textBox.Position = UDim2.new(0.5, -100, 0.5, -20)
textBox.PlaceholderText = "パスワード"
textBox.Text = ""
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
textBox.BorderSizePixel = 1
textBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
textBox.Font = Enum.Font.SourceSans
textBox.TextSize = 18
textBox.Parent = frame

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0, 100, 0, 40)
submitButton.Position = UDim2.new(0.5, -50, 0.7, 0)
submitButton.Text = "送信"
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
submitButton.BorderSizePixel = 0
submitButton.Font = Enum.Font.SourceSansBold
submitButton.TextSize = 18
submitButton.Parent = frame

frame.Parent = screenGui
screenGui.Parent = playerGui

-- リモートイベントを取得
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("PasswordRemoteEvent")

local attemptCount = 0  -- 試行回数

local function fadeOutUI()
    local fadeTime = 1  -- 1秒かけてフェードアウト
    local steps = 20  -- 20ステップで消す
    local stepTime = fadeTime / steps

    for i = 1, steps do
        frame.BackgroundTransparency = i / steps
        title.TextTransparency = i / steps
        textBox.TextTransparency = i / steps
        textBox.BackgroundTransparency = i / steps
        submitButton.TextTransparency = i / steps
        submitButton.BackgroundTransparency = i / steps
        wait(stepTime)
    end
    screenGui:Destroy()  -- 完全に消す
end

submitButton.MouseButton1Click:Connect(function()
    local inputPassword = textBox.Text
    attemptCount = attemptCount + 1

    -- サーバーにパスワードを送信
    remoteEvent:FireServer(inputPassword, attemptCount)
end)

-- サーバーからの結果を受け取る
remoteEvent.OnClientEvent:Connect(function(success)
    if success then
        -- パスワードが正しい場合、フェードアウト
        fadeOutUI()
    else
        if attemptCount >= 3 then
            -- 3回間違えた場合、サーバー側で退出させるので、ここでは何もしない
            -- 必要に応じてメッセージを表示
            textBox.Text = "パスワードが3回間違えられました。退出します。"
        else
            textBox.Text = ""
            textBox.PlaceholderText = string.format("パスワードが違います。残り%d回", 3 - attemptCount)
        end
    end
end)
