local E, L, V, P, G = unpack(ElvUI)	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local dUI = E:GetModule('dUI')	-- Import dUI Core
local DT = E:GetModule('DataTexts')
local dBAR = E:GetModule('DataBars')

-- Lua functions
local _G = _G
local select = select
local format, join, sub, upper, split, utf8sub = string.format, string.join, string.sub, string.upper, string.split, string.utf8sub

-- WoW API / Variables
local InCombatLockdown = InCombatLockdown

local BreakUpLargeNumbers = BreakUpLargeNumbers
local HasArtifactEquipped = HasArtifactEquipped
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local C_ArtifactUIGetEquippedArtifactInfo = C_ArtifactUI.GetEquippedArtifactInfo
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local IsArtifactPowerItem = IsArtifactPowerItem
local ShowUIPanel = ShowUIPanel
local HideUIPanel = HideUIPanel
local SocketInventoryItem = SocketInventoryItem
local ARTIFACT_POWER = ARTIFACT_POWER

local _, UnitXP, UnitXPMax = _, UnitXP, UnitXPMax
local UnitLevel = UnitLevel
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE

local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo, GetNumFactions, GetFactionInfo = GetWatchedFactionInfo, GetNumFactions, GetFactionInfo
local InCombatLockdown = InCombatLockdown
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local REPUTATION, STANDING = REPUTATION, STANDING

local CanPrestige = CanPrestige
local GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
local ToggleTalentFrame = ToggleTalentFrame
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local UnitIsPVP = UnitIsPVP
local UnitLevel = UnitLevel
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local PVP_HONOR_PRESTIGE_AVAILABLE = PVP_HONOR_PRESTIGE_AVAILABLE
local HONOR = HONOR
local MAX_HONOR_LEVEL = MAX_HONOR_LEVEL
----------------------------------------------------------

local displayIndex = 1
local ArtifactData = {}
local ExperienceData = {}
local HonorData = {}
local ReputationData = {}

local tooltips = {
  [1] = function(self) return constructXPTooltip(self) end,
  [2] = function(self) return constructArtifactTooltip(self) end,
  [3] = function(self) return constructReputationTooltip(self) end,
  [4] = function(self) return constructHonorTooltip(self) end,
}

local displayText = {
  [1] = function(self) return self.text:SetText(ExperienceData.dText) end,
  [2] = function(self) return self.text:SetText(ArtifactData.dText) end,
  [3] = function(self) return self.text:SetText(ReputationData.dText) end,
  [4] = function(self) return self.text:SetText(HonorData.dText) end,
}

local actions = {
  [1] = function() ToggleCharacter('PaperDollFrame') end,
  [2] = function()
    if ArtifactFrame and ArtifactFrame:IsShown() then
      HideUIPanel(ArtifactFrame)
    else
      ShowUIPanel(SocketInventoryItem(16))
    end
  end,
  [3] = function() ToggleCharacter('ReputationFrame') end,
  [4] = function() ToggleTalentFrame(3) end
}

local function abbreviateStanding(standing)
  local labels = {
    Exalted = 'Ex',
    Revered = 'Rv',
    Honored = 'Hr',
    Friendly = 'Fr',
    Neutral = 'Nu',
    Unfriendly = 'Uf',
    Hostile = 'Hs',
    Hated = 'Ht'
  }

  if labels[standing] then
    return labels[standing]
  elseif standing:utf8len() > 4 then
    return dUI:RemoveVowels(standing)
  else
    return standing
  end
end

