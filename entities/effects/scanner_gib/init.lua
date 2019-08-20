

function EFFECT:Init( data )

	local num = data:GetScale()
	local pos = data:GetOrigin()

	self.Entity:SetModel( GAMEMODE.ScannerGibs[ num ] )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Entity:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )
	self.Entity:SetAngles( Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360) ) )
	self.Entity:GetPos( pos )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:Wake()
		phys:SetMass( 100 )
		phys:AddAngleVelocity( VectorRand() * 500 )
		phys:SetVelocity( VectorRand() * math.random( 250, 500 ) )
	
	end
	
	self.LifeTime = CurTime() + 15
	self.ParTime = CurTime() + 5
	
	if math.random( 1, 2 ) == 1 then return end
	
	self.Emitter = ParticleEmitter( self.Entity:GetPos() )
	
end

function EFFECT:Think( )

	if self.LifeTime < CurTime() then
	
		if self.Emitter then
		
			self.Emitter:Finish()
		
		end
	
		return false
	
	elseif self.Emitter and self.ParTime > CurTime() then
	
		local particle = self.Emitter:Add( "effects/yellowflare", self.Entity:GetPos() )
		particle:SetVelocity( VectorRand() * 20 )
		particle:SetDieTime( 1.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.Rand( 2, 4 ) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.random( -360, 360 ) )
		particle:SetColor( 180, 180, 255 )
		
		particle:SetAirResistance( math.random( 0, 20 ) )
		particle:SetGravity( Vector( 0, 0, -400 ) )
		
		particle:SetCollide( true )
		particle:SetBounce( 0.5 )
	
	end

	return true //self.LifeTime > CurTime()
	
end

function EFFECT:Render()

	self.Entity:DrawModel()

end