

function EFFECT:Init( data )

	self.Ent = data:GetEntity()
	
	if not IsValid( self.Ent ) then  
		
		MsgN("DEAD")
		
		self.Cancel = true 
		
		return 
		
	end
	
	if LocalPlayer() == self.Ent then
		
		LocalPlayer():EmitSound( table.Random( GAMEMODE.PsySounds ), 150, math.random( 40, 60 ) )
		LocalPlayer():EmitSound( table.Random( GAMEMODE.PsySounds ), 150, math.random( 110, 130 ) )
		LocalPlayer():SetDSP( 24, false )
	
	else
	
		self.Emitter = ParticleEmitter( self.Ent:GetPos() )
		
		for i=1,20 do
		
			local pos = Vector(0,0,55) + self.Ent:GetAngles():Forward() * 10
		
			if self.Ent:KeyDown( IN_DUCK ) then
			
				pos = Vector(0,0,30) + self.Ent:GetAngles():Forward() * 10
			
			end
			
			local particle = self.Emitter:Add( "effects/yellowflare", self.Ent:GetPos() + pos )
			particle:SetVelocity( VectorRand() * 10 )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 2.5 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 100 )
			particle:SetStartSize( 4 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetColor( 25 + math.random( 0, 125 ), 0, 255 )
				
			particle:SetGravity( Vector( 0, 0, 50 ) )
			particle:SetCollide( true )
			particle:SetBounce( 1.0 )
				
			particle:SetThinkFunction( FlayThink )
			particle:SetNextThink( CurTime() + 0.1 )
		
		end
	
	end
	
	self.DieTime = CurTime() + 15
	self.ParTime = 0
	
end

function EFFECT:Think( )

	if self.Cancel then return false end
	
	if self.ParTime < CurTime() and IsValid( self.Ent ) and self.Ent != LocalPlayer() and self.Ent:Team() == TEAM_HUMAN then
	
		local pos = Vector(0,0,55) + self.Ent:GetAngles():Forward() * 10
		
		if self.Ent:KeyDown( IN_DUCK ) then
			
			pos = Vector(0,0,30) + self.Ent:GetAngles():Forward() * 10
			
		end
	
		local particle = self.Emitter:Add( "sprites/heatwave", self.Ent:GetPos() + pos )
		particle:SetVelocity( Vector(0,0,0) )
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 2.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 255 )
		particle:SetStartSize( math.Rand( 5, 15 ) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( -360, 360 ) )
		particle:SetColor( 255, 255, 255 )
				
		particle:SetGravity( VectorRand() * 5 )
	
	end

	if self.DieTime < CurTime() then
	
		if LocalPlayer() == self.Ent then
	
			LocalPlayer():SetDSP( 0, false )
			
		end
		
		if self.Emitter then
		
			self.Emitter:Finish()
		
		end
	
		return false
	
	end

	return true
	
end

function EFFECT:Render()

end

function FlayThink( part )

	local scale = 2.5 - part:GetLifeTime()
	
	part:SetGravity( VectorRand() * ( scale * 200 ) )
	part:SetNextThink( CurTime() + 0.1 )

end
