-- Arseus x Neo Style UI v3.0 - モバイル対応認証システム完全版
-- サービスの取得
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")

-- プレイヤーとマウス
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- デバイス判定
local IS_MOBILE = UserInputService.TouchEnabled
local IS_CONSOLE = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled
local IS_DESKTOP = not IS_MOBILE and not IS_CONSOLE

-- 画面サイズに基づくUIサイズ計算
function GetUISize()
	if IS_MOBILE then
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local width = math.min(viewportSize.X * 0.9, 450)
		local height = math.min(viewportSize.Y * 0.7, 500)
		return UDim2.new(0, width, 0, height)
	elseif IS_DESKTOP then
		return UDim2.new(0, 650, 0, 550)
	else
		return UDim2.new(0, 500, 0, 450)
	end
end

-- メインGUIの作成
local ArseusUI = Instance.new("ScreenGui")
ArseusUI.Name = "ArseusNeoUI"
ArseusUI.ResetOnSpawn = false
ArseusUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ArseusUI.IgnoreGuiInset = true
ArseusUI.Parent = player:WaitForChild("PlayerGui")

-- 認証パスワード
local SECURITY_PASSWORD = "しゅーくりーむ"
local authAttempts = 0
local MAX_AUTH_ATTEMPTS = 5

-- グローバル変数
local MainWindow = nil
local AuthWindow = nil
local CrosshairGui = nil

-- グローバル設定
local Settings = {
	UIColor = Color3.fromRGB(0, 170, 255),
	UIShape = "Rounded",
	Theme = "Dark",
	Transparency = 0.1,
	Crosshair = {
		Enabled = false,
		Type = "Cross",
		Color = Color3.fromRGB(255, 255, 255),
		Size = 20,
		Thickness = 2,
		Gap = 5,
		Outline = true,
		OutlineColor = Color3.fromRGB(0, 0, 0),
		Rotation = 0,
		Alpha = 1,
		Blinking = false,
		ShowDot = true,
		CustomShape = 1
	},
	Player = {
		WalkSpeed = 16,
		JumpPower = 50,
		FlyEnabled = false,
		FlySpeed = 50,
		NoClip = false,
		Gravity = 196.2,
		HipHeight = 0,
		FloatForce = 0,
		InfiniteJump = false,
		AutoSprint = false
	},
	Visual = {
		ShiftLock = false,
		ThirdPerson = false,
		FOV = 70,
		CameraOffset = Vector3.new(0, 0, 5),
		Esp = false,
		Tracers = false,
		Chams = false
	},
	Misc = {
		AutoFarm = false,
		AntiAfk = true,
		ClickTP = false,
		TPKey = Enum.KeyCode.T,
		SpeedKey = Enum.KeyCode.LeftShift,
		JumpKey = Enum.KeyCode.Space
	}
}

-- カラーパレット (12色)
local ColorPalette = {
	Color3.fromRGB(0, 170, 255),
	Color3.fromRGB(255, 50, 100),
	Color3.fromRGB(50, 255, 100),
	Color3.fromRGB(255, 200, 50),
	Color3.fromRGB(180, 50, 255),
	Color3.fromRGB(255, 100, 50),
	Color3.fromRGB(50, 200, 255),
	Color3.fromRGB(255, 50, 200),
	Color3.fromRGB(100, 255, 200),
	Color3.fromRGB(255, 150, 50),
	Color3.fromRGB(150, 50, 255),
	Color3.fromRGB(255, 255, 255)
}

-- UI形状タイプと詳細設定
local ShapeTypes = {
	{Name = "Rounded", CornerRadius = 20, Description = "丸みを帯びた角"},
	{Name = "Square", CornerRadius = 0, Description = "鋭い角"},
	{Name = "Circle", CornerRadius = 1000, Description = "完全な円形"},
	{Name = "Swastika", CornerRadius = 15, Description = "卍型のデザイン"},
	{Name = "Diamond", CornerRadius = 5, Description = "ダイヤモンド型"},
	{Name = "Hexagon", CornerRadius = 10, Description = "六角形"},
	{Name = "Pill", CornerRadius = 100, Description = "カプセル型"},
	{Name = "RoundedX", CornerRadius = 15, Description = "X型丸み"},
	{Name = "RoundedPlus", CornerRadius = 15, Description = "+型丸み"},
	{Name = "Custom", CornerRadius = 25, Description = "カスタム形状"}
}

