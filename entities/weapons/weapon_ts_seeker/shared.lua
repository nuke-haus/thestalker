if SERVER then

	AddCSLuaFile( "shared.lua" )

end

if CLIENT then
	
	SWEP.PrintName = "Seeker Drone"
	SWEP.Slot = 1
	SWEP.Slotpos = 1
	
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55
	
	SWEP.IconLetter = "Q"

end

SWEP.Base = "ts_base"

SWEP.HoldType = "slam"

SWEP.UseHands = true

SWEP.ViewModel			= "models/weapons/c_bugbait.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"
SWEP.ModelName          = "models/dav0r/hoverball.mdl"

SWEP.Primary.Throw          = Sound( "weapons/slam/throw.wav" )
SWEP.Primary.Delay			= 0.800
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Automatic		= false

function SWEP:ResetBones( vm )

	if not vm:GetBoneCount() then return end
		
	for i=0, vm:GetBoneCount() do
		
		vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
		vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
		vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
			
	end
	
end

function SWEP:AttachProp()

	self.Weapon:RemoveProp()
	
	local vm = self.Owner:GetViewModel()
	
	if IsValid( vm ) then

		self.Prop = ClientsideModel( "models/dav0r/hoverball.mdl", RENDER_GROUP_VIEW_MODEL_OPAQUE )
		self.Prop:SetModelScale( 0.42, 0 )
		self.Prop:SetPos( self.Owner:GetShootPos() + self.Owner:GetAimVector() * -10 )
		self.Prop:SetParent( vm )
		self.Prop:SetNoDraw( true )
		
	end

end

function SWEP:RemoveProp()

	if IsValid( self.Prop ) then
	
		self.Prop:Remove()
		self.Prop = nil
	
	end

end

function SWEP:ViewModelDrawn( vm )

	if not IsValid( self.Prop ) then return end
	
	bone = vm:LookupBone( "ValveBiped.Bip01_R_Hand" )
	local mat = vm:GetBoneMatrix( bone )
	
	local ang = Angle(0,0,0)
	local pos = Vector(0,0,0)
	
	if mat then
	
		pos = mat:GetTranslation()
		ang = mat:GetAngles()
		
	end
	
	self.Prop:SetPos( pos + ang:Forward() * 3.2 + ang:Right() * 3.7 + ang:Up() * 0.4 )
	self.Prop:DrawModel()

end

function SWEP:OnRemove()

	if SERVER then return end

	if IsValid( self.Owner ) then
	
		local vm = self.Owner:GetViewModel()
		
		if IsValid( vm ) then
		
			self.Weapon:ResetBones( vm ) 
			
		end
		
	end
	
	self.Weapon:RemoveProp()

end

function SWEP:Holster()

	if SERVER then return true end
	
	if IsValid( self.Owner ) then
	
		local vm = self.Owner:GetViewModel()
		
		if IsValid( vm ) then
		
			self.Weapon:ResetBones( vm ) 
			
		end
		
	end

	self.Weapon:RemoveProp()
	
	return true

end

function SWEP:Deploy()

	self.TossTime = nil
	
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	
	if CLIENT then
	
		self.Weapon:AttachProp()
	
	end
	
	return true
	
end  

function SWEP:PrimaryAttack()
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SendWeaponAnim( ACT_VM_HAULBACK )
	
	if CLIENT then return end
	
	self.TossTime = CurTime() + 0.200
	
end

function SWEP:Toss()

	local battery = math.min( self.Owner:GetInt( "Battery" ), 85 )

	local ent = ents.Create( "sent_seeker" )
	ent:SetPos( self.Owner:GetShootPos() + Vector(0,0,-15) )
	ent:SetPlayer( self.Owner )
	ent:SetAngles( self.Owner:GetAimVector():Angle() )
	ent:SetBattery( battery )
	ent:Spawn()
		
	self.Owner:AddInt( "Battery", battery * -1 )
	self.Owner:EmitSound( self.Primary.Throw, 80 )
	self.Owner:StripWeapon( "weapon_ts_seeker" )

end

function SWEP:Think()	

	if CLIENT then return end
	
	if self.TossTime and self.TossTime < CurTime() then
	
		self.Weapon:Toss()
	
	end

end

function SWEP:Reload()
	
end

