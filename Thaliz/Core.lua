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

-- Player class name. Only set if this class can resurrect other players
local playerClassName = false

local rezBtnPassive = ""
local rezBtnActive = ""

-- List of blacklisted (already ressed) people
local blacklistedTable = {}

local function GetDefaultsDb()
	local default = {
		profile = {
			button = {
				x = 0,
				y = 100
			},
			public = {
				enabled = true,
				channel = Thaliz.constant.TARGET_CHANNEL_DEFAULT,
				includeEveryone = true,
				messages = {
					['*'] = {
						message = "",
						group = Thaliz.constant.MESSAGE_TARGET_DEFAULT,
						groupValue = "",
					}
				}
			},
			private = {
				enabled = true,
				message = L["Resurrection incoming in 10 seconds!"]
			},
			debug = {
				enabled = false,
				functionName = L["None"],
				scanFrequency = 0.2 -- Scan 5 times per second
			}
		}
	}

	-- Add default messages
	for key, message in pairs(L["Default Messages"]) do
		default.profile.public.messages[key] = { message, Thaliz.constant.MESSAGE_TARGET_DEFAULT, "" }
	end

	return default
end

function Thaliz:OnInitialize()
	-- InitializeConfigSettings()

	self.db = LibStub("AceDB-3.0"):New(_ .. "DB", GetDefaultsDb())

	self:SetupOptions()

	currentVersion = CalculateVersion( GetAddOnMetadata(_, "Version") )

	self:RegisterEvents()
	self:RegisterOnUpdate()

	C_ChatInfo.RegisterAddonMessagePrefix(Thaliz.constant.MESSAGE_PREFIX)

	self:InitClassSpecificStuff()

	RepositionateButton(RezButton)
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


function GetUnitID(playername)
	local groupsize, grouptype

	groupsize = GetNumGroupMembers()
	if IsInRaid() then
		grouptype = "raid"
	else
		grouptype = "party"
	end

	for n=1, groupsize, 1 do
		local unitid = grouptype..n

		if UnitName(unitid) == playername then
			return unitid
		end
	end

	return nil
end


