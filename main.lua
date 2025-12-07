-- Rayfield UI syu_u開発者専用版
-- セキュリティ: 特定のユーザーのみアクセス可能

-- 開発者情報の設定
local DEVELOPER_USERNAME = "syu_u"
local DEVELOPER_USERID = 123456789  -- syu_uさんの実際のUserIDに変更してください

-- アクセスチェック関数
local function checkDeveloperAccess()
    local player = game.Players.LocalPlayer
    
    -- ユーザー名とUserIDの両方をチェック
    if player.Name == DEVELOPER_USERNAME and player.UserId == DEVELOPER_USERID then
        return true
    end
    
    -- 追加のセキュリティチェック（オプション）
    if player:GetRankInGroup(グループID) >= 管理者ランク then
        return true
    end
    
    return false
end

-- アクセス権の確認
if not checkDeveloperAccess() then
    -- 非開発者向けのメッセージ
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "アクセス拒否",
        Text = "この機能はsyu_u開発者専用です。",
        Duration = 5,
        Icon = "rbxassetid://13450249313"
    })
    return
end

-- Rayfield UIの読み込み
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()

-- カスタムスタイルのウィンドウ作成
local Window = Rayfield:CreateWindow({
   Name = "🔧 syu_u 開発者ツール",
   LoadingTitle = "syu_u 開発者コンソール",
   LoadingSubtitle = "バージョン 2.0.1 | 開発者専用",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "syu_u_DevTools",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "syu_u Dev Suite",
      Subtitle = "キーを入力",
      Note = "開発者専用",
      FileName = "syu_uKey",
      SaveKey = false,
      GrabKeyFromSite = false,
   }
})

-- メインタブ
local MainTab = Window:CreateTab("🛠️ メイン", 13078546872)

-- 開発者情報セクション
local DevInfoSection = MainTab:CreateSection("👨‍💻 開発者情報")

-- 開発者情報表示
local DevInfoLabel = MainTab:CreateLabel("ユーザー: syu_u")
local UserIdLabel = MainTab:CreateLabel("ユーザーID: " .. game.Players.LocalPlayer.UserId)
local AccountAgeLabel = MainTab:CreateLabel("アカウント年齢: " .. game.Players.LocalPlayer.AccountAge .. "日")

-- サーバー管理セクション
local ServerSection = MainTab:CreateSection("🌐 サーバー管理")

-- サーバー情報表示
local PlayerCount = #game.Players:GetPlayers()
local ServerInfoLabel = MainTab:CreateLabel("プレイヤー数: " .. PlayerCount .. "/" .. game.Players.MaxPlayers)

-- サーバーダウン機能
local ServerDownButton = MainTab:CreateButton({
   Name = "🚨 サーバーダウン（疑似）",
   Callback = function()
       -- 確認ダイアログ
       Rayfield:Notify({
           Title = "確認",
           Content = "サーバーに疑似ダウンを実行しますか？",
           Duration = 6.5,
           Image = 13078546872,
           Actions = {
               Confirm = {
                   Name = "実行",
                   Callback = function()
                       executeServerDown()
                   end
               },
               Decline = {
                   Name = "キャンセル",
                   Callback = function()
                       Rayfield:Notify({
                           Title = "キャンセル",
                           Content = "操作をキャンセルしました",
                           Duration = 3,
                           Image = 13078546872
                       })
                   end
               }
           }
       })
   end
})

-- サーバーダウン実行関数
local function executeServerDown()
    -- 実行前のログ
    print("[syu_u DevTools] サーバーダウンシーケンスを開始...")
    
    -- 開発者への通知
    Rayfield:Notify({
        Title = "実行中",
        Content = "サーバー疑似ダウンを実行中...",
        Duration = 5,
        Image = 13078546872
    })
    
    -- エフェクトパート1: 画面エフェクト
    local lighting = game:GetService("Lighting")
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = lighting
    
    -- エフェクトアニメーション
    local TweenService = game:GetService("TweenService")
    local blurTween = TweenService:Create(blurEffect, TweenInfo.new(2), {Size = 24})
    blurTween:Play()
    
    -- サーバーメッセージのブロードキャスト
    local function broadcastMessage(message)
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                -- リモートイベントを使用した疑似通知
                pcall(function()
                    local RemoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DevToolsNotification")
                    if RemoteEvent then
                        RemoteEvent:FireClient(player, "⚠️ サーバー警告", message, 5)
                    end
                end)
            end
        end
    end
    
    -- 段階的なエフェクト
    local messages = {
        "サーバー負荷が上昇しています...",
        "接続が不安定です...",
        "サーバー応答が遅延しています...",
        "再接続を試みてください..."
    }
    
    -- 段階的な実行
    for i, message in ipairs(messages) do
        wait(1.5)
        broadcastMessage(message)
        
        -- 開発者への進捗報告
        Rayfield:Notify({
            Title = "進行中 (" .. i .. "/4)",
            Content = message,
            Duration = 2,
            Image = 13078546872
        })
    end
    
    -- エフェクトパート2: 最終エフェクト
    wait(1)
    
    -- 画面フラッシュ
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = lighting
    colorCorrection.TintColor = Color3.fromRGB(255, 150, 150)
    
    local flashTween = TweenService:Create(colorCorrection, TweenInfo.new(0.5), {TintColor = Color3.fromRGB(255, 255, 255)})
    flashTween:Play()
    
    -- 完了通知
    Rayfield:Notify({
        Title = "完了",
        Content = "サーバーダウンシーケンスが完了しました",
        Duration = 5,
        Image = 13078546872
    })
    
    -- クリーンアップ
    wait(3)
    blurEffect:Destroy()
    colorCorrection:Destroy()
    
    print("[syu_u DevTools] サーバーダウンシーケンス完了")
