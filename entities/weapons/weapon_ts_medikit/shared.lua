if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "Injector"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	SWEP.IconLetter = "F"
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 45

end

SWEP.Base = "ts_base"

SWEP.HoldType = "slam"

SWEP.UseHands = true

SWEP.ViewModel		= "models/weapons/c_medkit.mdl"
SWEP.WorldModel		= "models/weapons/w_medkit.mdl"

SWEP.Primary.Deny           = Sound( "HL1/fvox/buzz.wav" )
SWEP.Primary.Heal           = Sound( "items/smallmedkit1.wav" )
SWEP.Primary.Delay          = 0.500

function SWEP:Deploy()
	
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	
	return true
	
end  

function SWEP:PrimaryAttack()

	if CLIENT then return end

	if self.Owner:Health() > self.Owner:GetMaxHealth() - 40 then
	
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		
		self.Owner:EmitSound( self.Primary.Deny, 50 )
		
		return
	
	end
	
	net.Start( "Stim" )
	net.Send( self.Owner )
	
	self.Owner:EmitSound( self.Primary.Heal )
	self.Owner:AddHealth( 50 )
	self.Owner:AddInt( "Battery", -35 )
	self.Owner:StripWeapon( "weapon_ts_medikit" )
	
end
