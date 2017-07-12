local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
local select, tonumber, assert, type, unpack, pairs = select, tonumber, assert, type, unpack, pairs
local tinsert, tremove = tinsert, tremove
local atan2, modf, ceil, floor, abs, sqrt, mod = math.atan2, math.modf, math.ceil, math.floor, math.abs, math.sqrt, mod
local format, sub, upper, split, utf8sub = string.format, string.sub, string.upper, string.split, string.utf8sub


function dUI:formatAP(ap, kind)
  if kind:lower() == 'c' then
    if ap >= 100e6 then
      return format('%dm', ap/1e6)
    elseif ap >= 1e6 then
      return format('%.1fm', ap/1e6)
    elseif ap >= 1e3 then
      return format('%.1fk', ap/1e3)
    else
      return format('%d', ap)
    end
  elseif kind:lower() == 'n' then
    if ap >= 1e9 then
      return format('%.1fb', ap/1e9)
    elseif ap >= 100e6 then
      return format('%.2fb', ap/1e9)
    else
      return dUI:formatAP(ap, 'c')
    end
  end
end

function dUI:RemoveTrailingSpace(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

function dUI:RemoveVowels(str)
  return str:gsub("[aeiou]", '')
end
