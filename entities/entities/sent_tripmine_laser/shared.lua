ENT.Type = "anim"

function ENT:SetEndPos( endpos )

	self.Entity:SetNWVector( "End", endpos )	
	self.Entity:SetCollisionBoundsWS( self.Entity:GetPos( ), endpos, Vector( ) * 0.25 )
	
end

function ENT:GetEndPos()

	return self.Entity:GetNWVector( "End", Vector(0,0,0) )
	
end