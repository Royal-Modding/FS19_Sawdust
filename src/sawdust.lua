---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

InitRoyalMod(Utils.getFilename("lib/rmod/", g_currentModDirectory))
InitRoyalUtility(Utils.getFilename("lib/utility/", g_currentModDirectory))

---@class Sawdust : RoyalMod
Sawdust = RoyalMod.new(r_debug_r, false)
Sawdust.directory = g_currentModDirectory
Sawdust.totalSawdust = 2
Sawdust.woodHarvesterCounter = 0
Sawdust.treeSawCounter = 0
Sawdust.stumpCutterCounter = 0
Sawdust.chainsawCounter = 0
Sawdust.showHelp = false

AmountTypes = {}
AmountTypes.WOODHARVESTER_CUT = 0
AmountTypes.TREESAW_CUT = 1
AmountTypes.STUPCUTTER_CUT = 2
AmountTypes.CHAINSAW_DELIMB = 3
AmountTypes.CHAINSAW_CUT = 4
AmountTypes.CHAINSAW_CUTDOWN = 5

function Sawdust:initialize()
    self.gameEnv["g_sawdust"] = self
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

function Sawdust:onWriteStream(streamId)
end

function Sawdust:onReadStream(streamId)
end

function Sawdust:onUpdate(dt)

    self.showHelp = false

    if g_currentMission.controlledVehicle ~= nil then
        if g_currentMission.controlledVehicle.spec_woodHarvester ~= nil then
            if g_currentMission.controlledVehicle.spec_woodHarvester.cutNode ~= nil then
                self:processWoodHarvester()
            end
        end

        if #g_currentMission.controlledVehicle.spec_attacherJoints.attachedImplements > 0 then
            for _, cutimplement in pairs(g_currentMission.controlledVehicle.spec_attacherJoints.attachedImplements) do
                local vehicle = cutimplement.object
                if vehicle.spec_stumpCutter ~= nil then
                    if vehicle.spec_stumpCutter.cutNode ~= nil then
                        self:processStumpCutter(vehicle.spec_stumpCutter)
                    end
                end
                if vehicle.spec_treeSaw ~= nil then
                    if vehicle.spec_treeSaw.cutNode ~= nil then
                        self:processTreeSaw(vehicle.spec_treeSaw)
                    end
                end
            end
        end
    end

    if g_currentMission.player and g_currentMission.player.baseInformation.currentHandtool and g_currentMission.player.baseInformation.currentHandtool.cutNode then
        self:processChainsaw()
    end

    if self.showHelp then
        g_currentMission:addExtraPrintText(g_i18n:getText("SW_DESCLEVEL") .. " " .. tostring(self.totalSawdust));
    end

end

function Sawdust:onUpdateTick(dt)
end

function Sawdust:onWriteUpdateStream(streamId, connection, dirtyMask)
end

function Sawdust:onReadUpdateStream(streamId, timestamp, connection)
end

function Sawdust:onMouseEvent(posX, posY, isDown, isUp, button)
end

function Sawdust:onKeyEvent(unicode, sym, modifier, isDown)
end

function Sawdust:onDraw()

end

function Sawdust:onPreSaveSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPostSaveSavegame(savegameDirectory, savegameIndex)
end

function Sawdust:onPreDeleteMap()
end

function Sawdust:onDeleteMap()
end

function Sawdust:keyEvent(unicode, sym, modifier, isDown)

    if not isDown then
        return
    end

    if self.showHelp == false then
        return
    end

    if sym == Input.KEY_z then
        if self.totalSawdust == 0 then
            self.totalSawdust = 3
        elseif self.totalSawdust == 3 then
            self.totalSawdust = 2
        elseif self.totalSawdust == 2 then
            self.totalSawdust = 1
        elseif self.totalSawdust == 1 then
            self.totalSawdust = 0
        end
    end

end

