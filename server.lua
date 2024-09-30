local QBCore = exports['qb-core']:GetCoreObject()

-- Server-side logic for handling payments
RegisterServerEvent('gardening:payForMarker')
AddEventHandler('gardening:payForMarker', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    
    if xPlayer then
        local paymentAmount = Config.Rewards.rewardPerMarker -- Use the reward value from config.lua
        xPlayer.Functions.AddMoney('cash', paymentAmount)
    end
end)