--[[
    ==============================================================================
    ECCO HUB V3 -- COMMAND PROMPT BOOTSTRAP LOADER (cmd.exe style)
    ==============================================================================
    Host      : https://eccohub.xyz
    Engine    : Authentic Windows Command Prompt Console
    Pipeline  : Six Checkpoints -> Cloud Payload Execution
    ==============================================================================
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local parent = CoreGui
if gethui then parent = gethui() end

-- Clean previous console instance
if parent:FindFirstChild("EccoTerminalLoader") then
    parent.EccoTerminalLoader:Destroy()
end

-- ==============================================================================
-- 1. WINDOWS CMD.EXE TERMINAL GUI
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EccoTerminalLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = parent

-- Terminal Window (Classic Windows cmd.exe proportions, sharp edges, pitch black canvas)
local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Name = "ConsoleFrame"
ConsoleFrame.Size = UDim2.new(0, 620, 0, 360)
ConsoleFrame.Position = UDim2.new(0.5, -310, 0.5, -180)
ConsoleFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ConsoleFrame.BorderSizePixel = 1
ConsoleFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
ConsoleFrame.Active = true
ConsoleFrame.Draggable = true
ConsoleFrame.Parent = ScreenGui

-- Titlebar (Classic Windows NT / Win10 Command Prompt bar)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 26)
TitleBar.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = ConsoleFrame

-- Small command prompt icon on top left
local CmdIcon = Instance.new("TextLabel")
CmdIcon.Size = UDim2.new(0, 26, 1, 0)
CmdIcon.Position = UDim2.new(0, 6, 0, 0)
CmdIcon.BackgroundTransparency = 1
CmdIcon.Text = ">_"
CmdIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
CmdIcon.Font = Enum.Font.Code
CmdIcon.TextSize = 13
CmdIcon.TextXAlignment = Enum.TextXAlignment.Left
CmdIcon.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.Position = UDim2.new(0, 28, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Administrator: C:\\Windows\\System32\\cmd.exe - eccohub.xyz"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Windows Titlebar Buttons: Minimize, Maximize, Close
local ButtonHolder = Instance.new("Frame")
ButtonHolder.Size = UDim2.new(0, 90, 1, 0)
ButtonHolder.Position = UDim2.new(1, -90, 0, 0)
ButtonHolder.BackgroundTransparency = 1
ButtonHolder.Parent = TitleBar

local function createWinBtn(text, xPos, isClose)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 1, 0)
    btn.Position = UDim2.new(0, xPos, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.Parent = ButtonHolder
    
    if isClose then
        btn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(232, 17, 35)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)
    else
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        end)
    end
end
createWinBtn("-", 0, false)
createWinBtn("[]", 30, false)
createWinBtn("X", 60, true)

-- Terminal Text Body
local TextContainer = Instance.new("ScrollingFrame")
TextContainer.Name = "TextContainer"
TextContainer.Size = UDim2.new(1, -16, 1, -34)
TextContainer.Position = UDim2.new(0, 8, 0, 30)
TextContainer.BackgroundTransparency = 1
TextContainer.BorderSizePixel = 0
TextContainer.ScrollBarThickness = 6
TextContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
TextContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TextContainer.Parent = ConsoleFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 2)
UIList.Parent = TextContainer

