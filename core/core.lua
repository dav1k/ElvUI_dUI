local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
local select, tonumber, assert, type, unpack, pairs = select, tonumber, assert, type, unpack, pairs
local tinsert, tremove = tinsert, tremove
local atan2, modf, ceil, floor, abs, sqrt, mod = math.atan2, math.modf, math.ceil, math.floor, math.abs, math.sqrt, mod
local format, sub, upper, split, utf8sub = string.format, string.sub, string.upper, string.split, string.utf8sub
