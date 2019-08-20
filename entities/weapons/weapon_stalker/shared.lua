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
	
	SWEP.PrintName = "Claws"
	SWEP.IconLetter = "C"
	SWEP.Slot = 0
	SWEP.Slotpos = 0
	
	SWEP.IconFont = "CSSelectIcons"
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		//draw.SimpleText( self.IconLetter, self.IconFont, x + wide/2, y + tall/2.5, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER )
	end
	
end

SWEP.ViewModel  = "models/zed/weapons/v_banshee.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.HoldType = "knife"

SWEP.Primary.Sound			= Sound( "weapons/knife/knife_slash2.wav" )
SWEP.Primary.Hit            = Sound( "npc/fast_zombie/claw_strike3.wav" )
SWEP.Primary.Damage			= 50
SWEP.Primary.HitForce       = 700
SWEP.Primary.Delay			= 1.000
SWEP.Primary.Automatic		= true

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1

SWEP.Secondary.Delay        = 1.500
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Secondary.Select       = Sound( "ui/buttonrollover.wav" )
SWEP.Secondary.Miss         = Sound( "ambient/atmosphere/cave_hit2.wav" )
SWEP.Secondary.Flay         = Sound( "ambient/levels/citadel/portal_beam_shoot6.wav" )
SWEP.Secondary.Scream       = Sound( "npc/stalker/go_alert2a.wav" )
SWEP.Secondary.Heal         = Sound( "npc/antlion_guard/growl_idle.wav" )
SWEP.Secondary.Tele         = Sound( "npc/turret_floor/active.wav" )
SWEP.Secondary.TeleShot     = Sound( "ambient/levels/citadel/portal_beam_shoot5.wav" )

SWEP.Mana = {}
SWEP.Mana.Scream = 25
SWEP.Mana.Flay = 50
SWEP.Mana.Psycho = 75
SWEP.Mana.Heal = 100

function SWEP:CanDrawLaser()

	return false

end

function SWEP:Initialize()

	self.Weapon:SetWeaponHoldType( self.HoldType )
	
end

function SWEP:Deploy()

	if SERVER then
	
		self.Owner:DrawWorldModel( false )
		
	end

	return true
	
end  

function SWEP:Holster()

	if SERVER then

		self.Owner:StopSound( self.Secondary.Heal )
	
	end
	
	return true

end

function SWEP:Think()	

	if CLIENT then return end

	self.Weapon:MenuThink()
	self.Weapon:HealThink()

end

function SWEP:MenuThink()

	if not self.Owner:KeyDown( IN_USE ) then
	
		self.Dragging = false
		
		return
	
	end
	
	if ( self.LastChange or 0 ) > CurTime() then return end
	
	self.Dragging = true
	
	local active = self.Owner:GetInt( "MenuChoice", 1 )
	local cmd = self.Owner:GetCurrentCommand()
	local x, y = cmd:GetMouseX(), cmd:GetMouseY()

	if x < 0 and y > 0 then
	
		active = 2
	
	elseif x < 0 and y < 0 then
	
		active = 1
	
	elseif x > 0 and y < 0 then
	
		active = 4
	
	elseif x > 0 and y > 0 then
	
		active = 3
	
	end
	
	if active != self.Owner:GetInt( "MenuChoice", 1 ) then
	
		self.LastChange = CurTime() + 0.2
		
		self.Owner:SetInt( "MenuChoice", active )
	
	end
	
end

function SWEP:Reload()
	
end

function SWEP:CanPrimaryAttack()

	return true
	
end

function SWEP:PrimaryAttack()

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self.Owner:LagCompensation(true)
	self.Weapon:MeleeTrace( self.Primary.Damage )
	self.Owner:LagCompensation(false)
	
end

