--[[
Author:			Mimma @ <EU-Pyrewood Village>
Create Date:	2015-05-10 17:50:57

The latest version of Thaliz can always be found at:
(tbd)

The source code can be found at Github:
https://github.com/Sentilix/thaliz-classic

Please see the ReadMe.txt for addon details.
]]

local _, Thaliz = ...

-- Create the AceAddon instance
Thaliz = LibStub("AceAddon-3.0"):NewAddon(Thaliz, _, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(_, true)


local currentVersion				= 0
local updateMessageShown			= false


--	List of valid class names with priority and resurrection spell name (if any)
--	classname, priority, ress spellname
local CLASS_INFO = {
	{ "Druid",   40, L["Rebirth"]			},
	{ "Hunter",  30, nil					},
	{ "Mage",    40, nil					},
	{ "Paladin", 50, L["Redemption"]		},
	{ "Priest",  50, L["Resurrection"]		},
	{ "Rogue",   10, nil					},
	{ "Shaman",  50, L["Ancestral Spirit"]	},
	{ "Warlock", 30, nil					},
	{ "Warrior", 20, nil					}
}


local isPaladin = false
local isPriest = false
local isShaman = false
local isDruid = false
local isResser = false

local rezBtnPassive		= ""
local rezBtnActive		= ""

-- List of blacklisted (already ressed) people
local blacklistedTable = {}

local doScanRaid = true
local scanFrequency = 0.2		-- Scan 5 times per second

local configurationLevel

local debugFunction = nil

-- Persisted information:
Thaliz_Options = { }


function Thaliz:OnInitialize()
	currentVersion = Thaliz_CalculateVersion( GetAddOnMetadata(_, "Version") )

	Thaliz:Echo(string.format("version %s by %s.", GetAddOnMetadata(_, "Version"), GetAddOnMetadata(_, "Author")))

	Thaliz:RegisterEvents()
	Thaliz:RegisterOnUpdate()

	C_ChatInfo.RegisterAddonMessagePrefix(Thaliz.constant.MESSAGE_PREFIX)

	Thaliz_InitClassSpecificStuff()

	Thaliz_RepositionateButton(RezButton)

	Thaliz_InitializeConfigSettings()

	Thaliz:SetupOptions()
end

function Thaliz:OnEnable()
    -- Called when the addon is enabled
end

function Thaliz:OnDisable()
    -- Called when the addon is disabled
end


--[[
	Echo a message for the local user only.
]]
local function echo(msg)
	if msg then
		DEFAULT_CHAT_FRAME:AddMessage(Thaliz.constant.COLOUR_CHAT .. msg .. Thaliz.constant.CHAT_END)
	end
end

--[[
	Echo in raid chat (if in raid) or party chat (if not)
]]
local function partyEcho(msg)
	if IsInRaid() then
		SendChatMessage(msg, Thaliz.constant.RAID_CHANNEL)
	elseif Thaliz:IsInParty() then
		SendChatMessage(msg, Thaliz.constant.PARTY_CHANNEL)
	end
end

--[[
	Echo a message for the local user only, including Thaliz "logo"
]]
function Thaliz:Echo(msg)
	echo("<"..Thaliz.constant.COLOUR_INTRO.."THALIZ"..Thaliz.constant.COLOUR_CHAT.."> "..msg)
end


--  *******************************************************
--
--	Configuration functions
--
--  *******************************************************

-- 
-- TODO: restore priorities into the new config dialog
-- 
function Thaliz_RefreshVisibleMessageList(offset)
--	echo(string.format("Thaliz_RefreshVisibleMessageList: Offset=%d", offset))
	local macros = Thaliz:GetResurrectionMessages()

	-- Set a priority on each spell, and then sort them accordingly:
	local macro, grp, prm, prio
	for n=1, table.getn(macros), 1 do
		grp = macros[n][2]
		prm = macros[n][3]
		if grp == Thaliz.constant.EMOTE_GROUP_GUILD then
			prio = 20
		elseif grp == Thaliz.constant.EMOTE_GROUP_CHARACTER then
			prio = 30
		elseif grp == Thaliz.constant.EMOTE_GROUP_CLASS then
			-- Class names are listed alphabetically:
			prio = 50
			if prm == "Druid" then
				prio = 59
			elseif prm == "Hunter" then
				prio = 58
			elseif prm == "Mage" then
				prio = 57
			elseif prm == "Paladin" then
				prio = 56
			elseif prm == "Priest" then
				prio = 55
			elseif prm == "Rogue" then
				prio = 54
			elseif prm == "Shaman" then
				prio = 53
			elseif prm == "Warlock" then
				prio = 52
			elseif prm == "Warrior" then
				prio = 51
			end
		elseif grp == Thaliz.constant.EMOTE_GROUP_RACE then
			prio = 40
			-- Racess are listed by faction, race name:
			if prm == "Dwarf" then
				prio = 49
			elseif prm == "Gnome" then
				prio = 48
			elseif prm == "Human" then
				prio = 47
			elseif prm == "Night Elf" then
				prio = 46
			elseif prm == "Orc" then
				prio = 45
			elseif prm == "Tauren" then
				prio = 44
			elseif prm == "Troll" then
				prio = 43
			elseif prm == "Undead" then
				prio = 42
			end
		elseif grp == Thaliz.constant.EMOTE_GROUP_DEFAULT then
			prio = 0
		end
		macros[n][4] = prio
	end

	Thaliz_SortTableDescending(macros, 4)

	for n=1, Thaliz.constant.MAX_VISIBLE_MESSAGES, 1 do
		macro = macros[n + offset]
		if not macro then
			macro = { "", Thaliz.constant.EMOTE_GROUP_DEFAULT, "" }
		end

		local msg = Thaliz_CheckMessage(macro[1])
		local grp = Thaliz_CheckGroup(macro[2])
		local prm = Thaliz_CheckGroupValue(macro[3])

		--echo(string.format("-> Msg=%s, Grp=%s, Value=%s", msg, grp, prm))

		local grpColor = { 0.5, 0.5, 0.5 }
		local prmColor = { 0.5, 0.5, 0.5 }

		prm = string.upper(prm)

		if grp == Thaliz.constant.EMOTE_GROUP_GUILD then
			grpColor = { 0.0, 1.0, 0.0 }
			prmColor = { 0.8, 0.8, 0.0 }
		elseif grp == Thaliz.constant.EMOTE_GROUP_CHARACTER then
			grpColor = { 0.8, 0.8, 0.8 }
			prmColor = { 0.8, 0.8, 0.0 }
		elseif grp == Thaliz.constant.EMOTE_GROUP_CLASS then
			grpColor = { 0.8, 0.0, 1.0 }

			if prm == "DRUID" then
				prmColor = { 1.00, 0.49, 0.04 }
			elseif prm == "HUNTER" then
				prmColor = { 0.67, 0.83, 0.45 }
			elseif prm == "MAGE" then
				prmColor = { 0.41, 0.80, 0.94 }
			elseif prm == "PALADIN" then
				prmColor = { 0.96, 0.55, 0.73 }
			elseif prm == "PRIEST" then
				prmColor = { 1.00, 1.00, 1.00 }
			elseif prm == "ROGUE" then
				prmColor = { 1.00, 0.96, 0.41 }
			elseif prm == "SHAMAN" then
				prmColor = { 0.96, 0.55, 0.73 }
			elseif prm == "WARLOCK" then
				prmColor = { 0.58, 0.51, 0.79 }
			elseif prm == "WARRIOR" then
				prmColor = { 0.78, 0.61, 0.43 }
			end
		elseif grp == Thaliz.constant.EMOTE_GROUP_RACE then
			grpColor = { 0.80, 0.80, 0.00 }
			if prm == "DWARF" or prm == "GNOME" or prm == "HUMAN"  or prm == "NIGHT ELF" then
				grpColor = { 0.00, 0.50, 1.00 }
			elseif prm == "ORC" or prm == "TAUREN" or prm == "TROLL"  or prm == "UNDEAD" then
				grpColor = { 1.00, 0.00, 0.00 }
			end
			prmColor = grpColor
		end
	end
end


function Thaliz_GetRootOption(parameter, defaultValue)
	if Thaliz_Options then
		if Thaliz_Options[parameter] then
			local value = Thaliz_Options[parameter]
			if (type(value) == "table") or not(value == "") then
				return value
			end
		end
	end

	return defaultValue
end

function Thaliz_SetRootOption(parameter, value)
	if not Thaliz_Options then
		Thaliz_Options = {}
	end

	Thaliz_Options[parameter] = value
end

function Thaliz:GetOption(parameter, defaultValue)
	local realmname = GetRealmName()
	local playername = UnitName("player")

	if configurationLevel == "Character" then
		-- Character level
		if Thaliz_Options[realmname] then
			if Thaliz_Options[realmname][playername] then
				if Thaliz_Options[realmname][playername][parameter] then
					local value = Thaliz_Options[realmname][playername][parameter]
					if (type(value) == "table") or not(value == "") then
						return value
					end
				end
			end
		end
	else
		-- Realm level:
		if Thaliz_Options[realmname] then
			if Thaliz_Options[realmname][parameter] then
				local value = Thaliz_Options[realmname][parameter]
				if (type(value) == "table") or not(value == "") then
					return value
				end
			end
		end
	end

	return defaultValue
end

function Thaliz:SetOption(parameter, value)
	local realmname = GetRealmName()
	local playername = UnitName("player")

	if configurationLevel == "Character" then
		-- Character level:
		if not Thaliz_Options[realmname] then
			Thaliz_Options[realmname] = {}
		end

		if not Thaliz_Options[realmname][playername] then
			Thaliz_Options[realmname][playername] = {}
		end

		Thaliz_Options[realmname][playername][parameter] = value
	else
		-- Realm level:
		if not Thaliz_Options[realmname] then
			Thaliz_Options[realmname] = {}
		end

		Thaliz_Options[realmname][parameter] = value
	end
end

function Thaliz_InitializeConfigSettings()
	if not Thaliz_Options then
		Thaliz_options = { }
	end

	Thaliz_SetRootOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, Thaliz_GetRootOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, Thaliz.constant.CONFIGURATION_DEFAULT_LEVEL))
	configurationLevel = Thaliz_GetRootOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, Thaliz.constant.CONFIGURATION_DEFAULT_LEVEL)

	Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL, Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL, Thaliz.constant.TARGET_CHANNEL_DEFAULT))
	Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER, Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER, Thaliz.constant.TARGET_WHISPER_DEFAULT))
	Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_WHISPER_MESSAGE, Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_WHISPER_MESSAGE, Thaliz.constant.RESURRECTION_WHISPER_MESSAGE_DEFAULT))
	Thaliz:SetOption(Thaliz.constant.OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP, Thaliz:GetOption(Thaliz.constant.OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP, Thaliz.constant.INCLUDE_DEFAULT_GROUP_DEFAULT))

	local x,y = RezButton:GetPoint()
	Thaliz:SetOption(Thaliz.constant.OPTION_REZ_BUTTON_POS_X, Thaliz:GetOption(Thaliz.constant.OPTION_REZ_BUTTON_POS_X, x))
	Thaliz:SetOption(Thaliz.constant.OPTION_REZ_BUTTON_POS_Y, Thaliz:GetOption(Thaliz.constant.OPTION_REZ_BUTTON_POS_Y, y))

	Thaliz_ValidateResurrectionMessages()
