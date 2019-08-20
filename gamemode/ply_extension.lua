
local meta = FindMetaTable( "Player" )
if not meta then return end 

function meta:GetInt( name, default )

	if not self.Data then return 0 end

	return self.Data[ name ] or ( default or 0 )

end

function meta:SetInt( name, value, override )

	value = math.Clamp( value, 0, 300 )
	
	self.Data[ name ] = value
	
	if override then return end
	
	net.Start( "SynchInt" )
			
		net.WriteString( name )	
		net.WriteUInt( value, 8 )
			
	net.Send( self )

end

function meta:AddInt( name, amt )

	self:SetInt( name, self:GetInt( name ) + amt )

end

function meta:SetLastDamager( ply )

	self.LastDamager = ply

end

function meta:GetLastDamager()

	return self.LastDamager

end

function meta:AddDamage( ply, dmg )

	if not self.Damagers[ply] then
	
		self.Damagers[ply] = dmg
	
	else
	
		self.Damagers[ply] = self.Damagers[ply] + dmg
	
	end

	self:SetLastDamager( ply )
	
end

function meta:GetHighestDamager()

	local max = 0
	local ply = nil

	for k,v in pairs( self.Damagers ) do
	
		if v > max then
		
			max = v
			ply = k
		
		end
	
	end
	
	return ply

end

function meta:SetCommander( b )
	self.Commander = b
end

function meta:IsCommander()
	return self.Commander
end

function meta:CanFlay()

	if self.FlayTime and self.FlayTime > CurTime() then
	
		return false
	
	end
	
	return true

end

function meta:Flay( attacker )

	net.Start( "Flay" )
	net.Send( self )
	
	net.Start( "Flay" )
	net.Send( attacker )

	local ed = EffectData()
	ed:SetEntity( self )
	util.Effect( "mind_flay", ed, true, true )
	
	self:TakeDamage( 5, attacker )
	self.FlayTime = CurTime() + 20

end

function meta:Gib( attacker )

	self.Gibbed = true

	local doll = ents.Create( "prop_ragdoll" )
	doll:SetModel( table.Random( GAMEMODE.GibCorpses ) )
	doll:SetPos( self:GetPos() )
	doll:SetAngles( self:GetAngles() )
	doll:Spawn()
	doll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	doll:SetMaterial( "models/flesh" )
	
	self:SetTeam( TEAM_SPECTATOR )
	self:SetMoveType( MOVETYPE_NOCLIP )
	self:Spectate( OBS_MODE_CHASE )
	self:SpectateEntity( doll )
	
	local ed = EffectData()
	ed:SetOrigin( self:GetPos() )
	util.Effect( "gore_explosion", ed, true, true )
	
	local dir = ( self:GetPos() - attacker:GetPos() ):GetNormal()
	local phys = doll:GetPhysicsObject()
			
	if IsValid( phys ) then
			
		phys:AddAngleVelocity( VectorRand() * 2000 )
		phys:ApplyForceCenter( dir * math.random( 3000, 6000 ) )

	end	
	
	for i=1, 12 do
	
		local trace = {}
		trace.start = doll:GetPos()
		trace.endpos = trace.start + VectorRand() * math.random( 5, 15 )
		trace.mask = MASK_NPCWORLDSTATIC
		trace.filter = doll
		
		local tr = util.TraceLine( trace )
	
		local gib = ents.Create( "sent_giblet" )
		gib:SetPos( tr.HitPos + tr.HitNormal * 5 )
		
		if i < 6 then
		
			gib:SetModel( table.Random( GAMEMODE.BigGibs ) )
		
		else
		
			gib:SetModel( table.Random( GAMEMODE.SmallGibs ) )
			
		end
		
		gib:Spawn()
	
	end

end

function meta:ClientSound( snd )

	self:SendLua( "surface.PlaySound( \"" .. snd .. "\" )" ) 

end

function meta:KillFlashlight()

	self:LuaFlashlight( false )
	self:SetInt( "Light", 0 )

end

