---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

---@class ExtendedStumpCutter
---@field spec_stumpCutter any
---@field isServer any
---@field getIsTurnedOn function
---@field getRootVehicle function
---@field getIsActiveForInput function
---@field addActionEvent function
ExtendedStumpCutter = {}
ExtendedStumpCutter.MOD_NAME = g_currentModName
ExtendedStumpCutter.SPEC_TABLE_NAME = string.format("spec_%s.extendedStumpCutter", ExtendedStumpCutter.MOD_NAME)

function ExtendedStumpCutter.prerequisitesPresent(specializations)
    return true
end

function ExtendedStumpCutter.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", ExtendedStumpCutter)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedStumpCutter)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedStumpCutter)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", ExtendedStumpCutter)
end

function ExtendedStumpCutter:onLoad()
    local spec = self[ExtendedStumpCutter.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedStumpCutter:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    local spec = self[ExtendedStumpCutter.SPEC_TABLE_NAME]
    if self:getIsActiveForInput(true, true) then
        local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.SAWDUST_ONOFF, self, ExtendedStumpCutter.sawdustToggle, false, true, false, true, nil, nil, true)
        g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(actionEventId, true)
    end
end

function ExtendedStumpCutter:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local rootVehicle = self:getRootVehicle()
    if rootVehicle.getIsEntered ~= nil and rootVehicle:getIsEntered() then
        g_sawdust:addPrintText()
    end
end

function ExtendedStumpCutter:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedStumpCutter.SPEC_TABLE_NAME]
    if self.isServer and g_sawdust.sawdustEnabled then
        if self:getIsTurnedOn() and self.spec_stumpCutter.curSplitShape then
            local delta = (20 / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(self.spec_stumpCutter.cutNode)
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer, "StumpCutter")
            spec.sawdustBuffer = 0
        end
    end
end

function ExtendedStumpCutter.sawdustToggle()
    SawdustEvent.sendEvent(not g_sawdust.sawdustEnabled)
end