end

function Thaliz_ValidateResurrectionMessages()
	local macros = Thaliz:GetResurrectionMessages()
	local changed = false

	for n=1, table.getn( macros ), 1 do
		local macro = macros[n]

		if type(macro) == "table" then
			-- Macro is fine; do nothing
		else
			-- Macro is ... hmmm beyond repair?; reset it:
			macros[n] = { "", Thaliz.constant.EMOTE_GROUP_DEFAULT, "" }
			changed = true
		end
	end

	if changed then
		Thaliz:SetResurrectionMessages(macros)
	end
end

function Thaliz_GetUnitID(playername)
	local groupsize, grouptype

	groupsize = GetNumGroupMembers()
	if IsInRaid() then
		grouptype = "raid"
	else
		grouptype = "party"
	end

	for n=1, groupsize, 1 do
		unitid = grouptype..n
		if UnitName(unitid) == playername then
			return unitid
		end
	end

	return nil
end

--[[
	Convert a msg so first letter is uppercase, and rest as lower case.
]]
function Thaliz_UCFirst(playername)
	if not playername then
		return ""
	end

	-- Handles utf8 characters in beginning.. Ugly, but works:
	local offset = 2
	local firstletter = string.sub(playername, 1, 1)
	if(not string.find(firstletter, '[a-zA-Z]')) then
		firstletter = string.sub(playername, 1, 2)
		offset = 3
	end

	return string.upper(firstletter) .. string.lower(string.sub(playername, offset))
