include('shared.lua')

function ENT:Initialize()

	self.Emitter = ParticleEmitter( self.Entity:GetPos() )
	self.LastPos = self.Entity:GetPos()
	
end

function ENT:OnRemove()

	if self.Emitter then
	
		self.Emitter:Finish()
	
	end

end

function ENT:Think()

	if not self.Emitter or not IsValid( self.Entity:GetOwner() ) then return end
	
	if self.Entity:GetOwner() == LocalPlayer() then return end
	
	if self.Entity:GetOwner():GetPos() == self.LastPos then return end
	
	self.LastPos = self.Entity:GetOwner():GetPos()

	local particle = self.Emitter:Add( "sprites/blueglow2", self.Entity:GetPos() + Vector( 0, 0, 1.5 ) )
	particle:SetVelocity( Vector( 0, 0, math.Rand( -2, 0 ) ) )
	particle:SetDieTime( 1.5 )
	particle:SetStartAlpha( 150 )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( math.Rand( 2, 4 ) )
	particle:SetEndSize( 6 )
	particle:SetRoll( math.random( -360, 360 ) )
	particle:SetColor( 255, 255, 200 )
	
	particle:SetAirResistance( math.random( 0, 20 ) )
	particle:SetGravity( Vector( 0, 0, 0 ) )
	
end

ENT.Glow = Material( "effects/yellowflare" )

function ENT:Draw()

	if self.Entity:GetOwner() == LocalPlayer() then return end

	self.Entity:DrawModel()
	
	local alpha = 125 + math.sin( CurTime() * 10 ) * 125
	local pos = self.Entity:GetPos() + self.Entity:GetForward() * 6 + self.Entity:GetUp() * -3
	
	render.SetMaterial( self.Glow )
	render.DrawSprite( pos, 5, 5, Color( 255, 0, 0, alpha ) )
	
end

