-- This file contains all barebones-registered events and has already set up the passed-in parameters for you to use.
-- You should comment or remove the stuff you don't need!

-- Handle stuff when a player disconnects
function barebones:OnDisconnect(keys)
	DebugPrint("[BAREBONES] A Player has disconnected ".. tostring(keys.userid))
	--PrintTable(keys)

	local name = keys.name
	local networkID = keys.networkid
	local reason = keys.reason
	local userID = keys.userid
	local playerID = keys.PlayerID

	Timers:CreateTimer(20, function()
		barebones:SetTeamCounts()
	end)
end

-- The overall game state has changed
function barebones:OnGameRulesStateChange(keys)
	--PrintTable(keys)

	local new_state = GameRules:State_Get()

	if new_state == DOTA_GAMERULES_STATE_INIT then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_INIT")

	elseif new_state == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD")

	elseif new_state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP")
		GameRules:SetCustomGameSetupAutoLaunchDelay(CUSTOM_GAME_SETUP_TIME)

	elseif new_state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_HERO_SELECTION")
		self:PostLoadPrecache()
		self:OnAllPlayersLoaded()

	elseif new_state == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_STRATEGY_TIME")

	elseif new_state == DOTA_GAMERULES_STATE_TEAM_SHOWCASE then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_TEAM_SHOWCASE")

	elseif new_state == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD")

	elseif new_state == DOTA_GAMERULES_STATE_PRE_GAME then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_PRE_GAME")
		GameRules:GetGameModeEntity():SetCustomDireScore(0) -- Thanks for Diretide

	elseif new_state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_GAME_IN_PROGRESS")
		self:OnGameInProgress()

	elseif new_state == DOTA_GAMERULES_STATE_POST_GAME then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_POST_GAME")

	elseif new_state == DOTA_GAMERULES_STATE_DISCONNECT then
		DebugPrint("[BAREBONES] Game State changed to: DOTA_GAMERULES_STATE_DISCONNECT")

	end
end

-- An NPC has spawned somewhere in game. This includes heroes
function barebones:OnNPCSpawned(keys)
	--DebugPrint("[BAREBONES] A unit Spawned")
	--PrintTable(keys)

	local npc = EntIndexToHScript(keys.entindex)
	local unit = EntIndexToHScript(keys.entindex)
	local unit_owner = npc:GetOwner()

	-- Put things here that will happen for every unit or hero when they spawn

	--  or string.find(unit:GetUnitName(), "_neutral_") 
	if unit:GetClassname() == "npc_dota_creep_lane" or unit:GetClassname() == "npc_dota_creep_siege" then
		
		-- if string.find(unit:GetUnitName(), "upgraded") then 
		-- 	multiplier	= creep_scaling_ability:GetSpecialValueFor("super_mult")
		
		
		local game_time	= math.floor(GameRules:GetDOTATime(false, false) / 60)
		-- local game_time = 10
		local additional_damage = barebones:Get_POG_CREEP_DAMAGE_SCALING(unit:GetTeamNumber()) * game_time
		local additional_health = barebones:Get_POG_CREEP_HEALTH_SCALING(unit:GetTeamNumber()) * game_time
		-- DebugPrint("Gametime: "..game_time)
		-- DebugPrint("Spawning creeps with additional damage: "..additional_damage)
		-- DebugPrint("Spawning creeps with additional health: "..additional_health)
		-- if string.find(unit:GetUnitName(), "upgraded_mega") then
		-- 	multiplier	= barebones
		-- end
		-- DebugPrint("Multiplier: "..multiplier)
		
		unit:SetBaseDamageMin(unit:GetBaseDamageMin() + additional_damage)
		unit:SetBaseDamageMax(unit:GetBaseDamageMax() + additional_damage)
		-- unit:SetBaseAttackTime(unit:GetBaseAttackTime() - creep_scaling_ability:GetSpecialValueFor("melee_aspd") * game_time * multiplier)
		-- unit:SetBaseMoveSpeed(unit:GetBaseMoveSpeed() + creep_scaling_ability:GetSpecialValueFor("melee_ms") * game_time * multiplier) -- Works but doesn't show on client side (wtf...)
		unit:SetMaxHealth(unit:GetMaxHealth() + additional_health)
		unit:SetBaseMaxHealth(unit:GetBaseMaxHealth() + additional_health)
		unit:SetHealth(unit:GetMaxHealth() + additional_health)
		-- unit:SetBaseHealthRegen(unit:GetBaseHealthRegen()) -- Works
	end

	-- OnHeroInGame
	if npc:IsRealHero() and npc.bFirstSpawned == nil then
		npc.bFirstSpawned = true
		self:OnHeroInGame(npc)
	end