function SWEP:MeleeTrace( dmg )
	
	if CLIENT then return end
	
	local pos = self.Owner:GetShootPos()
	local aim = self.Owner:GetAimVector() * 80
	
	local line = {}
	line.start = pos
	line.endpos = pos + aim
	line.filter = self.Owner
	
	local linetr = util.TraceLine( line )
	
	local tr = {}
	tr.start = pos + self.Owner:GetAimVector() * -5
	tr.endpos = pos + aim
	tr.filter = self.Owner
	tr.mask = MASK_SOLID
	tr.mins = Vector(-20,-20,-20)
	tr.maxs = Vector(20,20,20)

	local trace = util.TraceHull( tr )
	local ent = trace.Entity
	local ent2 = linetr.Entity
	
	if not IsValid( ent ) and IsValid( ent2 ) then
	
		ent = ent2
	
	end

	if not IsValid( ent ) then 
		
		self.Owner:EmitSound( self.Primary.Sound, 100, math.random(80,100) )
		
		return 
		
	else
	
		ent:EmitSound( self.Primary.Hit, 100, math.random(90,110) )
		
		if ent:IsPlayer() then 
		
			if self.RegenTime then
		
				if ent:Health() <= dmg + 10 then
				
					ent:TakeDamage( 100, self.Owner, self.Weapon )
					
					self.Owner:AddHealth( GetConVar( "sv_ts_stalker_blood_thirst" ):GetInt() + GetConVar( "sv_ts_stalker_blood_thirst_gib" ):GetInt() )
				
				else
		
					ent:TakeDamage( dmg + 10, self.Owner, self.Weapon )
					
					self.Owner:AddHealth( GetConVar( "sv_ts_stalker_blood_thirst" ):GetInt() )
					
				end
				
			else
			
				ent:TakeDamage( dmg, self.Owner, self.Weapon )
			
			end
			
		else
		
			ent:TakeDamage( dmg, self.Owner, self.Weapon )
		
			local phys = ent:GetPhysicsObject()
			
			if IsValid( phys ) then
			
				ent:SetPhysicsAttacker( self.Owner )
				phys:Wake()
				phys:ApplyForceCenter( self.Owner:GetAimVector() * phys:GetMass() * self.Primary.HitForce )
				
			end
			
			if ent:GetClass() == "prop_ragdoll" then
			
				self.Weapon:Gib( ent )
				
				if self.RegenTime then
				
					self.Owner:AddHealth( math.abs( GetConVar( "sv_ts_stalker_blood_thirst_gib" ):GetInt() ) )
					
				else
				
					self.Owner:AddHealth( math.abs( GetConVar( "sv_ts_stalker_gib_health" ):GetInt() ) )
				
				end
			
			elseif ent:GetClass() == "func_breakable_surf" then
				
				ent:Fire( "shatter", "1 1 1", 0 )
			
			elseif ent:GetClass() == "sent_tripmine" or ent:GetClass() == "sent_seeker" then
			
				ent:Malfunction()
			
			end
			
			return 
		
		end
		
	end

end

function SWEP:Gib( ent )

	//self.Owner:SetDrainTime( GetConVar( "sv_ts_stalker_drain_delay" ):GetInt() )

	local gibcount = 12

	if table.HasValue( GAMEMODE.GibCorpses, ent:GetModel() ) then
	
		gibcount = 15
	
	else

		local doll = ents.Create( "prop_ragdoll" )
		doll:SetModel( table.Random( GAMEMODE.GibCorpses ) )
		doll:SetPos( ent:GetPos() )
		doll:SetAngles( ent:GetAngles() )
		doll:Spawn()
		doll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		doll:SetMaterial( "models/flesh" )
		
		local dir = ( self.Owner:GetPos() - ent:GetPos() ):GetNormal()
		local phys = doll:GetPhysicsObject()
				
		if IsValid( phys ) then
				
			phys:AddAngleVelocity( VectorRand() * 2000 )
			phys:ApplyForceCenter( dir * math.random( 3000, 6000 ) )

		end	
		
	end
	
	local ed = EffectData()
	ed:SetOrigin( ent:LocalToWorld( ent:OBBCenter() ) )
	util.Effect( "gore_explosion", ed, true, true )
	
	for i=1, 12 do
	
		local trace = {}
		trace.start = ent:GetPos()
		trace.endpos = trace.start + VectorRand() * math.random( 5, 15 )
		trace.mask = MASK_NPCWORLDSTATIC
		trace.filter = doll
		
		local tr = util.TraceLine( trace )
	
		local gib = ents.Create( "sent_giblet" )
		gib:SetPos( tr.HitPos + tr.HitNormal * 5 )
		
		if i < 6 then
		
			gib:SetModel( table.Random( GAMEMODE.BigGibs ) )
		
		else
		
			gib:SetModel( table.Random( GAMEMODE.SmallGibs ) )
			
		end
		
		gib:Spawn()
	
	end
	
	ent:Remove()

