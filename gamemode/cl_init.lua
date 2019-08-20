
include( 'default_player.lua' )
include( 'tables.lua' )
include( 'shared.lua' )
include( 'cl_postprocess.lua' )
include( 'vgui_selectionbutton.lua' )
include( 'vgui_helpmenu.lua' )
include( 'cl_scoreboard.lua' )

GM.RadioNoiseTime = 0
GM.NextToggle = 0
GM.DisplayTime = 0
GM.PlayerData = {}
GM.TimeSeedTable = {}
GM.Elements = {}

CV_Loadout1 = CreateClientConVar( "ts_loadout_1", tostring( math.random( 1, 4 ) ), true, false )
CV_Loadout2 = CreateClientConVar( "ts_loadout_2", tostring( math.random( 1, 4 ) ), true, false )
CV_Loadout3 = CreateClientConVar( "ts_loadout_3", tostring( math.random( 1, 4 ) ), true, false )

function GM:CreateElement( name )

	local element = vgui.Create( name )
	
	table.insert( GAMEMODE.Elements, element )
	
	return element

end

function GM:ElementsVisible()

	return GAMEMODE.Elements[1]

end

function GM:ClearElements()

	for k,v in pairs( GAMEMODE.Elements ) do
	
		v:Remove()
		
	end
	
	GAMEMODE.Elements = {}

end

function GM:OpenMenu()

	for i=1,3 do
	
		for j=1,4 do
	
			local btn = GAMEMODE:CreateElement( "SelectionButton" )
			btn:SetPos( ScrW() * 0.5 + ( 300 * ( i - 2 ) ) - 125, 210 + j * 40 )
			btn:SetSize( 250, 30 )
			btn:SetText( GAMEMODE.ItemNames[i][j] or "HELLO" )
			btn:SetInt( i, j )
			
		end
	
	end

end

function GM:Initialize()

	surface.CreateFont( "HudTextSmall", { font = "Prototype", size = 20, weight = 450, antialias = 1 } )
	surface.CreateFont( "HudText", { font = "Prototype", size = 36, weight = 450, antialias = 1 } )
	surface.CreateFont( "HumanText", { font = "Prototype", size = 40, weight = 450, antialias = 1 } )
	surface.CreateFont( "HumanTextSm", { font = "Prototype", size = 20, weight = 400, antialias = 1 } )
	surface.CreateFont( "InfoText", { font = "Slippy", size = 28, weight = 450, antialias = 1 } )
	surface.CreateFont( "StalkerText", { font = "Slippy", size = 40, weight = 450, antialias = 1 } )
	surface.CreateFont( "Header", { font = "Tahoma", size = 12, weight = 450, antialias = 1 } )
	
	GAMEMODE.StalkerMat = Material( "sprites/heatwave" )
	
	RunConsoleCommand( "hud_fastswitch", 1 )
	
end

function GM:PlayerInit()

	if GAMEMODE.PlayerInitHappened then return end
	
	GAMEMODE.PlayerInitHappened = true

	for i=1, 3 do
	
		timer.Simple( 1, function() RunConsoleCommand( "ts_apply_loadout", i, GetConVar( "ts_loadout_" .. i ):GetInt(), 1 ) end )
		
		GAMEMODE.PlayerData[ "Loadout" .. i ] = math.Clamp( GetConVar( "ts_loadout_" .. i ):GetInt(), 1, 4 )
		
	end

end

function GM:ShowHelp()

	if IsValid( GAMEMODE.HelpFrame ) then return end
	
	self.HelpFrame = vgui.Create( "HelpMenu" )
	self.HelpFrame:SetSize( 415, 370 )
	self.HelpFrame:Center()
	self.HelpFrame:MakePopup()
	self.HelpFrame:SetKeyboardInputEnabled( false )
	
end

function GM:TimeSeed( num, min, max )
	
	if not GAMEMODE.TimeSeedTable[num] then 
	
		GAMEMODE.TimeSeedTable[num] = { Min = min, Max = max, Curr = min, Dest = min, Approach = 0.001 } 
		
	end
	
	return GAMEMODE.TimeSeedTable[num].Curr

end

