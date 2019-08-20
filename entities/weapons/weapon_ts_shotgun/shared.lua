if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "SPAS 12"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	SWEP.IconLetter = "k"
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
	
	SWEP.SupportsLaser = true
	SWEP.LaserScale = 0.85
	
	killicon.AddFont( "weapon_ts_shotgun", SWEP.KillFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType = "shotgun"

SWEP.Base = "ts_base"

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_Shotgun.Double" )
SWEP.Primary.Pump           = Sound( "Weapon_Shotgun.Special1" )
SWEP.Primary.ReloadSound    = Sound( "Weapon_Shotgun.Reload" )
SWEP.Primary.Damage			= 13
SWEP.Primary.Force          = 2
SWEP.Primary.NumShots		= 10
SWEP.Primary.Recoil			= 9.5
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay			= 0.550

SWEP.Primary.ClipSize		= 6
SWEP.Primary.Automatic		= false

SWEP.ShellType = 4

function SWEP:Deploy()

	if CLIENT then
	
		self.LaserTime = CurTime() + 0.5
	
	end

	self.Weapon:SetNWBool( "Reloading", false )
	self.Weapon:SetVar( "PumpTime", 0 )
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:DrawShadow( false )
	
	return true
	
end 

function SWEP:CanPrimaryAttack()
	
	if ( SERVER and self.Owner:GetAmmo() < 1 ) or ( CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 ) then
		
		self.Weapon:EmitSound( self.Primary.Empty, 50, 120 )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		
		return false
		
	end
	
	if self.Weapon:GetNWBool( "Reloading", false ) then
	
		self.Weapon:SetNWBool( "Reloading", false )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
		
		return false
	
	end

	if self.Weapon:Clip1() <= 0 and not self.Weapon:GetNWBool( "Reloading", false ) then
		
		self.Weapon:SetNWBool( "Reloading", true )
		self.Weapon:SetVar( "ReloadTimer", CurTime() + 0.5 )
		self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
		
		return false
		
	end
	
	return true
	
end

function SWEP:PrimaryAttack()

	if not self.Weapon:CanPrimaryAttack() then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self.Weapon:ShootBullets( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone )
	self.Weapon:TakePrimaryAmmo( 1 )
	self.Weapon:SetVar( "PumpTime", CurTime() + 0.5 )
	
	self.Weapon:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
	
	if SERVER then

		self.Owner:AddAmmo( -1 )
		
	end
	
	local scale = 0.50

	if self.Owner:KeyDown( IN_DUCK ) then

		scale = 0.40
		
	elseif self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then

		scale = 0.75
		
	end

	local pang, yang = math.Rand( -1 * scale, -0.2 ) * self.Primary.Recoil, math.Rand( -1 * ( scale * 0.2 ), ( scale * 0.2 ) ) * self.Primary.Recoil

	self.Owner:ViewPunch( Angle( pang, yang, 0 ) )
	
end

function SWEP:Reload()

	if self.Weapon:GetVar( "PumpTime", 0 ) != 0 and self.Weapon:GetVar( "PumpTime", 0 ) >= CurTime() then return end

	if SERVER and self.Owner:GetAmmo() < 1 then return end
	
	if CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 then return end

	if self.Weapon:Clip1() == self.Primary.ClipSize or self.Weapon:GetNWBool( "Reloading", false ) then return end
	
	self.Weapon:SetNWBool( "Reloading", true )
	self.Weapon:SetVar( "ReloadTimer", CurTime() + 0.5 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
end

function SWEP:PumpIt()

	self.Weapon:SetNWBool( "Reloading", false )
	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_PUMP )
	self.Weapon:EmitSound( self.Primary.Pump )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	//if CLIENT then return end
	
	//timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self.Owner:GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ) ) end end )
	
end

function SWEP:Think()

	if self.Weapon:GetVar( "PumpTime", 0 ) != 0 and self.Weapon:GetVar( "PumpTime", 0 ) < CurTime() then
	
		self.Weapon:SetVar( "PumpTime", 0 )
		self.Weapon:PumpIt()
		
	end

	if self.Weapon:GetNWBool( "Reloading", false ) then
	
		if self.Weapon:GetVar( "ReloadTimer", 0 ) < CurTime() then
			
			if self.Weapon:Clip1() >= self.Primary.ClipSize then
			
				self.Weapon:SetNWBool( "Reloading", false )
				self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
				self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
				
				return
				
			end
			
			// Next cycle
			self.Weapon:SetVar( "ReloadTimer", CurTime() + 0.75 )
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
			self.Weapon:EmitSound( self.Primary.ReloadSound, 100, math.random(90,110) )
			
		end
		
	end

end

function SWEP:ShootBullets( damage, numbullets, aimcone )

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		
	self.Owner:MuzzleFlash()								
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local scale = aimcone
	
	if self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then
	
		scale = aimcone * 1.10
		
	elseif self.Owner:KeyDown( IN_DUCK ) then
	
		scale = aimcone * 0.90
		
	end
	
	self.Weapon:CreateBullets( scale, damage, numbullets )
	
end

