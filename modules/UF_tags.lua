local E, L, V, P, G = unpack(ElvUI)	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local dUI = E:GetModule('dUI')	-- Import dUI Core

-- Grab ElvUI's UnitFrames
local UF = E:GetModule('UnitFrames');
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecializationInfo = GetSpecializationInfo

-- Spec/Power
local abbrSpecPower = {
	Arcane = 'Mana',
  Frost = 'Mana',
  Survival = 'Survl',
  Fury = 'Fury',
  Demonology = 'Mana',
  Windwalker = 'Wind',
  Subtlety = 'Energy',
  Havoc = 'Fury',
  Shadow = 'Insanity',
  Arms = 'Fury',
  Feral = 'Energy',
  Assassination = 'Energy',
  Elemental = 'Mana',
  Enhancement = 'Mana',
  Affliction = 'Mana',
  Outlaw = 'Energy',
  Marksmanship = 'Bullets',
  Destruction = 'Mana',
  Fire = 'Mana',
  Unholy = 'Rune Power',
  Balance = 'Mana',
  Vengeance = 'Pain',
  Protection = 'Pain',
  Guardian = 'Pain',
  Brewmaster = 'Stagger',
  Blood = 'Rune Power',
  Discipline = 'Mana',
  Holy = 'Mana',
  Mistweaver = 'Mana',
  Restoration = 'Mana',
}

