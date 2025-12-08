-- Key System with Crosshair UI
-- Roblox Executer Version

-- サービスを取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- プレイヤーを取得
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UIを作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- キー入力UI
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.new(0, 350, 0, 250)
keyFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
keyFrame.BorderSizePixel = 0
keyFrame.BackgroundTransparency = 0.1
keyFrame.Parent = screenGui

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 10)
UICorner1.Parent = keyFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "キー認証システム"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyBox"
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "認証キーを入力..."
keyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.TextScaled = true
keyBox.ClearTextOnFocus = false
keyBox.Parent = keyFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 5)
UICorner2.Parent = keyBox

local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(0.6, 0, 0, 40)
submitButton.Position = UDim2.new(0.2, 0, 0.6, 0)
submitButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
submitButton.BorderSizePixel = 0
submitButton.Text = "認証"
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.TextScaled = true
submitButton.Font = Enum.Font.GothamBold
submitButton.Parent = keyFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 5)
UICorner3.Parent = submitButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ステータス: 未認証"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = keyFrame

-- クロスヘアUI（初期状態では非表示）
local crosshairFrame = Instance.new("Frame")
crosshairFrame.Name = "CrosshairFrame"
crosshairFrame.Size = UDim2.new(0, 100, 0, 100)
crosshairFrame.Position = UDim2.new(0.5, -50, 0.5, -50)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Visible = false
crosshairFrame.Parent = screenGui

-- クロスヘアの各線を作成
local function createCrosshairLine(name, size, position, rotation)
	local line = Instance.new("Frame")
	line.Name = name
	line.Size = size
	line.Position = position
	line.Rotation = rotation
	line.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	line.BorderSizePixel = 0
	line.Parent = crosshairFrame
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = line
	
	return line
end

-- クロスヘアの線を4方向に作成
createCrosshairLine("TopLine", UDim2.new(0, 2, 0, 15), UDim2.new(0.5, -1, 0.5, -20), 0)
createCrosshairLine("BottomLine", UDim2.new(0, 2, 0, 15), UDim2.new(0.5, -1, 0.5, 10), 0)
createCrosshairLine("LeftLine", UDim2.new(0, 15, 0, 2), UDim2.new(0.5, -20, 0.5, -1), 0)
createCrosshairLine("RightLine", UDim2.new(0, 15, 0, 2), UDim2.new(0.5, 10, 0.5, -1), 0)

-- 中央の点
local centerDot = Instance.new("Frame")
centerDot.Name = "CenterDot"
centerDot.Size = UDim2.new(0, 4, 0, 4)
centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
centerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
centerDot.BorderSizePixel = 0
centerDot.Parent = crosshairFrame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(1, 0)
UICorner4.Parent = centerDot

-- 認証キー（ここでキーを設定）
local validKeys = {
	"ROBLOX123",
	"SECRETKEY",
	"ADMINPASS",
	"CROSSHAIR2024",
	"TESTKEY"
}

-- 認証状態を追跡
local isAuthenticated = false

-- キーを検証する関数
local function validateKey(inputKey)
	-- 大文字小文字を区別せずに比較
	for _, validKey in ipairs(validKeys) do
		if inputKey:upper() == validKey:upper() then
			return true
		end
	end
	return false
end