end

--[[
  Hero spawned for the first time. It can happen if the player's hero is replaced with a new hero for any reason.
  This can be used for initializing heroes, such as adding levels, changing the starting gold, removing/adding abilities, adding physics, etc.
  This happens to bot and custom created heroes as well.
  The hero parameter is the hero entity that just spawned.

]]
function barebones:OnHeroInGame(hero)
	-- Innate abilities like Earth Spirit Stone Remnant (abilities that a hero needs to have auto-leveled up at the start of the game)
	-- Add all custom innate abilities here
	local innate_abilities = {
		"innate_ability1",
		"innate_ability2"
	}

	-- Cycle through any innate abilities found, then set their level to 1
	for i = 1, #innate_abilities do
		local current_ability = hero:FindAbilityByName(innate_abilities[i])
		if current_ability then
			current_ability:SetLevel(1)
		end
	end

	Timers:CreateTimer(0.5, function()
		local playerID = hero:GetPlayerID()	-- never nil (-1 by default), needs delay 1 or more frames

		if PlayerResource:IsFakeClient(playerID) then
			-- This is happening only for bots
			DebugPrint("[BAREBONES] Bot hero "..hero:GetUnitName().." (re)spawned in the game.")
			-- Set starting gold for bots
			hero:SetGold(NORMAL_START_GOLD, false)
			-- for debugging
			barebones:SetTeamCounts()
		else
			DebugPrint("[BAREBONES] OnHeroInGame running for a non-bot player!")
			if not PlayerResource.PlayerData[playerID] then
				PlayerResource.PlayerData[playerID] = {}
				DebugPrint("[BAREBONES] PlayerResource's PlayerData for playerID "..playerID.." was not properly initialized.")
			end
			if hero:IsClone() then
				DebugPrint("[BAREBONES] Spawned hero is a Meepo clone")
				return
			end
			if hero:IsTempestDouble() then
				DebugPrint("[BAREBONES] Spawned hero is a Tempest Double")
				return
			end
			if hero:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") then
				DebugPrint("[BAREBONES] Spawned hero is a Monkey King clone")
				return
			end
			-- Set some hero stuff on first spawn or on every spawn (custom or not)
			if PlayerResource.PlayerData[playerID].already_set_hero == true then
				-- This is happening only when players create new heroes or replace them
			else
				-- This is happening for players when their primary hero spawns for the first time
				DebugPrint("[BAREBONES] Hero "..hero:GetUnitName().." spawned in the game for the first time for the player with ID "..playerID)

				-- Make heroes briefly visible on spawn (to prevent bad fog of war interactions)
				hero:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, 0.5)
				hero:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, 0.5)

				-- Set the starting gold for the player's hero
				-- Use 'PlayerResource:ModifyGold(playerID, NORMAL_START_GOLD-600, false, 0)' if GameRules:SetStartingGold breaks again
				-- If the NORMAL_START_GOLD is less then 600, disable Strategy Time and use 'hero:SetGold(NORMAL_START_GOLD, false)' instead
				-- Why? Because OnHeroInGame is triggering during PreGame (after Strategy Time) and players can buy items during Strategy Time (starting gold will remain default 600)

				-- Create an item and add it to the player, effectively ensuring they start with the item
				if ADD_ITEM_TO_HERO_ON_SPAWN then
					local item = CreateItem("item_example_item", hero, hero)
					hero:AddItem(item)
				end

				-- Make sure that stuff above will not happen again for the player if some other hero spawns
				-- for him for the first time during the game
				PlayerResource.PlayerData[playerID].already_set_hero = true
				DebugPrint("[BAREBONES] Hero "..hero:GetUnitName().." set for the player with ID "..playerID)
			end
		end
	end)
end

-- An item was picked up off the ground
function barebones:OnItemPickedUp(keys)
	DebugPrint("[BAREBONES] OnItemPickedUp")
	--PrintTable(keys)

	-- Find who picked up the item
	local unit_entity
	if keys.UnitEntitIndex then -- keys.UnitEntitIndex may be always nil
		unit_entity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unit_entity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local item_entity = EntIndexToHScript(keys.ItemEntityIndex)
	local playerID = keys.PlayerID
	local item_name = keys.itemname