----------------------------------------------------------
-- [1] EXPERIENCE DATA
function update_ExperienceData(event, unit)
  if UnitLevel('player') then
    ExperienceData.level = UnitLevel('player')
    ExperienceData.level_max = ExperienceData.level == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] and true or false
    ExperienceData.XP = UnitXP('player')
    ExperienceData.XPForNextLevel = UnitXPMax('player')
    ExperienceData.XP_percent = ExperienceData.XP / ExperienceData.XPForNextLevel * 100
    ExperienceData.XP_bars = ExperienceData.XP_percent * 2/10
    ExperienceData.XP_rem = ExperienceData.XPForNextLevel - ExperienceData.XP
    ExperienceData.XP_remPercent = ExperienceData.XP_rem / ExperienceData.XPForNextLevel * 100
    ExperienceData.XP_remBars = ExperienceData.XP_remPercent * 2/10
    ExperienceData.XP_rested = GetXPExhaustion() or 0
    ExperienceData.XP_restedPercent = ExperienceData.XP_rested / ExperienceData.XPForNextLevel * 100
    ExperienceData.XP_disabled = IsXPUserDisabled()

    -----

    if not ExperienceData.level_max then
      ExperienceData.dText = format('%s %d %.2f%%', ExperienceData.XP_disabled and '|cffFF2C2CLv.' or '|cff33CBFFLv.|r', ExperienceData.level, ExperienceData.XP_percent)
    else
      ExperienceData.dText = format('|cff33CBFFLv.|r %d', ExperienceData.level)
    end
  else
    ExperienceData.dText = 'Level Up'
  end
end

function constructXPTooltip(self)
  DT:SetupTooltip(self)

  DT.tooltip:ClearLines()
  DT.tooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

  DT.tooltip:AddLine(L["Experience"])
  DT.tooltip:AddLine(' ')

  if not ExperienceData.level_max then
    DT.tooltip:AddDoubleLine(L["Current Level:"], format(' %d', ExperienceData.level), 1, 1, 1)
    DT.tooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%.2f%%)', ExperienceData.XP, ExperienceData.XPForNextLevel, ExperienceData.XP_percent), 1, 1, 1)
    DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %d (%.2f%% - %.1f %s)', ExperienceData.XP_rem, ExperienceData.XP_remPercent, ExperienceData.XP_remBars, L["Bars"]), 1, 1, 1)

    if ExperienceData.XP_rested > 0 then
      DT.tooltip:AddDoubleLine(L["Rested:"], format('+%d (%.2f%%)', ExperienceData.XP_rested, ExperienceData.XP_restedPercent), 1, 1, 1)
    end
  else
    DT.tooltip:AddDoubleLine(L["Current Level:"], format(' %d (Level Cap)', ExperienceData.level), 1, 1, 1)
  end

  if ExperienceData.disabled then
    DT.tooltip:Addline('Experience Disabled.')
  end

  DT.tooltip:Show()
end

-- [2] ARTIFACT DATA
function update_ArtifactData(event, unit)
  local Artifact_ItemID, _, _, _, Artifact_Power, Artifact_Rank, _, _, _, _, _, _, Artifact_Tier = C_ArtifactUIGetEquippedArtifactInfo()

  if Artifact_ItemID then
    ArtifactData.ItemID = Artifact_ItemID
    ArtifactData.Rank = Artifact_Rank
    ArtifactData.Tier = Artifact_Tier
    ArtifactData.AvailablePoints, ArtifactData.XP, ArtifactData.XPForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(Artifact_Rank, Artifact_Power, Artifact_Tier)
    ArtifactData.XP_percent = ArtifactData.XP / ArtifactData.XPForNextPoint * 100
    ArtifactData.XP_rem = ArtifactData.XPForNextPoint - ArtifactData.XP
    ArtifactData.XP_remPercent = ArtifactData.XP_rem / ArtifactData.XPForNextPoint * 100
    ArtifactData.XP_remBars = 20/100 * ArtifactData.XP_remPercent

    -- Call the ElvUI Artifact bar for APinBags values
    ArtifactData.XPInBags = dBAR.artifactBar and dBAR:GetArtifactPowerInBags() or 0
    ArtifactData.XPInBags_percent = ArtifactData.XPInBags / ArtifactData.XPForNextPoint * 100
    ArtifactData.XPInBags_bars = 20/100 * ArtifactData.XPInBags_percent

    -------------
    ArtifactData.dText = format('|cffe6cc80%d|r: %s/%s %.1f%%', ArtifactData.Rank, dUI:formatAP(ArtifactData.XP,'c'), dUI:formatAP(ArtifactData.XPForNextPoint,'n'), ArtifactData.XP_percent)
  else
    ArtifactData.dText = 'No Artifact Weapon'
  end
