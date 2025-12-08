local function GetRayfield()
    print("Initiating Rayfield Download...")
    -- **修正：チェックと遅延を削除**
    local RayfieldLoader = loadstring(G:HttpGet("https://raw.githubusercontent.com/Rayfield-Official/Script/master/Rayfield.lua"))()
    
    if RayfieldLoader and RayfieldLoader.CreateWindow then
        print("Rayfield Loaded successfully.")
        return RayfieldLoader
    else
        warn("Rayfield failed to load or returned nil.")
        return nil
    end
end

-- 認証ロジック内の確認を強化:
task.spawn(function()
    local Rayfield = GetRayfield() 
    if not Rayfield then 
        warn("UIロード失敗：Rayfieldが取得できませんでした。")
        return 
    end
    -- ... (以下のモジュールロードに進む)
end)
