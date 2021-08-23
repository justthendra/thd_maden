ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('kazma', function(source)
	TriggerClientEvent('thd_maden:eleKazma', source)
end)


RegisterServerEvent('thd_maden:givekaya')
AddEventHandler('thd_maden:givekaya', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	local xItem = xPlayer.getInventoryItem("tas")

	xPlayer.addInventoryItem("tas", 1)
end)

RegisterServerEvent('thd_maden:giveToken')
AddEventHandler('thd_maden:giveToken', function(count)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addInventoryItem("token", count)
end)

RegisterServerEvent('thd_maden:givePara')
AddEventHandler('thd_maden:givePara', function(tokenmik, mik)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem("token", tokenmik)
	xPlayer.addMoney(mik)

end)

RegisterServerEvent('thd_maden:kayalariver')
AddEventHandler('thd_maden:kayalariver', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	local xItem = xPlayer.getInventoryItem("tas")

	if xItem.count > 0 then
		xPlayer.removeInventoryItem("tas", xItem.count)
		TriggerClientEvent('thd_maden:tokensayac', source, xItem.count * Config.KayaBasinaTokenMik)
		TriggerClientEvent('mythic_notify:SendAlert', "success", "Kayaları eritmeye bıraktın.", 3000)
		TriggerClientEvent('thd_maden:verchance', source, true)
	else
		TriggerClientEvent('mythic_notify:SendAlert', "error", "Üstünde Taş yok.", 3000)
	end
end)

RegisterServerEvent('thd_maden:arac')
AddEventHandler('thd_maden:arac', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if Config.aracfiyat < xPlayer.getMoney() then
		xPlayer.removeMoney(Config.aracfiyat)
		TriggerClientEvent('thd_maden:AracOlustur', _source)
	else
		TriggerClientEvent('mythic_notify:SendAlert', "error", "Yeterli Paranız yok", 4000)
	end
end)

RegisterServerEvent('thd_maden:paraver')
AddEventHandler('thd_maden:paraver', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	xPlayer.addMoney(Config.aracfiyat)
end)