function GM:AddDeathNotice( victim, inflictor, attacker )

end

function GM:PlayerBindPress( ply, bind, pressed )

	if not pressed or ply:IsFrozen() then return end
	
	if string.find( bind, "impulse 100" ) then

		if LocalPlayer():Team() == TEAM_STALKER then
		
			if GAMEMODE.NextToggle < CurTime() and not tobool( GAMEMODE:GetInt( "Thirst", 0 ) ) then
			
				GAMEMODE.NextToggle = CurTime() + 1
		
				RunConsoleCommand( "ts_toggle_esp" )
				
				if not tobool( GAMEMODE:GetInt( "StalkerEsp", 0 ) ) then
				
					LocalPlayer():EmitSound( "ambient/atmosphere/hole_hit5.wav", 100, 200 )
					
				else
				
					LocalPlayer():EmitSound( "ambient/atmosphere/cave_hit1.wav", 100, 150 )
					
				end
				
			end
			
		else
		
			RunConsoleCommand( "ts_toggle_light" )
		
			//GAMEMODE:ToggleLight( tobool( GAMEMODE:GetInt( "Light", 0 ) ) )
			
		end
		
	end
	
end

function GM:GoreRagdolls()

	local tbl = ents.FindByClass( "prop_ragdoll" )

	for k,v in pairs( tbl ) do
	
		if not v.Gore and table.HasValue( GAMEMODE.GibCorpses, string.lower( v:GetModel() ) ) then
		
			v.Gore = true
			v:SetMaterial( "models/flesh" )
		
		end
		
	end
	
end

function GM:RadioNoiseThink()

	if not IsValid( LocalPlayer() ) or LocalPlayer():Team() != TEAM_HUMAN or DisorientTime < CurTime() then return end
	
	if GAMEMODE.RadioNoiseTime < CurTime() then
	
		GAMEMODE.RadioNoiseTime = CurTime() + math.Rand( 0.5, 1.5 )
		
		sound.Play( table.Random( GAMEMODE.RadioBuzz ), LocalPlayer():GetPos(), 75, math.random( 90, 110 ), 0.3 )
	
	end

end

function GM:ForceMaterial()

	if GAMEMODE.StalkerMat then

		GAMEMODE.StalkerMat:SetInt( "$model", 1 )
		GAMEMODE.StalkerMat:SetInt( "$nofog", 1 )
		GAMEMODE.StalkerMat:SetInt( "$nodecal", 1 )
		GAMEMODE.StalkerMat:SetInt( "$bluramount", 1 )
		GAMEMODE.StalkerMat:SetInt( "$forcerefract", 1 )
		GAMEMODE.StalkerMat:SetFloat( "$refractamount", 0.0005 )
		GAMEMODE.StalkerMat:SetString( "$dudvmap", "effects/fisheyelens_dudv" )
		GAMEMODE.StalkerMat:SetString( "$normalmap", "effects/fisheyelens_normal" ) 
		
	end
	
	local vm = LocalPlayer():GetViewModel()
	
	if IsValid( vm ) then
	
		if not vm.Altered and LocalPlayer():Team() == TEAM_STALKER then
	
			vm.Altered = true
			vm:SetMaterial( "models/gibs/hgibs/scapula" )
		
		elseif vm.Altered and LocalPlayer():Team() != TEAM_STALKER then
		
			vm.Altered = false
			vm:SetMaterial( "" )
		
		end
	
	end

end

