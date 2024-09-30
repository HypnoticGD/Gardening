local QBCore = exports['qb-core']:GetCoreObject()

local isOnJob = false
local currentMarker = 1
local mower = nil
local blip = nil -- To store the single blip handle

local blips = {
    {title="Greenkeeper", colour=43, id=469, x = -1332.39, y = 33.99, z = 53.57},
}

Citizen.CreateThread(function()

    for _, info in pairs(blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 0.9)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local startDistance = GetDistanceBetweenCoords(playerCoords, Config.StartJobCoords.x, Config.StartJobCoords.y, Config.StartJobCoords.z, true)
        local endDistance = GetDistanceBetweenCoords(playerCoords, Config.JobEndCoords.x, Config.JobEndCoords.y, Config.JobEndCoords.z, true)

        -- Handle start job marker
        if not isOnJob and startDistance < 5.0 then
            DrawMarker(1, Config.StartJobCoords.x, Config.StartJobCoords.y, Config.StartJobCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)

            if startDistance < 2.0 then
                -- Show 3D text near the start marker
                DrawText3D(Config.StartJobCoords.x, Config.StartJobCoords.y, Config.StartJobCoords.z, "[E] INTERAGIEREN")
                -- Debug message to check if player is in proximity
                --[[ print("Player is near the start marker") ]]
                
                -- Capture keypress for 'E'
                if IsControlJustPressed(1, 38) then -- Using control group 1 instead of 0
                    print("E key pressed, starting job")
                    TriggerEvent('gardening:startJob')
                end
            end
        end

        -- Handle end job marker
        if isOnJob and endDistance < 5.0 then
            DrawMarker(1, Config.JobEndCoords.x, Config.JobEndCoords.y, Config.JobEndCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)

            if endDistance < 2.0 then
                -- Show 3D text near the end marker
                DrawText3D(Config.JobEndCoords.x, Config.JobEndCoords.y, Config.JobEndCoords.z, "[E] INTERAGIEREN")
                -- Debug message to check if player is in proximity
                print("Player is near the end marker")
                
                -- Capture keypress for 'E'
                if IsControlJustPressed(1, 38) then -- Using control group 1 instead of 0
                    print("E key pressed, finishing job")
                    finishJob()
                end
            end
        end
    end
end)



-- Starting the gardening job
RegisterNetEvent('gardening:startJob')
AddEventHandler('gardening:startJob', function()
    if not isOnJob then
        isOnJob = true
        currentMarker = 1
        spawnMowerAtLocation() -- Spawns the mower at predefined locations from config.lua
        exports['cdn-fuel']:SetFuel(mower, 99.9)
        setNextMarker()
        updateBlipForMarker(Config.Markers[currentMarker]) -- Create initial blip

        QBCore.Functions.Notify("INFORMATION", "Arbeit angetreten, Fahren zu die den Makierungen auf der map!", 5000)
    end
end)

function spawnMowerAtLocation()
    if mower == nil then -- Ensures that we don't spawn a second mower if one already exists
        local vehicleModel = GetHashKey(Config.MowerModel)

        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Citizen.Wait(100)
        end

        -- Select a random spawn location from the predefined set in config.lua
        local spawnLocation = Config.MowerSpawnLocations[math.random(#Config.MowerSpawnLocations)]
        local x, y, z, heading = table.unpack(spawnLocation)

        -- Spawn the mower at the selected location
        mower = CreateVehicle(vehicleModel, x, y, z, heading, true, false)

        -- Warp the player into the mower
        --[[ TaskWarpPedIntoVehicle(PlayerPedId(), mower, -1) ]]

        -- Give player the keys to the vehicle
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(mower))
    end
end

-- Function to create or update the blip at the current marker
function updateBlipForMarker(marker)
    if blip ~= nil then
        RemoveBlip(blip) -- Remove the existing blip
    end

    blip = AddBlipForCoord(marker.x, marker.y, marker.z)
    SetBlipSprite(blip, 1) -- Blip number (1 = circle)
    SetBlipColour(blip, 7) -- Blip color (7 = violet)
    SetBlipScale(blip, 0.8) -- Adjust blip size as needed
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mowing Marker")
    EndTextCommandSetBlipName(blip)
end

-- Setting the next marker
function setNextMarker()
    if currentMarker <= #Config.Markers then
        local marker = Config.Markers[currentMarker]
        updateBlipForMarker(marker) -- Update blip position to the current marker
        createMarker(marker)
    else
        -- Reset markers after completing all and allow continuous mowing
        currentMarker = 1
        setNextMarker() -- Loop back to the first marker after finishing all
    end
end

-- Creating a marker for mowing
function createMarker(position)
    local notified = false -- Flag to track if the player has been notified about the wrong vehicle

    Citizen.CreateThread(function()
        while isOnJob and currentMarker <= #Config.Markers do
            Citizen.Wait(0)
            DrawMarker(1, position.x, position.y, position.z - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false) -- Get the current vehicle player is in

            -- Check if player is near the marker
            if GetDistanceBetweenCoords(playerCoords, position.x, position.y, position.z, true) < 3.0 then
                if playerVehicle == mower then
                    -- Player reached the marker while in the correct vehicle
                    currentMarker = currentMarker + 1
                    setNextMarker() -- Set the next marker in the sequence
                    TriggerServerEvent('gardening:payForMarker') -- Pay player for reaching the marker
                    break
                elseif not notified then
                    -- Notify the player once if they are not in the correct vehicle
                    QBCore.Functions.Notify("INFORMATION", "Du musst das richtige Fahrzeug benutzen, um die Markierung zu sammeln!", 5000)
                    notified = true -- Set the flag so the notification only shows once
                end
            else
                -- Reset the notified flag if the player moves away from the marker
                notified = false
            end
        end
    end)
end

-- Helper function to draw 3D text at specified coordinates
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
    ClearDrawOrigin()
end

-- Finishing the job (player decides when to clock out)
function finishJob()
    isOnJob = false
    currentMarker = 1

    if mower ~= nil then
        DeleteEntity(mower) -- Deletes the mower when the player ends the job
        mower = nil
    end

    -- Remove the blip if it's still present
    if blip ~= nil then
        RemoveBlip(blip)
        blip = nil
    end

    QBCore.Functions.Notify("INFORMATION", "Arbeit Erfolgreich Beendet", 5000)
    Citizen.Wait(1000)
end