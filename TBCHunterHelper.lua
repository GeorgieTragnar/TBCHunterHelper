
local _, TBCHunterHelper = ...
local TBCHunterHelper = LibStub("AceAddon-3.0"):NewAddon(TBCHunterHelper, "TBCHunterHelper", "AceConsole-3.0", "AceEvent-3.0")
local LCG = LibStub("LibCustomGlow-1.0")



local _timeToPredict = 10.0
local _currentSize = 0
local _currentTimeProgress = 0.0
local _actionID = {} -- 0 - autoshot - 1 - steadyshot - 2 - multishot - 3 - arcaneshot - 4 - raptor - 5 - swing
local _timeStart = {}
local _castDur = {}
local _gcdInvoke = {}

local _parentFrame = nil
local _gcdPanel = nil
local _simulatedAutoshotPanel = nil
local _mainTimelineAuto = {}
local _mainTimelineAutoCount = 0
local _mainTimelineSteady = {}
local _mainTimelineSteadyCount = 0
local _mainTimelineMulti = {}
local _mainTimelineMultiCount = 0
local _mainTimelineArcane = {}
local _mainTimelineArcaneCount = 0
local _mainTimelineGCD = {}
local _mainTimelineGCDCount = 0
local _mainTimelineSwingCount = 0
local _mainTimelineRaptorCount = 0

local _mainTimelineAutoIcon = {}
local _mainTimelineSteadyIcon = {}
local _mainTimelineMultiIcon = {}
local _mainTimelineArcaneIcon = {}
local _mainTimelineSwingIcon = {}
local _mainTimelineRaptorIcon = {}


local _baseBowSpeed = 1
local _baseMeleeSpeed = 2.6
local _baseSpeed = 1.0 
local _baseMeleeSpeedMod = 1.0

local _gearHasteRating = 0

local _currentSpeedActual = 1.0 
local _lastB = 0
local _lastM = 0
local _gcd = 0
local _castLeft = 0

local _lastBActual = 0
local _lastMActual = 0
local _gcdActual = 0
local _castLeftActual = 0
local _simulatedAutoshot = false
local _simulatedCastLeftActual = 0
local _simulatedBLeftActual = 0

local _abacusLeftActual = 0
local _drumsLeftActual = 0
local _rapidLeftActual = 0 
local _hawkLeftActual = 0
local _dstLeftActual = 0
local _bloodlustLeftActual = 0
local _hastepotLeftActual = 0
local _multiCdLeftActual = 0
local _arcaneCdLeftActual = 0
local _raptorCdLeftActual = 0

local _abacusLeft = 0
local _drumsLeft = 0
local _rapidLeft = 0 
local _hawkLeft = 0
local _dstLeft = 0
local _bloodlustLeft = 0
local _hastepotLeft = 0
local _multiCdLeft = 0
local _arcaneCdLeft = 0
local _raptorCdLeft = 0
local _step = 0.01

local _arcaneCoef = 0.3
local _multiCoef = 0.6
local _steadyCoef = 1
local _weaveDur = 0.3

local _inCombat = 0
local _xOffset = 800
local _yOffset = -200

local _lastGetTime = 0
local _lastSpellcast = -1
local _lastSpellcastType = -1
local _tmp = 0

local _playerName = nil
local _mark = nil
local _currentTime = nil
local _highlight = nil

local _recalc = true
local _zoom = false

local _autopreview = nil
local _steadypreview = nil
local _multipreview = nil
local _arcanepreview = nil
local _raptorpreview = nil
local _whitepreview = nil

function Start()
	--/run print(UnitRangedDamage("player"))
	_baseBowSpeed = UnitRangedDamage("player")

