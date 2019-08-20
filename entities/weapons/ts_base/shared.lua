if SERVER then

	AddCSLuaFile( "shared.lua" )
	
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	
end

if CLIENT then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.CSMuzzleFlashes	= true

	SWEP.ViewModelFOV		= 74
	SWEP.ViewModelFlip		= true
	
	SWEP.PrintName = ""
	SWEP.IconLetter = "c"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	
	SWEP.IconFont = "CSSelectIcons"
	SWEP.KillFont = "CSKillIcons"
	
	SWEP.SupportsLaser = false
	SWEP.LaserOffset = Angle(0,0,0)
	SWEP.LaserScale = 1
	SWEP.LaserAttachment = 1
	SWEP.LaserBeamOffset = Vector(0,0,0)
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
		//draw.SimpleText( self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color( 15, 20, 200, 255 ), TEXT_ALIGN_CENTER )
		
	end
	
end

SWEP.SwayScale 	= 1.0
SWEP.BobScale 	= 1.0

SWEP.HoldType = "ar2"

SWEP.ViewModel	= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"

SWEP.Primary.Sound			= Sound( "Weapon_m4a1.single" )
SWEP.Primary.Empty          = Sound( "Weapon_smg1.empty" )
SWEP.Primary.Recoil			= 3.5
SWEP.Primary.Damage			= 20
SWEP.Primary.Force          = 2
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay			= 0.150

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 200
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.AmmoType		= "Pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ShellSounds = {}
SWEP.ShellSounds[1] = { Pitch = 100, Wavs = { "player/pl_shell1.wav", "player/pl_shell2.wav", "player/pl_shell3.wav" } }
SWEP.ShellSounds[2] = { Pitch = 90, Wavs = { "player/pl_shell1.wav", "player/pl_shell2.wav", "player/pl_shell3.wav" } }
SWEP.ShellSounds[3] = { Pitch = 80, Wavs = { "player/pl_shell1.wav", "player/pl_shell2.wav", "player/pl_shell3.wav" } }
SWEP.ShellSounds[4] = { Pitch = 110, Wavs = { "weapons/fx/tink/shotgun_shell1.wav", "weapons/fx/tink/shotgun_shell2.wav", "weapons/fx/tink/shotgun_shell3.wav" } }

SWEP.ShellType = 1

function SWEP:GetClipSize()

	return self.Primary.ClipSize

end

function SWEP:GetViewModelPosition( pos, ang )

	return pos, ang
	
end

function SWEP:AdjustMouseSensitivity()

	local scale = ( self.Owner:GetFOV() or 0 ) / 100
	
	if scale == 0 then
	
		return 
		
	end

	return scale
	
end	

function SWEP:Initialize()

	self.Weapon:SetWeaponHoldType( self.HoldType )
	
end

function SWEP:CanDrawLaser()

	return self.SupportsLaser and ( self.LaserTime or 0 ) < CurTime()

end

function SWEP:Deploy()

	if CLIENT then
	
		self.LaserTime = CurTime() + 0.5
	
	end

	self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:DrawShadow( false )
	
	return true
	
end  

function SWEP:Think()	

	self.Weapon:ReloadThink()

end

function SWEP:Reload()
	
	if SERVER and self.Owner:GetAmmo() < 1 then return end
	
	if CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 then return end
	
	if self.Weapon:Clip1() == self.Primary.ClipSize then return end

	//self.Weapon:DefaultReload( ACT_VM_RELOAD )
	self.Weapon:DoReload()
	
end

function SWEP:DoReload()

	if self.ReloadTime then return end

	local time = self.Weapon:StartWeaponAnim( ACT_VM_RELOAD )
	
	self.Weapon:SetNextPrimaryFire( CurTime() + time + 0.100 )
	
	self.ReloadTime = CurTime() + time

end

function SWEP:ReloadThink()

	if self.ReloadTime and self.ReloadTime <= CurTime() then
	
		self.ReloadTime = nil
		self.Weapon:SetClip1( self.Primary.ClipSize )
	
	end

end

function SWEP:StartWeaponAnim( anim )
		
	if IsValid( self.Owner ) then
	
		local vm = self.Owner:GetViewModel()
	
		local idealSequence = self:SelectWeightedSequence( anim )
		local nextSequence = self:FindTransitionSequence( self.Weapon:GetSequence(), idealSequence )

		if nextSequence > 0 then
		
			vm:SendViewModelMatchingSequence( nextSequence )
			
		else
		
			vm:SendViewModelMatchingSequence( idealSequence )
			
		end

		return vm:SequenceDuration( vm:GetSequence() )
		
	end	
	
end

function SWEP:CanPrimaryAttack()

	if ( SERVER and self.Owner:GetAmmo() < 1 ) or ( CLIENT and GAMEMODE:GetInt( "Ammo" ) < 1 ) then
		
		self.Weapon:EmitSound( self.Primary.Empty, 50, 120 )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		
		return false
		
	end

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
	
	self.Weapon:EmitSound( self.Primary.Sound, 100, math.random(95,105) )
	
	if SERVER then
		
		self.Owner:AddAmmo( -1 )
		
		timer.Simple( math.Rand( 0.4, 0.6 ), function() if IsValid( self ) then sound.Play( table.Random( self.ShellSounds[ self.ShellType ].Wavs ), self.Owner:GetPos(), 75, self.ShellSounds[ self.ShellType ].Pitch + math.random( -5, 5 ), 0.1 ) end end )
		
	end
	
	local scale = 0.50
		
	if self.Owner:KeyDown( IN_DUCK ) then
		
		scale = 0.25
			
	elseif self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then
		
		scale = 0.75
			
	end
	
	local pang, yang = math.Rand( -1 * scale, -0.1 ) * self.Primary.Recoil, math.Rand( -1 * ( scale * 0.2 ), ( scale * 0.2 ) ) * self.Primary.Recoil
		
	self.Owner:ViewPunch( Angle( pang, yang, 0 ) )
	