end


--  *******************************************************
--
--	Resurrect message functions
--
--  *******************************************************
function Thaliz_AnnounceResurrection(playername, unitid)
	if (Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL) == "NONE" and Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_WHISPER_MESSAGE) == 0) then
		return
	end

	if not unitid then
		unitid = Thaliz_GetUnitID(playername)

		if not unitid then
			return
		end
	end

	local guildname = GetGuildInfo(unitid)
	local race = string.upper(UnitRace(unitid))
	local classname = string.upper(Thaliz_UnitClass(unitid))
	local charname = string.upper(playername)

	if guildname then
		UCGuildname = string.upper(guildname)
	else
		-- Note: guildname is unfortunately not detected for released corpses.
		guildname = "(No Guild)"
		UCGuildname = ""
	end

	--echo(string.format("Ressing: player=%s, unitid=%s", playername, unitid))
	--echo(string.format("Guild=%s, class=%s, race=%s", guildname, class, race))

	-- This is a list of ALL messages.
	-- Now identify the macros suitable for this player only:
	local dmacro = { }		-- Default macros
	local gmacro = { }		-- Guild macros
	local nmacro = { }		-- character Name macros
	local cmacro = { }		-- Class macros
	local rmacro = { }		-- Race macros

	local didx = 0
	local gidx = 0
	local nidx = 0
	local cidx = 0
	local ridx = 0

	local macros = Thaliz:GetResurrectionMessages()
	for n=1, table.getn( macros ), 1 do
		local macro = macros[n]
		local param = ""
		if macro[3] then
			param = string.upper(macro[3])
		end

		if macro[2] == Thaliz.constant.EMOTE_GROUP_DEFAULT then
			didx = didx + 1
			dmacro[ didx ] = macro
		elseif macro[2] == Thaliz.constant.EMOTE_GROUP_GUILD then
			if param == UCGuildname then
				gidx = gidx + 1
				gmacro[ gidx ] = macro
			end
		elseif macro[2] == Thaliz.constant.EMOTE_GROUP_CHARACTER then
			if param == charname then
				nidx = nidx + 1
				nmacro[ nidx ] = macro
			end
		elseif macro[2] == Thaliz.constant.EMOTE_GROUP_CLASS then
			if param == classname then
				cidx = cidx + 1
				cmacro[ cidx ] = macro
			end
		elseif macro[2] == Thaliz.constant.EMOTE_GROUP_RACE then
			if param == race then
				ridx = ridx + 1
				rmacro[ ridx ] = macro
			end
		end
	end

	-- Now generate list, using the found criterias above:
	local macros = { }
	local index = 0
	for n=1, table.getn( gmacro ), 1 do
		index = index + 1
		macros[index] = gmacro[n]
	end
	for n=1, table.getn( nmacro ), 1 do
		index = index + 1
		macros[index] = nmacro[n]
	end
	for n=1, table.getn( cmacro ), 1 do
		index = index + 1
		macros[index] = cmacro[n]
	end
	for n=1, table.getn( rmacro ), 1 do
		index = index + 1
		macros[index] = rmacro[n]
	end

	-- Include the messages targetting everyone if:
	-- * There is no messages matching the group rule, or
	-- * The "Add messages for everyone to the list of targeted messages" option is selected.
	if table.getn(macros) == 0 or
		Thaliz:GetOption(Thaliz.constant.OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP) == 1 then
		for n=1, table.getn( dmacro ), 1 do
			index = index + 1
			macros[index] = dmacro[n]
		end
	end


	local validMessages = {}
	local validCount = 0
	for n=1, table.getn( macros ), 1 do
		local msg = macros[n][1]
		if msg and not (msg == "") then
			validCount = validCount + 1
			validMessages[ validCount ] = msg
		end
	end

	-- Fallback message if none are configured
	if validCount == 0 then
		validMessages[1] = "Resurrecting %s"
		validCount = 1
	end

	local message = validMessages[ math.random(validCount) ]
	message = string.gsub(message, "%%c", Thaliz_UCFirst(classname))
	message = string.gsub(message, "%%r", Thaliz_UCFirst(race))
	message = string.gsub(message, "%%g", guildname)
	message = string.gsub(message, "%%s", playername)

	local targetChannel = Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL)

	if not IsInInstance() then
		if targetChannel == "SAY" or targetChannel == "YELL" then
			targetChannel = "RAID"
		end
	end

	if targetChannel == "RAID" then
		partyEcho(message)
	elseif targetChannel == "SAY" then
		SendChatMessage(message, Thaliz.constant.SAY_CHANNEL)
	elseif targetChannel == "YELL" then
		SendChatMessage(message, Thaliz.constant.YELL_CHANNEL)
	else
		echo(message)
	end

	if Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER) == 1 then
		local whisperMsg = Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_WHISPER_MESSAGE)
		if whisperMsg and not(whisperMsg == "") then
			SendChatMessage(whisperMsg, "WHISPER", nil, playername)
		end
	end
