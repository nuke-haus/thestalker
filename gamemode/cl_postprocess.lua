
Sharpen = 0
MotionBlur = 0
ViewWobble = 0
TrueViewWobble = 0
DisorientTime = 0
AdrenalineTime = 0
DrainTime = 0

ColorModify = {}
ColorModify[ "$pp_colour_addr" ] 		= 0
ColorModify[ "$pp_colour_addg" ] 		= 0
ColorModify[ "$pp_colour_addb" ] 		= 0
ColorModify[ "$pp_colour_brightness" ] 	= 0
ColorModify[ "$pp_colour_contrast" ] 	= 1
ColorModify[ "$pp_colour_colour" ] 		= 1
ColorModify[ "$pp_colour_mulr" ] 		= 0
ColorModify[ "$pp_colour_mulg" ] 		= 1
ColorModify[ "$pp_colour_mulb" ] 		= 1

GM.HighlightProps = { "prop_physics",
"prop_physics_override",
"prop_physics_respawnable",
"prop_ragdoll" }

GM.ViewDist = 0
GM.HitPos = Vector(0,0,0)

function GM:RenderScreenspaceEffects()

	GAMEMODE:DoTrace()
	GAMEMODE:ColorModInternal()
	GAMEMODE:RenderLaser()
	GAMEMODE:DrawLights()

end

function GM:ColorModInternal()

	if Sharpen > 0 then
	
		DrawSharpen( Sharpen, 0.5 )
		
		Sharpen = math.Approach( Sharpen, 0, FrameTime() * 0.5 )
		
	end

	if MotionBlur > 0 then
	
		DrawMotionBlur( 1 - MotionBlur, 1, 0 )
		
		MotionBlur = math.Approach( MotionBlur, 0, FrameTime() * 0.03 )
		
	end
	
	local approach = FrameTime() * 0.2
	
	ColorModify[ "$pp_colour_mulr" ] 		= math.Approach( ColorModify[ "$pp_colour_mulr" ], 0, approach )
	ColorModify[ "$pp_colour_mulg" ]		= math.Approach( ColorModify[ "$pp_colour_mulg" ], 0, approach )
	ColorModify[ "$pp_colour_mulb" ] 		= math.Approach( ColorModify[ "$pp_colour_mulb" ], 0, approach )
	ColorModify[ "$pp_colour_colour" ] 		= math.Approach( ColorModify[ "$pp_colour_colour" ], 1, approach * 1.5 )
	ColorModify[ "$pp_colour_contrast" ] 	= math.Approach( ColorModify[ "$pp_colour_contrast" ], 1, approach )
	ColorModify[ "$pp_colour_brightness" ] 	= math.Approach( ColorModify[ "$pp_colour_brightness" ], 0, approach )
	ColorModify[ "$pp_colour_addr" ] 		= math.Approach( ColorModify[ "$pp_colour_addr" ], 0, approach )
	ColorModify[ "$pp_colour_addg" ] 		= math.Approach( ColorModify[ "$pp_colour_addg" ], 0, approach )
	ColorModify[ "$pp_colour_addb" ] 		= math.Approach( ColorModify[ "$pp_colour_addb" ], 0, approach )
	
	if LocalPlayer():Team() == TEAM_STALKER then 
	
		if LocalPlayer():Alive() then
		
			ColorModify[ "$pp_colour_addr" ]		= .10
			ColorModify[ "$pp_colour_addg" ]		= .05
			
			if tobool( GAMEMODE:GetInt( "StalkerEsp", 0 ) ) then
			
				ColorModify[ "$pp_colour_mulr" ] 		= 0.35
				ColorModify[ "$pp_colour_mulg" ] 		= 0.20
				ColorModify[ "$pp_colour_brightness" ] 	= -0.15
				ColorModify[ "$pp_colour_contrast" ]	= 1.0
			
			else
			
				ColorModify[ "$pp_colour_mulr" ] 		=  0.25
				ColorModify[ "$pp_colour_mulg" ] 		=  0.05
				ColorModify[ "$pp_colour_brightness" ] 	= -0.05
				ColorModify[ "$pp_colour_contrast" ]	=  1.45
				
			end
			
			if DrainTime < CurTime() then
			
				Sharpen = math.Approach( Sharpen, 2.5, FrameTime() * 0.8 )
				
				ColorModify[ "$pp_colour_mulr" ] 		= 0.70
				
			end
			
		else
		
			// dead stalker
			
			ColorModify[ "$pp_colour_brightness" ] 	= -0.20
			ColorModify[ "$pp_colour_addr" ]		=  0.25
			ColorModify[ "$pp_colour_mulr" ] 		=  0.30
			ColorModify[ "$pp_colour_addg" ]		=  0.05
			
		end
		
	else
	
		local wep = LocalPlayer():GetActiveWeapon()
		
		if IsValid( wep ) and wep:GetClass() == "weapon_ts_scanner" then
		
			ColorModify[ "$pp_colour_mulr" ] 		= -1.10
			ColorModify[ "$pp_colour_mulg" ] 		= -1.10
			ColorModify[ "$pp_colour_mulb" ] 		=  1.70
			
			ColorModify[ "$pp_colour_addr" ] 		= -0.10
			ColorModify[ "$pp_colour_addg" ] 		= -0.10
			ColorModify[ "$pp_colour_addb" ] 		=  0
			
			ColorModify[ "$pp_colour_brightness" ] 	=  0.20
			
			GAMEMODE:DrawStalker( ColorModify[ "$pp_colour_contrast" ] - 1.2 )
		
		elseif IsValid( wep ) and wep:GetClass() == "weapon_ts_spec_scanner" then
		
			ColorModify[ "$pp_colour_mulg" ] 		= -1.20
			
			ColorModify[ "$pp_colour_addr" ] 		= -0.05
			ColorModify[ "$pp_colour_addg" ] 		= -0.05
		
			GAMEMODE:DrawStalker( ColorModify[ "$pp_colour_contrast" ] - 1.6 )
		
		end
		
		if not LocalPlayer():Alive() and LocalPlayer():Team() == TEAM_SPECTATOR then
		
			ColorModify[ "$pp_colour_brightness" ] 	= -0.05
			ColorModify[ "$pp_colour_contrast" ]    =  0.95
			ColorModify[ "$pp_colour_addr" ]		=  0.05
		
		end
	
	end
	
	DrawColorModify( ColorModify )

