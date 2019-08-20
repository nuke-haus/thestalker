
include( 'shared.lua' )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
	
end

function ENT:Think()

	self.Entity:SetRenderBoundsWS( self.Entity:GetEndPos( ), self.Entity:GetPos( ) )
	
end

ENT.Laser = Material( "sprites/bluelaser1" )
ENT.Light = Material( "effects/blueflare1" )

--[[function ENT:Draw()

end]]

function ENT:Draw()
	
	if self.Entity:GetEndPos() == Vector(0,0,0) then return end
	
	local offset = CurTime() * 3
	local distance = self.Entity:GetEndPos():Distance( self.Entity:GetPos() )
	local size = math.Rand( 2, 4 )
	local normal = ( self.Entity:GetPos() - self.Entity:GetEndPos() ):GetNormal() * 0.1
	
	render.SetMaterial( self.Laser )
	render.DrawBeam( self.Entity:GetEndPos(), self.Entity:GetPos(), 2, offset, offset + distance / 8, Color( 50, 255, 50, 100 ) )
	render.DrawBeam( self.Entity:GetEndPos(), self.Entity:GetPos(), 1, offset, offset + distance / 8, Color( 50, 255, 50, 100 ) )
	
	render.SetMaterial( self.Light )
	render.DrawQuadEasy( self.Entity:GetEndPos() + normal, normal, size, size, Color( 50, 255, 50, 100 ), 0 )
	render.DrawQuadEasy( self.Entity:GetPos(), normal * -1, size, size, Color( 50, 255, 50, 100 ), 0 )
	 
end

