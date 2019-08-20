
AddCSLuaFile( "default_player.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cvars.lua" )
AddCSLuaFile( "tables.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_postprocess.lua" )
AddCSLuaFile( "vgui_selectionbutton.lua" )
AddCSLuaFile( "vgui_helpmenu.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )

include( "tables.lua" )
include( "default_player.lua" )
include( "shared.lua" )
include( "ply_extension.lua" )
include( "resource.lua" )

util.AddNetworkString( "SynchInt" )
util.AddNetworkString( "RoundEnd" )
util.AddNetworkString( "Scanner" )
util.AddNetworkString( "Stim" )
util.AddNetworkString( "Flay" )
util.AddNetworkString( "ToggleMenu" )
util.AddNetworkString( "ShowHelp" )

GM.NextRoundThink = 0
GM.RoundsPlayed = 0

function GM:InRound()

	return GetGlobalBool( "InRound", false )

end

function GM:SetInRound( b )

	SetGlobalBool( "InRound", b )

end

function GM:AlivePlayers( t )

	local num = 0

	for k,v in pairs( team.GetPlayers( t ) ) do
	
		if v:Alive() then
		
			num = num + 1
			
		end
		
	end
	
	return num

end

function GM:GetNextStalker()

	local frags = 9000
	local ply

	for k,v in pairs( player.GetAll() ) do
	
		if v == GAMEMODE.Winner then
		
			GAMEMODE.Winner = nil
			
			return v
			
		elseif v:Frags() < frags then
		
			frags = v:Frags()
			ply = v
			
		end
		
	end
	
	return ply

end

function GM:SetCommander()

	local score = 9999
	local ply

	for k,v in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
	
		v:SetCommander( false )
	
		if v:Frags() < score then
		
			score = v:Frags()
			ply = v
		
		elseif v:Frags() == score and ( math.random(1,3) == 1 or not ply ) then
		
			ply = v
		
		end
	
	end
	
	if ply then
	
		ply:SetCommander( true )
	
	end

end

function GM:RoundStart()

	GAMEMODE.NextRoundThink = CurTime() + 1
	
	game.CleanUpMap()
	
	BroadcastLua( "game.CleanUpMap()" )
	
	timer.Simple( 3, function() GAMEMODE:RemoveBadShit() end )
	
	for k,v in pairs( player.GetAll() ) do
	
		v:SetTeam( TEAM_HUMAN )
		
	end
	
	if team.NumPlayers( TEAM_HUMAN ) > 0 then
	
		local ply = GAMEMODE:GetNextStalker()
		
		ply:SetTeam( TEAM_STALKER )
		
	end
	
	GAMEMODE:SetCommander()
	
	for k,v in pairs( player.GetAll() ) do
	
		if v:Team() != TEAM_HUMAN and v:Team() != TEAM_STALKER then
		
			v:SetTeam( TEAM_HUMAN )
		
		end
	
		v:StripWeapons()
		v:Spawn()
		v:Freeze( true )
		v:SetNextVoice( VO_IDLE, math.random( 30, 120 ) )
		
		timer.Simple( 3, function() if IsValid( v ) then v:Freeze( false ) end end )
	
	end
	
	timer.Simple( 5, function() GAMEMODE:SetInRound( true ) end )
	
	if team.NumPlayers( TEAM_HUMAN ) < 1 then return end
	
	local pl = table.Random( team.GetPlayers( TEAM_HUMAN ) )
	
	if IsValid( pl ) then
	
		pl:VoiceSound( VO_SPAWN, true )
		
	end

end

function GM:RoundEnd( t, ply )

	local name = "N/A"
	
	if IsValid( ply ) then
	
		name = ply:Name()
	
	end
	
	if team.NumPlayers( TEAM_HUMAN ) + team.NumPlayers( TEAM_SPECTATOR ) > 0 then
	
		net.Start( "RoundEnd" )
		net.WriteInt( t, 8 )
		net.WriteString( name )	
		net.Broadcast()
		
		GAMEMODE.RoundsPlayed = GAMEMODE.RoundsPlayed + 1
		
		SetGlobalInt( "RoundNum", GAMEMODE.RoundsPlayed )
		
	end
	
	GAMEMODE:SetInRound( false )
	
	if GAMEMODE.RoundsPlayed == sv_ts_num_rounds:GetInt() then
	
		//GAMEMODE:LoadNextMap()
		hook.Call( "LoadNextMap", GAMEMODE )
		
		return
	
	end
	
	timer.Simple( 8, function() GAMEMODE:RoundStart() end )
	
end

function GM:LoadNextMap()

	timer.Simple( 8, function() for k,v in pairs( player.GetAll() ) do v:ChatPrint( "Next map: " .. game.GetMapNext() ) end end )
	timer.Simple( 15, function() game.LoadNextMap() end ) 

end

function GM:ShowTeam( ply )

	if ply:Team() == TEAM_STALKER then return end

	net.Start( "ToggleMenu" )
	net.Send( ply )
	
end

function GM:ShowHelp( ply )

	net.Start( "ShowHelp" )
	net.Send( ply )

end

function GM:IsRemovableProp( ent, phys )

	if string.find( ent:GetModel(), "explosive" ) or string.find( ent:GetModel(), "propane" ) or string.find( ent:GetModel(), "gascan" ) then return true end
	
	if ( IsValid( phys ) and phys:GetMass() <= 5 and phys:IsMotionEnabled() and phys:IsMoveable() ) then return true end

end

function GM:RemoveBadShit()	

	local heavy = {}

	local badshit = ents.FindByClass( "npc_*" )
	badshit = table.Add( badshit, ents.FindByClass( "prop_ragdoll" ) )
	badshit = table.Add( badshit, ents.FindByClass( "item_*" ) )
	badshit = table.Add( badshit, ents.FindByClass( "point_servercommand" ) )
	badshit = table.Add( badshit, ents.FindByClass( "game_text" ) )
	
	for k,v in pairs( ents.FindByClass( "prop_phys*" ) ) do
	
		local phys = v:GetPhysicsObject()
	
		if GAMEMODE:IsRemovableProp( v, phys ) then
		
			table.insert( badshit, v )
		
		elseif phys:GetMass() >= 300 then
		
			table.insert( heavy, v )
		
		end
	
	end
	
	for k,v in pairs( badshit ) do
	
		v:Remove()
	
	end
	
	local chosen = table.Random( heavy )
	
	if table.Count( heavy ) > 1 then
	
		for k,v in pairs( heavy ) do
		
			if v != chosen then
		
				v:Remove()
				
			end
		
		end
	
	end
	
end

function GM:Think()

	if GAMEMODE.NextRoundThink < CurTime() and GAMEMODE:InRound() then
	
		GAMEMODE.NextRoundThink = CurTime() + 1
	
		if GAMEMODE:AlivePlayers( TEAM_HUMAN ) < 1 and table.Count( player.GetAll() ) > 1 then
		
			GAMEMODE:RoundEnd( TEAM_STALKER )
		
		elseif GAMEMODE:AlivePlayers( TEAM_STALKER ) < 1 then
		
			local winner = GAMEMODE:GetWinner()//table.Random( team.GetPlayers( TEAM_HUMAN ) )
		
			GAMEMODE:RoundEnd( TEAM_HUMAN, winner )
		
		end
	
	end
	
	for k,v in pairs( player.GetAll() ) do
	
		v:Think()
	
	end

end

function GM:GetWinner()
	
	local mode = math.Clamp( sv_ts_select_mode:GetInt(), 1, 3 )
	local stalker = team.GetPlayers( TEAM_STALKER )[1]
	local rand = table.Random( team.GetPlayers( TEAM_HUMAN ) )
	
	GAMEMODE.Winner = rand
	
	if not IsValid( stalker ) or mode == SELECTION_MODE_RANDOM then
	
		return rand
	
	end
	
	if mode == SELECTION_MODE_KILLER then
	
		local ply = stalker:GetLastDamager()
		
		if IsValid( ply ) then
		
			GAMEMODE.Winner = ply
		
			return ply
		
		else
		
			return rand
		
		end
	
	elseif mode == SELECTION_MODE_DAMAGE then
	
		local ply = stalker:GetHighestDamager()
		
		if IsValid( ply ) then
		
			GAMEMODE.Winner = ply
		
			return ply
		
		else
		
			return rand
		
		end
	
	end

end

function GM:KeyPress( ply, key )

	ply:OnKeyPress( key )

end

function GM:AllowPlayerPickup( ply, ent )

	return false
	
end

function GM:PlayerInitialSpawn( ply )

	ply:InitializeData()

	if table.Count( player.GetAll() ) == 1 then
	
		ply:SetTeam( TEAM_STALKER ) 
		ply:Spawn()
		
		GAMEMODE:SetInRound( true )
	
	else
	
		//ply:Give( "weapon_ts_spec" )
		//ply:Spectate( OBS_MODE_ROAMING )
		//ply:SetMoveType( MOVETYPE_NOCLIP )
		
		ply:SetTeam( TEAM_SPECTATOR )
		
		ply:SpawnAsScanner()
		
		net.Start( "ShowHelp" )
		net.Send( ply )	
	
	end

end

function GM:PlayerSetModel( ply )

end

function GM:PlayerSelectSpawn( ply )

	local ent = GAMEMODE:PlayerSelectTeamSpawn( ply:Team(), ply )
	
	if IsValid( ent ) then return ent end
	
end

function GM:PlayerSpawn( ply )

	ply:ResetHull()
	
	if ply:Team() == TEAM_UNASSIGNED then
	
		ply:Spectate( OBS_MODE_ROAMING )
		ply:SetMoveType( MOVETYPE_NOCLIP )
		ply:SetPos( ply:GetPos() + Vector( 0, 0, 50 ) )
		
		return
		
	end
	
	ply:OnSpawn()
	
end

function GM:CanPlayerSuicide( ply )

	return false
	
end

function GM:PlayerDeathThink( ply )
	
	if ply:Team() == TEAM_SPECTATOR and ply.ScannerTime and ply.ScannerTime < CurTime() then
	
		ply:SpawnAsScanner()
	
	end
	
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	if ply:Team() == TEAM_HUMAN then return dmginfo end

	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage( 1.60 ) 
    elseif hitgroup == HITGROUP_CHEST then
		dmginfo:ScaleDamage( 1.40 ) 
	elseif hitgroup == HITGROUP_STOMACH then
		dmginfo:ScaleDamage( 1.20 ) 
	else
		dmginfo:ScaleDamage( 1.00 )
	end
	
	return dmginfo

end 

function GM:GetFallDamage( ply, speed )

	if ply:Team() == TEAM_STALKER then return 0 end

	return speed * 0.1
	
end

function GM:PlayerDamaged( ply, attacker, dmginfo )

	if ply:Team() == TEAM_STALKER then
	
		if dmginfo:IsExplosionDamage() or dmginfo:GetAttacker():IsWorld() then 
		
			dmginfo:ScaleDamage( 0 )
			
		end
		
		if dmginfo:GetDamage() < ply:Health() and ( ply.LastPain or 0 ) < CurTime() then
		
			ply:EmitSound( Sound( "npc/antlion_guard/angry3.wav" ), 60, math.random( 150, 170 ) )
			ply.LastPain = CurTime() + 2
			
		end
		
		if attacker != ply and attacker:IsPlayer() then
		
			if math.random(1,4) == 1 then
		
				attacker:SetNextVoice( VO_ALERT, math.Rand( 2, 4 ) )
				
			end
			
			ply:AddDamage( attacker, dmginfo:GetDamage() )
		
		end
		
	elseif ply:Team() == TEAM_HUMAN then
	
		if attacker:IsPlayer() then
		
			if attacker:Team() == TEAM_SPECTATOR then
			
				dmginfo:ScaleDamage( 0 )
				
				return
			
			end
		
			if sv_ts_ff:GetBool() and attacker:Team() == ply:Team() then
				
				if sv_ts_ff_damage_reflect:GetBool() and dmginfo:GetDamageType() != DMG_CRUSH then
				
					local dmg = DamageInfo()
					dmg:SetDamage( math.max( dmginfo:GetDamage() * sv_ts_ff_reflect_scale:GetFloat(), 1 ) ) 
					dmg:SetDamageType( DMG_CRUSH ) 
					dmg:SetAttacker( ply ) 
				
					attacker:TakeDamageInfo( dmg )
				
				end
				
				dmginfo:ScaleDamage( math.max( sv_ts_ff_damage_scale:GetFloat(), 0 ) )
				dmginfo:SetDamageType( DMG_CRUSH )
				
			elseif attacker:Team() == ply:Team() then
			
				dmginfo:ScaleDamage( 0 )
			
			end
		
		end
	
		if ply:GetLoadout( 3 ) == UTIL_HEALTH and not ply.HealTime and ply:Health() - dmginfo:GetDamage() <= 50 then
			
			ply.AutoHeal = 0
			ply.HealTime = CurTime()
				
			net.Start( "Stim" )
			net.Send( ply )
			
		end
	
		if dmginfo:GetDamage() < ply:Health() and attacker:IsPlayer() and dmginfo:GetDamageType() != DMG_CRUSH then
		
			ply:VoiceSound( VO_PAIN )
			
			if attacker:Team() == TEAM_STALKER then
			
				ply:SetNextVoice( VO_ALERT, math.Rand( 2, 4 ) )
				
			end
			
		end
		
		if attacker:GetClass() == "prop_physics" then

			if attacker.Tele then
		
				local stalker = team.GetPlayers( TEAM_STALKER )[1]
				
				if IsValid( stalker ) then
			
					dmginfo:SetAttacker( stalker )
					
				end
				
			else
				
				print("ASFAS" .. dmginfo:GetDamage());
				dmginfo:ScaleDamage( sv_ts_prop_dmg_scale:GetFloat() )
			
			end
		
		end
		
	end

end

function GM:EntityTakeDamage( ent, dmginfo )

	if not GAMEMODE:InRound() then 
	
		dmginfo:ScaleDamage( 0 ) 
		
		return 
		
	elseif string.find( ent:GetClass(), "prop" ) and dmginfo:GetAttacker():IsPlayer() then
	
		dmginfo:ScaleDamage( 0.1 )
	
	elseif ent:IsPlayer() then
	
		GAMEMODE:PlayerDamaged( ent, dmginfo:GetAttacker(), dmginfo )
	
	end
	
end

function GM:PlayerDeath( victim, inflictor, att )

	victim.NextSpawnTime = CurTime() + 2
	victim.DeathTime = CurTime()
	
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	
	if ply:Team() == TEAM_STALKER and attacker:IsPlayer() then 
	
		ply:SetMaterial( "" )
		
		if attacker != ply then
		
			attacker:SetNextVoice( VO_TAUNT, 2 )
			
		else
		
			ply:AddFrags( -1 )
		
		end
		
	elseif ply:Team() == TEAM_HUMAN and attacker:IsPlayer() and attacker:Team() == TEAM_STALKER then
	
		attacker:AddFrags( 1 ) 
		attacker:AddHealth( math.abs( sv_ts_stalker_kill_health:GetInt() ) )
		attacker:SetDrainTime( sv_ts_stalker_drain_delay:GetInt() )
		
	end
	
	ply:OnDeath( dmginfo )
	
end

function GM:PlayerDeathSound()

	return true 
	
end

function ToggleLight( ply, cmd, args )

	if ply:Team() != TEAM_HUMAN or ( ply.LastFlashlight or 0 ) > CurTime() then return end
	
	ply.LastFlashlight = CurTime() + 0.5
	
	ply:LuaFlashlight( not tobool( ply:GetInt( "Light" ) ) )

end
concommand.Add( "ts_toggle_light", ToggleLight )

function StalkerEsp( ply, cmd, args )

	if ply:Team() != TEAM_STALKER then return end
	
	if ply:GetInt( "Thirst", 0 ) == 1 then return end
	
	if ply:GetInt( "StalkerEsp", 0 ) == 0 then
	
		ply:SetInt( "StalkerEsp", 1 )
	
	else
	
		ply:SetInt( "StalkerEsp", 0 )
	
	end

end
concommand.Add( "ts_toggle_esp", StalkerEsp )

function ChooseUtil( ply, cmd, args )

	local category = math.Clamp( math.floor( tonumber( args[1] ) ), 1, 3 )
	local choice = math.Clamp( math.floor( tonumber( args[2] ) ), 1, 4 )
	local initial = tonumber( args[3] or 0 )
	
	if tobool( initial ) then
	
		ply.InitialData = true
	
	end
	
	if ( category == 3 or category == 1 ) then
	
		ply.NextLoadout[ category ] = choice
		
		return
	
	end

	ply:SetLoadout( category, choice )
	
end
concommand.Add( "ts_apply_loadout", ChooseUtil )