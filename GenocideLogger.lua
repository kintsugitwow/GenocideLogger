GENOCIDE_LOGGER_STATUS = {
    Total = 0,
    Units = {},
    Zones = {},
    ZoneNames = {}
}


local EventFrame = CreateFrame("frame")


local strfind = string.find
local strsub = string.sub
local strlower = string.lower
local strgsub = string.gsub
local function Print(msg, r, g, b, a)
    DEFAULT_CHAT_FRAME:AddMessage("\124cffffffff[GenocideLogger]:\124r " .. tostring(msg), r, g, b, a)
end


local function InitSavedVariables()
    if (not GENOCIDE_LOGGER_STATUS.Total) then
        GENOCIDE_LOGGER_STATUS.Total = 0
    end

    if (not GENOCIDE_LOGGER_STATUS.Units) then
        GENOCIDE_LOGGER_STATUS.Units = {}
    end

    if (not GENOCIDE_LOGGER_STATUS.Zones) then
        GENOCIDE_LOGGER_STATUS.Zones = {}
    end

    if (not GENOCIDE_LOGGER_STATUS.ZoneNames) then
        GENOCIDE_LOGGER_STATUS.ZoneNames = {}
    end
end


local function CleanZoneText(zoneText)
    zoneText = strgsub(zoneText, "%[", "")
    zoneText = strgsub(zoneText, "%]", "")
    zoneText = strgsub(zoneText, "%s+$", "")
    zoneText = strlower(zoneText)
    return zoneText
end


local function GetZoneName(zone)
    return tostring((GENOCIDE_LOGGER_STATUS.ZoneNames[zone] or zone) or "")
end


------------------------------------------------------------------------------------------------
-------------------------------------------- EVENTS --------------------------------------------
------------------------------------------------------------------------------------------------



EventFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("VARIABLES_LOADED")

EventFrame:SetScript("OnEvent", function()
    if (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
        local start, stop = strfind(arg1, " dies.")
        
        if (start and stop) then
            local zoneName = GetZoneText()
            local zone = strlower(zoneName)
            local name = strsub(arg1, 0, start - 1)

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

            if (not GENOCIDE_LOGGER_STATUS.ZoneNames[zone]) then
                GENOCIDE_LOGGER_STATUS.ZoneNames[zone] = zoneName
            end

            if (not GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name]) then
                GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name] = {}
                GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name].Count = 0
            end

            GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name].Count = GENOCIDE_LOGGER_STATUS.Zones[zone].Units[name].Count + 1
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Print("\124cff00ffffTotal score: \124r" .. tostring(GENOCIDE_LOGGER_STATUS.Total))
    elseif (event == "VARIABLES_LOADED") then
        InitSavedVariables()
    end
end)



------------------------------------------------------------------------------------------------
------------------------------------------- COMMANDS -------------------------------------------
------------------------------------------------------------------------------------------------



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



local function CmdListZones(msg)
    local cmd = { "zones", "listzones" }
    local args = MsgArgs(msg, 1)
    if (not IsCmd(cmd, args[1])) then return false end
    Print("Zones:")

    local index = 1
    for zoneName, zone in GENOCIDE_LOGGER_STATUS.Zones do
        Print(tostring(index) .. ". \124cff00ffff[" .. GetZoneName(zoneName) .. "]\124r")
        index = index + 1
    end

    return true
end


local function CmdStatus(msg)
    local cmd = { "status" }
    local args = MsgArgs(msg, 1)
    if (not IsCmd(cmd, args[1])) then return false end

    Print("\124cff00ffffTotal score: \124r" .. tostring(GENOCIDE_LOGGER_STATUS.Total))

    for zoneName, zone in GENOCIDE_LOGGER_STATUS.Zones do
        Print("\124cff00ffff[" .. GetZoneName(zoneName) .. "]\124r status:")
        Print("\124cff00ff00Total: \124r " .. tostring(zone.Total))

        for unitName, unit in zone.Units do
            Print("\124cffffff99" .. tostring(unitName) .. ":\124r " .. tostring(unit.Count))
        end
    end

    return true
end


