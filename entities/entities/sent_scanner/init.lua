
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Fly = Sound( "npc/scanner/scanner_alert1.wav" )
ENT.Zap = Sound( "npc/scanner/scanner_electric1.wav" )
ENT.Beep = Sound( "npc/scanner/cbot_servoscared.wav" )
ENT.Explode = { Sound( "npc/scanner/cbot_energyexplosion1.wav" ), Sound( "npc/scanner/scanner_explode_crash2.wav" ) } 

function ENT:Initialize()

	self.Entity:SetModel( "models/manhack.mdl" )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:Wake()
	
	end
	
	self.Entity:SetCollisionBounds(Vector(-1,-1,-1), Vector(1,1,1))
	
	self.SpawnTime = CurTime()
	self.SoundTime = 0
	self.ZapSound = 0
	self.TargetTime = 0
	self.TargetEnt = nil
	self.ShadowParams = {}
	
	local seq = self.Entity:LookupSequence( "fly" )
	
	self.Entity:ResetSequence( seq )
	self.Entity:StartMotionController()
	self.Entity:EmitSound( self.Beep )
	
end

function ENT:GetShootPos()

	return ( self.Entity:GetPos() + self.Entity:GetForward() * 6 + self.Entity:GetUp() * -3 )

end

function ENT:TargetEnemy( enemy )

	self.TargetEnt = enemy
	self.TargetTime = CurTime() + 3
	
	--[[local col = Color( 255, 0, 0 )
	local br = 1.5
	local size = 25
	local len = 250
	
	self.Entity:CreateLight( col, br, size, len )]]

end

function ENT:Gib()

	self.Entity:EmitSound( table.Random( self.Explode ), 100, math.random( 90, 110 ) ) 

	local ed = EffectData()
	ed:SetOrigin( self:GetPos() )
	ed:SetStart( self:GetPos() )
	ed:SetScale( 2 )
	ed:SetMagnitude( 10 )
	util.Effect( "sparks", ed, true, true )
	
	for i=1, table.Count( GAMEMODE.ScannerGibs ) do
	
		local ed = EffectData()
		ed:SetOrigin( self:GetPos() )
		ed:SetScale( i )
		util.Effect( "scanner_gib", ed, true, true )
	
	end

end

function ENT:Think()

	if not IsValid( self.Entity:GetOwner() ) then
	
		self.Entity:Remove()
	
	end
	
	if IsValid( self.FlashlightEnt ) and self.TargetTime < CurTime() then
	
		self.Entity:RemoveLight()
	
	end
	
	if self.SoundTime < CurTime() then
	
		self.SoundTime = CurTime() + 1
		
		sound.Play( self.Fly, self.Entity:GetPos(), 75, 75, 0.05 )
	
	end

end

function ENT:CreateLight( col, bright, size, len )

	self.FlashlightEnt = ents.Create( "env_projectedtexture" )
	self.FlashlightEnt:SetParent( self )
	self.FlashlightEnt:SetLocalPos( Vector(5,0,0) ) 
	self.FlashlightEnt:SetLocalAngles( Angle(0,0,0) )
	self.FlashlightEnt:SetKeyValue( "enableshadows", 0 )
	self.FlashlightEnt:SetKeyValue( "farz", len ) 
	self.FlashlightEnt:SetKeyValue( "nearz", 12 ) 
	self.FlashlightEnt:SetKeyValue( "lightfov", size ) 
		
	self.FlashlightEnt:SetKeyValue( "lightcolor", Format( "%i %i %i 255", col.r * bright, col.g * bright, col.b * bright ) )
	self.FlashlightEnt:Spawn()
	self.FlashlightEnt:Input( "SpotlightTexture", NULL, NULL, "effects/Flashlight001.vmt" )

end

function ENT:RemoveLight()

	if IsValid( self.FlashlightEnt ) then
	
		self.FlashlightEnt:Remove()
		
	end

end

function ENT:PhysicsSimulate( phys, deltatime )

	if not IsValid( self.Entity:GetOwner() ) then return end
 
	phys:Wake()
	
	local dir = self.Entity:GetOwner():GetAimVector()
	dir.z = math.Clamp( dir.z, -0.3, 0.3 )
	
	--[[if self.TargetTime > CurTime() and IsValid( self.TargetEnt ) then
	
		dir = ( ( self.TargetEnt:GetPos() + Vector(0,0,20) ) - self.Entity:GetPos() ):GetNormal()
	
	end]]
 
	self.ShadowParams.secondstoarrive = 0.01
	self.ShadowParams.pos = self.Entity:GetOwner():GetShootPos() + Vector( 0, 0, math.sin( ( CurTime() + self.SpawnTime ) * 4 ) * 2 )
	self.ShadowParams.angle = dir:Angle()
	self.ShadowParams.maxangular = 500000 
	self.ShadowParams.maxangulardamp = 600000
	self.ShadowParams.maxspeed = 500000 
	self.ShadowParams.maxspeeddamp = 600000
	self.ShadowParams.dampfactor = 0.9
	self.ShadowParams.teleportdistance = 500
	self.ShadowParams.deltatime = deltatime 
 
	phys:ComputeShadowControl( self.ShadowParams )
 
end

function ENT:PhysicsCollide( data, phys )

	if ( data.Speed > 250 or ( data.Speed > 100 and data.HitEntity.Tele ) ) and data.DeltaTime > 0.35 then
	
		self.Entity:Gib()
		self.Entity:Remove()
		
	end
	
end

function ENT:OnTakeDamage( dmginfo )

	if dmginfo:GetAttacker():IsPlayer() then
	
		if dmginfo:GetAttacker():Team() == TEAM_STALKER then
	
			self.Entity:Gib()
			self.Entity:Remove()
			
		elseif self.ZapSound < CurTime() then
		
			self.ZapSound = CurTime() + 1
		
			self.Entity:EmitSound( self.Zap, 100, math.random( 90, 110 ) )
		
		end
	
	end
	
end

function ENT:OnRemove()

	if IsValid( self.Entity:GetOwner() ) and self.Entity:GetOwner():Alive() and self.Entity:GetOwner():Team() == TEAM_SPECTATOR then
	
		self.Entity:GetOwner():Kill()
		self.Entity:GetOwner():Spectate( OBS_MODE_ROAMING )
		self.Entity:GetOwner():SetMoveType( MOVETYPE_NOCLIP )
		self.Entity:GetOwner():SetPos( self.Entity:GetPos() )
	
	end

	self.Entity:RemoveLight()

end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS // needed?

end

