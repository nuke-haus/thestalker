

function EFFECT:Init( data )

	if LocalPlayer():Team() == TEAM_STALKER then return end
	
	local pos = data:GetOrigin()
	local emitter = ParticleEmitter( pos )
	
	local particle = emitter:Add( "effects/blood_core", pos )
	particle:SetDieTime( 0.5 )
	particle:SetStartAlpha( 200 )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( 5 )
	particle:SetEndSize( math.Rand( 25, 50 ) )
	particle:SetRoll( math.Rand( -360, 360 ) )
	particle:SetColor( 120, 100, 0 )
	
	emitter:Finish()
	
end

function EFFECT:Think( )

	return false
	
end

function EFFECT:Render()
	
end

