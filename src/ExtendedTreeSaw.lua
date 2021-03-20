---${title}

---@author ${author}
---@version r_version_r
---@date 05/11/2020

---@class ExtendedTreeSaw
---@field spec_treeSaw any
---@field isServer any
ExtendedTreeSaw = {}
ExtendedTreeSaw.MOD_NAME = g_currentModName
ExtendedTreeSaw.SPEC_TABLE_NAME = string.format("spec_%s.extendedTreeSaw", ExtendedTreeSaw.MOD_NAME)

function ExtendedTreeSaw.prerequisitesPresent(specializations)
    return true
end

function ExtendedTreeSaw.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", ExtendedTreeSaw)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", ExtendedTreeSaw)
end

function ExtendedTreeSaw:onLoad()
    local spec = self[ExtendedTreeSaw.SPEC_TABLE_NAME]
    spec.sawdustBuffer = 0
    spec.sawdustBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
end

function ExtendedTreeSaw:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    ---@type any
    local spec = self[ExtendedTreeSaw.SPEC_TABLE_NAME]
    if self.isServer then
        if self.spec_treeSaw.isCutting then
            local delta = (50 / 1000) * dt
            delta = delta * g_sawdust.sawdustScale
            spec.sawdustBuffer = spec.sawdustBuffer + delta
        end
        if spec.sawdustBuffer >= spec.sawdustBufferMax then
            local x, y, z = getWorldTranslation(self.spec_treeSaw.cutNode)
            g_sawdust:addChipToGround(x, y, z, spec.sawdustBuffer)
            spec.sawdustBuffer = 0
        end
    end
end
