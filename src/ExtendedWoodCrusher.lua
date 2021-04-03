---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

---@class ExtendedWoodCrusher
---@field spec_woodCrusher any
---@field spec_advancedWoodCrusher any
---@field isServer any
---@field getIsTurnedOn function
---@field getRootVehicle function
---@field getIsActiveForInput function
---@field addActionEvent function
ExtendedWoodCrusher = {}
ExtendedWoodCrusher.MOD_NAME = g_currentModName
ExtendedWoodCrusher.SPEC_TABLE_NAME = string.format("spec_%s.extendedWoodCrusher", ExtendedWoodCrusher.MOD_NAME)

function ExtendedWoodCrusher.prerequisitesPresent(specializations)
    return true
end

function ExtendedWoodCrusher.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", ExtendedWoodCrusher)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedWoodCrusher)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedWoodCrusher)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", ExtendedWoodCrusher)
end

function ExtendedWoodCrusher:onLoad()
    local spec = self[ExtendedWoodCrusher.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedWoodCrusher:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    local spec = self[ExtendedWoodCrusher.SPEC_TABLE_NAME]
    if self:getIsActiveForInput(true, true) then
        local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.SAWDUST_ONOFF, self, ExtendedWoodCrusher.sawdustToggle, false, true, false, true, nil, nil, true)
        g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(actionEventId, true)
    end
end

function ExtendedWoodCrusher:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local rootVehicle = self:getRootVehicle()
    if rootVehicle.getIsEntered ~= nil and rootVehicle:getIsEntered() then
        g_sawdust:addPrintText()
    end
end

function ExtendedWoodCrusher:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedWoodCrusher.SPEC_TABLE_NAME]
    local woodCrusherSpec = self.spec_woodCrusher or self.spec_advancedWoodCrusher
    if self.isServer and g_sawdust.sawdustEnabled then
        if self:getIsTurnedOn() and woodCrusherSpec.crushingTime > 0 then
            local delta = (8 / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(woodCrusherSpec.cutNode)
            -- avoid dust under machinery
            x = x + ((math.random() * 2) + 1.5) * Utility.randomSign()
            z = z + ((math.random() * 2) + 1.5) * Utility.randomSign()
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer, "WoodCrusher")
            spec.sawdustBuffer = 0
        end
    end
end

function ExtendedWoodCrusher.sawdustToggle()
    SawdustEvent.sendEvent(not g_sawdust.sawdustEnabled)
end
