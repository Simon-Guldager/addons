function one_HP(unit)
	local unit = unit or "target"
	local percent = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
	return percent
end

function one_Mana(unit)
	local unit = unit or "player"
	return UnitMana("player")
end

function one_m(msg)
	local msg = msg or "No message"
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function one_ms(msg)
	local msg = msg or "No message"
	SendChatMessage(msg)	
end

function one_InRange(slot)
	inRange = IsActionInRange(slot)
	if inRange == 0 then
		return nil
	else
		return 1
	end
end


function one_CountItems(itemIn)
	local count = 0
	for bag = 0, 4 do 
		for slot = 1, 16 do 
			local name = GetContainerItemLink(bag,slot) 
			if name and string.find(name,itemIn) then 
				count = count + 1
			end 
		end
	end
	return count
end

function one_UseItem(itemIn)
	for bag = 0, 4 do 
		for slot = 1, 16 do 
			local name = GetContainerItemLink(bag,slot) 
			if name and string.find(name,itemIn) then 
				UseContainerItem(bag,slot) 
			end 
		end
	end
end

function one_CastersInGroup()
	local casters = 0
	local groupMembers = 1	 
	local target = "player"
	if UnitInRaid("player") then
		gropmembers = GetNumRaidMembers()
		target = "raid"
	elseif UnitInParty("player") then
		casters = 1
		groupMembers = 4
		target = "party"
	else
		casters = 1
	end
	for i = 1,groupMembers do
		TargetUnit(target..i)		
		if UnitClass("target") == "Mage" or UnitClass("target") == "Warlock" then
		casters = casters + 1	
		end
		ClearTarget()
	end
	return casters
end


-- [[ Spell Functions ]]


-- returns the spellID of a given spellName.
function one_GetSpellId(spellname)
	local id = 1
	for i = 1, GetNumSpellTabs() do
		local _, _, _, numSpells = GetSpellTabInfo(i)
		for j = 1, numSpells do
			local spellName = GetSpellName(id, BOOKTYPE_SPELL)
			if (spellName == spellname) then
				return id 
			end
			id = id + 1
		end
	end
	return nil	
end

-- returns the spellMaxRank of a given spellName.
function one_GetSpellRank(spellName)
	local rslt = 0
	local rankIndex = 0
	if spellName then		
		local id = one_GetSpellId(spellName)
		if id then	
			spell, rank = GetSpellName(id, BOOKTYPE_SPELL)
			if rank then 
				while rankIndex <= 15 do		
					if spell ~= GetSpellName(id + rankIndex, BOOKTYPE_SPELL) then
						break 		
					end	
					rankIndex = rankIndex + 1
				end
			else
				return 0
			end	
		end		
	end
	return rankIndex
end

-- returns true if a spell is on cooldown.
function one_SpellOnCD(spellName)
	local id = one_GetSpellId(spellName)
	if id then
		local start, duration = GetSpellCooldown(id, 0)
		if start == 0 and duration == 0 then
			return nil
		end
	end
	return true
end


--[[ ActionButton Functions ]]--


-- returns the spellName, spellRank, rankName, text, for a given actionSlot. 
function one_GetActionButtonTooltip(slot)
	if slot and HasAction(slot) then
		local text = GetActionText(slot)
		if text then
			return nil, nil, text
		end
		local lt = nil
		local spellName = nil
		local rt = nil
		local spellRank = nil
		local rankName = nil
		one_Button_Tooltip:SetAction(slot)
		local Lines = one_Button_Tooltip:NumLines()
		if Lines and Lines > 0 then
			lt = getglobal("one_Button_TooltipTextLeft1")
			if lt:IsShown() then
				spellName = lt:GetText()
				if spellName == "" then
					spellName = nil
				end
			end			
		end
		if spellName then
			rt = getglobal("one_Button_TooltipTextRight1")
			if rt:IsShown() then
				rankName = rt:GetText()
				if rankName == "" then
					rankName = nil
				end
			end
			if rankName then
				local found, _, rank = string.find(rankName, "(%d+)")
				if found then
					spellRank = tonumber(rank)
					rankName = "("..rankName..")"
				else
					spellRank = 1
					rankName = ""
				end
			else
				spellRank = 1
				rankName = ""
			end
			return spellName, spellRank, nil
		end
	end	
	return nil
end

-- adds actionButton spellName, spellRank, text, to the one_Button table. 
function one_RegisterButtons()
	one_Button = {}
	
	for i = 1, 120 do
		local spellName, spellRank, text = one_GetActionButtonTooltip(i)
		if text then
			if one_Button["Macro".."."..text] ~= i then
				one_Button["Macro".."."..text] = i
				one_m(text)
			end	
		elseif spellName and one_Button[spellName.."."..spellRank] ~= i then
			if one_Button[spellName] ~= i and spellRank == one_GetSpellRank(spellName) then
				one_Button[spellName] = i
				one_m(spellName)
			elseif one_GetSpellRank(spellName) > 0 then
				one_Button[spellName.."."..spellRank] = i
				one_m(spellName.."."..spellRank)
			end
		end
	end
end