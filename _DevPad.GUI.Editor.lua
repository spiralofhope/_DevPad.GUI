local GUI = select( 2, ... )
local NS = GUI.Dialog:New( '_DevPadGUIEditor' )
do  --  The main editor frame
  NS:SetMinResize( 100, 100 )
  -- TODO - relocate these variables.
  -- They apparently need to be in this file, even though they're not used in it.
  NS.DefaultWidth  = 500
  NS.DefaultHeight = 500
  function NS:OnShow()
    PlaySound( 844 )  --  igQuestListOpen / IG_QUEST_LOG_OPEN
  end
  NS:SetScript( 'OnShow', NS.OnShow )
  --- Close the open script.
  function NS:OnHide()
    PlaySound( 845 )  --  igQuestListClose / IG_QUEST_LOG_CLOSE
    StaticPopup_Hide( '_DEVPAD_GOTO' )
    if ( not self:IsShown() ) then -- Explicitly hidden, not obscured by world map
      return self:SetScriptObject()
    end
  end
  NS:SetScript( 'OnHide', NS.OnHide )
end

--local TAB_WIDTH = 2
--local AUTO_INDENT_LUA_SCRIPTS = true
local default_text_color_r = 1
local default_text_color_g = 1
local default_text_color_b = 1
local edit_line_color_r = 1
local edit_line_color_g = 1
local edit_line_color_b = 1
local edit_line_color_alpha = 0.1

do  --  fonts
  NS.font_size_steps =  1
  NS.font_size_minimum   =  6
  NS.font_size_maximum   = 34

  NS.default_font = [[Interface\AddOns\]]..( ... )..[[\Skin\DejaVuSansMono.ttf]]
  NS.Font = CreateFont( '_DevPadGUIEditorFont' )
  -- Font file paths for font cycling button
  NS.Font.Paths = {
    NS.default_font,
    [[Fonts\FRIZQT__.TTF]],
    [[Fonts\ARIALN.TTF]]
  }
end



local _DevPad = _DevPad
GUI.Editor = NS
-- Make the editor sticky to the list
GUI.Dialog.StickyFrames[ 'Editor' ] = NS

-- If too small, mouse dragging the text selection won't scroll the view easily:
-- TODO - I wonder if I ought do something like this, if scaling isn't going to be forced to be one:
--NS.TEXT_INSET = math.ceil( 8 * _DevPad_GUI_options.scale )
NS.TEXT_INSET = 8