--  *******************************************************
--
--	Resurrect message functions
--
--  *******************************************************
function Thaliz:AnnounceResurrection(playername, unitid)
	if not self.db.profile.public.enabled then
		return
	end

	if not unitid then
		unitid = GetUnitID(playername)

		if not unitid then
			return
		end
	end

	local guildname = GetGuildInfo(unitid)
	local race = string.upper(UnitRace(unitid))
	local _, classFilename = UnitClass(unitid)
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

	local macros = self.db.profile.public.messages
	for n=1, table.getn( macros ), 1 do
		local macro = macros[n]
		local param = ""
		if macro[3] then
			param = string.upper(macro[3])
		end

		if macro[2] == Thaliz.constant.MESSAGE_TARGET_DEFAULT then
			didx = didx + 1
			dmacro[ didx ] = macro
		elseif macro[2] == Thaliz.constant.MESSAGE_TARGET_GUILD then
			if param == UCGuildname then
				gidx = gidx + 1
				gmacro[ gidx ] = macro
			end
		elseif macro[2] == Thaliz.constant.MESSAGE_TARGET_CHARACTER then
			if param == charname then
				nidx = nidx + 1
				nmacro[ nidx ] = macro
			end
		elseif macro[2] == Thaliz.constant.MESSAGE_TARGET_CLASS then
			if param == classFilename then
				cidx = cidx + 1
				cmacro[ cidx ] = macro
			end
		elseif macro[2] == Thaliz.constant.MESSAGE_TARGET_RACE then
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
	if table.getn(macros) == 0 or self.db.profile.public.includeEveryone then
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
	message = string.gsub(message, "%%c", L[UCFirst(classFilename)])
	message = string.gsub(message, "%%r", L[UCFirst(race)])
	message = string.gsub(message, "%%g", guildname)
	message = string.gsub(message, "%%p", playername)

	local targetChannel = self.db.profile.public.channel

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

	if self.db.profile.private.enabled then
		local whisperMsg = self.db.profile.private.message
		if whisperMsg and not(whisperMsg == "") then
			SendChatMessage(whisperMsg, "WHISPER", nil, playername)
		end
	end
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
function Thaliz:ScanRaid()
	local debug = (self.db.profile.debug.enabled and self.db.profile.debug.functionName == "ScanRaid")

	--	Jesus, this class can't even ress!! Disable event
	if not playerClassName then
		SetRezTargetText()
		HideResurrectionButton()

		if (debug) then
			echo("**DEBUG**: playerClassName=false")
		end
		return
	end

	-- Doh, 1! Can't ress while dead!
	if UnitIsDeadOrGhost("player") then
		SetRezTargetText()
		SetButtonTexture(Thaliz.constant.REZBTN_DEAD)

		if (debug) then
			echo("**DEBUG**: UnitIsDeadOrGhost=true")
		end
		return
	end

	-- Doh, 2! Can't ress while in combat. Sorry druids, you get a LUA error if you try :-(
	if UnitAffectingCombat("player") then
		SetRezTargetText()
		SetButtonTexture(Thaliz.constant.REZBTN_COMBAT)

		if (debug) then
			echo("**DEBUG**: UnitAffectingCombat=true")
		end
		return
	end

	local groupsize = GetNumGroupMembers()
	if groupsize == 0 then
		HideResurrectionButton()

		if (debug) then
			echo("**DEBUG**: GetNumGroupMembers=0")
		end
		return
	end

	local _, classFilename = UnitClass("player")
	local classinfo = self:GetClassinfo(classFilename)
	local spellname = classinfo[3]

	local grouptype = "party"
	if IsInRaid() then
		grouptype = "raid"
	end

	local unitid
	local warlocksAlive = false
	for n=1, groupsize, 1 do
		unitid = grouptype..n
		_, classFilename = UnitClass(unitid)
		if not UnitIsDead(unitid) and UnitIsConnected(unitid) and UnitIsVisible(unitid) and classFilename == "WARLOCK" then
			warlocksAlive = true
			break
		end
	end

	CleanupBlacklistedPlayers()

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
			local blacklistInfo = blacklistedTable[b]
			-- local blacklistTick = blacklistInfo[2]

			if blacklistInfo[1] == playername then
				isBlacklisted = true
				if (debug) then
					echo(string.format("**DEBUG**: Player %s is blacklisted ...", playername))
				end
				break
			end
		end

		local targetname = UnitName("playertarget")

		if (isBlacklisted == false) and
				UnitIsDead(unitid) and
				(UnitHasIncomingResurrection(unitid) == false) and
				UnitIsConnected(unitid) and
				UnitIsVisible(unitid) and
				(IsSpellInRange(spellname, unitid) == 1) then
			_, classFilename = UnitClass(unitid)
			classinfo = self:GetClassinfo(classFilename)
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
		HideResurrectionButton()

		if (debug) then
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
		SortTableDescending(corpseTable, 2)

		unitid = corpseTable[1][1]

		if (debug) then
			if not spellname then spellname = "nil" end
			echo(string.format("**DEBUG**: corpse=%s, unitid=%s, spell=%s", UnitName(unitid), unitid, spellname))
		end

		RezButton:SetAttribute("type", "spell")
		RezButton:SetAttribute("spell", spellname)
		RezButton:SetAttribute("unit", unitid)
	end

	SetRezTargetText(UnitName(unitid))
	SetButtonTexture(rezBtnActive, true)
end


function BroadcastResurrection(self)
	local unitid = self:GetAttribute("unit")
	if not unitid then
		return
	end

	local playername = UnitName(unitid)

	Thaliz:SendAddonMessage(string.format("TX_RESBEGIN#%s#", playername))
end


function SetRezTargetText(playername)
	if not playername then
		playername = ""
	end

	RezButton.title:SetText(playername)
end


function HideResurrectionButton()
	SetButtonTexture(rezBtnPassive)
	RezButton:SetAttribute("type", nil)
	RezButton:SetAttribute("unit", nil)
	SetRezTargetText()
end


function Thaliz:InitClassSpecificStuff()
	local debug = (self.db.profile.debug.enabled and self.db.profile.debug.functionName == "InitClassSpecificStuff")
	local _, classFilename = UnitClass("player")

	if debug then
		if not classFilename then classFilename = "nil" end
		echo(string.format("**DEBUG**: [InitClassSpecificStuff] classname=%s", classFilename))
	end

	if (InNumericTable(classFilename, { "DRUID", "PALADIN", "PRIEST", "SHAMAN" })) then
		playerClassName = classFilename

		rezBtnPassive = Thaliz.constant["ICON_" .. classFilename .. "_PASSIVE"]
		rezBtnActive = Thaliz.constant["ICON_" .. classFilename .. "_ACTIVE"]
	else
		rezBtnPassive = Thaliz.constant.ICON_OTHER_PASSIVE
		rezBtnActive = Thaliz.constant.ICON_OTHER_PASSIVE
	end