function GM:Think()

	GAMEMODE:ForceMaterial()
	GAMEMODE:GoreRagdolls()
	GAMEMODE:RadioNoiseThink()
	
	if GAMEMODE.DisplayTime > CurTime() then
	
		MotionBlur = 0
		ViewWobble = 0
		DisorientTime = 0
	
	end

	if not IsValid( LocalPlayer() ) then return end
	
	GAMEMODE:PlayerInit()
	
	for k,v in pairs( GAMEMODE.TimeSeedTable ) do
	
		if v.Curr != v.Dest then
		
			v.Curr = math.Approach( v.Curr, v.Dest, v.Approach )
		
		else
		
			v.Dest = math.Rand( v.Min, v.Max )
			v.Approach = math.Rand( 0.001, 0.01 )
		
		end
	
	end
	
	if ( LocalPlayer():Alive() and LocalPlayer():Health() <= 25 and ( HeartBeat or 0 ) < CurTime() ) and AdrenalineTime < CurTime() then
	
		local scale = math.Clamp( LocalPlayer():Health() / 25, 0, 1 )
		HeartBeat = CurTime() + 0.5 + scale * 1.5
		
		LocalPlayer():EmitSound( "nuke/heartbeat.wav", 50, 150 - scale * 50 )
		
	elseif AdrenalineTime > CurTime() and ( HeartBeat or 0 ) < CurTime() then
		
		local scale = 1 - ( math.Clamp( AdrenalineTime - CurTime(), 0, 10 ) / 10 )
		HeartBeat = CurTime() + 0.2 + ( 0.4 * scale )
		
		LocalPlayer():EmitSound( "nuke/heartbeat.wav", 50, 160 - scale * 20 )
	
	end

	if LocalPlayer():Team() == TEAM_STALKER then
	
		if GAMEMODE:ElementsVisible() then
	
			GAMEMODE:ClearElements()
			gui.EnableScreenClicker( false )
		
		end
		
		if GAMEMODE:GetInt( "Drain", 0 ) > 0 then
		
			DrainTime = CurTime() + GAMEMODE:GetInt( "Drain", 0 )
			
			GAMEMODE.PlayerData[ "Drain" ] = 0
		
		end
		
		if DrainTime < CurTime() and ( HeartBeat or 0 ) < CurTime() and LocalPlayer():Alive() then
			
			local scale = math.Clamp( LocalPlayer():Health() / 50, 0, 1 )
			HeartBeat = CurTime() + 0.5 + scale + 1.5
			
			LocalPlayer():EmitSound( "nuke/heartbeat.wav", 50, 150 - scale * 50 )
		
		end
	
		if tobool( GAMEMODE:GetInt( "StalkerEsp", 0 ) ) or tobool( GAMEMODE:GetInt( "Thirst", 0 ) ) then
		
			if not HumanEmitter then
			
				HumanEmitter = ParticleEmitter( LocalPlayer():GetPos() )
				
			end
			
			local pos = LocalPlayer():GetPos()
			
			for k, ply in pairs( team.GetPlayers( TEAM_HUMAN ) ) do
	
				local trgpos = ply:GetPos() + Vector(0,0,50)
		
				if ply:KeyDown( IN_DUCK ) then
				
					trgpos = ply:GetPos() + Vector(0,0,20)
					
				end
				
				trgpos = trgpos + VectorRand() * 3
		
				if ply:Alive() and trgpos:Distance( pos ) < 5000 then
			
					local scale = math.Clamp( ply:Health() / 100, 0, 1 )
					
					//local par = HumanEmitter:Add( "sprites/light_glow02_add_noz.vmt", trgpos ) 
					local par = HumanEmitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), trgpos )
					par:SetVelocity( VectorRand() * 5 )
					par:SetDieTime( math.Rand(0.5, 1.0) )
					par:SetStartAlpha( 250 )
					par:SetEndAlpha( 0 )
					par:SetStartSize( math.random( 5, 15 ) )
					par:SetEndSize( math.random(0, 5) )
					par:SetColor( 255 - scale * 255, 55 + scale * 200, 50 ) 
					par:SetRoll( math.random( 0, 360 ) )
					
				end
				
			end
			
		end
		
	end
	
end

