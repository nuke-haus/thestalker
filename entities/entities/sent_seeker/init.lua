
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.CollideSound = Sound( "grenade.impacthard" )
ENT.TurnOn = Sound( "npc/roller/remote_yes.wav" )
ENT.Hover = Sound( "npc/scanner/combat_scan_loop2.wav" )
ENT.Cry = Sound( "npc/scanner/combat_scan3.wav" )
ENT.Idle = Sound( "npc/roller/mine/combine_mine_deactivate1.wav" ) 
ENT.IdleStart = Sound( "npc/roller/mine/combine_mine_deploy1.wav" ) 
ENT.Detect = Sound( "npc/scanner/combat_scan5.wav" ) 
ENT.DetectWeak = Sound( "npc/scanner/scanner_scan5.wav" ) 
ENT.Disabled = Sound( "npc/turret_floor/die.wav" )
ENT.Damaged = { Sound( "npc/scanner/scanner_pain1.wav" ), Sound( "npc/scanner/scanner_pain2.wav" ) }

ENT.MinDist = 100
ENT.MinDown = 0.5
ENT.MinUp = 0.7
ENT.RefreshLimit = 5
ENT.ScanRange = 800

function ENT:Initialize()
		
	self.Entity:PhysicsInitSphere( 3 )
	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
	self.Entity:DrawShadow( false )
	
	self.Entity:EmitSound( self.TurnOn, 80, 110 )

	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:SetMaterial( "gmod_silent" )
		phys:Wake()
		phys:SetMass( 1 )
		phys:ApplyForceCenter( self.Entity:GetAngles():Forward() * 500 )

	end
	
	self.ShadowParams = {}
	self.TargetAng = 0
	self.TargetPos = self.Entity:GetPos()
	self.SleepTime = CurTime() + 2
	self.LastRefresh = CurTime()
	self.CheckTime = CurTime() + 3
	
	self.Entity:StartMotionController()
	
end

function ENT:CreateLight( col, bright, size, len )

	self.FlashlightEnt = ents.Create( "env_projectedtexture" )
	self.FlashlightEnt:SetParent( self )
	self.FlashlightEnt:SetLocalPos( Vector(0,0,0) ) 
	self.FlashlightEnt:SetLocalAngles( Angle(90,0,90) )
	self.FlashlightEnt:SetKeyValue( "enableshadows", 0 )
	self.FlashlightEnt:SetKeyValue( "farz", len ) 
	self.FlashlightEnt:SetKeyValue( "nearz", 1 ) 
	self.FlashlightEnt:SetKeyValue( "lightfov", size ) 
		
	self.FlashlightEnt:SetKeyValue( "lightcolor", Format( "%i %i %i 255", col.r * bright, col.g * bright, col.b * bright ) )
	self.FlashlightEnt:Spawn()
	self.FlashlightEnt:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight/slit.vmt" )

end

function ENT:SetBattery( amt )

	self.LifeTime = CurTime() + ( 10 + ( amt / 85 ) * 25 )

end

function ENT:SetPlayer( ply )

	self.Player = ply

end

function ENT:Use( ply )

	if ply == self.Player and not self.Entity:GetNWBool( "Active", false ) then
	
		ply:Give( "weapon_ts_seeker" )
		//ply:SelectWeapon( "weapon_ts_seeker" )
		
		self.Entity:Remove()
	
	end

end

function ENT:Think() 

	if self.SleepTime and self.SleepTime < CurTime() then
	
		self.SleepTime = nil
		self.NeedsRefresh = true
		
		self.Entity:EmitSound( self.IdleStart, 120 )
		self.Entity:SetNWBool( "Active", true )
		
		local sound = CreateSound( self.Entity, self.Hover )
		sound:PlayEx( 0.3, 110 )
	
		self.FlySound = sound
		
		//self.Entity:CreateLight( Color( 0, 220, 255 ), 1.5, 50, 256 )
	
	end
	
	if self.LifeTime and self.LifeTime < CurTime() then
		
		self.Entity:EmitSound( self.IdleStart, 120, 80 )
		self.Entity:Disable()
	
	end
	
	if self.CryTime and self.CryTime < CurTime() then
	
		self.CryTime = CurTime() + 1
		
		self.Entity:EmitSound( self.Cry, 60, 140 )
	
	end
	
	if self.LifeTime and self.CheckTime < CurTime() then
	
		self.CheckTime = CurTime() + 1
		
		local stalker = team.GetPlayers( TEAM_STALKER )[1]
	
		if IsValid( stalker ) then
		
			if stalker:Alive() then
		
				if stalker:GetPos():Distance( self.Entity:GetPos() ) < self.MinDist then
		
					self.Entity:EmitSound( self.Detect, 120, 120 )
				
				elseif stalker:GetPos():Distance( self.Entity:GetPos() ) < self.MinDist * 4 then
				
					self.Entity:EmitSound( self.DetectWeak, 100, 120 )
				
				end
				
			end
		
		end
	
	end
	
	if not self.NeedsRefresh then
	
		local tr = self.Entity:Trace( ( self.TargetPos - self.Entity:GetPos() ):GetNormal(), self.Entity:GetPos(), self.TargetPos:Distance( self.Entity:GetPos() ) )
		local tr2 = self.Entity:Trace( Vector(0,0,-1) )
		
		if tr.HitWorld or tr2.HitPos:Distance( self.Entity:GetPos() ) < 10 then
		
			self.NeedsRefresh = true
		
		end
		
	end
	
	self.Entity:Pathfind()
	