end

function Thaliz:GetResurrectionMessages()
	local messages = Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGES, nil)

	if (not messages) or not(type(messages) == "table") or (table.getn(messages) == 0) then
		messages = Thaliz_ResetResurrectionMessages()
	end

	return messages
end

function Thaliz:GetResurrectionMessage(index)
	local messages = Thaliz:GetResurrectionMessages()

	return messages[index]
end

function Thaliz_RenumberTable(sourcetable)
	local index = 1
	local temptable = { }

	for key, value in next, sourcetable do
		temptable[index] = value
		index = index + 1
	end
	return temptable
end

function Thaliz:DeleteResurrectionMessage(index)
	local messages = Thaliz:GetResurrectionMessages()

	table.remove(messages, index)

	Thaliz:SetResurrectionMessages(messages)
end

function Thaliz:SetResurrectionMessages(resurrectionMessages)
	Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGES, Thaliz_RenumberTable(resurrectionMessages))
end

function Thaliz:SetResurrectionMessage(messageIndex, propertyIndex, value)
	local messages = Thaliz:GetResurrectionMessages()

	messages[messageIndex][propertyIndex] = value

	Thaliz:SetResurrectionMessages(messages)
end

function Thaliz_ResetResurrectionMessages()
	local messages = {}

	for key, message in pairs(L["Default Messages"]) do
		messages[key] = { message, Thaliz.constant.EMOTE_GROUP_DEFAULT, "" }
	end

	Thaliz:SetResurrectionMessages( messages )

	return Thaliz:GetResurrectionMessages()
end

function Thaliz_CheckMessage(msg)
	if not msg or msg == "" then
		msg = Thaliz.constant.EMPTY_MESSAGE
	end
	return msg
end

function Thaliz_CheckGroup(group)
	if not group or group == "" then
		group = Thaliz.constant.EMOTE_GROUP_DEFAULT
	end
	return group
end

function Thaliz_CheckGroupValue(param)
	if not param then
		param = ""
	end
	return param
end

function Thaliz:UpdateResurrectionMessage(index, offset, message, group, param)
	group = Thaliz_CheckGroup(group)
	param = Thaliz_CheckGroupValue(param)
	--echo(string.format("Updating message, Index=%d, offset=%d, msg=%s, grp=%s, val=%s", index, offset, message, group, param))

	local messages = Thaliz:GetResurrectionMessages()
	messages[index + offset] = { message, group, param }

	Thaliz:SetResurrectionMessages( messages )
end



--  *******************************************************
--
--	Ressing functions
--
--  *******************************************************