end

net.Receive( "Flay", function( len )

	if LocalPlayer():Team() == TEAM_HUMAN then
	
		DisorientTime = CurTime() + 20
		ViewWobble = 7.5
		MotionBlur = 0.9
		Sharpen = 4.5
		ColorModify[ "$pp_colour_mulg" ]   =  3.5
		ColorModify[ "$pp_colour_mulr" ]   =  4.5
		ColorModify[ "$pp_colour_addr" ]   =  0.2
		ColorModify[ "$pp_colour_addg" ]   =  0.1
		ColorModify[ "$pp_colour_colour" ] = -3.0
	
	else
	
		//ViewWobble = 2.5
		Sharpen = 2.5
		MotionBlur = 0.5
		ColorModify[ "$pp_colour_colour" ] = -1.2
	
	end

end )

net.Receive( "Scanner", function( len )

	ColorModify[ "$pp_colour_contrast" ] = 1.80
	Sharpen = 3.5
	
	if LocalPlayer():Team() == TEAM_SPECTATOR then
	
		ColorModify[ "$pp_colour_contrast" ] =  2.30
		
		ColorModify[ "$pp_colour_mulb" ] 	 =  2.10
		ColorModify[ "$pp_colour_mulr" ] 	 = -1.50
	
	end

end )

net.Receive( "Stim", function( len )

	local snd = table.Random( GAMEMODE.AutoMedic )

	LocalPlayer():EmitSound( snd, 100, 100 )

	AdrenalineTime = CurTime() + 12

	ColorModify[ "$pp_colour_contrast" ] =  1.20
	ColorModify[ "$pp_colour_mulr" ]     =  1.20
	MotionBlur = 0.8
	Sharpen = 3.5

end )

VisionMat = Material( "stalker/vision" )

