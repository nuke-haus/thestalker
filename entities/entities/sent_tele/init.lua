
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.SpawnSound = Sound( "ambient/atmosphere/city_skypass1.wav" )

function ENT:Initialize()
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if self.Collides then
	
		self.Entity:SetSolid( SOLID_VPHYSICS )
	
		if IsValid( phys ) then
		
			phys:Wake()
			phys:SetMaterial( self.PhysMat )
			phys:EnableGravity( false )
		
		end
	
	else
	
		self.Entity:SetSolid( SOLID_NONE )
	
		if IsValid( phys ) then
		
			phys:Wake()
			phys:SetMaterial( self.PhysMat )
		
		end
	
	end
	
	self.DieTime = CurTime() + 5
	
	local par = self.Entity:GetTrueParent()
			
	if IsValid( par ) then
	
		if par:GetClass() == "prop_ragdoll" then
		
			self.Bloody = true
		
			par.Cons = {}
		
			table.insert( par.Cons, constraint.Weld( par, self.Entity, 0, 0, 0, true, false ) )
		
			for i=0,16 do
			
				local phys = par:GetPhysicsObjectNum( i )
			
				if IsValid( phys ) then
				
					phys:EnableGravity( false )
					phys:Wake()
					phys:AddAngleVelocity( VectorRand() * 800 )
					//phys:SetMass( 10 )
					
					table.insert( par.Cons, constraint.NoCollide( self.Entity, par, 0, i ) )
				
				end
				
			end
		
		else
	
			local phys = par:GetPhysicsObject()
			
			if IsValid( phys ) then
			
				phys:SetMass( math.Clamp( phys:GetMass(), 100, 5000 ) )
				phys:EnableMotion( true )
				phys:EnableGravity( false )
				phys:Wake()
				phys:AddAngleVelocity( VectorRand() * 800 )
			
			end
			
		end
	
	end
	
	self.Entity:EmitSound( self.SpawnSound, 100, math.random( 90, 110 ) )
	
end

function ENT:SetTrueParent( ent )

	self.Entity:SetNWEntity( "TrueParent", ent )

end

function ENT:GetTrueParent()

	if IsValid( self.Entity:GetParent() ) then
	
		return self.Entity:GetParent()
		
	elseif IsValid( self.Entity:GetNWEntity( "TrueParent" ) ) then
	
		return self.Entity:GetNWEntity( "TrueParent" )
		
	end
	
	return NULL

end

function ENT:SetCollides( bool )

	self.Collides = bool

end

function ENT:SetProp( ent )

	self.Prop = ent
 
end

function ENT:SetMass( mass )

	self.Mass = mass

end

function ENT:SetPhysMat( mat )

	self.PhysMat = mat
	
end

function ENT:Think()

	local par = self.Entity:GetTrueParent()
	
	if IsValid( par ) then
	
		local phys = par:GetPhysicsObject()
	
		if IsValid( phys ) then
	
			if self.LaunchDir and not self.Launched then
			
				self.Launched = true
			
				phys:EnableGravity( true )
				phys:AddAngleVelocity( VectorRand() * self.Mass )
				phys:ApplyForceCenter( ( self.Mass * 2500 ) * self.LaunchDir )
				
				if par:GetClass() == "prop_ragdoll" then
		
					for i=0,16 do
					
						phys = par:GetPhysicsObjectNum( i )
					
						if IsValid( phys ) then
						
							phys:EnableGravity( true )
							phys:Wake()
						
						end
				
					end
					
				end
				
				if self.Collides then
				
					phys = self.Entity:GetPhysicsObject()
					
					if IsValid( phys ) then
					
						phys:EnableGravity( true )
						phys:ApplyForceCenter( ( self.Mass * 9000 ) * self.LaunchDir )
						
					end
				
				end
		
			end
			
		end
	
	end

	if self.DieTime < CurTime() or not IsValid( self.Entity:GetTrueParent() ) or not self.Entity:GetOwner():Alive() then
	
		self.Entity:Remove()
	
	end

end

function ENT:SetLaunchTarget( pos )

	local dir = ( pos - self.Entity:GetPos() ):GetNormal()
	
	dir.z = math.Clamp( dir.z, -0.5, 1.0 )
	
	self.LaunchDir = dir
	self.DieTime = CurTime() + 2

end

function ENT:OnRemove()

	local par = self.Entity:GetTrueParent()
			
	if IsValid( par ) then
	
		if par:GetClass() == "prop_ragdoll" then
	
			for k,v in pairs( par.Cons ) do
			
				if IsValid( v ) then
			
					v:Remove()
					
				end
			
			end
			
		end
	
		par.Tele = nil
	
		local phys = par:GetPhysicsObject()
			
		if IsValid( phys ) then
			
			phys:EnableGravity( true )
			phys:Wake()
			
		end
		
	end

end

function ENT:OnTakeDamage( dmginfo )
	
end

function ENT:PhysicsCollide( data, phys )

	if self.Collides and data.DeltaTime > 0.15 then
	
		self.Entity:EmitSound( "Flesh.ImpactHard", 100, math.random( 80, 100 ) )
		
		util.Decal( "Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
	
	end
	
end

function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS 

end

