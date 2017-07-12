local E, L, V, P, G = unpack(ElvUI)	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local dUI = E:GetModule('dUI')	-- Import dUI Core
local DT = E:GetModule('DataTexts') -- Grab ElvUI DataTexts

-- Cache Globals
local format = string.format
local select = select
local join = string.join

-- Bind WoW Apis
local CreateFrame = CreateFrame
local EasyMenu = EasyMenu
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecializationInfo = GetSpecializationInfo
local GetNumSpecGroups = GetNumSpecGroups
local GetLootSpecialization = GetLootSpecialization
local GetSpecializationInfoByID = GetSpecializationInfoByID
local SetLootSpecialization = SetLootSpecialization

local IsShiftKeyDown = IsShiftKeyDown

local LOOT = LOOT

local SELECT_LOOT_SPECIALIZATION, LOOT_SPECIALIZATION_DEFAULT = SELECT_LOOT_SPECIALIZATION, LOOT_SPECIALIZATION_DEFAULT

local lastPanel, active
local displayString = '';
local activeString = join("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = join("", "|cffFF0000", FACTION_INACTIVE, "|r")

-- Design Frame
local menuFrame = CreateFrame("Frame", "LootSpecializationDatatextClickMenu", E.UIParent, "UIDropDownMenuTemplate")
menuFrame:SetTemplate('Transparent')

local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true, func = function() SetLootSpecialization(0) end },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local specList = {
	{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local abbrPlayerSpecs = {
	Affliction = 'Aff',
	Arcane = 'Arcane',
	Arms = 'Arms',
	Assassination = 'Assn',
	Balance = 'Bal',
	BeastMastery = 'BM',
	Brewmaster = 'Brew',
	Blood = 'Blood',
	Demonology = 'Demo',
	Destruction = 'Destro',
	Discipline = 'Disc',
	Elemental = 'Ele',
	Enhancement = 'Enhnc',
	Fire = 'Fire',
	Feral = 'Feral',
  Frost = 'Frost',
	Fury = 'Fury',
	Guardian = 'Guard',
	Havoc = 'Havoc',
	Holy = 'Holy',
	Marksmanship = 'Marks',
	Mistweaver = 'Mist',
	Outlaw = 'Rrrr',
	Protection = 'Prot',
	Restoration = 'Resto',
	Retribution = 'Ret',
	Shadow = 'Shdw',
	Subtlety = 'Sub',
  Survival = 'Survl',
	Unholy = 'Unholy',
	Vengeance = 'Vngc',
	Windwalker = 'Wind',
}

local function OnEvent(self)
  lastPanel = self

  local specIndex = GetSpecialization()
  if not specIndex then return end

  active = GetActiveSpecGroup()

  -- PlayerSpec
  local talent, talentIcon = '', ''
  local currentSpec = GetSpecialization(false, false, active)
  if currentSpec then
    local _, name, _, texture = GetSpecializationInfo(currentSpec)

    if name then
      talent = format('%s', abbrPlayerSpecs[name:gsub('%s','')])
    end

    if texture then
      talentIcon = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
    end
  end

  -- LootSpec
  local lootSpec = GetLootSpecialization()
  local loot, lootIcon = '', ''

  if lootSpec == 0 then
    local specIndex = GetSpecialization()

    if specIndex then
      local _, name, _, texture = GetSpecializationInfo(specIndex)

      if name then
        loot = format('%s', abbrPlayerSpecs[name:gsub('%s','')])
      else
        loot = ''
      end

      if texture then
        lootIcon = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
      else
        lootIcon = ''
      end
    else
      loot = ''
      lootIcon = ''
    end
  else
    local _, name, _, texture = GetSpecializationInfoByID(lootSpec)

    if name then
      loot = format('%s', abbrPlayerSpecs[name])
    else
      loot = ''
    end

    if texture then
      lootIcon = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
    else
      lootIcon = ''
    end
  end
  self.text:SetFormattedText('%s/%s', talent, loot)
  -- self.text:SetFormattedText('%s %s / %s %s', talent, talentIcon, loot, lootIcon)
end

local function OnEnter(self)
  DT:SetupTooltip(self)

  for i = 1, GetNumSpecGroups() do
    if GetSpecialization(false, false, i) then
      DT.tooltip:AddLine(join(' ', format(displayString, select(2, GetSpecializationInfo(GetSpecialization(false, false, i)))), (i == active and activeString or inactiveString)), 1,1,1)
    end
  end

  DT.tooltip:AddLine(' ')
  local specialization = GetLootSpecialization()
  if specialization == 0 then
    local specIndex = GetSpecialization()

    if specIndex then
      local _, name = GetSpecializationInfo(specIndex)
      DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, format(LOOT_SPECIALIZATION_DEFAULT, name)))
    end
  else
    local specID, name = GetSpecializationInfoByID(specialization)
    if specID then
      DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, name))
    end
  end

  DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
  DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Loot Specialization"])

	DT.tooltip:Show()
end

local function OnClick(self, button)
  local specIndex = GetSpecialization()
  if not specIndex then return end

  if button == 'LeftButton' then
    DT.tooltip:Hide()

		if not PlayerTalentFrame then
			LoadAddOn("Blizzard_TalentUI")
		end

    for index = 1, 4 do
      local id, name, _, texture = GetSpecializationInfo(index)
      if id then
        specList[index + 1].text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', texture, name)
        specList[index + 1].func = function() SetSpecialization(index)
        end
      else
        specList[index + 1] = nil
      end
    end

    if IsShiftKeyDown() then
      if not PlayerTalentFrame:IsShown() then
        ShowUIPanel(PlayerTalentFrame)
      else
        HideUIPanel(PlayerTalentFrame)
      end
    else
      EasyMenu(specList, menuFrame, 'cursor', -15, -7, 'MENU', 2)
    end
  else
    DT.tooltip:Hide()
    local specID, specName = GetSpecializationInfo(specIndex)
    menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)

    for index = 1, 4 do
      local id, name = GetSpecializationInfo(index)
      if id then
        menuList[index + 2].text = name
        menuList[index + 2].func = function() SetLootSpecialization(id)
        end
      else
        menuList[index + 2] = nil
      end
    end
    EasyMenu(menuList, menuFrame, 'cursor', -15, -7, 'MENU', 2)
  end
end

local function ValueColorUpdate(hex, r, g, b)
  displayString = join('', '|cffFFFFFF%s:|r ')

  if lastPanel ~= nil then
    OnEvent(lastPanel)
  end
end

E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Spec Switch (dUI)',
{
  'PLAYER_ENTERING_WORLD',
  'CHARACTER_POINTS_CHANGED',
  'PLAYER_TALENT_UPDATE',
  'ACTIVE_TALENT_GROUP_CHANGED',
  'PLAYER_LOOT_SPEC_UPDATED'
},
OnEvent, nil, OnClick, OnEnter)
