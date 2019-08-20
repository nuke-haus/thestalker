
include( "cvars.lua" )

GM.Name 	= "The Stalker"
GM.Author 	= "twoski"
GM.Email 	= ""
GM.Website 	= ""

TEAM_HUMAN = 1
TEAM_STALKER = 2

function GM:CreateTeams()
	
	team.SetUp( TEAM_HUMAN, "Unit 8", Color( 80, 80, 255 ), true )
	team.SetSpawnPoint( TEAM_HUMAN, { "info_player_human", "info_player_counterterrorist", "info_player_combine", "info_player_deathmatch" } )
	
	team.SetUp( TEAM_STALKER, "The Stalker", Color( 255, 80, 80 ), false )
	team.SetSpawnPoint( TEAM_STALKER, { "info_player_stalker", "info_player_terrorist", "info_player_rebel", "info_player_start" } )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 80, 255, 150 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_counterterrorist", "info_player_combine", "info_player_human", "info_player_deathmatch" } ) 
	team.SetSpawnPoint( TEAM_UNASSIGNED, { "info_player_counterterrorist", "info_player_combine", "info_player_human", "info_player_deathmatch" } ) 

end

function GM:PlayerTraceAttack( ply, dmginfo, dir, trace ) 

	local dtrace = {}
	dtrace.start = trace.HitPos
	dtrace.endpos = dtrace.start + dir * 250
	dtrace.filter = ply
	dtrace.mask = MASK_NPCWORLDSTATIC
	
	local tr = util.TraceLine( dtrace )

	if ply:Team() == TEAM_STALKER then
	
		local ed = EffectData()
		ed:SetOrigin( trace.HitPos )
		util.Effect( "stalker_blood", ed )	
		
		if tr.Hit and tr.HitPos:Distance( trace.HitPos ) > 50 then
		
			util.Decal( "YellowBlood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
		
		end
	
	else
	
		local ed = EffectData()
		ed:SetOrigin( trace.HitPos + trace.HitNormal * 5 )
		util.Effect( "BloodImpact", ed )

		if tr.Hit then
		
			util.Decal( "Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
		
		end		
	
	end
	
	if SERVER then
	
 		GAMEMODE:ScalePlayerDamage( ply, trace.HitGroup, dmginfo ) 
		
		ply:TakeDamageInfo( dmginfo )
		
 	end 
	
	return true // override the default effects
	
end

GM.ScannerSpeed = 100

function GM:Move( ply, mv )
	
	if ply:Team() == TEAM_SPECTATOR and ply:Alive() then
		
		mv:SetMaxSpeed( 10 )
		
		local dir = ply:GetAimVector()
		local trdir
		local vert 
		local horiz 
		
		if ply:KeyDown( IN_FORWARD ) then
		
			trdir = dir
			horiz = 1
		
		elseif ply:KeyDown( IN_BACK ) then
		
			trdir = dir * -1
			horiz = -1
			
		elseif ply:KeyDown( IN_MOVERIGHT ) then
		
			trdir = ply:GetRight()
			horiz = 1
		
		elseif ply:KeyDown( IN_MOVELEFT ) then
		
			trdir = ply:GetRight() * -1
			horiz = -1
		
		elseif ply:KeyDown( IN_JUMP ) then
		
			trdir = Vector( 0, 0, 0.5 )
			vert = 0.5

		elseif ply:KeyDown( IN_WALK ) then
		
			trdir = Vector( 0, 0, -0.5 )
			vert = -0.5
			
		else
		
			mv:SetForwardSpeed( 0 )
			mv:SetUpSpeed( 0 )
			mv:SetVelocity( Vector( 0, 0, 0 ) )
			
			return mv
		
		end
		
		local trace = {}
		trace.start = ply:GetShootPos()
		trace.endpos = trace.start + trdir * 30
		trace.filter = { ply, ply.Scanner }
		trace.mask = MASK_NPCWORLDSTATIC
			
		local tr = util.TraceLine( trace )
			
		if tr.Hit then
			
			mv:SetForwardSpeed( 0 )
			mv:SetUpSpeed( 0 )
			mv:SetVelocity( Vector( 0, 0, 0 ) )
			
		else
				
			mv:SetVelocity( ( trdir * GAMEMODE.ScannerSpeed ) * FrameTime() )
			mv:SetOrigin( mv:GetOrigin() + ( trdir * GAMEMODE.ScannerSpeed ) * FrameTime() )			
				
			if vert then
				
				mv:SetUpSpeed( GAMEMODE.ScannerSpeed * vert * FrameTime() )
				
			else
				
				mv:SetForwardSpeed( GAMEMODE.ScannerSpeed * horiz * FrameTime() )
			
			end
		
		end
		
		return true
	
	end
	
	return mv

end

function GM:PlayerNoClip( ply, on )
	
	if game.SinglePlayer() then return true end
	
	if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
	
	return false
	
end

function GM:PlayerFootstep( ply, pos, foot, snd, volume, filter )
	
	if ply:Team() == TEAM_SPECTATOR or ply:GetMoveType() == MOVETYPE_FLY then return true end
	
	if ply:Team() == TEAM_STALKER and table.HasValue( GAMEMODE.Concrete, snd ) then 
		
		sound.Play( table.Random( GAMEMODE.StalkerFeet ), ply:GetPos() + ply:GetForward() * 5, 75, math.random( 40, 60 ), 0.1 )
		
		return true
		
	end
	
	if ply:Team() == TEAM_HUMAN then
		
		sound.Play( table.Random( GAMEMODE.HumanFeet ), ply:GetPos(), 75, math.random( 90, 110 ), 0.1 )
		
	end
	
end

function GM:OnPlayerChat( ply, text, teamchat, dead )
	
	// chat.AddText( player, Color( 255, 255, 255 ), ": ", strText )
	
	local tab = {}
	
	if dead then
	
		table.insert( tab, Color( 255, 255, 255 ) )
		table.insert( tab, "(DEAD) " )
		
	end
	
	if teamchat then 
	
		table.insert( tab, Color( 255, 255, 255 ) )
		table.insert( tab, "(TEAM) " )
		
	end
	
	if ( IsValid( ply ) ) then
	
		table.insert( tab, ply )
		
	else
	
		table.insert( tab, Color( 150, 255, 150 ) )
		table.insert( tab, "Console" )
		
	end
	
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": " .. text )
	
	chat.AddText( unpack( tab ) )

	return true
	
end