
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
		
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetMaterial( "models/flesh" )
		
	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:Wake()
		phys:SetMass( math.random( 20, 40 ) )
		phys:ApplyForceCenter( VectorRand() * 1000 )
		phys:AddAngleVelocity( VectorRand() * 500 )
		phys:SetMaterial( "flesh" )

	end
	
end

function ENT:Think() 
	
end 

function ENT:PhysicsCollide( data, phys )

	if data.Speed > 50 and data.DeltaTime > 0.35 then
	
		self.Entity:EmitSound( table.Random( GAMEMODE.GoreSplat ), 75, math.random( 80, 120 ) )
		
		if not self.Splat then
		
			self.Splat = true
			
			util.Decal( "Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
		
		end
		
	end
	
end

function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )

end