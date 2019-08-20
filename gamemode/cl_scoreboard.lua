local PANEL = {}

surface.CreateFont("ts_ScoreboardBig", {
	size = ScreenScale(25),
	weight = 800,
	antialias = true,
	font = "Prototype",
	outline = true
} )

surface.CreateFont("ts_ScoreboardMedium", {
	size = ScreenScale(12),
	weight = 600,
	antialias = true,
	font = "Prototype",
	outline = true
} )

surface.CreateFont("ts_ScoreboardSmall", {
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
	font = "Prototype",
	outline = true
} )

surface.CreateFont("ts_ScoreboardTiny", {
	size = ScreenScale(8),
	weight = 200,
	antialias = true,
	font = "Prototype",
} )


function PANEL:Init()
	self:SetSize(ScrW() * 0.55, ScrH() * 0.75)
	self:Center()

	self.body = self:Add("DPanel")
	self.body:Dock(FILL)
	self.body:DockMargin(5, 5, 5, 5)

	self.body.Paint = function(body, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 100) )
	end

	self.header = self.body:Add("DPanel")
	self.header:Dock(TOP)
	self.header:SetTall(self:GetTall() * 0.15)
	self.header:DockMargin(4, 4, 4, 4)

	self.header.Paint = function(header, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 200) )
	end

	self.header.title = self.header:Add("DLabel")
	self.header.title:SetText("The Stalker")
	self.header.title:SetFont("ts_ScoreboardBig")
	self.header.title:SetContentAlignment(5)
	self.header.title:Dock(FILL)

	self.header.hostName = self.header:Add("DLabel")
	self.header.hostName:SetText( GetHostName() )
	self.header.hostName:SetFont("ts_ScoreboardSmall")
	self.header.hostName:SetContentAlignment(5)
	self.header.hostName:DockMargin(3, 3, 3, 5)
	self.header.hostName:Dock(BOTTOM)

	self.stalker = self.body:Add("DPanel")
	self.stalker:Dock(TOP)
	self.stalker:SetTall(36)
	self.stalker:DockMargin(5, 5, 5, 5)

	self.stalker.Think = function(stalker)
		local client = team.GetPlayers(TEAM_STALKER)[1]

		if ( IsValid(client) ) then
			if (stalker.player != client) then
				stalker.player = client
			end

			stalker.avatar:SetPlayer(client)
		end
	end

	self.stalker.name = self.stalker:Add("DLabel")
	self.stalker.name:SetFont("ts_ScoreboardMedium")
	self.stalker.name:SetText("")
	self.stalker.name:SetContentAlignment(5)
	self.stalker.name:Dock(FILL)
	self.stalker.name:DockMargin(5, 5, 5, 5)
	self.stalker.name:SetTextColor( Color(250, 70, 70, 255) )
	self.stalker.name:SizeToContents()

	self.stalker.name.Think = function(name)
		if ( IsValid(self.stalker.player) and name:GetText() != self.stalker.player:Name() ) then
			name:SetText( self.stalker.player:Name() )
		end
	end

	self.stalker.Paint = function(stalker, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(75, 75, 75, 200) )
	end

	self.stalker.avatar = self.stalker:Add("AvatarImage")
	self.stalker.avatar:Dock(LEFT)
	self.stalker.avatar:DockMargin(4, 4, 4, 4)
	self.stalker.avatar:SetSize(32, 32)

	self.stalker.ping = self.stalker:Add("DLabel")
	self.stalker.ping:SetFont("ts_ScoreboardMedium")
	self.stalker.ping:SetText("")
	self.stalker.ping:DockMargin(5, 5, 5, 5)
	self.stalker.ping:Dock(RIGHT)
	self.stalker.ping:SizeToContents()

	self.stalker.ping.Think = function(ping)
		if ( IsValid(self.stalker.player) ) then
			local amount = math.Clamp(self.stalker.player:Ping() / 200, 0, 1)

			ping:SetTextColor( Color( (255 * amount), 255 - (255 * amount), (1 - amount) * 75, 200) )
			ping:SetText( self.stalker.player:Ping() )
			ping:SizeToContents()
		end
	end

	self.stats = self.body:Add("DLabel")
	self.stats:DockMargin(3, 3, 3, 3)
	self.stats:Dock(BOTTOM)
	self.stats:SetContentAlignment(5)
	self.stats:SetFont("ts_ScoreboardTiny")
	self.stats:SetText("Round: 0")
	self.stats:SetExpensiveShadow( 1, Color(5, 5, 5, 250) )
	self.stats:SizeToContents()

	self.stats.Think = function(stats)
		local round = GetGlobalInt("RoundNum", 0)
		local max = sv_ts_num_rounds:GetInt()
		local roundsleft = max - round
		
		if roundsleft == 0 then
		
			stats:SetText("Loading Next Map...")
		
		else
		
			stats:SetText("Rounds Left: "..roundsleft)
		
		end
		
	end

	self.units = self.body:Add("ts_ScoreboardTeam")
	self.units:SetWide( (self:GetWide() * 0.5) - 15 )
	self.units:DockMargin(5, 5, 5, 5)
	self.units:Dock(LEFT)
	self.units:SetTeam(TEAM_HUMAN)

	self.dead = self.body:Add("ts_ScoreboardTeam")
	self.dead:SetWide( (self:GetWide() * 0.5) - 15 )
	self.dead:DockMargin(5, 5, 5, 5)
	self.dead:Dock(RIGHT)
	self.dead:SetTeam(TEAM_SPECTATOR)