do  --  Create basic frames
  NS.ScrollChild  = CreateFrame( 'Frame', nil, NS.ScrollFrame )
  NS.ScrollChild:SetSize( 1, 1 )
  NS.ScrollFrame:SetScrollChild( NS.ScrollChild )
  do  --  focus
    NS.Focus = CreateFrame( 'Frame', nil, NS.Window )
    NS.Focus:SetAllPoints( NS.ScrollFrame )
    function NS.Focus:OnMouseDown()                                     --  Focus the edit box text if empty space gets clicked.
      NS.Edit:HighlightText( 0, 0 )
      NS.Edit:ScrollToNextCursorPosition()
      NS.Edit:SetCursorPositionUnescaped( NS.Edit:ValidateCursorPosition( #NS.Script._Text ) )
      NS.Edit:SetFocus()
    end
    NS.Focus:SetScript( 'OnMouseDown', NS.Focus.OnMouseDown )
  end
  do  --  The main area
    do  --  The editor
      NS.Edit         = CreateFrame( 'EditBox', nil, NS.ScrollChild )


      do  --  Hook to add clicked links' code to the edit box.
        --  Test case:
        --    - Open the spell book (perhaps with the hotkey `p`)
        --    - Open DevPad (`enter` `/devpad`)
        --    - Create a new item
        --    - Change it from type "lua" to type "text"
        --    - Click in the editor area
        --    - Shift-click a spell icon from the spellbook
        local Backup = ChatEdit_InsertLink
        --- Hook to add clicked links' code to the edit box.
        function NS.ChatEditInsertLink ( Link, ... )
          if ( Link and NS.Edit:HasFocus() ) then
            NS.Edit:Insert( NS.Edit.Lua and Link:gsub( '|', '||' ) or Link )
            return true
          end
          return Backup( Link, ... )
        end
      end


      do  --  Hook to keep the chat edit box open when focusing the editor.
        local Backup = ChatEdit_OnEditFocusLost
        function NS:ChatEditOnEditFocusLost ( ... )
          if ( IsMouseButtonDown() ) then
            local Focus = GetMouseFocus()
            if ( Focus and ( Focus == NS.Edit or Focus == NS.Focus or Focus == NS.Margin ) ) then
              return -- Probably clicked the editor to change focus
            end
          end
          return Backup( self, ... )
        end
      end


      NS.Edit:SetPoint( 'TOPLEFT', NS.TEXT_INSET, 0 )
      NS.Edit:SetPoint( 'RIGHT', NS.ScrollFrame )
      NS.Edit:SetAutoFocus( false )
      NS.Edit:SetMultiLine( true )
      NS.Edit:SetFontObject( NS.Font )
      NS.Edit:SetTextInsets( 0, NS.TEXT_INSET, NS.TEXT_INSET, NS.TEXT_INSET )
      NS.Edit:SetTextColor( 
        default_text_color_r, 
        default_text_color_g, 
        default_text_color_b
      )
      NS.Edit:SetScript( 'OnEscapePressed', NS.Edit.ClearFocus )

      function NS.Edit:OnTextChanged()                                  --  Saves text immediately after it changes.
        if ( NS.Script ) then
          local Text = self:GetText()
          NS.Script:SetText( self.Lua and Text:gsub( '||', '|' ) or Text )
        end
      end
      NS.Edit:SetScript( 'OnTextChanged', NS.Edit.OnTextChanged )
      --- Links/opens the clicked link.
      function NS.Edit:OnMouseUp( MouseButton )
        if ( self.Lua ) then
          return
        end
        local Text = NS.Script._Text
        local Cursor = self:GetCursorPositionUnescaped()

        -- Find first unescaped link delimiter
        local LinkEnd, Start, Code = Cursor
        while ( LinkEnd ) do
          Start, LinkEnd, Code = Text:find( "|+([Hh])", LinkEnd + 1 )
          if ( LinkEnd and ( LinkEnd - Start ) % 2 == 1 ) then -- Pipes not escaped
            break
          end
        end
        if ( Code ~= 'h' ) then
          return -- Not inside a link
        end

        -- Find start of link
        local End, Start, LinkStart = 0
        while ( End ) do
          Start, End = Text:find( "|+H", End + 1 )
          if ( End ) then
            if ( End > Cursor ) then
              break
            elseif ( ( End - Start ) % 2 == 1 ) then -- Pipes not escaped
              LinkStart = Start
            end
          end
        end

        if ( LinkStart and LinkEnd ) then
          local Link = Text:sub( LinkStart, LinkEnd )
          local ChatEdit = ChatEdit_GetActiveWindow()
          if ( ChatEdit and IsModifiedClick( 'CHATLINK' ) ) then
            ChatEdit:SetFocus()
          end
          SetItemRef( Link:match( "^|H(.-)|h" ), Link, MouseButton )
        end
      end
      NS.Edit:SetScript( 'OnMouseUp', NS.Edit.OnMouseUp )
      function NS.Edit:OnTabPressed()                                   --  Simulate a tab character with spaces.
        self:Insert( ( ' ' ):rep( _DevPad_tab_width() ) )
      end
      NS.Edit:SetScript( 'OnTabPressed', NS.Edit.OnTabPressed )
      function NS.Edit:OnCursorChanged( CursorX, CursorY, CursorWidth, CursorHeight )  --  Move the edit box's view to follow the cursor.
        local LastX
        local LastY
        local LastWidth
        local LastHeight
        --_DevPad_debug( ' -- ' )
        --_DevPad_debug( 'Cursor position: x=' .. CursorX     .. ' y=' .. CursorY      )
        --_DevPad_debug( 'Cursor size:     w=' .. CursorWidth .. ' h=' .. CursorHeight )
        self.LineHeight = CursorHeight
        -- Update line highlight
        self.Line:SetHeight( CursorHeight )
        self.Line:SetPoint( 'TOP', 0, CursorY - NS.TEXT_INSET )

        if ( self.CursorForceUpdate
          -- Force view to cursor, even if it didn't change
          or ( self:HasFocus() and (
            -- Only move view when cursor *moves*
               LastX ~= CursorX
            or LastY ~= CursorY
            or LastWidth  ~= CursorWidth
            or LastHeight ~= CursorHeight
        ) ) ) then
          self.CursorForceUpdate = nil
          LastX = CursorX
          LastY = CursorY
          LastWidth  = CursorWidth
          LastHeight = CursorHeight

          local Top    = -CursorY
          local Bottom = CursorHeight + ( 2 * NS.TEXT_INSET ) - CursorY

      --_DevPad_debug( CursorHeight .. ' - ' .. ( 2 * NS.TEXT_INSET ) .. ' .. ' .. CursorY )
      --_DevPad_debug( Bottom )

          NS.ScrollFrame:SetVerticalScrollToCoord( Top, Bottom )
        end
      end
      NS.Edit:SetScript( 'OnCursorChanged', NS.Edit.OnCursorChanged )
    end


    --  TODO - "shortcuts" doesn't make sense to me.  This is not hotkey functionality.
    do  --  Editor shortcuts
      NS.Shortcuts = CreateFrame( 'Frame',   nil, NS.Edit )
      NS.Shortcuts:SetPropagateKeyboardInput( true )
      NS.Shortcuts:EnableKeyboard( false )
      function NS.Shortcuts:OnHide()                                    --  Cancels pending focus change.
        self:SetScript( 'OnUpdate', nil )
      end
      NS.Shortcuts:SetScript( 'OnHide', NS.Shortcuts.OnHide )
      function NS.Edit:OnEditFocusGained()
        --  Start listening for shortcut keys.
        NS.Shortcuts:EnableKeyboard( true )
      end
      NS.Edit:SetScript( 'OnEditFocusGained', NS.Edit.OnEditFocusGained )
      function NS.Edit:OnEditFocusLost()
        --  Stop listening for shortcut keys.
        NS.Shortcuts:EnableKeyboard( false )
      end
      NS.Edit:SetScript( 'OnEditFocusLost', NS.Edit.OnEditFocusLost )
      function NS.Shortcuts:OnKeyDown( Key )
        --  Stop listening for control commands.
        if ( self[ Key ] ) then
          return self[ Key ]( self, Key )
        end
      end
      NS.Shortcuts:SetScript( 'OnKeyDown', NS.Shortcuts.OnKeyDown )
      do  --  TODO - describe
        local PendingEditBox
        --- Sets keyboard focus on next frame.
        local function OnUpdate( self )
          self:SetScript( 'OnUpdate', nil )
          PendingEditBox:HighlightText()
          return PendingEditBox:SetFocus()
        end
        --- Changes the keyboard focus after a shortcut gets processed.
        -- This prevents the new edit box from receiving the original shortcut key.
        function NS.Shortcuts:SetFocus( EditBox )
          PendingEditBox = EditBox
          self:SetScript( 'OnUpdate', OnUpdate )
        end
      end
    end

    do  -- Cursor line highlight
      NS.Edit.Line    = NS.Edit:CreateTexture()
      NS.Edit.Line:SetPoint( 'LEFT', Margin )
      NS.Edit.Line:SetPoint( 'RIGHT' )
      NS.Edit.Line:SetColorTexture(
        edit_line_color_r, 
        edit_line_color_g, 
        edit_line_color_b, 
        edit_line_color_alpha
      )
    end

  end

  --  NS.Background was never implemented
  --NS.Background:SetColorTexture( 0.05, 0.05, 0.06 ) -- Text background
end
ChatEdit_InsertLink = NS.ChatEditInsertLink
ChatEdit_OnEditFocusLost = NS.ChatEditOnEditFocusLost



do  --  Indentation and color
  if ( GUI.IndentationLib ) then
    local T = GUI.IndentationLib.Tokens
    NS.SyntaxColors = {}
    --- Assigns a color to multiple tokens at once.
    local function Color( Code, ... )
    --_DevPad_debug( 'local function Color(' .. Code, ... .. ' )' )
    --_DevPad_debug( 'local function Color(' .. Code .. ' )' )
      for Index = 1, select( '#', ... ) do
        NS.SyntaxColors[ select( Index, ... ) ] = Code
      end
    end
    -- Reserved words
    Color( "|cff88bbdd", T.KEYWORD )
    Color( "|cffff6666", T.UNKNOWN )
    Color( "|cffcc7777", T.CONCAT, T.VARARG, T.ASSIGNMENT, T.PERIOD, T.COMMA, T.SEMICOLON, T.COLON, T.SIZE )
    Color( "|cffffaa00", T.NUMBER )
    Color( "|cff888888", T.STRING, T.STRING_LONG )
    Color( "|cff55cc55", T.COMMENT_SHORT, T.COMMENT_LONG )
    Color( "|cffccaa88", T.LEFTCURLY, T.RIGHTCURLY, T.LEFTBRACKET, T.RIGHTBRACKET, T.LEFTPAREN, T.RIGHTPAREN, T.ADD, T.SUBTRACT, T.MULTIPLY, T.DIVIDE, T.POWER, T.MODULUS )
    Color( "|cffccddee", T.EQUALITY, T.NOTEQUAL, T.LT, T.LTE, T.GT, T.GTE )
    Color(
      "|cff55ddcc", 
      -- Minimal standard Lua functions
      'assert', 'error', 'ipairs', 'next', 'pairs', 'pcall', 'print', 'select', 'tonumber', 'tostring', 'type', 'unpack',
      -- Libraries
      'bit', 'coroutine', 'math', 'string', 'table'
    )
    -- Some of WoW's aliases for standard Lua functions
    Color(
      "|cffddaaff",
      -- math
      'abs', 'ceil', 'floor', 'max', 'min',
      -- string
      'format', 'gsub', 'strbyte', 'strchar', 'strconcat', 'strfind', 'strjoin', 'strlower', 'strmatch', 'strrep', 'strrev', 'strsplit', 'strsub', 'strtrim', 'strupper', 'tostringall',
      -- table
      'sort', 'tinsert', 'tremove', 'wipe'
    )
  end
end



function NS:SetScriptObject( Script )                                   --  TODO - describe
  --  @return True if script changed.
  -- Script is a table, so it can't be debugged like this.. yet.
  --_DevPad_debug( 'function NS:SetScriptObject( ' .. Script .. ' )' )
  if ( self.Script ~= Script ) then
    if ( self.Script ) then
      self.Script._EditCursor = self.Edit:GetCursorPositionUnescaped()
    end
    self.Script = Script
    if ( Script ) then
      _DevPad.RegisterCallback( self, 'ObjectSetName' )
      _DevPad.RegisterCallback( self, 'ScriptSetText' )
      _DevPad.RegisterCallback( self, 'ScriptSetLua'  )
      if ( Script._Parent ) then
        _DevPad.RegisterCallback( self, 'FolderRemove' )
      end
      self.ScrollFrame.Bar:SetValue( 0 )
      self:ObjectSetName( nil, Script )
      self:ScriptSetText( nil, Script )
      self:ScriptSetLua(  nil, Script )
      self.Edit:ScrollToNextCursorPosition()
      self.Edit:SetCursorPositionUnescaped(
        self.Edit:ValidateCursorPosition( Script._EditCursor or 0 )
      )
      self:Show()
    else
      _DevPad.UnregisterCallback( self, 'ObjectSetName' )
      _DevPad.UnregisterCallback( self, 'ScriptSetText' )
      _DevPad.UnregisterCallback( self, 'ScriptSetLua'  )
      _DevPad.UnregisterCallback( self, 'FolderRemove'  )
      self:Hide()
      self.Edit:ClearFocus()
    end
    GUI.Callbacks:Fire( 'EditorSetScriptObject', Script )
    return true
  end
end



function NS:SetFont( font_path, font_size )
  --  @return True if font changed.
  font_path = font_path or NS.default_font
  font_size = font_size or 10
  if ( ( self.FontPath ~= font_path or self.FontSize ~= font_size )
    and self.Font:SetFont( font_path, font_size )
  ) then
    self.FontPath = font_path
    self.FontSize = font_size
    GUI.Callbacks:Fire( 'EditorSetFont', font_path, font_size )
    _DevPad_debug( 'font size changed to ' .. font_size )
    _DevPad_debug( font_path )
    return true
  end
end



do  --  TODO                                                            --  bunches of stuff, in a do block made by saiket
  --- @return Number of Substring found between cursor positions Start and End.
  local function CountSubstring( Text, Substring, Start, End )
    --_DevPad_debug( 'local function CountSubstring( ' .. Text .. ' - ' .. Substring .. ' - ' .. Start .. ' - ' .. End .. ' )' )
    --_DevPad_debug( 'local function CountSubstring( '                  .. Substring .. ' - ' .. Start .. ' - ' .. End .. ' )' )
    if ( Start >= End ) then
      return 0
    end
    local Count = 0
    Start = Start + 1
    End = End - #Substring + 1
    while ( true ) do
      Start = Text:find( Substring, Start, true )
      if ( not Start or Start > End ) then
        --_DevPad_debug( Count .. ' Substring found between cursor positions Start and End' )
        return Count
      end
      Count = Count + 1
      Start = Start + #Substring
    end
  end
  --- Highlights a substring in the editor, accounting for escaped pipes.
  function NS.Edit:HighlightTextUnescaped( Start, End )
    --_DevPad_debug( 'function NS.Edit:HighlightTextUnescaped( ' .. Start .. ' - ' .. End .. ' )' )
    if ( self.Lua ) then
      local PipesBeforeStart
      if ( Start or End ) then
        PipesBeforeStart = CountSubstring( NS.Script._Text, '|', 0, Start or 0 )
      end
      if ( End ) then
        End = End + PipesBeforeStart + CountSubstring( NS.Script._Text, "|", Start or 0, End )
      end
      if ( Start ) then
        Start = Start + PipesBeforeStart
      end
    end
    return self:HighlightText( Start, End )
  end
  --- Forces the cursor into view the next time it moves, even if this editbox isn't focused.
  function NS.Edit:ScrollToNextCursorPosition()
    --_DevPad_debug( 'function NS.Edit:ScrollToNextCursorPosition()' )
    self.CursorForceUpdate = true
  end
  --- Moves the cursor to a position in the current script, accounting for escaped pipes.
  function NS.Edit:SetCursorPositionUnescaped( Cursor )
    --_DevPad_debug( 'function NS.Edit:SetCursorPositionUnescaped( ' .. Cursor .. ' )' )
    if ( self.Lua ) then
      Cursor = Cursor + CountSubstring( NS.Script._Text, '|', 0, Cursor )
    end
    return self:SetCursorPosition( Cursor )
  end
  --- @return Cursor position, ignoring extra pipe escape characters.
  function NS.Edit:GetCursorPositionUnescaped()
    --_DevPad_debug( 'function NS.Edit:GetCursorPositionUnescaped()' )
    local Cursor = self:GetCursorPosition()
    if ( self.Lua ) then
      Cursor = Cursor - CountSubstring( self:GetText(), '||', 0, Cursor )
      --_DevPad_debug( 'Cursor is saved at ' .. Cursor .. ' characters in.' )
    end
    --_DevPad_debug( 'NS.Edit:GetCursorPositionUnescaped() - Cursor = ' .. Cursor )
    return Cursor
  end
end



do  --  deal with pipes in text
  local BYTE_PIPE = ( '|' ):byte()
  local function IsPipeActive( Text, Position )
    -- @return True if the pipe at Position isn't escaped.
    --_DevPad_debug( 'local function IsPipeActive( ' .. Text .. ' - ' .. Position .. ' )' )
    --_DevPad_debug( 'local function IsPipeActive( <text>, ' .. Position .. ' )' )
    local Pipes = 0
    for Index = Position, 1, -1 do
      if ( Text:byte( Index ) ~= BYTE_PIPE ) then
        break
      end
      Pipes = Pipes + 1
    end
    --_DevPad_debug( 'Pipes ' .. Pipes )
    return Pipes % 2 == 1
  end
  local COLOR_LENGTH = 10
  --- Moves the cursor if it's currently in an invalid position.
  -- The cursor cannot be placed just after color codes or just before color
  --   terminators.  On live realms, the cursor interacts with codes in these
  --   positions like visible characters, which is confusing.  On builds with
  --   debug assertions enabled, doing this crashes the game instead.
  function NS.Edit:ValidateCursorPosition( Cursor )
    --_DevPad_debug( 'NS.Edit:ValidateCursorPosition( ' .. Cursor .. ' )' )
    if ( self.Lua ) then
      _DevPad_debug( 'Pipes are escaped' )
      return Cursor
    end
    local Text = NS.Script._Text
    if ( Cursor > 0 and IsPipeActive( Text, Cursor ) ) then
      Cursor = Cursor - 1 -- Can't be just after an active pipe
    end
    local __, End = Text:find( "^|[Rr]", Cursor + 1 )
    if ( End ) then -- Cursor is just before a color terminator
      --_DevPad_debug( 'Cursor is just before a color terminator' )
      Cursor = End
    elseif ( Cursor > 0 ) then
      local Start = Text:find( "|[Cc]%x%x%x%x%x%x%x%x", max( 1, Cursor - COLOR_LENGTH + 1 ) )
      --_DevPad_debug( 'NS.Edit:ValidateCursorPosition() - Start: '  .. tostring( Start )  )
      if ( Start and Start <= Cursor ) then -- Cursor is in or just after a color code
        Cursor = Start - 1
      end
    end
    --_DevPad_debug( 'NS.Edit:ValidateCursorPosition() - Cursor returned as: ' .. Cursor )
    return Cursor
  end
end



do  --  Color and auto-tabbing
  local function SetVertexColors( self, ... )                           --  Sets both button textures' vertex colors.
    -- TODO? - debug text
    self:GetNormalTexture():SetVertexColor( ... )
    self:GetPushedTexture():SetVertexColor( ... )
  end
  function NS:ScriptSetLua( _, Script )                                 --  Enables or disables syntax highlighting in the edit box.
    -- TODO? - debug text
    if not Script == self.Script then return nil end
    local Edit = self.Edit
    if ( Script._Lua ) then
      -- Escape control codes
      SetVertexColors( self.Lua, 0.4, 0.8, 1 )
      local Cursor = Edit:GetCursorPositionUnescaped()
      Edit.Lua = true
      Edit:SetText( self.Script._Text:gsub( '|', '||' ) )
      Edit:SetCursorPositionUnescaped( Cursor )
      if ( GUI.IndentationLib ) then
        GUI.IndentationLib.Enable( Edit, -- Suppress immediate auto-indent
          _DevPad_auto_indent_lua_scripts() and _DevPad_tab_width(), self.SyntaxColors, true )
      end
    elseif ( Edit.Lua ) then
      -- Disable syntax highlighting and unescape control codes
      SetVertexColors( self.Lua, 0.4, 0.4, 0.4 )
      if ( GUI.IndentationLib ) then
        GUI.IndentationLib.Disable( Edit )
      end
      local Cursor = Edit:GetCursorPositionUnescaped()
      Edit.Lua = false
      Edit:SetText( self.Script._Text )
      Edit:SetCursorPositionUnescaped( Edit:ValidateCursorPosition( Cursor ) )
    end
  end
end



function NS:ListSetSelection( _, Object )                               --  Shows the selected script from the list frame.
  -- TODO? - debug text
  if ( Object and Object._Class == 'Script' ) then
    return self:SetScriptObject( Object )
  end
end
GUI.RegisterCallback( NS, 'ListSetSelection' )






function NS:ScriptSetText( _, Script )                                  --  Synchronizes editor text with the script object if it gets set externally while editing.
  -- TODO? - debug text
  if ( Script == self.Script ) then
    local Text = self.Edit.Lua and Script._Text:gsub( '|', '||' ) or Script._Text
    -- Don't clear syntax highlighting unnecessarily
    if ( self.Edit:GetText() ~= Text ) then
      self.Edit:SetText( Text )
      if ( self.Edit.Lua and GUI.IndentationLib ) then -- Immediately recolor
        GUI.IndentationLib.Update( self.Edit, false )  -- Suppress auto-indent
      end
    end
  end
end



function NS:FolderRemove( _, _, Object )                                --  Hides the editor if the edited script gets removed.
  -- TODO? - debug text
  if ( Object == self.Script
    or ( Object._Class == 'Folder' and Object:Contains( self.Script ) )
  ) then
    self:SetScriptObject()
  end
end




do  --  Title (top bar)
  do  --  Run button
    NS.Run = CreateFrame( 'Button', nil, NS )
    function NS.Run:OnClick()                                               --  Runs the open script.
      PlaySound( 823 )  --  igMiniMapZoomIn / IG_MINIMAP_ZOOM_IN
      return _DevPad.SafeCall( NS.Script )
    end
    local Run = NS.Run
    Run:SetSize( 26, 26 )
    Run:SetPoint( 'TOPLEFT', 5, 1 )
    Run:SetHitRectInsets( 4, 4, 4, 4 )
    Run:SetNormalTexture( [[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]] )
    Run:SetPushedTexture( [[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]] )
    Run:SetHighlightTexture( [[Interface\BUTTONS\UI-ScrollBar-Button-Overlay]] )
    local Highlight = Run:GetHighlightTexture()
    Highlight:SetDesaturated( true )
    Highlight:SetVertexColor( 0.2, 0.8, 0.4 )
    Highlight:SetTexCoord( 0.13, 0.87, 0.13, 0.82 )
    Run:SetScript( 'OnEnter', GUI.Dialog.ControlOnEnter )
    Run:SetScript( 'OnLeave', GameTooltip_Hide )
    Run:SetScript( 'OnClick', Run.OnClick )
    Run.tooltipText = GUI.L.SCRIPT_RUN
  end


  --  Title text
  function NS:ObjectSetName( __, Object )
    if ( Object == self.Script ) then
      _DevPad_debug( 'Updating the title to:' )
      _DevPad_debug( Object._Name )
      self.Title:SetText( Object._Name )
      NS.Title:SetPoint( 'TOPLEFT', NS.Run, 'TOPRIGHT', 0, -7 )
      NS.Title:SetJustifyH( 'LEFT' )
    end
  end


  do  --  Font decrease button
    NS.FontDecrease = NS:NewButton( [[Interface\Icons\Spell_ChargeNegative]] )
    function NS.FontDecrease:OnClick()
      return NS:SetFont( NS.FontPath, max( NS.font_size_minimum, NS.FontSize - NS.font_size_steps ) )
    end
  end


  do  --  Font increase button
    NS.FontIncrease = NS:NewButton( [[Interface\Icons\Spell_ChargePositive]] )
    function NS.FontIncrease:OnClick()
      return NS:SetFont( NS.FontPath, min( NS.font_size_maximum, NS.FontSize + NS.font_size_steps ) )
    end
  end


  do  --  Font cycle button
    NS.cycle_through_fonts = NS:NewButton( [[Interface\ICONS\INV_Misc_Note_04]]     )
    function NS.cycle_through_fonts:OnClick()
      local Paths = NS.Font.Paths
      local NewIndex = 1
      for Index = 1, #Paths - 1 do
        if ( NS.FontPath == Paths[ Index ] ) then
          NewIndex = Index + 1
          break
        end
      end
      return NS:SetFont( Paths[ NewIndex ], NS.FontSize )
    end
  end


  do  --  Toggle Lua mode button
    --  TODO - Rename NS.Lua  -  I've been unable to do this.
    NS.Lua = NS:NewButton( [[Interface\MacroFrame\MacroFrame-Icon]] )
    function NS.Lua:OnClick()
      return NS.Script:SetLua( not NS.Script._Lua )
    end
  end


  local function SetupTitleButton( Button, TooltipText, Offset )
    NS:AddTitleButton( Button, ( Offset or 0 ) - 2 )
    Button:SetScript( 'OnClick', Button.OnClick )
    Button:SetMotionScriptsWhileDisabled( true )
    Button.tooltipText = TooltipText
  end
  SetupTitleButton( NS.Lua, GUI.L.LUA_TOGGLE )
  SetupTitleButton( NS.cycle_through_fonts, GUI.L.FONT_CYCLE, -8 )
  SetupTitleButton( NS.FontIncrease, GUI.L.FONT_INCREASE )
  SetupTitleButton( NS.FontDecrease, GUI.L.FONT_DECREASE )
end







-- TODO - Simplify
--   All of this seems overly complex, and simpler code could be borrowed from elsewhere.
do
  local Pack = NS.Pack
  --- Saves font, position, and size information for saved variables.
  function NS:Pack( ... )
    local Options = Pack( self, ... )
    Options.FontPath = self.FontPath
    Options.FontSize = self.FontSize
    if ( self.Color ) then
      Options.Color = self.Color:Pack()
    end
    return Options
  end
  local Unpack = NS.Unpack
  --- Loads font, position, and size from saved variables.
  function NS:Unpack( Options, ... )
    self:SetFont( Options.FontPath, Options.FontSize )
    if ( self.Color ) then
      self.Color:Unpack( Options.Color or {} )
    end
    return Unpack( self, Options, ... )
  end
end
NS:Unpack( {} ) -- Default position/size and font
