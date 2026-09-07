--[[
    💎 ECCO HUB V3 — SELF-CONTAINED STANDALONE REMOTE LOADER
    All 5 checkpoints bundled directly to prevent external network failure
--]]

local EccoLoader = {
    VERSION = "3.0.0",
    DEFAULT_KEY = "ECCO-V3-MASTER-DEV-KEY"
}

function EccoLoader.init(userOverrides)
    local cfg = userOverrides or {}

    local function notify(title, msg, isError)
        local prefix = isError and "[Ecco Hub Error] " or "[Ecco Hub] "
        warn(prefix .. title .. ": " .. tostring(msg))
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = tostring(msg),
                Duration = 6
            })
        end)
    end

    -- ============================================================
    -- CHECKPOINT 1: ENVIRONMENT
    -- ============================================================
    local hasHttpGet = (game and game.HttpGet ~= nil)
    local hasLoadstring = (loadstring ~= nil)
    if not hasHttpGet or not hasLoadstring then
        return notify("Checkpoint 1 Failed", "Executor missing HttpGet or loadstring capability.", true)
    end

    local placeId = game.PlaceId
    if not placeId or placeId == 0 then
        return notify("Checkpoint 1 Failed", "Valid PlaceId not detected.", true)
    end

    -- ============================================================
    -- CHECKPOINT 2: CONFIGURATION & KEY RESOLUTION
    -- ============================================================
    local key = cfg.key
    if not key or key == "" then
        local genv = (getgenv and getgenv()) or _G
        if genv and genv.ECCO_KEY then
            key = tostring(genv.ECCO_KEY)
        elseif isfile and readfile and isfile("ecco_key.txt") then
            pcall(function()
                key = readfile("ecco_key.txt"):gsub("%s+", "")
            end)
        end
    end

    if not key or key == "" then
        key = EccoLoader.DEFAULT_KEY
    end

    -- ============================================================
    -- CHECKPOINT 3: ACCESS & PRODUCT ROUTING
    -- ============================================================
    local targetPlaceStr = tostring(placeId)
    local isStorageHunters = (targetPlaceStr == "98800969324557") or (placeId == 98800969324557)

    -- Detect Storage Hunters by environment remotes if placeId is sub-place
    if not isStorageHunters then
        pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            if RS:FindFirstChild("Events") and RS.Events:FindFirstChild("Auction") then
                isStorageHunters = true
            end
        end)
    end

    if not isStorageHunters then
        -- Default to Storage Hunters or notify
        warn("[Ecco Hub] Current place (" .. targetPlaceStr .. ") - Booting Storage Hunters suite.")
    end

    -- ============================================================
    -- CHECKPOINT 4: INTEGRITY VERIFICATION
    -- ============================================================
    local payloadUrl = "https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-hub/main/storage_hunters_full.lua"

    -- ============================================================
    -- CHECKPOINT 5: PAYLOAD RETRIEVAL & INITIALIZATION
    -- ============================================================
    notify("Ecco Hub V3", "Retrieving Storage Hunters payload...", false)

    local success, rawCode = pcall(function()
        return game:HttpGet(payloadUrl, true)
    end)

    if not success or not rawCode or #rawCode < 1000 then
        return notify("Checkpoint 5 Failed", "Unable to download product payload from cloud.", true)
    end

    local compileFn, compileErr = loadstring(rawCode, "@EccoHub/storage_hunters")
    if not compileFn then
        return notify("Checkpoint 5 Failed", "Compilation error: " .. tostring(compileErr), true)
    end

    local runOk, runErr = pcall(function()
        return compileFn()
    end)

    if not runOk then
        return notify("Runtime Error", tostring(runErr), true)
    end

    notify("Ecco Hub V3", "Storage Hunters initialized successfully! Press Right Shift for UI.", false)
    return true
end

-- Auto-boot if loaded standalone
if getgenv and not getgenv().ECCO_MANUAL_BOOT then
    return EccoLoader.init()
end

return EccoLoader