function GM:DrawStalker( amt )

	local ang = Angle( 0, math.Rand( -0.2, 0.2 ), math.Rand( -0.05, 0.05 ) )

	cam.Start3D( EyePos() + ( EyeAngles():Forward() * math.Rand( -1.2, 1.2 ) ), EyeAngles() + ang )
	
	for k,v in pairs( team.GetPlayers( TEAM_STALKER ) ) do
		
		if v:Alive() and amt > 0 then
			
			local scale = ( 0.95 - ( math.Clamp( v:GetPos():Distance( LocalPlayer():GetPos() ), 0, 1500 ) / 1500 ) ) * amt

			render.SuppressEngineLighting( true )
			render.SetBlend( scale )
			
			render.MaterialOverride( VisionMat )
			render.SetColorModulation( 1.0, 0.2, 0 )
			
			cam.IgnoreZ( false )
	 
			v:SetupBones()
			v:DrawModel()
	 
			render.SuppressEngineLighting( false )
			render.SetColorModulation( 1, 1, 1 )
			render.SetBlend( 1.0 )
			
			render.MaterialOverride( 0 )

		end
		
	end
	
	cam.End3D()

end

LightMat = Material( "sprites/light_ignorez" )
BeamMat	= Material( "effects/lamp_beam" )

function GM:DrawLights()

	for k,v in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
	
		if not v.PixVis then
		
			v.PixVis = util.GetPixelVisibleHandle()
		
		end
		
		if v:GetNWBool( "Flashlight", false ) and v != LocalPlayer() then
	
			local id = v:LookupAttachment( "anim_attachment_LH" )
			local att = v:GetAttachment( id )
			
			if att then
			
				local vis = util.PixelVisible( att.Pos, 16, v.PixVis )
				
				local norm = ( att.Ang + Angle(0,90,0) ):Forward()
				local vnorm = ( att.Pos - EyePos() ):GetNormal()
				
				local dot = vnorm:Dot( norm * -1 )
				
				if dot > 0 and vis > 0 then
					
					local dist = math.Clamp( att.Pos:Distance( EyePos() ), 50, 500 )
					local size = math.Clamp( dist * dot, 2, 40 )
					
					local alpha = math.Clamp( ( 500 - dist ) * dot, 0, 255 )
					local col = Color( 255, 255, 200, alpha )
					
					cam.Start3D( EyePos(), EyeAngles() )
					
						render.SetMaterial( LightMat )
						
						render.DrawSprite( att.Pos, size, size, col )
						render.DrawSprite( att.Pos, size * 0.25, size * 0.25, Color( 255, 255, 255, alpha ) )
						
					cam.End3D()
					
				end
				
			end
			
		end
	
	end

end

ScannerMat = Material( "models/props_combine/stasisshield_sheet" )
SpeccyMat = Material( "effects/combine_binocoverlay" )

function GM:DrawScreenEffects()

	local wep = LocalPlayer():GetActiveWeapon()
		
	if IsValid( wep ) and wep:GetClass() == "weapon_ts_scanner" then

		render.UpdateScreenEffectTexture()

		ScannerMat:SetFloat( "$envmap", 0 )
		ScannerMat:SetFloat( "$alpha", 0.5 )
		ScannerMat:SetFloat( "$refractamount", 0.003 )
		ScannerMat:SetInt( "$ignorez", 1 )
		
		render.SetMaterial( ScannerMat )
		render.DrawScreenQuad()
		
	elseif IsValid( wep ) and wep:GetClass() == "weapon_ts_spec_scanner" then
	
		render.UpdateScreenEffectTexture()

		SpeccyMat:SetFloat( "$envmap", 0 )
		SpeccyMat:SetFloat( "$alpha", 0.5 )
		SpeccyMat:SetFloat( "$refractamount", 0.003 )
		SpeccyMat:SetInt( "$ignorez", 1 )
		
		render.SetMaterial( SpeccyMat )
		render.DrawScreenQuad()
	
	end

end

local matLaser = Material( "sprites/light_glow02_add" )
//local matBeam = Material( "sprites/bluelaser1" )