function meta:LuaFlashlight( on )

	if on then
	
		local c = Color( 255, 255, 200 ) 
		local b = 0.2
		local size = 35
		local len = 550
		
		if self:GetLoadout( 3 ) == UTIL_LIGHT then
		
			c = Color( 220, 220, 255 ) 
			b = 1.5
			size = 50
			len = 650
		
		end

		self.FlashlightEnt = ents.Create( "sent_flashlight" )
		self.FlashlightEnt:CreateLight( c, b, size, len )
		self.FlashlightEnt:SetOwner( self )
		self.FlashlightEnt:SetPos( self:GetShootPos() )
		self.FlashlightEnt:SetAngles( self:GetAimVector():Angle() )
		self.FlashlightEnt:Spawn()
		
		self:EmitSound( "items/flashlight1.wav", 50, 110 )
		self:SetNWBool( "Flashlight", true )
		self:SetInt( "Light", 1 )
		
	else
	
		if IsValid( self.FlashlightEnt ) then
		
			self.FlashlightEnt:Remove()
			
			self:EmitSound( "items/flashlight1.wav", 50, 90 )
			self:SetNWBool( "Flashlight", false )
			self:SetInt( "Light", 0 )
		
		end
	
	end

end

function meta:SpawnAsScanner()

	self:Spawn()
    self:SetPos( self:GetPos() + Vector(0,0,50) )
    self:Spectate( OBS_MODE_ROAMING )
    self:SetMoveType( MOVETYPE_NOCLIP )
    self:StripWeapons()
    self:Give( "weapon_ts_spec_scanner" )
	
	local ent = ents.Create( "sent_scanner" )
	ent:SetPos( self:GetShootPos() )
	ent:SetAngles( self:GetAngles() )
	ent:SetOwner( self )
	ent:Spawn()
	
	self:SetNetworkedEntity( "Scanner", ent )
	self.Scanner = ent

end

function meta:InitializeData()

	self.Data = {}
	self.NextLoadout = {}
	self.SpecNum = 1
	
	if self.InitialData then return end

	self:SetLoadout( 1, math.random( 1, 4 ) )
	self:SetLoadout( 2, math.random( 1, 4 ) )
	self:SetLoadout( 3, math.random( 1, 4 ) )

end

function meta:ObserverThink()

	if self:GetObserverMode() == OBS_MODE_CHASE or self:GetObserverMode() == OBS_MODE_IN_EYE then
	
		local target = self:GetObserverTarget()
		
		if not IsValid( target ) then
		
			self:UnSpectate()
			self:Spectate( OBS_MODE_ROAMING )
			self:SetPos( self:GetPos() + Vector(0,0,50) )
		
		elseif target:IsPlayer() and not self:IsValidObserverTarget( target ) then
		
			self:GetNextObserverTarget()
		
		end
	
	end
	
end

function meta:SetObserverTarget(target)

	self:SetPos( target:GetPos() )
	self:SpectateEntity( target )
	
end

function meta:GetNextObserverMode()

	if IsValid( self:GetObserverTarget() ) and self:GetObserverTarget():GetClass() == "prop_ragdoll" then
	
		return OBS_MODE_CHASE
	
	end

	if self:GetObserverMode() == OBS_MODE_ROAMING then
	
		return OBS_MODE_CHASE
		
	elseif self:GetObserverMode() == OBS_MODE_CHASE then
	
		return OBS_MODE_IN_EYE
		
	end
	
	return OBS_MODE_ROAMING
	
end

function meta:GetValidObserverTargets()

	return team.GetPlayers( TEAM_HUMAN )

end

function meta:GetPreviousObserverTarget()

	if not IsValid( self:GetObserverTarget() ) then
	
		self:Spectate( OBS_MODE_ROAMING )
		
		return
	
	end

	local prev = table.FindPrev( self:GetValidObserverTargets(), self:GetObserverTarget() )
	
	if IsValid( prev ) then
	
		self:SetObserverTarget( prev )
	
	else
	
		self:Spectate( OBS_MODE_ROAMING )
		
	end
	
end

function meta:GetNextObserverTarget()

	local nextTarget = table.FindNext( self:GetValidObserverTargets(), self:GetObserverTarget() )
	
	if IsValid( nextTarget ) then
	
		self:SetObserverTarget( nextTarget )
	
	else
	
		self:Spectate( OBS_MODE_ROAMING )
		
	end
	
end

function meta:IsValidObserverTarget(target)

	return target:Team() == TEAM_HUMAN
	
end

