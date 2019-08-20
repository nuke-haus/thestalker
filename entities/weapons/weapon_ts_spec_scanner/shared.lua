if SERVER then

	AddCSLuaFile( "shared.lua" )

end

SWEP.Base = "ts_base"

SWEP.ViewModel = ""

SWEP.Ping = Sound( "npc/combine_gunship/gunship_ping_search.wav" )
SWEP.Scan = Sound( "npc/scanner/scanner_blip1.wav" )
SWEP.Alert = Sound( "npc/scanner/scanner_siren2.wav" )
SWEP.Shoot = Sound( "npc/roller/mine/rmine_explode_shock1.wav" )
SWEP.Disable = Sound( "npc/turret_floor/retract.wav" )
SWEP.Enable = Sound( "npc/turret_floor/deploy.wav" )

SWEP.Primary.Automatic = true
SWEP.Primary.Damage    = 5
SWEP.Primary.Delay     = 0.700
SWEP.Primary.Cone      = 0.030
SWEP.Primary.Time      = 5.500

SWEP.Secondary.Automatic = true

function SWEP:Deploy()

	if SERVER then
	
		self.Owner:DrawWorldModel( false )
		
	end

	return true
	
end  

function SWEP:Think()

	if CLIENT then return end
	
	if self.FireTime and self.FireTime < CurTime() then
	
		self.FireTime = nil
	
		self.Weapon:SetNWBool( "CanShoot", false )
		self.Weapon:SetNextPrimaryFire( CurTime() + 1.0 )
		
		self.Owner:EmitSound( self.Disable )
	
	end

end

function SWEP:CreateBullets( scale, dmg, num )

	if not IsValid( self.Owner.Scanner ) then return end

    local bullet = {}

    bullet.Num         = num
    bullet.Src         = self.Owner:GetShootPos()
    bullet.Dir         = self.Owner:GetAimVector()
    bullet.Spread      = Vector( scale, scale, 0 )
    bullet.Tracer      = 0
    bullet.Force       = math.Round( dmg * 1.5 )
    bullet.Damage      = dmg
    bullet.AmmoType    = "Pistol"
    bullet.TracerName  = "Tracer"
    bullet.Callback = function ( attacker, tr, dmginfo )
	
        self:BulletCallback( attacker, tr, dmginfo, 0 )
		
		if SERVER and IsValid( attacker ) and IsValid( attacker.Scanner ) then
		
			local edata = EffectData()
			edata:SetStart( attacker.Scanner:GetShootPos() )
			edata:SetOrigin( tr.HitPos )
			edata:SetNormal( tr.HitNormal )
			edata:SetEntity( self.Owner )
			
			util.Effect( "laser_tracer", edata, true, true )
			
		end
		
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

function SWEP:PrimaryAttack()

	if self.Weapon:GetNWBool( "CanShoot", false ) then
	
		self.Weapon:CreateBullets( self.Primary.Cone, self.Primary.Damage, 1 )
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self.Weapon:EmitSound( self.Shoot, 100, 180 )
	
		return
		
	end

	if CLIENT then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + 4.0 )
	
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 5000
	trace.filter = { self.Owner, self.Owner.Scanner }
	
	local tr = util.TraceLine( trace )
	
	local trhull = {}
	trhull.start = self.Owner:GetShootPos()
	trhull.endpos = trhull.start + self.Owner:GetAimVector() * 5000
	trhull.filter = { self.Owner, self.Owner.Scanner }
	trhull.mask = MASK_SHOT_HULL
	trhull.mins = Vector(-15,-15,-15)
	trhull.maxs = Vector(15,15,15)

	local tr2 = util.TraceHull( trhull )
	
	if not IsValid( tr.Entity ) then
	
		tr.Entity = tr2.Entity
	
	end

	if IsValid( tr.Entity ) and tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_STALKER then

		self.Owner:EmitSound( self.Alert, 100, 180 )
		self.Owner:EmitSound( self.Enable )
		
		self.Weapon:SetNWBool( "CanShoot", true )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 )
		
		self.FireTime = CurTime() + self.Primary.Time
		
		if IsValid( self.Owner.Scanner ) then
		
			self.Owner.Scanner:TargetEnemy( tr.Entity )
		
		end
	
	else
	
		self.Owner:EmitSound( self.Scan, 50 )
		
	end
	
end

function SWEP:SecondaryAttack()

	if CLIENT then return end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 5.0 )
	
	self.Owner:EmitSound( self.Ping, 100, math.random( 110, 130 ) )
	
	net.Start( "Scanner" )
	net.Send( self.Owner )

end

if SERVER then return end

SWEP.CrossMat = surface.GetTextureID( "stalker/scream" )
SWEP.Rot = 0

function SWEP:DrawHUD()

	surface.SetDrawColor( 255, 255, 255, 10 )
	
	if self.Weapon:GetNWBool( "CanShoot", false ) then
	
		surface.SetDrawColor( 255, 0, 0, 50 )
		
		self.Rot = self.Rot + FrameTime() * 500
		
		if self.Rot > 360 then
		
			self.Rot = 360 - self.Rot
		
		end
	
	else
	
		self.Rot = math.Approach( self.Rot, 0, FrameTime() * 250 )
	
	end

	surface.SetTexture( self.CrossMat )
	surface.DrawTexturedRectRotated( ScrW() / 2, ScrH() / 2, 40, 40, self.Rot )

end