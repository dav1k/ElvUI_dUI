local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
local select, tonumber, assert, type, unpack, pairs = select, tonumber, assert, type, unpack, pairs
local tinsert, tremove = tinsert, tremove
local atan2, modf, ceil, floor, abs, sqrt, mod = math.atan2, math.modf, math.ceil, math.floor, math.abs, math.sqrt, mod
local format, sub, upper, split, utf8sub = string.format, string.sub, string.upper, string.split, string.utf8sub

-- Format number to a specific manitude of precision
local function FormatToDecimalsPlaces(num, digits)
  local value = ("%%.%df"):format(digits)
  return value:format(num)
end


-- Returns shorted/abbreviated values (usually for UFs)
function dUI:ReadableNumber(v, digits, lower)
  if not v then
    return 0
	else
    v = abs(v)
    local str = ''
    if v >= 100e9 then
      str = format('%sB', FormatToDecimalsPlaces(v/1e9, digits or 1))
    elseif v >= 1e9 then
      str = format('%sB', FormatToDecimalsPlaces(v/1e9, digits or 2))
    elseif v >= 100e6 then
      str = format('%sM', FormatToDecimalsPlaces(v/1e6, digits or 1))
    elseif v >= 1e6 then
      str = format('%sM', FormatToDecimalsPlaces(v/1e6, digits or 2))
    elseif v >= 100e3 then
      str = format('%sK', FormatToDecimalsPlaces(v/1e3, digits or 1))
    elseif v >= 1e3 then
      str = format('%sK', FormatToDecimalsPlaces(v/1e3, digits or 2))
    else
      str = format('%s', FormatToDecimalsPlaces(v, digits or 0))
    end
    if lower then
      return str:lower()
    else
      return str
    end
  end
end

-- Formats AP values. C for current values, N for needed values
function dUI:formatAP(ap, kind)
  if kind:lower() == 'c' then
    if ap >= 100e6 then
      return dUI:ReadableNumber(ap, 0, true)
    elseif ap >= 1e3 then
      return dUI:ReadableNumber(ap, 1, true)
    else
      return dUI:ReadableNumber(ap, 0, true)
    end
  elseif kind:lower() == 'n' then
    if ap >= 1e9 then
      return dUI:ReadableNumber(ap, 1, true)
    elseif ap >= 100e6 then
      return dUI:ReadableNumber(ap, 2, true)
    else
      return dUI:formatAP(ap, 'c')
    end
  end
end

-- Remove Trailing Spaces from string
function dUI:RemoveTrailingSpace(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Remove Vowels from string
function dUI:RemoveVowels(str, uppers)
  if uppers then
    return str:gsub("[AEIOUaeiou]", '')
  else
    return str:gsub("[aeiou]", '')
  end
end

-- Return Str such preceeding spaced words are changed to letter and period.
-- [1]: 'Jack Jacksmith Jackson' => 'J.J. Jackson'
-- [2]: 'Jack Jacksmith Jackson' => 'Ja. Ja. Jackson'
function dUI:AbbreviateString(str, type)
  if type == nil or type == 1 then
    return str:gsub("%s?(.[\128-\191*]*)%S+%s", "%1. ")
  elseif type == 2 then
    return str:gsub("%s?(..[\128-\191]*)%S+%s", "%1. ")
  end
end

-- Return String as inital letters of each word
-- 'Jack Jacksmith Jackson' => 'J. J. J.'
function dUI:InitialString(str, allUpper)
  local newStr = ''
  local words = {split(' ', str)}
  for _, word in pairs(words) do
    word = utf8sub(word, 1, 1) .. '. '
    word = allUpper and word:upper() or word
    newStr = newStr .. word
  end
  return dUI:RemoveTrailingSpace(newStr)
end