function meta:OnKeyPress( key )

	if self:Team() == TEAM_SPECTATOR and not self:Alive() then
	
		if key == IN_ATTACK then
		
			self:GetNextObserverTarget()
			
		elseif key == IN_ATTACK2 then
		
			self:GetPreviousObserverTarget()
		
		elseif key == IN_JUMP then
		
			self:Spectate( self:GetNextObserverMode() ) -- stop fucking with this nuke, this is how it works in cs
			
		elseif key == IN_SPEED then
		
			self:SetPos( self:GetPos() + Vector(0, 0, 50) )
			
		end
		
		return
	
	end

	if self:Team() != TEAM_STALKER then return end

	if key == IN_SPEED then
	
		if self:OnGround() and ( self.JumpTime or 0 ) < CurTime() then
		
			local jump = self:GetAimVector() * 400 + Vector( 0, 0, 350 )
		
			self:SetVelocity( jump )
			self:EmitSound( "npc/fast_zombie/foot3.wav", 40, math.random( 90, 110 ) )
			
			self.JumpTime = CurTime() + 1
			
		else
		
			local tr = util.TraceLine( util.GetPlayerTrace( self ) )
			
			if tr.HitPos:Distance( self:GetShootPos() ) < 50 and not self:OnGround() then
			
				self:SetLocalVelocity( Vector( 0, 0, 0 ) )
				self:SetMoveType( MOVETYPE_NONE )
				
			elseif self:GetMoveType() == MOVETYPE_NONE then
			
				self:SetMoveType( MOVETYPE_WALK )
				self:SetLocalVelocity( self:GetAimVector() * 500 )
				
			end
			
		end
		
	elseif key == IN_JUMP and self:GetMoveType() == MOVETYPE_NONE then
	
		self:SetMoveType( MOVETYPE_WALK )
		self:SetLocalVelocity( Vector( 0, 0, 50 ) )
		
	end

end

function meta:Think()
	
	if self:Team() == TEAM_SPECTATOR then
	
		self:ObserverThink()
	
	end

	if not self:Alive() or not GAMEMODE:InRound() then return end
	
	if self:Team() == TEAM_HUMAN then
	
		if ( self.BatteryTime or 0 ) < CurTime() then

			if tobool( self:GetInt( "Light", 0 ) ) then // light is on
			
				if self:GetInt( "Battery" ) > 0 then
				
					self.BatteryTime = CurTime() + 0.20
					self:AddInt( "Battery", -1 )
				
				end
				
				if self:GetInt( "Battery" ) < 1 then
				
					self.BatteryTime = CurTime() + 5.5
					self.LastFlashlight = CurTime() + 5.5
				
					if self:GetLoadout( 3 ) == UTIL_LIGHT then
					
						self.BatteryTime = CurTime() + 2.5
						self.LastFlashlight = CurTime() + 2.5
					
					end
		
					self:KillFlashlight()
				
				end
			
			elseif self:GetInt( "Battery" ) < 100 then
			
				self.BatteryTime = CurTime() + 0.35
				
				self:AddInt( "Battery", 1 )
				
				if self:GetLoadout( 3 ) == UTIL_LIGHT then
				
					self.BatteryTime = CurTime() + 0.25
				
				end
			
			end
		
		end
		
		if self.HealTime and self.HealTime < CurTime() and self.AutoHeal < 50 then
		
			self.HealTime = CurTime() + 0.35
			self.AutoHeal = self.AutoHeal + 1
			
			self:AddHealth( 1 )
		
		end
		
		if not self.NextVoice then
		
			self:SetNextVoice( VO_IDLE, math.random( 40, 140 ) )
		
		end
		
		if self.NextVoice < CurTime() then
		
			self:VoiceSound( self.NextVoiceType )
			self.NextVoice = nil
		
		end

	elseif self:Team() == TEAM_STALKER then 
	
		if ( self.ManaTime or 0 ) < CurTime() and not tobool( self:GetInt( "StalkerEsp" ) ) and self:GetInt( "Mana" ) < 100 then
		
			self.ManaTime = CurTime() + 0.5
			self:AddInt( "Mana", 1 )
		
		end
		
		if ( self.DrainTime or 0 ) < CurTime() and team.NumPlayers( TEAM_HUMAN ) > 0 and GAMEMODE:InRound() then
		
			self.DrainTime = CurTime() + math.max( sv_ts_stalker_drain_time:GetFloat(), 0.5 )
			
			local drain = math.ceil( ( self:Health() / 100 ) * sv_ts_stalker_drain_scale:GetFloat() )
		
			if self:Health() <= drain and self:Alive() then
			
				if IsValid( self.LastDamager ) and self.LastDamager:Alive() and self.LastDamager:Team() == TEAM_HUMAN then
				
					self:TakeDamage( drain + 10, self.LastDamager, self.LastDamager )
					
					self.LastDamager = nil
				
				else
			
					self:Kill()
					
				end
				
				return
				
			end
		
			self:AddHealth( -1 * drain )
		
		end
	
	end
		
end

function meta:SetDrainTime( num ) 

	self.DrainTime = CurTime() + num
	
	self:SetInt( "Drain", num )

end

function meta:SetNextVoice( vtype, delay )

	self.NextVoiceType = vtype or VO_IDLE
	self.NextVoice = CurTime() + ( delay or 5 )

