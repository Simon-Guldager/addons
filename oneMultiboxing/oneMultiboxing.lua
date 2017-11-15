GBox = {}

GSaved = {
	GLock = {
		CurseName = nil
	},
	GMage = {
		Polymorph = nil,
		CounterSpell = nil
	}
}

one_debug = false

function one_OnLoad() 
	-- for loading variables	
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	this:RegisterEvent("PLAYER_LEAVING_WORLD")
	this:RegisterEvent("PLAYER_LOGIN")
	this:RegisterEvent("GROUP_ROSTER_UPDATE")
	this:RegisterEvent("RAID_ROSTER_UPDATE")
	this:RegisterEvent("PARTY_CONVERTED_TO_RAID")
	-- for combat status
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("PLAYER_REGEN_DISABLED")
	-- for casting
	this:RegisterEvent("SPELLCAST_CHANNEL_START")
	this:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
	this:RegisterEvent("SPELLCAST_CHANNEL_STOP")
	this:RegisterEvent("SPELLCAST_START")
	this:RegisterEvent("SPELLCAST_STOP")
	this:RegisterEvent("SPELLCAST_INTERRUPTED")
	this:RegisterEvent("SPELLCAST_FAILED")
	this:RegisterEvent("SPELLCAST_FAILED_QUIET")
	-- for target casting
	this:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")	
	--this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
	this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- misc
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	this:RegisterEvent("BAG_UPDATE")
	this:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	-- for ignite
    this:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
    this:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
end

function one_OnEvent()
	if event == "PLAYER_LOGIN" then
		one_InitVariables()
	end
	
	-- for combat
	if evnet == "PLAYER_REGEN_ENABLED" then		
		one_Combat = 1
	elseif evnet == "PLAYER_REGEN_DISABLED" then
		one_Combat = nil 	
	-- for group opdates
	elseif event == "GROUP_ROSTER_UPDATE" or event == "RAID_ROSTER_	UPDATE" or event == "PARTY_CONVERTED_TO_RAID" then
		one_OnGroupUpdate()
	-- spell casting/channeling
	elseif event == "SPELLCAST_START" then
		one_Casting = 1
		one_m("startcast")
		one_RegisterButtons()
		damn = one_GetActionButtonTooltip(13)
		one_m(damn)
		did = one_Button["Corruption.1"] 
		one_m(did)
	elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_INTERRUPTED" then	
		one_Casting = nil
		one_m("stopcast")
	elseif event == "SPELLCAST_CHANNEL_START" then
		one_m("start")
		one_Channeling = 1
	elseif event == "SPELLCAST_CHANNEL_STOP" then
		one_m("stop")
		one_Channeling = nil
	elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		one_HitInfo = arg1	 
	end		
	
	-- misc	
	if event == "BAG_UPDATE" then
		one_OnBagUpdate()
	elseif event == "ACTIONBAR_SLOT_CHANGED" then		
		one_OnActionbarOpdate()
	end	
	
	-- for ignite 
	if one_Class == "Mage" then
		if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
			one_igniteInfo = arg1
			one_m(one_igniteInfo)
			GMage.ignite()
		elseif event == "CHAT_MSG_SPELL_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE" then	
			one_igniteInfo = arg1
			one_m(one_igniteInfo)
			GMage.ignite()
		elseif event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" then
			one_igniteInfo = arg1
			one_m(one_igniteInfo)
			GMage.ignite()
		elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
			one_m(arg1)
		end
	end
end

function one_InitVariables()
	
	BINDING_HEADER_ONEBOXING_HEADER = "oneMultiboxing"
	BINDING_NAME_ONE_DPS = "DPS rotation"
	
	one_Class = UnitClass("player")
	
	one_Casting = nil
	one_Channeling = nil
	one_Combat = nil
	one_HitInfo = nil

	if one_Class == "Warlock" then
		GLock.InitVariables()
	elseif one_Class == "Mage" then
		GMage.InitVariables()
	end	
end

function one_OnActionbarOpdate()
	if one_Class == "Warlock" then
		GLock.OnActionbarOpdate()
	elseif one_Class == "Mage" then
		GMage.OnActionbarOpdate()
	end	
end

function one_OnGroupUpdate()
	if one_Combat then return end
	if one_Class == "Warlock" then
		GLock.OnGroupUpdate()
	elseif one_Class == "Mage" then
		GMage.OnGroupUpdate()
	end	
end

function one_OnBagUpdate()
	if one_Class == "Warlock" then
		GLock.OnBagUpdate()
	elseif one_Class == "Mage" then
		GMage.OnBagUpdate()
	end	
end