---${title}

---@author ${author}
---@version r_version_r
---@date 05/11/2020

---@class ExtendedWoodHarvester
---@field spec_woodHarvester any
---@field isServer any

ExtendedWoodHarvester = {}
ExtendedWoodHarvester.MOD_NAME = g_currentModName
ExtendedWoodHarvester.SPEC_TABLE_NAME = string.format("spec_%s.extendedWoodHarvester", ExtendedWoodHarvester.MOD_NAME)

function ExtendedWoodHarvester.prerequisitesPresent(specializations)
    return true
end

function ExtendedWoodHarvester.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedWoodHarvester)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedWoodHarvester)
end

function ExtendedWoodHarvester:onLoad()
    local spec = self[ExtendedWoodHarvester.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedWoodHarvester:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedWoodHarvester.SPEC_TABLE_NAME]
    if self.isServer and g_sawdust.sawdustEnabled then
        local diameterScale = self.spec_woodHarvester.lastDiameter
        if self.spec_woodHarvester.isCutSamplePlaying then
            local delta = ((100 * diameterScale) / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if self:getIsTurnedOn() and self.spec_woodHarvester.isDelimbSamplePlaying then
            local delta = ((200 * diameterScale) / 1000) * dt
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(self.spec_woodHarvester.cutNode)
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer)
            spec.sawdustBuffer = 0
        end
    end
end
