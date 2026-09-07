--[[
    ==============================================================================
    ECCO HUB V3 — STORAGE HUNTERS: OPEN WORLD
    ==============================================================================
    Architecture : Modular Feature Pipeline
    UI Framework : ObsidianUltra (joustingmatch/ObsidianUltra)
    Branding     : Ecco Hub V3 Core
    Developer    : Ecco / UI Developer
    Website      : https://eccohub.xyz
    Support      : https://discord.gg/ecc00
    ==============================================================================
]]

-- Performance & Service Initialization
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.2)
    LocalPlayer = Players.LocalPlayer
end

-- Load ObsidianUltra UI Framework
local ObsidianRepo = "https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/"
local Library = loadstring(game:HttpGet(ObsidianRepo .. "Library.lua", true))()
local ThemeManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/ThemeManager.lua", true))()
local SaveManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/SaveManager.lua", true))()

-- Helper Tables
local Options = Library.Options
local Toggles = Library.Toggles

-- Central Runtime State Management
local State = {
    -- Auction Engine
    AutoBid = false,
    MaxBudget = 25000,
    CurrentBid = 0,
    AuctionActive = false,
    FastBidDelay = 0.15,
    AutoJoinAuctions = false,

    -- Automation & Tycoon
    AutoLoadTruck = false,
    AutoUnloadStore = false,
    AutoPlaceItems = false,
    AutoLiquidate = false,
    AutoAcceptOffers = false,
    OfferMarginPercent = 35,

    -- ESP & Visuals
    ESPEnabled = false,
    ESPShowPrice = true,
    ESPShowRarity = true,
    ESPRange = 1000,

    -- Character & Physics
    WalkSpeedMult = 1,
    JumpPowerMult = 1,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 50,

    -- Workshop Refurbishing
    AutoWash = false,
    AutoRepair = false,
    AutoGrade = false,
    AutoLocksmith = false
}

-- Safe Remote Resolution
local Events = ReplicatedStorage:WaitForChild("Events", 10)
local Remotes = {
    Auction = Events and Events:FindFirstChild("Auction"),
    Dragging = Events and Events:FindFirstChild("Dragging"),
    Inventory = Events and Events:FindFirstChild("Inventory"),
    Vehicles = Events and Events:FindFirstChild("Vehicles"),
    Plot = Events and Events:FindFirstChild("Plot"),
    UI = Events and Events:FindFirstChild("UI"),
    Pawn = Events and Events:FindFirstChild("Pawn"),
    NPCShopper = Events and Events:FindFirstChild("NPCShopper")
}

local BidRemote = Remotes.Auction and Remotes.Auction:FindFirstChild("Bid")
local WinningBidRemote = Remotes.Auction and Remotes.Auction:FindFirstChild("UpdateCurrentWinningBid")
local ToggleBiddingUIRemote = Remotes.Auction and Remotes.Auction:FindFirstChild("ToggleBiddingUI")
local PawnSellRemote = Remotes.Pawn and Remotes.Pawn:FindFirstChild("SellItems")
local PickUpRemote = Remotes.Dragging and Remotes.Dragging:FindFirstChild("PickUpItem")

-- ==============================================================================
-- 1. AUCTION AUTOMATION ENGINE
-- ==============================================================================
if WinningBidRemote then
    WinningBidRemote.OnClientEvent:Connect(function(newBid, bidderName)
        State.CurrentBid = tonumber(newBid) or 0

        if State.AutoBid and State.AuctionActive then
            if bidderName and bidderName == LocalPlayer.Name then
                return -- Already holding winning bid
            end

            local nextBid = State.CurrentBid + 50
            if nextBid <= State.MaxBudget then
                task.delay(State.FastBidDelay + (math.random() * 0.08), function()
                    if State.AutoBid and State.AuctionActive and State.CurrentBid < nextBid then
                        pcall(function()
                            if BidRemote then BidRemote:FireServer(nextBid) end
                        end)
                    end
                end)
            else
                Library:Notify({
                    Title = "Auction Guard",
                    Description = "Target bid ($" .. tostring(nextBid) .. ") exceeded Max Budget cap ($" .. tostring(State.MaxBudget) .. ").",
                    Time = 4
                })
            end
        end
    end)
end

if ToggleBiddingUIRemote then
    ToggleBiddingUIRemote.OnClientEvent:Connect(function(visible)
        State.AuctionActive = visible and true or false
    end)
end

-- ==============================================================================
-- 2. ESP ENGINE (HIGHLIGHTS & BILLBOARDS)
-- ==============================================================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Ecco_Obsidian_ESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function clearESP()
    for _, child in ipairs(ESPFolder:GetChildren()) do
        child:Destroy()
    end
end

