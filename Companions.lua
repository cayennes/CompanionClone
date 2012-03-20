local CompanionClone = LibStub("AceAddon-3.0"):GetAddon("CompanionClone")
local Companions = CompanionClone:GetModule("Companions")

-- lists of pets that have cooldowns or require reagents

Companions.usesReagent = {
	["Winter's Little Helper"] = true,
	["Winter Reindeer"] = true,
	["Tiny Snowman"] = true,
	["Father Winter's Helper"] = true,
}

Companions.hasCooldown = {
	["Guild Herald"] = true,
	["Guild Page"] = true,
}

-- TODO: before I add any of these to the similar or friends lists, figure out how I want to make the options for not summoning them in these cases work

-- list of pets that interact with other pets

local friends = {
	Stinker = {"Bombay Cat", "Black Tabby Cat", "Calico Cat"},
	["Bombay Cat"] = {"Stinker"},
	["Black Tabby Cat"] = {"Stinker"},
	["Calico Cat"] = {"Stinker"},
	Zergling = {"Grunty"},
	Grunty = {"Zergling"},
}

-- list of pets that are similar to other pets

-- TODO: more
-- TODO: make this a file of its own
local similar = {
	-- birds
	["Blue Mini Jouster"] = {"Gold Mini Jouster"},
	["Gold Mini Jouster"] = {"Blue Mini Jouster"},
	-- cats
	["Black Tabby Cat"] = {"Silver Tabby Cat", "Calico Cat", "Bombay Cat", "Orange Tabby Cat", "Cornish Rex Cat", "Siamese Cat", "White Kitten", "Panther Cub", "Winterspring Cup", "Spectral Tiger Cub"},
	["Bombay Cat"] = {"Calico Cat", "Black Tabby Cat", "Silver Tabby Cat", "Orange Tabby Cat", "Cornish Rex Cat", "Siamese Cat", "White Kitten", "Panther Cub", "Winterspring Cup", "Spectral Tiger Cub"},
	["Brown Prairie Dog"] = {"Mechanical Squirrel", "Giant Sewer Rat", "Whiskers the Rat"},
	["Calico Cat"] = {"Bombay Cat", "Black Tabby Cat", "Silver Tabby Cat", "Siamese Cat", "Cornish Rex Cat", "Orange Tabby Cat", "White Kitten", "Panther Cub", "Winterspring Cup", "Spectral Tiger Cub"},
	["Cornish Rex Cat"] = {"Orange Tabby Cat", "Silver Tabby Cat", "Black Tabby Cat", "Calico Cat", "Siamese Cat", "Bombay Cat", "White Kitten", "Panther Cub", "Winterspring Cup", "Spectral Tiger Cub"},
	["Orange Tabby Cat"] = {"Cornish Rex Cat", "Silver Tabby Cat", "Black Tabby Cat", "Calico Cat", "Siamese Cat", "Bombay Cat", "White Kitten", "Panther Cub", "Winterspring Cup", "Spectral Tiger Cub"},
	["Siamese Cat"] = {"Silver Tabby Cat", "Black Tabby Cat", "Orange Tabby Cat", "Cornish Rex Cat", "Calico Cat", "Bombay Cat", "White Kitten", "Spectral Tiger Cub", "Winterspring Cup", "Panther Cub"},
	["Silver Tabby Cat"] = {"Black Tabby Cat", "Siamese Cat", "White Kitten", "Orange Tabby Cat", "Cornish Rex Cat", "Calico Cat", "Bombay Cat", "Spectral Tiger Cub", "Winterspring Cup", "Panther Cub"},
	["Spectral Tiger Cub"] = {"Winterspring Cub", "Panther Cub", "White Kitten", "Silver Tabby Cat", "Siamese Cat", "Cornish Rex Cat", "Black Tabby Cat", "Calico Cat", "Bombay Cat", "Orange Tabby Cat"},
	["Winterspring Cub"] = {"Spectral Tiger Cub", "Panther Cub", "White Kitten", "Silver Tabby Cat", "Siamese Cat", "Cornish Rex Cat", "Black Tabby Cat", "Calico Cat", "Bombay Cat", "Orange Tabby Cat"},
	["Panther Cub"] = {"Winterspring Cub", "Spectral Tiger Cub", "Black Tabby Cat", "Bombay Cat", "Calico Cat", "White Kitten", "Silver Tabby Cat", "Siamese Cat", "Cornish Rex Cat", "Orange Tabby Cat"},
	["White Kitten"] = {"Siamese Cat", "Silver Tabby Cat", "Black Tabby Cat", "Orange Tabby Cat", "Cornish Rex Cat", "Calico Cat", "Bombay Cat", "Spectral Tiger Cub", "Winterspring Cup", "Panther Cub"},
	-- dinosaurs (TODO: order by color)
	["Darting Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Deviate Hatchling"] = {"Darting Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Gundrak Hatchling"] = {"Darting Hatchling", "Darting Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Lashtail Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Darting Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Leaping Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Darting Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Obsidian Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Darting Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Ravasaur Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Darting Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Razormaw Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Darting Hatchling", "Razzashi Hatchling", "Fossilized Hatchling"},
	["Rezzashi Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Darting Hatchling", "Fossilized Hatchling"},
	["Fossiziled Hatchling"] = {"Deviate Hatchling", "Gundrak Hatchling", "Lashtail Hatchling", "Leaping Hatchling", "Obsidian Hatchling", "Ravasaur Hatchling", "Razormaw Hatchling", "Razzashi Hatchling", "Darting Hatchling"},
	-- hippogryphs
	["Cenarion Hatchling"] = {"Hippogryph Hatchling"},
	["Hippogryph Hatchling"] = {"Cenarion Hatchling"},
	-- invertabrates
	["Legs"] = {"Tiny Sporebat"},
	["Tiny Sporebat"] = {"Legs"},
	-- liches
	["Landro's Lichling"] = {"Lil' K.T."},
	["Lil' K.T."] = {"Landro's Lichling"},
	-- robots
	["Blue Clockwork Rocket Bot"] = {"Clockwork Rocket Bot", "Warbot"},
	["Clockwork Rocket Bot"] = {"Blue Clockwork Rocket Bot", "Warbot"},
	["Landro's Lil' XT"] = {"Lil' XT", "Personal World Destroyer"},
	["Lil' XT"] = {"Landro's Lil' XT", "Personal World Destroyer"},
	["Personal World Destroyer"] = {"Landro's Lil' XT", "Lil' XT"},
	["Warbot"] = {"Blue Clockwork Rocket Bot", "Clockwork Rocket Bot"},
	-- rodents
	["Giant Sewer Rat"] = {"Whiskers the Rat", "Mechanical Squirrel", "Brown Prairie Dog"},
	["Mechanical Squirrel"] = {"Brown Prairie Dog", "Whiskers the Rat", "Giant Sewer Rat"},
	["Whiskers the Rat"] = {"Giant Sewer Rat", "Mechanical Squirrel", "Brown Prairie Dog"},
	["Brown Prairie Dog"] = {"Giant Sewer Rat", "Whiskers the Rat", "Mechanical Squirrel"},
	-- voodoo
	["Voodoo Figurine"] = {"Sen'jin Fetish"},
	["Sen'jin Fetish"] = {"Voodoo Figurine"},
}

