--[[****************************************************************************
  * _Clean.Units by Saiket                                                     *
  * _Clean.Units.oUF.lua - Adds custom skinned unit frames using oUF.          *
  ****************************************************************************]]


-- NOTE(Fix health bars for critters.)
local LibSharedMedia = LibStub( "LibSharedMedia-3.0" );
local L = _CleanLocalization.Units;
local _Clean = _Clean;
local me = {};
_Clean.Units.oUF = me;

me.FontNormal = CreateFont( "_CleanUnitsOUFFontNormal" );
me.FontTiny = CreateFont( "_CleanUnitsOUFFontTiny" );
me.FontMicro = CreateFont( "_CleanUnitsOUFFontMicro" );

me.StyleMeta = {};

local Colors = _Clean.Colors;
setmetatable( Colors, { __index = oUF.colors; } );
setmetatable( Colors.power, { __index = oUF.colors.power; } );
Colors.class = oUF.colors.class;




--[[****************************************************************************
  * Function: _Clean.Units.oUF:SetStatusBarColor                               *
  * Description: Colors bar text to match bars.                                *
  ****************************************************************************]]
function me:SetStatusBarColor ( R, G, B, A )
	self.Texture:SetVertexColor( R, G, B, A );
	if ( self.Value ) then
		self.Value:SetTextColor( R, G, B, A );
	end
end
--[[****************************************************************************
  * Function: _Clean.Units.oUF.BarFormatValue                                  *
  * Description: Formats bar text depending on the bar's style.                *
  ****************************************************************************]]
function me:BarFormatValue ( Value, ValueMax )
	self.Value:SetFormattedText( L.NumberFormats[ self.ValueLength ]( Value, ValueMax ) );
end




--[[****************************************************************************
  * Function: _Clean.Units.oUF:PostUpdateHealth                                *
  ****************************************************************************]]
do
	local function ColorDead ( Bar, Label )
		Bar.Texture:SetVertexColor( 0.2, 0.2, 0.2 );
		if ( Bar.Value ) then
			Bar.Value:SetText( L[ Label ] );
			Bar.Value:SetTextColor( unpack( Colors.disconnected ) );
		end
	end
	local UnitIsGhost = UnitIsGhost;
	local UnitIsDead = UnitIsDead;
	local UnitIsConnected = UnitIsConnected;
	function me:PostUpdateHealth ( Event, UnitID, Bar, Health, HealthMax )
		if ( UnitIsGhost( UnitID ) ) then
			Bar:SetValue( 0 );
			ColorDead( Bar, "GHOST" );
		elseif ( UnitIsDead( UnitID ) and not self.IsFeignDeath ) then
			Bar:SetValue( 0 );
			ColorDead( Bar, "DEAD" );
		elseif ( not UnitIsConnected( UnitID ) ) then
			ColorDead( Bar, "OFFLINE" );
		elseif ( Bar.Value ) then
			me.BarFormatValue( Bar, Health, HealthMax );
		end
	end
end
--[[****************************************************************************
  * Function: _Clean.Units.oUF:PostUpdatePower                                 *
  ****************************************************************************]]
function me:PostUpdatePower ( Event, UnitID, Bar, Power, PowerMax )
	local Dead = UnitIsDeadOrGhost( UnitID );
	if ( Dead ) then
		Bar:SetValue( 0 );
	end
	if ( Bar.Value ) then
		if ( Dead ) then
			Bar.Value:SetText();
		elseif ( select( 2, UnitPowerType( UnitID ) ) ~= "MANA" ) then
			Bar.Value:SetText();
		else
			me.BarFormatValue( Bar, Power, PowerMax );
		end
	end
end


--[[****************************************************************************
  * Function: _Clean.Units.oUF:PostCreateAuraIcon                              *
  ****************************************************************************]]
function me:PostCreateAuraIcon ( Frame )
	_Clean.SkinButtonIcon( Frame.icon );
	Frame.UpdateTooltip = me.AuraUpdateTooltip;
	Frame.cd:SetReverse( true );
	Frame:SetFrameLevel( self:GetFrameLevel() - 1 ); -- Don't allow auras to overlap other units

	Frame.count:ClearAllPoints();
	Frame.count:SetPoint( "BOTTOMLEFT" );
