---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

---@class ExtendedTreeSaw
---@field spec_treeSaw any
---@field isServer any
---@field getRootVehicle function
---@field getIsActiveForInput function
---@field addActionEvent function
ExtendedTreeSaw = {}
ExtendedTreeSaw.MOD_NAME = g_currentModName
ExtendedTreeSaw.SPEC_TABLE_NAME = string.format("spec_%s.extendedTreeSaw", ExtendedTreeSaw.MOD_NAME)

function ExtendedTreeSaw.prerequisitesPresent(specializations)
    return true
end

function ExtendedTreeSaw.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", ExtendedTreeSaw)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedTreeSaw)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedTreeSaw)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", ExtendedTreeSaw)
end

function ExtendedTreeSaw:onLoad()
    local spec = self[ExtendedTreeSaw.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedTreeSaw:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    local spec = self[ExtendedTreeSaw.SPEC_TABLE_NAME]
    if self:getIsActiveForInput(true, true) then
        local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.SAWDUST_ONOFF, self, ExtendedTreeSaw.sawdustToggle, false, true, false, true, nil, nil, true)
        g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(actionEventId, true)
    end
end

function ExtendedTreeSaw:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local rootVehicle = self:getRootVehicle()
    if rootVehicle.getIsEntered ~= nil and rootVehicle:getIsEntered() then
        g_sawdust:addPrintText()
    end
end

function ExtendedTreeSaw:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedTreeSaw.SPEC_TABLE_NAME]
    if self.isServer and g_sawdust.sawdustEnabled then
        if self.spec_treeSaw.isCutting then
            local delta = (50 / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(self.spec_treeSaw.cutNode)
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer, "TreeSaw")
            spec.sawdustBuffer = 0
        end
    end
end

function ExtendedTreeSaw.sawdustToggle()
    SawdustEvent.sendEvent(not g_sawdust.sawdustEnabled)
end
