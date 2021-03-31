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

    self.sawdustFadeMessage =
        FadeEffect:new(
        {
            position = {x = 0.5, y = g_safeFrameOffsetY * 3},
            align = {x = FadeEffect.ALIGNS.CENTER, y = FadeEffect.ALIGNS.BOTTOM},
            size = 0.024,
            shadow = true,
            shadowPosition = {x = 0.0016, y = 0.0016},
            statesTime = {0.75, 3, 0.95}
        }
    )
end

function Sawdust:onValidateVehicleTypes(vehicleTypeManager, addSpecialization, addSpecializationBySpecialization, addSpecializationByVehicleType, addSpecializationByFunction)
    -- avoid loading if mod RealWoodHarvester by kenny456
    if not g_modIsLoaded["FS19_RealWoodHarvester"] then
        addSpecializationBySpecialization("extendedWoodHarvester", "woodHarvester")
    end
    addSpecializationBySpecialization("extendedStumpCutter", "stumpCutter")
    addSpecializationBySpecialization("extendedTreeSaw", "treeSaw")
    addSpecializationBySpecialization("extendedWoodCrusher", "woodCrusher")
    addSpecializationByVehicleType("extendedWoodCrusher", "FS19_jenzBA725.selfPropelledWoodCrusher")
end

function Sawdust:onMissionInitialize(baseDirectory, missionCollaborators)
end

function Sawdust:onSetMissionInfo(missionInfo, missionDynamicInfo)
end

function Sawdust:onLoad()
    g_messageCenter:subscribe(MessageType.USER_ADDED, self.onAddPlayer, self)
end

function Sawdust:onPreLoadMap(mapFile)
end

function Sawdust:onCreateStartPoint(startPointNode)
end

function Sawdust:onLoadMap(mapNode, mapFile)
end

function Sawdust:onAddPlayer()
    if g_server ~= nil then
        SawdustEvent.sendEvent(self.sawdustEnabled)
    end
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
    self.sawdustFadeMessage:update(dt)
    self.chainsawInUse = g_currentMission.player and g_currentMission.player.baseInformation.currentHandtool and g_currentMission.player.baseInformation.currentHandtool.cutNode
    if self.chainsawInUse or self.printText then
        if self.sawdustEnabled then
            g_currentMission:addExtraPrintText(g_i18n:getText("SAWDUST_ENABLED"))
        else
            g_currentMission:addExtraPrintText(g_i18n:getText("SAWDUST_DISABLED"))
        end
        self.printText = false
    end
end

function Sawdust:onMouseEvent(posX, posY, isDown, isUp, button)
end

function Sawdust:onDraw()
    self.sawdustFadeMessage:draw()
end

function Sawdust:onPreSaveSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPostSaveSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPreDeleteMap()
end

function Sawdust:onDeleteMap()
end

function Sawdust:sawdustToggle(isEnabled)
    if isEnabled ~= self.sawdustEnabled then
        self.sawdustEnabled = isEnabled
        if not self.sawdustEnabled then
            self.sawdustFadeMessage:play(string.format("%s", g_i18n:getText("SAWDUST_DISABLED")))
        else
            self.sawdustFadeMessage:play(string.format("%s", g_i18n:getText("SAWDUST_ENABLED")))
        end
    end
end

function Sawdust:addChipToGround(x, y, z, amount, caller)
    if g_currentMission:getIsServer() then
        --g_logManager:devInfo("Sawdust calculated [%s]  ::  dropped [%s]  ::  caller [%s]", amount, dropped, caller)
        local xzRndm = ((math.random(1, 20)) - 10) / 10
        local xOffset = math.max(math.min(xzRndm, 0.3), -0.3)
        local zOffset = math.max(math.min(xzRndm, 0.8), -0.1)
        local ex = x + xOffset
        local ey = y - 0.1
        local ez = z + zOffset
        local outerRadius = DensityMapHeightUtil.getDefaultMaxRadius(FillType.WOODCHIPS)
        local dropped, lineOffset = DensityMapHeightUtil.tipToGroundAroundLine(nil, amount, FillType.WOODCHIPS, x, y, z, ex, ey, ez, 0, outerRadius, 1, false, nil)
    else
        g_logManager:devError("[%s] addChipToGround can be called server-side only!", self.name)
    end
end

function Sawdust:addPrintText()
    self.printText = true
end
