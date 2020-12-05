local _, Thaliz = ...
local L = LibStub("AceLocale-3.0"):GetLocale(_, true)
local playerFaction = UnitFactionGroup("player")

-- List the classes the player is able to choose
local function GetClasses()
	local classes = {
		["Druid"] = L["Druid"],
		["Hunter"] = L["Hunter"],
		["Mage"] = L["Mage"],
		["Priest"] = L["Priest"],
		["Rogue"] = L["Rogue"],
		["Warlock"] = L["Warlock"],
		["Warrior"] = L["Warrior"],
	}

	if (playerFaction == "Alliance") then
		classes["Paladin"] = L["Paladin"]
	else
		classes["Shaman"] = L["Shaman"]
	end

	return classes
end

-- List the races the player is able to choose
local function GetRaces()
	if (playerFaction == "Alliance") then
		return {
			["Dwarf"] = L["Dwarf"],
			["Gnome"] = L["Gnome"],
			["Human"] = L["Human"],
			["Night elf"] = L["Night elf"],
		}
	else
		return {
			["Orc"] = L["Orc"],
			["Tauren"] = L["Tauren"],
			["Troll"] = L["Troll"],
			["Undead"] = L["Undead"],
		}
	end
end

local function CreateMessageGroupValueOption(index)
	-- get the selected group
	local group = Thaliz.db.profile.public.messages[index][2]

	-- create the default option table
	local option = {
		name = "",
		type = "input",
		hidden = group == Thaliz.constant.EMOTE_GROUP_DEFAULT,
		order = 3,
		set = function (info, value) Thaliz.db.profile.public.messages[index][3] = value end,
		get = function (value) return Thaliz.db.profile.public.messages[index][3] end,
	}

	-- Change the option type for a select if the group is a class or a race, and add the values
	if group == Thaliz.constant.EMOTE_GROUP_CLASS or group == Thaliz.constant.EMOTE_GROUP_RACE then
		local keysValues

		if group == Thaliz.constant.EMOTE_GROUP_CLASS then
			keysValues = GetClasses()
		elseif group == Thaliz.constant.EMOTE_GROUP_RACE then
			keysValues = GetRaces()
		end

		option.type = "select"
		option.values = keysValues
	end

	return option
end

local function CreateMessageGroupOption(index)
	return {
		name = function (info)
			local message = Thaliz.db.profile.public.messages[index]

			local group = message[2]
			local groupValue = message[3]
			local rgbColor = "ff808080"

			if (group == Thaliz.constant.EMOTE_GROUP_GUILD) then rgbColor = "ff00ff00"
			elseif (group == Thaliz.constant.EMOTE_GROUP_CHARACTER) then rgbColor = "ffcccccc"
			elseif (group == Thaliz.constant.EMOTE_GROUP_CLASS and Thaliz.constant.RAID_CLASS_COLORS[string.upper(groupValue)] ~= nil ) then rgbColor = Thaliz.constant.RAID_CLASS_COLORS[string.upper(groupValue)].colorStr
			elseif (group == Thaliz.constant.EMOTE_GROUP_RACE) then
				if (groupValue == "Dwarf" or groupValue == "Gnome" or groupValue == "Human" or groupValue == "Night elf") then rgbColor = "ff0080ff"
				elseif (groupValue == "Orc" or groupValue == "Tauren" or groupValue == "Troll" or groupValue == "Undead") then rgbColor = "ffff0000"
				else rgbColor = "ffcc00ff"
				end
			end

			return "|c" .. rgbColor .. message[1]
		end,
		type = "group",
		order = index,
		args = {
			message = {
				name = L["Message"],
				type = "input",
				order = 1,
				width = "full",
				set = function (info, value) Thaliz.db.profile.public.messages[index][1] = value end,
				get = function (value) return Thaliz.db.profile.public.messages[index][1] end,
			},
			group = {
				name = L["Use it for"],
				type = "select",
				order = 2,
				values = {
					[Thaliz.constant.EMOTE_GROUP_DEFAULT] = L["Everyone"],
					[Thaliz.constant.EMOTE_GROUP_GUILD] = L["a Guild"],
					[Thaliz.constant.EMOTE_GROUP_CHARACTER] = L["a Character"],
					[Thaliz.constant.EMOTE_GROUP_CLASS] = L["a Class"],
					[Thaliz.constant.EMOTE_GROUP_RACE] = L["a Race"],
				},
				set = function (info, value)
					Thaliz.db.profile.public.messages[index][2] = value

					-- Reset the value of the groupValue option
					Thaliz.db.profile.public.messages[index][3] = ""
				end,
				get = function (value) return Thaliz.db.profile.public.messages[index][2] end,
			},
			groupValue = CreateMessageGroupValueOption(index, Thaliz.db.profile.public.messages[index][2]),
			delete = {
				name = L["Delete this message"],
				type = "execute",
				order = 4,
				width = "full",
				func = function (info)
					-- Remove from the memory
					Thaliz.db.profile.public.messages.remove(index)

					-- Remove from the options / GUI
					info.options.args.public.args.messages.args["message" .. index] = nil
				end,
			}
		},
	}
