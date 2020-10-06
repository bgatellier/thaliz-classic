local COLOUR_BEGINMARK		= "|c80"

_G["PARTY_CHANNEL"]			= "PARTY"
_G["RAID_CHANNEL"]			= "RAID"
_G["YELL_CHANNEL"]			= "YELL"
_G["SAY_CHANNEL"]			= "SAY"
_G["CHAT_END"]				= "|r"
_G["COLOUR_CHAT"]			= COLOUR_BEGINMARK.."40A0F8"
_G["COLOUR_INTRO"]			= COLOUR_BEGINMARK.."B040F0"
_G["MESSAGE_PREFIX"]		= "Thalizv1"
_G["MAX_VISIBLE_MESSAGES"]  = 20
_G["EMPTY_MESSAGE"]			= "(Empty)"

_G["EMOTE_GROUP_DEFAULT"]		= "Default"
_G["EMOTE_GROUP_GUILD"]			= "Guild"
_G["EMOTE_GROUP_CHARACTER"]		= "Name"
_G["EMOTE_GROUP_CLASS"]			= "Class"
_G["EMOTE_GROUP_RACE"]			= "Race"

-- https://wow.gamepedia.com/Class_colors
_G["RAID_CLASS_COLORS"] = {
	["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["WARLOCK"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
	["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["MAGE"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
	["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
}

_G["REZBTN_COMBAT"]			= "Interface\\Icons\\Ability_dualwield"
_G["REZBTN_DEAD"]			= "Interface\\Icons\\Ability_rogue_feigndeath"

_G["ICON_OTHER_PASSIVE"]		= "Interface\\Icons\\INV_Misc_Gear_01"
_G["ICON_DRUID_PASSIVE"]		= "Interface\\Icons\\INV_Misc_Monsterclaw_04"
_G["ICON_DRUID_ACTIVE"]		    = "Interface\\Icons\\spell_holy_resurrection"
_G["ICON_PALADIN_PASSIVE"]      = "Interface\\Icons\\INV_Hammer_01"
_G["ICON_PALADIN_ACTIVE"]	    = "Interface\\Icons\\spell_holy_resurrection"
_G["ICON_PRIEST_PASSIVE"]	    = "Interface\\Icons\\INV_Staff_30"
_G["ICON_PRIEST_ACTIVE"]		= "Interface\\Icons\\spell_holy_resurrection"
_G["ICON_SHAMAN_PASSIVE"]	    = "Interface\\Icons\\INV_Jewelry_Talisman_04"
_G["ICON_SHAMAN_ACTIVE"]		= "Interface\\Icons\\spell_holy_resurrection"

_G["PRIORITY_TO_FIRST_WARLOCK"]     = 45    -- Prio below ressers if no warlocks are alive
_G["PRIORITY_TO_GROUP_LEADER"]      = 45    -- Prio below ressers if raid leader or assistant
_G["PRIORITY_TO_CURRENT_TARGET"]    = 100   -- Prio over all if target is selected

-- Corpses are blacklisted for 40 seconds (10 seconds cast time + 30 seconds waiting) as default
_G["BLACKLIST_SPELLCAST"] =  10
_G["BLACKLIST_RESURRECT"] =  30
_G["BLACKLIST_TIMEOUT"] =    _G["BLACKLIST_SPELLCAST"] + _G["BLACKLIST_RESURRECT"]

-- Configuration constants:
_G["CONFIGURATION_DEFAULT_LEVEL"]				= "Character"	-- Can be "Character" or "Realm"
_G["TARGET_CHANNEL_DEFAULT"]					= "RAID"
_G["TARGET_WHISPER_DEFAULT"]					= "0"
_G["RESURRECTION_WHISPER_MESSAGE_DEFAULT"]      = "Resurrection incoming in 10 seconds!"
_G["INCLUDE_DEFAULT_GROUP_DEFAULT"]				= "1"

_G["ROOT_OPTION_CHARACTER_BASED_SETTINGS"]			= "CharacterBasedSettings"
_G["OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL"]	= "ResurrectionMessageTargetChannel"
_G["OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER"]	= "ResurrectionMessageTargetWhisper"
_G["OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP"]			= "AlwaysIncludeDefaultGroup"
_G["OPTION_RESURRECTION_WHISPER_MESSAGE"]			= "ResurrectionWhisperMessage"
_G["OPTION_RESURRECTION_MESSAGES"]				    = "ResurrectionMessages"
_G["OPTION_REZ_BUTTON_POS_X"]						= "RezButtonPosX"
_G["OPTION_REZ_BUTTON_POS_Y"]						= "RezButtonPosY"
