local PRINT_PREFIX = "<CompanionClone> "
local TEST_EMOTE_PRINT_PREFIX = "<CompanionClone test message> "
BINDING_HEADER_COMPANIONCLONE = "CompanionClone"
BINDING_NAME_CLONETARGET = "Clone target or follow CompanionClone preferences"
local CompanionClone = LibStub("AceAddon-3.0"):NewAddon("CompanionClone", "AceEvent-3.0")
local Config = CompanionClone:NewModule("Config")
local Companions = CompanionClone:NewModule("Companions", "AceEvent-3.0")

local doEmote = function(action, product)
	-- make an array of emotes enabled for this action and fully defined
	local emotes = {}
	local emote
	for i = 1, #CompanionClone.db.profile.emote do
		if CompanionClone.db.profile.emote[i][action]
		and CompanionClone.db.profile.emote[i].chatType
		and CompanionClone.db.profile.emote[i].text 
		then
			emotes[#emotes + 1] = CompanionClone.db.profile.emote[i]
		end
	end
	-- don't do it if there aren't any 
	if #emotes == 0 then 
		return
	-- pick a random one if there are
	else
		emote = emotes[random(#emotes)]
	end
	-- figure out what to say
	text, _ = gsub(emote.text, "![cC]", product)
	if UnitName("target") then
		text, _ = gsub(text, "![tT]", UnitName("target"))
	end
	-- channel
	chatType = emote.chatType
	if chatType ~= "test" then
		if chatType == "group" then
			if UnitInRaid("player") then
				chatType = "RAID"
			else
				chatType = "PARTY"
			end
		end
		-- send
		SendChatMessage(text, chatType)
	else
		print(TEST_EMOTE_PRINT_PREFIX..text)
	end
end

-- cloning

function CompanionClone:cloneTarget()
	-- clone mount
	if UnitIsPlayer("target") then
		mount = Companions:getUnitsMount("target")
		if mount and Companions:getMountIndex(mount) then
			Companions:callMount(mount)
			print(PRINT_PREFIX.."Cloned "..mount)
			doEmote("cloneMount", mount)
		else
			print(PRINT_PREFIX.."That player isn't riding a mount you own")
		end
	-- otherwise attempt to friend or clone pet
	else
		local targetName = UnitName("target")
		-- find friend if possible and preferred
		local friend
		if self.db.profile.friendMode == "friend" then
			friend = Companions:findFriend(targetName)
		end
		if friend ~= nil then
			Companions:callPet(friend)
			print(PRINT_PREFIX.."Found "..targetName.."\'s friend "..friend)
			doEmote("friend", friend)
		-- otherwise clone if possible
		elseif Companions:getPetIndex(targetName) ~= nil then
			Companions:callPet(targetName)
			print(PRINT_PREFIX.."Cloned "..targetName)
			doEmote("clonePet", targetName)
		-- look for something similar
		elseif self.db.profile.similarMode == "similar" and Companions:findSimilar(targetName) ~= nil then
			Companions:findSimilar(targetName)
			Companions:callPet(Companions:findSimilar(targetName))
			doEmote("similar", Companions:findSimilar(targetName))
		-- otherwise see why not, do what the preferences say, and print message
		elseif targetName ~= nil then
			if self.db.profile.cantCloneMode == "nothing" then
				print(PRINT_PREFIX.."You don't own a "..targetName.." pet")
			elseif self.db.profile.cantCloneMode == "random" then
				local pet = Companions:randomPet()
				if pet then
					print(PRINT_PREFIX.."You don't own a "..targetName.." pet so a "..pet.." was summoned randomly instead")
					Companions:callPet(pet)
					doEmote("randomPet", pet)
				else
					print(PRINT_PREFIX.."You don't own a "..targetName.." and you have no pets to randomly summon")
				end
			end
		else 
			if self.db.profile.noTargetMode == "nothing" then
				print(PRINT_PREFIX.."Do this while targeting a pet or mounted player to get out your clone.")
			elseif self.db.profile.noTargetMode == "random" then
				local pet = Companions:randomPet()
				if pet then
					Companions:callPet(pet)
					print(PRINT_PREFIX.."You don't have a target so a "..pet.." was summoned randomly")
					doEmote("randomPet", pet)
				else
					print(PRINT_PREFIX.."You have no pets to randomly summon")
				end
			end
		end
	end
end

-- slash command

local commandTable = {
	config = function() 
		InterfaceOptionsFrame_OpenToCategory(Config["CompanionClone-Help"])
		InterfaceOptionsFrame_OpenToCategory("CompanionClone") 
	end,
	help = function() 
		InterfaceOptionsFrame_OpenToCategory(Config["CompanionClone-Help"]) 
	end,
	[""] = function() 
		CompanionClone:cloneTarget()
	end,
	__index = function() return function() 
		print(PRINT_PREFIX.."type /companionclone help for usage information") 
	end end
}
setmetatable(commandTable, commandTable)

SLASH_COMPANIONCLONE1 = "/companionclone"
SlashCmdList["COMPANIONCLONE"] = function(action) 
	commandTable[action:lower()]()
end

-- Initialization

function CompanionClone:OnEnable()
	print(PRINT_PREFIX..[[addon loaded: type "/companionclone help" for more information]])
end

-- LDB button

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("CompanionClone", {
	type = "launcher",
	icon = "Interface\\Icons\\Ability_Seal",
	OnClick = function(clickedframe, button)
		if button == "LeftButton" then
			CompanionClone:cloneTarget()
		elseif button == "RightButton" then
			commandTable["config"]()
		end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		tooltip:AddLine("CompanionClone "..GetAddOnMetadata("CompanionClone", "Version"))
		tooltip:AddLine("Left-click to clone target")
		tooltip:AddLine("Right-click for options")
	end,
})
