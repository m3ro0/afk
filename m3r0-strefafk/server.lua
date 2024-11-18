ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Nagrody dla graczy
RegisterServerEvent('M3R0_AFK:reward')
AddEventHandler('M3R0_AFK:reward', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local reward = math.random(10000, 100000)
    xPlayer.addMoney(reward)
    TriggerClientEvent('esx:showNotification', source, 'Otrzymałeś ~g~' .. reward .. '$ ~s~za bycie w strefie AFK.')
end)

-- Obsługa wejścia do strefy (wysyłanie na klienta komendy ustawienia nieśmiertelności)
RegisterServerEvent('M3R0_AFK:enterZone')
AddEventHandler('M3R0_AFK:enterZone', function()
    TriggerClientEvent('M3R0_AFK:setInvincible', source, true)
    TriggerClientEvent('esx:showNotification', source, 'Wszedłeś do strefy AFK.')
end)

-- Obsługa wyjścia ze strefy (wysyłanie na klienta komendy wyłączenia nieśmiertelności)
RegisterServerEvent('M3R0_AFK:exitZone')
AddEventHandler('M3R0_AFK:exitZone', function()
    TriggerClientEvent('M3R0_AFK:setInvincible', source, false)
    TriggerClientEvent('esx:showNotification', source, 'Opuściłeś strefę AFK.')
end)
