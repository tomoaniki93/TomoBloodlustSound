-- Shared client check: Forever is a mainline-API client, not Classic Era.
-- Identical version/interface rule to TomoMod/Core/Compat.lua.
local version, interface = nil, 0
if GetBuildInfo then
    local v, _, _, i = GetBuildInfo()
    version, interface = v, tonumber(i) or 0
end
local major, minor = 0, 0
if type(version) == "string" then
    local a, b = version:match("^(%d+)%.(%d+)")
    major, minor = tonumber(a) or 0, tonumber(b) or 0
end
local mainline = WOW_PROJECT_ID == nil
    or (WOW_PROJECT_MAINLINE ~= nil and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
_G.TomoBloodlustSoundClient = {
    isForever = mainline and ((major == 1 and minor >= 60)
        or (interface >= 16000 and interface < 100000)) or false,
    interface = interface,
    version = version or "unknown",
}
