
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
		
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		
	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:Wake()
		phys:SetVelocity( Vector( 0, 0, 0 ) )

	end
	
	if not self.WepType then
	
		self.Entity:Remove()
	
	end
	
	self.CanUse = CurTime() + 1
	self.PushAway = 0
	
	if not self.Ammo then
	
		self.Ammo = 1
		
	end
	
end

function ENT:SetWepType( num )

	self.WepType = GAMEMODE.WeaponTypes[ num ]
	self.WepSlot = num
	
end

function ENT:SetAmmo( ammo )

	self.Ammo = ammo

end

function ENT:Think() 

	if self.PushAway < CurTime() then
	
		self.PushAway = CurTime() + 5
		
		for k,v in pairs( ents.FindByClass( "sent_droppedgun" ) ) do
		
			if v != self.Entity and v:GetPos():Distance( self.Entity:GetPos() ) < 50 then
			
				local dir = ( v:GetPos() - self.Entity:GetPos() ):GetNormal()
				local phys = v:GetPhysicsObject()
				
				if IsValid( phys ) then
				
					phys:ApplyForceCenter( dir * 600 )
				
				end
			
			end
		
		end
	
	end
	
end 

function ENT:Use( ply, caller )

	if ply:Team() != TEAM_HUMAN or self.CanUse > CurTime() then return end
	
	local ammo = ply:GetAmmo()
	local num = ply:GetCurrentWeapon()
	
	if GAMEMODE.WeaponModels[ num ] == self.Entity:GetModel() then
	
		ply:SetAmmo( self.Ammo )
		
		self.Entity:SetAmmo( ammo )
		self.Entity:SetPos( ply:GetPos() + Vector(0,0,20) )
		self.Entity:SetAngles( ply:GetAimVector():Angle() )
		
		local phys = self.Entity:GetPhysicsObject()
		
		if IsValid( phys ) then
		
			phys:Wake()
		
		end
		
		self.CanUse = CurTime() + 1
	
		return
	
	end
	
	local ent = ents.Create( "sent_droppedgun" )
	ent:SetPos( ply:GetPos() + Vector(0,0,20) )
	ent:SetAngles( ply:GetAimVector():Angle() )
	ent:SetModel( GAMEMODE.WeaponModels[ num ] )
	ent:SetWepType( num )
	ent:SetAmmo( ammo )
	ent:Spawn()
	
	if not ply.InitialWeapon then
	
		ply.InitialWeapon = ply:GetLoadout( 1 )
	
	end
	
	ply:Give( self.WepType )
	ply:SelectWeapon( self.WepType )
	ply:StripWeapon( GAMEMODE.WeaponTypes[ num ] )
	ply:SetAmmo( self.Ammo )
	//ply:SetLoadout( 1, self.WepSlot or 1 )
	ply:SetCurrentWeapon( self.WepSlot or 1 )
	
	self.Entity:Remove()

end

function ENT:PhysicsCollide( data, phys )

	if data.Speed > 50 and data.DeltaTime > 0.1 then
	
		self.Entity:EmitSound( table.Random( GAMEMODE.WeaponHit ), 60, math.random( 90, 110 ) )
		
	end
	
end