end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	if CLIENT then return end
	
	self.Weapon:DoSpecial( self.Owner:GetInt( "MenuChoice", 1 ) )

end

function SWEP:DoSpecial( num )

	if num == 1 then
		self.Weapon:Scream()
	elseif num == 2 then
		self.Weapon:Flay()
	elseif num == 3 then
		self.Weapon:Tele()
	else
		self.Weapon:Heal()
	end

end

function SWEP:TeleProp( ent )

	ent.Tele = true

	local psy = ents.Create( "sent_tele" )
	psy:SetOwner( self.Owner )
	psy:SetAngles( ent:GetAngles() )
	
	if ent:GetClass() == "prop_ragdoll" then
	
		psy:SetCollides( true )
		psy:SetTrueParent( ent )
		psy:SetPos( ent:LocalToWorld( ent:OBBCenter() ) )
		psy:SetModel( "models/props_junk/propanecanister001a.mdl" )
	
	else
	
		psy:SetParent( ent )
		psy:SetModel( ent:GetModel() )
		psy:SetPos( ent:GetPos() )
		
	end
		
	local phys = ent:GetPhysicsObject()
		
	if IsValid( phys ) then
		
		psy:SetMass( math.Clamp( phys:GetMass(), 100, 5000 ) )
		psy:SetPhysMat( phys:GetMaterial() )
		
	end
	
	psy:Spawn()
	
	self.Weapon.Prop = psy	
	
	self.Owner:AddInt( "Mana", -self.Mana.Psycho )
	self.Owner:EmitSound( self.Secondary.Tele, 50 )
	
	net.Start( "Flay" )
	net.Send( self.Owner )

end

function SWEP:CanTele( ent, phys )

	if ( string.find( ent:GetClass(), "prop_phys" ) or ent:GetClass() == "prop_ragdoll" ) and not IsValid( ent:GetParent() ) then 
	
		if IsValid( phys ) and phys:IsMotionEnabled() and phys:IsMoveable() then
		
			return true
		
		end
	
	end

end

function SWEP:Tele()
	
	local tr = util.TraceLine( util.GetPlayerTrace( self.Owner ) )
	
	if IsValid( self.Weapon.Prop ) then
	
		self.Weapon.Prop:EmitSound( self.Secondary.TeleShot, 100, math.random( 100, 120 ) )
		self.Weapon.Prop:SetLaunchTarget( tr.HitPos )
		self.Weapon.Prop = nil
	
		return
	
	end
	
	if self.Owner:GetInt( "Mana" ) < self.Mana.Psycho then
	
		self.Owner:EmitSound( self.Secondary.Miss, 40, 250 )
		
		return
	
	end
	
	local phys = tr.Entity:GetPhysicsObject()

	if IsValid( tr.Entity ) and IsValid( phys ) and self.Weapon:CanTele( tr.Entity, phys ) then
	
		self.Weapon:TeleProp( tr.Entity )
		
	else
	
		local dist = 250
		local ent
		local tbl = ents.FindByClass( "prop_phys*" )
		tbl = table.Add( tbl, ents.FindByClass( "prop_ragdoll" ) )
	
		for k,v in pairs( tbl ) do
			
			local phys = v:GetPhysicsObject()
			
			if v:GetPos():Distance( tr.HitPos ) < dist and not IsValid( v:GetParent() ) and self.Weapon:CanTele( v, phys ) then
			
				ent = v
				dist = v:GetPos():Distance( tr.HitPos )
				
			end
			
		end
		
		if IsValid( ent ) then
			
			self.Weapon:TeleProp( ent )
			
			return
		
		end
		
		self.Owner:EmitSound( self.Secondary.Miss, 50, 250 )
	
	end

end