--[[
Scan the entire raid / group for corpses, and activate
ress button if anyone found.
--]]
function Thaliz_ScanRaid()
	local debug = (debugFunction and debugFunction == "Thaliz_ScanRaid")

	if not doScanRaid then
		Thaliz_SetRezTargetText()
		if(debug) then
			echo("**DEBUG**: doScanRaid=false")
		end
		return
	end

	--	Jesus, this class can't even ress!! Disable event
	if not isResser then
		doScanRaid = false
		Thaliz_HideResurrectionButton()

		if(debug) then
			echo("**DEBUG**: isResser=false")
		end
		return
	end

	-- Doh, 1! Can't ress while dead!
	if UnitIsDeadOrGhost("player") then
		Thaliz_SetRezTargetText()
		Thaliz_SetButtonTexture(Thaliz.constant.REZBTN_DEAD)

		if(debug) then
			echo("**DEBUG**: UnitIsDeadOrGhost=true")
		end
		return
	end

	-- Doh, 2! Can't ress while in combat. Sorry druids, you get a LUA error if you try :-(
	if UnitAffectingCombat("player") then
		Thaliz_SetRezTargetText()
		Thaliz_SetButtonTexture(Thaliz.constant.REZBTN_COMBAT)

		if(debug) then
			echo("**DEBUG**: UnitAffectingCombat=true")
		end
		return
	end

	local groupsize = GetNumGroupMembers()
	if groupsize == 0 then
		Thaliz_HideResurrectionButton()

		if(debug) then
			echo("**DEBUG**: GetNumGroupMembers=0")
		end
		return
	end

	classinfo = Thaliz_GetClassinfo(Thaliz_UnitClass("player"))
	local spellname = classinfo[3]

	local grouptype = "party"
	if IsInRaid() then
		grouptype = "raid"
	end

	local unitid
	local warlocksAlive = false
	for n=1, groupsize, 1 do
		unitid = grouptype..n
		if not UnitIsDead(unitid) and UnitIsConnected(unitid) and UnitIsVisible(unitid) and Thaliz_UnitClass(unitid) == "WARLOCK" then
			warlocksAlive = true
			break
		end
	end

	Thaliz_CleanupBlacklistedPlayers()

	--Fetch current assigned target (if any):
	local currentPrio = 0
	local highestPrio = 0
	local currentIsValid = false
	local currentTarget = ""
	unitid = RezButton:GetAttribute("unit")
	if unitid then
		currentTarget = UnitName(unitid)
	end

	local targetprio
	local corpseTable = { }
	local playername, classinfo
	for n=1, groupsize, 1 do
		unitid = grouptype..n
		playername = UnitName(unitid)

		local isBlacklisted = false
		for b=1, table.getn(blacklistedTable), 1 do
			blacklistInfo = blacklistedTable[b]
			blacklistTick = blacklistInfo[2]

			if blacklistInfo[1] == playername then
				isBlacklisted = true
				if(debug) then
					echo(string.format("**DEBUG**: Player %s is blacklisted ...", playername))
				end
				break
			end
		end

		targetname = UnitName("playertarget")

		if (isBlacklisted == false) and
				UnitIsDead(unitid) and
				(UnitHasIncomingResurrection(unitid) == false) and
				UnitIsConnected(unitid) and
				UnitIsVisible(unitid) and
				(IsSpellInRange(spellname, unitid) == 1) then
			classinfo = Thaliz_GetClassinfo(Thaliz_UnitClass(unitid))
			targetprio = classinfo[2]
			if targetname and targetname == playername then
				targetprio = Thaliz.constant.PRIORITY_TO_CURRENT_TARGET
			end

--	IsRaidLeader(): removed in wow 5.0 and thereby Classic!
--			if IsRaidLeader(playername) and targetprio < Thaliz.constant.PRIORITY_TO_GROUP_LEADER then
--				targetprio = Thaliz.constant.PRIORITY_TO_GROUP_LEADER
--			end
			if not warlocksAlive and classinfo[1] == "Warlock" then
				targetprio = Thaliz.constant.PRIORITY_TO_FIRST_WARLOCK
			end

			-- Check if the current target is still eligible for ress:
			if playername == currentTarget then
				currentPrio = targetprio
				currentIsValid = true
			end

			if targetprio > highestPrio then
				highestPrio = targetprio
			end

			-- Add a random decimal factor to priority to spread ressings out.
			-- Random is a float between 0 and 1:
			targetprio = targetprio + math.random()

			--echo(string.format("%s added, unitid=%s, priority=%f", playername, unitid, targetprio))
			corpseTable[ table.getn(corpseTable) + 1 ] = { unitid, targetprio } 
		end
	end

	if (table.getn(corpseTable) == 0) then
		Thaliz_HideResurrectionButton()

		if(debug) then
			echo("**DEBUG**: corpseTable=(empty)")
		end
		return
	end

	if highestPrio > currentPrio then
		currentIsValid = false
	end


	if not currentIsValid then
		-- We found someone (or a new person) to ress.
		-- Sort the corpses with highest priority in top:
		Thaliz_SortTableDescending(corpseTable, 2)

		unitid = corpseTable[1][1]

		if(debug) then
			if not spellname then spellname = "nil" end
			echo(string.format("**DEBUG**: corpse=%s, unitid=%s, spell=%s", UnitName(unitid), unitid, spellname))
		end

		RezButton:SetAttribute("type", "spell")
		RezButton:SetAttribute("spell", spellname)
		RezButton:SetAttribute("unit", unitid)
	end

	Thaliz_SetRezTargetText(UnitName(unitid))
	Thaliz_SetButtonTexture(rezBtnActive, true)
end


function Thaliz_OnRezClick(self)
	Thaliz_BroadcastResurrection(self)
end


function Thaliz_BroadcastResurrection(self)
	local unitid = self:GetAttribute("unit")
	if not unitid then
		return
	end

	local playername = UnitName(unitid)

	Thaliz:SendAddonMessage(string.format("TX_RESBEGIN#%s#", playername))
end


function Thaliz_SetRezTargetText(playername)
	if not playername then
		playername = ""
	end

	RezButton.title:SetText(playername)
end


function Thaliz_HideResurrectionButton()
	Thaliz_SetButtonTexture(rezBtnPassive)
	RezButton:SetAttribute("type", nil)
	RezButton:SetAttribute("unit", nil)
	Thaliz_SetRezTargetText()
end


function Thaliz_InitClassSpecificStuff()
	local debug = (debugFunction and debugFunction == "Thaliz_Init")
	local classname = Thaliz_UnitClass("player")

	if(debug) then
		if not classname then classname = "nil" end
		echo(string.format("**DEBUG**: [Thaliz_InitClassSpecificStuff] classname=%s", classname))
	end


	rezBtnPassive = Thaliz.constant.ICON_OTHER_PASSIVE
	rezBtnActive = Thaliz.constant.ICON_OTHER_PASSIVE
	if classname == "DRUID" then
		isDruid = true
		isResser = true
		rezBtnPassive = Thaliz.constant.ICON_DRUID_PASSIVE
		rezBtnActive = Thaliz.constant.ICON_DRUID_ACTIVE
	elseif classname == "PALADIN" then
		isPaladin = true
		isResser = true
		rezBtnPassive = Thaliz.constant.ICON_PALADIN_PASSIVE
		rezBtnActive = Thaliz.constant.ICON_PALADIN_ACTIVE
	elseif classname == "PRIEST" then
		isPriest = true
		isResser = true
		rezBtnPassive = Thaliz.constant.ICON_PRIEST_PASSIVE
		rezBtnActive = Thaliz.constant.ICON_PRIEST_ACTIVE
	elseif classname == "SHAMAN" then
		isShaman = true
		isResser = true
		rezBtnPassive = Thaliz.constant.ICON_SHAMAN_PASSIVE
		rezBtnActive = Thaliz.constant.ICON_SHAMAN_ACTIVE
	end
