local bicycle = nil
local status = false
local attachedBikes = {}
local anim = {}
anim.animDict = 'amb@prop_human_seat_chair_mp@male@generic@base';
anim.animName = 'base';
anim.speed = 2;
anim.flag = 1;


function LoadAnimation(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end
RegisterKeyMapping('attachbike', 'Attach bike', 'keyboard', 'g')

local firstSpawn = true
AddEventHandler('playerSpawned', function()
    if not firstSpawn then
        TriggerServerEvent("lucid-attachbike:server:RequestData")
        firstSpawn = true
    end
end)

RegisterCommand("attachbike", function()
    
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
        return
    end
    if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 then
        return
    end

    bicycle = nil
    local vehicle, dist = GetNearestVehicle()

    if vehicle == nil then  
        return
    end
    
    if dist == -1 or dist > 2.0 then
        return    
    end
    
    local vehClass = GetVehicleClass(vehicle)
    if vehClass ~= 13 then 
        return  
    end

    if status then
        DetachEntity(PlayerPedId(), false, true)
        local coords = GetEntityCoords(PlayerPedId())
        SetEntityCoords(PlayerPedId(), coords.x+1.0, coords.y+1.0, coords.z-1.0)
        ClearPedTasks(PlayerPedId())
        status = false
        TriggerServerEvent("lucid-attachbike:server:SetBikeData", NetworkGetNetworkIdFromEntity(vehicle), false)
    else
        if attachedBikes[NetworkGetNetworkIdFromEntity(vehicle)] then
            return
        end 
        
        if GetEntityModel(vehicle) == GetHashKey("cruiser") then
            bicycle = vehicle
           AttachEntityToEntity(PlayerPedId(), bicycle,   0, 0, -0.7, 0.2, -10, 0, 0, true, false, false, false, 0, true)
        end 
        if GetEntityModel(vehicle) == GetHashKey("bmx") then
            bicycle = vehicle
           AttachEntityToEntity(PlayerPedId(), bicycle,   0, 0, 0.2, 0.6, 0, 0, 0, true, false, false, false, 0, true) 
        end 
        if GetEntityModel(vehicle) == GetHashKey("scorcher") then
            bicycle = vehicle
            AttachEntityToEntity(PlayerPedId(), bicycle,  0, 0, 0.35, 0.45, 0, 0, 0, true, false, false, false, 0, true)
        end
        if bicycle ~= nil then
            LoadAnimation(anim.animDict)
            TaskPlayAnim(PlayerPedId(), anim.animDict, anim.animName, 3.0, 3.0, -1, 1, 0, false, false, false)
            status = true
            TriggerServerEvent("lucid-attachbike:server:SetBikeData", NetworkGetNetworkIdFromEntity(vehicle), true)
        end
    end
end)

RegisterNetEvent("lucid-attachbike:client:SyncData")
AddEventHandler("lucid-attachbike:client:SyncData", function(data)
    attachedBikes = data
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if bicycle == nil then
            if status then
                DetachEntity(PlayerPedId(), true, false)
                status = false
            end
        else 
            if not DoesEntityExist(bicycle) then
                if status then
                    DetachEntity(PlayerPedId(), true, false)
                    status = false
                end
            end
        end
    end
end)

function GetNearestVehicle()
    local vehicles = GetGamePool("CVehicle")
    local closestDist = -1
    local closestEntity = nil
    local Player = PlayerPedId()
    for _,vehicle in pairs(vehicles) do
        local dist = #(GetEntityCoords(Player) - GetEntityCoords(vehicle))
        if closestDist == -1 or dist < closestDist then
            closestEntity = vehicle
            closestDist = dist
        end
    end
    return closestEntity, closestDist
end