end

function meta:VoiceSound( vtype, override )

	if not self:Alive() then return end

	if ( self.SoundTime or 0 ) < CurTime() or override then
	
		local sound = table.Random( GAMEMODE.Voices[ vtype ] )
		
		if vtype == VO_DEATH or vtype == VO_PAIN then
		
			self:EmitSound( sound )
			
			self.SoundTime = CurTime() + 0.5
		
		else
	
			self:EmitSound( table.Random( GAMEMODE.VoiceStart ), 100, math.random( 90, 110 ) )
			timer.Simple( 0.3, function() if IsValid( self ) and self:Alive() then self:EmitSound( sound, 100 ) end end )
			//timer.Simple( SoundDuration( sound ) + math.Rand( 0.6, 0.8 ), function() if IsValid( self ) then self:EmitSound( table.Random( GAMEMODE.VoiceEnd ), 100, math.random( 90, 110 ) ) end end )
			
			self.SoundTime = CurTime() + SoundDuration( sound ) + 1.5
			
			self:FindResponse( vtype, SoundDuration( sound ) + 1.5 )
			
		end
	
	end

end

function meta:FindResponse( vtype, delay )

	if vtype == VO_YES or vtype == VO_TAUNT or math.random(1,8) == 1 then return end
	
	for k,v in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
	
		if v:Alive() and v != self then
		
			if v:GetPos():Distance( self:GetPos() ) < 400 then
			
				v:SetNextVoice( VO_YES, delay )
				
				return
			
			end
		
		end
	
	end

end

function meta:SetLoadout( num, value )

	if num > 3 then return end
	
	if num == 3 then
	
		self:SetNWBool( "PickedLaser", ( value == UTIL_LASER ) )
		
	end

	self:SetInt( "Loadout" .. num, value )

end

function meta:GetLoadout( num )

	return self:GetInt( "Loadout" .. num, 1 )

end

function meta:SetCurrentWeapon( num )

	self.CurWep = num

end

function meta:GetCurrentWeapon()

	return self.CurWep or 1

end

function meta:HasLaserEquiped()

	return self:GetNetworkedBool("PickedLaser", false)
	
end

function meta:SetAmmo( amt )

	self:SetInt( "Ammo", amt )

end

function meta:GetAmmo()

	return self:GetInt( "Ammo" )

end

function meta:AddAmmo( amt )

	self:SetAmmo( self:GetAmmo() + amt )

end

function meta:OnSpawn()

	if self:Team() == TEAM_SPECTATOR and not self.ScannerTime then
	
		self:Spectate( OBS_MODE_ROAMING )
		self:SetMoveType( MOVETYPE_NOCLIP )
		self:Give( "weapon_ts_spec" )
		
		return
		
	end

	self.Gibbed = false
	self.HealTime = nil
	self.ScannerTime = nil
	self.Damagers = {}
	
	self:KillFlashlight()
	self:AllowFlashlight( false )
	self:StripWeapons()
	self:UnSpectate()
	self:SetMoveType( MOVETYPE_WALK )
	self:SetNoCollideWithTeammates( sv_ts_team_nocollide:GetBool() )

	if self:Team() == TEAM_HUMAN then
	
		if self:IsCommander() then
	
			self:SetHealth( 125 )
			self:SetMaxHealth( 125 )
			self.MaxHealth = 125
			self:SetModel( "models/player/combine_soldier.mdl" )
	
		else
		
			self:SetHealth( 100 )
			self:SetMaxHealth( 100 )
			self.MaxHealth = 100
			self:SetModel( "models/player/police.mdl" )
		
		end
		
		if self.NextLoadout[3] then
		
			self:SetLoadout( 3, self.NextLoadout[3] )
			
			self.NextLoadout[3] = nil
		
		end
		
		if self.NextLoadout[1] then
		
			self:SetLoadout( 1, self.NextLoadout[1] )
			
			self.NextLoadout[1] = nil
		
		end
		
		player_manager.SetPlayerClass( self, "player_combine" )
		
		local oldhands = self:GetHands()
	
		if IsValid( oldhands ) then
		
			oldhands:Remove()
			
		end

		local hands = ents.Create( "gmod_hands" )
		
		if IsValid( hands ) then
		
			hands:DoSetup( self )
			hands:Spawn()
			
		end	
		
		self:Give( GAMEMODE.WeaponTypes[ self:GetLoadout( 1 ) ] )
		self:Give( GAMEMODE.SecondaryTypes[ self:GetLoadout( 2 ) ] )
		self:SetCurrentWeapon( self:GetLoadout( 1 ) )
		
		local amt = GAMEMODE.MagAmounts[ self:GetLoadout( 1 ) ] or 0
		
		self:SetAmmo( amt * 3 )
		
		if self:GetLoadout( 3 ) == UTIL_AMMO then
		
			self:SetAmmo( amt * 4 )
		
		end
		
		self:SetJumpPower( 180 )
		self:SetWalkSpeed( 225 )
		self:SetRunSpeed( 225 )
		
		self:SetInt( "Battery", 100 )
		
		self:SetMaterial( "" )
		self:DrawShadow( true )
		self:SetAvoidPlayers( true )
		self:SetPlayerColor( Vector( 1, 1, 1 ) )
	
	elseif self:Team() == TEAM_STALKER then
	
		local hp = math.abs( sv_ts_stalker_health:GetInt() ) + math.abs( sv_ts_stalker_add_health:GetInt() ) * math.Clamp( team.NumPlayers( TEAM_HUMAN ), 0, 32 )
		
		self:SetHealth( hp )
		self:SetMaxHealth( hp )
		self.MaxHealth = hp
		
		self:SetWalkSpeed( 350 )
		self:SetRunSpeed( 350 )
		self:SetJumpPower( 300 )
		
		self:Give( "weapon_stalker" )
		self:SetModel( "models/player/soldier_stripped.mdl" )
		
		self:SetInt( "Mana", 100 )
		self:SetDrainTime( sv_ts_stalker_drain_delay:GetInt() )
		
		self:SetMaterial( "sprites/heatwave" )
		self:DrawShadow( false )
		self:SetAvoidPlayers( false )
		
	end

