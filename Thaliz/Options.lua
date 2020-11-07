local _, Thaliz = ...

local function isWarnPeopleDisabled()
	return Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL) == "NONE"
end

local function isTargetWhisperDisabled()
	return Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER) == 0
end


local function CreateMessageGroupOption(index)
	local groupClassesAllowed = { "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior" }
	local groupRacesAllowed = { "Dwarf", "Gnome", "Human", "Night elf", "Orc", "Tauren", "Troll", "Undead" }

	return {
		name = function (info)
			local message = Thaliz:GetResurrectionMessage(index)

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
				set = function (info, value) Thaliz:SetResurrectionMessage(index, 1, value) end,
				get = function (value) return Thaliz:GetResurrectionMessage(index)[1] end,
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
					Thaliz:SetResurrectionMessage(index, 2, value)

					-- Reset the value of the groupValue option
					Thaliz:SetResurrectionMessage(index, 3, "")

					-- Enable/disable the groupValue option
					info.options.args.public.args.messages.args["message" .. index].args.groupValue.disabled = (value == Thaliz.constant.EMOTE_GROUP_DEFAULT)
				end,
				get = function (value) return Thaliz:GetResurrectionMessage(index)[2] end,
			},
			groupValue = {
				name = "who/which is",
				desc = "For the class or race selector use the english language (e.g. hunter, dwarf...",
				type = "input",
				disabled = function ()
					local message = Thaliz:GetResurrectionMessage(index)

					return message[2] == Thaliz.constant.EMOTE_GROUP_DEFAULT
				end,
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

					Thaliz:SetResurrectionMessage(index, 3, value)
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
				get = function (value) return Thaliz:GetResurrectionMessage(index)[3] end,
			},
			delete = {
				name = "Delete this message",
				type = "execute",
				func = function (info)
					-- Remove from the memory
					Thaliz:DeleteResurrectionMessage(index)

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
						set = function (info, value)
							if value then
								-- Assume the default value "RAID" if checked
								Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL, "RAID")
							else
								Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL, "NONE")
							end
						end,
						get = function (value) return Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL) ~= "NONE" end,
					},
					channel = {
						name = "Broadcast channel",
						type = "select",
						values = { RAID = "Raid/Party", SAY = "Say", YELL = "Yell" },
						order = 2,
						width = "normal",
						hidden = isWarnPeopleDisabled,
						set = function (info, value) Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL, value) end,
						get = function (value) return Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_CHANNEL) end,
					},
					includeEveryone = {
						name = "Add messages for everyone to the list of targeted messages",
						type = "toggle",
						order = 3,
						width = "full",
						hidden = isWarnPeopleDisabled,
						set = function (info, value)
							if value then
								Thaliz:SetOption(Thaliz.constant.OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP, 1)
							else
								Thaliz:SetOption(Thaliz.constant.OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP, 0)
							end
						end,
						get = function (value) return Thaliz:GetOption(Thaliz.constant.OPTION_ALWAYS_INCLUDE_DEFAULT_GROUP) == 1 end,
					},
					messages = {
						name = "Messages",
						type = "group",
						order = 4,
						hidden = isWarnPeopleDisabled,
						args = {},
					},
					addMessage = {
						name = "Add a new message",
						usage = "Once your message has been added, you can change its group and group value.",
						type = "input",
						order = -1,
						width = "full",
						hidden = isWarnPeopleDisabled,
						set = function (info, value)
							local messageQty = table.getn(Thaliz:GetResurrectionMessages())

							local index = messageQty + 1

							Thaliz:UpdateResurrectionMessage(index, 0, value)

							local message = Thaliz:GetResurrectionMessage(index)

							info.options.args.public.args.messages.args["message" .. index] = Thaliz:createMessageGroupOption(index, message)
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
						set = function (info, value)
							if value then
								Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER, 1)
							else
								Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER, 0)
							end
						end,
						get = function (value) return Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_MESSAGE_TARGET_WHISPER) == 1 end,
					},
					message = {
						name = "Message",
						type = "input",
						order = 2,
						width = "full",
						hidden = isTargetWhisperDisabled,
						set = function (info, value) Thaliz:SetOption(Thaliz.constant.OPTION_RESURRECTION_WHISPER_MESSAGE, value) end,
						get = function (value) return Thaliz:GetOption(Thaliz.constant.OPTION_RESURRECTION_WHISPER_MESSAGE) end,
					},
				},
			},
			profile = {
				name = "Profile",
				type = "group",
				order = 3,
				cmdHidden = true,
				args = {
					macro = {
						name = "Store message's per Character",
						type = "toggle",
						order = 1,
						width = "full",
						set = function (info, value)
							if value then
								Thaliz:SetOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, "Character")
							else
								Thaliz:SetOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS, "Realm")
							end
						end,
						get = function (value) return Thaliz:GetOption(Thaliz.constant.ROOT_OPTION_CHARACTER_BASED_SETTINGS) == "Character" end,
					},
				},
			},
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
			config = {
				name = "Configuration",
				desc = "Show/Hide configuration options",
				type = "execute",
				guiHidden = true,
				func = function (info) LibStub("AceConfigDialog-3.0"):Open(_) end,
			},
			debug = {
				name = "Debug",
				desc = "Debug a Thaliz method",
				type = "input",
				pattern = "(%S*)",
				hidden = true,
				set = function (info, value)
					if value and value ~= '' then
						Thaliz:Echo(string.format("Enabling debug for %s", value))
						ThalizScanFrequency = 1.0
						Thaliz_DebugFunction = value
					else
						Thaliz:Echo("Disabling debug")
						ThalizScanFrequency = 0.2
						Thaliz_DebugFunction = nil
					end
				end,
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
	local messages = Thaliz:GetResurrectionMessages()
	for index in ipairs(messages) do
		local messageGroupOption = CreateMessageGroupOption(index)

		options.args.public.args.messages.args["message" .. index] = messageGroupOption
	end

	return options
end

function Thaliz:SetupOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(_, GetOptions, { "thaliz" })
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(_)
end