function SWEP:Heal()

	if self.Owner:GetInt( "Mana" ) < self.Mana.Heal then
	
		self.Owner:EmitSound( self.Secondary.Miss, 40, 250 )
		
		return
	
	end
	
	local hp = ( ( self.Owner.MaxHealth or 100 ) - self.Owner:Health() ) * 0.20
	
	self.Owner:SetDrainTime( sv_ts_stalker_drain_delay:GetInt() )
	self.Owner:AddInt( "Mana", -self.Mana.Heal )
	self.Owner:SetInt( "Thirst", 1 )
	self.Owner:SetInt( "StalkerEsp", 0 )
	
	local sound = CreateSound( self.Owner, self.Secondary.Heal )
	sound:PlayEx( 0.3, 150 )
	
	self.HealSound = sound
	self.RegenTime = CurTime() + 10

end

function SWEP:HealThink()

	if self.RegenTime and self.RegenTime < CurTime() then
	
		self.RegenTime = nil
		
		self.Owner:SetInt( "Thirst", 0 )
	
		if self.HealSound then
	
			self.HealSound:Stop()
			self.HealSound = nil
			
		end
	
	end

end

function SWEP:Scream()

	if self.Owner:GetInt( "Mana" ) < self.Mana.Scream then
	
		self.Owner:EmitSound( self.Secondary.Miss, 40, 250 )
		
		return
	
	end
	
	self.Owner:EmitSound( self.Secondary.Scream, 100, 90 )
	self.Owner:AddInt( "Mana", -self.Mana.Scream )

	for k,v in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
	
		if v:GetPos():Distance( self.Owner:GetPos() ) < 500 then
		
			util.BlastDamage( self.Owner, self.Owner, v:GetPos(), 5, 5 )
			
			local ed = EffectData()
			ed:SetOrigin( v:GetPos() )
			util.Effect( "scream_hit", ed, true, true )
			
		end
		
	end
	
	local tbl = ents.FindByClass( "sent_tripmine" )
	tbl = table.Add( tbl, ents.FindByClass( "sent_seeker" ) )
	
	for k,v in pairs( tbl ) do
	
		if v:GetPos():Distance( self.Owner:GetPos() ) < 350 then
		
			v:Malfunction()
		
		end
	
	end

end

function SWEP:Flay()

	if self.Owner:GetInt( "Mana" ) < self.Mana.Flay then
	
		self.Owner:EmitSound( self.Secondary.Miss, 40, 250 )
		
		return
	
	end

	local tr = util.TraceLine( util.GetPlayerTrace( self.Owner ) )

	if IsValid( tr.Entity ) and tr.Entity:IsPlayer() and tr.Entity:CanFlay() then
	
		tr.Entity:Flay( self.Owner )
		self.Owner:AddInt( "Mana", -self.Mana.Flay )
		self.Owner:EmitSound( self.Secondary.Flay, 100, 150 )
		
	else
	
		local dist = 250
		local ply
	
		for k,v in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
		
			if v:GetPos():Distance( tr.HitPos ) < dist and v:Alive() then
			
				ply = v
				dist = v:GetPos():Distance( tr.HitPos )
				
			end
			
		end
		
		if IsValid( ply ) and ply:CanFlay() then
		
			ply:Flay( self.Owner )
			self.Owner:AddInt( "Mana", -self.Mana.Flay )
			self.Owner:EmitSound( self.Secondary.Flay, 100, 150 )
			
			return 
		
		end
		
		self.Owner:EmitSound( self.Secondary.Miss, 50, 250 )
	
	end

end

if SERVER then return end

SWEP.Crosshair = surface.GetTextureID( "effects/select_ring" )

SWEP.DrawTable = {}
SWEP.DrawTable[1] = {}
SWEP.DrawTable[2] = {}
SWEP.DrawTable[3] = {}
SWEP.DrawTable[4] = {}

SWEP.DrawTable[1].Selected = {ScrW() / 2 - 200, ScrH() / 2 - 200, 200, 200}
SWEP.DrawTable[1].DeSelected = {ScrW() / 2 - 100, ScrH() / 2 - 100, 100, 100}
SWEP.DrawTable[1].Mat = surface.GetTextureID( "stalker/scream" )
SWEP.DrawTable[1].Desc = {"SCREAM", "Disorient nearby enemies and cause electronics to temporarily malfunction.", "Requires 25% of your energy."}
SWEP.DrawTable[1].Mana = 25

