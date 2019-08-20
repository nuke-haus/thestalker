local PANEL = {}

PANEL.Sound = Sound( "common/talk.wav" )

function PANEL:Init()
	
	self.Image = vgui.Create( "DImageButton", self )
	self.Image:SetImage( "icon16/car.png" )
	self.Image:SetStretchToFit( false )
	self.Image.DoClick = function()
	
		self:DoClick()
	
	end
	
	self:SetCursor( "hand" )
	self.Text = "a"
	
end

function PANEL:SetImage( img )

	self.Image:SetImage( img )

end

function PANEL:SetText( text )

	self.Text = text

end

function PANEL:DoClick()
	
	LocalPlayer():EmitSound( self.Sound, 100, 80 )
	
	RunConsoleCommand( "ts_loadout_" .. self.IntSlot, self.IntValue )
	RunConsoleCommand( "ts_apply_loadout", self.IntSlot, self.IntValue )
	
	if self.IntSlot == 3 then
	
		GAMEMODE.UtilSlot = self.IntValue
	
	else
	
		GAMEMODE.PlayerData[ "Loadout" .. self.IntSlot ] = self.IntValue
		
	end
	
	self:SetImage( "icon16/accept.png" )
	self.Check = true
	
	for k,v in pairs( GAMEMODE.Elements ) do
	
		if v:GetSlot() == self.IntSlot and v != self then
		
			v:SetImage( "icon16/cross.png" )
			v.Check = false
		
		end
	
	end

end

function PANEL:GetSlot()

	return self.IntSlot

end

function PANEL:SetInt( slot, value )

	self.IntSlot = slot
	self.IntValue = value
	
	if slot == 3 then
	
		if ( !GAMEMODE.UtilSlot and GAMEMODE:GetInt( "Loadout" .. ( self.IntSlot or 1 ) ) == ( self.IntValue or 1 ) ) or ( GAMEMODE.UtilSlot and GAMEMODE.UtilSlot == value ) then
	
			self:SetImage( "icon16/accept.png" )
			self.Check = true
			
		else
		
			self:SetImage( "icon16/cross.png" )
			self.Check = false
		
		end
		
		return
	
	end
	
	if GAMEMODE:GetInt( "Loadout" .. ( self.IntSlot or 1 ) ) == ( self.IntValue or 1 ) then
	
		self:SetImage( "icon16/accept.png" )
		self.Check = true
	
	else
	
		self:SetImage( "icon16/cross.png" )
		self.Check = false
	
	end

end

function PANEL:OnMousePressed( mousecode )

	self:MouseCapture( true )

end

function PANEL:OnMouseReleased( mousecode )

	self:MouseCapture( false )
	self:DoClick()

end

function PANEL:GetPadding()

	return 5
	
end

function PANEL:PerformLayout()

	local imgsize = self:GetTall() - ( 2 * self:GetPadding() )

	self.Image:SetSize( imgsize, imgsize )
	self.Image:SetPos( self:GetWide() - imgsize - self:GetPadding(), self:GetPadding() )

end

function PANEL:Paint()

	local tx, ty = self:GetPadding() * 2, self:GetTall() * 0.5 - 10
	//local px, py = self.Image:GetPos()
	local imgsize = self:GetTall() - ( 2 * self:GetPadding() )

	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 180 ) )
	
	if self.Hovered then
	
		draw.RoundedBox( 4, self:GetWide() - imgsize - self:GetPadding(), self:GetPadding(), imgsize, imgsize, Color( 100, 100, 100, 100 ) )
		
		draw.SimpleText( self.Text, "HumanTextSm", tx+1, ty+1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx-1, ty-1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx+1, ty-1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx-1, ty+1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx, ty, Color( 100, 255, 255, 255 ), TEXT_ALIGN_LEFT )
		
		GAMEMODE.CurItemInfo = GAMEMODE.ItemDescriptions[ self.IntSlot ][ self.IntValue ] 
		
		--[[surface.SetFont( "HumanTextSm" )
		
		local text = GAMEMODE.ItemDescriptions[ self.IntSlot ][ self.IntValue ]
		local tx, ty = surface.GetTextSize( text )
		local x = ScrW() * 0.5 - ( tx * 0.5 )
		local y = ( 5 - self.IntSlot ) * 40 + 210
		
		draw.RoundedBox( 4, x, y, tx + 10, ty + 10, Color( 0, 0, 0, 150 ) )
		draw.SimpleTextOutlined( text, "HumanTextSm", ScrW() * 0.5, y - ( ty * 0.5 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 10, 10, 10, 255 ) )]]
	
	else

		draw.RoundedBox( 4, self:GetWide() - imgsize - self:GetPadding(), self:GetPadding(), imgsize, imgsize, Color( 100, 100, 100, 100 ) )
		
		draw.SimpleText( self.Text, "HumanTextSm", tx+1, ty+1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx-1, ty-1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx+1, ty-1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx-1, ty+1, Color( 0, 0, 0, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( self.Text, "HumanTextSm", tx, ty, Color( 150, 150, 150, 255 ), TEXT_ALIGN_LEFT )
		
	end
	
end

derma.DefineControl( "SelectionButton", "A shitty button thing.", PANEL, "DPanel" )
