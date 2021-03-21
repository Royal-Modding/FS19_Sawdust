---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

InitRoyalMod(Utils.getFilename("lib/rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("lib/utility/", g_currentModDirectory))

---@class Sawdust : RoyalMod
Sawdust = RoyalMod.new(r_debug_r, false)
Sawdust.directory = g_currentModDirectory
Sawdust.sawdustEnabled = true
Sawdust.chainsawInUse = false

function Sawdust:initialize()
    self.gameEnv["g_sawdust"] = self

    Utility.overwrittenFunction(Player, "new", ExtendedPlayerChainsaw.player_new)
    if Player.sawdustOnOff == nil then
        Player.sawdustOnOff = ExtendedPlayerChainsaw.sawdustOnOff
    end

    Utility.overwrittenFunction(Chainsaw, "load", ExtendedPlayerChainsaw.chainsaw_load)
    Utility.overwrittenFunction(Chainsaw, "update", ExtendedPlayerChainsaw.chainsaw_update)
end

function Sawdust:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
    addSpecializationBySpecialization("extendedWoodHarvester", "woodHarvester")
    addSpecializationBySpecialization("extendedStumpCutter", "stumpCutter")
    addSpecializationBySpecialization("extendedTreeSaw", "treeSaw")
end

function Sawdust:onMissionInitialize(baseDirectory, missionCollaborators)
end

function Sawdust:onSetMissionInfo(missionInfo, missionDynamicInfo)
end

function Sawdust:onLoad()
end

function Sawdust:onPreLoadMap(mapFile)
end

function Sawdust:onCreateStartPoint(startPointNode)
end

function Sawdust:onLoadMap(mapNode, mapFile)
end

function Sawdust:onPostLoadMap(mapNode, mapFile)
end

function Sawdust:onLoadSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPreLoadVehicles(xmlFile, resetVehicles)
end

function Sawdust:onPreLoadItems(xmlFile)
end

function Sawdust:onPreLoadOnCreateLoadedObjects(xmlFile)
end

function Sawdust:onLoadFinished()
end

function Sawdust:onStartMission()
end

function Sawdust:onMissionStarted()
end

function Sawdust:onUpdate(dt)
    self.chainsawInUse = g_currentMission.player and g_currentMission.player.baseInformation.currentHandtool and g_currentMission.player.baseInformation.currentHandtool.cutNode
end

function Sawdust:onMouseEvent(posX, posY, isDown, isUp, button)
end

function Sawdust:sawdustToggle()
    if self.sawdustEnabled then
        self.sawdustEnabled = false
        g_currentMission:showBlinkingWarning(g_i18n:getText("SAWDUST_DISABLED"), 2000)
    else
        self.sawdustEnabled = true
        g_currentMission:showBlinkingWarning(g_i18n:getText("SAWDUST_ENABLED"), 2000)
    end
end

function Sawdust:onDraw()
    if self.chainsawInUse then 
        if self.sawdustEnabled then
            g_currentMission:addExtraPrintText(g_i18n:getText("SAWDUST_ENABLED"))
        else
            g_currentMission:addExtraPrintText(g_i18n:getText("SAWDUST_DISABLED"))
        end
    end
end

function Sawdust:onPreSaveSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPostSaveSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPreDeleteMap()
end

function Sawdust:onDeleteMap()
end

--[[ 
function Sawdust:processChainsaw()
    self.showHelp = true
    -- chainsaw delimb
    if g_currentMission.player.baseInformation.currentHandtool.particleSystems[1].isEmitting and not g_currentMission.player.baseInformation.currentHandtool.isCutting then
        if math.random(10) > (8 - self.sawdustScale) then
            self.chainsawCounter = self.chainsawCounter + (1 * self.sawdustScale)
        end
        if self.chainsawCounter > 100 then
            local x, y, z = getWorldTranslation(g_currentMission.player.baseInformation.currentHandtool.cutNode)
            self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.CHAINSAW_DELIMB))
            self.chainsawCounter = 0
        end
    end
    -- chainsaw cut
    if g_currentMission.player.baseInformation.currentHandtool.isCutting then
        self.chainsawCounter = self.chainsawCounter + (1 * self.sawdustScale)
        if g_currentMission.player.baseInformation.currentHandtool.waitingForResetAfterCut then
            if g_currentMission.player.baseInformation.currentHandtool.isHorizontalCut and self.chainsawCounter > 220 then
                local x, y, z = getWorldTranslation(g_currentMission.player.baseInformation.currentHandtool.cutNode)
                self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.CHAINSAW_CUTDOWN))
                self.chainsawCounter = 0
            end
            if not g_currentMission.player.baseInformation.currentHandtool.isHorizontalCut and self.chainsawCounter > 220 then
                local x, y, z = getWorldTranslation(g_currentMission.player.baseInformation.currentHandtool.cutNode)
                self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.CHAINSAW_CUT))
                self.chainsawCounter = 0
            end
        end
    end
end
]]

--[[ 
function Sawdust:calcDelta(type)
    local amount = 0
    if type == AmountTypes.CHAINSAW_DELIMB then
        amount = math.random(40, 50)
    elseif type == AmountTypes.CHAINSAW_CUTDOWN then
        amount = math.random(60, 70)
    elseif type == AmountTypes.CHAINSAW_CUT then
        amount = math.random(50, 60)
    elseif type == AmountTypes.WOODHARVESTER_CUT then
        amount = math.random(50, 70)
    elseif type == AmountTypes.STUPCUTTER_CUT then
        amount = math.random(45, 60)
    elseif type == AmountTypes.TREESAW_CUT then
        amount = math.random(45, 65)
    end
    local fillTypeIndex = g_fillTypeManager:getFillTypeIndexByName("WOODCHIPS")
    local testDrop = g_densityMapHeightManager:getMinValidLiterValue(fillTypeIndex)
    --return math.max(DensityMapHeightManager.getMinValidLiterValue(fillTypeIndex), amount * self.totalSawdust);
    print("testDrop: " .. tostring(testDrop))
    return amount * self.sawdustScale
end
]]

function Sawdust:addChipToGround(x, y, z, amount)
    if g_currentMission:getIsServer() then
        local xzRndm = ((math.random(1, 20)) - 10) / 10
        local xOffset = math.max(math.min(xzRndm, 0.3), -0.3)
        local zOffset = math.max(math.min(xzRndm, 0.8), -0.1)
        local ex = x + xOffset
        local ey = y - 0.1
        local ez = z + zOffset
        local outerRadius = DensityMapHeightUtil.getDefaultMaxRadius(FillType.WOODCHIPS)
        local dropped, lineOffset = DensityMapHeightUtil.tipToGroundAroundLine(nil, amount, FillType.WOODCHIPS, x, y, z, ex, ey, ez, 0, outerRadius, 1, false, nil)
    else
        g_client:getServerConnection():sendEvent(SawdustEvent:new(x, y, z, amount))
    end
end