end

function SWEP:SecondaryAttack()

end

function SWEP:ShootBullets( damage, numbullets, aimcone )

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		
	self.Owner:MuzzleFlash()								
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local scale = aimcone
	
	if self.Owner:KeyDown( IN_FORWARD ) or self.Owner:KeyDown( IN_BACK ) or self.Owner:KeyDown( IN_MOVELEFT ) or self.Owner:KeyDown( IN_MOVERIGHT ) then
	
		scale = aimcone * 1.25
		
	elseif self.Owner:KeyDown( IN_DUCK ) then
	
		scale = aimcone * 0.5
		
	end
	
	self.Owner:LagCompensation( true )
	
	self.Weapon:CreateBullets( scale, damage, numbullets )
	
	self.Owner:LagCompensation( false )
	
end

function SWEP:CreateBullets( scale, dmg, num )

    local bullet = {}

    bullet.Num         = num
    bullet.Src         = self.Owner:GetShootPos()
    bullet.Dir         = self.Owner:GetAimVector()
    bullet.Spread      = Vector( scale, scale, 0 )
    bullet.Tracer      = 0
    bullet.Force       = self.Primary.Force
    bullet.Damage      = dmg
    bullet.AmmoType    = "Pistol"
    bullet.TracerName  = "Tracer"
    bullet.Callback = function ( attacker, tr, dmginfo )
	
        self:BulletCallback(  attacker, tr, dmginfo, 0 )
		
		if tr.MatType == MAT_GLASS then
		
			local edata = EffectData()
			edata:SetOrigin( tr.HitPos )
			edata:SetNormal( tr.HitNormal )        
			edata:SetStart( tr.StartPos )
			//edata:SetSurfaceProp( util.GetSurfaceIndex( "glass" ) )
			
			util.Effect( "GlassImpact", edata )
		
		end
		
		if tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_STALKER then
			
			sound.Play( "Flesh.BulletImpact", tr.HitPos, 75, math.random( 90, 110 ), 1.0 )
			
			return { effects = false }
			
		end
		
    end

    self.Owner:FireBullets( bullet )
	
end

function SWEP:BulletCallback( attacker, tr, dmginfo, bounce )

	if ( !self or not IsValid( self.Weapon ) ) then return end
	
	self.Weapon:BulletPenetration( attacker, tr, dmginfo, bounce + 1 )
	
end

function SWEP:GetPenetrationDistance( mat_type )

	if ( mat_type == MAT_PLASTIC || mat_type == MAT_WOOD || mat_type == MAT_FLESH || mat_type == MAT_ALIENFLESH || mat_type == MAT_GLASS ) then
	
		return 64
		
	end
	
	return 32
	
end

function SWEP:GetPenetrationDamageLoss( mat_type, distance, damage )

	if ( mat_type == MAT_GLASS || mat_type == MAT_FLESH || mat_type == MAT_ALIENFLESH ) then
		return damage
	elseif ( mat_type == MAT_PLASTIC  || mat_type == MAT_WOOD ) then
		return damage - distance
	elseif( mat_type == MAT_TILE || mat_type == MAT_SAND || mat_type == MAT_DIRT ) then
		return damage - ( distance * 1.2 )
	end
	
	return damage - ( distance * 1.8 )
	
end

function SWEP:BulletPenetration( attacker, tr, dmginfo, bounce )

	if ( !self or not IsValid( self.Weapon ) ) then return end
	
	if ( bounce > 3 ) then return false end
	
	local PeneDir = tr.Normal * self:GetPenetrationDistance( tr.MatType )
		
	local PeneTrace = {}
	   PeneTrace.endpos = tr.HitPos
	   PeneTrace.start = tr.HitPos + PeneDir
	   PeneTrace.mask = MASK_SHOT
	   PeneTrace.filter = { self.Owner }
	   
	local PeneTrace = util.TraceLine( PeneTrace ) 
	
	if ( PeneTrace.StartSolid || PeneTrace.Fraction >= 1.0 || tr.Fraction <= 0.0 ) then return false end
	
	local distance = ( PeneTrace.HitPos - tr.HitPos ):Length()
	local new_damage = self:GetPenetrationDamageLoss( tr.MatType, distance, dmginfo:GetDamage() )
	
	if new_damage > 0 then
	
		local bullet = 
		{	
			Num 		= 1,
			Src 		= PeneTrace.HitPos,
			Dir 		= tr.Normal,	
			Spread 		= Vector( 0, 0, 0 ),
			Tracer		= 0,
			Force		= 5,
			Damage		= new_damage,
			AmmoType 	= "Pistol",
		}
		
		bullet.Callback = function( a, b, c ) 
		
			if ( self.BulletCallback ) then 
			
				self:BulletCallback( a, b, c, bounce + 1 ) 
				
				if tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_STALKER then
					
					sound.Play( "Flesh.BulletImpact", tr.HitPos, 75, math.random( 90, 110 ), 1.0 )
					
					return { effects = false }
					
				end
						
			end 
			
		end
		
		local effectdata = EffectData()
		effectdata:SetOrigin( PeneTrace.HitPos );
		effectdata:SetNormal( PeneTrace.Normal );
		util.Effect( "Impact", effectdata ) 
		
		timer.Simple( 0.05, function() attacker:FireBullets( attacker, bullet, true ) end )
		
	end
	
end

function SWEP:DrawHUD()
	
end
