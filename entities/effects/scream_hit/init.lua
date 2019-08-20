
function EFFECT:Init( data )

	self.Pos = data:GetOrigin()
	
	if LocalPlayer():GetPos():Distance( self.Pos ) > 50 or LocalPlayer():Team() == TEAM_STALKER or LocalPlayer():Team() == TEAM_SPECTATOR then return end

	DisorientTime = CurTime() + 10
	ViewWobble = 3.5
	MotionBlur = 0.7
	Sharpen = 6.5
	
end

function EFFECT:Think( )

	return false
	
end

function EFFECT:Render()

end