if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "NV Range Scanner"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
	
	SWEP.IconLetter = "Q"

end

SWEP.Base = "ts_base"

SWEP.HoldType = "slam"

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.Primary.Deny           = Sound( "HL1/fvox/buzz.wav" )
SWEP.Primary.Sound          = Sound( "NPC_CombineGunship.PatrolPing" )
SWEP.Primary.Deploy         = Sound( "buttons/button19.wav" )
SWEP.Primary.Blip           = Sound( "buttons.snd15" )
SWEP.Primary.Holster        = Sound( "buttons/combine_button3.wav" )
SWEP.Primary.Delay			= 1.800
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.BatteryUse     = 35

function SWEP:Deploy()

	if SERVER then
	
		self.Owner:AddInt( "Battery", -5 )
	
	end

	self.Weapon:EmitSound( self.Primary.Deploy, 100, math.random( 90, 110 ) )
	self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DRAW )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	self.Weapon:DrawShadow( false )
	
	return true
	
end  

function SWEP:Holster()

	if CLIENT then

		self.Owner:EmitSound( self.Primary.Holster, 50, math.random( 100, 120 ) )
		
	end

	return true

end

function SWEP:PrimaryAttack()
	
	if ( SERVER and self.Owner:GetInt( "Battery" ) < self.Primary.BatteryUse ) or ( CLIENT and GAMEMODE:GetInt( "Battery" ) < self.Primary.BatteryUse ) then 
	
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		
		if SERVER then
		
			self.Owner:EmitSound( self.Primary.Deny, 40 )
			
		end
	
		return 
		
	end
	
	self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if SERVER then
	
		self.Owner:EmitSound( self.Primary.Blip, 100, math.random( 90, 110 ) )
		self.Owner:EmitSound( self.Primary.Sound, 100, math.random( 90, 110 ) )
		self.Owner:AddInt( "Battery", -1 * self.Primary.BatteryUse )
		
		net.Start( "Scanner" )
		net.Send( self.Owner )
	
	end
	
end

function SWEP:Think()	

end

function SWEP:Reload()
	
end

function SWEP:OnRemove()

end
