---${title}

---@author ${author}
---@version r_version_r
---@date 05/11/2020

---@class ExtendedStumpCutter
---@field spec_stumpCutter any
---@field isServer any
---@field getIsTurnedOn function
ExtendedStumpCutter = {}
ExtendedStumpCutter.MOD_NAME = g_currentModName
ExtendedStumpCutter.SPEC_TABLE_NAME = string.format("spec_%s.extendedStumpCutter", ExtendedStumpCutter.MOD_NAME)

function ExtendedStumpCutter.prerequisitesPresent(specializations)
    return true
end

function ExtendedStumpCutter.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedStumpCutter)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedStumpCutter)
end

function ExtendedStumpCutter:onLoad()
    local spec = self[ExtendedStumpCutter.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedStumpCutter:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedStumpCutter.SPEC_TABLE_NAME]
    if self.isServer then
        if self:getIsTurnedOn() and self.spec_stumpCutter.curSplitShape then
            local delta = (10 / 1000) * dt
            delta = delta * g_sawdust.sawdustScale
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(self.spec_stumpCutter.cutNode)
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer)
            spec.sawdustBuffer = 0
        end
    end
end