-- クロスヘアタイプと詳細設定
local CrosshairTypes = {
	{Name = "Cross", Parts = 4, Description = "基本の十字"},
	{Name = "Dot", Parts = 1, Description = "単純な点"},
	{Name = "Circle", Parts = 1, Description = "円形"},
	{Name = "Square", Parts = 1, Description = "四角形"},
	{Name = "Crosshair", Parts = 5, Description = "精密クロスヘア"},
	{Name = "Target", Parts = 3, Description = "ターゲット型"},
	{Name = "Arrow", Parts = 3, Description = "矢印型"},
	{Name = "Diamond", Parts = 1, Description = "ダイヤモンド型"},
	{Name = "Hexagon", Parts = 1, Description = "六角形"},
	{Name = "Star", Parts = 10, Description = "星型"},
	{Name = "Custom1", Parts = 4, Description = "カスタム1"},
	{Name = "Custom2", Parts = 6, Description = "カスタム2"}
}

-- スムーズなアニメーション設定
local AnimationConfig = {
	Duration = 0.3,
	EasingStyle = Enum.EasingStyle.Quint,
	EasingDirection = Enum.EasingDirection.Out,
	HoverScale = 1.05,
	ClickScale = 0.95
}

-- 関数: スムーズドラッグ
local function CreateSmoothDrag(frame, dragPart)
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function Update(input)
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local frameSize = frame.AbsoluteSize
		newPos = UDim2.new(
			math.clamp(newPos.X.Scale, 0, 1 - (frameSize.X / viewportSize.X)),
			math.clamp(newPos.X.Offset, 0, viewportSize.X - frameSize.X),
			math.clamp(newPos.Y.Scale, 0, 1 - (frameSize.Y / viewportSize.Y)),
			math.clamp(newPos.Y.Offset, 0, viewportSize.Y - frameSize.Y)
		)
		
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(frame, tweenInfo, {Position = newPos})
		tween:Play()
	end
	
	dragPart.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
	
	dragPart.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			Update(input)
		end
	end)
end

-- 関数: ボタンアニメーション
local function CreateButtonAnimation(button)
	local originalSize = button.Size
	local originalColor = button.BackgroundColor3
	
	button.MouseEnter:Connect(function()
		if not AnimationConfig then return end
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(
				originalSize.X.Scale * AnimationConfig.HoverScale,
				originalSize.X.Offset * AnimationConfig.HoverScale,
				originalSize.Y.Scale * AnimationConfig.HoverScale,
				originalSize.Y.Offset * AnimationConfig.HoverScale
			),
			BackgroundColor3 = Color3.new(
				math.min(originalColor.R * 1.2, 1),
				math.min(originalColor.G * 1.2, 1),
				math.min(originalColor.B * 1.2, 1)
			)
		})
		tween:Play()
	end)
	
	button.MouseLeave:Connect(function()
		if not AnimationConfig then return end
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(button, tweenInfo, {
			Size = originalSize,
			BackgroundColor3 = originalColor
		})
		tween:Play()
	end)
	
	button.MouseButton1Down:Connect(function()
		if not AnimationConfig then return end
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(
				originalSize.X.Scale * AnimationConfig.ClickScale,
				originalSize.X.Offset * AnimationConfig.ClickScale,
				originalSize.Y.Scale * AnimationConfig.ClickScale,
				originalSize.Y.Offset * AnimationConfig.ClickScale
			)
		})
		tween:Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		if not AnimationConfig then return end
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(
				originalSize.X.Scale * AnimationConfig.HoverScale,
				originalSize.X.Offset * AnimationConfig.HoverScale,
				originalSize.Y.Scale * AnimationConfig.HoverScale,
				originalSize.Y.Offset * AnimationConfig.HoverScale
			)
		})
		tween:Play()
	end)
end

