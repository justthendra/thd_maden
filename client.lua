ESX				 = nil
kontrol          = 2000
kontrol2         = 2000
kazma            = false
local zone       = nil
local sayac      = 60
local anliktoken = 0
local alabilir   = false
local var        = false
local vehicle    = nil
sesler = { "rockhit1", "rockhit2", "rockhit3", "rockhit4"}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Create Blips
Citizen.CreateThread(function()
    for k,v in pairs(Config.Blips) do
        v.blip = AddBlipForCoord(v.Location, v.Location, v.Location)
        SetBlipSprite(v.blip, v.id)
        SetBlipAsShortRange(v.blip, true)
	    BeginTextCommandSetBlipName("STRING")
        SetBlipColour(v.blip, 0)
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(v.blip)
    end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(kontrol) -- bozulursa 0 yap

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
                kontrol = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 180.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            else
                kontrol = 1000
            end
		end
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(kontrol2) -- bozulursa 0 yap

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones2) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 85.0) then
                kontrol2 = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 180.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            else
                kontrol2 = 2000
            end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(kontrol)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 3.0 then
                kontrol = 0
				isInMarker  = true
				currentZone = k
			end
		end

        for k,v in pairs(Config.Zones2) do
			if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 1.5 then
                kontrol2 = 0
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('thd_maden:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('thd_maden:hasExitedMarker', LastZone)
		end
        
	end
end)

function OpenMenu()
	local elements = {
		{label = "Araç al", value = 'aracal'},
        {label = "Token Sat", value = 'tokensat'},
        {label = "Araç koy", value = 'arackoy'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Madencilik', {
		title    = "Madencilik",
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'tokensat' then
			TokenVerMenu()
		elseif data.current.value == 'aracal' then
            AracOlustur()
        elseif data.current.value == 'arackoy' then
            AracSil()
		end
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('thd_maden:eleKazma')
AddEventHandler('thd_maden:eleKazma', function()
    eleKazma()
end)

function eleKazma()
    if kazma == false then
        kazma = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true) 
        AttachEntityToEntity(kazma, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 1, true)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
        TriggerEvent('thd_maden:vuramaz')
        TriggerEvent('thd_maden:vuramaz2')
        kazma = true
    else
        DetachEntity(kazma, 1, true)
        DeleteObject(kazma)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
        TriggerEvent('thd_maden:vuramaz')
        TriggerEvent('thd_maden:vuramaz2')
		kazma = false
    end
end

function AracOlustur()
    if vehicle == nil then
        TriggerServerEvent('thd_maden:arac')
    else
        exports['mythic_notify']:SendAlert('error', 'Zaten bir aracın var.', 5000)
    end
end

RegisterNetEvent('thd_maden:AracOlustur')
AddEventHandler('thd_maden:AracOlustur', function ()
    if vehicle == nil then
        local modelHash = GetHashKey("Rebel")
        RequestModel(modelHash)
        local isLoaded = HasModelLoaded(modelHash)
        while isLoaded == false do
            Citizen.Wait(100)
        end
        vehicle = CreateVehicle(modelHash, Config.AracSpawnCords, 145.50, 1, 0)
        plate = GetVehicleNumberPlateText(vehicle)
        exports['mythic_notify']:SendAlert('success', 'Araç kiralandı.', 5000)
    else
        exports['mythic_notify']:SendAlert('error', 'Zaten bir aracın var.', 5000)
    end
end)

function AracSil()
    if vehicle ~= nil then
        if plate == GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true)) then
            DeleteEntity(vehicle)
            DeleteVehicle(vehicle)
            ESX.Game.DeleteVehicle(vehicle)
            vehicle = nil
            exports['mythic_notify']:SendAlert('success', 'Araç teslim edildi.', 5000)
            TriggerServerEvent('thd_maden:paraver')
        else
            exports['mythic_notify']:SendAlert('inform', 'Araca binip tekrardan deneyin.', 5000)
        end
    end
end

