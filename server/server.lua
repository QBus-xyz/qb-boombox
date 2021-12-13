QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

QBCore.Functions.CreateUseableItem("boombox", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem('boombox', 1) then
        TriggerClientEvent('3dsounds:client:placeBoombox', src, item)
    end
end)

QBCore.Functions.CreateCallback('qb-boombox:server:putAwayBoombox', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.AddItem('boombox', 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['boombox'], "add")
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('qb-boombox:server:playBoombox')
AddEventHandler('qb-boombox:server:playBoombox', function(coords, song, volume, radius, object)
    local uniqueId = "boombox_"..tostring(object)
    exports['xyz-3dsound']:Play(coords, song, volume, radius, uniqueId)
end)

RegisterServerEvent('qb-boombox:server:pauseBoombox')
AddEventHandler('qb-boombox:server:pauseBoombox', function(object)
    local uniqueId = "boombox_"..tostring(object)
    exports['xyz-3dsound']:Pause(uniqueId)
end)

RegisterServerEvent('qb-boombox:server:resumeBoombox')
AddEventHandler('qb-boombox:server:resumeBoombox', function(object)
    local uniqueId = "boombox_"..tostring(object)
    exports['xyz-3dsound']:Resume(uniqueId)
end)

RegisterServerEvent('qb-boombox:server:stopBoombox')
AddEventHandler('qb-boombox:server:stopBoombox', function(object)
    local uniqueId = "boombox_"..tostring(object)
    exports['xyz-3dsound']:Delete(uniqueId)
end)

RegisterServerEvent('qb-boombox:server:updateCoords')
AddEventHandler('qb-boombox:server:updateCoords', function(object, coords)
    local uniqueId = "boombox_"..tostring(object)
    exports['xyz-3dsound']:UpdateCoords(uniqueId, coords)
end)

QBCore.Commands.Add("testsound", "Change your callsign", {}, false, function(source, args)
    local src = source
	local sourcePed = GetPlayerPed(src)
	local coords = GetEntityCoords(sourcePed)

    local song = 'washedout.ogg'
    local volume = 1.0
    local radius = 120

    exports['xyz-3dsound']:Play(coords, song, volume, radius, uniqueId)
end)