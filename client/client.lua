local QBCore = exports['qb-core']:GetCoreObject()

local holdingBoombox = false
local boomanimDict = "missheistdocksprep1hold_cellphone"
local boomanimName = "hold_cellphone"

Keys = {
    ['E'] = 38
}

RegisterNetEvent('3dsounds:client:attach', function(data)
    local net = data.object
    local index = data.index
    RequestAnimationDict("pickup_object")
    TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
    Citizen.Wait(1300)
    ClearPedTasks(PlayerPedId())
    local object = NetToObj(net)
    AttachEntityToEntity(object, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 57005), 0.30, 0, 0, 0, 260.0, 60.0, true, true, false, true, 1, true)
    holdingBoombox = true
    --carry(index)
    TriggerEvent("carryBoombox", net)
    TriggerEvent("holdingBoombox", net)
end)

RegisterNetEvent("carryBoombox")
AddEventHandler("carryBoombox", function(net)
    Citizen.CreateThread(function()
        while holdingBoombox do
            --print(Sounds[index].pos)
            local ped = PlayerPedId()
            local coords = GetEntityCoords(NetToObj(net))
            --local coords = GetEntityCoords(ped)
            --print(index)
            --if Sounds[net].playing then
                TriggerServerEvent("qb-boombox:server:updateCoords", net, coords)
            --end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent("holdingBoombox")
AddEventHandler("holdingBoombox", function(net)
	Citizen.CreateThread(function()
        local object = NetToObj(net)
        
        --print("ASDF")
		local alreadyEnteredZone = false
		while holdingBoombox do
			inZone  = true
            header = "Boombox"
            footer = ""
            icon = '<i class="fas fa-music"></i>'
            text = '<span style="color: green;">E</span> - Put down Boombox'
            if IsControlJustReleased(0, Keys["E"]) then
                holdingBoombox = false
                --DetachEntity(GLOBAL_PED, 1, true)
                --ClearPedTasks(GLOBAL_PED)
                inZone  = false
                RequestAnimationDict("pickup_object")
                TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
                Citizen.Wait(1300)
                ClearPedTasks(PlayerPedId())
                DetachEntity(object, true, true)
                PlaceObjectOnGroundProperly(object)
                FreezeEntityPosition(object, true)
                local coords = GetEntityCoords(NetToObj(net))
                TriggerServerEvent("qb-boombox:server:updateCoords", net, coords)
            end

			if inZone and not alreadyEnteredZone then
				TriggerEvent('mnm_notify_client:showNotification', icon, header, text, footer, true)
				alreadyEnteredZone = true
			end

			if not inZone and alreadyEnteredZone then
				TriggerEvent('mnm_notify_client:removeNotification', false)
				alreadyEnteredZone = false
			end
			Citizen.Wait(3)
		end
	end)
end)

RegisterNetEvent("3dsounds:client:changeSong")
AddEventHandler("3dsounds:client:changeSong", function(index)
    local coords = GetEntityCoords(PlayerPedId())
    
    TriggerServerEvent("3dsounds:server:serverStop", index)
    Citizen.Wait(1500)
    TriggerServerEvent("3dsounds:server:play3dsound", coords, "washedout", 1.0, 120)
end)

RegisterNetEvent("3dsounds:client:placeBoombox")
AddEventHandler("3dsounds:client:placeBoombox", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 0.5)
    RequestAnimationDict("pickup_object")
    TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
    Citizen.Wait(1300)
    ClearPedTasks(PlayerPedId())
    local object = CreateObject(GetHashKey('prop_boombox_01'), x, y, z, true, false, false)
    SetModelAsNoLongerNeeded(object)
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)

    exports['qb-target']:AddTargetEntity(object, {
        --debugPoly=true,
        options = {
            {
                name = "3dsounds_"..object, 
                type = "client",
                event = "qb-boombox:client:putAwayBoombox",
                icon = "fas fa-question",
                label = "Put Away",
                object = NetworkGetNetworkIdFromEntity(object),
            },
            {
                name = "3dsounds_"..object, 
                type = "client",
                event = "3dsounds:client:boomBoxMenu",
                icon = "fas fa-question",
                label = "Boombox Menu",
                object = NetworkGetNetworkIdFromEntity(object),
            },
            {
                name = "3dsounds_"..object, 
                type = "client",
                event = "3dsounds:client:attach",
                icon = "fas fa-question",
                label = "Pickup",
                object = NetworkGetNetworkIdFromEntity(object),
            },
            
        },
        distance = 5.0
    })
end)

