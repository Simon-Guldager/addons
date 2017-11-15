GLock = {
	SpellTextures = {
		Corruption = "Spell_Shadow_AbominationExplosion",
		ShadowBolt = "Spell_Shadow_ShadowBolt"
	}	
}

if UnitClass("player") ~= "Warlock" then return end

SLASH_GLock_ROTATION1 = '/glock'
function SlashCmdList.GLock_ROTATION(rotation)
	rotation = tostring(rotation)
	rotation = string.lower(rotation)
	if rotation == "dps" then
		GLock.DPS()		
	elseif string.find(rotation,"curse") then
			if rotation == "curse coe" then
				GSaved.GLock.curseName = "Curse of the Elements"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BCurse of the Elements ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse cos" then
				GSaved.GLock.curseName = "Curse of Shadow"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BCurse of Shadow ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse cow" then
				GSaved.GLock.curseName = "Curse of Weakness"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BCurse of Weakness ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse coa" then
				GSaved.GLock.curseName = "Curse of Agony"
				DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BCurse of Agony ".."|cFFFFFFFFWill now be applied during your rotation.")
			elseif rotation == "curse off" then
				GSaved.GLock.curseName = nil
				DEFAULT_CHAT_FRAME:AddMessage("You will no longer apply ".."|cFF8B008Bany curse".."|cFFFFFFFF during your rotation.")
			else 
				DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BGLock ".."|cFFFFD700-GoldMultiboxing-".."|cFFFFFFFF A multiboxing supplementary.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BUsage".."|cFFFFFFFF: /GLock curse {Off | CoA | CoE | CoS | CoW}")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008BOff: ".."|cFFFFFFFFNo curse will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008BCoA: ".."|cFFFFFFFFCurse of Agony will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008BCoE: ".."|cFFFFFFFFCurse of the Elements will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008BCoS: ".."|cFFFFFFFFCurse of Shadow will be applied during your rotation.")
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008BCoW: ".."|cFFFFFFFFCurse of Weakness will be applied during your rotation.")
			end
	else	
		DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BGlock ".."|cFFFFD700-GoldMultiboxing-".."|cFFFFFFFF A multiboxing supplementary.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFF8B008BUsage".."|cFFFFFFFF: /GLock {dps | curse}")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008Bdps: ".."|cFFFFFFFFWarlock dps rotation.")
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF   - ".."|cFF8B008Bcurse: ".."|cFFFFFFFFSets the curse that will be applied during your rotation.")  
	end	
	GLock.InitVariables()
end

function GLock.OnActionbarOpdate()
	GLock.CorruptionIndex = GBox.FindActionButton(GLock.SpellTextures.Corruption)
	GLock.ShadowBoltIndex = GBox.FindActionButton(GLock.SpellTextures.ShadowBolt)
end	

function GLock.OnGroupUpdate()
	GLock.castersInGroup = GBox.CastersInGroup()	
	GLock.dotHPLimit = GLock.castersInGroup * 4000
	GLock.drainSoulHP = GLock.castersInGroup * 500
	GLock.shadowburnHP = GLock.castersInGroup * 400
end

function GLock.OnBagUpdate()	
	GLock.healthstone = GBox.CountItems("Major Healthstone")
	GLock.Shards = GBox.CountItems("Soul Shard")
end

function GLock.InitVariables()	
	-- saved vars
	GLock.curseName = GSaved.GLock.curseName 
	
	-- timers
	GLock.curseTimer = 0
	GLock.corruptionTimer = 0	
	
	-- finisher
	GLock.drainOK = 0
	
	-- item in bag
	GLock.healthstone = nil
	
	-- on opdate
	GLock.OnGroupUpdate()
	GLock.OnBagUpdate()
	GLock.OnActionbarOpdate()
end 

function GLock.DPS()
	--[[ out of combat lifetab
	if not GBox.Combat and UnitManaMax("player") - UnitMana("player") >= 600 and GBox.HP("player") >= 800 then
		CastSpellByName("Life Tap")
	end	]]
	
	if not UnitExists("target") then return end
	
	-- healthstone
	if GBox.Combat and GLock.healthstone and GBox.HP("player") <=10 and GBox.HP() >=5 then
		GBox.UseItem("Major Healthstone")
		GLock.healthstone = nil
	end
	
	if not GBox.Casting	and not GBox.Channeling and not GBox.SpellOnCD("Shadow Bolt") then	
		-- range check
		if not GBox.InRange(GLock.ShadowBoltIndex) then
			GBox.ms("Not in range for any spells.")
		elseif not GBox.InRange(GLock.CorruptionIndex) then
			GBox.ms("Not in range for any DoT's")	
		end
		
		-- check for corruption/curse miss
		if GBox.HitInfo then
			if GLock.Curser and string.find(GBox.HitInfo,"Your "..GLock.curseName.." was (.+)") then
				GLock.Curse = 0
			elseif string.find(GBox.HitInfo,"Your Corruption (.+)") then
				GLock.Corruption = 0	
			end	
			GBox.HitInfo = nil
		end
			
		-- finisher
		if UnitHealthMax("target") <= 60000 and UnitHealth("target") <= GLock.drainSoulHP and GLock.ShadowBolt then
			CastSpellByName("Drain Soul(Rank 1)")
		elseif GLock.Shards >= 3 and UnitHealth("target") <= GLock.shadowburnHP and not GBox.SpellOnCD("Shadowburn") then
			CastSpellByName("Shadowburn")
		end
		
		GLock.drainOk = 0
		
		-- dps corruption > life tab > shadow bolt
		if GLock.curseName and GBox.InRange(GLock.CorruptionIndex) and UnitHealth("target") >= GLock.dotHPLimit and UnitMana("player") >= 250 and GetTime() - GLock.curseTimer >= 298 then
			CastSpellByName(GLock.curseName)
			GLock.curseTimer = GetTime()
		elseif GBox.InRange(GLock.CorruptionIndex) and UnitHealth("target") >= GLock.dotHPLimit and UnitMana("player") >= 290 and GetTime() - GLock.corruptionTimer >= 17 then
			GLock.corruptionTimer = GetTime()
			CastSpellByName("Corruption")	
		elseif UnitMana("player") <= 355 and GBox.HP("player") >= 800 then	
			CastSpellByName("Life Tap")
		elseif GBox.InRange(GLock.ShadowBoltIndex) and UnitMana("player") >= 355 then
			CastSpellByName("Shadow Bolt")
			GLock.drainOK = 1
		end
	end	
end