end

-- プレイヤー管理セクション
local PlayerSection = MainTab:CreateSection("👥 プレイヤー管理")

-- プレイヤーリスト
local playerDropdown = MainTab:CreateDropdown({
    Name = "プレイヤーを選択",
    Options = {},
    CurrentOption = "選択してください",
    Flag = "PlayerSelect",
    Callback = function(Option)
        _G.SelectedPlayer = Option
    end
})

-- プレイヤーリストの更新
local function updatePlayerList()
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    playerDropdown:Set(players)
end

-- 初期更新
updatePlayerList()

-- プレイヤー更新ボタン
local refreshButton = MainTab:CreateButton({
    Name = "🔄 プレイヤーリスト更新",
    Callback = function()
        updatePlayerList()
        Rayfield:Notify({
            Title = "更新完了",
            Content = "プレイヤーリストを更新しました",
            Duration = 2,
            Image = 13078546872
        })
    end
})

-- 開発ツールタブ
local ToolsTab = Window:CreateTab("⚙️ 開発ツール", 13078561973)

-- デバッグセクション
local DebugSection = ToolsTab:CreateSection("🐛 デバッグツール")

-- FPS表示
local FPSLabel = ToolsTab:CreateLabel("FPS: 測定中...")

-- FPS計測関数
local function measureFPS()
    local RunService = game:GetService("RunService")
    local fps = 0
    local frameCount = 0
    local lastTime = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = math.floor(frameCount / (currentTime - lastTime))
            frameCount = 0
            lastTime = currentTime
            FPSLabel:Set("FPS: " .. fps)
        end
    end)
end

-- FPS計測開始
measureFPS()

-- パフォーマンスモニター
local PerformanceButton = ToolsTab:CreateButton({
    Name = "📊 パフォーマンス診断",
    Callback = function()
        local memory = math.floor(collectgarbage("count") / 1024)
        Rayfield:Notify({
            Title = "パフォーマンス情報",
            Content = "メモリ使用量: " .. memory .. " MB\nインスタンス数: " .. #game:GetDescendants(),
            Duration = 5,
            Image = 13078561973
        })
    end
})

-- スクリプトタブ
local ScriptTab = Window:CreateTab("📜 スクリプト", 13078570453)

-- スクリプトセクション
local ScriptSection = ScriptTab:CreateSection("🚀 スクリプト実行")

-- スクリプト実行ボックス
local scriptInput = ScriptTab:CreateInput({
    Name = "スクリプトを入力",
    PlaceholderText = "ここにLuaコードを入力",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        _G.LastScript = Text
    end
})

-- スクリプト実行ボタン
local executeButton = ScriptTab:CreateButton({
    Name = "▶️ スクリプト実行",
    Callback = function()
        if _G.LastScript then
            local success, errorMsg = pcall(function()
                loadstring(_G.LastScript)()
            end)
            
            if success then
                Rayfield:Notify({
                    Title = "実行成功",
                    Content = "スクリプトが正常に実行されました",
                    Duration = 3,
                    Image = 13078570453
                })
            else
                Rayfield:Notify({
                    Title = "実行エラー",
                    Content = "エラー: " .. errorMsg,
                    Duration = 5,
                    Image = 13078570453
                })
            end
        else
            Rayfield:Notify({
                Title = "エラー",
                Content = "実行するスクリプトがありません",
                Duration = 3,
                Image = 13078570453
            })
        end
    end
})

-- 設定タブ
local SettingsTab = Window:CreateTab("⚙️ 設定", 13078575317)

-- UI設定セクション
local UISettings = SettingsTab:CreateSection("🎨 UI設定")

-- UIトグル
local UIToggle = SettingsTab:CreateToggle({
    Name = "UIを表示",
    CurrentValue = true,
    Flag = "UIToggle",
    Callback = function(Value)
        Window:Toggle(Value)
    end
})

-- UI透明度
local UITransparency = SettingsTab:CreateSlider({
    Name = "UI透明度",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 0,
    Flag = "UITransparency",
    Callback = function(Value)
        Window:SetTransparency(Value / 100)
    end
})

-- ログセクション
local LogSection = SettingsTab:CreateSection("📝 ログ")

-- ログクリアボタン
local clearLogsButton = SettingsTab:CreateButton({
    Name = "🗑️ ログをクリア",
    Callback = function()
        print("=== syu_u DevTools ログクリア ===")
        Rayfield:Notify({
            Title = "ログクリア",
            Content = "コンソールログをクリアしました",
            Duration = 3,
            Image = 13078575317
        })
    end
})

-- 初期化完了通知
wait(1)
Rayfield:Notify({
    Title = "syu_u 開発者ツール",
    Content = "開発者コンソールが起動しました\nユーザー: " .. game.Players.LocalPlayer.Name,
    Duration = 5,
    Image = 13078546872
})

print("[syu_u DevTools] 開発者ツールが正常に起動しました")
print("[syu_u DevTools] ユーザー: " .. game.Players.LocalPlayer.Name)
print("[syu_u DevTools] ユーザーID: " .. game.Players.LocalPlayer.UserId)
