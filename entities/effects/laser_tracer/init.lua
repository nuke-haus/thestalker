
EFFECT.Mat = Material( "effects/spark" )

function EFFECT:Init( data )

	self.StartPos   = data:GetStart()       
    self.EndPos     = data:GetOrigin()
	self.Normal     = data:GetNormal()
	self.Ent        = data:GetEntity()
	self.Col        = Color( 255, 0, 0 )
	
	if self.Ent == LocalPlayer() then
	
		self.StartPos = self.StartPos + Vector(0,0,-20)
		self.Col = Color( 0, 255, 255 )
	
	end
	
    self.Dir        = self.EndPos - self.StartPos
        
    self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
        
    self.TracerTime = 0.1
    self.Length = 0.25
    self.DieTime = CurTime() + self.TracerTime
	self.Emitter = ParticleEmitter( self.EndPos )
        
end

function EFFECT:Think( )

    if CurTime() > self.DieTime then
	
		if self.Emitter then
		
			local particle = self.Emitter:Add( "effects/yellowflare", self.EndPos + self.Normal * 2 )
			particle:SetVelocity( Vector(0,0,0) )
			particle:SetDieTime( 0.3 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 2 )
			particle:SetEndSize( 8 )
			particle:SetRoll( math.random( -360, 360 ) )
			particle:SetColor( self.Col.r, self.Col.g, self.Col.b )
			particle:SetGravity( Vector(0,0,0) )
	
			for i=1, math.random( 6, 10 ) do
			
				local particle = self.Emitter:Add( "effects/yellowflare", self.EndPos )
				particle:SetVelocity( self.Normal * -250 + VectorRand() * 100 )
				particle:SetDieTime( math.Rand( 1.5, 3.0 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 2, 4 ) )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.random( -360, 360 ) )
				particle:SetColor( self.Col.r, self.Col.g, self.Col.b )
				particle:SetGravity( Vector( 0, 0, math.random( -600, -400 ) ) )
				particle:SetCollide( true )
				particle:SetBounce( math.Rand( 0.6, 0.8 ) )
				
			end
			
			self.Emitter:Finish()
			
		end
	
        return false 
			
	end
        
    return true

end

function EFFECT:Render( )

	//if self.Ent == LocalPlayer() then return end

    local delta = ( self.DieTime - CurTime() ) / self.TracerTime
    delta = math.Clamp( delta, 0, 1 ) ^ 0.5
                        
    render.SetMaterial( self.Mat )
        
    local sin = math.sin( delta * math.pi )
        
    render.DrawBeam( self.EndPos - self.Dir * ( delta - sin * self.Length ),            
                                     self.EndPos - self.Dir * ( delta + sin * self.Length ),
                                     2 + sin * 16,                                  
                                     1,                                     
                                     0,                             
                                     Color( self.Col.r, self.Col.g, self.Col.b, 255 ) )
                                         
end