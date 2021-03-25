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

function SawdustEvent:new(isEnabled)
    local e = SawdustEvent:emptyNew()
	e.isEnabled = isEnabled
    return e
end

function SawdustEvent:readStream(streamId, connection)
	self.isEnabled = streamReadBool(streamId)
	self:run(connection)
end

function SawdustEvent:writeStream(streamId, connection)
	streamWriteBool(streamId, self.isEnabled)
end

function SawdustEvent:run(connection)
    if g_server ~= nil and connection:getIsServer() == false then
		SawdustEvent.sendEvent(self.isEnabled)
	else
		g_sawdust:sawdustToggle(self.isEnabled)
	end
end

function SawdustEvent.sendEvent(isEnabled)
    local event = SawdustEvent:new(isEnabled)
	if g_server ~= nil then
		g_server:broadcastEvent(event, true)
	else
		g_client:getServerConnection():sendEvent(event)
	end
end
