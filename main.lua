local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- リモートイベントの取得
local PasswordEvent = ReplicatedStorage:WaitForChild("PasswordEvent")
local KickEvent = Instance.new("RemoteEvent")
KickEvent.Name = "KickPlayerEvent"
KickEvent.Parent = ReplicatedStorage

-- フェードアウト状態を追跡
local isFading = false

-- UI作成関数
local function createPasswordUI()
    -- ScreenGuiの作成
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PasswordUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true -- 全画面表示用
    
    -- メインフレーム（全画面）
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "PasswordFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0) -- 全画面
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- 白背景
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Parent = screenGui
    
    -- 昔のUI風にするための装飾的なボーダー（内側に）
    local innerBorder = Instance.new("Frame")
    innerBorder.Name = "InnerBorder"
    innerBorder.Size = UDim2.new(0.9, 0, 0.8, 0)
    innerBorder.Position = UDim2.new(0.05, 0, 0.1, 0)
    innerBorder.BackgroundTransparency = 1
    innerBorder.BorderSizePixel = 4
    innerBorder.BorderColor3 = Color3.fromRGB(100, 100, 100)
    innerBorder.Parent = mainFrame
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 0, 80)
    title.Position = UDim2.new(0.5, -((1 - 100)/2), 0.1, 20)
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Text = "パスワード認証"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 36
    title.Parent = innerBorder
    
    -- 説明文
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -80, 0, 60)
    description.Position = UDim2.new(0, 40, 0.2, 0)
    description.Text = "パスワードを入力してください:"
    description.TextColor3 = Color3.fromRGB(50, 50, 50)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.SourceSans
    description.TextSize = 28
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = innerBorder
    
    -- パスワード入力欄
    local passwordBox = Instance.new("TextBox")
    passwordBox.Name = "PasswordBox"
    passwordBox.Size = UDim2.new(1, -80, 0, 60)
    passwordBox.Position = UDim2.new(0, 40, 0.35, 0)
    passwordBox.PlaceholderText = "パスワードを入力..."
    passwordBox.Text = ""
    passwordBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    passwordBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    passwordBox.BorderSizePixel = 3
    passwordBox.BorderColor3 = Color3.fromRGB(200, 200, 200)
    passwordBox.Font = Enum.Font.SourceSans
    passwordBox.TextSize = 24
    passwordBox.ClearTextOnFocus = false
    passwordBox.Parent = innerBorder
    
    -- 送信ボタン
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0, 200, 0, 60)
    submitButton.Position = UDim2.new(0.5, -100, 0.6, 0)
    submitButton.AnchorPoint = Vector2.new(0.5, 0)
    submitButton.Text = "送信"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    submitButton.BorderSizePixel = 3
    submitButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
    submitButton.Font = Enum.Font.SourceSansBold
    submitButton.TextSize = 24
    submitButton.Parent = innerBorder
    
    -- ヒント（パスワード忘れ防止用）
    local hint = Instance.new("TextLabel")
    hint.Name = "Hint"
    hint.Size = UDim2.new(1, -80, 0, 40)
    hint.Position = UDim2.new(0, 40, 0.75, 0)
    hint.Text = "ヒント: 好きな食べ物（カタカナで）"
    hint.TextColor3 = Color3.fromRGB(150, 150, 150)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.SourceSansItalic
    hint.TextSize = 20
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Parent = innerBorder
    
    -- エラーメッセージ表示用
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Name = "ErrorLabel"
    errorLabel.Size = UDim2.new(1, -80, 0, 50)
    errorLabel.Position = UDim2.new(0, 40, 0.5, 0)
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Font = Enum.Font.SourceSans
    errorLabel.TextSize = 20
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Visible = false
    errorLabel.Parent = innerBorder
    
    -- 残り試行回数表示
    local attemptsLabel = Instance.new("TextLabel")
    attemptsLabel.Name = "AttemptsLabel"
    attemptsLabel.Size = UDim2.new(1, -80, 0, 40)
    attemptsLabel.Position = UDim2.new(0, 40, 0.85, 0)
    attemptsLabel.Text = "残り試行回数: 3回"
    attemptsLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    attemptsLabel.BackgroundTransparency = 1
    attemptsLabel.Font = Enum.Font.SourceSans
    attemptsLabel.TextSize = 18
    attemptsLabel.TextXAlignment = Enum.TextXAlignment.Center
    attemptsLabel.Parent = innerBorder
    
    -- モバイル対応のためのUI調整
    if UserInputService.TouchEnabled then
        passwordBox.TextSize = 28
        submitButton.TextSize = 28
        submitButton.Size = UDim2.new(0, 250, 0, 70)
        submitButton.Position = UDim2.new(0.5, -125, 0.6, 0)
        title.TextSize = 40
        description.TextSize = 32
    end
    
    return screenGui, passwordBox, submitButton, errorLabel, mainFrame, innerBorder, attemptsLabel
end

