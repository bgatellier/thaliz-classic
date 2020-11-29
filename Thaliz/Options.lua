local _, Thaliz = ...
local L = LibStub("AceLocale-3.0"):GetLocale(_, true)


local function CreateMessageGroupOption(index)
	local groupClassesAllowed = { "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior" }
	local groupRacesAllowed = { "Dwarf", "Gnome", "Human", "Night elf", "Orc", "Tauren", "Troll", "Undead" }

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
				name = "Message",
				type = "input",
				order = 1,
				width = "full",
				set = function (info, value) Thaliz.db.profile.public.messages[index][1] = value end,
				get = function (value) return Thaliz.db.profile.public.messages[index][1] end,
			},
			group = {
				name = "Use it for",
				type = "select",
				order = 2,
				values = {
					[Thaliz.constant.EMOTE_GROUP_DEFAULT] = "Everyone",
					[Thaliz.constant.EMOTE_GROUP_GUILD] = "a Guild",
					[Thaliz.constant.EMOTE_GROUP_CHARACTER] = "a Character",
					[Thaliz.constant.EMOTE_GROUP_CLASS] = "a Class",
					[Thaliz.constant.EMOTE_GROUP_RACE] = "a Race",
				},
				set = function (info, value)
					Thaliz.db.profile.public.messages[index][2] = value

					-- Reset the value of the groupValue option
					Thaliz.db.profile.public.messages[index][3] = ""

					-- Enable/disable the groupValue option
					info.options.args.public.args.messages.args["message" .. index].args.groupValue.disabled = (value == Thaliz.constant.EMOTE_GROUP_DEFAULT)
				end,
				get = function (value) return Thaliz.db.profile.public.messages[index][2] end,
			},
			groupValue = {
				name = "who/which is",
				desc = "For the class or race selector use the english language (e.g. hunter, dwarf...",
				type = "input",
				disabled = function () return Thaliz.db.profile.public.messages[index][2] == Thaliz.constant.EMOTE_GROUP_DEFAULT end,
				order = 3,
				width = "full",
				set = function (info, value)
					local group = info.options.args.public.args.messages.args["message" .. index].args.group.get()

					-- Allow both "nightelf" and "night elf".
					-- This weird construction ensures all are shown with capital first letter.
					if (group == Thaliz.constant.EMOTE_GROUP_RACE and string.upper(value) == "NIGHTELF" or string.upper(value) == "NIGHT ELF") then
						value = "night elf"
					end

					if group == Thaliz.constant.EMOTE_GROUP_CHARACTER or group == Thaliz.constant.EMOTE_GROUP_CLASS or group == Thaliz.constant.EMOTE_GROUP_RACE then
						value = UCFirst(value)
					end

					Thaliz.db.profile.public.messages[index][3] = value
				end,
				validate = function (info, value)
					local allowedValues = {}
					local standardizedInput = value
					local selectedGroup = info.options.args.public.args.messages.args["message" .. index].args.group.get()

					if (selectedGroup == Thaliz.constant.EMOTE_GROUP_CLASS) then
						allowedValues = groupClassesAllowed
						standardizedInput = UCFirst(standardizedInput)
					elseif (selectedGroup == Thaliz.constant.EMOTE_GROUP_RACE) then
						allowedValues = groupRacesAllowed

						-- Allow both "nightelf" and "night elf".
						-- This weird construction ensures all are shown with capital first letter.
						if string.upper(standardizedInput) == "NIGHTELF" or string.upper(standardizedInput) == "NIGHT ELF" then
							standardizedInput = "night elf"
						end

						standardizedInput = UCFirst(standardizedInput)
					end

					local allowedValuesQty = table.getn(allowedValues)

					-- Nothing to validate: returns validation OK
					if (allowedValuesQty == 0) then return true end

					local isValidInput = InNumericTable(standardizedInput, allowedValues)

					-- Input is valid: returns validation OK
					if (isValidInput) then return true end

					-- Input is invalid: build and returns the error message
					local error = "The value must be one of: "

					for k, allowedValue in ipairs(allowedValues) do
						error = error .. allowedValue

						if (k < allowedValuesQty) then
							error = error .. ", "
						else
							error = error .. "."
						end
					end

					return error
				end,
				get = function (value) return Thaliz.db.profile.public.messages[index][3] end,
			},
			delete = {
				name = "Delete this message",
				type = "execute",
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
				name = "Public messages",
				type = "group",
				order = 1,
				cmdHidden = true,
				args = {
					enabled = {
						name = "Enabled",
						type = "toggle",
						order = 1,
						set = function (info, value) Thaliz.db.profile.public.enabled = value end,
						get = function (value) return Thaliz.db.profile.public.enabled end,
					},
					channel = {
						name = "Broadcast channel",
						type = "select",
						values = { RAID = "Raid/Party", SAY = "Say", YELL = "Yell" },
						order = 2,
						width = "normal",
						hidden = not Thaliz.db.profile.public.enabled,
						set = function (info, value) Thaliz.db.profile.public.message = value end,
						get = function (value) return Thaliz.db.profile.public.message end,
					},
					includeEveryone = {
						name = "Add messages for everyone to the list of targeted messages",
						type = "toggle",
						order = 3,
						width = "full",
						hidden = not Thaliz.db.profile.public.enabled,
						set = function (info, value) Thaliz.db.profile.public.includeEveryone = value end,
						get = function (value) return Thaliz.db.profile.public.includeEveryone end,
					},
					messages = {
						name = "Messages",
						type = "group",
						order = 4,
						hidden = not Thaliz.db.profile.public.enabled,
						args = {},
					},
					addMessage = {
						name = "Add a new message",
						usage = "Once your message has been added, you can change its group and group value.",
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
				name = "Private message",
				type = "group",
				order = 2,
				cmdHidden = true,
				args = {
					enabled = {
						name = "Enabled",
						type = "toggle",
						order = 1,
						set = function (info, value) Thaliz.db.profile.private.enabled = value end,
						get = function (value) return Thaliz.db.profile.private.enabled end,
					},
					message = {
						name = "Message",
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
				name = "About",
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
						name = string.format("\nVersion %s", GetAddOnMetadata(_, "Version")),
						fontSize = "medium",
						order = 2,
					},
					authors = {
						type = "description",
						name = string.format("\nBy %s", GetAddOnMetadata(_, "Author")),
						fontSize = "medium",
						order = 3,
					},
					repository = {
						type = "description",
						name = string.format("\nDownload the latest version at %s", GetAddOnMetadata(_, "X-Website")),
						fontSize = "medium",
						order = 4,
					},
				},
			},
			debug = {
				name = "Debug",
				type = "group",
				order = 5,
				args = {
					enabled = {
						name = "Enabled",
						type = "toggle",
						order = 1,
						width = "full",
						set = function (info, value) Thaliz.db.profile.debug.enabled = value end,
						get = function (value) return Thaliz.db.profile.debug.enabled end,
					},
					functionName = {
						name = "Function name",
						type = "select",
						order = 2,
						values = { None = "None", ScanRaid = "ScanRaid", InitClassSpecificStuff = "InitClassSpecificStuff", GetClassinfo = "GetClassinfo", OnEvent = "OnEvent" },
						width = "normal",
						hidden = not Thaliz.db.profile.debug.enabled,
						set = function (info, value) Thaliz.db.profile.debug.functionName = value end,
						get = function (value) return Thaliz.db.profile.debug.functionName end,
					},
					scanFrequency = {
						name = "Scan frequency (per seconds)",
						type = "input",
						order = 3,
						hidden = not Thaliz.db.profile.debug.enabled,
						set = function (info, value) Thaliz.db.profile.debug.scanFrequency = 1 / value end,
						get = function (value) return Thaliz.db.profile.debug.scanFrequency end,
					}
				},
			},
			config = {
				name = "Configuration",
				desc = "Show/Hide configuration options",
				type = "execute",
				guiHidden = true,
				func = function (info) LibStub("AceConfigDialog-3.0"):Open(_) end,
			},
			version = {
				name = "Version",
				desc = "Displays Thaliz version",
				type = "execute",
				guiHidden = true,
				func = function()
					if IsInRaid() or Thaliz:IsInParty() then
						Thaliz:SendAddonMessage("TX_VERSION##")
					else
						Thaliz:Echo(string.format("version %s by %s", GetAddOnMetadata(_, "Version"), GetAddOnMetadata(_, "Author")))
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
