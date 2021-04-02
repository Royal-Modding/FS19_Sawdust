---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

ExtendedPlayerChainsaw = {}

function ExtendedPlayerChainsaw:player_new(superFunc, isServer, isClient)
    self = superFunc(nil, isServer, isClient)
    self.inputInformation.registrationList[InputAction.SAWDUST_ONOFF] = {
        eventId = "",
        callback = self.sawdustOnOff,
        triggerUp = false,
        triggerDown = true,
        triggerAlways = false,
        activeType = Player.INPUT_ACTIVE_TYPE.STARTS_ENABLED,
        callbackState = nil,
        text = "",
        textVisibility = true
    }
    return self
end

function ExtendedPlayerChainsaw:updateActionEvents()
    local eventId = self.inputInformation.registrationList[InputAction.SAWDUST_ONOFF].eventId
    g_inputBinding:setActionEventActive(eventId, g_sawdust.chainsawInUse ~= nil)
    g_inputBinding:setActionEventTextVisibility(eventId, g_sawdust.chainsawInUse ~= nil)
end

function ExtendedPlayerChainsaw:sawdustOnOff()
    if g_sawdust.chainsawInUse then
        SawdustEvent.sendEvent(not g_sawdust.sawdustEnabled)
    end
end

function ExtendedPlayerChainsaw:chainsaw_load(superFunc, ...)
    self.chainSawBuffer = 0
    self.chainSawBufferMax = g_densityMapHeightManager:getMinValidLiterValue(FillType.WOODCHIPS)
    return superFunc(self, ...)
end

function ExtendedPlayerChainsaw:chainsaw_update(superFunc, dt, isActive)
    if self.isServer and g_sawdust.sawdustEnabled then
        if self.isCutting then
            local delta = (20 / 1000) * dt
            self.chainSawBuffer = self.chainSawBuffer + delta
        end
        if self.chainSawBuffer >= self.chainSawBufferMax then
            local x, y, z = getWorldTranslation(self.cutNode)
            g_sawdust:addChipToGround(x, y, z, self.chainSawBuffer, "player")
            self.chainSawBuffer = 0
        end
    end

    return superFunc(self, dt, isActive)
end
