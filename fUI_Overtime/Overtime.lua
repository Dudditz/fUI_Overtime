  
  local E, S
  
  --- Initialization ---
  local numTabs = 20
  local skinUI, loadedUI
  
  local function InitDB()
	-- Create new DB if needed --
	if (not CTradeSkillDB) then
		CTradeSkillDB = {}
	end
	if not CTradeSkillDB['Tabs'] then CTradeSkillDB['Tabs'] = {} end

  end

local ToyIDs = {
    [134020] = true,  --Chef's Hat
    [127652] = true,  --Felflame Campfire
    [153039] = true,  --Crystalline Campfire
    [163211] = true,  --Akunda's Firesticks
    [116757] = true,  --Steamworks Sausage Grill
    [182780] = true,  --Muckpool Cookpot
    [104309] = true,  --Eternal Kiln
    [116435] = true,  --Cozy Bonfire
    [198402] = true,  --Maruuk Cooking Pot
    [128536] = true,  --Leylight Brazier
}

--[67097]  = true,  --Grim Campfire
--[70722]  = true,  --Little Wickerman
--[219403] = true,  --Stonebound Lantern
--[199892] = true,  --Tuskarr Traveling Soup Pot
--[184404] = true,  --Ever-Abundant Hearth
--[203757] = true,  --Brazier of Madness

  -------------------------------------------------
  ---Create Frame ---
  -------------------------------------------------
  
  local f = CreateFrame('Frame', 'Overtime')
  f:RegisterEvent('PLAYER_LOGIN')
  f:RegisterEvent('TRADE_SKILL_LIST_UPDATE')
  f:RegisterEvent('TRADE_SKILL_DATA_SOURCE_CHANGED')
  f:RegisterEvent('TRADE_SKILL_SHOW')
  f:RegisterEvent("TOYS_UPDATED")
  
  -------------------------------------------------
  --- Check Current Tab ---
  -------------------------------------------------
  
  local function isCurrentTab(self)
   if self.tooltip and C_Spell.IsCurrentSpell(self.tooltip) then
   if ProfessionsFrame:IsShown() and (self.isSub == 0) then
    CTradeSkillDB['Panel'] = self.id
    end
   end
  end

  -------------------------------------------------
  --- Skin With ElvUI ---
  -------------------------------------------------
  local function SkinTab(tab)
   if not (E and S and E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then
    return
   end

   if tab.isSkinned then return end

   -- Disable Blizzard highlight texture ONLY
   if tab:GetHighlightTexture() then
    tab:GetHighlightTexture():SetAlpha(0)
   end

   S:HandleButton(tab)

   if tab.Icon then
    tab.Icon:SetTexCoord(unpack(E.TexCoords))
    tab.Icon:ClearAllPoints()
    tab.Icon:SetInside(tab)
   end

    tab.isSkinned = true
  end

  -------------------------------------------------
  --- Add Tab Button ---
  -------------------------------------------------
  
  local function addTab(id, index, isSub)

    local name, icon, tabType

    if ToyIDs[id] then
    local itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(id)

    name = toyName
    icon = toyIcon
    tabType = "toy"

    if not name then
        name = " "
    end

    if not icon then
        icon = "Interface\\Icons\\INV_Misc_QuestionMark"
    end

    elseif id == 87216 then
        name = GetItemInfo(id)
        icon = C_Item.GetItemIconByID(id)
        tabType = "item"

    else
        name = C_Spell.GetSpellName(id)
        icon = C_Spell.GetSpellTexture(id)
        tabType = "spell"
    end

  local tab = _G['CTradeSkillTab' .. index] or CreateFrame('Button', 'CTradeSkillTab' .. index, ProfessionsFrame, "ActionButtonTemplate, SecureActionButtonTemplate")
    
   if tab:GetHighlightTexture() then
    tab:GetHighlightTexture():SetAlpha(0)
   end
	
   if tab:GetPushedTexture() then
    tab:SetPushedTexture("UI-HUD-ActionBar-IconFrame")
	local pushedTexture = tab:GetPushedTexture()
	pushedTexture:SetSize(46, 46)
  end
	 
    tab:SetScript('OnEvent', isCurrentTab)
    tab:RegisterEvent('TRADE_SKILL_SHOW')
    tab:RegisterEvent('CURRENT_SPELL_CAST_CHANGED')
    tab:SetSize(46, 46)
	tab:RegisterForClicks("AnyUp", "AnyDown")

   -- Create icon texture
   if not tab.Icon then
    tab.Icon = tab:CreateTexture(nil, "ARTWORK")
    tab.Icon:SetPoint("TOPLEFT", 3.4, -3.4)
    tab.Icon:SetPoint("BOTTOMRIGHT", -3.4, 3.4)
    tab.Icon:SetTexCoord(.08, .92, .08, .92)
   end

    tab.Icon:SetTexture(icon)

    tab.id = id
    tab.isSub = isSub
    tab.tooltip = name
	  
    tab:SetAttribute('type', tabType)

   if tabType == 'spell' then
    tab:SetAttribute('spell', id)
   elseif tabType == 'item' then
    tab:SetAttribute('item', name) -- items still require name or item link
   elseif tabType == 'toy' then
    tab:SetAttribute('toy', id)
   end
		
    tab:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")

    if self.isSub == 1 and ToyIDs[self.id] then
    local _, toyName = C_ToyBox.GetToyInfo(self.id)
    GameTooltip:SetText(toyName or ("Toy "..self.id), 1,1,1)
    else
        GameTooltip:SetText(self.tooltip, 1,1,1)
    end
    end)  
    tab:SetScript("OnLeave", function(self, motion)
	   GameTooltip:Hide()
       end)
		
    isCurrentTab(tab)
    tab:Show()
	
	SkinTab(tab)
	
  end
  
  -------------------------------------------------
  --- Remove Tab Buttons ---
  -------------------------------------------------
  
  local function removeTabs()
   for i = 1, numTabs do
   local tab = _G['CTradeSkillTab' .. i]	
			
   if tab and tab:IsShown() then
    tab:UnregisterEvent('TRADE_SKILL_SHOW')
	tab:UnregisterEvent('CURRENT_SPELL_CAST_CHANGED')
	tab:Hide()
   end
   end
  end

  -------------------------------------------------
  --- Sort Tabs ---
  -------------------------------------------------
  
  local MAX_VISIBLE_TABS = 11  -- what fits visually

  local function sortTabs()
   local index = 1

   for i = 1, numTabs do
   local tab = _G['CTradeSkillTab' .. i]
   if tab then
   if CTradeSkillDB['Tabs'][tab.id] == true and index <= MAX_VISIBLE_TABS then
    tab:SetPoint('TOPLEFT', ProfessionsFrame, 'TOPRIGHT', 1, (-48 * index) + (-40 * tab.isSub))
    tab:Show()
    index = index + 1
   else
    tab:Hide()
   end
   end
   end
  end

  -------------------------------------------------
  --- Check Profession Useable ---
  -------------------------------------------------
  
  local function isUseable(id)
  local name = C_Spell.GetSpellInfo(id)
		
   return C_SpellBook.IsSpellBookItemUsable(name)
	
  end

  -------------------------------------------------
  --- Update Profession Tabs ---
  -------------------------------------------------
  
  local function updateTabs(init)
  
  local mainTabs, subTabs = {}, {}

  local _, class = UnitClass('player')
   if class == 'DEATHKNIGHT' then
    tinsert(subTabs, 53428) --RuneForging
  elseif class == 'ROGUE' then
    tinsert(subTabs, 1804) --PickLock
  end
     
  --- Add Toys --- 
   if PlayerHasToy(134020) then
    tinsert(subTabs, 134020) --ChefHat
  end
   if PlayerHasToy(127652) then
    tinsert(subTabs, 127652) --Felflame Campfire
  end
   if PlayerHasToy(153039) then
    tinsert(subTabs, 153039) --Crystalline Campfire
  end
   if PlayerHasToy(163211) then
	 tinsert(subTabs, 163211) --Akunda's Fire Sticks
  end
   if PlayerHasToy(116757) then
	 tinsert(subTabs, 116757) --steamworks-sausage-grill
  end
   if PlayerHasToy(182780) then
	 tinsert(subTabs, 182780) --Muckpool Cookpot
  end
  if PlayerHasToy(104309) then
	 tinsert(subTabs, 104309) --Eternal Kiln
  end
  if PlayerHasToy(67097) then
	 tinsert(subTabs, 67097) --Grim Campfire
  end
  if PlayerHasToy(116435) then
	 tinsert(subTabs, 116435) --Cozy Bonfire
  end
  if PlayerHasToy(198402) then
	 tinsert(subTabs, 198402) --Maruuk Cooking Pot
  end
  if PlayerHasToy(128536) then
	 tinsert(subTabs, 128536) --Leylight Brazier
  end
   if GetItemCount(87216) ~= 0 then
	 tinsert(subTabs, 126462) --ThermalAnvil
  end
  
  local prof1, prof2, arch, fish, cook = GetProfessions()
  local profs = {prof1, prof2, fish, cook}
				
  for _, prof in pairs(profs) do
  local num, offset, line, _, _, spec = select(5, GetProfessionInfo(prof))
   if (spec and spec ~= 0) then num = 1 
  end
  
  for i = 1, num do
   if not C_SpellBook.IsSpellBookItemPassive(offset + i, Enum.SpellBookSpellBank.Player) 
  then
  local info = C_SpellBook.GetSpellBookItemInfo(offset + i, Enum.SpellBookSpellBank.Player)
  local id = info and info.spellID
  if (i == 1) then
    tinsert(mainTabs, id)
  if init and not CTradeSkillDB['Panel'] then
    CTradeSkillDB['Panel'] = line
  return
  end
  
  else
    tinsert(subTabs, id)
  end
  end
  end
  end

  local sameTabs = true
  for i = 1, #mainTabs + #subTabs do
  local id = mainTabs[i] or subTabs[i - #mainTabs]

  if CTradeSkillDB['Tabs'][id] == nil then
   if ToyIDs[id] then
    -- Toys default OFF
    CTradeSkillDB['Tabs'][id] = false
   else
    -- Professions default ON
    CTradeSkillDB['Tabs'][id] = true
   end

   sameTabs = false
   end
  end 

  if not sameTabs or (numTabs ~= #mainTabs + #subTabs) then
    removeTabs()
    numTabs = #mainTabs + #subTabs

  for i = 1, numTabs do
  local id = mainTabs[i] or subTabs[i - #mainTabs]
    addTab(id, i, mainTabs[i] and 0 or 1)
	end
	sortTabs()
	end

  end

  -------------------------------------------------
  --- Force ESC Close ---
  -------------------------------------------------
  
  hooksecurefunc('ToggleGameMenu', function()
  if CTradeSkillDB['Unlock'] and ProfessionsFrame:IsShown() then
    C_TradeSkillUI.CloseTradeSkill()
	HideUIPanel(GameMenuFrame)
	end
  end)

  -------------------------------------------------
  --- Create Option Menu ---
  -------------------------------------------------
  local function createOptions()

  --- Dropdown Menu ---
  local function CTSDropdown_Init(self, level)
  local info = UIDropDownMenu_CreateInfo()
  if level == 1 then
   info.text = f:GetName()
   info.isTitle = true
   info.notCheckable = true
   UIDropDownMenu_AddButton(info, level)

   info.isTitle = false
   info.disabled = false
   info.isNotRadio = true
   info.notCheckable = false
   info.keepShownOnClick = true

   info.func = nil
   info.checked = 	nil
   info.notCheckable = true
   info.hasArrow = true

   info.text = PRIMARY
   info.value = 1
   info.disabled = InCombatLockdown()
   UIDropDownMenu_AddButton(info, level)

   info.text = SECONDARY
   info.value = 2
   info.disabled = InCombatLockdown()
   UIDropDownMenu_AddButton(info, level)
			
  elseif level == 2 then
   info.isNotRadio = true
   info.keepShownOnClick = true
  if UIDROPDOWNMENU_MENU_VALUE == 1 then
  for i = 1, numTabs do
  local tab = _G['CTradeSkillTab' .. i]
  if tab and (tab.isSub == 0) then
   info.text = tab.tooltip
   info.func = function()
   CTradeSkillDB['Tabs'][tab.id] = not CTradeSkillDB['Tabs'][tab.id]
   sortTabs()
  end
	
   info.checked = CTradeSkillDB['Tabs'][tab.id]
   UIDropDownMenu_AddButton(info, level)					
  end
  end
	
  elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
  for i = 1, numTabs do
  local tab = _G['CTradeSkillTab' .. i]
  if tab and (tab.isSub == 1) then
   info.text = tab.tooltip
   info.func = function()
   CTradeSkillDB['Tabs'][tab.id] = not CTradeSkillDB['Tabs'][tab.id]
   sortTabs()
  end
   info.checked = CTradeSkillDB['Tabs'][tab.id]
   UIDropDownMenu_AddButton(info, level)
  end
  end
  end
  end
  end
  
  local menu = CreateFrame('Frame', 'CTSDropdown', nil, 'UIDropDownMenuTemplate')
  UIDropDownMenu_Initialize(CTSDropdown, CTSDropdown_Init, 'MENU')

  --- Option Button ---
  EventUtil.ContinueOnAddOnLoaded("Blizzard_Professions", function()
  local button = CreateFrame('Button', 'CTSOption', ProfessionsFrame.CloseButton)
   button:SetScript('OnClick', function(self) ToggleDropDownMenu(1, nil, CTSDropdown, self, 2, -6) end)
   button:SetPoint('RIGHT', ProfessionsFrame.CloseButton, 'LEFT', -26, 0)
   button:SetSize(22, 22)
   button.Icon = button:CreateTexture(nil, "ARTWORK")
   button.Icon:SetAllPoints()
   button.Icon:SetAtlas("mechagon-projects")
  
  --- ElvUI skin ---
  if E and S and E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill then
   button:SetSize(28, 28)
   button.Icon:SetAtlas("GM-icon-settings")
    
	
  local classColor = E:ClassColor(E.myclass)

   button:HookScript("OnEnter", function(self)
    self.Icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
   end)

   button:HookScript("OnLeave", function(self)
    self.Icon:SetVertexColor(1, 1, 1)
   end)
  end
		
  end);
	
  end

  -------------------------------------------------
  --- Handle Events ---
  -------------------------------------------------
  
  f:SetScript("OnEvent", function(self, event, ...)

  if event == "PLAYER_LOGIN" then
   InitDB()
   createOptions()
   C_AddOns.LoadAddOn("Blizzard_Collections")
   
  if C_AddOns.IsAddOnLoaded("ElvUI") then
   E = unpack(ElvUI)
   S = E:GetModule("Skins")
  end

  EventUtil.ContinueOnAddOnLoaded("Blizzard_Professions", function()
  if ProfessionsFrame then
   ProfessionsFrame:HookScript("OnShow", function()
  if not InCombatLockdown() then
   updateTabs(true)
						
     end
    end)
   end
  end)

  elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
  if not InCombatLockdown() then
   updateTabs()
   end

  elseif event == "TOYS_UPDATED" then
  if ProfessionsFrame and ProfessionsFrame:IsShown() then
  if not InCombatLockdown() then
   updateTabs()
     end
    end
   end
  end)