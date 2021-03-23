---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

---@class ExtendedWoodHarvester
---@field spec_woodHarvester any
---@field isServer any
---@field getIsTurnedOn function
---@field getRootVehicle function
---@field getIsActiveForInput function
---@field addActionEvent function
ExtendedWoodHarvester = {}
ExtendedWoodHarvester.MOD_NAME = g_currentModName
ExtendedWoodHarvester.SPEC_TABLE_NAME = string.format("spec_%s.extendedWoodHarvester", ExtendedWoodHarvester.MOD_NAME)

function ExtendedWoodHarvester.prerequisitesPresent(specializations)
    return true
end

function ExtendedWoodHarvester.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", ExtendedWoodHarvester)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedWoodHarvester)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedWoodHarvester)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", ExtendedWoodHarvester)
end

function ExtendedWoodHarvester:onLoad()
    local spec = self[ExtendedWoodHarvester.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedWoodHarvester:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    local spec = self[ExtendedWoodHarvester.SPEC_TABLE_NAME]
    if self:getIsActiveForInput(true, true) then
        local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.SAWDUST_ONOFF, self, ExtendedWoodHarvester.sawdustToggle, false, true, false, true, nil, nil, true)
        g_inputBinding:setActionEventTextVisibility(actionEventId, false)
    end
end

function ExtendedWoodHarvester:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local rootVehicle = self:getRootVehicle()
    if rootVehicle.getIsEntered ~= nil and rootVehicle:getIsEntered() then
        g_sawdust:addPrintText()
    end
end

function ExtendedWoodHarvester:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedWoodHarvester.SPEC_TABLE_NAME]
    if self.isServer and g_sawdust.sawdustEnabled then
        local diameterScale = self.spec_woodHarvester.lastDiameter
        if self.spec_woodHarvester.isCutSamplePlaying then
            local delta = ((200 * diameterScale) / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if self:getIsTurnedOn() and self.spec_woodHarvester.isDelimbSamplePlaying then
            local delta = ((250 * diameterScale) / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(self.spec_woodHarvester.cutNode)
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer, "WoodHarvester")
            spec.sawdustBuffer = 0
        end
    end
end

function ExtendedWoodHarvester.sawdustToggle()
    g_sawdust:sawdustToggle()
end