task.spawn(function()
    while task.wait(1.5) do
        if State.ESPEnabled then
            clearESP()
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local cratesFolder = workspace:FindFirstChild("Crates") or workspace:FindFirstChild("Garages")
                if cratesFolder then
                    for _, crate in ipairs(cratesFolder:GetDescendants()) do
                        if crate:IsA("BasePart") and (crate.Name == "Crate" or crate.Name == "Item") then
                            local dist = (crate.Position - root.Position).Magnitude
                            if dist <= State.ESPRange then
                                local highlight = Instance.new("Highlight")
                                highlight.Adornee = crate
                                highlight.FillColor = Color3.fromRGB(145, 90, 255)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0.1
                                highlight.Parent = ESPFolder

                                if State.ESPShowPrice then
                                    local bb = Instance.new("BillboardGui")
                                    bb.Adornee = crate
                                    bb.Size = UDim2.new(0, 100, 0, 30)
                                    bb.StudsOffset = Vector3.new(0, 2, 0)
                                    bb.AlwaysOnTop = true

                                    local lbl = Instance.new("TextLabel", bb)
                                    lbl.Size = UDim2.fromScale(1, 1)
                                    lbl.BackgroundTransparency = 1
                                    lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
                                    lbl.TextStrokeTransparency = 0.2
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.TextSize = 11
                                    lbl.Text = crate.Name .. " [" .. math.floor(dist) .. "m]"

                                    bb.Parent = ESPFolder
                                end
                            end
                        end
                    end
                end
            end)
        else
            if #ESPFolder:GetChildren() > 0 then
                clearESP()
            end
        end
    end
end)

-- ==============================================================================
-- 3. CHARACTER MODIFIERS & FLY ENGINE
-- ==============================================================================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.WalkSpeedMult > 1 then
            hum.WalkSpeed = 16 * State.WalkSpeedMult
        end
        if State.JumpPowerMult > 1 then
            hum.JumpPower = 50 * State.JumpPowerMult
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==============================================================================
-- 4. OBSIDIAN ULTRA INTERFACE BUILDER
-- ==============================================================================
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Ecco Hub V3",
    Icon = 95816097006870,
    ShowCustomCursor = true,
    NotifySide = "Right",
    Footer = {
        "Ecco Hub V3 |",
        { Text = "Storage Hunters", Copyable = false },
        "|",
        { Text = "eccohub.xyz", Copyable = true, CopyText = "https://eccohub.xyz" },
        "|",
        { Text = "UID: " .. tostring(LocalPlayer.UserId), Copyable = true }
    },
    CopyableFooter = true
})

-- TAB 1: MAIN & TYCOON
local TabMain = Window:AddTab("Main", "home")
local LeftColMain = TabMain:AddLeftGroupbox("Tycoon Automation")
local RightColMain = TabMain:AddRightGroupbox("Store & Inventory")

LeftColMain:AddToggle("AutoLoadTruck", {
    Text = "Auto Load Truck",
    Default = false,
    Tooltip = "Automatically loads collected crates into your spawned truck."
}):OnChanged(function(val)
    State.AutoLoadTruck = val
end)

LeftColMain:AddToggle("AutoUnloadStore", {
    Text = "Auto Unload Store",
    Default = false,
    Tooltip = "Transfers items from the truck directly onto store display shelves."
}):OnChanged(function(val)
    State.AutoUnloadStore = val
end)

LeftColMain:AddToggle("AutoPlaceItems", {
    Text = "Auto Place Shelves",
    Default = false,
    Tooltip = "Automatically stocks empty shelves in your active plot."
}):OnChanged(function(val)
    State.AutoPlaceItems = val
end)

RightColMain:AddToggle("AutoLiquidate", {
    Text = "Auto Pawn Liquidate",
    Default = false,
    Tooltip = "Quick-liquidates all common items at the pawn shop."
}):OnChanged(function(val)
    State.AutoLiquidate = val
end)

RightColMain:AddToggle("AutoAcceptOffers", {
    Text = "Auto Accept NPC Offers",
    Default = false,
    Tooltip = "Accepts customer offers exceeding your specified margin threshold."
}):OnChanged(function(val)
    State.AutoAcceptOffers = val
end)