-- 関数: 認証画面の作成（モバイル最適化版）
local function CreateAuthWindow()
	AuthWindow = Instance.new("Frame")
	AuthWindow.Name = "AuthWindow"
	
	local uiSize = GetUISize()
	local authWidth = IS_MOBILE and math.min(uiSize.X.Offset * 0.95, 380) or uiSize.X.Offset * 0.7
	local authHeight = IS_MOBILE and math.min(uiSize.Y.Offset * 0.7, 420) or uiSize.Y.Offset * 0.6
	
	AuthWindow.Size = UDim2.new(0, authWidth, 0, authHeight)
	AuthWindow.Position = UDim2.new(0.5, -authWidth / 2, 0.5, -authHeight / 2)
	AuthWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	AuthWindow.BackgroundTransparency = 0.05
	AuthWindow.BorderSizePixel = 0
	AuthWindow.ZIndex = 999
	AuthWindow.Parent = ArseusUI
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, IS_MOBILE and 18 or 15)
	corner.Parent = AuthWindow
	
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554236805"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = -1
	shadow.Parent = AuthWindow
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ContentScroll"
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = IS_MOBILE and 4 or 6
	scrollFrame.ScrollBarImageColor3 = Settings.UIColor
	scrollFrame.ScrollBarImageTransparency = 0.5
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, IS_MOBILE and 400 or 350)
	scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollFrame.Parent = AuthWindow
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, IS_MOBILE and 60 or 60)
	title.Position = UDim2.new(0, 20, 0, IS_MOBILE and 25 or 15)
	title.BackgroundTransparency = 1
	title.Text = "🔒 セキュリティ認証"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = IS_MOBILE and 28 or 28
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = scrollFrame
	
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, -40, 0, IS_MOBILE and 50 or 40)
	subtitle.Position = UDim2.new(0, 20, 0, IS_MOBILE and 90 or 85)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Arseus x Neo UIにアクセスするには\n認証が必要です"
	subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	subtitle.TextSize = IS_MOBILE and 16 or 16
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	subtitle.TextWrapped = true
	subtitle.Parent = scrollFrame
	
	local passwordFrame = Instance.new("Frame")
	passwordFrame.Name = "PasswordFrame"
	passwordFrame.Size = UDim2.new(1, -40, 0, IS_MOBILE and 60 or 50)
	passwordFrame.Position = UDim2.new(0, 20, 0, IS_MOBILE and 155 or 145)
	passwordFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	passwordFrame.BorderSizePixel = 0
	passwordFrame.Parent = scrollFrame
	
	local passwordCorner = Instance.new("UICorner")
	passwordCorner.CornerRadius = UDim.new(0, IS_MOBILE and 14 or 10)
	passwordCorner.Parent = passwordFrame
	
	local passwordBox = Instance.new("TextBox")
	passwordBox.Name = "PasswordBox"
	passwordBox.Size = UDim2.new(1, IS_MOBILE and -75 or -60, 1, 0)
	passwordBox.Position = UDim2.new(0, IS_MOBILE and 18 or 10, 0, 0)
	passwordBox.BackgroundTransparency = 1
	passwordBox.PlaceholderText = "暗証番号を入力..."
	passwordBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
	passwordBox.Text = ""
	passwordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	passwordBox.TextSize = IS_MOBILE and 20 or 18
	passwordBox.Font = Enum.Font.Gotham
	passwordBox.TextXAlignment = Enum.TextXAlignment.Left
	passwordBox.ClearTextOnFocus = false
	passwordBox.Parent = passwordFrame
	
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleVisibility"
	toggleBtn.Size = UDim2.new(0, IS_MOBILE and 48 or 40, 0, IS_MOBILE and 48 or 40)
	toggleBtn.Position = UDim2.new(1, IS_MOBILE and -54 or -45, 0.5, IS_MOBILE and -24 or -20)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	toggleBtn.AutoButtonColor = false
	toggleBtn.Text = "👁"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = IS_MOBILE and 20 or 16
	toggleBtn.Font = Enum.Font.Gotham
	toggleBtn.Parent = passwordFrame
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, IS_MOBILE and 12 or 8)
	toggleCorner.Parent = toggleBtn
	
	local authButton = Instance.new("TextButton")
	authButton.Name = "AuthButton"
	authButton.Size = UDim2.new(1, -40, 0, IS_MOBILE and 60 or 50)
	authButton.Position = UDim2.new(0, 20, 0, IS_MOBILE and 235 or 215)
	authButton.BackgroundColor3 = Settings.UIColor
	authButton.AutoButtonColor = false
	authButton.Text = "認証を開始"
	authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	authButton.TextSize = IS_MOBILE and 22 or 20
	authButton.Font = Enum.Font.GothamBold
	authButton.Parent = scrollFrame
	
	local authCorner = Instance.new("UICorner")
	authCorner.CornerRadius = UDim.new(0, IS_MOBILE and 14 or 10)
	authCorner.Parent = authButton
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(1, -40, 0, IS_MOBILE and 60 or 50)
	messageLabel.Position = UDim2.new(0, 20, 0, IS_MOBILE and 315 or 285)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = ""
	messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	messageLabel.TextSize = IS_MOBILE and 17 or 16
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextWrapped = true
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top
	messageLabel.Parent = scrollFrame
	
	local passwordVisible = false
	
	toggleBtn.MouseButton1Click:Connect(function()
		passwordVisible = not passwordVisible
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		if passwordVisible then
			passwordBox.TextTransparency = 0
			local tween = TweenService:Create(toggleBtn, tweenInfo, {
				BackgroundColor3 = Settings.UIColor,
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})
			tween:Play()
			toggleBtn.Text = "👁‍🗨"
		else
			passwordBox.TextTransparency = 0
			local tween = TweenService:Create(toggleBtn, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(40, 40, 50),
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})
			tween:Play()
			toggleBtn.Text = "👁"
		end
	end)
	
	CreateButtonAnimation(authButton)
	CreateButtonAnimation(toggleBtn)
	
	if IS_MOBILE then
		passwordBox.Focused:Connect(function()
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(scrollFrame, tweenInfo, {
				CanvasPosition = Vector2.new(0, 100)
			})
			tween:Play()
		end)
		
		passwordBox.FocusLost:Connect(function()
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(scrollFrame, tweenInfo, {
				CanvasPosition = Vector2.new(0, 0)
			})
			tween:Play()
		end)
	end
	
	local function ProcessAuth()
		local input = passwordBox.Text
		
		if input == "" then
			messageLabel.Text = "⚠️ 暗証番号を入力してください"
			messageLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
			return
		end
		
		authAttempts = authAttempts + 1
		
		if input == SECURITY_PASSWORD then
			messageLabel.Text = "✅ 認証成功！UIを読み込み中..."
			messageLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local tween1 = TweenService:Create(AuthWindow, tweenInfo, {
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, -authWidth / 2, 0.5, -authHeight / 2 - 50)
			})
			local tween2 = TweenService:Create(shadow, tweenInfo, {
				ImageTransparency = 1
			})
			tween1:Play()
			tween2:Play()
			
			tween1.Completed:Connect(function()
				if AuthWindow then
					AuthWindow:Destroy()
					AuthWindow = nil
				end
				-- 元のコードのCreateMainWindow()をここで呼び出す
				print("✅ 認証成功 - メインUIを作成してください")
			end)
		else
			messageLabel.Text = string.format("❌ 認証失敗 (%d/%d)\n暗証番号が正しくありません", authAttempts, MAX_AUTH_ATTEMPTS)
			messageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			
			local originalPos = AuthWindow.Position
			for i = 1, 8 do
				AuthWindow.Position = UDim2.new(
					originalPos.X.Scale,
					originalPos.X.Offset + math.random(-10, 10),
					originalPos.Y.Scale,
					originalPos.Y.Offset + math.random(-5, 5)
				)
				RunService.RenderStepped:Wait()
			end
			AuthWindow.Position = originalPos
			
			passwordBox.Text = ""
			
			if authAttempts >= MAX_AUTH_ATTEMPTS then
				messageLabel.Text = "🚫 試行回数制限に達しました\nUIがロックされました"
				authButton.Text = "ロックアウト"
				authButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				authButton.Active = false
				passwordBox.Active = false
				toggleBtn.Active = false
				
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(AuthWindow, tweenInfo, {
					BackgroundColor3 = Color3.fromRGB(30, 15, 15)
				})
				tween:Play()
			end
		end
	end
	
	authButton.MouseButton1Click:Connect(ProcessAuth)
	
	passwordBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and authAttempts < MAX_AUTH_ATTEMPTS then
			ProcessAuth()
		end
	end)
	
	if not IS_MOBILE then
		CreateSmoothDrag(AuthWindow, AuthWindow)
	end
	
	return AuthWindow
end

-- 初期化
CreateAuthWindow()

-- デバッグメッセージ
print("⚡ Arseus x Neo UI v3.0 - モバイル対応認証システム loaded!")
print("🔒 Security Password: しゅーくりーむ")
print("📱 Device: " .. (IS_MOBILE and "Mobile ✓" or IS_DESKTOP and "Desktop" or "Console"))
print("📱 Mobile optimizations:")
print("  - Larger touch targets (48-60px)")
print("  - Keyboard auto-scroll")
print("  - Optimized text sizes")
print("  - Improved spacing for touch")
print("")
print("💡 Note: この認証システムのみモバイル最適化されています")
print("💡 元のコードのCreateMainWindow()以降の関数をそのまま追加してください")