SWEP.DrawTable[2].Selected = {ScrW() / 2 - 200, ScrH() / 2, 200, 200}
SWEP.DrawTable[2].DeSelected = {ScrW() / 2 - 100, ScrH() / 2, 100, 100}
SWEP.DrawTable[2].Mat = surface.GetTextureID( "stalker/flay" )
SWEP.DrawTable[2].Desc = {"MIND FLAY", "Invade an enemy's mind with psionic waves and disrupt their senses.", "Requires 50% of your energy."}
SWEP.DrawTable[2].Mana = 50

SWEP.DrawTable[3].Selected = {ScrW() / 2, ScrH() / 2, 200, 200}
SWEP.DrawTable[3].DeSelected = {ScrW() / 2, ScrH() / 2, 100, 100}
SWEP.DrawTable[3].Mat = surface.GetTextureID( "stalker/psycho" )
SWEP.DrawTable[3].Desc = {"TELEKINESIS", "Turn a corpse or an inanimate object into a violent weapon.", "Requires 75% of your energy."}
SWEP.DrawTable[3].Mana = 75

SWEP.DrawTable[4].Selected = {ScrW() / 2, ScrH() / 2 - 200, 200, 200}
SWEP.DrawTable[4].DeSelected = {ScrW() / 2, ScrH() / 2 - 100, 100, 100}
SWEP.DrawTable[4].Mat = surface.GetTextureID( "stalker/regen" )
SWEP.DrawTable[4].Desc = {"BLOOD THIRST", "Regenerate health through your attacks for a short duration.", "Requires 100% of your energy."}
SWEP.DrawTable[4].Mana = 100

function SWEP:FreezeMovement()

    return self.Owner:KeyDown( IN_USE )

end

function SWEP:DrawHUD()

	draw.TexturedQuad{
        texture = self.Crosshair,
        color = Color(255, 255, 255, 30),
        x = ScrW() * 0.5 - 10,
        y = ScrH() * 0.5 - 10,
        w = 20,
        h = 20 }

	if self.Owner:KeyDown( IN_USE ) then
		
		for i=1,4 do
		
			surface.SetTexture( self.DrawTable[i].Mat )
			
			if GAMEMODE:GetInt( "Mana" ) >= self.DrawTable[i].Mana then
			
				surface.SetDrawColor( 50, 255, 50, 150 )
				
			else
			
				surface.SetDrawColor( 255, 50, 50, 150 )
				
			end
			
			if GAMEMODE:GetInt( "MenuChoice", 1 ) == i then
			
				surface.DrawTexturedRect( unpack( self.DrawTable[i].Selected ) )
				
			else
			
				surface.DrawTexturedRect( unpack( self.DrawTable[i].DeSelected ) )
				
			end
			
		end
		
		for k,v in pairs( self.DrawTable[ GAMEMODE:GetInt( "MenuChoice", 1 ) ].Desc ) do 
		
			draw.SimpleTextOutlined( v, "InfoText", ScrW() / 2, ScrH() / 8 + k * 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10,10,10,255) )
			
		end
		
		--[[if not self.FirstNotice then
		
			draw.SimpleTextOutlined( "Left click or right click to select an ability.", "InfoText", ScrW() / 2, ScrH() - 100, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10,10,10,255) )
			draw.SimpleTextOutlined( "Press your ALT key to toggle this menu.", "InfoText", ScrW() / 2, ScrH() - 75, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(10,10,10,255) )
			
		end]]
		
	else
	
		if GAMEMODE:GetInt( "Mana" ) >= self.DrawTable[ GAMEMODE:GetInt( "MenuChoice", 1 ) ].Mana then
		
			surface.SetDrawColor( 50, 255, 50, 100 )
			
		else
		
			surface.SetDrawColor( 255, 50, 50, 100 )
			
		end
	
		surface.SetTexture( self.DrawTable[ GAMEMODE:GetInt( "MenuChoice", 1 ) ].Mat )
		surface.DrawTexturedRect( ScrW() / 2 - 25, ScrH() - 75, 50, 50 )
	
	end
	
end