end

local RezButtonLastTexture = ""
function SetButtonTexture(textureName, isEnabled)
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


function Thaliz:GetClassinfo(classname)
	local debug = (self.db.profile.debug.enabled and self.db.profile.debug.functionName == "GetClassinfo")

	classname = UCFirst(classname)
	for key, val in next, CLASS_INFO do
		if val[1] == classname then
			if (debug) then
				if not classname then classname = "nil" end
				echo(string.format("**DEBUG**: classname=%s, info=True", classname))
			end

			return val
		end
	end

	if (debug) then
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
function BlacklistPlayer(playername, blacklistTime)
	if not blacklistTime then
		blacklistTime = Thaliz.constant.BLACKLIST_TIMEOUT
	end

	local timerTick = GetTimerTick()

	if IsPlayerBlacklisted(playername) then
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
function WhitelistPlayer(playername)
	local WhitelistTable = {}
	--echo("Whitelisting "..playername)

	for n=1, table.getn(blacklistedTable), 1 do
		local blacklistInfo = blacklistedTable[n]
		if not (playername == blacklistInfo[1]) then
			WhitelistTable[ table.getn(WhitelistTable) + 1 ] = blacklistInfo
		end
	end
	blacklistedTable = WhitelistTable
end


function IsPlayerBlacklisted(playername)
	CleanupBlacklistedPlayers()

	for n=1, table.getn(blacklistedTable), 1 do
		if blacklistedTable[n][1] == playername then
			return true
		end
	end
	return false
end


function CleanupBlacklistedPlayers()
	local BlacklistedTableNew = {}
	local blacklistInfo
	local timerTick = GetTimerTick()

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
function GetPlayerName(nameAndRealm)
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


function SortTableDescending(sourcetable, index)
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
function Thaliz:OnRaidRosterUpdate(event, ...)
	if currentVersion > 0 and not updateMessageShown then
		if IsInRaid() or self:IsInParty() then
			local versionstring = GetAddOnMetadata(_, "Version")
			self:SendAddonMessage(string.format("TX_VERCHECK#%s#", versionstring))
		end
	end
end

function CalculateVersion(versionString)
	local _, _, major, minor, patch = string.find(versionString, "([^\.]*)\.([^\.]*)\.([^\.]*)")
	local version = 0

	if (tonumber(major) and tonumber(minor) and tonumber(patch)) then
		version = major * 100 + minor
		--echo(string.format("major=%s, minor=%s, patch=%s, version=%d", major, minor, patch, version))
	end

	return version
end

function CheckIsNewVersion(versionstring)
	local incomingVersion = CalculateVersion( versionstring )

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

	self.frame:SetScript("OnUpdate", OnTimer)
end


local Timers = {}
local TimerTick = 0
local NextScanTime = 0

function OnTimer(self, elapsed)
	TimerTick = TimerTick + elapsed

	if TimerTick > (NextScanTime + Thaliz.db.profile.debug.scanFrequency) then
		Thaliz:ScanRaid()
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

function GetTimerTick()
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
		elseif self:IsInParty() then
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
function HandleTXVersion(message, sender)
	local response = GetAddOnMetadata(_, "Version")
	Thaliz:SendAddonMessage("RX_VERSION#"..response.."#"..sender)
end

function HandleTXResBegin(message, sender)
	-- Blacklist target unless ress was initated by me
	if not (sender == UnitName("player")) then
		--echo(string.format("*** Remote blacklisting %s (%s is ressing)", message, sender))
		BlacklistPlayer(message)
	end
end

--[[
	A version response (RX) was received. The version information is displayed locally.
]]
function HandleRXVersion(message, sender)
	Thaliz:Echo(string.format("%s is using Thaliz version %s", sender, message))
end

function HandleTXVerCheck(message, sender)
	CheckIsNewVersion(message)
end

function OnChatMsgAddon(event, ...)
	local prefix, msg, channel, sender = ...
	if prefix == Thaliz.constant.MESSAGE_PREFIX then
		HandleThalizMessage(msg, GetPlayerName(sender))
	end
end