-- Abbreviate UnitName to <12 chars
ElvUF.Tags.Events['name:abbr12'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr12'] = function(unit)
  return dUI:ReadableString(UnitName(unit), 12)
end

-- Abbreviate UnitName to <16 chars
ElvUF.Tags.Events['name:abbr16'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr16'] = function(unit)
  return dUI:ReadableString(UnitName(unit), 16)
end

-- Abbreviate UnitName to <18 chars
ElvUF.Tags.Events['name:abbr18'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr18'] = function(unit)
  return dUI:ReadableString(UnitName(unit), 18)
end

-- Abbreviate UnitName to <20 chars
ElvUF.Tags.Events['name:abbr20'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr20'] = function(unit)
  return dUI:ReadableString(UnitName(unit), 20)
end

-- Abbreviate UnitName to <25 chars
ElvUF.Tags.Events['name:abbr25'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr25'] = function(unit)
  return dUI:ReadableString(UnitName(unit), 25)
end

-- UnitName returned as all Caps
ElvUF.Tags.Events['name:caps'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:caps'] = function(unit)
  return UnitName(unit) and UnitName(unit):upper() or ''
end

-- UnitName, Abbr 12 & Cap'd
ElvUF.Tags.Events['name:abbr12-caps'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr12-caps'] = function(unit)
  return _TAGS['name:abbr12'](unit):upper() or ''
end

-- UnitName, Abbr 16 & Cap'd
ElvUF.Tags.Events['name:abbr16-caps'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr16-caps'] = function(unit)
  return _TAGS['name:abbr16'](unit):upper() or ''
end

-- UnitName, Abbr 18 & Cap'd
ElvUF.Tags.Events['name:abbr18-caps'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr18-caps'] = function(unit)
  return _TAGS['name:abbr18'](unit):upper() or ''
end

-- UnitName, Abbr 20 & Cap'd
ElvUF.Tags.Events['name:abbr20-caps'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr20-caps'] = function(unit)
  return _TAGS['name:abbr20'](unit):upper() or ''
end

-- UnitName, Abbr 25 & Cap'd
ElvUF.Tags.Events['name:abbr25-caps'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags.Methods['name:abbr25-caps'] = function(unit)
  return _TAGS['name:abbr25'](unit):upper() or ''
end

-- Custom HealthColor
ElvUF.Tags.Events['healthcolor2'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags.Methods['healthcolor2'] = function(unit)
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
    return Hex(0.70, 0.70, 0.70)
  elseif UnitGetTotalAbsorbs(unit) > 0 and (UnitGetTotalAbsorbs(unit) + UnitHealth(unit)) > UnitHealthMax(unit) then
    local r,g,b = ElvUF.ColorGradient(UnitGetTotalAbsorbs(unit), UnitHealthMax(unit)*0.3,
      0.80,1.00,1.00, -- 0%
      0.10,0.77,1.00  -- 100%
    )
    return Hex(r,g,b)
  else
    local r,g,b = ElvUF.ColorGradient(UnitHealth(unit), UnitHealthMax(unit),
      1.00,0.10,0.10,   -- 0%
      1.00,0.80,0.00,   -- 25%
      1.00,1.00,1.00,   -- 50%
      1.00,1.00,1.00,   -- 75%
      1.00,1.00,1.00    -- 100%
    )
    return Hex(r,g,b)
  end
end

-- Displays (HP+ABSORB):percent w/ nostatus tag
ElvUF.Tags.Events['health-absorbs:percent-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION'
ElvUF.Tags.Methods['health-absorbs:percent-nostatus'] = function(unit)
  local absorb = UnitGetTotalAbsorbs(unit) or 0
  local healthTotalIncludingAbsorbs = UnitHealth(unit) + absorb
  local percent = healthTotalIncludingAbsorbs/UnitHealthMax(unit) * 100

  if healthTotalIncludingAbsorbs > UnitHealthMax(unit) then
    return format('%.1f%%', percent)
  elseif UnitHealth(unit) == UnitHealthMax(unit) and absorb == 0 then
    return format('%d%%', percent)
  else
    return format('%.2f%%', percent)
  end
end

ElvUF.Tags.Events['health-absorbs:percent'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION'
ElvUF.Tags.Methods['health-absorbs:percent'] = function(unit)
  local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

  if status then
    return status
  else
    return _TAGS['health-absorbs:percent-nostatus'](unit)
  end
end

-- Returns (HP+ABSORB):Current
ElvUF.Tags.Events['health-absorbs:current-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION'
ElvUF.Tags.Methods['health-absorbs:current-nostatus'] = function(unit)
  local absorb = UnitGetTotalAbsorbs(unit) or 0
  local healthTotalIncludingAbsorbs = UnitHealth(unit) + absorb

  return dUI:ReadableNumber(healthTotalIncludingAbsorbs)
end

ElvUF.Tags.Events['health-absorbs:current'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION'
ElvUF.Tags.Methods['health-absorbs:current'] = function(unit)
  local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

  if status then
    return status
  else
    return _TAGS['health-absorbs:current-nostatus'](unit)
  end
end

-- Displays Health as HP+ABSORB w/ nostatus tag
ElvUF.Tags.Events['health-plus-absorbs:current-nostatus'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION'
ElvUF.Tags.Methods['health-plus-absorbs:current-nostatus'] = function(unit)
  if UnitGetTotalAbsorbs(unit) > 0 then
    return dUI:ReadableNumber(UnitHealth(unit)) .. '+' .. dUI:ReadableNumber(UnitGetTotalAbsorbs(unit))
  else
    return dUI:ReadableNumber(UnitHealth(unit))
  end
end

ElvUF.Tags.Events['health-plus-absorbs:current'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION'
ElvUF.Tags.Methods['health-plus-absorbs:current'] = function(unit)
  local status = UnitIsDead(unit) and L["Dead"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

  if status then
    return status
  else
    return _TAGS['health-plus-absorbs:current-nostatus'](unit)
  end
end

-- Threat% of my Target's Target (useful for targettarget unitframes)
ElvUF.Tags.Events['tt:threat-percent'] = 'UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE'
ElvUF.Tags.Methods['tt:threat-percent'] = function(unit)
  local _, _, percent = UnitDetailedThreatSituation('targettarget', unit)
  if (percent and percent > 0) then
    return format('%d%%', percent)
  else
    return ''
  end
end