end

function constructArtifactTooltip(self)
  DT:SetupTooltip(self)

  DT.tooltip:ClearLines()
  DT.tooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

  DT.tooltip:AddLine(ARTIFACT_POWER)
  DT.tooltip:AddLine(' ')

  if ArtifactData.ItemID then
    DT.tooltip:AddDoubleLine(L['AP:'], format(' %s / %s (%.2f%%)', BreakUpLargeNumbers(ArtifactData.XP), BreakUpLargeNumbers(ArtifactData.XPForNextPoint), ArtifactData.XP_percent))
    DT.tooltip:AddDoubleLine(L['Remaining:'], format(' %s (%.2f%% - %.1f %s)', BreakUpLargeNumbers(ArtifactData.XP_rem), BreakUpLargeNumbers(ArtifactData.XP_remPercent), BreakUpLargeNumbers(ArtifactData.XP_remBars), L["Bars"] ), 1, 1, 1)
    DT.tooltip:AddDoubleLine(L["In Bags:"], format(' %s (%.2f%% - %.1f %s)', BreakUpLargeNumbers(ArtifactData.XPInBags), ArtifactData.XPInBags_percent, ArtifactData.XPInBags_bars, L["Bars"]), 1, 1, 1)

    if ArtifactData.AvailablePoints >= 1 then
      DT.tooltip:AddLine(' ')
      DT.tooltip:AddDoubleLine("Available Points:", format('%d', ArtifactData.AvailablePoints), 1, 1, 1)
    end
  else
    DT.tooltip:AddLine('No Artifact Weapon')
  end

  DT.tooltip:Show()
end

-- [3] REPUTATION DATA
function update_ReputationData(event, unit)
  if GetWatchedFactionInfo() then
    local clrScale = 1.0
    local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
    ReputationData.name = name
    ReputationData.color = FACTION_BAR_COLORS[reaction] and E:RGBToHex(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b) or E:RGBToHex(FACTION_BAR_COLORS[1].r, FACTION_BAR_COLORS[1].g, FACTION_BAR_COLORS[1].b)
    ReputationData.isParagon = false

    if C_Reputation_IsFactionParagon(factionID) then
      ReputationData.isParagon = true
      ReputationData.color = '|cff0088ee'
      local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
      min, max = 0, threshold
      value = currentValue % threshold
      if hasRewardPending then
        value = value + threshold
      end
    end

    local normDiff = (max - min == 0 ) and 1 or (max - min)

    ReputationData.value = value - min
    ReputationData.max = max - min
    ReputationData.remaining = (max - min) - (value - min)
    ReputationData.percent = (value - min) / normDiff * 100

    for i=1, GetNumFactions() do
      local factionName, _, standingID,_,_,_,_,_,_,_,_,_,_, factionID = GetFactionInfo(i)
      local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)

      if factionName == ReputationData.name then
        if friendID then
          ReputationData.standingLabel = friendTextLevel
        else
          ReputationData.standingLabel = standingID and _G['FACTION_STANDING_LABEL'..standingID] or UNKNOWN
        end
      end
    end

    ReputationData.dText = format('%s%s|r: %0.1f%% [%s%s|r]', ReputationData.color, dUI:ReadableString(ReputationData.name, 12), ReputationData.percent, ReputationData.color, ReputationData.isParagon and 'P+' or abbreviateStanding(ReputationData.standingLabel))

  else
    ReputationData.dText = 'No Faction'
    ReputationData.name = 'No Selected Faction'
    ReputationData.standingLabel = 'n/a'
    ReputationData.value, ReputationData.max, ReputationData.percent = 0, 0, 0
  end
end