local function CmdZoneStatus(msg)
    local cmd = { "status" }
    local args = MsgArgs(msg, 2)
    if (not IsCmd(cmd, args[1])) then return false end
    local zone = CleanZoneText(args[2])

    if (type(GENOCIDE_LOGGER_STATUS.Zones[zone]) ~= "table") then
        Print("\124cffff0000Invalid zone!\124r")
        return true
    end

    Print("\124cff00ffff[" .. GetZoneName(zone) .. "]\124r status:")
    Print("\124cff00ff00Total: \124r " .. tostring(GENOCIDE_LOGGER_STATUS.Zones[zone].Total))

    for k, v in GENOCIDE_LOGGER_STATUS.Zones[zone].Units do
        Print("\124cffffff99" .. tostring(k) .. ":\124r " .. tostring(v.Count))
    end

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
        ZoneNames = {},
    }

    return true
end


local function CmdZoneReset(msg)
    local cmd = { "reset" }
    local args = MsgArgs(msg, 2)
    if (not IsCmd(cmd, args[1])) then return false end
    local zone = CleanZoneText(args[2])

    if (type(GENOCIDE_LOGGER_STATUS.Zones[zone]) ~= "table") then
        Print("\124cffff0000Invalid zone!\124r")
        return true
    end

    Print("Reseting " .. GetZoneName(zone) .. " data...", 1, 0.5, 0)

    GENOCIDE_LOGGER_STATUS.Total = GENOCIDE_LOGGER_STATUS.Total - GENOCIDE_LOGGER_STATUS.Zones[zone].Total
    for name, unit in GENOCIDE_LOGGER_STATUS.Zones[zone].Units do
        GENOCIDE_LOGGER_STATUS.Units[name].Count = GENOCIDE_LOGGER_STATUS.Units[name].Count - unit.Count
    end
    GENOCIDE_LOGGER_STATUS.Zones[zone] = nil

    return true
end


local function CmdExport(msg)
    local cmd = { "export" }
    local args = MsgArgs(msg, 1)
    if (not IsCmd(cmd, args[1])) then return false end

    local content = "Total score: " .. tostring(GENOCIDE_LOGGER_STATUS.Total) .. "\n\n"

    for zoneName, zone in GENOCIDE_LOGGER_STATUS.Zones do
        content = content .. "["..GetZoneName(zoneName) .. "] status:\n"
        content = content .. "Total: " .. tostring(zone.Total) .. "\n"
    
        for unitName, unit in zone.Units do
            content = content .. "" .. tostring(unitName) .. ": " .. tostring(unit.Count) .. "\n"
        end
        content = content .. "\n"
    end

    local dateTable = date("*t")
    local time = string.format("%04d-%02d-%02d_%02d-%02d-%02d",
        dateTable.year,
        dateTable.month,
        dateTable.day,
        dateTable.hour,
        dateTable.min,
        dateTable.sec)

    local filename = "GenocideLogger_" .. time
    local result = ExportFile(filename, content)
    if (result == 1) then
        Print("Export saved as \124cff00ff00" .. filename .. "\124r.")
    else
        Print("\124cffff0000Failed to export file.\124r")
    end

    return true
end


local function CmdZoneExport(msg)
    local cmd = { "export" }
    local args = MsgArgs(msg, 2)
    if (not IsCmd(cmd, args[1])) then return false end
    local zone = CleanZoneText(args[2])

    if (type(GENOCIDE_LOGGER_STATUS.Zones[zone]) ~= "table") then
        Print("\124cffff0000Invalid zone!\124r")
        return true
    end

    local content = "[" .. GetZoneName(zone) .. "] status:\n"
    content = content .. "Total: " .. tostring(GENOCIDE_LOGGER_STATUS.Zones[zone].Total) .. "\n"

    for unitName, unit in GENOCIDE_LOGGER_STATUS.Zones[zone].Units do
        content = content .. tostring(unitName) .. ": " .. tostring(unit.Count) .. "\n"
    end

    local dateTable = date("*t")
    local time = string.format("%04d-%02d-%02d_%02d-%02d-%02d",
        dateTable.year,
        dateTable.month,
        dateTable.day,
        dateTable.hour,
        dateTable.min,
        dateTable.sec)

    local filename = "GenocideLogger_" .. time .. "_" .. GetZoneName(zone)
    local result = ExportFile(filename, content)
    if (result == 1) then
        Print("Export saved as \124cff00ff00" .. filename .. "\124r.")
    else
        Print("\124cffff0000Failed to export file.\124r")
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
    if (CmdExport(msg)) then return end
    if (CmdZoneExport(msg)) then return end

end