local _, Thaliz = ...

local COLOUR_BEGINMARK      = "|c80"
local BLACKLIST_SPELLCAST   = 10
local BLACKLIST_RESURRECT   = 30

Thaliz.constant = {
    ["PARTY_CHANNEL"]			= "PARTY",
    ["RAID_CHANNEL"]			= "RAID",
    ["YELL_CHANNEL"]			= "YELL",
    ["SAY_CHANNEL"]			    = "SAY",
    ["CHAT_END"]				= "|r",
    ["COLOUR_CHAT"]			    = COLOUR_BEGINMARK.."40A0F8",
    ["COLOUR_INTRO"]			= COLOUR_BEGINMARK.."B040F0",
    ["MESSAGE_PREFIX"]		    = "Thalizv1",
    ["MAX_VISIBLE_MESSAGES"]    = 20,
    ["EMPTY_MESSAGE"]			= "(Empty)",

    ["EMOTE_GROUP_DEFAULT"]		= "Default",
    ["EMOTE_GROUP_GUILD"]		= "Guild",
    ["EMOTE_GROUP_CHARACTER"]	= "Name",
    ["EMOTE_GROUP_CLASS"]		= "Class",
    ["EMOTE_GROUP_RACE"]		= "Race",

    -- https://wow.gamepedia.com/Class_colors
    ["RAID_CLASS_COLORS"] = {
        ["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
        ["WARLOCK"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
        ["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
        ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
        ["MAGE"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
        ["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
        ["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
        ["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
        ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
    },

    ["REZBTN_COMBAT"]		= "Interface\\Icons\\Ability_dualwield",
    ["REZBTN_DEAD"]			= "Interface\\Icons\\Ability_rogue_feigndeath",

    ["ICON_OTHER_PASSIVE"]		= "Interface\\Icons\\INV_Misc_Gear_01",
    ["ICON_DRUID_PASSIVE"]		= "Interface\\Icons\\INV_Misc_Monsterclaw_04",
    ["ICON_DRUID_ACTIVE"]		= "Interface\\Icons\\spell_holy_resurrection",
    ["ICON_PALADIN_PASSIVE"]    = "Interface\\Icons\\INV_Hammer_01",
    ["ICON_PALADIN_ACTIVE"]	    = "Interface\\Icons\\spell_holy_resurrection",
    ["ICON_PRIEST_PASSIVE"]	    = "Interface\\Icons\\INV_Staff_30",
    ["ICON_PRIEST_ACTIVE"]		= "Interface\\Icons\\spell_holy_resurrection",
    ["ICON_SHAMAN_PASSIVE"]	    = "Interface\\Icons\\INV_Jewelry_Talisman_04",
    ["ICON_SHAMAN_ACTIVE"]		= "Interface\\Icons\\spell_holy_resurrection",

    ["PRIORITY_TO_FIRST_WARLOCK"]     = 45,    -- Prio below ressers if no warlocks are alive
    ["PRIORITY_TO_GROUP_LEADER"]      = 45,    -- Prio below ressers if raid leader or assistant
    ["PRIORITY_TO_CURRENT_TARGET"]    = 100,   -- Prio over all if target is selected

    -- Corpses are blacklisted for 40 seconds (10 seconds cast time + 30 seconds waiting) as default
    ["BLACKLIST_SPELLCAST"]     = BLACKLIST_SPELLCAST,
    ["BLACKLIST_RESURRECT"]     = BLACKLIST_RESURRECT,
    ["BLACKLIST_TIMEOUT"]       = BLACKLIST_SPELLCAST + BLACKLIST_RESURRECT,

    -- Configuration constants:
    ["CONFIGURATION_DEFAULT_LEVEL"]				= "Character",	-- Can be "Character" or "Realm"
    ["TARGET_CHANNEL_DEFAULT"]					= "RAID",
    ["TARGET_WHISPER_DEFAULT"]					= "0",
    ["RESURRECTION_WHISPER_MESSAGE_DEFAULT"]    = "Resurrection incoming in 10 seconds!",
    ["INCLUDE_DEFAULT_GROUP_DEFAULT"]			= "1",

    ["ROOT_OPTION_CHARACTER_BASED_SETTINGS"]	    = "CharacterBasedSettings",
    ["OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL"]	= "ResurrectionMessageTargetChannel",
    ["OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER"]	= "ResurrectionMessageTargetWhisper",
    ["OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP"]			= "AlwaysIncludeDefaultGroup",
    ["OPTION_RESURRECTION_WHISPER_MESSAGE"]			= "ResurrectionWhisperMessage",
    ["OPTION_RESURRECTION_MESSAGES"]				= "ResurrectionMessages",
    ["OPTION_REZ_BUTTON_POS_X"]						= "RezButtonPosX",
    ["OPTION_REZ_BUTTON_POS_Y"]						= "RezButtonPosY",
}
