-- Based on ElvUI Framework
-- Sourced from TukUI Lua Forum
-- http://www.tukui.org/forums/forum.php?id=27

-- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI);

-- Create a plugin within ElvUI
-- Adopt AceHook, AceEvent and AceTimer
local dUI = E:NewModule('dUI', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');

local EP = LibStub('LibElvUIPlugin-1.0')
-- Used to insert GUI tables when ElvUI_Config is loaded.

local addonName, addonTable = ...
-- As shown: http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

-- Bind Globals
local tinsert = table.insert

-- Begin Plugin Registration
dUI.Config = {}

function dUI:cOption(str)
  local color = 'ff68aeff'
  return format('|c%s%s|r', color, str)
end

-- Default Options
P['dUI'] = {}

local function createDefaultOptions()
end

tinsert(dUI.Config, createDefaultOptions)

function dUI:AddOptions()
  for _, func in pairs(dUI.Config) do
    func()
  end
end


-- Register plugin and properly insert config during load
function dUI:Initialize()
  print(dUI:cOption('dUI'), 'plugin load was successful.')
  EP:RegisterPlugin(addonName, dUI.AddOptions)
end

-- Register the module with ElvUI
-- ElvUI will call Initialize() when its ready to load this plugin
E:RegisterModule(dUI:GetName())