function GM:DrawTextBar( x, y, text, col, num, flip, sub )
	
	surface.SetFont( "HudText" )
	local tw, th = surface.GetTextSize( num )
	
	surface.SetFont( "HudTextSmall" )
	local tw2, th2 = surface.GetTextSize( text )
	
	local w = 200 - ( sub or 0 )
	local h = th2 + 20
	
	if flip then
	
		draw.RoundedBox( 4, x - w, y - h, w, h, Color( 35, 35, 35, 200 ) )
		draw.SimpleTextOutlined( num, "HudText", x - w + 10, y - ( h * 0.5 ) - ( th * 0.5 ), col, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color( 10, 10, 10, 255 ) )
		draw.SimpleTextOutlined( text, "HudTextSmall", x - 10, y - ( h * 0.5 ) - ( th2 * 0.5 ), Color( 150, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 2, Color( 10, 10, 10, 255 ) )
	
	else
	
		draw.RoundedBox( 4, x, y - h, w, h, Color( 35, 35, 35, 200 ) )
		draw.SimpleTextOutlined( num, "HudText", x + w - 10, y - ( h * 0.5 ) - ( th * 0.5 ), col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 2, Color( 10, 10, 10, 255 ) )
		draw.SimpleTextOutlined( text, "HudTextSmall", x + 10, y - ( h * 0.5 ) - ( th2 * 0.5 ), Color( 150, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color( 10, 10, 10, 255 ) )
		
	end
	
	return h

end

function GM:DrawResults( x, y, col, font, text, text2 )
	
	surface.SetFont( font )
	local tw, th = surface.GetTextSize( text )
	
	if text2 then
	
		surface.SetFont( font .. "Sm" )
		local tw2, th2 = surface.GetTextSize( text2 )
		
		local w2 = tw2 + 20
		local h2 = th2 + 20
	
		draw.RoundedBox( 4, x - w2 * 0.5, y + 80, w2, h2, Color( 35, 35, 35, 200 ) )
		draw.SimpleTextOutlined( text2, font .. "Sm", x, y + 80 + ( h2 * 0.5 ), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 10, 10, 10, 255 ) )
	
	end
	
	local w = tw + 20
	local h = th + 20
	
	draw.RoundedBox( 4, x - w * 0.5, y, w, h, Color( 35, 35, 35, 200 ) )
	draw.SimpleTextOutlined( text, font, x, y + ( h * 0.5 ), col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 10, 10, 10, 255 ) )
	
	return h

end

function GM:PaintItemInfo()

	if not GAMEMODE.CurItemInfo then return end

	local text = GAMEMODE.CurItemInfo
	
	GAMEMODE.CurItemInfo = nil
	
	surface.SetFont( "HudTextSmall" )
	local tw, th = surface.GetTextSize( text )
	
	local w = tw + 20
	local h = th + 20
	
	draw.RoundedBox( 4, ScrW() * 0.5 - ( w * 0.5 ), 550, w, h, Color( 35, 35, 35, 200 ) )
	draw.SimpleTextOutlined( text, "HudTextSmall", ScrW() * 0.5, 550 + ( h * 0.5 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 10, 10, 10, 255 ) )

end

function GM:DrawTargetID()

	if not IsValid( GAMEMODE.TargetEnt ) or not GAMEMODE.TargetEnt:IsPlayer() or GAMEMODE.TargetEnt:Team() == TEAM_STALKER then return end
	
	local text = GAMEMODE.TargetEnt:Name()
	
	surface.SetFont( "HudTextSmall" )
	
	local tw, th = surface.GetTextSize( text )
	local w = tw + 20
	local h = th + 20
	
	local x = ScrW() * 0.5
	local y = ScrH() * 0.5 + 75
	
	if LocalPlayer():Team() == TEAM_SPECTATOR then
	
		y = ScrH() - 75
		
	end
	
	draw.RoundedBox( 4, x - ( w * 0.5 ), y, w, h, Color( 35, 35, 35, 200 ) )
	draw.SimpleTextOutlined( text, "HudTextSmall", x, y + 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color( 10, 10, 10, 255 ) )

end

function GM:ScrambleText( len )

	local str = ""

	for i=1, len do
	
		str = str .. string.char( math.random( 65, 90 ) )
	
	end
	
	return str

end

GM.PaintableWeapons = { "weapon_ts_usp",
"weapon_ts_shotgun",
"weapon_ts_famas",
"weapon_ts_p90",
"weapon_ts_sg552" }

