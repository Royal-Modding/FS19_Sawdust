---${title}

---@author ${author}
---@version r_version_r
---@date 19/03/2021

SawdustEvent = {}
SawdustEvent_mt = Class(SawdustEvent, Event)

InitEventClass(SawdustEvent, "sawdustEvent")

function SawdustEvent:emptyNew()
    local e = Event:new(SawdustEvent_mt)
    return e
end

function SawdustEvent:new(x, y, z, amountDelta)
    local e = SawdustEvent:emptyNew()
    e.x, e.y, e.z = x, y, z
    e.amountDelta = amountDelta
    return e
end

function SawdustEvent:readStream(streamId, connection)
    self.x = streamReadFloat32(streamId)
    self.y = streamReadFloat32(streamId)
    self.z = streamReadFloat32(streamId)
    self.amountDelta = streamReadFloat32(streamId)
    self:run(connection)
end

function SawdustEvent:writeStream(streamId, connection)
    streamWriteFloat32(streamId, self.x)
    streamWriteFloat32(streamId, self.y)
    streamWriteFloat32(streamId, self.z)
    streamWriteFloat32(streamId, self.amountDelta)
end

function SawdustEvent:run(connection)
    if not connection:getIsServer() then
        g_currentMission.sawdustBase:addChipToGround(self.x, self.y, self.z, self.amountDelta)
    end
end
