if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "USP Compact"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	SWEP.IconLetter = "c"
	
	SWEP.SupportsLaser = true
	SWEP.LaserOffset = Angle( -1.3, 0.3, 0 )
	SWEP.LaserScale = 0.35
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	
	killicon.AddFont( "weapon_ts_usp", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.Base = "ts_base"

SWEP.HoldType = "revolver"

SWEP.UseHands = true

SWEP.ViewModel	= "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_Pistol.NPC_Single" )
SWEP.Primary.Clipout        = Sound( "Weapon_deagle.clipout" )
SWEP.Primary.Clipin         = Sound( "Weapon_usp.clipin" )
SWEP.Primary.Slide          = Sound( "Weapon_usp.sliderelease" )
SWEP.Primary.Damage			= 30
SWEP.Primary.Force          = 8
SWEP.Primary.NumShots		= 1
SWEP.Primary.Recoil			= 6.5
SWEP.Primary.Cone			= 0.040
SWEP.Primary.Delay			= 0.180

SWEP.Primary.ClipSize		= 12
SWEP.Primary.Automatic		= false

function SWEP:Reload()
	
	if self.Weapon:Clip1() == self.Primary.ClipSize then return end

	self.Weapon:DoReload()
	
	if SERVER or self.SlideSound then return end
	
	self.Owner:EmitSound( self.Primary.Clipout, 100, math.random( 95, 105 ) )
	
	self.ClipSound = CurTime() + 0.6
	self.SlideSound = CurTime() + 1.1
	
end

function SWEP:CanPrimaryAttack()

	if self.Weapon:Clip1() <= 0 then
	
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		self.Weapon:Reload()
		
		return false
		
	end
	
	return true
	
end

function SWEP:PrimaryAttack()

	if not self.Weapon:CanPrimaryAttack() then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self.Weapon:ShootBullets( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )
	self.Weapon:TakePrimaryAmmo( 1 )
	
	if IsFirstTimePredicted() then
	
		self.Weapon:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
		
		local scale = 0.50
			
		if self.Owner:KeyDown( IN_DUCK ) then
			
			scale = 0.25
				
		elseif self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then
			
			scale = 0.60
				
		end
			
		local pang, yang = math.Rand( -1 * scale, -0.1 ) * self.Primary.Recoil, math.Rand( -1 * ( scale * 0.2 ), ( scale * 0.2 ) ) * self.Primary.Recoil
			
		self.Owner:ViewPunch( Angle( pang, yang, 0 ) )
			
		timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self.Owner:GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ), 0.1 ) end end )
		
	end
	
end

function SWEP:Think()	

	self.Weapon:ReloadThink()
	
	if SERVER then return end
	
	if self.ClipSound and self.ClipSound < CurTime() then
	
		self.ClipSound = nil
		
		self.Owner:EmitSound( self.Primary.Clipin, 100, math.random( 95, 105 ) )
	
	end
	
	if self.SlideSound and self.SlideSound < CurTime() then
	
		self.SlideSound = nil
		
		self.Owner:EmitSound( self.Primary.Slide, 100, math.random( 95, 105 ) )
	
	end

end
