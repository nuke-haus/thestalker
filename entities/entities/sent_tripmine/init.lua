
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Alarm = Sound( "npc/attack_helicopter/aheli_megabomb_siren1.wav" )
ENT.Beep = Sound( "npc/scanner/scanner_scan2.wav" )
ENT.Beep2 = Sound( "npc/turret_floor/ping.wav" )
ENT.Ignore = Sound( "npc/scanner/scanner_scan4.wav" )
ENT.Click = Sound( "weapons/smg1/switch_single.wav" )
ENT.Damaged = { Sound( "npc/scanner/scanner_pain1.wav" ), Sound( "npc/scanner/scanner_pain2.wav" ) }

function ENT:Initialize()

	self.Entity:SetModel( "models/weapons/w_slam.mdl" )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:DrawShadow( false )
	
	self.ActivateTime = CurTime() + 5
	self.PingTime = CurTime() + 0.5
	
end

function ENT:Think()

	if self.ActivateTime and self.ActivateTime < CurTime() then
	
		self.ActivateTime = nil
		
		self.Entity:StartUp()
	
	end
	
	if self.PingTime and self.PingTime < CurTime() then
	
		self.PingTime = nil
		
		self.Entity:EmitSound( self.Beep2, 60 )
	
	end

	if self.AlarmTimer and self.AlarmTimer < CurTime() then
	
		self.AlarmTimer = nil
	
	end
	
	if self.BrokenTimer and self.BrokenTimer < CurTime() then
	
		self.BrokenTimer = CurTime() + 0.5
		
		self.Entity:EmitSound( self.Beep2, 60 )
	
	end

end

function ENT:SetPlayer( ply )

	self.Player = ply

end

function ENT:DoUse( ply, caller )

	self.Entity:Use( ply, caller, 1, 1 )
	
end

function ENT:Use( ply, caller )

	if IsValid( self.Player ) and self.Player == ply and not self.Removed then
	
		self.Removed = true
	
		ply:Give( "weapon_ts_tripmine" )
		//ply:SelectWeapon( "weapon_ts_tripmine" )
		
		self.Entity:EmitSound( self.Click, 50, math.random( 90, 110 ) )
		self.Entity:Remove()
	
	end

end

function ENT:StartUp()

	if self.BrokenTimer then return end

	self.Entity:EmitSound( self.Beep, 80, 250 )

	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + ( self.Entity:GetAngles() + Angle( -90, 0, 0 ) ):Forward() * 5000
	trace.filter = self.Entity
	trace.mask = MASK_NPCWORLDSTATIC
	
	local tr = util.TraceLine( trace )

	local ent = ents.Create( "sent_tripmine_laser" )
	ent:SetPos( self.Entity:GetPos() + self.Entity:GetRight() * -3 + self.Entity:GetForward() + self.Entity:GetUp() * 0.7 )
	ent:Spawn()
	ent:SetEndPos( tr.HitPos )	
	ent:SetParent( self.Entity )
	
	self.Laser = ent

end

function ENT:Malfunction() 

	if IsValid( self.Laser ) then
	
		self.Laser:Remove()
	
	end
	
	self.BrokenTimer = CurTime() + 1
	
	self.Entity:EmitSound( table.Random( self.Damaged ), 100, math.random( 90, 110 ) )

end

function ENT:OnRemove()

	if IsValid( self.Laser ) then
	
		self.Laser:Remove()
	
	end

end

function ENT:DoAlarm( enemy, damaged, override )

	if self.AlarmTimer and not override then return end
	
	if enemy then

		self.AlarmTimer = CurTime() + 3
	
		self.Entity:EmitSound( self.Alarm, 120, 180 )
		
	elseif damaged then
	
		self.AlarmTimer = CurTime() + 3
	
		self.Entity:EmitSound( table.Random( self.Damaged ), 100, math.random( 90, 110 ) )
	
	else
	
		self.AlarmTimer = CurTime() + 1.0
	
		self.Entity:EmitSound( self.Ignore )
	
	end

end

function ENT:OnTakeDamage( dmginfo )
	
	self.Entity:DoAlarm( false, true, true )
	
end