RegisterNetEvent("3dsounds:client:boomBoxMenu")
AddEventHandler("3dsounds:client:boomBoxMenu", function(data)
    local object = data.object
    local menu = {
        {
            header = "Close",
            txt = 'Available Tapes',
            icon = "fas fa-angle-left",
            params = {
                event = "qb-menu:closeMenu",
            }
        }
    }

    for k, v in pairs(QBCore.Functions.GetPlayerData().items) do
        if Config.SongsList[v.name] ~= nil then
            menu[#menu+1] = {
                header = 'Play "' .. Config.SongsList[v.name]["song"] ..'"',
                txt = 'By ' .. Config.SongsList[v.name]["artist"],
                icon = "fas fa-hand-holding-dollar",
                params = {
                    event = "qb-boombox:client:playBoombox",
                    args = {
                        song = Config.SongsList[v.name]["file"],
                        object = data.object
                    }
                }
            }
        end
    end

    menu[#menu+1] = {
        header = 'Pause',
        txt = 'Pause the music',
        icon = "fas fa-hand-holding-dollar",
        params = {
            event = "qb-boombox:client:pauseBoombox",
            args = {
                object = data.object
            }
        }
    }
    menu[#menu+1] = {
        header = 'Resume',
        txt = 'Resume the music',
        icon = "fas fa-hand-holding-dollar",
        params = {
            event = "qb-boombox:client:resumeBoombox",
            args = {
                object = data.object
            }
        }
    }
    menu[#menu+1] = {
        header = 'Eject',
        txt = 'Eject the tape',
        icon = "fas fa-hand-holding-dollar",
        params = {
            event = "qb-boombox:client:stopBoombox",
            args = {
                object = data.object
            }
        }
    }
	exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("qb-boombox:client:playBoombox")
AddEventHandler("qb-boombox:client:playBoombox", function(data)
    local song = data.song
    local object = data.object
    local coords = GetEntityCoords(NetToObj(object))
    TriggerServerEvent("qb-boombox:server:playBoombox", coords, song, 0.6, 100, object)
end)

RegisterNetEvent("qb-boombox:client:resumeBoombox")
AddEventHandler("qb-boombox:client:resumeBoombox", function(object)
    TriggerServerEvent("qb-boombox:server:resumeBoombox", object)
end)

RegisterNetEvent("qb-boombox:client:stopBoombox")
AddEventHandler("qb-boombox:client:stopBoombox", function(object)
    TriggerServerEvent("qb-boombox:server:stopBoombox", object)
end)

RegisterNetEvent("qb-boombox:client:pauseBoombox")
AddEventHandler("qb-boombox:client:pauseBoombox", function(object)
    TriggerServerEvent("qb-boombox:server:pauseBoombox", object)
end)


RegisterNetEvent("qb-boombox:client:putAwayBoombox")
AddEventHandler("qb-boombox:client:putAwayBoombox", function(data)
    QBCore.Functions.TriggerCallback('qb-boombox:server:putAwayBoombox', function(result)
        if result then
            local net = data.object
            RequestAnimationDict("pickup_object")
            TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false )
            Citizen.Wait(1300)
            ClearPedTasks(PlayerPedId())
            local object = NetToObj(net)
            DeleteEntity(object)
            TriggerServerEvent("qb-boombox:server:stopBoombox", net)
        end
    end)
end)

function RequestAnimationDict(AnimDict)
    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do
        Citizen.Wait(1)
    end
end