end

-- A player has reconnected to the game. This function can be used to repaint Player-based particles or change state as necessary
function barebones:OnPlayerReconnect(keys)
	DebugPrint("[BAREBONES] A Player has reconnected.")
	--PrintTable(keys)

	local new_state = GameRules:State_Get()
	if new_state > DOTA_GAMERULES_STATE_HERO_SELECTION then
		local playerID = keys.PlayerID or keys.player_id

		if PlayerResource:HasSelectedHero(playerID) or PlayerResource:HasRandomed(playerID) then
			-- This playerID already had a hero before disconnect
		else
			-- PlayerResource:IsConnected(index) is custom-made; can be found in 'player_resource.lua' library
			if PlayerResource:IsConnected(playerID) and (not PlayerResource:IsBroadcaster(playerID)) then
				PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()
				PlayerResource:SetHasRandomed(playerID)
				PlayerResource:SetCanRepick(playerID, false)
				DebugPrint("[BAREBONES] Randomed a hero for a player number "..playerID.." that reconnected.")
			end
		end
	end
end

-- An ability was used by a player; Doesn't trigger on disconnected players.
function barebones:OnAbilityUsed(keys)
	--PrintTable(keys)

	local playerID = keys.PlayerID
	local ability_name = keys.abilityname

	-- If you need to adjust abilities on their cast, use Order Filter or modifier events, not this
end

-- A player leveled up an ability; Note: IT DOESN'T TRIGGER WHEN YOU USE SetLevel() ON THE ABILITY!
function barebones:OnPlayerLearnedAbility(keys)
	DebugPrint("[BAREBONES] OnPlayerLearnedAbility")
	--PrintTable(keys)

	local player
	if keys.player then
		player = EntIndexToHScript(keys.player)
	end

	local ability_name = keys.abilityname

	local playerID
	if player then
		playerID = player:GetPlayerID()
	else
		playerID = keys.PlayerID
	end

	-- PlayerResource:GetBarebonesAssignedHero(index) is custom-made; can be found in 'player_resource.lua' library
	-- This could return a wrong hero if you change your hero often during gameplay
	local hero = PlayerResource:GetBarebonesAssignedHero(playerID)
end

-- A player leveled up
function barebones:OnPlayerLevelUp(keys)
	DebugPrint("[BAREBONES] OnPlayerLevelUp")
	--PrintTable(keys)

	local level = keys.level
	local playerID = keys.player_id or keys.PlayerID -- Valve keeps changing this :)

	local hero
	if keys.hero_entindex then
		hero = EntIndexToHScript(keys.hero_entindex)
	else
		hero = PlayerResource:GetBarebonesAssignedHero(playerID)
	end

	if hero then
		-- Update hero gold bounty when a hero gains a level
		if USE_CUSTOM_HERO_GOLD_BOUNTY then
			local hero_level = hero:GetLevel() or level
			local hero_streak = hero:GetStreak()

			local gold_bounty
			if hero_streak > 2 then
				gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL + (hero_streak-2)*HERO_KILL_GOLD_PER_STREAK
			else
				gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL
			end

			hero:SetMinimumGoldBounty(gold_bounty)
			hero:SetMaximumGoldBounty(gold_bounty)
		end

		-- Example how to add an extra skill point when a hero levels up
		--[[
		local levels_without_ability_point = {17, 19, 21, 22, 23, 24}	-- on this levels you should get a skill point (edit this if needed)
		for i = 1, #levels_without_ability_point do
			if level == levels_without_ability_point[i] then
				local unspent_ability_points = hero:GetAbilityPoints()
				hero:SetAbilityPoints(unspent_ability_points + 1)
			end
		end
		]]

		-- If you want to remove skill points when a hero levels up then uncomment the following line:
		-- hero:SetAbilityPoints(0)
	end
end

