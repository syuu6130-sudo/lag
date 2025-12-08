--!strict
-- Key System UI for Roblox (Modified Version)

-- サービス取得
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- プレイヤーを取得
local player = Players.LocalPlayer
if not player then return end -- LocalPlayerが存在しない場合は実行しない
local playerGui = player:WaitForChild("PlayerGui")

-- 外部通信用
-- NOTE: サーバーと通信するためのRemoteEventが必要です。
-- ReplicatedStorageに "KeySystemEvent" というRemoteEventを作成してください。
local keySystemEvent = ReplicatedStorage:WaitForChild("KeySystemEvent")

-- /////////////////////////////////////////////////////////////
-- /// 設定 (クライアント側ではキー自体は保持しません) ///
-- /////////////////////////////////////////////////////////////
local UI_CONFIG = {
	FrameSize = UDim2.new(0, 400, 0, 400), -- 高さを少し増やしてレイアウトに余裕を持たせる
	Padding = UDim.new(0, 20), -- パディング用
	InputHeight = 45,
	ButtonHeight = 50,
	TitleText = "🔑 認証システム v2.0",
	SuccessText = "認証成功！\nゲームを開始してください。",
	AdminSuccessText = "管理者権限で認証成功！\nすべての機能が利用可能です。",
	IconAssetId = "rbxassetid://3926305904",
	IconRectOffset = Vector2.new(964, 324), -- 鍵アイコン
	SuccessIconRectOffset = Vector2.new(964, 204), -- チェックマークアイコン
}
-- /////////////////////////////////////////////////////////////

