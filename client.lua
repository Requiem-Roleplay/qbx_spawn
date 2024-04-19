--local config = require '@qbx_apartments.config.shared'
local camZPlus1 = 1500
local camZPlus2 = 50
local pointCamCoords = 75
local pointCamCoords2 = 0
local cam1Time = 500
local cam2Time = 1000
local isChoosingSpawn = false
local Houses = {}
local cam = nil
local cam2 = nil

-- Functions

-- Stops player from moving while choosing spawn
local function launchDisableControlsThread()
    CreateThread(function()
        while isChoosingSpawn do
            Wait(0)
            DisableAllControlActions(0)
        end
    end)
end

---Displays the spawn UI and disables controls
---@param isShowing boolean
---@return void
local function setDisplay(isShowing)
    isChoosingSpawn = isShowing
    if isShowing then launchDisableControlsThread() end
    SetNuiFocus(isShowing, isShowing)
    SendNUIMessage({
        action = "showUi",
        status = isShowing
    })
end

-- Events

RegisterNetEvent('qb-spawn:client:openUI', function(value)
    SetEntityVisible(cache.ped, false)
    DoScreenFadeOut(250)
    Wait(1000)
    DoScreenFadeIn(250)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", QBX.PlayerData.position.x, QBX.PlayerData.position.y,
        QBX.PlayerData.position.z + camZPlus1, -85.00, 0.00, 0.00, 100.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    Wait(500)
    setDisplay(value)
end)

RegisterNetEvent('qb-houses:client:setHouseConfig', function(houseConfig)
    Houses = houseConfig
end)

RegisterNetEvent('qb-spawn:client:setupSpawns', function(cData, new, apps)
    if not new then
        local houses = lib.callback.await('qb-spawn:server:getOwnedHouses', false, cData.citizenid)
        local myHouses = {}
        --        if houses then
        --            for i = 1, #houses do
        --                myHouses[#myHouses+1] = {
        --                    house = houses[i].house,
        --                    label = Houses[houses[i].house].adress,
        --                }
        --            end
        if houses ~= nil then
            for i = 1, (#houses), 1 do
                local house = houses[i]
                myHouses[#myHouses + 1] = {
                    house = house,
                    label = (house.apartment or house.street)
                }
            end
        end
        ---end

        Wait(500)
        SendNUIMessage({
            action = "setupLocations",
            locations = QB.Spawns,
            houses = myHouses,
            isNew = new
        })
    elseif new then
        SendNUIMessage({
            action = "setupAppartements",
            locations = apps,
            isNew = new
        })
    end
end)

-- NUI Callbacks

RegisterNUICallback("exit", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "showUi",
        status = false
    })
    isChoosingSpawn = false
    cb("ok")
end)

local function SetCam(campos)
    cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus1, 300.00, 0.00, 0.00,
        110.00, false, 0)
    PointCamAtCoord(cam2, campos.x, campos.y, campos.z + pointCamCoords)
    SetCamActiveWithInterp(cam2, cam, cam1Time, true, true)
    if DoesCamExist(cam) then
        DestroyCam(cam, true)
    end
    Wait(cam1Time)

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus2, 300.00, 0.00, 0.00,
        110.00, false, 0)
    PointCamAtCoord(cam, campos.x, campos.y, campos.z + pointCamCoords2)
    SetCamActiveWithInterp(cam, cam2, cam2Time, true, true)
    SetEntityCoords(cache.ped, campos.x, campos.y, campos.z)
end

RegisterNUICallback('setCam', function(data, cb)
    local location = tostring(data.posname)
    local type = tostring(data.type)
    DoScreenFadeOut(200)
    Wait(500)
    DoScreenFadeIn(200)
    if DoesCamExist(cam) then DestroyCam(cam, true) end
    if DoesCamExist(cam2) then DestroyCam(cam2, true) end
    if type == "current" then
        SetCam(QBX.PlayerData.position)
    elseif type == "house" then
        SetCam(Houses[location].coords.enter)
    elseif type == "normal" then
        SetCam(QB.Spawns[location].coords)
    elseif type == "appartment" then
        --SetCam(config.locations[location].coords.enter)
    end
    cb('ok')
end)

