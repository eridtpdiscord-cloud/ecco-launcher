--[[
    ECCO HUB V3 — High-Performance Game Router
    Community: https://discord.gg/ecc00
    CDN: https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/
--]]

local master_key, fetchFile = ...
local PlaceId = game.PlaceId
local CreatorId = game.CreatorId
local GameId = game.GameId

local ROUTE_MAP = {
    -- Storage Hunters: Open World
    ["storage_hunters"] = {
        places = {98800969324557},
        creators = {9640154},
        script = "products/storage_hunters.lua",
        name = "Storage Hunters: Open World"
    },
    -- Saber Simulator
    ["saber_simulator"] = {
        places = {3823781113, 3823781100},
        creators = {5028964},
        script = "products/saber_simulator.lua",
        name = "Saber Simulator"
    },
    -- Anime Squadron
    ["anime_squadron"] = {
        places = {},
        creators = {9190691},
        script = "products/anime_squadron.lua",
        name = "Anime Squadron"
    },
    -- Axe RNG
    ["axe_rng"] = {
        places = {},
        creators = {896806231},
        script = "products/axe_rng.lua",
        name = "Axe RNG"
    },
    -- Click Simulator
    ["click_simulator"] = {
        places = {},
        creators = {1105128955},
        script = "products/click_simulator.lua",
        name = "Click Simulator"
    },
    -- Survive Zombie Arena
    ["survive_zombie"] = {
        places = {},
        creators = {561990553},
        script = "products/survive_zombie_arena.lua",
        name = "Survive Zombie Arena"
    },
    -- Merge SCP
    ["merge_scp"] = {
        places = {},
        creators = {899260384},
        script = "products/merge_scp.lua",
        name = "Merge SCP"
    },
    -- Dino Game
    ["dino_game"] = {
        places = {},
        creators = {290340269},
        script = "products/dino_game.lua",
        name = "Dino Game"
    },
    -- Endless Tower
    ["endless_tower"] = {
        places = {},
        creators = {7020486356},
        script = "products/endless_tower.lua",
        name = "Endless Tower"
    },
    -- Hunting Season
    ["hunting_season"] = {
        places = {},
        creators = {5086436},
        script = "products/hunting_season.lua",
        name = "Hunting Season"
    },
    -- Pickaxe Tycoon
    ["pickaxe_tycoon"] = {
        places = {},
        creators = {374857141},
        script = "products/pickaxe_tycoon.lua",
        name = "Pickaxe Tycoon"
    },
    -- Sell Lemons
    ["sell_lemons"] = {
        places = {79268393072444},
        creators = {},
        script = "sell_lemons.lua",
        name = "Sell Lemons"
    },
    -- Murder Mystery 2
    ["mm2"] = {
        places = {142823291, 66654135, 18206581791},
        creators = {},
        script = "mm2.lua",
        name = "Murder Mystery 2"
    }
}

local matchedRoute = nil

for _, config in pairs(ROUTE_MAP) do
    for _, pid in ipairs(config.places) do
        if pid == PlaceId then
            matchedRoute = config
            break
        end
    end
    if not matchedRoute then
        for _, cid in ipairs(config.creators) do
            if cid == CreatorId then
                matchedRoute = config
                break
            end
        end
    end
    if matchedRoute then break end
end

if not matchedRoute then
    warn("[ecco] Current experience (PlaceId: " .. tostring(PlaceId) .. ", Creator: " .. tostring(CreatorId) .. ") not mapped in core catalog.")
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {
            Title = "Ecco Hub V3",
            Text = "Game not yet in active catalog. Join discord.gg/ecc00 to request!",
            Duration = 6
        })
    end)
    return
end

print("[ecco] Routing to " .. matchedRoute.name .. " (" .. matchedRoute.script .. ")")

local RAW_BASE = "https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/"
local WEB_BASE = "https://eccohub.xyz/api/script/"

local sourceCode = nil

-- Attempt 1: Raw GitHub CDN
local ok, code = pcall(function()
    return game:HttpGet(RAW_BASE .. matchedRoute.script, true)
end)
if ok and code and #code > 100 and not code:find("404: Not Found") then
    sourceCode = code
end

-- Attempt 2: Web Domain Fallback
if not sourceCode then
    local okWeb, codeWeb = pcall(function()
        return game:HttpGet(WEB_BASE .. matchedRoute.script .. "?key=" .. tostring(master_key or ""), true)
    end)
    if okWeb and codeWeb and #codeWeb > 100 and not codeWeb:find("404") then
        sourceCode = codeWeb
    end
end

if not sourceCode then
    warn("[ecco] Failed to load payload for " .. matchedRoute.name)
    return
end

local func, parseErr = loadstring(sourceCode)
if func then
    local res = func(master_key, master_key)
    if type(res) == "function" then
        res(master_key)
    end
else
    warn("[ecco] Compile error in " .. matchedRoute.name .. ": " .. tostring(parseErr))
end
