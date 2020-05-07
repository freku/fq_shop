local playersUpgrades = {} -- [id-gracza] = upgrades
local ESXs = exports['fq_callbacks']:getServerObject()
local items = {
    [1] = 6200,
    [2] = 6800,
    [3] = 156000,
    [4] = 158500,
    [5] = 162000,
    [6] = 155000,
    [7] = 157500,
    [8] = 160000,
    [9] = 158500,
    [10] = 156000,
    [11] = 161000,
    [12] = 159000,
    [13] = 155000,
    [14] = 6200,
    [15] = 8000,
    [16] = 7800,
    [17] = 7800,
    [18] = 7450,
    [19] = 9000,
    [20] = 8450,
    [21] = 6300,
    [22] = 2650,
    [23] = 3200,
    [24] = 2000,
    [25] = 2300,
    [26] = 2500,
    [27] = 1025,
    [28] = 950,
    car = 1250
}

local ups_ids = {
    [3] = {4,1},
    [4] = {4, 2},
    [5] = {4, 3},
    [6] = {4, 4},
    [7] = {1, 1},
    [8] = {1, 2},
    [9] = {2, 1},
    [10] = {2, 2},
    [11] = {2, 3},
    [12] = {3, 1},
    [13] = {3, 2},
}

-- RegisterNetEvent('fq:updateUpgradesOnSv')
-- AddEventHandler('fq:updateUpgradesOnSv', function(ups)
--     if type(ups) == 'table' and #ups == 4 then
--         playersUpgrades[source] = ups
--     end
-- end)

AddEventHandler('playerDropped', function()
    
end)

RegisterNetEvent('fq:playerLeftShop')
AddEventHandler('fq:playerLeftShop', function(src)
    if not exports['fq_essentials']:isCallerConsole(source) then return end

    local src = src

    if playersUpgrades[src] then
        playersUpgrades[src] = nil
    end
end)
    
RegisterNetEvent('fq:removeMoneyByItemID')
AddEventHandler('fq:removeMoneyByItemID', function(item)
    if items[item] then
        TriggerEvent('fq:removeMoney', items[item], source)
    end
end)

ESXs.RegisterServerCallback('fq:canBuyItem', function(source, cb, itemID, isUpgrade)
    local src_money = exports['fq_player']:getPlayerMoney(source)
    local canBuy = src_money >= items[itemID]

    if not src_money or not items[itemID] then
        return
    end

    if isUpgrade and playersUpgrades[source] then
        if not playersUpgrades[source][ups_ids[itemID][1]][ups_ids[itemID][2]] then
            if canBuy then
                playersUpgrades[source][ups_ids[itemID][1]][ups_ids[itemID][2]] = true;
            end
        end
    end

    cb(canBuy)
end)

function getSteamid(source)
    local player_steam_id = nil
    local ids = GetPlayerIdentifiers(source)
    for i, v in ipairs(ids) do
        if string.find(v, 'steam') then
            player_steam_id = v:sub(7)
            break
        end
    end
    
    return player_steam_id
end

function setPlayerUpgrades(src, upgradesString)
    local upsTable = json.decode(upgradesString)

    if type(upsTable) == 'table' and #upsTable == 4 then
        playersUpgrades[src] = upsTable
        return true
    end

    return false
end

function getPlayerUpgrades(src, asString)
    local upsString 
    
    if playersUpgrades[src] then
        upsString = json.encode(playersUpgrades[src])
        return (asString and upsString or playersUpgrades[src])
    end

    return false
end

exports('setPlayerUpgrades', setPlayerUpgrades)
exports('getPlayerUpgrades', getPlayerUpgrades)