ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

local isPlacing = false
local cooldown = false

local function PlaceProp(model)
    if isPlacing then return end
    isPlacing = true

    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
    
    -- Carica il modello dell'oggetto
    lib.requestModel(model)

    -- Crea l'oggetto
    local object = CreateObject(model, coords.x, coords.y, coords.z, true, true)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(object), true)

    -- Rendi l'oggetto trasparente e disattiva le collisioni per farlo attraversare
    SetEntityAlpha(object, 150, false) -- 150 rende l'oggetto semitrasparente
    SetEntityCollision(object, false, true) -- Disattiva le collisioni
    
    -- Mostra textui
    lib.showTextUI('Premi E per posizionare l\'oggetto', {
        position = "top-center",
        icon = 'fa-solid fa-info-circle',
        style = {
            borderRadius = 0,
            backgroundColor = '#48BB78',
            color = 'white'
        }
    })

    -- Inizia il ciclo per far muovere il prop insieme al giocatore
    CreateThread(function()
        while isPlacing do
            -- Ottieni le coordinate del giocatore e aggiorna la posizione dell'oggetto
            coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
            SetEntityCoords(object, coords.x, coords.y, coords.z, false, false, false, true)
            SetEntityHeading(object, GetEntityHeading(playerPed))

            -- Verifica se il giocatore preme il tasto 'E' per finalizzare il posizionamento
            if IsControlJustPressed(0, 38) then -- Tasto E (default key code 38)
                -- Rendi l'oggetto solido e visibile al 100%
                SetEntityAlpha(object, 255, false) -- Rendi l'oggetto completamente visibile
                SetEntityCollision(object, true, true) -- Attiva le collisioni
                PlaceObjectOnGroundProperly(object)
                FreezeEntityPosition(object, true) -- Rendi l'oggetto immobile
                isPlacing = false
                lib.hideTextUI()
            end

            Wait(0)
        end
    end)
end

local function Cooldown()
    if cooldown then
        ShowNotification(Config.Locale.notifications.cooldown, 'error')
    else
        cooldown = true
        SetTimeout(4000, function()
            cooldown = false
        end)
        return true
    end
end

local jobs = {
    ['police'] = 0,
    ['sheriff'] = 0,
    ['sahp'] = 0,
    ['us_army'] = 0,
}

CreateThread(function()
    exports.ox_target:addModel({ `prop_roadcone02a`, `p_ld_stinger_s`, `prop_barrier_work05` }, {
        {
            name = 'remove_prop',
            icon = 'fa-solid fa-trash',
            label = 'Rimuovi oggetto',
            groups = jobs,
            onSelect = function(data)
                local tick = 0
                lib.progressCircle({
                    duration = 3500,
                    position = 'bottom',
                    label = 'Stai rimuovendo l\'oggetto',
                    useWhileDead = false,
                    canCancel = false,
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_player'
                    },
                    disable = {
                        move = true,
                        car = false
                    },
                })
                while not NetworkHasControlOfEntity(data.entity) and tick < 50 do
                    NetworkRequestControlOfEntity(data.entity)
                    tick = tick + 1
                    Wait(0)
                end
                DeleteEntity(data.entity)
            end
        }
    })
    lib.registerContext({
        id = 'pdprops',
        title = Config.Locale.menu.title,
        options = {
            {
                icon = 'triangle-exclamation',
                title = Config.Locale.menu.options.cone,
                onSelect = function()
                    if not Cooldown() then return end
                    PlaceProp(`prop_roadcone02a`)
                end
            },
            {
                icon = 'road-spikes',
                title = Config.Locale.menu.options.spikestrip,
                onSelect = function()
                    if not Cooldown() then return end
                    PlaceProp(`p_ld_stinger_s`)
                end
            },
            {
                icon = 'road-barrier',
                title = Config.Locale.menu.options.barrier,
                onSelect = function()
                    if not Cooldown() then return end
                    PlaceProp(`prop_barrier_work05`)
                end
            }
            
        }
    })
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, `p_ld_stinger_s`, false, false, false)
        if object ~= 0 then
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
    
                for i=0, 7, 1 do
                    if not IsVehicleTyreBurst(vehicle, i, true) then
                        SetVehicleTyreBurst(vehicle, i, true, 1000)
                    end
                end
            end
        end
        Wait(500)
    end
end)

RegisterKeyMapping(Config.Command, Config.RegisterKeyMapping.description, Config.RegisterKeyMapping.device, Config.RegisterKeyMapping.key)

RegisterCommand(Config.Command, function()
    if Config.Jobs[ESX.GetPlayerData().job.name] == nil then return end
    lib.showContext('pdprops')
end, false)