end
--[[****************************************************************************
  * Function: _Clean.Units.oUF:PostUpdateAura                                  *
  * Description: Resizes the buffs frame so debuffs anchor correctly.          *
  ****************************************************************************]]
do
	local FeignDeath = GetSpellInfo( 28728 );
	function me:PostUpdateAura ( Event, UnitID )
		local Frame = self.Buffs;
		local BuffsPerRow = max( 1, floor( Frame:GetWidth() / Frame.size ) );
		Frame:SetHeight( max( 1, Frame.size * ceil( Frame.visibleBuffs / BuffsPerRow ) ) );

		-- Check for feign death
		local IsFeignDeath = UnitAura( UnitID, FeignDeath ) and true or false;
		if ( self.IsFeignDeath ~= IsFeignDeath ) then
			self.IsFeignDeath = IsFeignDeath;
			self:PostUpdateHealth( Event, UnitID, self.Health, UnitHealth( UnitID ), UnitHealthMax( UnitID ) );
		end
	end
end
--[[****************************************************************************
  * Function: _Clean.Units.oUF:AuraUpdateTooltip                               *
  * Description: Updates aura tooltips while they're moused over.              *
  ****************************************************************************]]
function me:AuraUpdateTooltip ()
	GameTooltip:SetUnitAura( self.frame.unit, self:GetID(), self.filter );
end


--[[****************************************************************************
  * Function: _Clean.Units.oUF:ReputationPostUpdate                            *
  * Description: Recolors the reputation bar on update.                        *
  ****************************************************************************]]
function me:ReputationPostUpdate ( _, _, Bar, _, _, _, _, StandingID )
	Bar:SetStatusBarColor( unpack( Colors.reaction[ StandingID ] ) );
end

--[[****************************************************************************
  * Function: _Clean.Units.oUF:ExperiencePostUpdate                            *
  * Description: Adjusts the rested experience bar segment.                    *
  ****************************************************************************]]
function me:ExperiencePostUpdate ( _, UnitID, Bar, Value, ValueMax )
	if ( UnitID == "player" ) then
		local RestedExperience = GetXPExhaustion();
		local Texture = Bar.RestTexture;
		if ( RestedExperience ) then
			local Width = Bar:GetParent():GetWidth(); -- Bar's width not calculated by PLAYER_ENTERING_WORLD, but parent's width is
			Texture:Show();
			Texture:SetPoint( "LEFT", Value / ValueMax * Width, 0 );
			Texture:SetPoint( "RIGHT", Bar, "LEFT", min( 1, ( Value + RestedExperience ) / ValueMax ) * Width, 0 );
		else -- Not resting
			Texture:Hide();
		end
	end
end


--[[****************************************************************************
  * Function: _Clean.Units.oUF:ClassificationUpdate                            *
  * Description: Shows the rare/elite border for appropriate mobs.             *
  ****************************************************************************]]
do
	local Classifications = {
		elite = "elite"; worldboss = "elite";
		rare = "rare"; rareelite = "rare";
	};
	function me:ClassificationUpdate ( Event, UnitID )
		if ( not Event or UnitIsUnit( UnitID, self.unit ) ) then
			local Type = Classifications[ UnitClassification( self.unit ) ];
			local Texture = self.Classification;
			if ( Type ) then
				Texture:Show();
				SetDesaturation( Texture, Type == "rare" );
			else
				Texture:Hide();
			end
		end
	end
end




--[[****************************************************************************
  * Function: _Clean.Units.oUF.TagClassification                               *
  * Description: Tag that displays level/classification or group # in raid.    *
  ****************************************************************************]]
do
	local Plus = { worldboss = true; elite = true; rareelite = true; };
	function me.TagClassification ( UnitID )
		if ( UnitID == "player" and GetNumRaidMembers() > 0 ) then
			return L.OUF_GROUP_FORMAT:format( select( 3, GetRaidRosterInfo( GetNumRaidMembers() ) ) );
		else
			local Level = UnitLevel( UnitID );
			if ( Plus[ UnitClassification( UnitID ) ] or Level ~= MAX_PLAYER_LEVEL or UnitLevel( "player" ) ~= MAX_PLAYER_LEVEL ) then
				local Color = Level < 0 and QuestDifficultyColors[ "impossible" ] or GetQuestDifficultyColor( Level );
				return L.OUF_CLASSIFICATION_FORMAT:format( Color.r * 255, Color.g * 255, Color.b * 255,
					oUF.Tags[ "[smartlevel]" ]( UnitID ) );
			end
		end
	end