RegisterNetEvent('thd_maden:vuramaz')
AddEventHandler('thd_maden:vuramaz', function()
    Citizen.CreateThread(function()
        while kazma do
            Citizen.Wait(0)
            DisablePlayerFiring(PlayerPedId(), true)
            if IsControlJustPressed(1,  346) then
                FreezeEntityPosition(PlayerPedId(), true)
                if currentBar ~= nil then
                    ESX.Streaming.RequestAnimDict("melee@large_wpn@streamed_core", function()
                        TaskPlayAnim(PlayerPedId(), "melee@large_wpn@streamed_core", "ground_attack_on_spot", 1.0, -1.0, 1000, 49, 1, false, false, false)
                        EnableControlAction(0, 32, true) -- w
                        EnableControlAction(0, 34, true) -- a
                        EnableControlAction(0, 8, true) -- s
                        EnableControlAction(0, 9, true) -- d
                        EnableControlAction(0, 22, true) -- space
                        EnableControlAction(0, 36, true) -- ctrl
                        EnableControlAction(0, 21, true) -- SHIFT
                        TriggerEvent('InteractSound_CL:PlayOnOne', sesler[ math.random( #sesler ) ], 0.3)
                        Citizen.Wait(1500)
                        DisablePlayerFiring(PlayerPedId(), true)
                        FreezeEntityPosition(PlayerPedId(), false)
                        DisablePlayerFiring(PlayerPedId(), true)
                        BarEkle()
                    end)
                else
                    DisablePlayerFiring(PlayerPedId(), true)
                    FreezeEntityPosition(PlayerPedId(), false)
                    exports['mythic_notify']:SendAlert('error', 'Yakında taş yok.', 5000)
                end
            end
        end
    end)
end)

RegisterNetEvent('thd_maden:vuramaz2')
AddEventHandler('thd_maden:vuramaz2', function()
    Citizen.CreateThread(function()
        while kazma do
            Citizen.Wait(0)
            DisablePlayerFiring(PlayerPedId(), true)
        end
    end)
end)

loadModel = function(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

function TokenVerMenu()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Token Satma', {
		title = "Satılacak Token Miktarı",
	}, function (data2, menu)
		local tokenMik = tonumber(data2.value)
		if tokenMik < 0 or tokenMik == nil then
			exports['mythic_notify']:SendAlert('error', 'Aynen şuan buga soktun.', 5000)
		else
            TriggerServerEvent('thd_maden:givePara', tokenMik, tokenMik * Config.BirTokenFiyat)
			menu.close()
		end
	end, function (data2, menu)
		menu.close()
	end)
end

function mesajGoster(msg, action)
    Citizen.CreateThread(function()
        while currentBar ~= nil do
            Citizen.Wait(0)
            SetTextComponentFormat('STRING')
			AddTextComponentString(msg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustPressed(1,  38) then
                if action == "tokenal" then
                    if var == true then
                        if alabilir == true then
                            alabilir = false
                            TriggerServerEvent('thd_maden:giveToken', anliktoken)
                            anliktoken = 0
                            var = false
                        else
                            exports['mythic_notify']:SendAlert('inform', "Tokenleri almak için " .. sayac .. " saniye beklemen lazım", 5000)
                        end
                    else
                        exports['mythic_notify']:SendAlert('error', 'Eritilen taş yok.', 5000)
                    end
                elseif action == "kayaver" then
                    ESX.Streaming.RequestAnimDict("amb@prop_human_bum_bin@idle_a", function()
                        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_a", "idle_a", 1.0, -1.0, 5000, 0, 1, true, true, true)
                        EnableControlAction(0, 32, true) -- w
                        EnableControlAction(0, 34, true) -- a
                        EnableControlAction(0, 8, true) -- s
                        EnableControlAction(0, 9, true) -- d
                        EnableControlAction(0, 22, true) -- space
                        EnableControlAction(0, 36, true) -- ctrl
                        Citizen.Wait(5000)
                        DisablePlayerFiring(PlayerPedId(), true)
                        FreezeEntityPosition(PlayerPedId(), false)
                        DisablePlayerFiring(PlayerPedId(), true)
                    end)
                    TriggerServerEvent('thd_maden:kayalariver')
                elseif action == "tokensat" then
                    OpenMenu()
                end
            end
        end
    end)
end

RegisterNetEvent('thd_maden:verchance')
AddEventHandler('thd_maden:verchance', function(bool)
    var = bool
end)

RegisterNetEvent('thd_maden:tokensayac')
AddEventHandler('thd_maden:tokensayac', function(itemsayi)
    sayac = Config.KayaEritmeSuresi
    while sayac > 0 do
        sayac = sayac - 1
        Citizen.Wait(1000)
    end
    exports['mythic_notify']:SendAlert('success', 'Tokenler alınmaya hazır.', 5000)
    anliktoken = itemsayi + anliktoken
    alabilir = true
end)

AddEventHandler('thd_maden:hasEnteredMarker', function(zone)
    currentBar = zone
    if (zone ~= "tokenal" and zone ~= "kayaver" and zone ~= "tokensat") then
        SetDisplay(zone, "block")
        kontrol = 0
    else
        for k,v in pairs(Config.Zones2) do
            if zone == k then
                mesajGoster(v.Message, k)
            end
		end
        kontrol2 = 0
    end
end)

AddEventHandler('thd_maden:hasExitedMarker', function(zone)
    closeAll()
    currentBar = nil
end)

RegisterNUICallback("kaya", function(data)
    if data.kaya then
        TriggerServerEvent('thd_maden:givekaya')
    end
end)

function SetDisplay(bar, bool)
    --SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = bar,
        status = bool,
    })
end

function BarEkle(zonee) 
    SendNUIMessage({
        type = "ekle",
        bar = currentBar,
    })
end

function closeAll()
    SendNUIMessage({
        type = "bar1",
        status = "none",
    })
    SendNUIMessage({
        type = "bar2",
        status = "none",
    })
    SendNUIMessage({
        type = "bar3",
        status = "none",
    })
    SendNUIMessage({
        type = "bar4",
        status = "none",
    })
    SendNUIMessage({
        type = "bar5",
        status = "none",
    })
    SendNUIMessage({
        type = "bar6",
        status = "none",
    })
end