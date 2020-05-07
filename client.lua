local CFG = exports['fq_essentials']:getCFG()
local mCFG = CFG.menu
local gCFG = CFG.gangs
local msgCFG = CFG.msg.pl

local gangId = nil
local clientMoney = nil
local isShopShown = false
local upgrades = nil

local components = {
    {
        {'COMPONENT_AT_PI_SUPP', 'COMPONENT_AT_AR_SUPP_02'},
        {'COMPONENT_COMBATPISTOL_CLIP_02', 'COMPONENT_PISTOL50_CLIP_02', 'COMPONENT_HEAVYPISTOL_CLIP_02', 'COMPONENT_VINTAGEPISTOL_CLIP_02'},
    },
    {
        {'COMPONENT_AT_AR_SUPP_02', 'COMPONENT_AT_PI_SUPP'},
        {'COMPONENT_AT_SCOPE_MACRO', 'COMPONENT_AT_SCOPE_SMALL'},
        {'COMPONENT_MICROSMG_CLIP_02', 'COMPONENT_SMG_CLIP_02', 'COMPONENT_ASSAULTSMG_CLIP_02', 'COMPONENT_COMBATPDW_CLIP_02'}
    },
    {
        {'COMPONENT_AT_SR_SUPP', 'COMPONENT_AT_AR_SUPP_02'},
        {'COMPONENT_AT_AR_AFGRIP'}
    },
    {
        {'COMPONENT_AT_SCOPE_MACRO', 'COMPONENT_AT_SCOPE_MEDIUM', 'COMPONENT_AT_SCOPE_SMALL'},
        {'COMPONENT_AT_AR_SUPP_02', 'COMPONENT_AT_AR_SUPP'},
        {'COMPONENT_ASSAULTRIFLE_CLIP_02', 'COMPONENT_CARBINERIFLE_CLIP_02', 'COMPONENT_ADVANCEDRIFLE_CLIP_02', 'COMPONENT_BULLPUPRIFLE_CLIP_02'},
        {'COMPONENT_AT_AR_AFGRIP'}
    },
}

local items = {
    [1] = {2400, 'weapon_mg', 4, 50}, -- cena, bron, ammo limit
    [2] = {2400, 'weapon_combatmg', 4, 50},
    [3] = 2400,
    [4] = 2400,
    [5] = 2400,
    [6] = 2400,
    [7] = 2400,
    [8] = 2400,
    [9] = 2400,
    [10] = 2400,
    [11] = 2400,
    [12] = 2400,
    [13] = 2400,
    [14] = {2400, 'weapon_sniperrifle', 4, 6},
    [15] = {2400, 'weapon_heavysniper', 5, 1},
    [16] = {2400, 'weapon_marksmanrifle', 2, 4}, 
    [17] = {2400, 'weapon_rpg', 2, 1},
    [18] = {2400, 'weapon_grenadelauncher', 5, 2},
    [19] = {2400, 'weapon_minigun', 2, 60},
    [20] = {2400, 'weapon_hominglauncher', 1, 1},
    [21] = {2400, 'weapon_compactlauncher', 5, 1},
    [22] = {2400, 'weapon_grenade', 3, 1},
    [23] = {2400, 'weapon_stickybomb', 2, 1},
    [24] = {2400, 'weapon_bzgas', 3, 2},
    [25] = {2400, 'weapon_molotov', 5, 1},
    [26] = {2400, 'weapon_pipebomb', 5, 1},
    [27] = 2400,
    [28] = 2400
}

local tempItemsBoughtThisLife = {}

local onlyOneAllowed = {
    {'weapon_grenadelauncher', 'weapon_compactlauncher'},
    {'weapon_combatmg', 'weapon_mg'},
    {'weapon_sniperrifle', 'weapon_heavysniper', 'weapon_marksmanrifle'}
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

local ESXs = exports['fq_callbacks']:getServerObject()

RegisterNetEvent('fq:onAuth')
AddEventHandler('fq:onAuth', function()
    msgCFG = CFG.msg[exports['fq_login']:getLang()]
    
    SendNUIMessage({
		type = 'SET_LANG',
		lang = lng
	})
end)

AddEventHandler('fq:pickedCharacter', function(gangIndex, modelIndex)
    if gCFG[gangIndex] and gCFG[gangIndex].models[modelIndex] then
        gangId = gangIndex
    end
end)

RegisterNetEvent('fq:updateLocalMoney')
AddEventHandler('fq:updateLocalMoney', function(money, sv_upgrades)
    clientMoney = money

    if sv_upgrades then
        upgrades = json.decode(sv_upgrades)
        TriggerEvent('fq:setUpgrades', upgrades)
        TriggerServerEvent('fq:updateUpgradesOnSv', upgrades)
    end
end)

RegisterNetEvent('fq:showShop')
AddEventHandler('fq:showShop', function(state, whatToShow)
    SendNUIMessage({
		type = 'ON_STATE',
        display = state,
        show = whatToShow -- {'w', 'u'}
    })
    
    TriggerEvent('hideChat', state)
    SetNuiFocus(state, state)
    isShopShown = state
end)

RegisterNetEvent('fq:setUpgrades')
AddEventHandler('fq:setUpgrades', function(ups)
	SendNUIMessage({
		type = 'ON_UPDATE',
		data = ups
	})
end)

RegisterNetEvent('fq:boughtItem')
AddEventHandler('fq:boughtItem', function(itemId, up)
    SendNUIMessage({
        type = 'ON_BOUGHT',
        id = itemId,
        isUp = up
    })
end)

RegisterNetEvent('fq:giveWeaponKit')
AddEventHandler('fq:giveWeaponKit', function()
    local guns = gCFG[gangId].weapons
    
    RemoveAllPedWeapons(GetPlayerPed(-1))
    
    for i, v in ipairs(guns) do
        GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(v), 999, false, i == 4 and false or true)
        for j, k in ipairs(components[i]) do 
            if upgrades[i][j] then
                for u, z in ipairs(k) do 
                    if DoesWeaponTakeWeaponComponent(GetHashKey(v), GetHashKey(z)) then
                        GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(v), GetHashKey(z))
                        break
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied', function()
    tempItemsBoughtThisLife = {}
