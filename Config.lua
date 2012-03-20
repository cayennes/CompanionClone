local CompanionClone = LibStub("AceAddon-3.0"):GetAddon("CompanionClone")
local Companions = CompanionClone:GetModule("Companions")
local Config = CompanionClone:GetModule("Config")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Setters and Getters

function Config:setPreference(info, val)
	CompanionClone.db.profile[info[#info]] = val
	if (info[#info] == "summonCooldownPet") 
	or (info[#info] == "summonReagentPet") then
		Companions:getOwnedCompanions()
	end
end

function Config:getPreference(info)
	return CompanionClone.db.profile[info[#info]]
end

-- Utility function to make it easy to put headers on paragraphs
local textInABox = function(title, text, ...) 
	order, _ = ...
	return {
		type = "group",
		name = title,
		inline = true,
		order = order,
		args = {
			text = {
				type = "description",
				fontSize = "medium",
				name = text
			}
		}
	}
end

local options = {
	type = "group",
	name = "CompanionClone",
	handler = Config,
	set = "setPreference",
	get = "getPreference",
	args = {
		behavior = {
			name = "Behavior",
			type = "group",
			inline = true,
			order = 10,
			args =  {
				info = {
					type = "description",
					order = 0,
					name = "These settings determine the behavior when you activate CompanionClone with or without a target.  Tooltips provide more information about each option."
				},
				friendMode = {
					order = 1,
					name = "Used on interacting pet",
					desc = "What to do when you own a pet that interacts with the pet that you're trying to clone",
					type = "select",
					values = {
						friend = "Get out interacter",
						clone = "Always clone",
					}
				},
				noTargetMode = {
					order = 2,
					name = "Used without a target",
					desc = "What to do when you activate the addon without having a target",
					type = "select",
					values = {
						nothing = "Do nothing",
						random = "Get out random pet",
					},
				},
				similarMode = {
					order = 3,
					name = "If you own similar only",
					desc = "What to do when used on a pet you don't own when you do own a similar pet",
					type = "select",
					values = {
						similar = "Get out similar pet",
						cantclone = "Treat as uncloneable"
					},
				},
				cantCloneMode = {
					order = 4,
					name = "Used on uncloneable target",
					desc = "What to do when you attemt to clone a non-player target and you don't own a clone (or interacting pet if that feature is turned on)",
					type = "select",
					values = {
						nothing = "Do nothing",
						random = "Get out random pet",
					},
				},
				summonCooldownPet = {
					order = 10,
					name = "Summon cooldown pet",
					type = "select",
					desc = "When to consider summoning a pet that has a cooldown",
					values = {
						clone = "Only when cloning",
						always = "Even on random",
					}
				},
				summonReagentPet = {
					order = 11,
					name = "Summon reagent pet",
					type = "select",
					desc = "When to consider summoning a pet that uses a reagent",
					values = {
						clone = "Only when cloning",
						always = "Even on random",
					}
				},
			}
		},
		keybindings = {
			name = "Keybindings",
			type = "group",
			inline = true,
			order = 20,
			args = {
				info = {
					type = "description",
					order = 0,
					name = "Set this to activate CompanionClone with a key",
				},
				defaultkey = {
					name = "Clone etc.",
					desc = BINDING_NAME_CLONETARGET,
					type = "keybinding",
					order = 10,
					set = function(info, val)
						-- unbind old key
						local oldKey = GetBindingKey("CLONETARGET")
						if oldKey ~= nil then
							SetBinding(oldKey, nil)
						end
						-- set new one if it wasn't escape which is supposed to just clear
						if key ~= "ESCAPE" then
							SetBinding(val, "CLONETARGET")
						end
						-- save
						SaveBindings(GetCurrentBindingSet())
					end,
					get = function(info)
						return GetBindingKey("CLONETARGET") 
					end
				},
			}
		},
	}
}

-- make emotes section exist first so functions can do something with it

local emotes = {
	args = {}
}

-- The stuff that's the same for every emote section

local function staticEmoteConfig()
	return {
	-- name
	type = "group",
	inline = true,
	-- order
	args = {
		type = {
			order = 1,
			name = "Action",
			type = "select",
			values = {
				EMOTE = "Emote",
				SAY = "Say",
				group = "Group or raid",
				test = "Test message",
			},
			-- set
			-- get
		},
		text = {
			order = 2,
			name = "Text",
			type = "input",
			-- set
			-- get
		},
		clonePet = {
			order = 10,
			name = "On cloning pet",
			desc = "Check this box to do this when you clone a pet",
			type = "toggle",
			-- set
			-- get
		},	
		cloneMount = {
			order = 11,
			name = "On cloning mount",
			desc = "Check this box to do this when you clone a mount",
			type = "toggle",
			-- set
			-- get
		},
		friend = {
			order = 12,
			name = "On interacting pet",
			desc = "Check this box to do this when you get out an interacting pet",
			type = "toggle",
			-- set
			-- get
		},
		similar = {
			order = 13,
			name = "On similar pet",
			desc = "Check this box to do this when you get out a similar pet",
			type = "toggle",
			-- set
			-- get
		},
		randomPet = {
			order = 14,
			name = "On random pet",
			desc = "Check this box to do this when you get out a random pet",
			type = "toggle",
			-- set
			-- get
		},
		remove = {
			type = "execute",
			order = 100,
			name = "Remove",
			-- func
		}
	}
}
end

-- Emote class since adding and removing them can get messy.  This is still somewhat messy.  TODO: use cleaner method, with proper higher up setter and getter functions.

local Emote = { all = { } }
Emote.__index = Emote

function Emote:setIndex(index)
	self.index = index or self.index
	self.configSection.name = "Emote/Speech "..self.index
	self.configSection.order = 5 + self.index
end

function Emote:new()
	-- create an object
	local o = { }
	setmetatable(o, Emote)
	-- give it a new index	
	o.index = #Emote.all + 1
	-- create the config panel section and add the functions that are specific to each
	o.configSection = staticEmoteConfig()
	o.configSection.args.type.set = function(info, val) CompanionClone.db.profile.emote[o.index].chatType = val end
	o.configSection.args.type.get = function(info) return CompanionClone.db.profile.emote[o.index].chatType end
	o.configSection.args.text.set = function(info, val) CompanionClone.db.profile.emote[o.index].text = val end
	o.configSection.args.text.get = function(info) return CompanionClone.db.profile.emote[o.index].text end
	o.configSection.args.clonePet.set = function(info, val) CompanionClone.db.profile.emote[o.index].clonePet = val end
	o.configSection.args.clonePet.get = function(info) return CompanionClone.db.profile.emote[o.index].clonePet end
	o.configSection.args.cloneMount.set = function(info, val) CompanionClone.db.profile.emote[o.index].cloneMount = val end
	o.configSection.args.cloneMount.get = function(info) return CompanionClone.db.profile.emote[o.index].cloneMount end
	o.configSection.args.friend.set = function(info, val) CompanionClone.db.profile.emote[o.index].friend = val end
	o.configSection.args.friend.get = function(info) return CompanionClone.db.profile.emote[o.index].friend end
	o.configSection.args.similar.set = function(info, val) CompanionClone.db.profile.emote[o.index].similar = val end
	o.configSection.args.similar.get = function(info) return CompanionClone.db.profile.emote[o.index].similar end
	o.configSection.args.randomPet.set = function(info, val) CompanionClone.db.profile.emote[o.index].randomPet = val end
	o.configSection.args.randomPet.get = function(info) return CompanionClone.db.profile.emote[o.index].randomPet end
	o.configSection.args.remove.func = function() o:remove() end
	o.configSection.args.remove.confirm = function() return "Remove "..o.configSection.name.."?" end
	-- have it set the index the other ways it needs to be set
	o:setIndex()
	-- if this is a new one with no config db entry yet, add one
	CompanionClone.db.profile.emote[o.index] = CompanionClone.db.profile.emote[o.index] or {}
	-- store it in the class array
	table.insert(Emote.all, o)
	-- add it to the thing that will define the options panel
	emotes.args["emote"..o.index] = o.configSection
	-- return like a normal constructor even though this isn't currently used
	return o
end

function Emote:decrement()
	emotes.args["emote"..self.index] = nil
	self:setIndex(self.index - 1)
	emotes.args["emote"..self.index] = self.configSection
end

function Emote:remove()
	emotes.args["emote"..#Emote.all] = nil
	for i = self.index + 1, #Emote.all do
		Emote.all[i]:decrement()
	end
	table.remove(CompanionClone.db.profile.emote, self.index)
	table.remove(Emote.all, self.index)
end

emotes = {
	name = "Emotes",
	type = "group",
	args = {
		info = textInABox(
			"About",
			"If you would like your character to emote an action or say something you can set it here.  If you select \"Test Message\" for action, then it will just print in your chat frame so you can see what it would do.\n\n!C will be replaced by the companion you summon\n!T will be replaced by the name of your target.\n\nRemember to click the little okay button after you enter your text.",
			1
		),
		addEmote = {
			type = "group",
			inline = true,
			order = 100,
			name = "Another emote/speech",
			args = {
				add = {
					type = "execute",
					name = "Add another",
					func = function()
						Emote:new()
					end
				}
			}
		}
	}
}

local help = {
	name = "Help",
	type = "group",
	args = {
		usage = {
			type = "group",
			name = "Usage",
			args = {
				intro = textInABox(
					"About",
					"CompanionClone allows you target a pet or mount and use any of the methods below to summon a pet or mount identical to one you have targeted.  If you have a pet that interacts with the targeted pet, it can summon that instead, and it can also summon a random pet when you don't have a target.\n\nSee the main CompanionClone options panel for various options about what to summon when, and the Emotes panel for setting emotes or speech for your character to do/say. Mouseover text on the dropdown arrows provides more information about each option.",
					1
				),
				libdatabroker = textInABox(
					"LibDataBroker",
					"CompanionClone provides a LibDataBroker plugin if you have a LibDataBroker display addon."
				),
				command = textInABox(
					"Slash command",
					"CompanionClone provides the command /companionclone.  It can be used in a macro.  Use it as follows:\n\n/companionclone - attempt to clone the target, using preferences to determine behavior\n/companionclone config - open options panel\n/companionclone help - open help panel"
				),
				keybindings = textInABox(
					"Key Binding",
					"You can set a key binding either in the main CompanionClone preference page or in the blizzard keybindings menu."
				)
			}
		},
		howtohelp = {
			name = "How to help me",
			type = "group",
			order = -10,
			args = { 
				bugs = textInABox(
					"Bugs", 
					"If you find any bugs or it doesn't behave how you would expect it to, please let me know.  The user base of this addon is just big enough that other people are probably experiencing the same bug, but you can't count on anyone reporting it if you don't; I might not know to fix it until someone tells me about it."
				),
				data = textInABox(
					"Am I missing data?",
					"Some behavior needs to be coded manually and I may be missing some data.  Please let me know if you know of any of the following:\n- Mounts with different buff names than spell names besides the paladin class mounts and Bronze Drake\n- Pets that have different unit names than spell names\n- Pets that interact with specific other pets besides Stinker/any black cat and Grunty/Zergling\n - Pets other than Guild Herald and Guild Page that have cooldowns\n - Pets other than the Winter's Veil ones that require reagents\n - Particular pets that are similar to other pets that you'd liked included in the similar pet summoning feature" 
				),
				requests = textInABox(
					"Feature requests",
					"Do let me know if you have any feature requests! Many of the features this addon has were requested before I added them.  Even if it's a feature I've already thought of I'm more likely to get around to it, and sooner, if I know someone wants it.  So your feature requests make this a better addon."
				),
				appreciation = textInABox(
					"Show your appreciation",
					"The more people I know use and enjoy the addon the more motiviated I am to keep it up-to-date and improve it.  So let me know."
				)
			}
		},
		about = {
			name = "About/Contact",
			type = "group",
			order = -20,
			args = {
				info = {
					type = "description",
					fontSize = "medium",
					-- this-version added in OnEnable
					name = [[You can contact me via email at luacayenne@gmail.com, or on curse you can send a message to LuaCayenne or leave a comment on the CompanionClone page, or you can file a ticket on the CompanionClone curseforge page.]]
				}
			}
		}
	}
}

local defaults = {
	profile = {
		friendMode = "friend",
		similarMode = "similar",
		noTargetMode = "random",
		cantCloneMode = "nothing",
		summonCooldownPet = "clone",
		summonReagentPet = "clone",
		emote = {} -- emote[i].chatType, emote[i].text, emote[i].clonePet, emote[i].friend, emote[i].cloneMount, emote[i].randomPet
	}
}

local function createOptionsPanel(optionsTable, name, parent)
	local fullName = name
	if parent ~= nil then
		fullName = parent.."-"..name
	end
	AceConfig:RegisterOptionsTable(fullName, optionsTable)
	if parent ~= nil then
		Config[fullName] = AceConfigDialog:AddToBlizOptions(fullName, name, parent)
	else
		Config[fullName] = AceConfigDialog:AddToBlizOptions(fullName)
	end
end

function Config:OnInitialize()
	CompanionClone.db = LibStub("AceDB-3.0"):New("CompanionCloneDB", defaults, true)
	help.args.about.args.info.name = "\nCompanionClone by Cayenne\n\nversion "..GetAddOnMetadata("CompanionClone", "Version").."\n\n"..help.args.about.args.info.name
	createOptionsPanel(options, "CompanionClone")
	createOptionsPanel(emotes, "Emotes", "CompanionClone")
	createOptionsPanel(AceDBOptions:GetOptionsTable(CompanionClone.db), "Profiles", "CompanionClone")
	createOptionsPanel(help, "Help", "CompanionClone")
	for i = 1, #CompanionClone.db.profile.emote do
		Emote:new()
	end
end
