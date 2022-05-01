ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('kazma', function(source)
	TriggerClientEvent('cwl_maden:eleKazma', source)
end)


RegisterServerEvent('cwl_maden:givekaya')
AddEventHandler('cwl_maden:givekaya', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	local xItem = xPlayer.getInventoryItem("tas")

	xPlayer.addInventoryItem("tas", 1)
end)

RegisterServerEvent('cwl_maden:giveToken')
AddEventHandler('cwl_maden:giveToken', function(count)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addInventoryItem("token", count)
end)

RegisterServerEvent('cwl_maden:givePara')
AddEventHandler('cwl_maden:givePara', function(tokenmik, mik)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem("token", tokenmik)
	xPlayer.addMoney(mik)

end)

RegisterServerEvent('cwl_maden:kayalariver')
AddEventHandler('cwl_maden:kayalariver', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	local xItem = xPlayer.getInventoryItem("tas")

	if xItem.count > 0 then
		xPlayer.removeInventoryItem("tas", xItem.count)
		TriggerClientEvent('cwl_maden:tokensayac', source, xItem.count * Config.KayaBasinaTokenMik)
		TriggerClientEvent('mythic_notify:SendAlert', "success", "Kayaları eritmeye bıraktın.", 3000)
		TriggerClientEvent('cwl_maden:verchance', source, true)
	else
		TriggerClientEvent('mythic_notify:SendAlert', "error", "Üstünde Taş yok.", 3000)
	end
end)

RegisterServerEvent('cwl_maden:arac')
AddEventHandler('cwl_maden:arac', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if Config.aracfiyat < xPlayer.getMoney() then
		xPlayer.removeMoney(Config.aracfiyat)
		TriggerClientEvent('cwl_maden:AracOlustur', _source)
	else
		TriggerClientEvent('mythic_notify:SendAlert', "error", "Yeterli Paranız yok", 4000)
	end
end)

RegisterServerEvent('cwl_maden:paraver')
AddEventHandler('cwl_maden:paraver', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	xPlayer.addMoney(Config.aracfiyat)
end)