function HandleThalizMessage(msg, sender)
	local _, _, cmd, message, recipient = string.find(msg, "([^#]*)#([^#]*)#([^#]*)")

	--	Ignore message if it is not for me.
	--	Receipient can be blank, which means it is for everyone.
	if not (recipient == "") then
		if not (recipient == UnitName("player")) then
			return
		end
	end

	if cmd == "TX_VERSION" then
		HandleTXVersion(message, sender)
	elseif cmd == "RX_VERSION" then
		HandleRXVersion(message, sender)
	elseif cmd == "TX_RESBEGIN" then
		HandleTXResBegin(message, sender)
	elseif cmd == "TX_VERCHECK" then
		HandleTXVerCheck(message, sender)
	end
end


function IsSpellResurrect(spellId)
	local isResurrect = false

	if spellId then
		spellId = 1 * spellId

		if (
			playerClassName == "PRIEST" and InNumericTable(spellId, { 2006, 2010, 10880, 10881, 20770 })
			or playerClassName == "PALADIN" and InNumericTable(spellId, { 7328, 10322, 10324, 20772, 20773 })
			or playerClassName == "SHAMAN" and InNumericTable(spellId, { 2008, 20609, 20610, 20776, 20777 })
			or playerClassName == "DRUID" and InNumericTable(spellId, { 20484, 20739, 20742, 20747, 20748 })
		) then
			isResurrect = true
		end
	end

	return isResurrect
end


--[[
	Return # of seconds left of blacklist timer, nil if not blacklisted
--]]
function IsPlayerBlacklisted(playername)
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
	local debug = (self.db.profile.debug.enabled and self.db.profile.debug.functionName == "OnEvent")

	if (event == "UNIT_SPELLCAST_SENT") then
		local resser, target, _, spellId = ...
		if (resser == "player") then
			if (target ~= "Unknown") then
				if (debug) then
					echo(string.format("**DEBUG**: UNIT_SPELLCAST_SENT, SpellId=%s", spellId))
				end
				if not IsPlayerBlacklisted(target) then
					if IsSpellResurrect(spellId) then
						BlacklistPlayer(target)
						self:AnnounceResurrection(target)
					end
				end
			end
		end

	elseif (event == "UNIT_SPELLCAST_START") then
		SpellcastIsStarted = TimerTick
		if (debug) then
			echo(string.format("**DEBUG**: UNIT_SPELLCAST_START,sc=%d", SpellcastIsStarted))
		end

	elseif (event == "UNIT_SPELLCAST_STOP") then
		SpellcastIsStarted = 0
		if (debug) then
			echo(string.format("**DEBUG**: UNIT_SPELLCAST_STOP,sc=%d", SpellcastIsStarted))
		end

	elseif (event == "INCOMING_RESURRECT_CHANGED") then
		local arg1 = ...
		local target = nil

		-- Hack: we assume this is someone ressing; we can't see the spellId on the event!
		local timeDiff = TimerTick - SpellcastIsStarted
		if (debug) then
			echo(string.format("**DEBUG**: INCOMING_RESURRECT_CHANGED,sc=%d, td=%f", SpellcastIsStarted, timeDiff))
		end

		if (timeDiff < 0.001) and UnitIsGhost(arg1) then
			if (debug) then
				echo("**DEBUG**: INCOMING_RESURRECT_CHANGED,starting")
			end

			SpellcastIsStarted = 0
			if IsInRaid() then
				if BeginsWith(arg1, 'raid') then
					target = UnitName(arg1)
				end
			else
				if BeginsWith(arg1, 'party') then
					target = UnitName(arg1)
				end
			end

			if target then
				if (debug) then
					echo(string.format("**DEBUG**: INCOMING_RESURRECT_CHANGED,casting, tg=%s", target))
				end

				if not IsPlayerBlacklisted(target) then
					BlacklistPlayer(target, 10)
					self:AnnounceResurrection(target, arg1)
				end
			end
		end

	elseif (event == "CHAT_MSG_ADDON") then
		OnChatMsgAddon(event, ...)

	elseif (event == "RAID_ROSTER_UPDATE") then
		self:OnRaidRosterUpdate(event, ...)

	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, subevent, _, _, sourceName, _, _, _, destName = CombatLogGetCurrentEventInfo()

		if subevent == "SPELL_RESURRECT" then
			if sourceName ~= UnitName("player") then
				BlacklistPlayer(destName, Thaliz.constant.BLACKLIST_RESURRECT)
			end
		end

	else
		if (debug) then
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

function RepositionateButton(self)
	local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight()

	Thaliz.db.profile.button.x = x
	Thaliz.db.profile.button.y = y
end
