GMage = {
	SpellTextures = {
		fireball = "Spell_Shadow_AbominationExplosion",
		frostbolt = "Spell_Shadow_ShadowBolt",
		scorch = "",
		counterSpell = "lol",
		polymorph = "lol"
	}	
}

if UnitClass("player") ~= "Mage" then return end

SLASH_GMage_ROTATION1 = '/GMage'
function SlashCmdList.GMage_ROTATION(rotation)
	rotation = tostring(rotation)
	rotation = string.lower(rotation)
	-- gold #|cFFFFD700
	-- 00BFFF
	if rotation == "dps" then
		GMage.DPS()		
	elseif string.find(rotation,"curse") then 
			if rotation == "curse coe" then
				GSaved.GMage.CurseName = "Curse of the Elements"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFCurse of the Elements ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse cos" then
				GSaved.GMage.CurseName = "Curse of Shadow"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFCurse of Shadow ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse cow" then
				GSaved.GMage.CurseName = "Curse of Weakness"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFCurse of Weakness ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse coa" then
				GSaved.GMage.CurseName = "Curse of Agony"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFCurse of Agony ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse off" then
				GSaved.GMage.CurseName = nil
				DEFAULT_CHAT_FRAME:AddMessage("You will no longer apply ".."|cFF00BFFFany curse".."|cFFFFFFFF during your rotation.")
			else 
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFGMage ".."|cFFFFD700-GoldMultiboxing-".."|cFFFFFFFF A multiboxing supplementary.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFUsage".."|cFFFFFFFF: /GMage curse {Off | CoA | CoE | CoS | CoW}")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFOff: ".."|cFFFFFFFFNo curse will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFCoA: ".."|cFFFFFFFFCurse of Agony will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFCoE: ".."|cFFFFFFFFCurse of the Elements will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFCoS: ".."|cFFFFFFFFCurse of Shadow will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFCoW: ".."|cFFFFFFFFCurse of Weakness will be applied during your rotation.")
			end
	else	
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFGMage ".."|cFFFFD700-GoldMultiboxing-".."|cFFFFFFFF A multiboxing supplementary.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFFUsage".."|cFFFFFFFF: /GMage {dps | polymorph | counterSpell}")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFdps: ".."|cFFFFFFFFMage dps rotation.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFpolymorph: ".."|cFFFFFFFFSets what mark you will Polymorph.")  
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF00BFFFcounterSpell: ".."|cFFFFFFFFSets when you will use Counter Spell.")  
	end	
	GMage.InitVariables()
end

function GMage.OnActionbarOpdate()
	GMage.fireBlastIndex = GBox.FindActionButton(GMage.SpellTextures.fireBlast)
	GMage.fireballIndex = GBox.FindActionButton(GMage.SpellTextures.fireball)
	GMage.frostboltIndex = GBox.FindActionButton(GMage.SpellTextures.frostbolt)
	GMage.scorchIndex = GBox.FindActionButton(GMage.SpellTextures.scorch)
	GMage.counterSpellIndex = GBox.FindActionButton(GMage.SpellTextures.counterSpell)
	GMage.polymorphIndex = GBox.FindActionButton(GMage.SpellTextures.polymorph)
end	

function GMage.OnGroupUpdate()
	GMage.castersInGroup = GBox.CastersInGroup()	
	GMage.fireBlastHP = GMage.castersInGroup * 400
end

function GMage.OnBagUpdate()	
	GLock.manastone = GBox.CountItems("Major Manastone")
end

function GMage.InitVariables()
	-- saved vars
	GMage.polyNumber = GSaved.GMage.polyNumber 
	
	
	-- timers
	GMage.scorchTimer = 0
	
	GMage.OnGroupUpdate()
	GMage.OnBagUpdate()
	GMage.OnActionbarOpdate()
	
	--ignite 
	--GMage.igniteInfo 
	GMage.igniteStatus = nil
	
	
end 

function GMage.ignite()
	-- drop ignite
	if string.find (GBox.igniteInfo,"(.+) Scorch crits (.+)") or string.find (GBox.igniteInfo,"(.+) Fire Blast crits (.+)") then
		GMage.igniteStatus = 2
	-- ignite on fireball	
	elseif string.find (GBox.igniteInfo,"(.+) Fireball crits(.+)") then
		local i,j = string.find(GBox.igniteInfo,"%d+")
		GBox.m(string.sub(GBox.igniteInfo,i,j))
		GMage.igniteStatus = 1
	-- ignite gone	
	elseif 	string.find (GBox.igniteInfo,"Ignite fades from (.+)") then
		GMage.igniteStatus = nil	
	end
	
	--GMage.igniteInfo
	
end

function GMage.DPS()	
	
	if not UnitExists("target") then return end
	
	-- manastone
	if GBox.Combat and GMage.manastone and GBox.Mana() <=15 and GBox.HP() >=5 then
		GBox.UseItem("Major Healthstone")
		GMage.manastone = nil
	end
	
	if not GBox.Casting	and not GBox.Channeling and not GBox.SpellOnCD("Shadow Bolt") then
		-- Evocation
		if UnitMana("player") >= 400 then 
			CastSpellByName("Evocation")
		end
			
		-- range check 
		if not GBox.InRange(GMage.fireballIndex) then
			GBox.ms("Not in range for any spells.")
		elseif not GBox.InRange(GMage.scorchIndex) then
			GBox.ms("Not in range for scorch.")	
		end
		
		-- ignite check
		-- if teammate crit on scorc -> drop ignite
		-- if teammate crit on fireball -> ignite go
		-- if 
				
		-- finisher 
		if GMage.igniteStatus == 1 and GMage.combustion then
			CastSpellByName("Combustion")
		elseif GBox.InRange(GMage.scorchIndex) and GetTime() - GMage.scorchTimer >= 29 then
			CastSpellByName("Scorch")
		elseif GBox.InRange(GMage.fireBlastIndex) and UnitHealth("target") <= GMage.fireBlastHP then
			CastSpellByName("Fire Blast")
		elseif GMage.igniteStatus == 2 and GBox.InRange(GMage.frostboltIndex)then
			CastSpellByName("Frostbolt")
		elseif GBox.InRange(GMage.fireballIndex) then
			CastSpellByName("Fireball")
			
		end
		
		-- dps scorch > fireball 	
		
		
		
		
	
	end	
end

