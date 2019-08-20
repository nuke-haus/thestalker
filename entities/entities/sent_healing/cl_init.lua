include('shared.lua')

function ENT:Initialize()

	self.Emitter = ParticleEmitter( self.Entity:GetPos() ) 
	
	self.EndTime = CurTime() + 5
	
end

function ENT:OnRemove()

	if self.Emitter then
	
		self.Emitter:Finish()
		
	end

end

function ENT:Think()

	if IsValid( self.Entity:GetOwner() ) and self.Entity:GetOwner() == LocalPlayer() and not self.Started then
	
		self.Started = true
		self.EndTime = CurTime() + 5
		
		ViewWobble = 1.0
		Sharpen = 5.5
		ColorModify[ "$pp_colour_addb" ] = 0.5
		ColorModify[ "$pp_colour_mulb" ] = 0.5
	
	elseif not IsValid( self.Entity:GetOwner() ) then
	
		return
	
	end
	
	for i=1, math.random( 5, 10 ) do
	
		local scale = ( self.EndTime - CurTime() ) / 5
	
		local particle = self.Emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.Entity:GetOwner():GetPos() + Vector( math.random(-10,10), math.random(-10,10), math.random(1,50) ) )
		particle:SetVelocity( VectorRand() * 5 )
		particle:SetDieTime( math.Rand(3.5,4.5) )
		particle:SetStartAlpha( 15 + scale * 20 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.Rand(10,20) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.random(-360,360) )
		particle:SetRollDelta( math.Rand(-5,5) )
		particle:SetColor( 50, 150, 255 )
		
		particle:SetGravity( Vector( 0, 0, 0 ) )
	
	end
	
end

function ENT:Draw()
	
end

