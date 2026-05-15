local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('pickaxe', function(source)
	TriggerClientEvent('thd_maden:eleKazma', source)
end)

RegisterNetEvent('thd_maden:givekaya', function()
	local src = source
    print("[thd_maden] GiveKaya triggered for source: " .. src)
	local added = exports.ox_inventory:AddItem(src, 'stone', 1)
    if not added then
        print("[thd_maden] Failed to add stone to source: " .. src .. " (inventory full?)")
    end
end)

RegisterNetEvent('thd_maden:giveToken', function(count)
	local src = source
    print("[thd_maden] GiveToken triggered for source: " .. src .. " count: " .. count)
	exports.ox_inventory:AddItem(src, 'token', count)
end)

RegisterNetEvent('thd_maden:givePara', function(tokenmik, mik)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    
    if exports.ox_inventory:GetItemCount(src, 'token') >= tokenmik then
        exports.ox_inventory:RemoveItem(src, 'token', tokenmik)
        Player.Functions.AddMoney('cash', mik)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Yeterli tokenin yok.', 'error')
    end
end)

RegisterNetEvent('thd_maden:kayalariver', function()
	local src = source
    local count = exports.ox_inventory:GetItemCount(src, 'stone')

	if count > 0 then
		exports.ox_inventory:RemoveItem(src, 'stone', count)
		TriggerClientEvent('thd_maden:tokensayac', src, count * Config.KayaBasinaTokenMik)
        TriggerClientEvent('QBCore:Notify', src, 'Kayaları eritmeye bıraktın.', 'success')
		TriggerClientEvent('thd_maden:verchance', src, true)
	else
        TriggerClientEvent('QBCore:Notify', src, 'Üstünde taş yok.', 'error')
	end
end)

RegisterNetEvent('thd_maden:arac', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	
	if Player.Functions.GetMoney('cash') >= Config.aracfiyat then
		Player.Functions.RemoveMoney('cash', Config.aracfiyat)
		TriggerClientEvent('thd_maden:AracOlustur', src)
	else
        TriggerClientEvent('QBCore:Notify', src, 'Yeterli paran yok.', 'error')
	end
end)

RegisterNetEvent('thd_maden:paraver', function(returnedPlate)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	Player.Functions.AddMoney('cash', Config.aracfiyat)
    
    -- Remove the specific key for this vehicle when returned
    if returnedPlate then
        local items = exports.ox_inventory:Search(src, 'slots', 'vehicle_key')
        if items then
            for _, item in pairs(items) do
                if item.metadata and item.metadata.plate == returnedPlate then
                    exports.ox_inventory:RemoveItem(src, 'vehicle_key', 1, nil, item.slot)
                    break
                end
            end
        end
    end
end)

RegisterNetEvent('thd_maden:server:GiveKey', function(plate)
    local src = source
    local meta = {
        plate = plate,
        description = "Plaka: " .. plate .. " | Kiralık Maden Aracı"
    }
    exports.ox_inventory:AddItem(src, 'vehicle_key', 1, meta)
end)