function GM:DrawHumanHUD()

	if DisorientTime > CurTime() then
	
		local h = GAMEMODE:DrawTextBar( 5, ScrH() - 5, GAMEMODE:ScrambleText( 6 ), col, math.random( 100, 999 ) .. "%", false ) 
		GAMEMODE:DrawTextBar( 5, ScrH() - 10 - h, GAMEMODE:ScrambleText( 7 ), col2, math.random( 100, 999 ) .. "%", false )
		
		local wep = LocalPlayer():GetActiveWeapon()
		
		if IsValid( wep ) and table.HasValue( GAMEMODE.PaintableWeapons, wep:GetClass() ) then
				
			if wep:GetClass() != "weapon_ts_usp" then
				
				GAMEMODE:DrawTextBar( ScrW() - 5, ScrH() - 5, GAMEMODE:ScrambleText( 5 ), Color( 255, 255, 255, 255 ), math.random( 100, 999 ), true, 50 )
				GAMEMODE:DrawTextBar( ScrW() - 5, ScrH() - 10 - h, GAMEMODE:ScrambleText( 4 ), Color( 255, 255, 255, 255 ), math.random( 100, 999 ), true, 50 )
				
			else
				
				GAMEMODE:DrawTextBar( ScrW() - 5, ScrH() - 5, GAMEMODE:ScrambleText( 4 ), Color( 255, 255, 255, 255 ), math.random( 100, 999 ), true, 50 )
				
			end
			
		end

		return
	
	end

	local col = Color( 255, 255, 255, 255 )
	local col2 = Color( 255, 255, 255, 255 )
		
	if LocalPlayer():Health() < 50 then
		
		col = Color( 255, 120 + math.sin( RealTime() * 3 ) * 100, 120 + math.sin( RealTime() * 3 ) * 100, 200 )
		
	end
		
	if GAMEMODE:GetInt( "Battery" ) < 25 then
		
		col2 = Color( 255, 120 + math.sin( RealTime() * 3 ) * 100, 120 + math.sin( RealTime() * 3 ) * 100, 200 )
		
	end
	
	local h = GAMEMODE:DrawTextBar( 5, ScrH() - 5, "VITALS", col, math.Clamp( LocalPlayer():Health(), 0, 100 ) .. "%", false ) 
	GAMEMODE:DrawTextBar( 5, ScrH() - 10 - h, "BATTERY", col2, GAMEMODE:GetInt( "Battery" ) .. "%", false )
		
	local wep = LocalPlayer():GetActiveWeapon()
		
	if IsValid( wep ) and table.HasValue( GAMEMODE.PaintableWeapons, wep:GetClass() ) then
			
		if wep:GetClass() != "weapon_ts_usp" then
			
			GAMEMODE:DrawTextBar( ScrW() - 5, ScrH() - 5, "AMMO", Color( 255, 255, 255, 255 ), math.min( wep:Clip1(), GAMEMODE:GetInt( "Ammo" ) ), true, 40 )
			GAMEMODE:DrawTextBar( ScrW() - 5, ScrH() - 10 - h, "RESERVE", Color( 255, 255, 255, 255 ), math.max( GAMEMODE:GetInt( "Ammo" ) - wep:Clip1(), 0 ), true, 40 )
			
		else
			
			GAMEMODE:DrawTextBar( ScrW() - 5, ScrH() - 5, "AMMO", Color( 255, 255, 255, 255 ), wep:Clip1(), true, 40 )
			
		end
		
	end

end

local matHeart = Material( "stalker/heart" )
local matBrain = Material( "stalker/brain" )