end

function meta:AddHealth( num )

	self:SetHealth( math.Clamp( self:Health() + num, 1, self.MaxHealth ) )

end

function meta:OnDeath( dmginfo )

	if self:Team() == TEAM_SPECTATOR then return end

	if self:Team() == TEAM_HUMAN then
		
		local gun = self:GetCurrentWeapon()
	
		local wep = ents.Create( "sent_droppedgun" )
		wep:SetPos( self:GetShootPos() + Vector(0,0,-10) )
		wep:SetAngles( self:GetAngles() )
		wep:SetModel( GAMEMODE.WeaponModels[ gun ] )
		wep:SetWepType( gun )
		wep:SetAmmo( self:GetAmmo() )
		wep:Spawn()
		
		if self.InitialWeapon then
		
			self:SetLoadout( 1, self.InitialWeapon )
			
			self.InitialWeapon = nil
		
		end
		
		self:SetAmmo( 0 )
		self:SetFOV( 0, 0.5 )
		self:KillFlashlight()
		self.ScannerTime = CurTime() + sv_ts_spectate_time:GetInt()
		
		if dmginfo:GetDamage() > 80 then
			
			self:Gib( dmginfo:GetAttacker() )
			
		else
			
			self:VoiceSound( VO_DEATH )
		
		end
	
	elseif self:Team() == TEAM_STALKER then
	
		self:EmitSound( table.Random( GAMEMODE.StalkerDie ), 80, math.random( 160, 180 ) )
		
	end
	
	self:CreateDeathRagdoll( dmginfo:GetAttacker(), dmginfo )

end

function meta:CreateDeathRagdoll( attacker, dmginfo )

	if self.Gibbed then return end

	if self:Team() == TEAM_STALKER then
	
		self:CreateRagdoll()
		
		return
	
	end
	
	local doll = ents.Create( "prop_ragdoll" )
	doll:SetModel( self:GetModel() )
	doll:SetPos( self:GetPos() )
	doll:SetAngles( self:GetAngles() )
	doll:SetKeyValue( "sequence", 1 )
	doll:Spawn()
	doll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	self:SetTeam( TEAM_SPECTATOR )
	self:SetMoveType( MOVETYPE_NOCLIP )
	self:Spectate( OBS_MODE_CHASE )
	self:SpectateEntity( doll )
	
	self.SpecTimer = CurTime() + 3
	
	if IsValid( attacker ) and attacker:IsPlayer() and attacker != self then
	
		local dir = ( self:GetPos() - attacker:GetPos() ):GetNormal()
		
		for i=1, math.random( 3, 5 ) do
		
			local phys = doll:GetPhysicsObjectNum( math.random( 0, doll:GetPhysicsObjectCount() ) )
			
			if IsValid( phys ) then
			
				phys:AddAngleVelocity( VectorRand() * 1000 )
				phys:ApplyForceCenter( dir * math.random( 3000, 6000 ) )
			
			end

		end	
		
	end
	
end