end 

function ENT:Disable()

	self.LifeTime = nil
	self.SleepTime = nil
	self.CryTime = CurTime() + 1

	self.Entity:SetNWBool( "Active", false )
	
	if IsValid( self.FlashlightEnt ) then
	
		self.FlashlightEnt:Remove()
	
	end
	
	if self.FlySound then
	
		self.FlySound:Stop()
		self.FlySound = nil
	
	end

end

function ENT:Trace( dir, pos, dist )

	local trace = {}
	trace.start = pos or self.Entity:GetPos()
	trace.endpos = trace.start + dir * ( dist or 9000 )
	trace.filter = self.Entity
	
	return util.TraceLine( trace )

end

function ENT:FindTravelPos( pos, normal )

	normal.z = 0

	local tr = self.Entity:Trace( normal, pos, self.MinDist )
	
	local vec = tr.HitPos
	local up = self.Entity:Trace( Vector(0,0,1), vec )
	local dn = self.Entity:Trace( Vector(0,0,-1), vec )
	local dist = dn.HitPos:Distance( up.HitPos )
		
	vec = dn.HitPos + Vector(0,0,1) * ( dist * math.Rand( self.MinDown, self.MinUp ) )
	
	return vec

end

function ENT:Pathfind()

	if not self.NeedsRefresh then return end
	
	self.NeedsRefresh = false
	self.LastRefresh = CurTime()
	
	if self.NextPos then
	
		self.TargetPos = self.NextPos
	
	else

		local up = self.Entity:Trace( Vector(0,0,1) )
		local dn = self.Entity:Trace( Vector(0,0,-1) )
		local dist = dn.HitPos:Distance( up.HitPos )
		
		self.TargetPos = dn.HitPos + Vector(0,0,1) * ( dist * math.Rand( self.MinDown, self.MinUp ) )
	
	end
	
	local stalker = team.GetPlayers( TEAM_STALKER )[1]
	
	if IsValid( stalker ) then
	
		local tr = self.Entity:Trace( ( ( stalker:GetPos() + Vector(0,0,40) - self.Entity:GetPos() ) ):GetNormal(), nil, 9000 )
		
		if IsValid( tr.Entity ) and tr.Entity == stalker and stalker:GetPos():Distance( self.Entity:GetPos() ) < self.ScanRange then
		
			self.TargetPos = stalker:GetPos() + Vector(0,0,60)
			
		else
		
			local dir = VectorRand()
			dir.z = 0
			
			local tr = self.Entity:Trace( dir )
		
			self.NextPos = self.Entity:FindTravelPos( tr.HitPos, tr.HitNormal )
		
		end
	
	end

end

function ENT:PhysicsSimulate( phys, delta )

	phys:Wake()

	if not IsValid( self.Player ) or self.SleepTime or not self.LifeTime then 
	
		return //Vector(0,0,0), Angle(0,0,0), SIM_LOCAL_FORCE
		
	end
	
	if self.Entity:GetPos():Distance( self.TargetPos ) < self.MinDist or CurTime() - self.LastRefresh > self.RefreshLimit then
	
		self.NeedsRefresh = true
	
	end
	
	self.TargetAng = math.ApproachAngle( self.TargetAng, self.TargetAng + 250, FrameTime() * 350 )
 
	self.ShadowParams.secondstoarrive = 0.5
	self.ShadowParams.pos = self.TargetPos + Vector( 0, 0, ( math.sin( CurTime() * 5 ) * 30 ) )
	self.ShadowParams.angle = Angle( -90, 0, self.TargetAng )
	self.ShadowParams.maxangular = 50000
	self.ShadowParams.maxangulardamp = 60000
	self.ShadowParams.maxspeed = 35
	self.ShadowParams.maxspeeddamp = 80
	self.ShadowParams.dampfactor = 0.2
	self.ShadowParams.teleportdistance = 10000
	self.ShadowParams.deltatime = delta
 
	phys:ComputeShadowControl( self.ShadowParams )
 
end

function ENT:PhysicsCollide( data, phys )

	if data.Speed > 50 and data.DeltaTime > 0.35 then
		
		self.Entity:EmitSound( self.CollideSound, 80, 80 )
		
	end
	
end

function ENT:Malfunction()

	self.Entity:EmitSound( table.Random( self.Damaged ), 100 )
	self.Entity:Disable()
	
	if self.LifeTime then
	
		self.Entity:EmitSound( self.Disabled, 80, 130 )
			
		self.LifeTime = 0
			
	end
	
end

function ENT:OnTakeDamage( dmginfo )
	
	if dmginfo:GetAttacker():IsPlayer() then
	
		self.Entity:Malfunction()
		
		local phys = self.Entity:GetPhysicsObject()
			
		if IsValid( phys ) then
				
			local dir = ( self.Entity:GetPos() - dmginfo:GetAttacker():GetPos() ):GetNormal()
		
			phys:Wake()
			phys:ApplyForceCenter( dir * 100 )
			
		end
		
	end

end