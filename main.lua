-- ServerScriptService内に配置
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- RemoteEventを作成
local LagEvent = Instance.new("RemoteEvent")
LagEvent.Name = "LagEvent"
LagEvent.Parent = ReplicatedStorage

LagEvent.OnServerEvent:Connect(function(player, action, params)
    if action == "simulate_lag" then
        -- 実行者を除外
        local excludePlayer = params.excludePlayer
        
        -- 他の全プレイヤーに疑似ラグを発生
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= excludePlayer then
                -- ここで各プレイヤーにラグをシミュレート
                -- 注意: 実際に悪影響を与える処理は実装しないでください
                
                -- 安全な通知のみ送信
                local clientNotify = ReplicatedStorage:FindFirstChild("NotifyClient")
                if clientNotify then
                    clientNotify:FireClient(otherPlayer, "サーバー負荷検出", "接続が不安定です", 5)
                end
            end
        end
    end
end)