function Sawdust:processWoodHarvester()
    self.showHelp = true
    if g_currentMission.controlledVehicle.spec_woodHarvester.hasAttachedSplitShape then
        if g_currentMission.controlledVehicle.spec_woodHarvester.cutTimer > 1 then
            self.woodHarvesterCounter = self.woodHarvesterCounter + (1 * self.totalSawdust)
        end
        if g_currentMission.controlledVehicle.spec_woodHarvester.isAttachedSplitShapeMoving then
            self.woodHarvesterCounter = self.woodHarvesterCounter + (math.random(2, 4) * self.totalSawdust)
        end
    end
    if self.woodHarvesterCounter > 220 then
        local x, y, z = getWorldTranslation(g_currentMission.controlledVehicle.spec_woodHarvester.cutNode)
        self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.WOODHARVESTER_CUT))
        self.woodHarvesterCounter = 0
    end
end

function Sawdust:processTreeSaw(object)
    self.showHelp = true
    local workingToolNode = object.cutNode
    if workingToolNode ~= nil then -- workaround per i coglioni che usano i treesaw senza un cutnode
        if object.isCutting then
            self.treeSawCounter = self.treeSawCounter + (1 * self.totalSawdust)
        end
        if self.treeSawCounter > 150 then
            local x, y, z = getWorldTranslation(workingToolNode)
            self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.TREESAW_CUT))
            self.treeSawCounter = 0
        end
    end
end

function Sawdust:processStumpCutter(object)
    self.showHelp = true
    if object.curSplitShape ~= nil then
        self.stumpCutterCounter = self.stumpCutterCounter + (1 * self.totalSawdust)
    end
    if self.stumpCutterCounter > 200 then
        local x, y, z = getWorldTranslation(object.stumpCutterCutNode)
        self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.STUPCUTTER_CUT))
        self.stumpCutterCounter = 0
    end
end

function Sawdust:processChainsaw()
    self.showHelp = true
    -- chainsaw delimb
    if g_currentMission.player.baseInformation.currentHandtool.particleSystems[1].isEmitting and not g_currentMission.player.baseInformation.currentHandtool.isCutting then
        if math.random(10) > (8 - self.totalSawdust) then
            self.chainsawCounter = self.chainsawCounter + (1 * self.totalSawdust)
        end
        if self.chainsawCounter > 100 then
            local x, y, z = getWorldTranslation(g_currentMission.player.baseInformation.currentHandtool.cutNode)
            self:addChipToGround(x, y, z, self:calcDelta(AmountTypes.CHAINSAW_DELIMB))
            self.chainsawCounter = 0
        end
    end
    -- chainsaw cut
    if g_currentMission.player.baseInformation.currentHandtool.isCutting then
        self.chainsawCounter = self.chainsawCounter + (1 * self.totalSawdust)
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
    return amount * self.totalSawdust
end

function Sawdust:addChipToGround(x, y, z, amount)
    if self.totalSawdust > 0 then
        if g_currentMission:getIsServer() then
            local xzRndm = ((math.random(1, 20)) - 10) / 10
            local xOffset = math.max(math.min(xzRndm, 0.3), -0.3)
            local zOffset = math.max(math.min(xzRndm, 0.8), -0.1)
            local ex = x + xOffset
            local ey = y - 0.1
            local ez = z + zOffset
            local fillTypeIndex = g_fillTypeManager:getFillTypeIndexByName("WOODCHIPS")
            local outerRadius = DensityMapHeightUtil.getDefaultMaxRadius(fillTypeIndex)
            local dropped, lineOffset = DensityMapHeightUtil.tipToGroundAroundLine(nil, amount, fillTypeIndex, x, y, z, ex, ey, ez, 0, outerRadius, 1, false, nil)
            print("dropped: " .. tostring(dropped) .. "lineOffset: " .. tostring(lineOffset))
        else
            g_client:getServerConnection():sendEvent(SawdustEvent:new(x, y, z, amount))
        end
    end
end
