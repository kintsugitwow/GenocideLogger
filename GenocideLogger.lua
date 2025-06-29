GENOCIDE_LOGGER_STATUS = {
    Total = 0,
    Units = {},
    Zones = {},
}


local EventFrame = CreateFrame("frame")

local strfind = string.find
local strsub = string.sub
local function Print(msg, r, g, b, a)
    DEFAULT_CHAT_FRAME:AddMessage("\124cffffffff[GenocideLogger]:\124r "..tostring(msg), r, g, b, a)
end



EventFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
EventFrame:SetScript("OnEvent", function()
    if (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
        local start, stop = strfind(arg1, " dies.")
        
        if (start and stop) then
            local zone = GetZoneText()
            local name = strsub(arg1, 0, start)

            GENOCIDE_LOGGER_STATUS.Total = GENOCIDE_LOGGER_STATUS.Total + 1
            if (not GENOCIDE_LOGGER_STATUS.Units[name]) then
                GENOCIDE_LOGGER_STATUS.Units[name] = {}
                GENOCIDE_LOGGER_STATUS.Units[name].Count = 0
            end
            GENOCIDE_LOGGER_STATUS.Units[name].Count = GENOCIDE_LOGGER_STATUS.Units[name].Count + 1
            
            if (not GENOCIDE_LOGGER_STATUS.Zones[zone]) then
                GENOCIDE_LOGGER_STATUS.Zones[zone] = {}
                GENOCIDE_LOGGER_STATUS.Zones[zone].Total = 0
                GENOCIDE_LOGGER_STATUS.Zones[zone].Units = {}
            end
            GENOCIDE_LOGGER_STATUS.Zones[zone].Total = GENOCIDE_LOGGER_STATUS.Zones[zone].Total + 1

            if (not GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name]) then
                GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name] = {}
                GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name].Count = 0
            end

            GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name].Count = GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name].Count + 1
        end
    end
end)

--------------------------------------- COMMANDS ------------------------------------------

local function MsgArgs(msg, argCount)
	if (not argCount) then
		argCount = 1
	end

	local args = {}
	local i = 1

	while i < argCount do
		local _, stop = strfind(msg, " ")
		if (stop) then
			args[i] = strsub(msg, 1, stop - 1)
			msg = strsub(msg, stop + 1)
		end
		i = i + 1
	end
	args[i] = msg

	if (not args[1]) then
		args[1] = args[i]
	end

	return args
end


local function IsCmd(cmd, input)
	for k, v in cmd do
		if (v == input) then
			return true
		end
	end
	return false
end


local function CmdStatus(msg)
    local cmd = { "status" }
    local args = MsgArgs(msg, 1)
    if (not IsCmd(cmd, args[1])) then return false end

    Print("\124cff00ffffTotal score:\124r"..tostring(GENOCIDE_LOGGER_STATUS.Total))

    for zoneName, zone in GENOCIDE_LOGGER_STATUS.Zones do
        Print("\124cff00ffff"..zoneName.."\124r status:")
        Print("\124cff00ff00Total:\124r "..tostring(zone.Total))

        for k, v in zone.Units do
            Print("\124cffffff99"..tostring(k)..":\124r "..tostring(v.Count))
        end
    end

    return true
end

local function CmdZoneStatus(msg)
    local cmd = { "status" }
    local args = MsgArgs(msg, 2)
    if (not IsCmd(cmd, args[1])) then return false end
    local zone = args[2]

    if (type(GENOCIDE_LOGGER_STATUS.Zones[zone]) ~= "table") then
        Print("Invalid zone!", 1, 0, 0)
        return true
    end

    Print("\124cff00ffff"..zone.."\124r status:")
    Print("\124cff00ff00Total:\124r "..tostring(GENOCIDE_LOGGER_STATUS.Zones[zone].Total))

    for k, v in GENOCIDE_LOGGER_STATUS.Zones[zone].Units do
        Print("\124cffffff99"..tostring(k)..":\124r "..tostring(v.Count))
    end

    return true
end


local function CmdZoneReset(msg)
    local cmd = { "reset" }
    local args = MsgArgs(msg, 2)
    if (not IsCmd(cmd, args[1])) then return false end
    local zone = args[2]

    if (type(GENOCIDE_LOGGER_STATUS.Zones[zone]) ~= "table") then
        Print("Invalid zone!", 1, 0, 0)
        return true
    end

    Print("Reseting zone data...", 1, 0.5, 0)

    GENOCIDE_LOGGER_STATUS.Total = GENOCIDE_LOGGER_STATUS.Total - GENOCIDE_LOGGER_STATUS.Zones[zone].Total
    for name, unit in GENOCIDE_LOGGER_STATUS.Zones[zone].Units do
        GENOCIDE_LOGGER_STATUS.Units[name].Count = GENOCIDE_LOGGER_STATUS.Units[name].Count - unit.Count
    end
    GENOCIDE_LOGGER_STATUS.Zones[zone] = nil

    return true
end


local function CmdReset(msg)
    local cmd = { "reset" }
    local args = MsgArgs(msg, 1)
    if (not IsCmd(cmd, args[1])) then return false end

    Print("Reseting all zones...", 1, 0.5, 0)

    GENOCIDE_LOGGER_STATUS = {
        Total = 0,
        Units = {},
        Zones = {},
    }

    return true
end



local function CmdListZones(msg)
    local cmd = { "zones", "listzones" }
    local args = MsgArgs(msg, 1)
    if (not IsCmd(cmd, args[1])) then return false end
    Print("Zones:")

    local index = 1
    for k, v in GENOCIDE_LOGGER_STATUS.Zones do
        Print(tostring(index)..". '"..tostring(k).."'")
    end

    return true
end


SLASH_GENOCIDELOGGER1 = "/genocidelogger"
SLASH_GENOCIDELOGGER2 = "/gl"

SlashCmdList["GENOCIDELOGGER"] = function(msg)

    if (CmdListZones(msg)) then return end
    if (CmdStatus(msg)) then return end
    if (CmdZoneStatus(msg)) then return end
    if (CmdReset(msg)) then return end
    if (CmdZoneReset(msg)) then return end

end