-- UIのフェードアウト関数（改善版）
local function fadeOutUI(mainFrame, innerBorder, callback)
    if isFading then return end
    isFading = true
    
    local fadeDuration = 2.0 -- 2秒かけてフェードアウト
    local startTime = tick()
    
    -- すべてのUI要素を収集
    local allUIElements = {}
    
    -- メインフレームとその子要素を収集
    local function collectElements(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") then
                table.insert(allUIElements, child)
                collectElements(child)
            end
        end
    end
    
    collectElements(mainFrame)
    
    -- フェードアウト処理
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.min(elapsed / fadeDuration, 1.0)
        
        -- 透明度を徐々に上げる（0→1）
        local transparency = alpha
        
        -- メインフレームの背景色を薄く
        mainFrame.BackgroundColor3 = Color3.fromRGB(
            255 - (255 * alpha * 0.7),
            255 - (255 * alpha * 0.7),
            255 - (255 * alpha * 0.7)
        )
        
        -- すべてのUI要素をフェードアウト
        for _, element in ipairs(allUIElements) do
            if element:IsA("TextLabel") or element:IsA("TextBox") or element:IsA("TextButton") then
                if element:IsA("TextBox") or element:IsA("TextButton") then
                    element.BackgroundTransparency = transparency * 0.8
                    element.BorderColor3 = Color3.fromRGB(
                        200 - (200 * alpha),
                        200 - (200 * alpha),
                        200 - (200 * alpha)
                    )
                end
                
                element.TextTransparency = transparency
                
                if element:IsA("TextBox") then
                    element.PlaceholderColor3 = Color3.fromRGB(
                        150 - (150 * alpha),
                        150 - (150 * alpha),
                        150 - (150 * alpha)
                    )
                end
            elseif element:IsA("Frame") and element ~= mainFrame then
                element.BackgroundTransparency = transparency
                element.BorderColor3 = Color3.fromRGB(
                    100 - (100 * alpha),
                    100 - (100 * alpha),
                    100 - (100 * alpha)
                )
            end
        end
        
        -- フェードアウト完了
        if alpha >= 1.0 then
            connection:Disconnect()
            isFading = false
            
            if callback then
                callback()
            end
        end
    end)
end

-- 退出処理関数
local function setupKickListener()
    KickEvent.OnClientEvent:Connect(function(kickMessage)
        -- 退出メッセージを表示
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "KickMessageUI"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BackgroundTransparency = 0.3
        frame.Parent = screenGui
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0.8, 0, 0.3, 0)
        textLabel.Position = UDim2.new(0.1, 0, 0.35, 0)
        textLabel.Text = kickMessage
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 28
        textLabel.TextWrapped = true
        textLabel.Parent = frame
        
        screenGui.Parent = PlayerGui
        
        -- 2秒待ってから退出
        task.wait(2)
    end)
end

-- メイン処理
local screenGui, passwordBox, submitButton, errorLabel, mainFrame, innerBorder, attemptsLabel = createPasswordUI()
screenGui.Parent = PlayerGui

-- 退出リスナーを設定
setupKickListener()

-- エラーメッセージ表示関数
local function showError(message)
    errorLabel.Text = message
    errorLabel.Visible = true
    
    -- 2秒後にエラーメッセージを非表示
    task.delay(2, function()
        if errorLabel and errorLabel.Parent then
            errorLabel.Visible = false
        end
    end)
end

-- 残り試行回数を更新
local function updateAttemptsLabel(remaining)
    if attemptsLabel and attemptsLabel.Parent then
        attemptsLabel.Text = "残り試行回数: " .. tostring(remaining) .. "回"
        
        -- 残り回数が少ない場合は色を変える
        if remaining == 2 then
            attemptsLabel.TextColor3 = Color3.fromRGB(200, 150, 0) -- オレンジ
        elseif remaining == 1 then
            attemptsLabel.TextColor3 = Color3.fromRGB(200, 0, 0) -- 赤
        else
            attemptsLabel.TextColor3 = Color3.fromRGB(100, 100, 100) -- グレー
        end
    end
end

-- 送信ボタンのクリックイベント
submitButton.MouseButton1Click:Connect(function()
    local password = passwordBox.Text
    
    if password == "" then
        showError("パスワードを入力してください")
        return
    end
    
    -- サーバーにパスワードを送信
    PasswordEvent:FireServer(password)
end)

-- タッチデバイス用のタップイベント（モバイル対応）
if UserInputService.TouchEnabled then
    submitButton.TouchTap:Connect(function()
        local password = passwordBox.Text
        
        if password == "" then
            showError("パスワードを入力してください")
            return
        end
        
        PasswordEvent:FireServer(password)
    end)
end

-- エンターキーでも送信可能に
passwordBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        submitButton.MouseButton1Click:Fire()
    end
end)

-- サーバーからの応答を待機
PasswordEvent.OnClientEvent:Connect(function(success, remainingAttempts)
    if success then
        -- パスワードが正しい場合
        submitButton.Text = "認証成功！"
        submitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        submitButton.AutoButtonColor = false
        
        -- 入力欄とボタンを無効化
        passwordBox.Text = ""
        passwordBox.ClearTextOnFocus = true
        passwordBox:ReleaseFocus()
        
        -- UIをフェードアウト
        fadeOutUI(mainFrame, innerBorder, function()
            task.wait(0.5) -- 少し待ってからUIを削除
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    else
        -- パスワードが間違っている場合
        if remainingAttempts > 0 then
            showError("パスワードが違います。残り" .. tostring(remainingAttempts) .. "回")
            updateAttemptsLabel(remainingAttempts)
            passwordBox.Text = ""
            
            -- 入力欄にフォーカスを戻す
            task.wait(0.1)
            if passwordBox and passwordBox.Parent then
                passwordBox:CaptureFocus()
            end
        else
            -- 3回間違えた場合（サーバー側で退出処理が行われる）
            showError("パスワードを3回間違えました。退出します...")
            submitButton.Text = "退出中..."
            submitButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end
end)

-- 最初にフォーカスを当てる
task.wait(0.5)
if passwordBox and passwordBox.Parent then
    passwordBox:CaptureFocus()
end
