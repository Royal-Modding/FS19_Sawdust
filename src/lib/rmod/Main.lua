--- Royal Mod

---@author Royal Modding
---@version 1.4.1.0
---@date 03/12/2020

--- Initialize RoyalMod
---@param rmodDirectory string
function InitRoyalMod(rmodDirectory)
    source(Utils.getFilename("RoyalMod.lua", rmodDirectory))
    g_logManager:devInfo("Royal Mod loaded successfully by " .. g_currentModName)
    return true
end
