-- Key System UI for Roblox
-- このスクリプトはStarterGuiの中のScreenGuiに配置するか、
-- またはLocalScriptとしてStarterPlayerScriptsに配置してください

-- サービス取得
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- プレイヤーを取得
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 正しいキー（ここで変更可能）
local correctKey = "ROBLOX123"
-- 管理者用キー（オプション）
local adminKey = "ADMIN2024"

-- GUIを作成する関数
local function createKeySystemGUI()
	-- ScreenGuiを作成
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "KeySystemGUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- メインフレーム
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 400, 0, 350)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
	mainFrame.AnchorPoint = Vector2.new(0, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	
	-- 角丸にする
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainFrame
	
	-- 上部バー
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	topBar.BorderSizePixel = 0
	
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)
	topBarCorner.Parent = topBar
	
	-- タイトル
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 1, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🔐 キー認証システム"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = topBar
	
	-- アイコン
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 30, 0, 30)
	icon.Position = UDim2.new(0.5, -15, 0, 70)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://3926305904"
	icon.ImageRectOffset = Vector2.new(964, 324)
	icon.ImageRectSize = Vector2.new(36, 36)
	icon.Parent = mainFrame
	
	-- 説明文
	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Size = UDim2.new(0.8, 0, 0, 60)
	description.Position = UDim2.new(0.1, 0, 0, 110)
	description.BackgroundTransparency = 1
	description.Text = "このゲームにアクセスするには認証キーが必要です。\nキーを持っている場合は以下に入力してください。"
	description.TextColor3 = Color3.fromRGB(200, 200, 200)
	description.TextWrapped = true
	description.TextScaled = true
	description.Font = Enum.Font.Gotham
	description.TextSize = 18
	description.Parent = mainFrame
	
	-- キー入力ラベル
	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "KeyLabel"
	keyLabel.Size = UDim2.new(0.8, 0, 0, 20)
	keyLabel.Position = UDim2.new(0.1, 0, 0, 180)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = "キーを入力:"
	keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyLabel.TextXAlignment = Enum.TextXAlignment.Left
	keyLabel.Font = Enum.Font.Gotham
	keyLabel.TextSize = 18
	keyLabel.Parent = mainFrame
	
	-- キーテキストボックス
	local keyTextBox = Instance.new("TextBox")
	keyTextBox.Name = "KeyTextBox"
	keyTextBox.Size = UDim2.new(0.8, 0, 0, 45)
	keyTextBox.Position = UDim2.new(0.1, 0, 0, 205)
	keyTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	keyTextBox.BorderSizePixel = 0
	keyTextBox.PlaceholderText = "ここにキーを入力..."
	keyTextBox.Text = ""
	keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyTextBox.Font = Enum.Font.Gotham
	keyTextBox.TextSize = 20
	keyTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	keyTextBox.ClearTextOnFocus = false
	keyTextBox.Parent = mainFrame
	
	-- テキストボックスの角丸
	local textBoxCorner = Instance.new("UICorner")
	textBoxCorner.CornerRadius = UDim.new(0, 8)
	textBoxCorner.Parent = keyTextBox
	
	-- 送信ボタン
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Size = UDim2.new(0.8, 0, 0, 50)
	submitButton.Position = UDim2.new(0.1, 0, 0, 270)
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	submitButton.BorderSizePixel = 0
	submitButton.Text = "認証する"
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.Font = Enum.Font.GothamBold
	submitButton.TextSize = 22
	submitButton.AutoButtonColor = true
	submitButton.Parent = mainFrame
	
	-- 送信ボタンの角丸
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = submitButton
	
	-- ボタンにホバーエフェクトを追加
	submitButton.MouseEnter:Connect(function()
		submitButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	end)
	
	submitButton.MouseLeave:Connect(function()
		submitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	end)
	
	-- メッセージ表示ラベル
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "MessageLabel"
	messageLabel.Size = UDim2.new(0.8, 0, 0, 40)
	messageLabel.Position = UDim2.new(0.1, 0, 0, 330)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = ""
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextWrapped = true
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextSize = 16
	messageLabel.Parent = mainFrame
	
	-- 閉じるボタン（右上）
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.Parent = topBar
	
	-- 閉じるボタンのホバーエフェクト
	closeButton.MouseEnter:Connect(function()
		closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
	end)
	
	closeButton.MouseLeave:Connect(function()
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	
	-- GUIをプレイヤーのGuiに追加
	screenGui.Parent = playerGui
	mainFrame.Parent = screenGui
	
	-- 成功時に表示するメッセージフレーム
	local successFrame = Instance.new("Frame")
	successFrame.Name = "SuccessFrame"
	successFrame.Size = UDim2.new(0, 400, 0, 200)
	successFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
	successFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
	successFrame.BorderSizePixel = 0
	successFrame.Visible = false
	
	local successCorner = Instance.new("UICorner")
	successCorner.CornerRadius = UDim.new(0, 12)
	successCorner.Parent = successFrame
	
	-- 成功アイコン
	local successIcon = Instance.new("ImageLabel")
	successIcon.Name = "SuccessIcon"
	successIcon.Size = UDim2.new(0, 60, 0, 60)
	successIcon.Position = UDim2.new(0.5, -30, 0, 30)
	successIcon.BackgroundTransparency = 1
	successIcon.Image = "rbxassetid://3926305904"
	successIcon.ImageRectOffset = Vector2.new(964, 204)
	successIcon.ImageRectSize = Vector2.new(36, 36)
	successIcon.Parent = successFrame
	
	-- 成功メッセージ
	local successMessage = Instance.new("TextLabel")
	successMessage.Name = "SuccessMessage"
	successMessage.Size = UDim2.new(0.8, 0, 0, 60)
	successMessage.Position = UDim2.new(0.1, 0, 0, 110)
	successMessage.BackgroundTransparency = 1
	successMessage.Text = "認証成功！\nゲームを開始してください。"
	successMessage.TextColor3 = Color3.fromRGB(200, 255, 200)
	successMessage.TextWrapped = true
	successMessage.TextScaled = true
	successMessage.Font = Enum.Font.GothamBold
	successMessage.TextSize = 22
	successMessage.Parent = successFrame
	
	successFrame.Parent = screenGui
	
	-- 関数を返す
	return {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		KeyTextBox = keyTextBox,
		SubmitButton = submitButton,
		MessageLabel = messageLabel,
		CloseButton = closeButton,
		SuccessFrame = successFrame,
		SuccessMessage = successMessage
	}
end

-- キー検証関数
local function validateKey(inputKey)
	-- キーの前後の空白を削除
	inputKey = string.gsub(inputKey, "^%s*(.-)%s*$", "%1")
	
	-- 正しいキーかチェック
	if inputKey == correctKey then
		return true, "standard"
	elseif inputKey == adminKey then
		return true, "admin"
	else
		return false, "invalid"
	end
end

-- メイン処理
local function main()
	-- GUIを作成
	local guiElements = createKeySystemGUI()
	
	-- キーボード入力で送信できるようにする
	guiElements.KeyTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			guiElements.SubmitButton:Activate()
		end
	end)
	
	-- 送信ボタンのクリックイベント
	guiElements.SubmitButton.MouseButton1Click:Connect(function()
		local inputKey = guiElements.KeyTextBox.Text
		
		if inputKey == "" then
			guiElements.MessageLabel.Text = "キーを入力してください。"
			guiElements.MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
			return
		end
		
		local isValid, keyType = validateKey(inputKey)
		
		if isValid then
			-- 成功メッセージ
			guiElements.MessageLabel.Text = "認証中..."
			guiElements.MessageLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			
			-- 少し遅延を入れて成功を演出
			wait(0.8)
			
			if keyType == "admin" then
				guiElements.SuccessMessage.Text = "管理者権限で認証成功！\nすべての機能が利用可能です。"
				guiElements.SuccessMessage.TextColor3 = Color3.fromRGB(255, 215, 0)
			else
				guiElements.SuccessMessage.Text = "認証成功！\nゲームを開始してください。"
				guiElements.SuccessMessage.TextColor3 = Color3.fromRGB(200, 255, 200)
			end
			
			-- メインフレームを非表示、成功フレームを表示
			guiElements.MainFrame.Visible = false
			guiElements.SuccessFrame.Visible = true
			
			-- 5秒後に成功フレームを非表示にする
			wait(3)
			guiElements.ScreenGui:Destroy()
			
			-- ここに認証成功後の処理を追加
			-- 例: ゲームの機能を有効化する
			print("キー認証成功: " .. keyType .. " 権限")
			
			-- ゲーム内で使うグローバル変数（オプション）
			_G.KeyAuthenticated = true
			_G.KeyType = keyType
			
		else
			-- エラーメッセージ
			guiElements.MessageLabel.Text = "無効なキーです。\n正しいキーを入力してください。"
			guiElements.MessageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			
			-- テキストボックスを揺らすアニメーション
			local originalPosition = guiElements.KeyTextBox.Position
			for i = 1, 5 do
				guiElements.KeyTextBox.Position = UDim2.new(
					originalPosition.X.Scale, 
					originalPosition.X.Offset + math.random(-3, 3),
					originalPosition.Y.Scale, 
					originalPosition.Y.Offset
				)
				wait(0.02)
			end
			guiElements.KeyTextBox.Position = originalPosition
			
			-- テキストボックスを赤くする
			guiElements.KeyTextBox.BackgroundColor3 = Color3.fromRGB(65, 40, 40)
			wait(0.5)
			guiElements.KeyTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
		end
	end)
	
	-- 閉じるボタンのクリックイベント
	guiElements.CloseButton.MouseButton1Click:Connect(function()
		guiElements.MessageLabel.Text = "ゲームをプレイするには認証が必要です。"
		guiElements.MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	end)
	
	-- ヒントを表示（実際のゲームでは削除）
	guiElements.MessageLabel.Text = "ヒント: 正しいキーは '" .. correctKey .. "' です"
	guiElements.MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
end

-- スクリプトの実行
main()
