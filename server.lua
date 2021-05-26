ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent("thd-tokensat")
AddEventHandler("thd-tokensat", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.removeInventoryItem(Config.Token, 1) then
    xPlayer.addMoney(15)
    end
end)

RegisterNetEvent("thd-araccikar")
AddEventHandler("thd-araccikar", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeMoney(200)
end)


RegisterNetEvent("thd-kaya")
AddEventHandler("thd-kaya", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem(Config.Kaya, 1)
end)

RegisterNetEvent("thd-taserit")
AddEventHandler("thd-taserit", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.removeInventoryItem(Config.Kaya, 1) then
    xPlayer.addInventoryItem(Config.Tas, 1)
    end
end)

RegisterNetEvent("thd-tokenal")
AddEventHandler("thd-tokenal", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.removeInventoryItem(Config.Tas, 1) then
        xPlayer.addInventoryItem(Config.Token, 1)
    end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		print('[^2thd-maden^0] - Başlatıldı!')
	end
end)