function constructReputationTooltip(self)
  DT:SetupTooltip(self)

  DT.tooltip:ClearLines()
  DT.tooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

  DT.tooltip:AddLine(ReputationData.name)
  DT.tooltip:AddLine(' ')
  DT.tooltip:AddDoubleLine(STANDING..':', format('%s%s', ReputationData.standingLabel, ReputationData.isParagon and ' (Paragon)' or ''), 1, 1, 1)
  DT.tooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%0.2f%%)', ReputationData.value, ReputationData.max, ReputationData.percent), 1, 1, 1)

  DT.tooltip:Show()
end

-- [4] HONOR DATA
function update_HonorData(event, unit)
  if UnitHonor('player') then
    HonorData.XP = UnitHonor('player')
    HonorData.XPForNextLevel = UnitHonorMax('player')
    HonorData.XP_percent = HonorData.XP / HonorData.XPForNextLevel * 100
    HonorData.XP_rem = HonorData.XPForNextLevel - HonorData.XP
    HonorData.XP_remPercent = HonorData.XP_rem / HonorData.XPForNextLevel * 100
    HonorData.XP_remBars = HonorData.XP_remPercent * 20/100
    HonorData.level = UnitHonorLevel('player')
    HonorData.level_max = GetMaxPlayerHonorLevel()
    HonorData.level_prestige = UnitPrestige('player')

    if HonorData.level_prestige >= 1 then
      HonorData.dText = format('|cffFC5151H:|r%d+%d %.1f%%', HonorData.level, HonorData.level_prestige, HonorData.XP_percent)
    else
      HonorData.dText = format('|cffFC5151H:|r%d %.1f%%', HonorData.level, HonorData.XP_percent)
    end
  else
    HonorData.dText = 'Honor'
  end
end

function constructHonorTooltip(self)
  DT:SetupTooltip(self)

  DT.tooltip:ClearLines()
  DT.tooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

  DT.tooltip:AddLine(HONOR)
  DT.tooltip:AddDoubleLine(L["Current Level:"], HonorData.level, 1, 1, 1)
  DT.tooltip:AddDoubleLine(PVP_PRESTIGE_RANK_UP_TITLE..HEADER_COLON, HonorData.level_prestige, 1, 1, 1)
  DT.tooltip:AddLine(' ')

  if CanPrestige() then
    DT.tooltip:AddLine(PVP_HONOR_PRESTIGE_AVAILABLE)
  elseif HonorData.level == HonorData.level_max then
    DT.tooltip:AddLine(MAX_HONOR_LEVEL)
  else
    DT.tooltip:AddDoubleLine(L["Honor XP:"], format(' %d / %d (%.1f%%)', HonorData.XP, HonorData.XPForNextLevel, HonorData.XP_percent), 1, 1, 1)
    DT.tooltip:AddDoubleLine(L["Honor Remaining:"], format(' %d (%.1f%% - %.1f %s)', HonorData.XP_rem, HonorData.XP_remPercent, HonorData.XP_remBars, L["Bars"]), 1, 1, 1)
  end

  DT.tooltip:Show()
end


----------------------------------------------------------

local function combined_OnEvent(self, event, unit)
  -- Refresh data
  update_ExperienceData(event, unit)
  update_ArtifactData(event, unit)
  update_ReputationData(event, unit)
  update_HonorData(event, unit)


  -- Change displayIndex according to game events
  if event == 'PLAYER_LOG_IN' or event == 'PLAYER_ENTERING_WORLD' then
    -- print(format('Event Switch XP: %s', event))
    displayIndex = ExperienceData.level_max and 2 or 1
  elseif event == 'PLAYER_XP_UPDATE' or event == 'DISABLE_XP_GAIN' or event == 'ENABLE_XP_GAIN' then
    print(format('Event Switch XP: %s', event))
    displayIndex = 1
  elseif event == 'ARTIFACT_XP_UPDATE' then
    -- print(format('Event Switch AP: %s', event))
    displayIndex = 2
  elseif event == 'UPDATE_FACTION' then
    -- print(format('Event Switch Rep: %s', event))
    displayIndex = 3
  elseif event == 'HONOR_XP_UPDATE' or event == 'HONOR_PRESTIGE_UPDATE' then
    -- print(format('Event Switch PvP: %s', event))
    displayIndex = 4
  end
  displayText[displayIndex](self)
