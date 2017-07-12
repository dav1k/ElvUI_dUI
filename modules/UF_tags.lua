-- Insert Custom ElvUI tags for use in UnitFrames
local E, L, V, P, G = unpack(ElvUI); -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

-- Grab ElvUI's UnitFrames
local UF = E:GetModule('UnitFrames');
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecializationInfo = GetSpecializationInfo
