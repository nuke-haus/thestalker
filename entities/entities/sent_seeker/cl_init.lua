
include('shared.lua')

function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()

end

function ENT:Think()

	self.Entity:SetModelScale( 0.5, 0 )

	if not self.Entity:GetNWBool( "Active", false ) then return end
	
	local dlight = DynamicLight( self.Entity:EntIndex() )
	
	if dlight then
	
		dlight.Pos = self.Entity:GetPos()
		dlight.r = 0
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 1.5
		dlight.Decay = 0
		dlight.size = 128
		dlight.DieTime = CurTime() + 0.5
		
	end
	
end

ENT.Shine = Material( "sprites/light_ignorez" )
ENT.Beam = Material( "effects/lamp_beam" )

function ENT:DrawTranslucent()
	
	if not self.Entity:GetNWBool( "Active", false ) then return end
	
	local norm = ( self.Entity:GetAngles() + Angle(90,0,0) ):Forward()
	local norm2 = ( self.Entity:GetAngles() + Angle(-90,0,0) ):Forward()
	local view = self.Entity:LocalToWorld( self.Entity:OBBCenter() ) - EyePos()
	local dist = view:Length()
	
	view:Normalize()
	
	local dot = view:Dot( norm * -1 )
	local dot2 = view:Dot( norm2 * -1 )
	local pos = self.Entity:LocalToWorld( self.Entity:OBBCenter() ) + norm * 3
	local pos2 = self.Entity:LocalToWorld( self.Entity:OBBCenter() ) + norm2 * 3
	
	if dot >= 0 then
		
		self.Entity:DrawLight( dot, pos, dist )
		
	elseif dot2 >= 0 then
	
		self.Entity:DrawLight( dot2, pos2, dist )
	
	end
	
end

function ENT:DrawLight( dot, pos, dist )

	render.SetMaterial( self.Shine )
		
	local visibile = util.PixelVisible( pos, 8, self.PixVis )	
		
	if visible == 0 then return end
		
	local size = math.Clamp( dist * visibile * dot * 2, 4, 24 )
		
	dist = math.Clamp( dist, 32, 800 )
		
	local alpha = math.Clamp( ( 1000 - dist ) * visibile * dot, 0, 100 )
		
	render.DrawSprite( pos, size, size, Color( 0, 255, 255, alpha ), visibile * dot )
	render.DrawSprite( pos, size * 0.4, size * 0.4, Color( 0, 255, 255, alpha ), visibile * dot )

end

ENT.Light = Material( "effects/blueflare1" )

function ENT:Draw()

	self.Entity:DrawModel()
	
	if not self.Entity:GetNWBool( "Active", false ) then return end
	
	local pos = self.Entity:LocalToWorld( self.Entity:OBBCenter() )
	local size = 15 + math.sin( CurTime() * 5 ) * 5
	
	render.SetMaterial( self.Light )
	render.DrawSprite( pos, size, size, Color( 0, 255, 255 ) )
	
end