RegisterNUICallback('chooseAppa', function(data, cb)
    --    local appaYeet = data.appType
    --    setDisplay(false)
    --    DoScreenFadeOut(500)
    --    Wait(5000)
    --    TriggerServerEvent("apartments:server:CreateApartment", appaYeet, config.locations[appaYeet].label)
    --    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    --    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    --    FreezeEntityPosition(cache.ped, false)
    --    RenderScriptCams(false, true, 500, true, true)
    --    SetCamActive(cam, false)
    --    DestroyCam(cam, true)
    --    SetCamActive(cam2, false)
    --    DestroyCam(cam2, true)
    --    SetEntityVisible(cache.ped, true)
    local appaYeet = data.appType
    setDisplay(false)
    DoScreenFadeOut(500)
    Wait(100)
    FreezeEntityPosition(cache.ped, false)
    RenderScriptCams(false, true, 0, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(cache.ped, true)
    Wait(500)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    Wait(100)
    TriggerServerEvent("ps-housing:server:createNewApartment", appaYeet)
    cb('ok')
end)

local function PreSpawnPlayer()
    setDisplay(false)
    DoScreenFadeOut(500)
    Wait(2000)
end

local function PostSpawnPlayer(ped)
    FreezeEntityPosition(ped, false)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(cache.ped, true)
    Wait(500)
    DoScreenFadeIn(250)
end

RegisterNUICallback('spawnplayer', function(data, cb)
    -- local location = tostring(data.spawnloc)
    -- local type = tostring(data.typeLoc)
    -- local insideMeta = QBX.PlayerData.metadata["inside"]
    -- if type == "current" then
    --     PreSpawnPlayer()
    --     SetEntityCoords(cache.ped, QBX.PlayerData.position.x, QBX.PlayerData.position.y, QBX.PlayerData.position.z)
    --     SetEntityHeading(cache.ped, QBX.PlayerData.position.a)
    --     FreezeEntityPosition(cache.ped, false)
    --
    --     if insideMeta.house ~= nil then
    --         local houseId = insideMeta.house
    --         TriggerEvent('qb-houses:client:LastLocationHouse', houseId)
    --     elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
    --         local apartmentType = insideMeta.apartment.apartmentType
    --         local apartmentId = insideMeta.apartment.apartmentId
    --         TriggerEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
    --     end
    --     TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    --     TriggerEvent('QBCore:Client:OnPlayerLoaded')
    --     PostSpawnPlayer()
    -- elseif type == "house" then
    --     PreSpawnPlayer()
    --     TriggerEvent('qb-houses:client:enterOwnedHouse', location)
    --     TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    --     TriggerEvent('QBCore:Client:OnPlayerLoaded')
    --     TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    --     TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    --     PostSpawnPlayer()
    -- elseif type == "normal" then
    --     local pos = QB.Spawns[location].coords
    --     PreSpawnPlayer()
    --     SetEntityCoords(cache.ped, pos.x, pos.y, pos.z)
    --     TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    --     TriggerEvent('QBCore:Client:OnPlayerLoaded')
    --     TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    --     TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    --     Wait(500)
    --     SetEntityCoords(cache.ped, pos.x, pos.y, pos.z)
    --     SetEntityHeading(cache.ped, pos.w)
    --     PostSpawnPlayer()
    -- end
    -- cb('ok')
    local location = tostring(data.spawnloc)
    local type = tostring(data.typeLoc)
    local PlayerData = QBX.PlayerData
    local insideMeta = PlayerData.metadata["inside"]
    if type == "current" then
        PreSpawnPlayer()
        SetEntityCoords(cache.ped, QBX.PlayerData.position.x, QBX.PlayerData.position.y, QBX.PlayerData.position.z)
        SetEntityHeading(cache.ped, QBX.PlayerData.position.a)
        FreezeEntityPosition(cache.ped, false)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        if insideMeta.property_id ~= nil then
            local property_id = insideMeta.property_id
            TriggerServerEvent('ps-housing:server:enterProperty', tostring(property_id))
        end
        PostSpawnPlayer()
    elseif type == "house" then
        PreSpawnPlayer()
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        local property_id = data.spawnloc.property_id
        TriggerServerEvent('ps-housing:server:enterProperty', tostring(property_id))
        PostSpawnPlayer()
    elseif type == "normal" then
        local pos = QB.Spawns[location].coords
        PreSpawnPlayer()
        SetEntityCoords(cache.ped, pos.x, pos.y, pos.z)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('ps-housing:server:resetMetaData')
        SetEntityCoords(cache.ped, pos.x, pos.y, pos.z)
        SetEntityHeading(cache.ped, pos.w)
        PostSpawnPlayer()
    end
    cb('ok')
end)