--[[
    ==============================================================================
    ECCO HUB V3 — REMOTE CLOUD BOOTSTRAP
    ==============================================================================
    Product  : Storage Hunters: Open World (Place ID: 98800969324557)
    UI Engine: ObsidianUltra
    Host     : eccohub.xyz / Cloud Edge
    ==============================================================================
]]

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
end

notify("Ecco Hub V3", "Connecting to cloud backend...")

local cdnUrl = "https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-hub/main/storage_hunters_full.lua"

local ok, payload = pcall(function()
    return game:HttpGet(cdnUrl, true)
end)

if not ok or not payload or #payload < 500 then
    notify("Ecco Hub Error", "Failed to fetch cloud payload.")
    return
end

local compileFn, compileErr = loadstring(payload, "@EccoHubV3/StorageHunters")
if not compileFn then
    notify("Ecco Hub Error", "Compilation failure: " .. tostring(compileErr))
    return
end

compileFn()
