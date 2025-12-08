-- LocalScript (StarterGui > ScreenGui内に配置)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- 正しいパスワード
local CORRECT_PASSWORD = "しゅーくりーむ"
local MAX_ATTEMPTS = 3
local currentAttempts = 0

-- ScreenGuiの作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PasswordGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 背景フレームの作成(白背景)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.Parent = screenGui

-- タイトルラベル(昔風のデザイン)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "パスワード入力"
titleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Font = Enum.Font.SourceSans
titleLabel.TextSize = 24
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

-- パスワード入力ボックス
local passwordBox = Instance.new("TextBox")
passwordBox.Size = UDim2.new(0, 300, 0, 40)
passwordBox.Position = UDim2.new(0.5, -150, 0, 70)
passwordBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
passwordBox.BorderSizePixel = 2
passwordBox.BorderColor3 = Color3.fromRGB(128, 128, 128)
passwordBox.Text = ""
passwordBox.PlaceholderText = "パスワードを入力してください"
passwordBox.TextColor3 = Color3.fromRGB(0, 0, 0)
passwordBox.Font = Enum.Font.SourceSans
passwordBox.TextSize = 18
passwordBox.ClearTextOnFocus = false
passwordBox.Parent = mainFrame

-- 確認ボタン(昔風のボタン)
local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0, 120, 0, 40)
submitButton.Position = UDim2.new(0.5, -60, 0, 130)
submitButton.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
submitButton.BorderSizePixel = 2
submitButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
submitButton.Text = "OK"
submitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
submitButton.Font = Enum.Font.SourceSans
submitButton.TextSize = 20
submitButton.Parent = mainFrame

-- メッセージラベル
local messageLabel = Instance.new("TextLabel")
messageLabel.Size = UDim2.new(1, -20, 0, 30)
messageLabel.Position = UDim2.new(0, 10, 0, 190)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = ""
messageLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
messageLabel.Font = Enum.Font.SourceSans
messageLabel.TextSize = 16
messageLabel.TextXAlignment = Enum.TextXAlignment.Center
messageLabel.Parent = mainFrame

-- UIを徐々に消す関数
local function fadeOutUI()
	local tweenInfo = TweenInfo.new(
		2, -- 2秒かけて消える
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	
	-- 全ての子要素を徐々に透明にする
	for _, child in pairs(mainFrame:GetDescendants()) do
		if child:IsA("GuiObject") then
			local tween
			if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
				tween = TweenService:Create(child, tweenInfo, {
					TextTransparency = 1,
					BackgroundTransparency = 1
				})
			else
				tween = TweenService:Create(child, tweenInfo, {
					BackgroundTransparency = 1
				})
			end
			tween:Play()
		end
	end
	
	-- フレーム自体も透明に
	local frameTween = TweenService:Create(mainFrame, tweenInfo, {
		BackgroundTransparency = 1
	})
	frameTween:Play()
	
	-- 完全に消えたら削除
	wait(2.1)
	screenGui:Destroy()
end

-- パスワード確認関数
local function checkPassword()
	local inputPassword = passwordBox.Text
	
	if inputPassword == CORRECT_PASSWORD then
		-- パスワードが正しい場合
		messageLabel.TextColor3 = Color3.fromRGB(0, 128, 0)
		messageLabel.Text = "認証成功！"
		submitButton.Active = false
		passwordBox.Active = false
		
		wait(0.5)
		fadeOutUI()
	else
		-- パスワードが間違っている場合
		currentAttempts = currentAttempts + 1
		local remainingAttempts = MAX_ATTEMPTS - currentAttempts
		
		if remainingAttempts > 0 then
			messageLabel.Text = "パスワードが違います (残り" .. remainingAttempts .. "回)"
			passwordBox.Text = ""
		else
			messageLabel.Text = "認証失敗。サーバーから退出します..."
			submitButton.Active = false
			passwordBox.Active = false
			
			wait(2)
			player:Kick("パスワード認証に失敗しました")
		end
	end
end

-- ボタンクリック時の処理
submitButton.MouseButton1Click:Connect(checkPassword)

-- Enterキーでも送信可能に
passwordBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		checkPassword()
	end
end)