-- 認証成功時の処理
local function onAuthenticationSuccess()
	isAuthenticated = true
	statusLabel.Text = "ステータス: 認証成功!"
	statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	
	-- クロスヘアを表示
	crosshairFrame.Visible = true
	
	-- キー入力UIを非表示にする
	keyFrame.Visible = false
	
	-- 認証成功メッセージ
	local successMsg = Instance.new("TextLabel")
	successMsg.Name = "SuccessMessage"
	successMsg.Size = UDim2.new(0, 300, 0, 50)
	successMsg.Position = UDim2.new(0.5, -150, 0.1, 0)
	successMsg.BackgroundTransparency = 1
	successMsg.Text = "認証成功! クロスヘアが有効になりました。"
	successMsg.TextColor3 = Color3.fromRGB(100, 255, 100)
	successMsg.TextScaled = true
	successMsg.Font = Enum.Font.GothamBold
	successMsg.Visible = true
	successMsg.Parent = screenGui
	
	-- 3秒後にメッセージを消す
	task.wait(3)
	successMsg:Destroy()
	
	-- クロスヘアの色を変更する関数
	local colorChangeThread = coroutine.create(function()
		while isAuthenticated do
			for i = 0, 1, 0.05 do
				if not isAuthenticated then break end
				
				-- 色を緑から赤に変化
				local r = 1 - i
				local g = i
				local color = Color3.new(r, g, 0)
				
				-- クロスヘアの色を変更
				for _, child in ipairs(crosshairFrame:GetChildren()) do
					if child:IsA("Frame") then
						child.BackgroundColor3 = color
					end
				end
				
				task.wait(0.1)
			end
			
			for i = 0, 1, 0.05 do
				if not isAuthenticated then break end
				
				-- 色を赤から緑に変化
				local r = i
				local g = 1 - i
				local color = Color3.new(r, g, 0)
				
				-- クロスヘアの色を変更
				for _, child in ipairs(crosshairFrame:GetChildren()) do
					if child:IsA("Frame") then
						child.BackgroundColor3 = color
					end
				end
				
				task.wait(0.1)
			end
		end
	end)
	
	coroutine.resume(colorChangeThread)
end

-- 認証失敗時の処理
local function onAuthenticationFailed()
	statusLabel.Text = "ステータス: 認証失敗"
	statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	
	-- テキストボックスを揺らすアニメーション
	local originalPosition = keyBox.Position
	for i = 1, 3 do
		keyBox.Position = UDim2.new(0.1, math.random(-5, 5), 0.3, math.random(-2, 2))
		task.wait(0.05)
	end
	keyBox.Position = originalPosition
	
	-- テキストボックスを赤くする
	keyBox.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
	task.wait(0.5)
	keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	
	-- テキストをクリア
	keyBox.Text = ""
end

-- 認証ボタンのクリックイベント
submitButton.MouseButton1Click:Connect(function()
	local inputKey = keyBox.Text
	
	if inputKey == "" then
		statusLabel.Text = "ステータス: キーを入力してください"
		statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		return
	end
	
	if validateKey(inputKey) then
		onAuthenticationSuccess()
	else
		onAuthenticationFailed()
	end
end)

-- Enterキーでも認証できるように
keyBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitButton.MouseButton1Click:Wait()
	end
end)

-- UIを閉じる機能（オプション）
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = keyFrame

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(0, 15)
UICorner5.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
	keyFrame.Visible = false
end)

-- クロスヘアの表示/非表示を切り替えるキー（例: Hキー）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.H and isAuthenticated then
		crosshairFrame.Visible = not crosshairFrame.Visible
		
		-- 切り替えメッセージ
		local toggleMsg = Instance.new("TextLabel")
		toggleMsg.Name = "ToggleMessage"
		toggleMsg.Size = UDim2.new(0, 250, 0, 40)
		toggleMsg.Position = UDim2.new(0.5, -125, 0.15, 0)
		toggleMsg.BackgroundTransparency = 1
		toggleMsg.Text = "クロスヘア: " .. (crosshairFrame.Visible and "ON" or "OFF")
		toggleMsg.TextColor3 = crosshairFrame.Visible and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		toggleMsg.TextScaled = true
		toggleMsg.Font = Enum.Font.Gotham
		toggleMsg.Visible = true
		toggleMsg.Parent = screenGui
		
		task.wait(1.5)
		toggleMsg:Destroy()
	end
end)

-- デバッグ用: コンソールに有効なキーを表示
print("有効な認証キー:")
for i, key in ipairs(validKeys) do
	print(i .. ": " .. key)
end
print("Hキーでクロスヘアの表示/非表示を切り替えられます")

-- ヒントを表示
local hintLabel = Instance.new("TextLabel")
hintLabel.Name = "HintLabel"
hintLabel.Size = UDim2.new(0.8, 0, 0, 20)
hintLabel.Position = UDim2.new(0.1, 0, 0.75, 0)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "ヒント: 有効なキーの例: ROBLOX123, SECRETKEY"
hintLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
hintLabel.TextScaled = true
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextXAlignment = Enum.TextXAlignment.Left
hintLabel.Parent = keyFrame
