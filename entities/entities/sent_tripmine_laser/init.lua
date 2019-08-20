
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self.Entity:DrawShadow( false )
	self.Entity:SetTrigger( true )
	self.Entity:SetSolid( SOLID_BBOX )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	self.Entity:SetModel( "models/weapons/w_grenade.mdl" )
	
end

function ENT:Think()

end

function ENT:Use( ply, caller )

	local parent = self.Entity:GetParent()
	
	if not IsValid( parent ) then

		self.Entity:Remove()
	
	end
	
	if ply:GetShootPos():Distance( parent:GetPos() ) < 80 then
	
		parent:DoUse( ply, caller )
	
	end

end

function ENT:Touch( ent )

	local parent = self.Entity:GetParent()
	
	if not IsValid( parent ) then

		self.Entity:Remove()
	
	end
	
	if not ent:IsPlayer() then
	
		local phys = ent:GetPhysicsObject()
		
		if IsValid( phys ) and not phys:IsAsleep() then
		
			parent:DoAlarm( false )
		
		end
	
	else
	
		if ent:Team() == TEAM_STALKER then
			
			parent:DoAlarm( true )

		elseif ent:Team() == TEAM_HUMAN then
		
			parent:DoAlarm( false )
			
		end
		
	end

end