function GM:HUDPaint()

	GAMEMODE:PaintItemInfo()
	GAMEMODE:DrawScreenEffects()

	if GAMEMODE.DisplayTime > CurTime() then
	
		if GAMEMODE.WinningTeam == TEAM_HUMAN then
		
			if GAMEMODE.WinningPlayer != "" then
			
				GAMEMODE:DrawResults( ScrW() * 0.5, 50, Color( 0, 100, 255 ), "HumanText", "THE STALKER HAS BEEN ELIMINATED", GAMEMODE.WinningPlayer .. " is credited with the kill" )
			
			else
		
				GAMEMODE:DrawResults( ScrW() * 0.5, 50, Color( 0, 100, 255 ), "HumanText", "THE STALKER HAS BEEN ELIMINATED" )
				
			end
		
		else
		
			GAMEMODE:DrawResults( ScrW() * 0.5, 50, Color( 255, 100, 0 ), "StalkerText", "UNIT 8 HAS BEEN ERADICATED" )
		
		end
	
	end
	
	if LocalPlayer():Team() == TEAM_HUMAN or LocalPlayer():Team() == TEAM_SPECTATOR then
	
		GAMEMODE:DrawTargetID()	
		
	end

	if LocalPlayer():Alive() and LocalPlayer():Team() == TEAM_HUMAN then
	
		GAMEMODE:DrawHumanHUD()
	
	elseif LocalPlayer():Alive() and LocalPlayer():Team() == TEAM_STALKER then
	
		local size = 55
		local textsize = 75
		local col = Color( 255, 255, 255, 200 )
		local col2 = Color( 255, 255, 255, 200 )
		
		if LocalPlayer():Health() <= 50 then
		
			col = Color( 255, 100 + math.sin( RealTime() * 3 ) * 100, 100 + math.sin( RealTime() * 3 ) * 100, 200 )	
			
		end
		
		if GAMEMODE:GetInt( "Mana" ) < 25 then
		
			col2 = Color( 255, 120 + math.sin( RealTime() * 3 ) * 100, 120 + math.sin( RealTime() * 3 ) * 100, 200 )	
		
		end
	
		surface.SetDrawColor( 200, 200, 200, 255 ) 
		surface.SetMaterial( matHeart ) 
		surface.DrawTexturedRect( ScrW() - textsize - size - 20, ScrH() - size - 20, size, size ) //45
		surface.SetMaterial( matBrain )
		surface.DrawTexturedRect( ScrW() - ( textsize * 2 ) - ( size * 2 ) - 40, ScrH() - size - 20, size, size )
		
		draw.SimpleTextOutlined( math.Clamp( LocalPlayer():Health(), 0, 1000 ), "StalkerText", ScrW() - textsize - 15, ScrH() - 70, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color(10,10,10,255) )	
		draw.SimpleTextOutlined( GAMEMODE:GetInt( "Mana" ), "StalkerText", ScrW() - ( textsize * 2 ) - size - 30, ScrH() - 70, col2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 2, Color(10,10,10,255) )
	
	end
	
end

function GM:HUDShouldDraw( name )

	if GAMEMODE.ScoreboardVisible then return false end
	
	for k, v in pairs{ "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudVoiceStatus" } do
	
		if name == v then return false end 
		
  	end 
	
	if name == "CHudDamageIndicator" and not LocalPlayer():Alive() then
	
		return false
		
	end
	
	return true
	
end

function GM:HUDDrawTargetID()

	return false
	
end

function GM:HUDWeaponPickedUp( wep )

end

function GM:AddDeathNotice()

end

function GM:GetInt( name, def )

	return GAMEMODE.PlayerData[ name ] or ( def or 0 )

end

function GM:CreateMove( cmd )

	local lp = LocalPlayer()
	
	if IsValid( lp ) and lp:Team() == TEAM_SPECTATOR and cmd:KeyDown( IN_DUCK ) then
	
		cmd:SetButtons( cmd:GetButtons() - IN_DUCK )
		
	end	
	
end

net.Receive( "ShowHelp", function( len )

	if IsValid( GAMEMODE.HelpFrame ) then return end

	GAMEMODE:ShowHelp()

end )

net.Receive( "ToggleMenu", function( len )

	if IsValid( GAMEMODE.HelpFrame ) then return end
	
	if not IsValid( LocalPlayer() ) then return end

	if GAMEMODE:ElementsVisible() then
	
		GAMEMODE:ClearElements()
		gui.EnableScreenClicker( false )
	
	elseif LocalPlayer():Team() != TEAM_STALKER then
	
		GAMEMODE:OpenMenu()
		gui.EnableScreenClicker( true )
	
	end

end )

net.Receive( "RoundEnd", function( len )

	local t = net.ReadInt( 8 )
	
	GAMEMODE.WinningPlayer = net.ReadString()
	GAMEMODE.WinningTeam = t
	GAMEMODE.DisplayTime = CurTime() + 7

end )

net.Receive( "SynchInt", function( len )

	local name = net.ReadString()
	local value = net.ReadUInt( 8 )
	
	GAMEMODE.PlayerData[ name ] = value

end )