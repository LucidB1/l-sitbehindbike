local attachedBikes = {}

RegisterServerEvent('l-sitbehindbike:server:SetBikeData')
AddEventHandler('l-sitbehindbike:server:SetBikeData', function(networkid, val)
    attachedBikes[networkid] = val
    TriggerClientEvent("l-sitbehindbike:client:SyncData", -1, attachedBikes)
end)

RegisterServerEvent('l-sitbehindbike:server:RequestData')
AddEventHandler('l-sitbehindbike:server:RequestData', function()
    TriggerClientEvent("l-sitbehindbike:client:SyncData", -1, attachedBikes)
end)