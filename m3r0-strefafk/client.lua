
local isInAFKZone = false
local afkZoneCoords = vector3(1731.4688720703, 3314.5307617188, 41.223472595215)
local afkZoneRadius = 30.0
local afkTimer = 600  -- 10 minut
local afkBlip

-- Funkcja do wyświetlania timera na środku u góry ekranu
local function displayAFKTimer()
    if isInAFKZone then
        local minutes = math.floor(afkTimer / 60)
        local seconds = afkTimer % 60
        local displayText = string.format("AFK Timer: %02d:%02d", minutes, seconds)
        
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.5)
        SetTextColour(255, 255, 255, 255) -- Biały kolor tekstu
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(displayText)
        DrawText(0.5, 0.1) -- Pozycja (0.5, 0.1) to środek u góry ekranu
    end
end

-- Funkcja rysująca promień strefy AFK na szaro
local function drawAFKZone()
    DrawMarker(1, afkZoneCoords.x, afkZoneCoords.y, afkZoneCoords.z - 1.0, 0, 0, 0, 0, 0, 0, afkZoneRadius * 2.0, afkZoneRadius * 2.0, 1.0, 150, 150, 150, 100, false, false, 2, false, nil, nil, false)
end

-- Dodanie blipu na mapie dla strefy AFK
Citizen.CreateThread(function()
    afkBlip = AddBlipForCoord(afkZoneCoords.x, afkZoneCoords.y, afkZoneCoords.z)
    SetBlipSprite(afkBlip, 310)
    SetBlipDisplay(afkBlip, 4)
    SetBlipScale(afkBlip, 0.8)
    SetBlipColour(afkBlip, 5)
    SetBlipAsShortRange(afkBlip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Strefa AFK")
    EndTextCommandSetBlipName(afkBlip)
end)

-- Blokowanie akcji w strefie i wyświetlanie timera
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInAFKZone then
            DisableControlAction(0, 24, true)  -- Blokada strzelania
            DisableControlAction(0, 25, true)  -- Blokada celowania
            DisableControlAction(0, 37, true)  -- Blokada otwierania koła wyboru broni
            DisablePlayerFiring(PlayerPedId(), true)  -- Blokada oddawania strzałów
            DisableControlAction(0, 142, true) -- Blokada walki wręcz
            ResetPlayerStamina(PlayerId()) -- Reset wytrzymałości

            displayAFKTimer()
        end
        drawAFKZone()
    end
end)

-- Sprawdzanie pozycji gracza i czy jest w strefie
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPos = GetEntityCoords(PlayerPedId())
        
        if #(playerPos - afkZoneCoords) < afkZoneRadius then
            if not isInAFKZone then
                isInAFKZone = true
                TriggerServerEvent('M3R0_AFK:enterZone')
            end
        else
            if isInAFKZone then
                isInAFKZone = false
                afkTimer = 600
                TriggerServerEvent('M3R0_AFK:exitZone')
            end
        end

        if isInAFKZone then
            afkTimer = afkTimer - 1
            if afkTimer <= 0 then
                TriggerServerEvent('M3R0_AFK:reward')
                afkTimer = 600
            end
        end
    end
end)

-- Funkcja wyświetlająca pasek postępu i sprawdzająca ruch
local function showCancelableProgressBar(duration)
    local startTime = GetGameTimer()
    local startPos = GetEntityCoords(PlayerPedId())
    while (GetGameTimer() - startTime) < duration do
        Citizen.Wait(0)
        local progress = (GetGameTimer() - startTime) / duration
        DrawRect(0.5, 0.9, 0.3, 0.03, 0, 0, 0, 150) -- Tło paska
        DrawRect(0.5 - (0.3 / 2) + (0.3 * progress) / 2, 0.9, 0.3 * progress, 0.03, 0, 255, 0, 200) -- Pasek postępu

        local currentPos = GetEntityCoords(PlayerPedId())
        if #(startPos - currentPos) > 0.5 then -- Jeśli gracz się poruszył
            return false
        end
    end
    return true
end

-- Obsługa teleportacji komendą z wymaganiem pozostania w miejscu na 5 sekund
RegisterCommand('strefafk', function()
    local success = showCancelableProgressBar(5000) -- Wyświetlanie paska postępu przez 5 sekund
    if not success then
        return
    end
    SetEntityCoords(PlayerPedId(), afkZoneCoords.x, afkZoneCoords.y, afkZoneCoords.z)
end, false)

-- Obsługa nieśmiertelności
RegisterNetEvent('M3R0_AFK:setInvincible')
AddEventHandler('M3R0_AFK:setInvincible', function(state)
    SetEntityInvincible(PlayerPedId(), state)
end)
