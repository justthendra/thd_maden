local QBCore = exports['qb-core']:GetCoreObject()
local kazma = false
local kazmaObj = nil
local currentZone = nil
local isMining = false
local sayac = 60
local anliktoken = 0
local alabilir = false
local var = false
local vehicle = nil
local plate = nil
local sesler = { "rockhit1", "rockhit2", "rockhit3", "rockhit4"}

-- Create Blips
Citizen.CreateThread(function()
    for k,v in pairs(Config.Blips) do
        local blip = AddBlipForCoord(v.Location)
        SetBlipSprite(blip, v.id)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Optimized Markers and Interaction using ox_lib Points
for k, v in pairs(Config.Zones) do
    local point = lib.points.new({
        coords = vector3(v.Pos.x, v.Pos.y, v.Pos.z),
        distance = 3.0,
    })

    function point:onEnter()
        currentZone = k
    end

    function point:onExit()
        currentZone = nil
    end

    function point:nearby()
        DrawMarker(v.Type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0, 180.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
        
        if kazma and not isMining and IsDisabledControlJustPressed(0, 346) then -- LMB with weapon disabled
            MiningAction()
        end
    end
end

for k, v in pairs(Config.Zones2) do
    local point = lib.points.new({
        coords = vector3(v.Pos.x, v.Pos.y, v.Pos.z),
        distance = 1.5,
    })

    function point:onEnter()
        lib.showTextUI(v.Message)
    end

    function point:onExit()
        lib.hideTextUI()
    end

    function point:nearby()
        DrawMarker(v.Type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0, 180.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
        
        if IsControlJustPressed(0, 38) then
            if k == "tokenal" then
                GetTokens()
            elseif k == "kayaver" then
                GiveRocks()
            elseif k == "tokensat" then
                OpenMinerMenu()
            elseif k == "aracteslim" then
                AracSil()
            end
        end
    end
end

function MiningAction()
    if not currentZone or isMining then return end
    isMining = true
    
    FreezeEntityPosition(PlayerPedId(), true)
    lib.requestAnimDict("melee@large_wpn@streamed_core")
    
    -- Play animation on a loop
    TaskPlayAnim(PlayerPedId(), "melee@large_wpn@streamed_core", "ground_attack_on_spot", 1.0, -1.0, -1, 1, 1, false, false, false)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', sesler[math.random(#sesler)], 0.3)
    
    SendNUIMessage({
        action = "startMinigame"
    })
    
    Citizen.CreateThread(function()
        while isMining do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 38) then -- E key
                SendNUIMessage({ action = "hit" })
                TriggerServerEvent('InteractSound_SV:PlayOnSource', sesler[math.random(#sesler)], 0.3)
                
                -- Play animation swing to give visual feedback
                TaskPlayAnim(PlayerPedId(), "melee@large_wpn@streamed_core", "ground_attack_on_spot", 1.0, -1.0, -1, 1, 1, false, false, false)
            end
            
            -- Press BACKSPACE or ESC to cancel
            if IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then
                SendNUIMessage({ action = "stopMinigame" })
            end
        end
    end)
end

function GetTokens()
    if var then
        if alabilir then
            alabilir = false
            TriggerServerEvent('thd_maden:giveToken', anliktoken)
            anliktoken = 0
            var = false
            QBCore.Functions.Notify('Tokenlar alındı.', 'success')
        else
            QBCore.Functions.Notify('Tokenların hazır olması için ' .. sayac .. ' saniye beklemelisin.', 'info')
        end
    else
        QBCore.Functions.Notify('Henüz eritilen taş yok.', 'error')
    end
end

function GiveRocks()
    lib.requestAnimDict("amb@prop_human_bum_bin@idle_a")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0, -1.0, 5000, 0, 1, true, true, true)
    
    if lib.progressBar({
        duration = 5000,
        label = 'Kayalar veriliyor...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
        },
    }) then
        TriggerServerEvent('thd_maden:kayalariver')
    else
        ClearPedTasks(PlayerPedId())
    end
end

function OpenMinerMenu()
    lib.registerContext({
        id = 'miner_menu',
        title = 'Madenci Menüsü',
        options = {
            {
                title = 'Araç Kirala',
                description = '500$ karşılığında araç kirala',
                icon = 'car',
                onSelect = function()
                    AracOlustur()
                end,
            },
            {
                title = 'Token Sat',
                description = 'Topladığın tokenları sat',
                icon = 'coins',
                onSelect = function()
                    TokenVerMenu()
                end,
            },
            {
                title = 'Aracı Teslim Et',
                description = 'Kiralık aracı geri ver',
                icon = 'truck-ramp-box',
                onSelect = function()
                    AracSil()
                end,
            },
        }
    })
    lib.showContext('miner_menu')
end

function TokenVerMenu()
    local input = lib.inputDialog('Token Satış', {
        {type = 'number', label = 'Satılacak Token Miktarı', description = 'Kaç adet satmak istiyorsun?', min = 1},
    })
 
    if not input then return end
    local tokenMik = input[1]
    
    TriggerServerEvent('thd_maden:givePara', tokenMik, tokenMik * Config.BirTokenFiyat)
end

function AracOlustur()
    if vehicle == nil then
        TriggerServerEvent('thd_maden:arac')
    else
        QBCore.Functions.Notify('Zaten bir aracın var.', 'error')
    end
end

RegisterNetEvent('thd_maden:AracOlustur', function()
    local model = `rebel`
    lib.requestModel(model)
    vehicle = CreateVehicle(model, Config.AracSpawnCords.x, Config.AracSpawnCords.y, Config.AracSpawnCords.z, 145.50, true, false)
    plate = GetVehicleNumberPlateText(vehicle)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    exports['LegacyFuel']:SetFuel(vehicle, 100.0) 
    
    TriggerServerEvent('thd_maden:server:GiveKey', plate)
    QBCore.Functions.Notify('Araç kiralandı ve anahtarı verildi.', 'success')
end)

function AracSil()
    if vehicle ~= nil then
        local currVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        if currVeh == vehicle then
            local tempPlate = plate -- Store plate before clearing
            QBCore.Functions.DeleteVehicle(vehicle)
            vehicle = nil
            plate = nil
            TriggerServerEvent('thd_maden:paraver', tempPlate)
            QBCore.Functions.Notify('Araç teslim edildi, depozito iade edildi.', 'success')
        else
            QBCore.Functions.Notify('Kiralanan aracın içinde olmalısın.', 'error')
        end
    end
end

RegisterNetEvent('thd_maden:eleKazma', function()
    if not kazma then
        kazmaObj = CreateObject(`prop_tool_pickaxe`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(kazmaObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 1, true)
        kazma = true
        QBCore.Functions.Notify('Kazma kuşanıldı. [LMB] ile kazabilirsin.', 'primary')
        
        -- Loop to disable firing while pickaxe is out
        Citizen.CreateThread(function()
            while kazma do
                DisablePlayerFiring(PlayerId(), true)
                Citizen.Wait(0)
            end
        end)
    else
        if kazmaObj then
            DeleteEntity(kazmaObj)
            kazmaObj = nil
        end
        kazma = false
        QBCore.Functions.Notify('Kazma kaldırıldı.', 'primary')
    end
end)

RegisterNetEvent('thd_maden:verchance', function(bool)
    var = bool
end)

RegisterNetEvent('thd_maden:tokensayac', function(itemsayi)
    sayac = Config.KayaEritmeSuresi
    Citizen.CreateThread(function()
        while sayac > 0 do
            sayac = sayac - 1
            Citizen.Wait(1000)
        end
        QBCore.Functions.Notify('Tokenlar alınmaya hazır!', 'success')
        anliktoken = itemsayi + anliktoken
        alabilir = true
    end)
end)

RegisterNUICallback("minigameResult", function(data, cb)
    isMining = false
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    
    if data.success then
        TriggerServerEvent('thd_maden:givekaya')
        QBCore.Functions.Notify('Başarıyla kazdın!', 'success')
    else
        QBCore.Functions.Notify('Kazma işlemi başarısız oldu.', 'error')
    end
    cb('ok')
end)
