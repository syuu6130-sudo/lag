-- サービスの取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- プレイヤー
local player = Players.LocalPlayer

-- UI設定
local SECURITY_PASSWORD = "しゅーくりーむ"
local UIColors = {
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

-- UIの作成
local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ArseusNeoUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- メインウィンドウ
    local mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 600, 0, 400)
    mainWindow.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainWindow.BorderSizePixel = 0
    mainWindow.Parent = screenGui

    -- 丸みを帯びたコーナー
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainWindow

    -- タイトル
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "Arseus x Neo UI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainWindow

    -- 認証ボタン
    local authButton = Instance.new("TextButton")
    authButton.Size = UDim2.new(0, 200, 0, 50)
    authButton.Position = UDim2.new(0.5, -100, 0.5, -25)
    authButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    authButton.Text = "認証"
    authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    authButton.TextSize = 20
    authButton.Font = Enum.Font.GothamBold
    authButton.Parent = mainWindow

    -- 認証画面
    local function CreateAuthWindow()
        local authWindow = Instance.new("Frame")
        authWindow.Size = UDim2.new(0, 400, 0, 300)
        authWindow.Position = UDim2.new(0.5, -200, 0.5, -150)
        authWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        authWindow.BorderSizePixel = 0
        authWindow.Parent = screenGui

        local authCorner = Instance.new("UICorner")
        authCorner.CornerRadius = UDim.new(0, 15)
        authCorner.Parent = authWindow

        -- タイトル
        local authTitle = Instance.new("TextLabel")
        authTitle.Size = UDim2.new(1, 0, 0, 40)
        authTitle.BackgroundTransparency = 1
        authTitle.Text = "🔒 セキュリティ認証"
        authTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        authTitle.TextSize = 24
        authTitle.Font = Enum.Font.GothamBold
        authTitle.Parent = authWindow

        -- パスワード入力欄
        local passwordBox = Instance.new("TextBox")
        passwordBox.Size = UDim2.new(0, 300, 0, 50)
        passwordBox.Position = UDim2.new(0.5, -150, 0.5, -20)
        passwordBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        passwordBox.PlaceholderText = "暗証番号を入力..."
        passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        passwordBox.TextSize = 20
        passwordBox.Font = Enum.Font.Gotham
        passwordBox.Parent = authWindow

        -- 送信ボタン
        local submitBtn = Instance.new("TextButton")
        submitBtn.Size = UDim2.new(0, 100, 0, 40)
        submitBtn.Position = UDim2.new(0.5, -50, 0.5, 40)
        submitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        submitBtn.Text = "送信"
        submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        submitBtn.TextSize = 20
        submitBtn.Font = Enum.Font.GothamBold
        submitBtn.Parent = authWindow

        -- メッセージ表示
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -20, 0, 40)
        messageLabel.Position = UDim2.new(0, 10, 0, 100)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = ""
        messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        messageLabel.TextSize = 18
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.Parent = authWindow

        -- 送信ボタン機能
        submitBtn.MouseButton1Click:Connect(function()
            if passwordBox.Text == SECURITY_PASSWORD then
                messageLabel.Text = "✅ 認証成功！"
                wait(1)
                authWindow:Destroy()
                CreateMainUI()
            else
                messageLabel.Text = "❌ 認証失敗！"
            end
        end)
    end

    -- メインUIの作成
    local function CreateMainUI()
        local mainUI = Instance.new("Frame")
        mainUI.Size = UDim2.new(0, 600, 0, 400)
        mainUI.Position = UDim2.new(0.5, -300, 0.5, -200)
        mainUI.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        mainUI.BorderSizePixel = 0
        mainUI.Parent = screenGui

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 15)
        mainCorner.Parent = mainUI

        -- タイトル
        local mainTitle = Instance.new("TextLabel")
        mainTitle.Size = UDim2.new(1, 0, 0, 50)
        mainTitle.BackgroundTransparency = 1
        mainTitle.Text = "メイン機能"
        mainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainTitle.TextSize = 24
        mainTitle.Font = Enum.Font.GothamBold
        mainTitle.Parent = mainUI

        -- スピード変更ボタン
        local speedButton = Instance.new("TextButton")
        speedButton.Size = UDim2.new(0, 200, 0, 50)
        speedButton.Position = UDim2.new(0.5, -100, 0.5, -25)
        speedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        speedButton.Text = "スピード変更"
        speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedButton.TextSize = 20
        speedButton.Font = Enum.Font.GothamBold
        speedButton.Parent = mainUI

        -- スピード変更機能（例）
        speedButton.MouseButton1Click:Connect(function()
            player.Character.Humanoid.WalkSpeed = 50 -- スピードを50に変更
        end)

        -- クロスヘア設定ボタン
        local crosshairButton = Instance.new("TextButton")
        crosshairButton.Size = UDim2.new(0, 200, 0, 50)
        crosshairButton.Position = UDim2.new(0.5, -100, 0.5, 40)
        crosshairButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        crosshairButton.Text = "クロスヘア設定"
        crosshairButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        crosshairButton.TextSize = 20
        crosshairButton.Font = Enum.Font.GothamBold
        crosshairButton.Parent = mainUI

        -- クロスヘア設定機能（例）
        crosshairButton.MouseButton1Click:Connect(function()
            -- クロスヘア設定の処理をここに追加
        end)

        -- UI削除ボタン
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0, 200, 0, 50)
        deleteButton.Position = UDim2.new(0.5, -100, 0.5, 100)
        deleteButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        deleteButton.Text = "削除"
        deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteButton.TextSize = 20
        deleteButton.Font = Enum.Font.GothamBold
        deleteButton.Parent = mainUI

        -- 削除確認機能
        deleteButton.MouseButton1Click:Connect(function()
            local confirmDialog = Instance.new("Frame")
            confirmDialog.Size = UDim2.new(0, 300, 0, 150)
            confirmDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
            confirmDialog.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            confirmDialog.BorderSizePixel = 0
            confirmDialog.Parent = screenGui

            local confirmCorner = Instance.new("UICorner")
            confirmCorner.CornerRadius = UDim.new(0, 15)
            confirmCorner.Parent = confirmDialog

            local confirmTitle = Instance.new("TextLabel")
            confirmTitle.Size = UDim2.new(1, 0, 0, 40)
            confirmTitle.BackgroundTransparency = 1
            confirmTitle.Text = "本当に削除しますか？"
            confirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            confirmTitle.TextSize = 20
            confirmTitle.Font = Enum.Font.GothamBold
            confirmTitle.Parent = confirmDialog

            local yesButton = Instance.new("TextButton")
            yesButton.Size = UDim2.new(0, 100, 0, 40)
            yesButton.Position = UDim2.new(0.5, -110, 0.5, 40)
            yesButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            yesButton.Text = "はい"
            yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            yesButton.TextSize = 20
            yesButton.Font = Enum.Font.GothamBold
            yesButton.Parent = confirmDialog

            local noButton = Instance.new("TextButton")
            noButton.Size = UDim2.new(0, 100, 0, 40)
            noButton.Position = UDim2.new(0.5, 10, 0.5, 40)
            noButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            noButton.Text = "いいえ"
            noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            noButton.TextSize = 20
            noButton.Font = Enum.Font.GothamBold
            noButton.Parent = confirmDialog

            yesButton.MouseButton1Click:Connect(function()
                mainUI:Destroy()
                confirmDialog:Destroy()
            end)

            noButton.MouseButton1Click:Connect(function()
                confirmDialog:Destroy()
            end)
        end)
    end

    -- 認証ボタン機能
    authButton.MouseButton1Click:Connect(CreateAuthWindow)
end

-- UIの初期化
CreateUI()