print(_baseBowSpeed)
--print(GetRangedHaste("player"))

	_lastGetTime = GetTime()
	_playerName = UnitName("player")
	print("staring on enable")
    --if not PlayerIsClass("HUNTER") then return end
    print("is hunter")
	
	--PLAYER_ENTER_COMBAT
	--CURRENT_SPELL_CAST_CHANGED UNIT_SPELLCAST_SUCCEEDED

    getNewTimeline()
	
    print("created timeline")


	print (_currentSize)
	print (_timeStart[0])
	print (_timeStart[1])

	_currentTime = CreateFrame("Frame", nil, UIParent)
	_currentTime:SetSize(64, 64) -- not sure if this is needed when you set absolute sizes on the textures
	_currentTime:SetPoint("LEFT")

	_highlight = CreateFrame("Frame", nil, UIParent)
	_highlight:SetSize(20, 20) -- not sure if this is needed when you set absolute sizes on the textures
	_highlight:SetPoint("LEFT", UIParent, "LEFT", _xOffset, _yOffset - 20)
	_highlight:Hide()

	LCG.PixelGlow_Start(_highlight)

        _mark = _currentTime:CreateTexture()
        _mark:SetWidth(5)
        _mark:SetHeight(40)
        _mark:SetColorTexture(0, 0, 0)
        _mark:SetPoint("LEFT", _currentTime, "LEFT", _xOffset, _yOffset + 5)
	
	_autopreview = _currentTime:CreateTexture()
	_autopreview:SetTexture(GetSpellTexture("Auto Shot"))
        _autopreview:SetPoint("LEFT", _currentTime, "LEFT", _xOffset + 40, _yOffset - 20)
	_autopreview:SetWidth(20)
	_autopreview:SetHeight(20)
        UIFrameFadeIn(_autopreview, 0, 0, 0.6)
	

	_steadypreview = _currentTime:CreateTexture()
	_steadypreview:SetTexture(GetSpellTexture("34120"))
        _steadypreview:SetPoint("LEFT", _currentTime, "LEFT", _xOffset + 20, _yOffset - 20)
	_steadypreview:SetWidth(20)
	_steadypreview:SetHeight(20)
        UIFrameFadeIn(_steadypreview, 0, 0, 0.6)
	
	_multipreview = _currentTime:CreateTexture()
	_multipreview:SetTexture(GetSpellTexture("Multi-Shot"))
        _multipreview:SetPoint("LEFT", _currentTime, "LEFT", _xOffset + 0, _yOffset - 20)
	_multipreview:SetWidth(20)
	_multipreview:SetHeight(20)
        UIFrameFadeIn(_multipreview, 0, 0, 0.6)
	

	_arcanepreview = _currentTime:CreateTexture()
	_arcanepreview:SetTexture(GetSpellTexture("Arcane Shot"))
        _arcanepreview:SetPoint("LEFT", _currentTime, "LEFT", _xOffset - 20, _yOffset - 20)
	_arcanepreview:SetWidth(20)
	_arcanepreview:SetHeight(20)
        UIFrameFadeIn(_arcanepreview, 0, 0, 0.6)
	
	_raptorpreview = _currentTime:CreateTexture()
	_raptorpreview:SetTexture(GetSpellTexture("Raptor Strike"))
        _raptorpreview:SetPoint("LEFT", _currentTime, "LEFT", _xOffset - 40, _yOffset - 20)
	_raptorpreview:SetWidth(20)
	_raptorpreview:SetHeight(20)
        UIFrameFadeIn(_raptorpreview, 0, 0, 0.6)
	
	_whitepreview = _currentTime:CreateTexture()
	_whitepreview:SetTexture(GetSpellTexture("Attack"))
        _whitepreview:SetPoint("LEFT", _currentTime, "LEFT", _xOffset - 60, _yOffset - 20)
	_whitepreview:SetWidth(20)
	_whitepreview:SetHeight(20)
        UIFrameFadeIn(_whitepreview, 0, 0, 0.6)

	_gcdPanel = _currentTime:CreateTexture()
	_gcdPanel:SetWidth(0)
	_gcdPanel:SetHeight(10)
	_gcdPanel:SetColorTexture(0.7, 0.7, 0.7)
	_gcdPanel:SetPoint("LEFT", _currentTime, "LEFT", _xOffset , _yOffset + 20)

	_simulatedAutoshotPanel = _currentTime:CreateTexture()
	_simulatedAutoshotPanel:SetWidth(50)
	_simulatedAutoshotPanel:SetHeight(10)
	_simulatedAutoshotPanel:SetColorTexture(1, 0, 0)
	_simulatedAutoshotPanel:SetPoint("LEFT", _currentTime, "LEFT", _xOffset, _yOffset)
	_simulatedAutoshotPanel:Hide()


	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(64, 64) -- not sure if this is needed when you set absolute sizes on the textures
	frame:SetPoint("CENTER")

	_parentFrame = frame
	_parentFrame:SetPoint("LEFT", UIParent, "LEFT", _xOffset -_currentTimeProgress, _yOffset)	
	_parentFrame:SetScript("OnUpdate", OnUpdate)


	--local texture = _parentFrame:CreateTexture()
	--texture:SetTexture([[Interface\Buttons\WHITE8X8]])
	--texture:SetColorTexture(1,0,0)
	--texture:SetPoint("CENTER") -- this is relative to the frame created above, unless an anchor frame is given
	--texture:SetSize(64, 64)
	--texture:Hide()

    --_parentFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    --_parentFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
    --_parentFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --_parentFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")


local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
	self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function f:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, arg1, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, arg4, arg5, arg6, arg7, arg8, arg9, arg10 = ...

	--print(timestamp, subevent, sourceGUID, sourceName, arg1, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, arg4, arg5, arg6)
	
	if sourceName == _playerName then
		print(subevent, spellName)