end

local function combined_OnClick(self, button)
  if button == 'LeftButton' then
    actions[displayIndex]()
  elseif button == 'RightButton' then
    displayIndex = displayIndex + 1
    if displayIndex == 5 then
      displayIndex = 1
    end
    tooltips[displayIndex](self)
    displayText[displayIndex](self)
  end
end

local function combined_OnEnter(self)
  tooltips[displayIndex](self)
end

DT:RegisterDatatext('Combined Data (dUI)',
{
  'PLAYER_LOG_IN',
  'PLAYER_ENTERING_WORLD',

  'ARTIFACT_XP_UPDATE',
  'UNIT_INVENTORY_CHANGED',
  'BAG_UPDATE_DELAYED',

  'PLAYER_XP_UPDATE',
  'DISABLE_XP_GAIN',
  'ENABLE_XP_GAIN',
  'UPDATE_EXHAUSTION',
  'UPDATE_EXPANSION_LEVEL',

  'UPDATE_FACTION',

  'HONOR_XP_UPDATE',
  'HONOR_PRESTIGE_UPDATE',
},
combined_OnEvent, nil, combined_OnClick, combined_OnEnter)

----------------------------------------------------------
local function exp_OnEvent(self, event, unit)
  update_ExperienceData(event, unit)
  displayText[1](self)
end

local function exp_OnClick(self, button)
  if button == 'LeftButton' or button == 'RightButton' then
    actions[1]()
  end
end

local function exp_OnEnter(self)
  tooltips[1](self)
end

DT:RegisterDatatext('Experience (dUI)',
{
  'PLAYER_LOG_IN',
  'PLAYER_ENTERING_WORLD',
  'DISABLE_XP_GAIN',
  'ENABLE_XP_GAIN',
  'UPDATE_EXHAUSTION',
  'UPDATE_EXPANSION_LEVEL'
},
exp_OnEvent, nil, exp_OnClick, exp_OnEnter)

----------------------------------------------------------
local function artifact_OnEvent(self, event, unit)
  update_ArtifactData(event, unit)
  displayText[2](self)
end

local function artifact_OnClick(self, button)
  if button == 'LeftButton' or button =='RightButton' then
    actions[2]()
  end
end

local function artifact_OnEnter(self)
  tooltips[2](self)
end

DT:RegisterDatatext('Artifact Power (dUI)',
{
  'PLAYER_LOG_IN',
  'PLAYER_ENTERING_WORLD',
  'ARTIFACT_XP_UPDATE',
  'UNIT_INVENTORY_CHANGED',
  'BAG_UPDATE_DELAYED',
},
artifact_OnEvent, nil, artifact_OnClick, artifact_OnEnter)

----------------------------------------------------------
local function rep_OnEvent(self, event, unit)
  update_ReputationData(event, unit)
  displayText[3](self)
end

local function rep_OnClick(self, button)
  if button == 'LeftButton' or button == 'RightButton' then
    actions[3]()
  end
end

local function rep_OnEnter(self)
  tooltips[3](self)
end

DT:RegisterDatatext('Reputation (dUI)',
{
  'PLAYER_LOG_IN',
  'PLAYER_ENTERING_WORLD',
  'UPDATE_FACTION'
},
rep_OnEvent, nil, rep_OnClick, rep_OnEnter)
----------------------------------------------------------
local function honor_OnEvent(self, event, unit)
  update_HonorData(event, unit)
  displayText[4](self)
end

local function honor_OnClick(self, button)
  if button == 'LeftButton' or button == 'RightButton' then
    actions[4]()
  end
end

local function honor_OnEnter(self)
  tooltips[4](self)
end

DT:RegisterDatatext('Honor (dUI)',
{
  'PLAYER_LOG_IN',
  'PLAYER_ENTERING_WORLD',
  'HONOR_XP_UPDATE',
  'HONOR_PRESTIGE_UPDATE'
},
honor_OnEvent, nil, honor_OnClick, honor_OnEnter)