function GM:RenderLaser()

	local lp = LocalPlayer()
	
	for _, v in pairs( player.GetAll() ) do
	
		if v:Team() == TEAM_HUMAN and v:GetNWBool( "PickedLaser", false ) then

			local wep = v:GetActiveWeapon()
			
			if IsValid( wep ) and wep.CanDrawLaser then
			
				if wep:CanDrawLaser() then
				
					local look = ( v:EyeAngles() + v:GetPunchAngle() )
					local dir = look:Forward()
					--[[local vm = v:GetViewModel( 0 )
					
					if not IsValid( vm ) then break end
					
					local tbl = vm:GetAttachment( wep.LaserAttachment )
					//local lasforward
					
					--[[if v == lp or ( lp:GetObserverMode() == OBS_MODE_IN_EYE and lp:GetObserverTarget() == v ) then
					
						local ang = tbl.Ang or Angle()
						
						ang:RotateAroundAxis( look:Up(), wep.LaserOffset.p )
						ang:RotateAroundAxis( look:Forward(), wep.LaserOffset.r )
						ang:RotateAroundAxis( look:Right(), wep.LaserOffset.y )
						
						local forward = ang:Forward()
						//lasforward = tbl.Ang:Forward()
						
						forward = forward * wep.LaserScale
						
						dir = dir +	forward
						
					end]]
						
					local trace = {}
					trace.start = v:GetShootPos()
					
					trace.endpos = trace.start + dir * 9000
					trace.filter = { v, weap, lp }
					trace.mask = MASK_SOLID
					
					local tr = util.TraceLine( trace )
											
					local dist = math.Clamp( tr.HitPos:Distance( EyePos() ), 0, 500 )
					local size = math.Rand( 2, 4 ) + ( dist / 500 ) * 6
					local col = Color( 255, 0, 0, 255 )
					
					if v == lp and IsValid( GAMEMODE.TargetEnt ) and GAMEMODE.TargetEnt:IsPlayer() and GAMEMODE.TargetEnt:Team() == TEAM_HUMAN then
					
						size = size + math.Rand( 0.5, 2.0 ) 
						
					elseif v != lp then
					
						size = math.Rand( 0, 1 ) + ( dist / 500 ) * 6
					
					end
						
					cam.Start3D( EyePos(), EyeAngles() )
					
						local norm = ( EyePos() - tr.HitPos ):GetNormal()
					
						render.SetMaterial( matLaser )
						render.DrawQuadEasy( tr.HitPos + norm * size, norm, size, size, col, 0 )
						
						--[[if v == lp then
							
							local start = tbl.Pos + ( lasforward * -5 ) + wep.LaserBeamOffset
							
							render.SetMaterial( matBeam )
									
							for i=0,254 do
									
								render.DrawBeam( start, start + dir * 0.1, 2, 0, 12, Color( 255, 0, 0, 255 - i ) )
										
								start = start + dir * 0.1
										
							end
							
						end]]
						
					cam.End3D()
				
				end
				
			end
			
		end
	
	end

end

function GM:DoTrace()

	local lp = LocalPlayer()
	
	if IsValid( lp ) then
	
		if lp:GetObserverMode() > OBS_MODE_NONE and lp:GetObserverMode() != OBS_MODE_ROAMING then
		
			GAMEMODE.TargetEnt = lp:GetObserverTarget()
			GAMEMODE.ViewDist = 0
			
			if IsValid( GAMEMODE.TargetEnt ) then
			
				GAMEMODE.HitPos = GAMEMODE.TargetEnt:GetPos()
				
			end
			
			return
			
		end
	
		local dir = ( lp:EyeAngles() + lp:GetPunchAngle() ):Forward()
		
		local trace = {}
		trace.start = lp:GetShootPos()
		trace.endpos = trace.start + dir * 9000
		trace.filter = { lp, lp:GetActiveWeapon(), lp:GetNetworkedEntity( "Scanner" ) }
		trace.mask = MASK_SHOT
		
		local tr = util.TraceLine( trace )
			
		GAMEMODE.ViewDist = tr.HitPos:Distance( EyePos() )
		GAMEMODE.HitPos = tr.HitPos
		GAMEMODE.TargetEnt = tr.Entity
		
	end

end

function GM:PreDrawHalos()

	if not GetGlobalBool( "InRound", false ) or not IsValid( GAMEMODE.TargetEnt ) or not LocalPlayer():Alive() then return end
	
	if LocalPlayer():Team() == TEAM_HUMAN or ( LocalPlayer():Team() == TEAM_SPECTATOR and LocalPlayer():Alive() ) then
	
		local dist = math.Clamp( GAMEMODE.ViewDist, 0, 800 )
		local scale = 1 - ( dist / 800 )
	
		if GAMEMODE.TargetEnt:IsPlayer() and GAMEMODE.TargetEnt:Team() == TEAM_HUMAN then
		
			local hp = math.Clamp( GAMEMODE.TargetEnt:Health(), 1, 100 )
			local sc = hp / 100
			
			halo.Add( { GAMEMODE.TargetEnt, GAMEMODE.TargetEnt:GetActiveWeapon() }, Color( 255 * ( 1 - sc ), 255 * sc, 100 * sc, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
			
		elseif GAMEMODE.TargetEnt:GetClass() == "sent_droppedgun" or GAMEMODE.TargetEnt:GetClass() == "sent_tripmine" or GAMEMODE.TargetEnt:GetClass() == "sent_scanner" or GAMEMODE.TargetEnt:GetClass() == "sent_seeker" then
		
			halo.Add( {GAMEMODE.TargetEnt}, Color( 0, 255, 100, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
		
		elseif GAMEMODE.TargetEnt:GetClass() == "prop_ragdoll" then
		
			halo.Add( {GAMEMODE.TargetEnt}, Color( 255, 0, 0, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
		
		end
		
	elseif LocalPlayer():Team() == TEAM_STALKER then
	
		local dist = math.Clamp( GAMEMODE.ViewDist, 0, 800 )
		local scale = 1 - ( dist / 800 )
		
		if GAMEMODE:GetInt( "MenuChoice" ) == 2 and GAMEMODE.TargetEnt:IsPlayer() and GAMEMODE.TargetEnt:Team() == TEAM_HUMAN then
			
			halo.Add( { GAMEMODE.TargetEnt, GAMEMODE.TargetEnt:GetActiveWeapon() }, Color( 255, 255, 255, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
		
		elseif table.HasValue( GAMEMODE.HighlightProps, GAMEMODE.TargetEnt:GetClass() ) then
		
			if GAMEMODE.TargetEnt:GetClass() == "prop_ragdoll" then
			
				halo.Add( {GAMEMODE.TargetEnt}, Color( 0, 255, 0, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
			
			elseif GAMEMODE.TargetEnt:GetClass() == "sent_scanner" then
			
				halo.Add( {GAMEMODE.TargetEnt}, Color( 255, 0, 0, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
			
			else
		
				halo.Add( {GAMEMODE.TargetEnt}, Color( 0, 200, 255, 255 * scale ), 2 * scale, 2 * scale, 1, 1, false )
				
			end
		
		end
	
	end

end

function GM:GetMotionBlurValues( y, x, fwd, spin ) 

	if LocalPlayer():Alive() and LocalPlayer():Health() <= 25 and LocalPlayer():Team() == TEAM_HUMAN then
	
		local scale = LocalPlayer():Health() / 25
		fwd = 0.5 - ( scale * 0.5 )
		ViewWobble = 0.5 - 0.5 * scale
		
	end
	
	if LocalPlayer():Alive() and LocalPlayer():Health() <= 50 and LocalPlayer():Team() == TEAM_STALKER then
	
		local scale = LocalPlayer():Health() / 50
		fwd = 1 - scale
		ViewWobble = 0.5 - 0.5 * scale
		
	end
	
	if DisorientTime > CurTime() then
	
		if not LocalPlayer():Alive() then 
		
			DisorientTime = 0
			
		end
	
		local scale = ( DisorientTime - CurTime() ) / 20
		local newx, newy = RotateAroundCoord( 0, 0, 1.0, scale * 0.05 )
		
		return newy, newx, fwd, spin
	
	end

	return y, x, fwd, spin

end

function RotateAroundCoord( x, y, speed, dist )

	local newx = x + math.sin( CurTime() * speed ) * dist
	local newy = y + math.cos( CurTime() * speed ) * dist

	return newx, newy

end

function GM:CalcView( ply, origin, angle, fov )

	local vel = ply:GetVelocity()
	local ang = ply:EyeAngles()
	
	ViewWobble = math.Approach( ViewWobble, 0, FrameTime() * 0.2 ) 
	TrueViewWobble = math.Approach( TrueViewWobble, ViewWobble, FrameTime() * 0.4 )
	
	if ViewWobble > 0 then
	
		angle.roll = angle.roll + math.sin( CurTime() + GAMEMODE:TimeSeed( 1, -2, 2 ) ) * TrueViewWobble
		angle.pitch = angle.pitch + math.sin( CurTime() + GAMEMODE:TimeSeed( 2, -2, 2 ) ) * TrueViewWobble
		angle.yaw = angle.yaw + math.sin( CurTime() + GAMEMODE:TimeSeed( 3, -2, 2 ) ) * TrueViewWobble
			
	end
		
	return self.BaseClass:CalcView( ply, origin, angle, fov )
	
end