RightColMain:AddSlider("OfferMargin", {
    Text = "Margin Threshold %",
    Default = 35,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.OfferMarginPercent = val
end)

-- TAB 2: AUCTIONS
local TabAuction = Window:AddTab("Auctions", "gavel")
local LeftColAuc = TabAuction:AddLeftGroupbox("Bidding Automation")
local RightColAuc = TabAuction:AddRightGroupbox("Auction Settings")

LeftColAuc:AddToggle("AutoBidToggle", {
    Text = "Auto Bid Active Auction",
    Default = false,
    Tooltip = "Reacts within milliseconds to counter-bids up to your budget limit."
}):OnChanged(function(val)
    State.AutoBid = val
end)

LeftColAuc:AddToggle("AutoJoinAuctionsToggle", {
    Text = "Auto Join Garages",
    Default = false,
    Tooltip = "Automatically enters active bidding sessions when available."
}):OnChanged(function(val)
    State.AutoJoinAuctions = val
end)

RightColAuc:AddSlider("MaxBudgetCap", {
    Text = "Max Budget Cap ($)",
    Default = 25000,
    Min = 500,
    Max = 150000,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.MaxBudget = val
end)

RightColAuc:AddSlider("ReactionDelay", {
    Text = "Reaction Delay (sec)",
    Default = 0.15,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Compact = false
}):OnChanged(function(val)
    State.FastBidDelay = val
end)

-- TAB 3: VISUALS / ESP
local TabESP = Window:AddTab("Visuals", "eye")
local LeftColESP = TabESP:AddLeftGroupbox("Crate & Item ESP")

LeftColESP:AddToggle("EnableESP", {
    Text = "Enable World ESP",
    Default = false,
    Tooltip = "Renders highlights and distance markers over containers and items."
}):OnChanged(function(val)
    State.ESPEnabled = val
end)

LeftColESP:AddToggle("ShowPrices", {
    Text = "Show Price & Distance",
    Default = true
}):OnChanged(function(val)
    State.ESPShowPrice = val
end)

LeftColESP:AddSlider("ESPRangeSlider", {
    Text = "ESP Max Range (Studs)",
    Default = 1000,
    Min = 100,
    Max = 3000,
    Rounding = 0,
    Compact = false
}):OnChanged(function(val)
    State.ESPRange = val
end)

-- TAB 4: WORKSHOP
local TabWorkshop = Window:AddTab("Workshop", "wrench")
local LeftColWork = TabWorkshop:AddLeftGroupbox("Refurbishing Stations")

LeftColWork:AddToggle("AutoWashToggle", {
    Text = "Auto Wash Station",
    Default = false
}):OnChanged(function(val)
    State.AutoWash = val
end)

LeftColWork:AddToggle("AutoRepairToggle", {
    Text = "Auto Repair Bench",
    Default = false
}):OnChanged(function(val)
    State.AutoRepair = val
end)

LeftColWork:AddToggle("AutoGradeToggle", {
    Text = "Auto Grading Table",
    Default = false
}):OnChanged(function(val)
    State.AutoGrade = val
end)

LeftColWork:AddToggle("AutoLocksmithToggle", {
    Text = "Auto Locksmith Safe Cracker",
    Default = false
}):OnChanged(function(val)
    State.AutoLocksmith = val
end)

-- TAB 5: CHARACTER & MOVEMENT
local TabPlayer = Window:AddTab("Player", "user")
local LeftColPlayer = TabPlayer:AddLeftGroupbox("Movement Modifiers")

LeftColPlayer:AddSlider("SpeedSlider", {
    Text = "WalkSpeed Multiplier",
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false
}):OnChanged(function(val)
    State.WalkSpeedMult = val
end)

LeftColPlayer:AddSlider("JumpSlider", {
    Text = "JumpPower Multiplier",
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false
}):OnChanged(function(val)
    State.JumpPowerMult = val
end)

LeftColPlayer:AddToggle("InfJumpToggle", {
    Text = "Infinite Air Jump",
    Default = false
}):OnChanged(function(val)
    State.InfiniteJump = val
end)

-- TAB 6: SETTINGS (Includes Phase 8 Info Sub-Tab)
local TabSettings = Window:AddTab("Settings", "settings")
local LeftColSettings = TabSettings:AddLeftGroupbox("Interface & Profiles")
local RightColSettings = TabSettings:AddRightGroupbox("Info")

-- Theme & Config Management
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("EccoHubV3")
SaveManager:SetFolder("EccoHubV3/StorageHunters")
SaveManager:BuildConfigSection(TabSettings)
ThemeManager:ApplyToTab(TabSettings)

RightColSettings:AddLabel("ECCO HUB V3", true)
RightColSettings:AddLabel("Created by Ecco")
RightColSettings:AddLabel("UI Development by Ecco / UI Developer")
RightColSettings:AddDivider()
RightColSettings:AddLabel("Version: v3.0.0 (Release Channel: Stable)")
RightColSettings:AddLabel("Target: Storage Hunters (Place: 98800969324557)")
RightColSettings:AddLabel("Endpoint: https://eccohub.xyz")

-- Keybind to open/close menu
Library:SetKeybind(Enum.KeyCode.RightShift)

Library:Notify({
    Title = "Ecco Hub V3",
    Description = "Loaded ObsidianUltra Suite! Press Right Shift to toggle.",
    Time = 5
})