-- A player last hit a creep, a tower, or a hero
function barebones:OnLastHit(keys)
	DebugPrint("[BAREBONES] OnLastHit")
	--PrintTable(keys)

	local IsFirstBlood = keys.FirstBlood == 1
	local IsHeroKill = keys.HeroKill == 1
	local IsTowerKill = keys.TowerKill == 1

	-- Player ID that got a last hit
	local playerID = keys.PlayerID

	-- Killed unit (creep, hero, tower etc.)
	local killed_entity = EntIndexToHScript(keys.EntKilled)

	DebugPrint("killed_entity type: "..killed_entity:GetName())
	if killed_entity:GetName() == "npc_dota_creep_neutral" then
		local extra_experience = barebones:Get_POG_NEUTRAL_EXPERIENCE(playerID)
		PlayerResource:GetSelectedHeroEntity(playerID):AddExperience(extra_experience, DOTA_ModifyXP_Unspecified, false, true)
		-- DebugPrint("Added "..extra_experience.." from neutral kill.")
	end
end

-- A tree was cut down by tango, quelling blade, etc
function barebones:OnTreeCut(keys)
	DebugPrint("[BAREBONES] OnTreeCut")
	--PrintTable(keys)

	-- Tree coordinates on the map
	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function barebones:OnRuneActivated(keys)
	DebugPrint("[BAREBONES] OnRuneActivated")
	--PrintTable(keys)

  local playerID = keys.PlayerID
  local rune = keys.rune

  -- For Bounty Runes use BountyRuneFilter
  -- For modifying which runes spawn use RuneSpawnFilter (if it works)
  -- This event can be used for adding more effects to existing runes.
end

-- A player picked or randomed a hero, it actually happens on spawn (this is sometimes happening before OnHeroInGame).
function barebones:OnPlayerPickHero(keys)
	DebugPrint("[BAREBONES] OnPlayerPickHero")
	--PrintTable(keys)

	local hero_name = keys.hero
	local hero_entity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)

	local to_remove = -1
	for index, id in pairs(POG_HERO_POOL) do
		if id == keys.heroindex then
			to_remove = index
			break
		end
	end
	if to_remove ~= -1 then
		POG_HERO_POOL[to_remove] = nil
	end

	Timers:CreateTimer(0.5, function()
		local playerID = hero_entity:GetPlayerID() -- or player:GetPlayerID() if player is not disconnected
		if PlayerResource:IsFakeClient(playerID) then
			-- This is happening only for bots when they spawn for the first time or if they use custom hero-create spells (Custom Illusion spells)
		else
			if not PlayerResource.PlayerData[playerID] then
				PlayerResource.PlayerData[playerID] = {}
				DebugPrint("[BAREBONES] PlayerResource's PlayerData for playerID "..playerID.." was not properly initialized.")
			end
			if PlayerResource.PlayerData[playerID].already_assigned_hero == true then
				-- This is happening only when players create new heroes or replacing heroes
				DebugPrint("[BAREBONES] Player with playerID "..playerID.." got a new hero "..hero_entity:GetUnitName())
			else
				PlayerResource:AssignHero(playerID, hero_entity)
				PlayerResource.PlayerData[playerID].already_assigned_hero = true
			end
		end
	end)
end