end

local RezButtonLastTexture = ""
function Thaliz_SetButtonTexture(textureName, isEnabled)
	local alphaValue = 0.5
	if isEnabled then
		alphaValue = 1.0
	end

	if RezButtonLastTexture ~= textureName then
		RezButtonLastTexture = textureName
		RezButton:SetAlpha(alphaValue)
		RezButton:SetNormalTexture(textureName)
	end
end


function Thaliz_GetClassinfo(classname)
	local debug = (debugFunction and debugFunction == "Thaliz_GetClassinfo")

	classname = Thaliz_UCFirst(classname)
	for key, val in next, CLASS_INFO do
		if val[1] == classname then
			if(debug) then
				if not classname then classname = "nil" end
				echo(string.format("**DEBUG**: classname=%s, info=True", classname))
			end

			return val
		end
	end

	if(debug) then
		if not classname then classname = "nil" end
		echo(string.format("**DEBUG**: classname=%s, info=False", classname))
	end

	return nil
end



--  *******************************************************
--
--	Blacklisting functions
--
--  *******************************************************
function Thaliz_BlacklistPlayer(playername, blacklistTime)
	if not blacklistTime then
		blacklistTime = Thaliz.constant.BLACKLIST_TIMEOUT
	end

	local timerTick = Thaliz_GetTimerTick()

	if Thaliz_IsPlayerBlacklisted(playername) then
		-- Player is already blacklisted; if the current blacklist time is higher than
		-- the remaining blacklist value, we need to replace the current time with the
		-- requested time.
		for b=1, table.getn(blacklistedTable), 1 do
			local blacklistInfo = blacklistedTable[b]
			if blacklistInfo[1] == playername then
				local remainingTime = blacklistInfo[2] - timerTick
				if remainingTime < blacklistTime then
					blacklistedTable[b][2] = timerTick + blacklistTime
				end
				break
			end
		end
	else
		blacklistedTable[ table.getn(blacklistedTable) + 1 ] = { playername, timerTick + blacklistTime }
	end
end

--[[
	Remove player from Blacklist (if any)
]]
function Thaliz_WhitelistPlayer(playername)
	local WhitelistTable = {}
	--echo("Whitelisting "..playername)

	for n=1, table.getn(blacklistedTable), 1 do
		blacklistInfo = blacklistedTable[n]
		if not (playername == blacklistInfo[1]) then
			WhitelistTable[ table.getn(WhitelistTable) + 1 ] = blacklistInfo
		end
	end
	blacklistedTable = WhitelistTable
end


function Thaliz_IsPlayerBlacklisted(playername)
	Thaliz_CleanupBlacklistedPlayers()

	for n=1, table.getn(blacklistedTable), 1 do
		if blacklistedTable[n][1] == playername then
			return true
		end
	end
	return false
end


function Thaliz_CleanupBlacklistedPlayers()
	local BlacklistedTableNew = {}
	local blacklistInfo
	local timerTick = Thaliz_GetTimerTick()

	for n=1, table.getn(blacklistedTable), 1 do
		blacklistInfo = blacklistedTable[n]
		if timerTick < blacklistInfo[2] then
			BlacklistedTableNew[ table.getn(BlacklistedTableNew) + 1 ] = blacklistInfo
		end
	end
	blacklistedTable = BlacklistedTableNew
end



--  *******************************************************
--
--	Helper functions
--
--  *******************************************************
function Thaliz_GetPlayerName(nameAndRealm)
	local _, _, name = string.find(nameAndRealm, "([^-]*)-%s*")
	if not name then
		name = nameAndRealm
	end

	return name
end

function Thaliz:IsInParty()
	if not IsInRaid() then
		return ( GetNumGroupMembers() > 0 )
	end
	return false
end

function Thaliz_UnitClass(unitid)
	local _, classname = UnitClass(unitid)
	return classname
end


function Thaliz_SortTableDescending(sourcetable, index)
	local doSort = true
	while doSort do
		doSort = false
		for n=1,table.getn(sourcetable) - 1,1 do
			local a = sourcetable[n]
			local b = sourcetable[n + 1]
			if tonumber(a[index]) and tonumber(b[index]) and tonumber(a[index]) < tonumber(b[index]) then
				sourcetable[n] = b
				sourcetable[n + 1] = a
				doSort = true
			end
		end
	end
end



--  *******************************************************
--
--	Version functions
--
--  *******************************************************

--[[
	Broadcast my version if this is not a beta (CurrentVersion > 0) and
	my version has not been identified as being too low (MessageShown = false)
]]
function Thaliz_OnRaidRosterUpdate(event, ...)
	if currentVersion > 0 and not updateMessageShown then
		if IsInRaid() or Thaliz:IsInParty() then
			local versionstring = GetAddOnMetadata(_, "Version")
			Thaliz:SendAddonMessage(string.format("TX_VERCHECK#%s#", versionstring))
		end
	end