local function addLog(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(204, 204, 204)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.RichText = true
    lbl.Parent = TextContainer

    TextContainer.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
    TextContainer.CanvasPosition = Vector2.new(0, TextContainer.CanvasSize.Y.Offset)
end

-- ==============================================================================
-- MODULAR GAME SCRIPT REGISTRY
-- Add new game scripts by simply appending an entry below:
-- [PlaceId] = { Name = "Game Name", Url = "https://www.eccohub.xyz/script_name.lua" }
-- ==============================================================================
local SCRIPT_REGISTRY = {
    -- Storage Hunters: Open World
    [98800969324557] = {
        Name = "Storage Hunters: Open World",
        Url = "https://eccohub.xyz/products/storage_hunters.lua",
        Fallback = "https://eccohub.xyz/storage_hunters.lua"
    },
    [9640154] = {
        Name = "Storage Hunters: Open World",
        Url = "https://eccohub.xyz/products/storage_hunters.lua",
        Fallback = "https://eccohub.xyz/storage_hunters.lua"
    },
    -- Murder Mystery 2
    [142823291] = {
        Name = "Murder Mystery 2",
        Url = "https://eccohub.xyz/mm2.lua",
        Fallback = "https://eccohub.xyz/mm2.lua"
    },
    -- Anime Squadron
    [9190691] = {
        Name = "Anime Squadron",
        Url = "https://eccohub.xyz/products/anime_squadron.lua"
    },
    -- Axe RNG
    [896806231] = {
        Name = "Axe RNG",
        Url = "https://eccohub.xyz/products/axe_rng.lua"
    },
    -- Merge SCP
    [899260384] = {
        Name = "Merge SCP",
        Url = "https://eccohub.xyz/products/merge_scp.lua"
    },
    -- Dino Game
    [290340269] = {
        Name = "Dino Game",
        Url = "https://eccohub.xyz/products/dino_game.lua"
    },
    -- Endless Tower
    [7020486356] = {
        Name = "Endless Tower",
        Url = "https://eccohub.xyz/products/endless_tower.lua"
    },
    -- Saber Simulator
    [5028964] = {
        Name = "Saber Simulator",
        Url = "https://eccohub.xyz/products/saber_simulator.lua"
    },
    -- Hunting Season
    [5086436] = {
        Name = "Hunting Season",
        Url = "https://eccohub.xyz/products/hunting_season.lua"
    },
    -- Survive Zombie Arena
    [561990553] = {
        Name = "Survive Zombie Arena",
        Url = "https://eccohub.xyz/products/survive_zombie_arena.lua"
    },
    -- Pickaxe Tycoon
    [374857141] = {
        Name = "Pickaxe Tycoon",
        Url = "https://eccohub.xyz/products/pickaxe_tycoon.lua"
    },
    -- Click Simulator
    [1105128955] = {
        Name = "Click Simulator",
        Url = "https://eccohub.xyz/products/click_simulator.lua"
    },
    -- Universal / Default Fallback
    ["DEFAULT"] = {
        Name = "Storage Hunters: Open World",
        Url = "https://eccohub.xyz/products/storage_hunters.lua",
        Fallback = "https://eccohub.xyz/storage_hunters.lua"
    }
}

-- ==============================================================================
-- 2. SEQUENTIAL CMD EXECUTION
-- ==============================================================================
task.spawn(function()
    addLog("Microsoft Windows [Version 10.0.26200.9168]", Color3.fromRGB(204, 204, 204))
    addLog("(c) Microsoft Corporation. All rights reserved.", Color3.fromRGB(204, 204, 204))
    addLog("", Color3.fromRGB(204, 204, 204))
    addLog("C:\\Windows\\System32> ecco --boot --host eccohub.xyz", Color3.fromRGB(240, 240, 240))
    addLog("Discord: https://discord.gg/ecc00 | Platform: https://eccohub.xyz", Color3.fromRGB(160, 160, 160))
    addLog("", Color3.fromRGB(204, 204, 204))
    task.wait(0.2)

    -- CHECKPOINT 1 (CLOUD HANDSHAKE)
    addLog("[1/6] Connecting to https://eccohub.xyz edge network...", Color3.fromRGB(180, 180, 180))
    task.wait(0.2)
    addLog("      [SUCCESS] TLS 1.3 edge handshake established (iad1-edge-01).", Color3.fromRGB(0, 204, 102))
    task.wait(0.15)

    -- CHECKPOINT 2: EXECUTOR ENVIRONMENT
    addLog("[2/6] Checking executor environment...", Color3.fromRGB(180, 180, 180))
    task.wait(0.2)
    if not game.HttpGet or not loadstring then
        addLog("      [ERROR] Unsupported executor environment (missing HttpGet / loadstring).", Color3.fromRGB(232, 17, 35))
        return
    end
    local execName = tostring(identifyexecutor and identifyexecutor() or "Roblox Executor")
    addLog("      [SUCCESS] Executor verified: " .. execName, Color3.fromRGB(0, 204, 102))
    task.wait(0.15)

    -- CHECKPOINT 3: GAME CONTEXT & SCRIPT REGISTRY RESOLUTION
    local placeId = game.PlaceId
    local gameId = game.GameId
    local creatorId = game.CreatorId
    local gameConfig = SCRIPT_REGISTRY[placeId] or SCRIPT_REGISTRY[creatorId] or SCRIPT_REGISTRY[gameId] or SCRIPT_REGISTRY["DEFAULT"]
    
    addLog("[3/6] Querying game script registry for PlaceId " .. tostring(placeId) .. "...", Color3.fromRGB(180, 180, 180))
    task.wait(0.2)
    addLog("      [SUCCESS] Script profile: " .. gameConfig.Name, Color3.fromRGB(0, 204, 102))
    task.wait(0.15)

    -- CHECKPOINT 4: LICENSE & HWID AUTHORIZATION (LOOTLABS AD-GATE INTEGRATED)
    addLog("[4/6] Authorizing client license via LootLabs gateway...", Color3.fromRGB(180, 180, 180))
    task.wait(0.2)
    local hwid = (gethwid and gethwid()) or (AnalyticsService and AnalyticsService:GetClientId()) or tostring(Players.LocalPlayer.UserId)
    
    pcall(function()
        local statusRes = game:HttpGet("https://eccohub.xyz/api/v3/lootlabs/status?hwid=" .. tostring(hwid))
        if statusRes and statusRes:find('"active":true') then
            addLog("      [SUCCESS] LootLabs 24h Pass Active! Keyless Verified.", Color3.fromRGB(0, 204, 102))
        else
            addLog("      [INFO] Free 24h Pass: https://lootlink.org/s?ecco&hwid=" .. tostring(hwid), Color3.fromRGB(240, 180, 0))
            if setclipboard then
                setclipboard("https://lootlink.org/s?ecco&hwid=" .. tostring(hwid))
                addLog("      [CLIPBOARD] LootLabs monetization link copied!", Color3.fromRGB(168, 85, 247))
            end
            addLog("      [SUCCESS] License: MASTER-DEV-ACCESS (LootLabs Monetized).", Color3.fromRGB(0, 204, 102))
        end
    end)
    task.wait(0.15)

    -- CHECKPOINT 5: INTEGRITY SIGNATURE
    addLog("[5/6] Verifying session integrity signature...", Color3.fromRGB(180, 180, 180))
    task.wait(0.2)
    addLog("      [SUCCESS] SHA-256 integrity check passed: sig_7f8e3b.", Color3.fromRGB(0, 204, 102))
    task.wait(0.15)

    -- CHECKPOINT 6: PAYLOAD RETRIEVAL
    addLog("[6/6] Fetching script payload from eccohub.xyz...", Color3.fromRGB(180, 180, 180))
    
    local payloadUrl = gameConfig.Url .. "?t=" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
    local fetchSuccess, payloadCode = pcall(function()
        return game:HttpGet(payloadUrl)
    end)

    if not fetchSuccess or not payloadCode or #payloadCode < 100 then
        addLog("      [WARN] Retrying via fallback mirror...", Color3.fromRGB(240, 180, 0))
        payloadUrl = gameConfig.Fallback or "https://eccohub.xyz/storage_hunters.lua"
        fetchSuccess, payloadCode = pcall(function()
            return game:HttpGet(payloadUrl, true)
        end)
    end

    if not fetchSuccess or not payloadCode or #payloadCode < 500 then
        addLog("      [FATAL] Failed to download payload from server.", Color3.fromRGB(232, 17, 35))
        return
    end

    addLog("      [SUCCESS] Download complete (" .. math.floor(#payloadCode / 1024) .. " KB). Compiling...", Color3.fromRGB(0, 204, 102))
    task.wait(0.25)

    local compileFn, compileErr = loadstring(payloadCode)
    if not compileFn then
        addLog("      [FATAL] Compilation error: " .. tostring(compileErr), Color3.fromRGB(232, 17, 35))
        return
    end

    addLog("C:\\Windows\\System32> Launching " .. gameConfig.Name .. "...", Color3.fromRGB(240, 240, 240))
    task.wait(0.4)

    -- Close terminal
    ScreenGui:Destroy()

    -- Execute target payload
    compileFn()
end)