-- GUIを作成する関数
local function createKeySystemGUI()
	-- ScreenGuiを作成
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "KeySystemGUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	-- メインフレーム
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UI_CONFIG.FrameSize
	mainFrame.Position = UDim2.new(0.5, -UI_CONFIG.FrameSize.X.Offset / 2, 0.5, -UI_CONFIG.FrameSize.Y.Offset / 2)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- アンカーポイントを中央に変更
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	-- 角丸にする
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainFrame
	
	-- UListLayout: 子要素を垂直に自動配置
	local listLayout = Instance.new("UIListLayout")
	listLayout.Name = "ContentLayout"
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.Padding = UDim.new(0, 15)
	listLayout.Parent = mainFrame
	
	-- UIPadding: フレーム全体にパディング
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 50) -- TopBarの高さ分+α
	uiPadding.PaddingBottom = UI_CONFIG.Padding
	uiPadding.PaddingLeft = UI_CONFIG.Padding
	uiPadding.PaddingRight = UI_CONFIG.Padding
	uiPadding.Parent = mainFrame
	
	-- TopBarとTitleの再配置 (TopBarはLayoutの外に配置)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)
	topBarCorner.Parent = topBar
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -70, 1, 0) -- 閉じるボタンのスペースを確保
	title.Position = UDim2.new(0, 35, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = UI_CONFIG.TitleText
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = topBar
	
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

	-- アイコン (ContentLayoutに追加)
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.BackgroundTransparency = 1
	icon.Image = UI_CONFIG.IconAssetId
	icon.ImageRectOffset = UI_CONFIG.IconRectOffset
	icon.ImageRectSize = Vector2.new(36, 36)
	icon.Parent = mainFrame
	
	-- 説明文
	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Size = UDim2.new(1, -UI_CONFIG.Padding.Offset * 2, 0, 60)
	description.BackgroundTransparency = 1
	description.Text = "このゲームにアクセスするには認証キーが必要です。\nキーを持っている場合は以下に入力してください。"
	description.TextColor3 = Color3.fromRGB(200, 200, 200)
	description.TextWrapped = true
	description.TextScaled = true
	description.Font = Enum.Font.Gotham
	description.TextSize = 18
	description.Parent = mainFrame
	
	-- キー入力コンテナ (レイアウト調整用)
	local keyInputContainer = Instance.new("Frame")
	keyInputContainer.Name = "KeyInputContainer"
	keyInputContainer.Size = UDim2.new(1, -UI_CONFIG.Padding.Offset * 2, 0, UI_CONFIG.InputHeight + 20) -- ラベルの高さ分+
	keyInputContainer.BackgroundTransparency = 1
	keyInputContainer.Parent = mainFrame
	
	local keyInputListLayout = Instance.new("UIListLayout")
	keyInputListLayout.FillDirection = Enum.FillDirection.Vertical
	keyInputListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	keyInputListLayout.Padding = UDim.new(0, 5)
	keyInputListLayout.Parent = keyInputContainer
	
	-- キー入力ラベル
	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "KeyLabel"
	keyLabel.Size = UDim2.new(1, 0, 0, 15)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = "キーを入力:"
	keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyLabel.TextXAlignment = Enum.TextXAlignment.Left
	keyLabel.Font = Enum.Font.Gotham
	keyLabel.TextSize = 18
	keyLabel.Parent = keyInputContainer
	
	-- キーテキストボックス
	local keyTextBox = Instance.new("TextBox")
	keyTextBox.Name = "KeyTextBox"
	keyTextBox.Size = UDim2.new(1, 0, 0, UI_CONFIG.InputHeight)
	keyTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	keyTextBox.BorderSizePixel = 0
	keyTextBox.PlaceholderText = "ここにキーを入力..."
	keyTextBox.Text = ""
	keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyTextBox.Font = Enum.Font.Gotham
	keyTextBox.TextSize = 20
	keyTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	keyTextBox.ClearTextOnFocus = false
	keyTextBox.Parent = keyInputContainer
	
	-- テキストボックスの角丸
	local textBoxCorner = Instance.new("UICorner")
	textBoxCorner.CornerRadius = UDim.new(0, 8)
	textBoxCorner.Parent = keyTextBox
	
	-- 送信ボタン
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Size = UDim2.new(1, 0, 0, UI_CONFIG.ButtonHeight)
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
	messageLabel.Size = UDim2.new(1, 0, 0, 40)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = ""
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextWrapped = true
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextSize = 16
	messageLabel.Parent = mainFrame
	
	-- 成功時に表示するメッセージフレーム
	local successFrame = Instance.new("Frame")
	successFrame.Name = "SuccessFrame"
	successFrame.Size = UI_CONFIG.FrameSize -- メインフレームと同じサイズで重ねて表示
	successFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	successFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	successFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
	successFrame.BorderSizePixel = 0
	successFrame.Visible = false
	successFrame.ZIndex = 2 -- メインフレームの上に表示
	successFrame.Parent = screenGui
	
	local successCorner = Instance.new("UICorner")
	successCorner.CornerRadius = UDim.new(0, 12)
	successCorner.Parent = successFrame
	
	local successLayout = Instance.new("UIListLayout")
	successLayout.FillDirection = Enum.FillDirection.Vertical
	successLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	successLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	successLayout.Padding = UDim.new(0, 15)
	successLayout.Parent = successFrame
	
	-- 成功アイコン
	local successIcon = Instance.new("ImageLabel")
	successIcon.Name = "SuccessIcon"
	successIcon.Size = UDim2.new(0, 60, 0, 60)
	successIcon.BackgroundTransparency = 1
	successIcon.Image = UI_CONFIG.IconAssetId
	successIcon.ImageRectOffset = UI_CONFIG.SuccessIconRectOffset
	successIcon.ImageRectSize = Vector2.new(36, 36)
	successIcon.Parent = successFrame
	
	-- 成功メッセージ
	local successMessage = Instance.new("TextLabel")
	successMessage.Name = "SuccessMessage"
	successMessage.Size = UDim2.new(0.8, 0, 0, 60)
	successMessage.BackgroundTransparency = 1
	successMessage.Text = UI_CONFIG.SuccessText
	successMessage.TextColor3 = Color3.fromRGB(200, 255, 200)
	successMessage.TextWrapped = true
	successMessage.TextScaled = true
	successMessage.Font = Enum.Font.GothamBold
	successMessage.TextSize = 22
	successMessage.Parent = successFrame
	
	-- 関数を返す
	return {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		KeyTextBox = keyTextBox,
		SubmitButton = submitButton,
		MessageLabel = messageLabel,
		CloseButton = closeButton,
		SuccessFrame = successFrame,
		SuccessMessage = successMessage,
		Icon = icon -- アニメーション用に追加
	}
end

-- キー認証処理 (サーバーへ送信)
local function authenticateKey(guiElements: { [string]: GuiObject }, inputKey: string)
	guiElements.SubmitButton.Active = false
	
	-- キーの前後の空白を削除
	inputKey = string.gsub(inputKey, "^%s*(.-)%s*$", "%1")
	
	if inputKey == "" then
		guiElements.MessageLabel.Text = "キーを入力してください。"
		guiElements.MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		guiElements.SubmitButton.Active = true
		return
	end
	
	guiElements.MessageLabel.Text = "認証中..."
	guiElements.MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
	
	-- /////////////////////////////////////////////////////////////
	-- /// サーバーへキーを送信し、認証結果を待つ (重要な変更点) ///
	-- /////////////////////////////////////////////////////////////
	local success, keyType = keySystemEvent:InvokeServer("ValidateKey", inputKey)
	
	if success == true then
		-- 成功
		
		-- アニメーション演出
		guiElements.Icon.ImageRectOffset = Vector2.new(964, 204) -- 鍵からチェックマークに
		
		task.wait(0.5)
		
		if keyType == "admin" then
			guiElements.SuccessMessage.Text = UI_CONFIG.AdminSuccessText
			guiElements.SuccessMessage.TextColor3 = Color3.fromRGB(255, 215, 0)
		else
			guiElements.SuccessMessage.Text = UI_CONFIG.SuccessText
			guiElements.SuccessMessage.TextColor3 = Color3.fromRGB(200, 255, 200)
		end
		
		-- メインフレームを非表示、成功フレームを表示
		guiElements.MainFrame.Visible = false
		guiElements.SuccessFrame.Visible = true
		
		-- 3秒後に成功フレームを非表示にし、GUIを破棄
		task.wait(3)
		
		-- ここに認証成功後の処理（例: ゲームの機能有効化）
		print("キー認証成功: " .. keyType .. " 権限")
		
		-- グローバル変数（オプション）
		_G.KeyAuthenticated = true
		_G.KeyType = keyType
		
		-- GUIを破棄
		guiElements.ScreenGui:Destroy()
		
	else
		-- 失敗
		guiElements.SubmitButton.Active = true
		guiElements.Icon.ImageRectOffset = UI_CONFIG.IconRectOffset -- アイコンを元に戻す
		
		guiElements.MessageLabel.Text = "無効なキーです。\n正しいキーを入力してください。"
		guiElements.MessageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		
		-- テキストボックスを揺らすアニメーション
		local originalPosition = guiElements.KeyTextBox.Position
		local originalColor = guiElements.KeyTextBox.BackgroundColor3
		
		-- 揺れ
		local tweenService = game:GetService("TweenService")
		local shakeTweenInfo = TweenInfo.new(0.02, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 5, true, 0)
		for i = 1, 5 do
			guiElements.KeyTextBox.Position = UDim2.new(
				originalPosition.X.Scale,
				originalPosition.X.Offset + math.random(-3, 3),
				originalPosition.Y.Scale,
				originalPosition.Y.Offset
			)
			task.wait(0.02)
		end
		guiElements.KeyTextBox.Position = originalPosition
		
		-- 赤色強調
		guiElements.KeyTextBox:TweenBackgroundColor(Color3.fromRGB(65, 40, 40), "Out", "Linear", 0.1, false)
		task.wait(0.5)
		guiElements.KeyTextBox:TweenBackgroundColor(originalColor, "Out", "Linear", 0.5, false)
	end
end

-- メイン処理
local function main()
	-- GUIを作成
	local guiElements = createKeySystemGUI()
	
	-- キーボード入力で送信できるようにする
	guiElements.KeyTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			authenticateKey(guiElements, guiElements.KeyTextBox.Text)
		end
	end)
	
	-- 送信ボタンのクリックイベント
	guiElements.SubmitButton.MouseButton1Click:Connect(function()
		authenticateKey(guiElements, guiElements.KeyTextBox.Text)
	end)
	
	-- 閉じるボタンのクリックイベント
	guiElements.CloseButton.MouseButton1Click:Connect(function()
		-- 認証システムを閉じてもゲームをプレイできないようにするため、警告を再表示
		guiElements.MessageLabel.Text = "ゲームをプレイするには認証が必要です。"
		guiElements.MessageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	end)
end

-- スクリプトの実行
main()