end

function Thaliz_CalculateVersion(versionString)
	local _, _, major, minor, patch = string.find(versionString, "([^\.]*)\.([^\.]*)\.([^\.]*)")
	local version = 0

	if (tonumber(major) and tonumber(minor) and tonumber(patch)) then
		version = major * 100 + minor
		--echo(string.format("major=%s, minor=%s, patch=%s, version=%d", major, minor, patch, version))
	end

	return version
end

function Thalix_CheckIsNewVersion(versionstring)
	local incomingVersion = Thaliz_CalculateVersion( versionstring )

	if (currentVersion > 0 and incomingVersion > 0) then
		if incomingVersion > currentVersion then
			if not updateMessageShown then
				updateMessageShown = true
				Thaliz:Echo(string.format("NOTE: A newer version of ".. Thaliz.constant.COLOUR_INTRO .."THALIZ"..Thaliz.constant.COLOUR_CHAT.."! is available (version %s)!", versionstring))
				Thaliz:Echo(string.format("NOTE: Download the latest version at %s.", GetAddOnMetadata(_, "X-Website")))
			end
		end
	end
end


--  *******************************************************
--
--	Timer functions
--
--  *******************************************************
function Thaliz:RegisterOnUpdate()
	if not self.frame then
		self.frame = CreateFrame("Frame")
	end

	self.frame:SetScript("OnUpdate", Thaliz_OnTimer)
end


local Timers = {}
local TimerTick = 0
local NextScanTime = 0

function Thaliz_OnTimer(self, elapsed)
	TimerTick = TimerTick + elapsed

	if TimerTick > (NextScanTime + scanFrequency) then
		Thaliz_ScanRaid()
		NextScanTime = TimerTick
	end

	for n=1,table.getn(Timers),1 do
		local timer = Timers[n]
		if TimerTick > timer[2] then
			Timers[n] = nil
			timer[1]()
		end
	end
end

function Thaliz_GetTimerTick()
	return TimerTick
end





--  *******************************************************
--
--	Internal Communication Functions
--
--  *******************************************************

function Thaliz:SendAddonMessage(message)
	local memberCount = GetNumGroupMembers()
	if memberCount > 0 then
		local channel = nil
		if IsInRaid() then
			channel = "RAID"
		elseif Thaliz:IsInParty() then
			channel = "PARTY"
		end
		C_ChatInfo.SendAddonMessage(Thaliz.constant.MESSAGE_PREFIX, message, channel)
	end
end



--[[
	Respond to a TX_VERSION command.
	Input:
		msg is the raw message
		sender is the name of the message sender.
	We should whisper this guy back with our current version number.
	We therefore generate a response back (RX) in raid with the syntax:
	Thaliz:<sender (which is actually the receiver!)>:<version number>
]]
function Thaliz_HandleTXVersion(message, sender)
	local response = GetAddOnMetadata(_, "Version")
	Thaliz:SendAddonMessage("RX_VERSION#"..response.."#"..sender)
end

function Thaliz_HandleTXResBegin(message, sender)
	-- Blacklist target unless ress was initated by me
	if not (sender == UnitName("player")) then
		--echo(string.format("*** Remote blacklisting %s (%s is ressing)", message, sender))
		Thaliz_BlacklistPlayer(message)
	end
end

--[[
	A version response (RX) was received. The version information is displayed locally.
]]
function Thaliz_HandleRXVersion(message, sender)
	Thaliz:Echo(string.format("%s is using Thaliz version %s", sender, message))
end

function Thaliz_HandleTXVerCheck(message, sender)
	Thalix_CheckIsNewVersion(message)
end

function Thaliz_OnChatMsgAddon(event, ...)
	local prefix, msg, channel, sender = ...
	if prefix == Thaliz.constant.MESSAGE_PREFIX then
		Thaliz_HandleThalizMessage(msg, Thaliz_GetPlayerName(sender))
	end
end

function Thaliz_HandleThalizMessage(msg, sender)
	local _, _, cmd, message, recipient = string.find(msg, "([^#]*)#([^#]*)#([^#]*)")

	--	Ignore message if it is not for me.
	--	Receipient can be blank, which means it is for everyone.
	if not (recipient == "") then
		if not (recipient == UnitName("player")) then
			return
		end
	end

	if cmd == "TX_VERSION" then
		Thaliz_HandleTXVersion(message, sender)
	elseif cmd == "RX_VERSION" then
		Thaliz_HandleRXVersion(message, sender)
	elseif cmd == "TX_RESBEGIN" then
		Thaliz_HandleTXResBegin(message, sender)
	elseif cmd == "TX_VERCHECK" then
		Thaliz_HandleTXVerCheck(message, sender)
	end
end

function Thaliz_BeginsWith(String, Start)
   return string.sub(String, 1, string.len(Start)) == Start
end


function Thaliz_SpellIsResurrect(spellId)
	local resSpell = false

	if spellId then
		spellId = 1 * spellId

		if isPriest then
			--Resurrection, rank 1=2006, 2=2010, 3=10880, 4=10881, 5=20770:
			if (spellId == 2006) or (spellId == 2010) or (spellId == 10880) or (spellId == 10881) or (spellId == 20770) then
				resSpell = true
			end
		elseif isPaladin then
			if (spellId == 7328) or (spellId == 10322) or (spellId == 10324) or (spellId == 20772) or (spellId == 20773) then
				resSpell = true
			end
		elseif isShaman then
			--Ancestral Spirit, rank 1=2008, 2=20609, 3=20610, 4=20776, 5=20777:
			if (spellId == 2008) or (spellId == 20609) or (spellId == 20610) or (spellId == 20776) or (spellId == 20777) then
				resSpell = true
			end
		elseif isDruid then
			--Rebirth, rank 1=20484, 2=20739, 3=20742, 4=20747, 5=20748:
			if (spellId == 20484) or (spellId == 20739) or (spellId == 20742) or (spellId == 20747) or (spellId == 20748) then
				resSpell = true
			end
		end
	end

	return resSpell
