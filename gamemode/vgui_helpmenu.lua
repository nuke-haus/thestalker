local PANEL = {}

PANEL.Text = { "<html><body style=\"background-color:DimGray;\">",
"<p style=\"font-family:tahoma;color:red;font-size:25;text-align:center\"><b>READ THIS!</b></p>",
"<p style=\"font-family:verdana;color:black;font-size:10px;text-align:left\">",
"<b><u>Unit 8 Gameplay:</u></b> You are part of a team tasked with finding and eliminating a genetic anomaly only known as The Stalker. You haven't been briefed on the origins of this creature but you have been informed that ",
"it is barely visible to the naked eye and is highly aggressive.<br><br>",
"<b>Drones:</b> If you are killed as a soldier, you will respawn shortly after as a drone. As a drone, you can locate the stalker using your built-in range scanner (right click) and if a drone locks on to the Stalker ",
"(left click), it will sound an alarm and briefly enable its built in particle beam weapon.<br><br>",
"<b>Battery Power:</b> As a soldier, you have limited battery power. Using your flashlight will deplete your battery. If you empty your battery completely, it will take longer to recharge.<br><br>",
"<b>Your Loadout:</b> Press F2 as a soldier to open the loadout menu. Changes you make will take effect when you spawn next.<br><br>",
"<b>Secondary Item - Glock 19:</b> This sidearm is very useful if you find yourself running out of ammo often. It has unlimited ammo.<br><br>",
"<b>Secondary Item - Seeker Drone:</b> When deployed, this drone will hover around, scanning for lifeforms. It will sound off if it finds any unusual heat signatures.<br><br>",
"<b>Secondary Item - Optic Range Scanner:</b> This scanner will detect the location of the Stalker when used (primary fire). It consumes battery power with each use.<br><br>",
"<b>Secondary Item - Portable Sensor:</b> This sensor can be placed to block off passages and detect the location of the Stalker. Use it in places where it cannot be bypassed for maximum efficiency.<br><br>",
"<b>Utility - Ammunition Pack:</b> An option preferred by those who are less conservative with ammo.<br><br>",
"<b>Utility - Laser Module:</b> In addition to accurately marking where your shots will land, this utility can also help detect the Stalker if you manage to point your weapon directly at it.<br><br>",
"<b>Utility - Dual Cell Battery:</b> This utility amplifies your flashlight and improves your battery recharge rate.<br><br>",
"<b>Utility - Automedic System:</b> An integrated morphine injector for your armor which activates when you are injured.<br><br><br>",
"<b><u>The Stalker Gameplay:</u></b> You must use cunning and stealth to eliminate Unit 8 before they are able to overwhelm you. You are strongest when targeting solitary prey.<br><br>",
"<b>Health and Ability Power:</b> As the Stalker, each ability draws on your mental power. Your mental power constantly regenerates unless you are using ESP. ",
"Your health slowly deteriorates over time but you regain health by killing players and ripping apart corpses. You thrive on bloodshed.<br><br>",
"<b>Jumping and Clinging:</b> Press your sprint key (default SHIFT) to jump great distances. Press it again when you're facing a wall in midair to cling to the wall.<br><br>",
"<b>Extrasensory Perception:</b> As the Stalker, you can toggle ESP using your flashlight key (default F). This allows you to see the health of your enemies.<br><br>",
"<b>The Ability Menu:</b> To open your ability menu as the Stalker, hold down your use button (default E) and use your mouse to select an ability. Right click to use your abilities once the menu is closed.<br><br>",
"<b>Ability - Scream:</b> Use this ability when cornered or surrounded by enemies to maximise its usefulness. Screaming then leaping away is a great escape technique.<br><br>",
"<b>Ability - Mind Flay:</b> Use this ability to disorient a lone soldier. This ability is great for picking off stragglers.<br><br>",
"<b>Ability - Telekinesis:</b> Use this ability to attack enemies from a distance and kill multiple soldiers when they are grouped. Right click an object to possess it, then right click your target to launch it.<br><br>",
"<b>Ability - Blood Thirst:</b> Use this ability to increase your melee power and leech life with your attacks. This ability increases your healing from dismembering corpses as well.<br>" }

PANEL.ButtonText = { "Holy Shit I Don't Care",
"I Didn't Read Any Of That",
"That's A Lot Of Words",
"I'd Rather Just Whine For Help",
"Just Wanna Play Video Games",
"Who Gives A Shit?",
"Help Menus Are For Nerds",
"I Thought This Was A Roleplay Server",
"I Don't Like Reading",
"TL;DR",
"Click Me" }

function PANEL:Init()

	//self:SetTitle( "" )
	//self:ShowCloseButton( false )
	self:ChooseParent()
	
	local text = ""
	
	for k,v in pairs( self.Text ) do
	
		text = text .. v
	
	end
	
	self.Label = vgui.Create( "HTML", self )
	self.Label:SetHTML( text )
	
	self.Button = vgui.Create( "DButton", self )
	self.Button:SetText( table.Random( self.ButtonText ) )
	self.Button.OnMousePressed = function()

		self:Remove() 
		
	end
	
end

function PANEL:ChooseParent()
	
end

function PANEL:GetPadding()
	return 5
end

function PANEL:PerformLayout()

	local x,y = self:GetPadding(), self:GetPadding() + 10
	
	self.Label:SetSize( self:GetWide() - ( self:GetPadding() * 2 ) - 5, self:GetTall() - 50 )
	self.Label:SetPos( x + 5, y + 5 )
	
	self.Button:SetSize( 250, 20 )
	self.Button:SetPos( self:GetWide() * 0.5 - self.Button:GetWide() * 0.5, self:GetTall() - 30 )
	
	self:SizeToContents()

end

function PANEL:Paint()

	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 255 ) )
	draw.RoundedBox( 4, 1, 1, self:GetWide() - 2, self:GetTall() - 2, Color( 150, 150, 150, 150 ) )
	
	draw.SimpleText( "Help Menu", "Header", self:GetWide() * 0.5, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

end

derma.DefineControl( "HelpMenu", "A help menu.", PANEL, "DPanel" )
