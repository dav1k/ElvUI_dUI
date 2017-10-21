-- Locals

local macroName = 'dUI-HP'
local bHealthstone = false
local bAstralHP = false
local bAncientHP = false


-- Event Handler

dUI_autoMacro = CreateFrame('frame')
dUI_autoMacro:SetScript('OnEvent',
  function(self, event, ...)
    if self[event] then
      return self[event](self, event, ...)
    end
  end
)
dUI_autoMacro:RegisterEvent("PLAYER_LOGIN")

function dUI_autoMacro:Print(...)
  ChatFrame1:AddMessage(string.join(' ', '|cFF33FF99autoMacro|r:', ...))
end

function dUI_autoMacro:PLAYER_LOGIN(event)
  -- self:Print(event)

  self:RegisterEvent("PLAYER_LOGOUT")
  self:RegisterEvent("BAG_UPDATE_DELAYED")
end

function dUI_autoMacro:PLAYER_LOGOUT(event)
  self:Print(event)
  bHealthstone = false
  bAstralHP = false
  bAncientHP = false
end

function dUI_autoMacro:BAG_UPDATE_DELAYED(event)
  -- self:Print(event)
  if not InCombatLockdown() then
    self:Scan()
  end
end

function dUI_autoMacro:Scan()
  bHealthstone = false
  bAstralHP = false
  bAncientHP = false

  for bag=0,4 do
    for slot=1, GetContainerNumSlots(bag) do
      local link = GetContainerItemLink(bag, slot)
      local itemID = GetContainerItemID(bag, slot)
      local _, itemCount = GetContainerItemInfo(bag, slot)

      if itemID == 5512 then
        bHealthstone = true
      elseif itemID == 152615 then
        bAstralHP = true
      elseif itemID == 127834 then
        bAncientHP = true
      end
    end
  end

  if bHealthstone then
    dUI_autoMacro:EditMacro('Healthstone')
  elseif bAstralHP then
    dUI_autoMacro:EditMacro('Astral Healing Potion')
  elseif bAncientHP then
    dUI_autoMacro:EditMacro('Ancient Healing Potion')
  end
end

function dUI_autoMacro:EditMacro(itemName)
  local macroID = GetMacroIndexByName(macroName)
  local macroBody = string.format('#showtooltip\n/use %s', itemName)
  -- self:Print(macroBody)
  EditMacro(macroID, macroName, 'INV_Misc_QuestionMark', macroBody, 1)
end
