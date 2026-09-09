--[[
    ECCO HUB — Game Router
--]]

local master_key, fetchFile = ...
local PlaceId = game.PlaceId
local targetScript = nil

local isSellLemons      = (tostring(PlaceId) == "79268393072444") or (PlaceId == 79268393072444)
local isLastLetter      = (tostring(PlaceId) == "129866685202296") or (PlaceId == 129866685202296)
local isStorageHunters  = (tostring(PlaceId) == "98800969324557") or (PlaceId == 98800969324557)
local isMergeANuke      = (tostring(PlaceId) == "128784467030899") or (PlaceId == 128784467030899)
local isScratchyLoot    = (tostring(PlaceId) == "78105732598311") or (PlaceId == 78105732598311)
local isLake            = (tostring(PlaceId) == "124786371598438") or (PlaceId == 124786371598438)
local isMM2             = (tostring(PlaceId) == "142823291") or (PlaceId == 142823291) or (tostring(PlaceId) == "66654135") or (PlaceId == 66654135) or (tostring(PlaceId) == "18206581791") or (PlaceId == 18206581791)

-- Fallback detection for games
if not isLastLetter and not isScratchyLoot and not isLake and not isMM2 then
    pcall(function()
        if game:GetService("ReplicatedStorage"):FindFirstChild("Constants") and
           game:GetService("ReplicatedStorage").Constants:FindFirstChild("Remotes") then
            isLastLetter = true
        elseif game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and
               game:GetService("ReplicatedStorage").Remotes:FindFirstChild("BotScratched") then
            isScratchyLoot = true
        elseif game:GetService("ReplicatedStorage"):FindFirstChild("VerdantRemotes") or
               game:GetService("ReplicatedStorage"):FindFirstChild("Verdant") then
            isLake = true
        elseif game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData") or
               game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Gameplay") then
            isMM2 = true
        end
    end)
end

local creatorId = game.CreatorId
local isAnimeSquadron   = (creatorId == 9190691)
local isAxeRNG          = (creatorId == 896806231)
local isMergeSCP        = (creatorId == 899260384)
local isDinoGame        = (creatorId == 290340269)
local isEndlessTower    = (creatorId == 7020486356)
local isSaberSim        = (creatorId == 5028964)
local isHuntingSeason   = (creatorId == 5086436)
local isSurviveZombie   = (creatorId == 561990553)
local isPickaxeTycoon   = (creatorId == 374857141)
local isClickSimulator  = (creatorId == 1105128955)

if isSellLemons then
    targetScript = "sell_lemons.lua"
elseif isLastLetter then
    targetScript = "last_letter.lua"
elseif isStorageHunters or (creatorId == 9640154) then
    targetScript = "products/storage_hunters.lua"
elseif isAnimeSquadron then
    targetScript = "products/anime_squadron.lua"
elseif isAxeRNG then
    targetScript = "products/axe_rng.lua"
elseif isMergeSCP then
    targetScript = "products/merge_scp.lua"
elseif isDinoGame then
    targetScript = "products/dino_game.lua"
elseif isEndlessTower then
    targetScript = "products/endless_tower.lua"
elseif isSaberSim then
    targetScript = "products/saber_simulator.lua"
elseif isHuntingSeason then
    targetScript = "products/hunting_season.lua"
elseif isSurviveZombie then
    targetScript = "products/survive_zombie_arena.lua"
elseif isPickaxeTycoon then
    targetScript = "products/pickaxe_tycoon.lua"
elseif isClickSimulator then
    targetScript = "products/click_simulator.lua"
elseif isMergeANuke then
    targetScript = "ecco_auto_merge.lua"
elseif isScratchyLoot then
    targetScript = "scratchy_loot.lua"
elseif isLake then
    targetScript = "ecco_lake.lua"
elseif isMM2 then
    targetScript = "mm2.lua"
end

local domain = "https://eccohub.xyz"

if targetScript then
    local url = domain .. "/api/script/" .. targetScript .. "?key=" .. tostring(master_key or "")
    local success, code = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not code or #code == 0 or code:find("404") then
        warn("[ecco] Failed to fetch game segment from website domain: " .. tostring(targetScript))
        return
    end
    local func, parseErr = loadstring(code)
    if func then
        local res = func(master_key, master_key)
        if type(res) == "function" then
            res(master_key)
        end
    else
        warn("[ecco] Failed to compile segment: " .. tostring(parseErr))
    end
else
    warn("[ecco] This place (" .. tostring(PlaceId) .. ") is not supported by Ecco Hub.")
end