-- aura to mount spell where it's different; fall back to same for those things not listed

local auraToSpellName = {
	["Summon Charger"] = "Charger",
	["Summon Warhorse"] = "Warhorse",
	["Bronze Drake"] = "Bronze Drake Mount",
	__index = function(_, auraName) 
		return auraName 
	end
}
setmetatable(auraToSpellName, auraToSpellName)

-- read your collection

local initialized = false

function Companions:getOwnedCompanions()
	self.ownedPets = {}
	self.forRandom = {}
	-- pets
	for i=1, GetNumCompanions("CRITTER") do
		_, name = GetCompanionInfo("CRITTER", i)
		self.ownedPets[name] = i
		self.ownedPets[i] = name
		-- NOTE: this uses the fact that none both require reagents and have cooldowns.  I don't expect them to add any more pets with reagents, but if somehow this changed the addon would nee to be updated.
		if self.hasCooldown[name] == true then
			if CompanionClone.db.profile.summonCooldownPet == "always" then
				self.forRandom[#self.forRandom + 1] = name
			end
		elseif self.usesReagent[name] == true then
			if CompanionClone.db.profile.summonReagentPet == "always" then
				self.forRandom[#self.forRandom + 1] = name
			end
		else
			self.forRandom[#self.forRandom + 1] = name
		end
	end
	-- mounts
	self.ownedMounts = {}
	for i=1, GetNumCompanions("MOUNT") do
		_, name = GetCompanionInfo("MOUNT", i)
		self.ownedMounts[name] = i
		self.ownedMounts[i] = name
	end
	initialized = true
end

-- Note that this function doesn't actually do quite what it says; it only gets the units mount if you own it.  I'd need a full database of mounts to get any mount.
function Companions:getUnitsMount(unit)
	if not initialized then self:getOwnedCompanions() end
	for i=1, 40 do
		local mount = auraToSpellName[(UnitBuff(unit, i))]
		-- done if no more buffs
		if mount == nil then
			return nil
		-- mount if the buff is a mount we have
		elseif self.ownedMounts[mount] ~= nil then
			return mount
		end
	end
end

-- Convert spell or unit names to index

function Companions:getPetIndex(pet)
	if not initialized then self:getOwnedCompanions() end
	if type(pet) == "number" then
		return pet
	else
		return self.ownedPets[pet]
	end
end

function Companions:getMountIndex(mount)
	if not initialized then self:getOwnedCompanions() end
	if type(mount) == "number" then
		return mount
	else 
		return self.ownedMounts[mount] or self.ownedMounts[auraToSpellName[mount]]
	end
end

-- these should accept unit name, spell name, or index

function Companions:callPet(pet)
	if not initialized then self:getOwnedCompanions() end
	DismissCompanion("CRITTER")
	CallCompanion("CRITTER", self:getPetIndex(pet))
end

function Companions:callMount(mount)
	if not initialized then self:getOwnedCompanions() end
	DismissCompanion("MOUNT")
	CallCompanion("MOUNT", self:getMountIndex(mount))
end

-- find friend

function Companions:findFriend(pet)
	if not initialized then self:getOwnedCompanions() end
	if friends[pet] == nil then
		return nil
	else
		local found = {}
		if friends[pet] ~= nil then
			for i=1, #friends[pet] do
				if self.ownedPets[friends[pet][i]] ~= nil then
					found[#found+1] = friends[pet][i]
				end
			end
		end
		if #found == 0 then
			return nil
		else
			return found[random(#found)]
		end
	end
end

function Companions:findSimilar(pet)
	if similar[pet] ~= nil then
		for i = 1, #similar[pet] do
			if self:getPetIndex(similar[pet][i]) then
				return similar[pet][i]
			end
		end
	end
	return nil
end

function Companions:randomPet()
	if not initialized then self:getOwnedCompanions() end
	if #self.forRandom > 0 then
		local petNum = random(#self.forRandom)
		return self.forRandom[petNum]
	else
		return nil
	end
end

-- initialization and events

function Companions:OnEnable()
	self:RegisterEvent("COMPANION_LEARNED", "getOwnedCompanions") -- recreate list when new things are learned
end