end

function PANEL:Paint(w, h)
	draw.RoundedBox( 4, 0, 0, w, h, Color(10, 10, 10, 225) )
end

vgui.Register("ts_Scoreboard", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self.title = self:Add("DLabel")
	self.title:Dock(TOP)
	self.title:DockMargin(5, 5, 5, 5)
	self.title:SetFont("ts_ScoreboardMedium")
	self.title:SetText("N/A")
	self.title:SizeToContents()

	self.scroll = self:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(5, 5, 5, 5)

	self.scroll.Paint = function(scroll, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color(75, 75, 75, 200) )
	end
end

function PANEL:SetTeam(index)
	self.team = index
	self.title:SetTextColor( team.GetColor(index) )
end

function PANEL:Think()
	if (self.team) then
		local suffix = " Players"
		local players = team.NumPlayers(self.team)
		local name = team.GetName(self.team)

		if (players == 1) then
			suffix = " Player"
		end

		self.title:SetText(name.." - "..players..suffix)

		for k, v in SortedPairs( player.GetAll() ) do
			if (!IsValid(v.ts_Row) and v:Team() == self.team) then
				local row = self.scroll:Add("ts_ScoreboardPlayer")
				row:Dock(TOP)
				row:DockMargin(3, 3, 3, 0)
				row:SetPlayer(v)

				v.ts_Row = row

				self.scroll:AddItem(row)
			end
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 225) )
end

vgui.Register("ts_ScoreboardTeam", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
	self:SetTall(36)

	self.avatar = self:Add("AvatarImage")
	self.avatar:Dock(LEFT)
	self.avatar:DockMargin(3, 3, 3, 3)
	self.avatar:SetSize(32, 32)

	self.avatar.click = self.avatar:Add("DButton")
	self.avatar.click:Dock(FILL)
	self.avatar.click:SetText("")

	self.avatar.click.Paint = function() end

	self.avatar.click.DoClick = function(avatarButton)
		local menu = DermaMenu()

		menu:AddOption("View Profile", function()
			if ( IsValid(self.player) ) then
				self.player:ShowProfile()
			end
		end)

		local text = "Mute"

		if (self.player.ts_Muted) then
			text = "Unmute"
		end
		
		menu:AddOption(text, function()
			if ( IsValid(self.player) ) then
				self.player.ts_Muted = !self.player.ts_Muted
				self.player:SetMuted(self.player.ts_Muted)
			end
		end)

		menu:Open()
	end

	self.name = self:Add("DLabel")
	self.name:SetFont("ts_ScoreboardSmall")
	self.name:SetText("N/A")
	self.name:Dock(LEFT)
	self.name:DockMargin(5, 5, 5, 5)
	self.name:SizeToContents()

	self.ping = self:Add("DLabel")
	self.ping:SetFont("ts_ScoreboardMedium")
	self.ping:SetText("")
	self.ping:DockMargin(5, 5, 5, 5)
	self.ping:Dock(RIGHT)
	self.ping:SizeToContents()

	self.frags = self:Add("DLabel")
	self.frags:SetFont("ts_ScoreboardMedium")
	self.frags:SetText("0")
	self.frags:DockMargin(5, 5, 15, 5)
	self.frags:Dock(RIGHT)
	self.frags:SizeToContents()
end

function PANEL:SetPlayer(client)
	if ( IsValid(client) ) then
		self.player = client
		self.team = client:Team()
		self.avatar:SetPlayer(client)
		self.initialized = true
	end
end

function PANEL:Think()
	if ( self.initialized and !IsValid(self.player) ) then
		self:Remove()
	elseif (self.initialized) then
		if ( self.team != self.player:Team() ) then
			self:Remove()
		end

		self.frags:SetText( self.player:Frags() )
		self.frags:SizeToContents()

		local amount = math.Clamp(self.player:Ping() / 200, 0, 1)

		self.ping:SetTextColor( Color( (255 * amount), 255 - (255 * amount), (1 - amount) * 75, 200) )
		self.ping:SetText( self.player:Ping() )
		self.ping:SizeToContents()

		if ( self.player:Name() != self.name:GetText() ) then
			self.name:SetText( self.player:Name() )
			self.name:SizeToContents()
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox( 4, 0, 0, w, h, Color(50, 50, 50, 225) )
end

vgui.Register("ts_ScoreboardPlayer", PANEL, "DPanel")

local SCOREBOARD

function GM:ScoreboardShow()
	gui.EnableScreenClicker(true)

	SCOREBOARD = vgui.Create("ts_Scoreboard")
end

function GM:ScoreboardHide()
	gui.EnableScreenClicker(false)
	
	if not SCOREBOARD then return end

	SCOREBOARD:Remove()
end