end


--[[
	Return # of seconds left of blacklist timer, nil if not blacklisted
--]]
function Thaliz_IsPlayerBlacklisted(playername)

	for b=1, table.getn(blacklistedTable), 1 do
		local blacklistInfo = blacklistedTable[b]
		if blacklistInfo[1] == playername then
			return (blacklistInfo[2] - TimerTick)
		end
	end
	return nil
end


--  *******************************************************
--
--	Event handlers
--
--  *******************************************************
function Thaliz:RegisterEvents()
	local eventNames = {
		"CHAT_MSG_ADDON",
		"RAID_ROSTER_UPDATE",
		"UNIT_SPELLCAST_START",
		"UNIT_SPELLCAST_STOP",
		"UNIT_SPELLCAST_SENT",
		"INCOMING_RESURRECT_CHANGED",
		"COMBAT_LOG_EVENT_UNFILTERED",
	}

	for k, eventName in ipairs(eventNames) do
		Thaliz:RegisterEvent(eventName, "OnEvent")
	end
end


local SpellcastIsStarted = 0
function Thaliz:OnEvent(event, ...)
	local debug = (debugFunction and debugFunction == "Thaliz_OnEvent")

	if (event == "UNIT_SPELLCAST_SENT") then
		local resser, target, _, spellId = ...
		if(resser == "player") then
			if (target ~= "Unknown") then
				if(debug) then
					echo(string.format("**DEBUG**: UNIT_SPELLCAST_SENT, SpellId=%s", spellId))
				end
				if not Thaliz_IsPlayerBlacklisted(target) then
					if Thaliz_SpellIsResurrect(spellId) then
						Thaliz_BlacklistPlayer(target)
						Thaliz_AnnounceResurrection(target)
					end
				end
			end
		end

	elseif (event == "UNIT_SPELLCAST_START") then
		SpellcastIsStarted = TimerTick
		if(debug) then
			echo(string.format("**DEBUG**: UNIT_SPELLCAST_START,sc=%d", SpellcastIsStarted))
		end

	elseif (event == "UNIT_SPELLCAST_STOP") then
		SpellcastIsStarted = 0
		if(debug) then
			echo(string.format("**DEBUG**: UNIT_SPELLCAST_STOP,sc=%d", SpellcastIsStarted))
		end

	elseif (event == "INCOMING_RESURRECT_CHANGED") then
		local arg1 = ...
		local target = nil

		-- Hack: we assume this is someone ressing; we can't see the spellId on the event!
		local timeDiff = TimerTick - SpellcastIsStarted
		if(debug) then
			echo(string.format("**DEBUG**: INCOMING_RESURRECT_CHANGED,sc=%d, td=%f", SpellcastIsStarted, timeDiff))
		end

		if (timeDiff < 0.001) and UnitIsGhost(arg1) then
			if(debug) then
				echo("**DEBUG**: INCOMING_RESURRECT_CHANGED,starting")
			end

			SpellcastIsStarted = 0
			if IsInRaid() then
				if Thaliz_BeginsWith(arg1, 'raid') then
					target = UnitName(arg1)
				end
			else
				if Thaliz_BeginsWith(arg1, 'party') then
					target = UnitName(arg1)
				end
			end

			if target then
				if(debug) then
					echo(string.format("**DEBUG**: INCOMING_RESURRECT_CHANGED,casting, tg=%s", target))
				end

				if not Thaliz_IsPlayerBlacklisted(target) then
					Thaliz_BlacklistPlayer(target, 10)
					Thaliz_AnnounceResurrection(target, arg1)
				end
			end
		end

	elseif (event == "CHAT_MSG_ADDON") then
		Thaliz_OnChatMsgAddon(event, ...)

	elseif (event == "RAID_ROSTER_UPDATE") then
		Thaliz_OnRaidRosterUpdate(event, ...)

	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, subevent, _, _, sourceName, _, _, _, destName = CombatLogGetCurrentEventInfo()

		if subevent == "SPELL_RESURRECT" then
			if sourceName ~= UnitName("player") then
				Thaliz_BlacklistPlayer(destName, Thaliz.constant.BLACKLIST_RESURRECT)
			end
		end

	else
		if(debug) then
			echo("**DEBUG**: Other event: "..event)

			local arg1, arg2, arg3, arg4 = ...
			if arg1 then
				echo(string.format("**DEBUG**: arg1=%s", arg1))
			end
			if arg2 then
				echo(string.format("**DEBUG**: arg2=%s", arg2))
			end
			if arg3 then
				echo(string.format("**DEBUG**: arg3=%s", arg3))
			end
			if arg4 then
				echo(string.format("**DEBUG**: arg4=%s", arg4))
			end
		end
	end
end

function Thaliz_RepositionateButton(self)
	local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight()

	Thaliz:SetOption(Thaliz.constant.OPTION_REZ_BUTTON_POS_X, x)
	Thaliz:SetOption(Thaliz.constant.OPTION_REZ_BUTTON_POS_Y, y)
end