end
--[[****************************************************************************
  * Function: _Clean.Units.oUF.TagName                                         *
  * Description: Colored name with server name if different from player's.     *
  ****************************************************************************]]
do
	local Name, Server, Color, R, G, B;
	function me.TagName ( UnitID, Override )
		Name, Server = UnitName( Override or UnitID );

		if ( UnitIsPlayer( UnitID ) ) then
			Color = Colors.class[ select( 2, UnitClass( UnitID ) ) ];
		elseif ( UnitPlayerControlled( UnitID ) or UnitPlayerOrPetInRaid( UnitID ) ) then -- Pet
			Color = Colors.Pet;
		else -- NPC
			Color = Colors.reaction[ UnitReaction( UnitID, "player" ) or 5 ];
		end

		R, G, B = unpack( Color );
		return L.OUF_NAME_FORMAT:format( R * 255, G * 255, B * 255,
			( Server and Server ~= "" ) and L.OUF_SERVER_DELIMITER:join( Name, Server ) or Name );
	end
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	me.FontNormal:SetFont( [[Fonts\ARIALN.TTF]], 10, "OUTLINE" );
	me.FontTiny:SetFont( [[Fonts\ARIALN.TTF]], 8, "OUTLINE" );
	me.FontMicro:SetFont( [[Fonts\ARIALN.TTF]], 6 );


	-- Hide default buff frame
	BuffFrame:Hide();
	TemporaryEnchantFrame:Hide();
	BuffFrame:UnregisterAllEvents();


	-- Custom tags
	oUF.Tags[ "[_CleanUnitsClassification]" ] = me.TagClassification;
	oUF.TagEvents[ "[_CleanUnitsClassification]" ] = "UNIT_LEVEL PLAYER_LEVEL_UP RAID_ROSTER_UPDATE "..( oUF.TagEvents[ "[shortclassification]" ] or "" );

	oUF.Tags[ "[_CleanUnitsName]" ] = me.TagName;
	oUF.TagEvents[ "[_CleanUnitsName]" ] = "UNIT_NAME_UPDATE UNIT_FACTION";




	local BarTexture = LibSharedMedia:Fetch( LibSharedMedia.MediaType.STATUSBAR, "_Clean" );
	local function CreateBarBackground ( self, Brightness )
		local Background = self:CreateTexture( nil, "BACKGROUND" );
		Background:SetAllPoints( self );
		Background:SetVertexColor( Brightness, Brightness, Brightness );
		Background:SetTexture( BarTexture );
		return Background;
	end
	local function CreateBar ( self )
		local Bar = CreateFrame( "StatusBar", nil, self );
		Bar:SetStatusBarTexture( BarTexture );
		Bar.Texture = Bar:GetStatusBarTexture();
		return Bar;
	end
	local CreateBarReverse; -- Creates a status bar that fills in reverse.
	do
		local function SetStatusBarTexture ( self, Path )
			self.Texture:SetTexture( Path );
		end
		local function GetStatusBarTexture ( self )
			return self.Texture;
		end
		local function OnSizeChanged ( self, Width )
			Width = ( 1 - self:GetValue() / select( 2, self:GetMinMaxValues() ) ) * Width;
			if ( Width > 0 ) then
				self.Texture:SetWidth( Width );
				self.Texture:Show();
			else -- Full health
				self.Texture:Hide();
			end
		end
		local function OnValueChanged ( self )
			OnSizeChanged( self, self:GetWidth() );
		end
		function CreateBarReverse ( self )
			local Bar = CreateFrame( "StatusBar", nil, self );
			Bar.Texture = Bar:CreateTexture( nil, "BORDER" );
			Bar.Texture:SetPoint( "TOPRIGHT" );
			Bar.Texture:SetPoint( "BOTTOM" );
			Bar.Texture:SetTexture( BarTexture );

			Bar.SetStatusBarTexture = SetStatusBarTexture;
			Bar.GetStatusBarTexture = GetStatusBarTexture;
			Bar:SetScript( "OnValueChanged", OnValueChanged );
			Bar:SetScript( "OnSizeChanged", OnSizeChanged );

			return Bar;
		end
	end


	local CreateDebuffHighlight; -- Creates a border frame that behaves like a texture for the oUF_DebuffHighlight element.
	if ( IsAddOnLoaded( "oUF_DebuffHighlight" ) ) then
		local function SetVertexColor ( self, ... )
			for Index = 1, #self do
				self[ Index ]:SetVertexColor( ... );
			end
		end
		local function GetVertexColor ( self )
			return self[ 1 ]:GetVertexColor();
		end
		local function CreateTexture( self, Point1, Point1Frame, Point2, Point2Frame, Point2Rel )
			local Texture = self:CreateTexture( nil, "OVERLAY" );
			tinsert( self, Texture );
			Texture:SetTexture( [[Interface\Buttons\WHITE8X8]] );
			Texture:SetPoint( Point1, Point1Frame );
			Texture:SetPoint( Point2, Point2Frame, Point2Rel );
		end
		function CreateDebuffHighlight ( self, Backdrop )
			local Frame = CreateFrame( "Frame", nil, self.Health );
			-- Four separate outline textures so faded frames blend correctly
			CreateTexture( Frame, "TOPLEFT", Backdrop, "BOTTOMRIGHT", self, "TOPRIGHT" );
			CreateTexture( Frame, "TOPRIGHT", Backdrop, "BOTTOMLEFT", self, "BOTTOMRIGHT" );
			CreateTexture( Frame, "BOTTOMRIGHT", Backdrop, "TOPLEFT", self, "BOTTOMLEFT" );
			CreateTexture( Frame, "BOTTOMLEFT", Backdrop, "TOPRIGHT", self, "TOPLEFT" );

			Frame.GetVertexColor = GetVertexColor;
			Frame.SetVertexColor = SetVertexColor;
			Frame:SetVertexColor( 0, 0, 0, 0 ); -- Hide when not debuffed
			return Frame;
		end
	end


	local function Initialize ( Style, self, UnitID ) -- Sets up a unit frame based on its style table.
		-- Enable the right-click menu
		SecureUnitButton_OnLoad( self, UnitID, _Clean.Units.ShowGenericMenu );
		self:RegisterForClicks( "LeftButtonUp", "RightButtonUp" );

		self.colors = Colors;
		self.disallowVehicleSwap = true;

		self[ IsAddOnLoaded( "oUF_SpellRange" ) and "SpellRange" or "Range" ] = true;
		self.inRangeAlpha = 1.0;
		self.outsideRangeAlpha = 0.4;

		self:SetScript( "OnEnter", UnitFrame_OnEnter );
		self:SetScript( "OnLeave", UnitFrame_OnLeave );

		local Backdrop = _Clean.Backdrop.Add( self );
		self:SetHighlightTexture( [[Interface\QuestFrame\UI-QuestTitleHighlight]] );
		self:GetHighlightTexture():SetAllPoints( Backdrop );
		local Background = self:CreateTexture( nil, "BACKGROUND" );
		Background:SetAllPoints();
		Background:SetTexture( 0, 0, 0 );

		local Bars = CreateFrame( "Frame", nil, self );
		self.Bars = Bars;
		-- Portrait and overlapped elements
		if ( Style.PortraitSide ) then
			local Portrait = CreateFrame( "PlayerModel", nil, self );
			self.Portrait = Portrait;
			local Side = Style.PortraitSide;
			local Opposite = Side == "RIGHT" and "LEFT" or "RIGHT";
			Portrait:SetPoint( "TOP" );
			Portrait:SetPoint( "BOTTOM" );
			Portrait:SetPoint( Side );
			Portrait:SetWidth( Style[ "initial-height" ] );

			local Classification = Portrait:CreateTexture( nil, "OVERLAY" );
			local Size = Style[ "initial-height" ] * 1.35;
			self.Classification = Classification;
			Classification:SetPoint( "CENTER" );
			Classification:SetWidth( Size );
			Classification:SetHeight( Size );
			Classification:SetTexture( [[Interface\AchievementFrame\UI-Achievement-IconFrame]] );
			Classification:SetTexCoord( 0, 0.5625, 0, 0.5625 );
			Classification:SetAlpha( 0.8 );
			tinsert( self.__elements, me.ClassificationUpdate );
			self:RegisterEvent( "UNIT_CLASSIFICATION_CHANGED", me.ClassificationUpdate );

			local RaidIcon = Portrait:CreateTexture( nil, "OVERLAY" );
			Size = Style[ "initial-height" ] / 2;
			self.RaidIcon = RaidIcon;
			RaidIcon:SetPoint( "CENTER" );
			RaidIcon:SetWidth( Size );
			RaidIcon:SetHeight( Size );

			if ( IsAddOnLoaded( "oUF_CombatFeedback" ) ) then
				local FeedbackText = Portrait:CreateFontString( nil, "OVERLAY", "NumberFontNormalLarge" );
				self.CombatFeedbackText = FeedbackText;
				FeedbackText:SetPoint( "CENTER" );
				FeedbackText.ignoreEnergize = true;
				FeedbackText.ignoreOther = true;
			end

			Bars:SetPoint( "TOP" );
			Bars:SetPoint( "BOTTOM" );
			Bars:SetPoint( Side, Portrait, Opposite );
			Bars:SetPoint( Opposite );
		else
			Bars:SetAllPoints();
		end


		-- Health bar
		local Health = CreateBarReverse( self );
		self.Health = Health;
		Health:SetPoint( "TOPLEFT", Bars );
		Health:SetPoint( "RIGHT", Bars );
		Health:SetHeight( Style[ "initial-height" ] * ( 1 - Style.PowerHeight - Style.ProgressHeight ) );
		Health.SetStatusBarColor = me.SetStatusBarColor;
		CreateBarBackground( Health, 0.07 );
		Health.frequentUpdates = true;
		Health.colorDisconnected = true;
		Health.colorTapping = true;
		Health.colorSmooth = true;
		Health.smoothGradient = Colors.HealthSmooth;

		if ( Style.HealthText ) then
			local HealthValue = Health:CreateFontString( nil, "OVERLAY", Style.BarValueFont:GetName() );
			Health.Value = HealthValue;
			HealthValue:SetPoint( "TOPRIGHT", -2, 0 );
			HealthValue:SetPoint( "BOTTOM" );
			HealthValue:SetJustifyV( "MIDDLE" );
			HealthValue:SetAlpha( 0.75 );
			Health.ValueLength = Style.HealthText;
		end
		if ( IsAddOnLoaded( "oUF_HealComm4" ) ) then
			local HealCommBar = CreateFrame( "StatusBar", nil, Health );
			self.HealCommBar = HealCommBar;
			self.allowHealCommOverflow = true;
			HealCommBar:SetStatusBarTexture( BarTexture );
			local R, G, B = unpack( Colors.reaction[ 8 ] );
			HealCommBar:SetStatusBarColor( R, G, B, 0.5 );
		end

		self.PostUpdateHealth = me.PostUpdateHealth;


		-- Power bar
		local Power = CreateBar( self );
		self.Power = Power;
		Power:SetPoint( "TOPLEFT", Health, "BOTTOMLEFT" );
		Power:SetPoint( "RIGHT", Bars );
		Power:SetHeight( Style[ "initial-height" ] * Style.PowerHeight );
		Power.SetStatusBarColor = me.SetStatusBarColor;
		CreateBarBackground( Power, 0.14 );
		Power.frequentUpdates = true;
		Power.colorPower = true;

		if ( Style.PowerText ) then
			local PowerValue = Power:CreateFontString( nil, "OVERLAY", Style.BarValueFont:GetName() );
			Power.Value = PowerValue;
			PowerValue:SetPoint( "TOPRIGHT", -2, 0 );
			PowerValue:SetPoint( "BOTTOM" );
			PowerValue:SetJustifyV( "MIDDLE" );
			PowerValue:SetAlpha( 0.75 );
			Power.ValueLength = Style.PowerText;
		end

		self.PostUpdatePower = me.PostUpdatePower;


		-- Casting/rep/exp bar
		local Progress = CreateBar( self );
		Progress:SetStatusBarTexture( BarTexture );
		Progress:SetPoint( "BOTTOMLEFT", Bars );
		Progress:SetPoint( "TOPRIGHT", Power, "BOTTOMRIGHT" );
		Progress:SetAlpha( 0.8 );
		Progress:Hide();
		CreateBarBackground( Progress, 0.07 ):SetParent( Bars ); -- Show background while hidden
		if ( UnitID == "player" ) then
			if ( IsAddOnLoaded( "oUF_Experience" ) and UnitLevel( "player" ) ~= MAX_PLAYER_LEVEL and not IsXPUserDisabled() ) then
				self.Experience = Progress;
				Progress:SetStatusBarColor( unpack( Colors.Experience ) );
				Progress.PostUpdate = me.ExperiencePostUpdate;
				Progress:Show();
				local Rest = Progress:CreateTexture( nil, "ARTWORK" );
				Progress.RestTexture = Rest;
				Rest:SetTexture( BarTexture );
				Rest:SetVertexColor( unpack( Colors.ExperienceRested ) );
				Rest:SetPoint( "TOP" );
				Rest:SetPoint( "BOTTOM" );
				Rest:Hide();
			elseif ( IsAddOnLoaded( "oUF_Reputation" ) ) then
				self.Reputation = Progress;
				Progress.PostUpdate = me.ReputationPostUpdate;
			end
		elseif ( UnitID == "pet" ) then
			if ( IsAddOnLoaded( "oUF_Experience" ) and select( 2, UnitClass( "player" ) ) == "HUNTER" ) then
				self.Experience = Progress;
				Progress:SetStatusBarColor( unpack( Colors.Experience ) );
				Progress:Show();
			end
		else -- Castbar
			self.Castbar = Progress;
			Progress:SetStatusBarColor( unpack( Colors.Cast ) );

			local Time;
			if ( Style.CastTime ) then
				Time = Progress:CreateFontString( nil, "OVERLAY", me.FontMicro:GetName() );
				Progress.Time = Time;
				Time:SetPoint( "BOTTOMRIGHT", -6, 0 );
			end

			local Text = Progress:CreateFontString( nil, "OVERLAY", me.FontMicro:GetName() );
			Progress.Text = Text;
			Text:SetPoint( "BOTTOMLEFT", 2, 0 );
			if ( Time ) then
				Text:SetPoint( "RIGHT", Time, "LEFT" );
			else
				Text:SetPoint( "RIGHT", -2, 0 );
			end
			Text:SetJustifyH( "LEFT" );
		end


		-- Name
		local Name = Health:CreateFontString( nil, "OVERLAY", Style.NameFont:GetName() );
		self.Name = Name;
		Name:SetPoint( "LEFT", 2, 0 );
		if ( Health.Value ) then
			Name:SetPoint( "RIGHT", Health.Value, "LEFT" );
		else
			Name:SetPoint( "RIGHT", -2, 0 );
		end
		Name:SetJustifyH( "LEFT" );
		self:Tag( Name, "[_CleanUnitsName]" );


		-- Info string
		local Info = Health:CreateFontString( nil, "OVERLAY", me.FontTiny:GetName() );
		self.Info = Info;
		Info:SetPoint( "BOTTOM", 0, 2 );
		Info:SetPoint( "TOPLEFT", Name, "BOTTOMLEFT" );
		Info:SetJustifyV( "BOTTOM" );
		Info:SetAlpha( 0.8 );
		self:Tag( Info, "[_CleanUnitsClassification]" );


		if ( Style.Auras ) then
			-- Buffs
			local Buffs = CreateFrame( "Frame", nil, self );
			self.Buffs = Buffs;
			Buffs:SetPoint( "TOPLEFT", Backdrop, "BOTTOMLEFT" );
			Buffs:SetPoint( "RIGHT", Backdrop );
			Buffs:SetHeight( 1 );
			Buffs.initialAnchor = "TOPLEFT";
			Buffs[ "growth-y" ] = "DOWN";
			Buffs.size = Style.AuraSize;

			-- Debuffs
			local Debuffs = CreateFrame( "Frame", nil, self );
			self.Debuffs = Debuffs;
			Debuffs:SetPoint( "TOPLEFT", Buffs, "BOTTOMLEFT" );
			Debuffs:SetPoint( "RIGHT", Backdrop );
			Debuffs:SetHeight( 1 );
			Debuffs.initialAnchor = "TOPLEFT";
			Debuffs[ "growth-y" ] = "DOWN";
			Debuffs.showDebuffType = true;
			Debuffs.size = Style.AuraSize;

			self.PostCreateAuraIcon = me.PostCreateAuraIcon;
			self.PostUpdateAura = me.PostUpdateAura;
		end

		-- Debuff highlight
		if ( CreateDebuffHighlight and Style.DebuffHighlight ) then
			self.DebuffHighlight = CreateDebuffHighlight( self, Backdrop );
			self.DebuffHighlightAlpha = 1;
			self.DebuffHighlightFilter = Style.DebuffHighlight ~= "ALL";
		end


		-- Icons
		local function IconResize ( self )
			self:SetWidth( self:IsShown() and 16 or 1 );
		end
		local LastIcon;
		local function AddIcon ( Key )
			local Icon = Health:CreateTexture( nil, "ARTWORK" );
			hooksecurefunc( Icon, "Show", IconResize );
			hooksecurefunc( Icon, "Hide", IconResize );
			self[ Key ] = Icon;
			Icon:Hide();
			Icon:SetHeight( 16 );
			if ( LastIcon ) then
				Icon:SetPoint( "LEFT", LastIcon, "RIGHT" );
			else
				Icon:SetPoint( "TOPLEFT", 1, -1 );
			end
			LastIcon = Icon;
		end
		AddIcon( "Leader" );
		AddIcon( "MasterLooter" );
		if ( UnitID == "player" ) then
			AddIcon( "Resting" );
		end
	end




	-- Defaults
	me.StyleMeta.__call = Initialize;
	me.StyleMeta.__index = {
		[ "initial-width" ] = 130;
		[ "initial-height" ] = 50;

		PortraitSide = "RIGHT"; -- "LEFT"/"RIGHT"/false
		HealthText = "Small"; -- "Full"/"Small"/"Tiny"
		PowerText  = "Small"; -- Same as Health
		NameFont = me.FontNormal;
		BarValueFont = me.FontTiny;
		CastTime = true;
		Auras = true;
		AuraSize = 15;
		DebuffHighlight = true;

		PowerHeight = 0.25;
		ProgressHeight = 0.1;
	};

	oUF:RegisterStyle( "_CleanUnits", setmetatable( {
		[ "initial-width" ] = 160;
	}, me.StyleMeta ) );
	oUF:RegisterStyle( "_CleanUnitsSelf", setmetatable( {
		PortraitSide = false;
		HealthText = "Full";
		PowerText  = "Full";
		CastTime = false;
		DebuffHighlight = "ALL";
	}, me.StyleMeta ) );
	oUF:RegisterStyle( "_CleanUnitsSmall", setmetatable( {
		PortraitSide = "LEFT";
		HealthText = "Tiny";
		NameFont = me.FontTiny;
		CastTime = false;
		AuraSize = 10;
	}, me.StyleMeta ) );


	-- Top row
	oUF:SetActiveStyle( "_CleanUnitsSelf" );
	me.Player = oUF:Spawn( "player", "_CleanUnitsPlayer" );
	me.Player:SetPoint( "TOPLEFT", _Clean.TopMargin, "BOTTOMLEFT" );

	oUF:SetActiveStyle( "_CleanUnits" );
	me.Target = oUF:Spawn( "target", "_CleanUnitsTarget" );
	me.Target:SetPoint( "TOPLEFT", me.Player, "TOPRIGHT", 28, 0 );

	oUF:SetActiveStyle( "_CleanUnitsSmall" );
	me.TargetTarget = oUF:Spawn( "targettarget", "_CleanUnitsTargetTarget" );
	me.TargetTarget:SetPoint( "TOPLEFT", me.Target, "TOPRIGHT", 2 * _Clean.Backdrop.Padding, 0 );


	-- Bottom row
	oUF:SetActiveStyle( "_CleanUnitsSmall" );
	me.Pet = oUF:Spawn( "pet", "_CleanUnitsPet" );
	me.Pet:SetPoint( "TOPLEFT", me.Player, "BOTTOMLEFT", 0, -56 );

	oUF:SetActiveStyle( "_CleanUnits" );
	me.Focus = oUF:Spawn( "focus", "_CleanUnitsFocus" );
	me.Focus:SetPoint( "LEFT", me.Target );
	me.Focus:SetPoint( "TOP", me.Pet );

	oUF:SetActiveStyle( "_CleanUnitsSmall" );
	me.FocusTarget = oUF:Spawn( "focustarget", "_CleanUnitsFocusTarget" );
	me.FocusTarget:SetPoint( "LEFT", me.TargetTarget );
	me.FocusTarget:SetPoint( "TOP", me.Pet );


	if ( not _Clean.IsAddOnLoadable( "_Clean.Units.Arena" ) ) then
		-- Garbage collect initialization code
		me.StyleMeta.__call = nil;
	end
end