-- An entity died (an entity killed an entity)
function barebones:OnEntityKilled(keys)
    DebugPrint("[BAREBONES] An entity was killed.")
    --PrintTable(keys)

    -- Indexes:
    local killed_entity_index = keys.entindex_killed
    local attacker_entity_index = keys.entindex_attacker
    local inflictor_index = keys.entindex_inflictor -- it can be nil if not killed by an item/ability

    -- Find the entity that was killed
    local killed_unit
    if killed_entity_index then
      killed_unit = EntIndexToHScript(killed_entity_index)
    end

    -- Find the entity (killer) that killed the entity mentioned above
    local killer_unit
    if attacker_entity_index then
      killer_unit = EntIndexToHScript(attacker_entity_index)
    end

    if killed_unit == nil or killer_unit == nil then
      -- Don't continue if killer or killed entity doesn't exist
      return
    end

	-- Find the ability/item used to kill, or nil if not killed by an item/ability
    local killing_ability
    if inflictor_index then
      killing_ability = EntIndexToHScript(inflictor_index)
    end
	

    -- For Meepo clones, find the original
    if killed_unit:IsClone() then
      if killed_unit:GetCloneSource() then
        killed_unit = killed_unit:GetCloneSource()
      end
    end

	-- Pog gameplay mechanics
	local killer_owner = killer_unit:GetOwnerEntity()
	local killer_teamID = killer_unit:GetTeam()
	local killed_owner = killed_unit:GetOwnerEntity()
	local killed_teamID = killed_unit:GetTeam()
	DebugPrint("killed unit name: "..killed_unit:GetUnitName())
	DebugPrint("killed unit class: "..killed_unit:GetName())
	DebugPrint("Killed team"..killed_teamID.." | "..killer_teamID.." killer team")

	-- share gold
	if killing_ability == nil or (killing_ability ~= nil and killing_ability:GetAbilityName() ~= "item_hand_of_midas") then
		DebugPrint("Will share gold")
		for id = 0, POG_MAX_PLAYER_COUNT do
			if barebones:OnTeam(id, killer_teamID) then
				local shareAmount = 0
				if barebones:shouldShareGold(killer_owner, id) then
					shareAmount = math.floor(barebones:Get_POG_BOUNTY(killed_unit:GetGoldBounty(), killed_unit) * SHARED_GOLD_PERCENTAGE)
					DebugPrint("Granting "..shareAmount.." as shared last hit gold to "..id)
				elseif barebones:shouldShareMissedGold(killer_unit, id) then
					shareAmount =  math.floor(barebones:Get_POG_BOUNTY(killed_unit:GetGoldBounty(), killed_unit) * SHARED_MISSED_GOLD_PERCENTAGE)
					DebugPrint("Granting "..shareAmount.." as shared missed gold to "..id)
				end
				PlayerResource:ModifyGold(id, shareAmount, false, DOTA_ModifyGold_SharedGold)
			end
		end
	end
	-- do pog rune
	barebones:PogRuneOnUnitKilled(killer_unit, killed_unit)

	-- END POG MECHANICS

	-- Killed Unit is a hero (not an illusion) and he is not reincarnating
	if killed_unit:IsRealHero() and not killed_unit:IsTempestDouble() and not killed_unit:IsReincarnating() then
		-- Hero gold bounty update for the killer
		if USE_CUSTOM_HERO_GOLD_BOUNTY then
			if killer_unit:IsRealHero() then
				-- Get his killing streak
				local hero_streak = killer_unit:GetStreak()
				-- Get his level
				local hero_level = killer_unit:GetLevel()
				-- Adjust Gold bounty
				local gold_bounty
				if hero_streak > 2 then
					gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL + (hero_streak-2)*HERO_KILL_GOLD_PER_STREAK
				else
					gold_bounty = HERO_KILL_GOLD_BASE + hero_level*HERO_KILL_GOLD_PER_LEVEL
				end

				killer_unit:SetMinimumGoldBounty(gold_bounty)
				killer_unit:SetMaximumGoldBounty(gold_bounty)
			end
		end

		-- Hero Respawn time configuration
		if ENABLE_HERO_RESPAWN then
			local killed_unit_level = killed_unit:GetLevel()

			-- Calculating respawn time without buyback penalty
			local respawn_time = 1
			if USE_CUSTOM_RESPAWN_TIMES then
				-- Get respawn time from the table that we defined
				respawn_time = CUSTOM_RESPAWN_TIME[killed_unit_level]
			else
				-- Get dota default respawn time
				respawn_time = math.min(math.floor(killed_unit:GetRespawnTime() * POG_RESPAWN_REDUCTION_PERCENT), POG_MAX_RESPAWN_TIME)
				if barebones:PlayerOnDeficitTeam(killed_unit:GetPlayerID()) then
					respawn_time = math.floor(killed_unit:GetRespawnTime() * POG_DEFICIT_RESPAWN_REDUCTION_PERCENT)
				end
			end

			-- Fixing respawn time after level 30, this is usually bugged in custom games if default respawn times are used -> respawn time are either too long or too short. We fix that.
			local respawn_time_after_30 = 100 + (killed_unit_level-30)*5
			if killed_unit_level > 30 and respawn_time ~= respawn_time_after_30 and not USE_CUSTOM_RESPAWN_TIMES then
				respawn_time = POG_MAX_RESPAWN_TIME
			end

			-- Old Bloodstone respawn reduction (this example doesn't check items in backpack because bloodstone cannot go in backpack)
			-- for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
				-- local item = killed_unit:GetItemInSlot(i)
				-- if item then
					-- if item:GetName() == "item_bloodstone" then
						-- local current_charges = item:GetCurrentCharges()
						-- local charges_before_death = math.ceil(current_charges*1.5)
						-- local reduction_per_charge = item:GetLevelSpecialValueFor("respawn_time_reduction", item:GetLevel() - 1)
						-- local respawn_reduction = charges_before_death*reduction_per_charge
						-- respawn_time = math.max(1, respawn_time-respawn_reduction)
						-- break -- break for loop, to prevent multiple bloodstones granting respawn reduction
					-- end
				-- end
			-- end

			-- Reaper's Scythe respawn time increase
			if killing_ability then
				if killing_ability:GetAbilityName() == "necrolyte_reapers_scythe" then
					DebugPrint("[BAREBONES] A hero was killed by a Necro Reaper's Scythe. Increasing respawn time!")
					local respawn_extra_time = killing_ability:GetLevelSpecialValueFor("respawn_constant", killing_ability:GetLevel() - 1)
					respawn_time = respawn_time + respawn_extra_time
				end
			end

			-- Killer is a neutral creep
			if killer_unit:IsNeutralUnitType() then
				-- If a hero is killed by a neutral creep, respawn time can be modified here
			end

			-- Capping Respawn Time (MAX respawn time)
			if respawn_time > MAX_RESPAWN_TIME then
				DebugPrint("[BAREBONES] Reducing respawn time of "..killed_unit:GetUnitName().." because it was too long.")
				respawn_time = MAX_RESPAWN_TIME
			end

			-- If hero is actually reincarnating don't change his respawn time:
			if not killed_unit:IsReincarnating() then
				killed_unit:SetTimeUntilRespawn(respawn_time)
			end
		end

		-- Hero Buyback Cooldown
		if CUSTOM_BUYBACK_COOLDOWN_ENABLED then
			if barebones:PlayerOnDeficitTeam(killed_unit:GetPlayerID()) then
				PlayerResource:SetCustomBuybackCooldown(killed_unit:GetPlayerID(), POG_DEFICIT_BUYBACK_COOLDOWN)
			else
				PlayerResource:SetCustomBuybackCooldown(killed_unit:GetPlayerID(), CUSTOM_BUYBACK_COOLDOWN_TIME)
			end
		end

		-- Hero Buyback Gold Cost, you can replace BUYBACK_FIXED_GOLD_COST with your formula
		if CUSTOM_BUYBACK_COST_ENABLED then
			PlayerResource:SetCustomBuybackCost(killed_unit:GetPlayerID(), BUYBACK_FIXED_GOLD_COST)
		end

		-- Killer is not a real hero but it killed a hero; IsFountain() is custom-made, can be found in 'util.lua'
		if killer_unit:IsTower() or killer_unit:IsCreep() or killer_unit:IsFountain() then
			-- Put stuff here that you want to happen if a hero is killed by a creep, tower or fountain.
		end

		-- When team hero kill limit is reached declare the winner
		if END_GAME_ON_KILLS and GetTeamHeroKills(killer_unit:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
			GameRules:SetGameWinner(killer_unit:GetTeam())
		end

		-- Setting top bar values
		if SHOW_KILLS_ON_TOPBAR then
			--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS))   -- Doesn't work since Diretide 2020
			--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS)) -- Doesn't work since Diretide 2020
			GameRules:GetGameModeEntity():SetCustomRadiantScore(GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
			GameRules:GetGameModeEntity():SetCustomDireScore(GetTeamHeroKills(DOTA_TEAM_BADGUYS))
		end
	end

	-- Ancient destruction detection (if the map doesn't have ancients with these names, this will never happen)
	if killed_unit:GetUnitName() == "npc_dota_badguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		GameRules:SetCustomVictoryMessage("#dota_post_game_radiant_victory")
		GameRules:SetCustomVictoryMessageDuration(POST_GAME_TIME)
	elseif killed_unit:GetUnitName() == "npc_dota_goodguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		GameRules:SetCustomVictoryMessage("#dota_post_game_dire_victory")
		GameRules:SetCustomVictoryMessageDuration(POST_GAME_TIME)
	end

	-- Remove dead non-hero units from selection -> fixing bugged ability/cast bar
	if killed_unit:IsIllusion() or (killed_unit:IsControllableByAnyPlayer() and not killed_unit:IsRealHero() and not killed_unit:IsCourier() and not killed_unit:IsClone() and not killed_unit:IsTempestDouble()) then
		local player = killed_unit:GetPlayerOwner()
		local playerID
		if player == nil then
			playerID = killed_unit:GetPlayerOwnerID()
		else
			playerID = player:GetPlayerID()
		end

		if Selection then
			-- Without Selection library this will return an error
			PlayerResource:RemoveFromSelection(playerID, killed_unit)
		end
	end

	-- pog roshan
	if killed_unit:GetUnitName() == "npc_dota_roshan" then
		barebones:onRoshanDeath(killed_unit:GetAbsOrigin())
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function barebones:OnConnectFull(keys)
	DebugPrint("[BAREBONES] A Player fully connected.")
	--PrintTable(keys)

	self:CaptureGameMode()

	local index = keys.index           -- player slot
	local playerID = keys.PlayerID
	local userID = keys.userid         -- user ID on server

	-- PlayerResource:OnPlayerConnect(event) is custom-made; can be found in 'player_resource.lua' library
	PlayerResource:OnPlayerConnect(keys)
end

-- This function is called whenever a tower is destroyed
function barebones:OnTowerKill(keys)
	DebugPrint("[BAREBONES] OnTowerKill")
	--PrintTable(keys)

	local gold = keys.gold
	local killer_userID = keys.killer_userid
	local team = keys.teamnumber
end

-- This function is called whenever a player changes their custom team selection during Custom Game Setup
function barebones:OnPlayerSelectedCustomTeam(keys)
	DebugPrint("[BAREBONES] OnPlayerSelectedCustomTeam")
	--PrintTable(keys)

	local playerID = keys.player_id
	local success = (keys.success == 1)
	local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target (npc can be a lane creep, goal entity can be a path corner)
function barebones:OnNPCGoalReached(keys)
	--DebugPrint("[BAREBONES] OnNPCGoalReached")
	--PrintTable(keys)

	local goal_entity_index = keys.goal_entindex             -- Entity index of the next goal entity on the path (if any) which the npc will now be pathing towards
	local next_goal_entity_index = keys.next_goal_entindex   -- Entity index of the path goal entity which has been reached
	local npc_index = keys.npc_entindex                      -- Entity index of the npc which was following a path and has reached a goal entity

	local npc
	local goal_entity

	if npc_index and goal_entity_index then
		npc = EntIndexToHScript(npc_index)
		goal_entity = EntIndexToHScript(goal_entity_index)
	end

	local next_goal_entity
	if next_goal_entity_index then
		next_goal_entity = EntIndexToHScript(next_goal_entity_index)
	end

	if npc and goal_entity then
		-- Your code here
	end
end

-- This function is called whenever any player sends a chat message to team or to All
function barebones:OnPlayerChat(keys)
	DebugPrint("[BAREBONES] Player used the chat")
	--PrintTable(keys)

	local team_only = keys.teamonly -- true if team only chat
	local userID = keys.userid
	local playerID = keys.playerid
	local text = keys.text
end

function barebones:dropRune(location, type)
	CreateRune(location, type)
end

function barebones:shouldShareGold(killer_owner, playerID)
	-- DebugPrint("killer_unit "..killer_owner:GetName()..", id: "..killer_owner:GetPlayerID()..", team: "..killer_owner:GetTeamNumber())
	-- DebugPrint("player "..PlayerResource:GetPlayer(playerID):GetName()..", id: "..playerID..", team: "..PlayerResource:GetPlayer(playerID):GetTeamNumber())
	return killer_owner ~= nil and PlayerResource:IsValidPlayerID(playerID) and playerID ~= killer_owner:GetPlayerID() and PlayerResource:GetPlayer(playerID):GetTeamNumber() == killer_owner:GetTeamNumber()
end

function barebones:shouldShareMissedGold (killer_unit, playerID)
	-- DebugPrint("killer_unit "..killer_unit:GetName()..", id: "..killer_unit:GetPlayerID()..", team: "..killer_unit:GetTeamNumber())
	-- DebugPrint("player "..PlayerResource:GetPlayer(playerID):GetName()..", id: "..playerID..", team: "..PlayerResource:GetPlayer(playerID):GetTeamNumber())
	return killer_unit ~= nil and killer_unit:GetOwnerEntity() == nil and PlayerResource:IsValidPlayerID(playerID) and PlayerResource:GetPlayer(playerID):GetTeamNumber() == killer_unit:GetTeamNumber()
end