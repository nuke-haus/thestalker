if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "FN P90"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.IconLetter = "m"
	
	SWEP.ViewModelFlip = false
	
	SWEP.ViewModelFOV = 60
	
	SWEP.SupportsLaser = true
	SWEP.LaserAttachment = 1	
	SWEP.LaserOffset = Angle( 39.9, -50, -90 )
	SWEP.LaserScale = 0.75
	SWEP.LaserBeamOffset = Vector( 0, 0, 2.1 )
	
	killicon.AddFont( "weapon_ts_p90", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.Base = "ts_base" 

SWEP.HoldType = "rpg"

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_P90.Single" )
SWEP.Primary.Damage			= 20
SWEP.Primary.Force          = 7
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 4.0
SWEP.Primary.Cone			= 0.055
SWEP.Primary.Delay			= 0.075

SWEP.Primary.ClipSize		= 50
SWEP.Primary.Automatic		= true

SWEP.ShellType = 2