end

local function GetOptions()
	local options =  {
		type = "group",
		childGroups = "tab",
		args = {
			public = {
				name = L["Public Messages"],
				type = "group",
				order = 1,
				cmdHidden = true,
				args = {
					enabled = {
						name = L["Enabled"],
						type = "toggle",
						order = 1,
						set = function (info, value) Thaliz.db.profile.public.enabled = value end,
						get = function (value) return Thaliz.db.profile.public.enabled end,
					},
					channel = {
						name = L["Broadcast channel"],
						type = "select",
						values = { RAID = L["Raid/Party"], SAY = L["Say"], YELL = L["Yell"] },
						order = 2,
						width = "normal",
						hidden = not Thaliz.db.profile.public.enabled,
						set = function (info, value) Thaliz.db.profile.public.channel = value end,
						get = function (value) return Thaliz.db.profile.public.channel end,
					},
					includeEveryone = {
						name = L["Add messages for everyone to the list of targeted messages"],
						type = "toggle",
						order = 3,
						width = "full",
						hidden = not Thaliz.db.profile.public.enabled,
						set = function (info, value) Thaliz.db.profile.public.includeEveryone = value end,
						get = function (value) return Thaliz.db.profile.public.includeEveryone end,
					},
					messages = {
						name = L["Messages"],
						type = "group",
						order = 4,
						hidden = not Thaliz.db.profile.public.enabled,
						args = {},
					},
					addMessage = {
						name = L["Add a new message"],
						usage = L["Once your message has been added, you can change its group and group value."],
						type = "input",
						order = -1,
						width = "full",
						hidden = not Thaliz.db.profile.public.enabled,
						set = function (info, value)
							local messageQty = table.getn(Thaliz.db.profile.public.messages)

							local index = messageQty + 1

							Thaliz.db.profile.public.messages[index] = { value, Thaliz.constant.EMOTE_GROUP_DEFAULT, "" }

							info.options.args.public.args.messages.args["message" .. index] = CreateMessageGroupOption(index, value)
						end,
					},
				},
			},
			private = {
				name = L["Private message"],
				type = "group",
				order = 2,
				cmdHidden = true,
				args = {
					enabled = {
						name = L["Enabled"],
						type = "toggle",
						order = 1,
						set = function (info, value) Thaliz.db.profile.private.enabled = value end,
						get = function (value) return Thaliz.db.profile.private.enabled end,
					},
					message = {
						name = L["Message"],
						type = "input",
						order = 2,
						width = "full",
						hidden = not Thaliz.db.profile.private.enabled,
						set = function (info, value) Thaliz.db.profile.private.message = value end,
						get = function (value) return Thaliz.db.profile.private.message end,
					},
				},
			},
			-- profile = {
			-- 	name = "Profile",
			-- 	type = "group",
			-- 	order = 3,
			-- 	cmdHidden = true,
			-- 	args = {
			-- 		macro = {
			-- 			name = "Store message's per Character",
			-- 			type = "toggle",
			-- 			order = 1,
			-- 			width = "full",
			-- 			set = function (info, value)
			-- 				if value then
			-- 					Thaliz:SetOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, "Character")
			-- 				else
			-- 					Thaliz:SetOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, "Realm")
			-- 				end
			-- 			end,
			-- 			get = function (value) return Thaliz:GetOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS) == "Character" end,
			-- 		},
			-- 	},
			-- },
			about = {
				name = L["About"],
				type = "group",
				order = 4,
				cmdHidden = true,
				args = {
					title = {
						type = "description",
						name = GetAddOnMetadata(_, "Title"),
						fontSize = "large",
						order = 1,
					},
					version = {
						type = "description",
						name = string.format("\n" .. L["Version %s"], GetAddOnMetadata(_, "Version")),
						fontSize = "medium",
						order = 2,
					},
					authors = {
						type = "description",
						name = string.format("\n" .. L["By %s"], GetAddOnMetadata(_, "Author")),
						fontSize = "medium",
						order = 3,
					},
					repository = {
						type = "description",
						name = string.format("\n" .. L["Download the latest version at %s"], GetAddOnMetadata(_, "X-Website")),
						fontSize = "medium",
						order = 4,
					},
				},
			},
			debug = {
				name = L["Debug"],
				type = "group",
				order = 5,
				args = {
					enabled = {
						name = L["Enabled"],
						type = "toggle",
						order = 1,
						width = "full",
						set = function (info, value) Thaliz.db.profile.debug.enabled = value end,
						get = function (value) return Thaliz.db.profile.debug.enabled end,
					},
					functionName = {
						name = L["Function name"],
						type = "select",
						order = 2,
						values = { None = L["None"], ScanRaid = "ScanRaid", InitClassSpecificStuff = "InitClassSpecificStuff", GetClassinfo = "GetClassinfo", OnEvent = "OnEvent" },
						width = "normal",
						hidden = not Thaliz.db.profile.debug.enabled,
						set = function (info, value) Thaliz.db.profile.debug.functionName = value end,
						get = function (value) return Thaliz.db.profile.debug.functionName end,
					},
					scanFrequency = {
						name = L["Raid/party scan frequency"],
						desc = L["Frequency (in seconds) at which the raid or party is scanned for corpses to resurrect"],
						type = "range",
						min = 1,
						max = 10,
						step = 1,
						order = 3,
						width = "double",
						hidden = not Thaliz.db.profile.debug.enabled,
						set = function (info, value) Thaliz.db.profile.debug.scanFrequency = 1 / value end,
						get = function (value) return 1 / Thaliz.db.profile.debug.scanFrequency end,
					}
				},
			},
			config = {
				name = L["Configuration"],
				desc = L["Show/Hide configuration options"],
				type = "execute",
				guiHidden = true,
				func = function (info) LibStub("AceConfigDialog-3.0"):Open(_) end,
			},
			version = {
				name = L["Version"],
				desc = L["Displays Thaliz version"],
				type = "execute",
				guiHidden = true,
				func = function()
					if IsInRaid() or Thaliz:IsInParty() then
						Thaliz:SendAddonMessage("TX_VERSION##")
					else
						Thaliz:Echo(string.format(L["version %s by %s"], GetAddOnMetadata(_, "Version"), GetAddOnMetadata(_, "Author")))
					end
				end
			},
		}
	}

	-- Populate the resurrection messages box
	for index in ipairs(Thaliz.db.profile.public.messages) do
		local messageGroupOption = CreateMessageGroupOption(index)

		options.args.public.args.messages.args["message" .. index] = messageGroupOption
	end

	return options
end

function Thaliz:SetupOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(_, GetOptions, { "thaliz" })
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(_)
end
