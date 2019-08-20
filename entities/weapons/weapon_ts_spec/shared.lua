if SERVER then

	AddCSLuaFile( "shared.lua" )

end

SWEP.Base = "ts_base"

SWEP.ViewModel = ""

function SWEP:Deploy()

	if SERVER then
	
		self.Owner:DrawWorldModel( false )
		
	end

	return true
	
end  

function SWEP:PrimaryAttack()

end
