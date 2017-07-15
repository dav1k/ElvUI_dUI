local E, L, V, P, G = unpack(ElvUI)	-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local dUI = E:GetModule('dUI')	-- Import dUI Core

--Cache global variables
local select, tonumber, assert, type, unpack, pairs = select, tonumber, assert, type, unpack, pairs
local tinsert, tremove = tinsert, tremove
local atan2, modf, ceil, floor, abs, sqrt, mod = math.atan2, math.modf, math.ceil, math.floor, math.abs, math.sqrt, mod
local format, sub, match, upper, split, utf8sub = string.format, string.sub, string.match, string.upper, string.split, string.utf8sub

-- Format number to a specific manitude of precision
local function FormatToDecimalsPlaces(num, digits)
  local value = ("%%.%df"):format(digits)
  return value:format(num)
end


-- Returns shorted/abbreviated values (usually for UFs)
function dUI:ReadableNumber(v, digits, lower)
  digits = digits or false
  lower = lower and true or false
  if not v then
    return 0
	else
    v = abs(v)
    local str = ''
    if v >= 100e9 then      -- 100.0B
      str = format('%sB', FormatToDecimalsPlaces(v/1e9, digits or 1))
    elseif v >= 1e9 then    -- 1.00B
      str = format('%sB', FormatToDecimalsPlaces(v/1e9, digits or 2))
    elseif v >= 100e6 then  -- 100.0M
      str = format('%sM', FormatToDecimalsPlaces(v/1e6, digits or 1))
    elseif v >= 1e6 then    -- 1.00M
      str = format('%sM', FormatToDecimalsPlaces(v/1e6, digits or 2))
    elseif v >= 100e3 then  -- 100.0K
      str = format('%sK', FormatToDecimalsPlaces(v/1e3, digits or 1))
    elseif v >= 1e3 then    -- 1.00K
      str = format('%sK', FormatToDecimalsPlaces(v/1e3, digits or 2))
    else                    -- 1
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
  kind = kind:lower() or 'c'
  if kind == 'c' then
    if ap >= 10e9 then
      return dUI:ReadableNumber(ap, 1, true) -- 10.0b
    elseif ap >= 1e9 then
      return dUI:ReadableNumber(ap, 2, true) -- 1.00b
    elseif ap >= 100e6 then
      return dUI:ReadableNumber(ap, 0, true) -- 100m
    elseif ap >= 10e6 then
      return dUI:ReadableNumber(ap, 1, true) -- 10.0m
    elseif ap >= 1e6 then
      return dUI:ReadableNumber(ap, 2, true) -- 1.00m
    elseif ap >= 100e3 then
      return dUI:ReadableNumber(ap, 0, true) -- 100k
    elseif ap >= 10e3 then
      return dUI:ReadableNumber(ap, 1, true) -- 10.0k
    elseif ap >= 1e3 then
      return dUI:ReadableNumber(ap, 2, true) -- 1.00k
    else
      return dUI:ReadableNumber(ap, 0, true) -- 100
    end
  elseif kind == 'n' then
    if ap >= 1e9 then
      return dUI:ReadableNumber(ap, 1, true) -- 1.0b
    elseif ap >= 500e6 then
      -- return dUI:ReadableNumber(ap, 0, true) -- 500m
      return format('%sb', FormatToDecimalsPlaces(ap/1e9, 2)) -- 0.50b
    else
      return dUI:formatAP(ap, 'c')
    end
  end
end

-- Remove Trailing Spaces from string
function dUI:RemoveTrailingSpace(str)
  return str:gsub('%s%.',''):gsub("^%s*(.-)%s*$", "%1")
end

-- Remove Vowels from string
function dUI:RemoveVowels(str, uppers)
  uppers = uppers and true or false
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
  type = type or 1
  if type == 1 then
    return str:gsub("%s?(.[\128-\191*]*)%S+%s", "%1. ")
  elseif type == 2 then
    return str:gsub("%s?(..[\128-\191]*)%S+%s", "%1. ")
  end
end

-- Return String as inital letters of each word
-- 'Jack Jacksmith Jackson' => 'J. J. J.'
function dUI:InitialString(str, allUpper)
  allUpper = allUpper and true or false
  local newStr = ''
  local words = {split(' ', str)}
  for _, word in pairs(words) do
    word = utf8sub(word, 1, 1) .. '. '
    word = allUpper and word:upper() or word
    newStr = newStr .. word
  end
  return dUI:RemoveTrailingSpace(newStr)
end

-- Take first Inital or remove short words in string
function dUI:RemoveShortWordsInString(str, length)
  local newStr = ''
  local wordLength = length or 3
  local words = {split(' ', str)}
  for i, word in pairs(words) do
    if i ~= #words then
      if word:utf8len() > wordLength then
        word = utf8sub(word, 1, 1) .. '. '
      else
        word = ''
      end
    end
    newStr = newStr .. word
  end
  return dUI:RemoveTrailingSpace(newStr)
end

-- Abbreviate String according to maxLength
function dUI:ReadableString(str, maxLength)
  if not str then return end
  local attempts = {
    [0] = function(string) return string end,
    [1] = function(string) return dUI:AbbreviateString(string, 2) end,
    [2] = function(string) return dUI:AbbreviateString(string, 1) end,
    [3] = function(string) return dUI:RemoveShortWordsInString(string, 3) end,
    [4] = function(string) return dUI:RemoveTrailingSpace(dUI:AbbreviateString(string, 1):gsub("[aeiou]", '')) end,
    [5] = function(string) return dUI:InitialString(string) end
  }
  local index = 0
  local currentAttempt = str
  while ( index <= 5 and currentAttempt:utf8len() > maxLength) do
    index = index + 1
    currentAttempt = attempts[index](str)
  end
  return currentAttempt
end