end)

RegisterNUICallback('menuResult', function(data, cb)
    local id = data.id
    local isUpgrade = data.isUpgrade

    if data.type == "ON_BUY" then
        -- id: itemID,
        -- cost: itemCost,
        -- isUpgrade: isUps
        if id then
            if isUpgrade then
                if not upgrades[ups_ids[id][1]][ups_ids[id][2]] then
                    ESXs.TriggerServerCallback('fq:canBuyItem', function(canBuy)
                        if canBuy then
                            upgrades[ups_ids[id][1]][ups_ids[id][2]] = true;
                            
                            TriggerEvent('fq:setUpgrades', upgrades)
                            TriggerEvent('fq:boughtItem', id, true)
                            TriggerServerEvent('fq:removeMoneyByItemID', id)
                            -- TriggerServerEvent('fq:updateUpgradesOnSv', upgrades) -- <---
                            -- CLIENT MOZE TO WYKORZYSTAC, PRZENIESC W PELNI NA SERWER
                            return
                        else
                            TriggerEvent('fq:boughtItem', false)
                            return
                        end
                    end, id, true)
                end
                -- TriggerEvent('fq:boughtItem', false)
                return
            end
            -- if clientMoney > data.cost then
            ESXs.TriggerServerCallback('fq:canBuyItem', function(canBuy)
                if canBuy then
                    if type(items[id]) == 'table' then
                        if not tempItemsBoughtThisLife[id] then
                            tempItemsBoughtThisLife[id] = 0
                        else
                            tempItemsBoughtThisLife[id] = tempItemsBoughtThisLife[id] + 1
                            
                            if tempItemsBoughtThisLife[id] >= items[id][3] then
                                TriggerEvent('fq:boughtItem', false)
                                return
                            end
                        end
                    
                        local weaponIndex = 0
                        for i, v in ipairs(onlyOneAllowed) do
                            for j, m in ipairs(v) do
                                if m == items[id][2] then
                                    if not tempItemsBoughtThisLife['only'] then 
                                        tempItemsBoughtThisLife['only'] = {}
                                    end
                                    
                                    if not tempItemsBoughtThisLife['only'][i] then
                                        tempItemsBoughtThisLife['only'][i] = m
                                    end
                                    weaponIndex = i
                                    break
                                end
                            end
                        end
                        if weaponIndex > 0 then
                            if tempItemsBoughtThisLife['only'][weaponIndex] and tempItemsBoughtThisLife['only'][weaponIndex] ~= items[id][2] then
                                TriggerEvent('fq:boughtItem', false)
                                return
                            end
                        end
                    end

                    if id == 27 then
                        local inv = exports['fq_player']:getInventory()
                        if inv.armor < 3 then
                            exports['fq_player']:addItem('armor')
                        else
                            TriggerEvent('fq:boughtItem', false)
                            return
                        end
                    elseif id == 28 then
                        local inv = exports['fq_player']:getInventory()
                        if inv.health < 3 then
                            exports['fq_player']:addItem('health')
                        else
                            TriggerEvent('fq:boughtItem', false)
                            return
                        end
                    else
                        GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(items[id][2]), items[id][4], false, false)
                    end
                    
                    TriggerEvent('fq:boughtItem', id, false)
                    TriggerServerEvent('fq:removeMoneyByItemID', id)
                else
                    TriggerEvent('fq:boughtItem', false)
                    return
                end
            -- else
            --     TriggerEvent('fq:boughtItem', false)
            --     return
            end, id)
        end
    elseif data.type == 'CLOSE_UI' then
        TriggerEvent('fq:showShop', false)
    end
end)