print(timestamp, subevent, sourceGUID, sourceName, arg1, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
		
		if subevent == "SPELL_CAST_SUCCESS" then
			if spellName == "Auto Shot" then
				AutoshotEnd()
			elseif spellName == "Steady Shot" or spellName == "Serpent Sting" then
				SteadyshotEnd()
			elseif spellName == "Multi-Shot" then
				MultishotEnd()
			elseif spellName == "Arcane Shot" then
				ArcaneshotEnd()
			elseif spellName == "Raptor Strike" then
				RaptorStrikeCast()
			end
		end
		
		if subevent == "SPELL_CAST_START" then
			if spellName == "Auto Shot" then
				AutoshotStart()
			elseif spellName == "Steady Shot" or spellName == "Serpent Sting" then
				SteadyshotStart()
			elseif spellName == "Multi-Shot" then
				MultishotStart()
			elseif spellName == "Arcane Shot" then
				ArcaneshotStart()
			end
		end

		if subevent == "SPELL_AURA_APPLIED" then
			if spellName == "Quick Shots" then
				QuickShotsStart()
			elseif spellName == "Rapid Fire" then
				RapidFireStart()
			elseif spellName == "Drums of Battle" then
				DrumsStart()
			elseif spellID == 28507 then
				HastepotStart()
			elseif spellID == 34774 then
				DSTStart()
			elseif spellID == 33807 then
				AbacusStart()
			elseif spellID == 2825 or spellID == 32182 then
				BloodlustStart()
			end
		end

		if subevent == "SPELL_AURA_REMOVED" then
			if spellName == "Quick Shots" then
				QuickShotsEnd()
			elseif spellName == "Rapid Fire" then
				RapidFireEnd()
			elseif spellName == "Drums of Battle" then
				DrumsEnd()
			elseif spellID == 28507 then
				HastepotEnd()
			elseif spellID == 34774 then
				DSTEnd()
			elseif spellID == 33807 then
				AbacusEnd()
			elseif spellID == 2825 or spellID == 32182 then
				BloodlustEnd()
			end
		end

		if subevent == "SWING_DAMAGE" then
			print(UnitAttackSpeed("player"))
			Swing()
		end
	end
end


	
    print("created main frame")
    
    _mainTimelineAutoCount = 20
    for i = 0, _mainTimelineAutoCount - 1 
    do
        _mainTimelineAuto[i] = _parentFrame:CreateTexture()
        _mainTimelineAuto[i]:SetWidth(50)
        _mainTimelineAuto[i]:SetHeight(10)
        _mainTimelineAuto[i]:SetColorTexture(1, 0, 0)
        _mainTimelineAuto[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
        _mainTimelineAuto[i]:Hide()

	_mainTimelineAutoIcon[i] = _parentFrame:CreateTexture()
	_mainTimelineAutoIcon[i]:SetTexture(GetSpellTexture("Auto Shot"))
        _mainTimelineAutoIcon[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
	_mainTimelineAutoIcon[i]:SetWidth(20)
	_mainTimelineAutoIcon[i]:SetHeight(20)
        _mainTimelineAutoIcon[i]:Hide()
    end
    
    _mainTimelineSteadyCount = 10
    for i = 0, _mainTimelineSteadyCount - 1 
    do
        _mainTimelineSteady[i] = _parentFrame:CreateTexture()
        _mainTimelineSteady[i]:SetWidth(110)
        _mainTimelineSteady[i]:SetHeight(10)
        _mainTimelineSteady[i]:SetColorTexture(0, 0, 1)
        _mainTimelineSteady[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
        _mainTimelineSteady[i]:Hide()

        _mainTimelineSteadyIcon[i] = _parentFrame:CreateTexture()
	_mainTimelineSteadyIcon[i]:SetTexture(GetSpellTexture("34120"))
        _mainTimelineSteadyIcon[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
	_mainTimelineSteadyIcon[i]:SetWidth(20)
	_mainTimelineSteadyIcon[i]:SetHeight(20)
        --_mainTimelineSteadyIcon[i]:Hide()
    end
    
    _mainTimelineMultiCount = 2
    for i = 0, _mainTimelineMultiCount - 1 
    do
        _mainTimelineMulti[i] = _parentFrame:CreateTexture()
        _mainTimelineMulti[i]:SetWidth(50)
        _mainTimelineMulti[i]:SetHeight(10)
        _mainTimelineMulti[i]:SetColorTexture(0, 1, 0)
        _mainTimelineMulti[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
        _mainTimelineMulti[i]:Hide()

        _mainTimelineMultiIcon[i] = _parentFrame:CreateTexture()
	_mainTimelineMultiIcon[i]:SetTexture(GetSpellTexture("Multi-Shot"))
        _mainTimelineMultiIcon[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
	_mainTimelineMultiIcon[i]:SetWidth(20)
	_mainTimelineMultiIcon[i]:SetHeight(20)
        _mainTimelineMultiIcon[i]:Hide()
    end
    
    _mainTimelineArcaneCount = 3
    for i = 0, _mainTimelineArcaneCount - 1 
    do
        _mainTimelineArcane[i] = _parentFrame:CreateTexture()
        _mainTimelineArcane[i]:SetWidth(10)
        _mainTimelineArcane[i]:SetHeight(10)
        _mainTimelineArcane[i]:SetColorTexture(0, 0.7, 0.7)
        _mainTimelineArcane[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
        _mainTimelineArcane[i]:Hide()

        _mainTimelineArcaneIcon[i] = _parentFrame:CreateTexture()
	_mainTimelineArcaneIcon[i]:SetTexture(GetSpellTexture("Arcane Shot"))
        _mainTimelineArcaneIcon[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
	_mainTimelineArcaneIcon[i]:SetWidth(20)
	_mainTimelineArcaneIcon[i]:SetHeight(20)
        _mainTimelineArcaneIcon[i]:Hide()
    end

	_mainTimelineSwingCount = 20
    for i = 0, _mainTimelineSwingCount - 1 
    do

        _mainTimelineSwingIcon[i] = _parentFrame:CreateTexture()
	_mainTimelineSwingIcon[i]:SetTexture(GetSpellTexture("Attack"))
        _mainTimelineSwingIcon[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
	_mainTimelineSwingIcon[i]:SetWidth(20)
	_mainTimelineSwingIcon[i]:SetHeight(20)
       -- _mainTimelineSwingIcon[i]:Hide()
    end
	
    _mainTimelineRaptorCount = 5
    for i = 0, _mainTimelineRaptorCount - 1 
    do

        _mainTimelineRaptorIcon[i] = _parentFrame:CreateTexture()
	_mainTimelineRaptorIcon[i]:SetTexture(GetSpellTexture("Raptor Strike"))
        _mainTimelineRaptorIcon[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 0)
	_mainTimelineRaptorIcon[i]:SetWidth(20)
	_mainTimelineRaptorIcon[i]:SetHeight(20)
        --_mainTimelineRaptorIcon[i]:Hide()
    end
    
    _mainTimelineGCDCount = 10
    for i = 0, _mainTimelineGCDCount - 1 
    do
        _mainTimelineGCD[i] = _parentFrame:CreateTexture()
        _mainTimelineGCD[i]:SetWidth(150)
        _mainTimelineGCD[i]:SetHeight(10)
        _mainTimelineGCD[i]:SetColorTexture(0.7, 0.7, 0.7)
        _mainTimelineGCD[i]:SetPoint("LEFT", _parentFrame, "LEFT", 0, 10)
        _mainTimelineGCD[i]:Hide()
    end
    --drawTimeline()
	

		getNewTimeline()
		drawGuitarHeroTimeline()
end

function RaptorStrikeCast()
	_recalc = true
	_raptorCdLeftActual = 6
	Swing()
end

function Swing()
	_recalc = true
	_lastMActual = UnitAttackSpeed("player")
end

function BloodlustStart()
	_recalc = true
	_currentSpeedActual = _currentSpeedActual / 1.3
	_bloodlustLeftActual = 40
end

function BloodlustEnd()
	_recalc = true
	_currentSpeedActual = _currentSpeedActual * 1.3
end

function AbacusStart()
	_recalc = true
	_abacusLeftActual = 10
end

function AbacusEnd()
	_recalc = true

end

function DSTStart()
	_recalc = true
	_dstLeftActual = 10
end

function DSTEnd()
	_recalc = true

end

function HastepotStart()
	_recalc = true
	_hastepotLeftActual = 15
end

function HastepotEnd()
	_recalc = true

end

function DrumsStart()
	_recalc = true
	_drumsLeftActual = 30
end

function DrumsEnd()
	_recalc = true

end

function RapidFireStart()
	_recalc = true
	_currentSpeedActual = _currentSpeedActual / 1.4
	_rapidLeftActual = 15
end

function RapidFireEnd()
	_recalc = true
	_currentSpeedActual = _currentSpeedActual * 1.4
end

function QuickShotsStart()
	_recalc = true
	_currentSpeedActual = _currentSpeedActual / 1.15
	_hawkLeftActual = 12
end

function QuickShotsEnd()
	_recalc = true
	_currentSpeedActual = _currentSpeedActual * 1.15
end

function AutoshotStart()
        UIFrameFadeIn(_autopreview, 0, 0, 1)
	_recalc = true
	--_simulatedAutoshotPanel:Show()
	_simulatedAutoshotPanel:SetWidth(50 * _currentSpeedActual)
	_simulatedAutoshot = true
	_lastBActual = _baseBowSpeed * _currentSpeedActual
	_castLeftActual = 0.5 * _currentSpeedActual
	--print("auto")
end

function AutoshotEnd()
        UIFrameFadeIn(_autopreview, 0, 0, 0.6)
	_recalc = true
	_simulatedAutoshotPanel:Hide()
	_simulatedAutoshot = false
	--_lastBActual = _baseBowSpeed * _currentSpeedActual - 0.5 * _currentSpeedActual
	_castLeftActual = 0
	--print("auto")
end

function SteadyshotStart()
        UIFrameFadeIn(_steadypreview, 0, 0, 1)
	_recalc = true
	_castLeftActual = 1.5 * _currentSpeedActual
	--print("steady")
end

function SteadyshotEnd()
        UIFrameFadeIn(_steadypreview, 0, 0, 0.6)
	_recalc = true
--	_castLeftActual = 0
-- only for testing with serpent sting
	_castLeftActual = 1.5 * _currentSpeedActual
	--getNewTimeline()
	--drawTimeline()
	--print("steady")
end

function MultishotStart()
        UIFrameFadeIn(_multipreview, 0, 0, 1)
	_recalc = true
	_castLeftActual = 0.5 * _currentSpeedActual
	--print("multi")
end

function MultishotEnd()
        UIFrameFadeIn(_multipreview, 0, 0, 0.6)
	_recalc = true
	_castLeftActual = 0
	_multiCdLeftActual = 10
	--print("multi")
end

function ArcaneshotStart()
	_recalc = true
	_castLeftActual = 0
	--print("arcane")
end

function ArcaneshotEnd()
	_recalc = true
	_castLeftActual = 0
	_arcaneCdLeftActual = 6
	--print("arcane")
end

function OnUpdate()
	local now = GetTime()
	local delta = now - _lastGetTime

	if _recalc and false then
		_recalc = false
		getNewTimeline()
		drawGuitarHeroTimeline()
	else 
		for i = 0, _currentSize -1
		do
			_timeStart[i] = _timeStart[i] - delta
		end
		drawGuitarHeroTimeline()
	end


	local time = GetTime() - GetSpellCooldown("Serpent Sting")
	_gcdActual = 1.5 - time
	if _gcdActual < 0 then _gcdActual = 0 end
	--_gcdPanel:SetWidth(_gcdActual * 100)
	_gcdPanel:Hide()
	--print(_gcdActual)

	_parentFrame:SetPoint("LEFT", UIParent, "LEFT", _xOffset, _yOffset)

	--_lastB
	if (_lastBActual > 0) then
		_lastBActual = _lastBActual - delta
	end
	if (_lastMActual > 0) then
		_lastMActual = _lastMActual - delta
	end
	if (_castLeftActual > 0) then
		_castLeftActual = _castLeftActual - delta
	end

	if _multiCdLeftActual > 0 then
		_multiCdLeftActual = _multiCdLeftActual - delta
	end

	if _arcaneCdLeftActual > 0 then
		_arcaneCdLeftActual = _arcaneCdLeftActual - delta
	end

	if _raptorCdLeftActual > 0 then
		_raptorCdLeftActual = _raptorCdLeftActual - delta
	end

	if _hawkLeftActual > 0 then
		_hawkLeftActual = _hawkLeftActual - delta
	end

	if _rapidLeftActual > 0 then
		_rapidLeftActual = _rapidLeftActual - delta
	end

	if _drumsLeftActual > 0 then
		_drumsLeftActual = _drumsLeftActual - delta
	end

	if _hastepotLeftActual > 0 then
		_hastepotLeftActual = _hastepotLeftActual - delta
	end

	if _dstLeftActual > 0 then
		_dstLeftActual = _dstLeftActual - delta
	end

	if _abacusLeftActual > 0 then
		_abacusLeftActual = _abacusLeftActual - delta
	end

	if _bloodlustLeftActual > 0 then
		_bloodlustLeftActual = _bloodlustLeftActual - delta
	end

	if _bloodlustLeftActual > 0 or _rapidLeftActual > 0 then
		_zoom = true
	else
		_zoom = false
	end

	_lastGetTime = now
end

function drawGuitarHeroTimeline()
	_mark:SetWidth(140)
	_mark:SetHeight(5)
	_mark:SetPoint("LEFT", _currentTime, "LEFT", _xOffset - 70, _yOffset - 10)
	
    for i = 0, _mainTimelineGCDCount - 1 
    do 
        _mainTimelineGCD[i]:Hide()
    end
    for i = 0, _mainTimelineAutoCount - 1 
    do 
        _mainTimelineAuto[i]:Hide()
        _mainTimelineAutoIcon[i]:Hide()
    end
    for i = 0, _mainTimelineSteadyCount - 1 
    do 
        _mainTimelineSteady[i]:Hide()
        _mainTimelineSteadyIcon[i]:Hide()
    end
    for i = 0, _mainTimelineMultiCount - 1 
    do 
        _mainTimelineMulti[i]:Hide()
        _mainTimelineMultiIcon[i]:Hide()
    end
    for i = 0, _mainTimelineArcaneCount - 1 
    do 
        _mainTimelineArcane[i]:Hide()
        _mainTimelineArcaneIcon[i]:Hide()
    end
    for i = 0, _mainTimelineSwingCount - 1 
    do 
        _mainTimelineSwingIcon[i]:Hide()
    end
    for i = 0, _mainTimelineRaptorCount - 1 
    do 
        _mainTimelineRaptorIcon[i]:Hide()
    end
    -- main draw loop
    local auto = 0
    local steady = 0
    local multi = 0
    local arcane = 0
	local swing = 0
	local raptor = 0
    local gcd = 0

	local length = 30
	if _zoom then
		length = 60
	end

	if _simulatedAutoshot then
		_mainTimelineAutoIcon[auto]:Show()
		_mainTimelineAutoIcon[auto]:SetPoint("LEFT", _parentFrame, "LEFT", 40, _castLeftActual * length - _currentSpeedActual * length)
		auto = 1

		local xoffset = 20
		if _actionID[0] == 1 then
			offset = 20
		elseif _actionID[0] == 2 then
			offset = 0
		elseif _actionID[0] == 3 then
			offset = -20
		elseif _actionID[0] == 4 then
			offset = -40
		elseif _actionID[0] == 5 then
			offset = -60
	        end
		_highlight:SetPoint("LEFT", UIParent, "LEFT", _xOffset + offset, _yOffset + _timeStart[0] * length)
		_highlight:Show()
	else 
		_highlight:Hide()
	end

    for i = 0, _currentSize - 1
    do
        if _actionID[i] == 0 then
            _mainTimelineAutoIcon[auto]:Show()
            _mainTimelineAutoIcon[auto]:SetPoint("LEFT", _parentFrame, "LEFT", 40, _timeStart[i] * length)
            auto = auto + 1
        elseif _actionID[i] == 1 then
            _mainTimelineSteadyIcon[steady]:Show()
            _mainTimelineSteadyIcon[steady]:SetPoint("LEFT", _parentFrame, "LEFT", 20, _timeStart[i] * length)
            steady = steady + 1
        elseif _actionID[i] == 2 then
            _mainTimelineMultiIcon[multi]:Show()
            _mainTimelineMultiIcon[multi]:SetPoint("LEFT", _parentFrame, "LEFT", 0, _timeStart[i] * length)
            multi = multi + 1
        elseif _actionID[i] == 3 then
            _mainTimelineArcaneIcon[arcane]:Show()
            _mainTimelineArcaneIcon[arcane]:SetPoint("LEFT", _parentFrame, "LEFT", -20, _timeStart[i] * length)
            arcane = arcane + 1
        elseif _actionID[i] == 4 then
            _mainTimelineRaptorIcon[raptor]:Show()
            _mainTimelineRaptorIcon[raptor]:SetPoint("LEFT", _parentFrame, "LEFT", -40, _timeStart[i] * length)
            raptor = raptor + 1
        elseif _actionID[i] == 5 then
            _mainTimelineSwingIcon[swing]:Show()
            _mainTimelineSwingIcon[swing]:SetPoint("LEFT", _parentFrame, "LEFT", -60, _timeStart[i] * length)
            swing = swing + 1
        end
    end
end

function drawTimeline()
    --_currentTimeProgress = 0
    --_parentFrame:SetPoint("LEFT", UIParent, "LEFT", _xOffset -_currentTimeProgress, _yOffset)
    -- 1s = 100px
    for i = 0, _mainTimelineAutoCount - 1 
    do 
        _mainTimelineAuto[i]:Hide()
        _mainTimelineAutoIcon[i]:Hide()
    end
    for i = 0, _mainTimelineSteadyCount - 1 
    do 
        _mainTimelineSteady[i]:Hide()
        _mainTimelineSteadyIcon[i]:Hide()
    end
    for i = 0, _mainTimelineMultiCount - 1 
    do 
        _mainTimelineMulti[i]:Hide()
        _mainTimelineMultiIcon[i]:Hide()
    end
    for i = 0, _mainTimelineArcaneCount - 1 
    do 
        _mainTimelineArcane[i]:Hide()
        _mainTimelineArcaneIcon[i]:Hide()
    end
    -- main draw loop
    local auto = 0
    local steady = 0
    local multi = 0
    local arcane = 0
    local gcd = 0

	if _simulatedAutoshot then
		_mainTimelineAuto[auto]:Show()
		_mainTimelineAuto[auto]:SetPoint("LEFT", _parentFrame, "LEFT", _castLeftActual * 100 - _currentSpeedActual * 50, 0)
		_mainTimelineAuto[auto]:SetWidth(_currentSpeedActual * 50)
		auto = 1

		_highlight:SetPoint("LEFT", UIParent, "LEFT", _xOffset + _timeStart[0] * 100, _yOffset - 20)
		_highlight:Show()

	else 
		_highlight:Hide()
	end

	--print(_gcdActual)
	if _gcdActual > 0 then
            _mainTimelineGCD[gcd]:Show()
            _mainTimelineGCD[gcd]:SetPoint("LEFT", _parentFrame, "LEFT",_gcdActual * 100 - 150, 10)
            _mainTimelineGCD[gcd]:SetWidth(149)
            gcd = 1
	end

    for i = 0, _currentSize - 1
    do
        if _gcdInvoke[i] == 1 then
            _mainTimelineGCD[gcd]:Show()
            _mainTimelineGCD[gcd]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, 10)
            _mainTimelineGCD[gcd]:SetWidth(149)
            gcd = gcd + 1
        end
        if _actionID[i] == 0 then
            _mainTimelineAuto[auto]:Show()
            _mainTimelineAuto[auto]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, 0)
            _mainTimelineAuto[auto]:SetWidth(_castDur[i] * 100)
            _mainTimelineAutoIcon[auto]:Show()
            _mainTimelineAutoIcon[auto]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, -20)
            auto = auto + 1
        elseif _actionID[i] == 1 then
            _mainTimelineSteady[steady]:Show()
            _mainTimelineSteady[steady]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, 0)
            _mainTimelineSteady[steady]:SetWidth(_castDur[i] * 100)
            _mainTimelineSteadyIcon[steady]:Show()
            _mainTimelineSteadyIcon[steady]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, -20)
            steady = steady + 1
        elseif _actionID[i] == 2 then
            _mainTimelineMulti[multi]:Show()
            _mainTimelineMulti[multi]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, 0)
            _mainTimelineMulti[multi]:SetWidth(_castDur[i] * 100)
            _mainTimelineMultiIcon[multi]:Show()
            _mainTimelineMultiIcon[multi]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, -20)
            multi = multi + 1
        elseif _actionID[i] == 3 then
            _mainTimelineArcane[arcane]:Show()
            _mainTimelineArcane[arcane]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, 0)
            _mainTimelineArcane[arcane]:SetWidth(10)
            _mainTimelineArcaneIcon[arcane]:Show()
            _mainTimelineArcaneIcon[arcane]:SetPoint("LEFT", _parentFrame, "LEFT", _timeStart[i] * 100, -20)
            arcane = arcane + 1
        end
    end
end

function getNewTimeline()            
    -- clear the arrays that hold rotation info
    for i = 0, _currentSize 
    do 
        _actionID[i]=nil 
        _timeStart[i]=nil 
        _castDur[i]=nil 
        _gcdInvoke[i]=nil 
    end
    _currentSize = 0
    -- update all global variables (current time left on cds especially)
    -- TODO            

	_gcd = _gcdActual

	_castLeft = _castLeftActual
	_lastB = _lastBActual
	_lastM = _lastMActual

	_abacusLeft = _abacusLeftActual
	_drumsLeft = _drumsLeftActual
	_rapidLeft = _rapidLeftActual
	_hawkLeft = _hawkLeftActual
	_dstLeft = _dstLeftActual
	_bloodlustLeft = _bloodlustLeftActual
	_hastepotLeft = _hastepotLeftActual
	
	_raptorCdLeft = _raptorCdLeftActual
    
    if _multiCdLeftActual == nil or _multiCdLeftActual == 0 then
        _multiCdLeft = 0
    else
        _multiCdLeft = _multiCdLeftActual
    end

    if _arcaneCdLeftActual == nil or _arcaneCdLeftActual == 0 then
        _arcaneCdLeft = 0
    else
        _arcaneCdLeft = _arcaneCdLeftActual
    end

    -- start the main prediction loop
    local arrayIndex = 0
    local currentBowSpeed = _baseSpeed
	local currentMeleeSpeed = _baseMeleeSpeedMod
    local currentHasteRating = _gearHasteRating
    for t = 0, _timeToPredict * 100
    do
	--security nil checks fml rly
	if _multiCdLeft == nil then _multiCdLeft = 0 end
	if _arcaneCdLeft == nil then _arcaneCdLeft = 0 end




        if _abacusLeft > 0 then
            currentHasteRating = currentHasteRating + 260
        end
        if _drumsLeft > 0 then
            currentHasteRating = currentHasteRating + 80
        end
        if _dstLeft > 0 then
            currentHasteRating = currentHasteRating + 325
        end
        if _hastepotLeft > 0 then
            currentHasteRating = currentHasteRating + 400
        end
        currentBowSpeed = _baseSpeed / (1 + currentHasteRating / 1577)
	currentMeleeSpeed = _baseMeleeSpeedMod / (1 + currentHasteRating / 1577)
        if _hawkLeft > 0 then
            currentBowSpeed = currentBowSpeed / 1.15
        end
        if _bloodlustLeft > 0 then
            currentBowSpeed = currentBowSpeed / 1.3
        end
        if _rapidLeft > 0 then
            currentBowSpeed = currentBowSpeed / 1.4
        end
--print(currentBowSpeed)
        -- cast autoshot
        if _lastB <= 0 and _castLeft <= 0 then
            _lastB = _baseBowSpeed * currentBowSpeed
            _castLeft = 0.5 * currentBowSpeed

            _actionID[arrayIndex] = 0
            _timeStart[arrayIndex] = t / 100
            _castDur[arrayIndex] = _castLeft
            _gcdInvoke[arrayIndex] = 0
            arrayIndex = arrayIndex + 1
            _currentSize = _currentSize + 1
        end

	if _lastM <= 0 and _lastB > _weaveDur and _castLeft <= 0 then
		_castLeft = _weaveDur
		if _raptorCdLeft <= 0 then
            		_actionID[arrayIndex] = 4
			_raptorCdLeft = 6
		else
            		_actionID[arrayIndex] = 5
		end
		_lastM = _baseMeleeSpeed * currentMeleeSpeed
            	_timeStart[arrayIndex] = t / 100
            	_castDur[arrayIndex] = _castLeft
            	_gcdInvoke[arrayIndex] = 0
            	arrayIndex = arrayIndex + 1
            	_currentSize = _currentSize + 1
	end

        if _castLeft <= 0 and _gcd <= 0 then
            if (_lastB < (currentBowSpeed * 1.5 * _arcaneCoef) and _arcaneCdLeft <= 0) or
            (_lastB < (currentBowSpeed * 1.5 * _multiCoef) and _multiCdLeft <= 0) or
            (_lastB > (currentBowSpeed * 1.5 * _steadyCoef)) then
                if (_lastB < (currentBowSpeed * 1.5 * _arcaneCoef) and _arcaneCdLeft <= 0) then 
                    _gcd = 1.5
                    _castLeft = 0
                    _arcaneCdLeft = 6                                                           

                    _actionID[arrayIndex] = 3
                    _timeStart[arrayIndex] = t / 100
                    _castDur[arrayIndex] = _castLeft
                    _gcdInvoke[arrayIndex] = 1
                    arrayIndex = arrayIndex + 1
                    _currentSize = _currentSize + 1
                elseif (_lastB < (currentBowSpeed * 1.5 * _multiCoef) and _multiCdLeft <= 0) then
                    _gcd = 1.5
                    _castLeft = currentBowSpeed * 0.5
                    _multiCdLeft = 10

                    _actionID[arrayIndex] = 2
                    _timeStart[arrayIndex] = t / 100
                    _castDur[arrayIndex] = _castLeft
                    _gcdInvoke[arrayIndex] = 1
                    arrayIndex = arrayIndex + 1
                    _currentSize = _currentSize + 1
                else 
                    _gcd = 1.5
                    _castLeft = currentBowSpeed * 1.5

                    _actionID[arrayIndex] = 1
                    _timeStart[arrayIndex] = t / 100
                    _castDur[arrayIndex] = _castLeft
                    _gcdInvoke[arrayIndex] = 1
                    arrayIndex = arrayIndex + 1
                    _currentSize = _currentSize + 1
                end
            end
        end


        -- progress simulated future time on all variables
        _lastB = _lastB - _step
	_lastM = _lastM - _step
        _gcd = _gcd - _step
	_castLeft = _castLeft - _step
        _rapidLeft = _rapidLeft - _step
        _hawkLeft = _hawkLeft - _step
        _dstLeft = _dstLeft - _step
        _bloodlustLeft = _bloodlustLeft - _step
        _hastepotLeft = _hastepotLeft - _step
	_drumsLeft = _drumsLeft - _step
	if _multiCdLeft == nil then _multiCdLeft = -_step
	else _multiCdLeft = _multiCdLeft - _step end
        _arcaneCdLeft = _arcaneCdLeft - _step
	



    end    
	--print(_actionID[0], " ", _castDur[0], " ", _timeStart[0])
	--print(_actionID[1], " ", _castDur[1], " ", _timeStart[1])
	--print(_actionID[2], " ", _castDur[2], " ", _timeStart[2])
	--print(_actionID[3], " ", _castDur[3], " ", _timeStart[3])
	--print(_actionID[4], " ", _castDur[4], " ", _timeStart[4]) 
end

Start()

