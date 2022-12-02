local noteOffsetX = 25;
local SustainNoteOffsetX = 10;

local noteOffsetY = 0;
local SustainNoteOffsetY = -32;

local defaultNotePos = {};

function onSongStart()
    for i = 0,7 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
		alpha = getPropertyFromGroup('strumLineNotes', i, 'alpha')
        angle = getPropertyFromGroup('strumLineNotes', i, 'angle')
 
        table.insert(defaultNotePos, {x,y,alpha,angle})
    end
end

local songPos;
local downScrollValue = -1;
function onUpdate(elapsed)
	songPos = getSongPosition()
	--setProperty('health', 2);
	if mechanics == true then
		setProperty('healthGain', 1.5);
		setProperty('healthLoss', 0.5);
	end

	if downscroll then
        downScrollValue = 1
    else
        downScrollValue = -1
    end
end

function onStepHit()
	if mechanics == true then
		if curStep == 1 then
			noteTweenX('Movement X 0', 0, defaultPlayerStrumX0, 7.38 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 1', 1, defaultPlayerStrumX1, 7.38 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 2', 2, defaultPlayerStrumX2, 7.38 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 3', 3, defaultPlayerStrumX3, 7.38 / initialPlaybackRate, 'quadOut')
		end
		if curStep == 64 then
			noteTweenX('Movement X 4', 4, defaultOpponentStrumX0, 7.38 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 5', 5, defaultOpponentStrumX1, 7.38 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 6', 6, defaultOpponentStrumX2, 7.38 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 7', 7, defaultOpponentStrumX3, 7.38 / initialPlaybackRate, 'quadOut')
			for i = 4,7 do noteTweenAlpha('Alpha ' .. i, i, 0.35, 7.38, 'quadOut') end
			for j = 0,3 do for i = 4,7 do noteTweenAlpha('Alpha ' .. j, j, defaultNotePos[i+1][3], 7.38, 'quadOut') end end
		end
		if curStep == 188 then
			noteTweenX('Movement X 0', 0, defaultOpponentStrumX0, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 1', 1, defaultOpponentStrumX1, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 2', 2, defaultOpponentStrumX2, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 3', 3, defaultOpponentStrumX3, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 4', 4, defaultPlayerStrumX0, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 5', 5, defaultPlayerStrumX1, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 6', 6, defaultPlayerStrumX2, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 7', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate, 'quadOut')
			for i = 0,7 do
				noteTweenAngle('Angle ' .. i, i, 360, 0.46 / initialPlaybackRate)
			end
			for j = 0,3 do
				noteTweenAlpha('Alpha ' .. j, j, 0.35, 0.46 / initialPlaybackRate, 'quadOut')
			end
			for k = 4,7 do 
				noteTweenAlpha('Alpha ' .. k, k, defaultNotePos[k+1][3], 0.46 / initialPlaybackRate, 'quadOut')
			end
		end
		if curStep == 252 then
			noteTweenX('Movement X 0', 0, defaultPlayerStrumX0, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 1', 1, defaultPlayerStrumX1, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 2', 2, defaultPlayerStrumX2, 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenX('Movement X 3', 3, defaultPlayerStrumX3, 0.46 / initialPlaybackRate, 'quadOut')
			for i = 4,7 do 
				noteTweenY('Movement Y ' .. i, i, (downscroll and 1000 or -150), (0.115 / initialPlaybackRate) * i, 'circInOut')
			end
			for i = 0,3 do
				noteTweenAngle('Angle ' .. i, i, 0, 0.46 / initialPlaybackRate)
				for j = 4,7 do noteTweenAlpha('Alpha ' .. i, i, defaultNotePos[j+1][3], 0.46 / initialPlaybackRate, 'quadOut') end
			end
		end
		if curStep == 316 then
			for i = 4,7 do noteTweenY('Movement Y '..i, i, defaultPlayerStrumY0, (0.115 / initialPlaybackRate) * i, 'circInOut') end
			for i = -1,3 do noteTweenY('Movement Y '..i, i, (downscroll and 1000 or -150), (0.115 / initialPlaybackRate) * i, 'circInOut') end
		end
		if curStep == 376 then
			for i = 0,3 do 
				noteTweenX('Movement X '..i, i, defaultNotePos[i + 1][1], 0.46 / initialPlaybackRate, 'quadOut') 
				noteTweenAlpha('Alpha ' .. i, i, 0.35, 0.46 / initialPlaybackRate, 'quadOut')
			end
			noteTweenY('Movement Y 1', 1, defaultNotePos[1 + 1][2], 0.46 / initialPlaybackRate, 'quadOut')
			noteTweenY('Movement Y 0', 0, (downscroll and defaultNotePos[0 + 1][2]-50 or defaultNotePos[0 + 1][2]+50), 0.46 / initialPlaybackRate, 'quadOut') 
			noteTweenY('Movement Y 2', 2, defaultNotePos[2 + 1][2], 0.46, 'quadOut')
			noteTweenY('Movement Y 3', 3, (downscroll and defaultNotePos[3 + 1][2]-50 or defaultNotePos[3 + 1][2]+50), 0.46 / initialPlaybackRate, 'quadOut') 
			noteTweenAngle('Angle 3', 3, (downscroll and -25 or 25), 0.46 / initialPlaybackRate)
			noteTweenAngle('Angle 0', 0, 25, 0.46 / initialPlaybackRate)
		end
		if curStep == 504 then
			for i = 0,3 do
				noteTweenAngle('Angle '..i, i, 360, 0.46 / initialPlaybackRate)
				noteTweenX('Movement X 0', 0, defaultPlayerStrumX0, 0.46 / initialPlaybackRate, 'quadOut')
				noteTweenX('Movement X 1', 1, defaultPlayerStrumX1, 0.46 / initialPlaybackRate, 'quadOut')
				noteTweenX('Movement X 2', 2, defaultPlayerStrumX2, 0.46 / initialPlaybackRate, 'quadOut')
				noteTweenX('Movement X 3', 3, defaultPlayerStrumX3, 0.46 / initialPlaybackRate, 'quadOut')
				noteTweenY('Movement Y '..i, i, (downscroll and 50 or 570), 0.46 / initialPlaybackRate, 'quadOut')
				for j = 4,7 do noteTweenAlpha('Alpha ' .. i, i, defaultNotePos[j+1][3], 0.46 / initialPlaybackRate, 'quadOut') end
			end
		end
		if curStep == 576 then
			for i = 0,3 do
				noteTweenAngle('Angle '..i, i, 0, 0.23 / initialPlaybackRate)
				noteTweenY('Movement Y '..i, i, (downscroll and 570 or 50), 0.46 / initialPlaybackRate, 'quadOut')
			end
			for i = 4,7 do
				noteTweenAngle('Angle '..i, i, 0, 0.23 / initialPlaybackRate)
				noteTweenY('Movement Y '..i, i, (downscroll and 50 or 570), 0.46 / initialPlaybackRate, 'quadOut')
			end
		end
		if curStep == 640 then for i = 4,7 do noteTweenY('Movement Y '..i, i, (downscroll and -150 or 1000), (0.115 / initialPlaybackRate) * i, 'circInOut') end end
		if curStep == 654 then 
			for i = 4,7 do 
				noteTweenY('Movement Y '..i, i, (downscroll and 1000 or -150), 0.0001 / initialPlaybackRate, 'quadOut') 
			end
			noteTweenX('Movement X 0', 0, defaultPlayerStrumX3, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 1', 1, defaultPlayerStrumX2, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 2', 2, defaultPlayerStrumX1, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 3', 3, defaultPlayerStrumX0, 0.23 / initialPlaybackRate, 'quadOut') 
		end
		if curStep == 670 then 
			for i = -1,3 do noteTweenY('Movement Y '..i, i, (downscroll and 1000 or -150), (0.115 / initialPlaybackRate) * i, 'circInOut') end
			for i = 4,7 do noteTweenY('Movement Y '..i, i, defaultNotePos[i + 1][2], (0.115 / initialPlaybackRate) * i, 'circInOut') end
		end
		if curStep == 686 then 
			noteTweenX('Movement X 4', 4, defaultPlayerStrumX3, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 5', 5, defaultPlayerStrumX2, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 6', 6, defaultPlayerStrumX1, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 7', 7, defaultPlayerStrumX0, 0.23 / initialPlaybackRate, 'quadOut') 

			noteTweenX('Movement X 0', 0, defaultPlayerStrumX0, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 1', 1, defaultPlayerStrumX1, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 2', 2, defaultPlayerStrumX2, 0.23 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 3', 3, defaultPlayerStrumX3, 0.23 / initialPlaybackRate, 'quadOut') 
			for i = 0,3 do noteTweenAlpha('Alpha ' .. i, i, 0, 0.000001 / initialPlaybackRate, 'quadOut') end
			for i = 0,3 do
				for j = 4,7 do noteTweenY('Movement Y '..i, i, defaultNotePos[j + 1][2], 0.000001 / initialPlaybackRate, 'quadOut') end
			end
		end
		if curStep == 702 then 
			for i = 4,7 do noteTweenAlpha('Alpha ' .. i, i, 0, 0.23 / initialPlaybackRate, 'quadOut') end
			for i = 0,3 do for j = 4,7 do noteTweenAlpha('Alpha ' .. i, i, defaultNotePos[j+1][3], 0.23 / initialPlaybackRate, 'quadOut') end end
		end
		if curStep == 716 then
			noteTweenX('Movement X 4', 4, defaultPlayerStrumX0, 0.00001 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 5', 5, defaultPlayerStrumX1, 0.00001 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 6', 6, defaultPlayerStrumX2, 0.00001 / initialPlaybackRate, 'quadOut') 
			noteTweenX('Movement X 7', 7, defaultPlayerStrumX3, 0.00001 / initialPlaybackRate, 'quadOut') 
		end
		if curStep == 732 then
			for i = 4,7 do noteTweenAlpha('Alpha ' .. i, i, defaultNotePos[i+1][3], 0.46 / initialPlaybackRate, 'quadOut') end
			for i = 0,3 do noteTweenAlpha('Alpha ' .. i, i, 0, 0.46 / initialPlaybackRate, 'quadOut') end
		end
		if curStep == 748 then
			for i = 0,3 do noteTweenX('Movement X ' .. i, i, defaultNotePos[i + 1][1], 0.00001 / initialPlaybackRate, 'quadOut') end
		end
		if curStep == 764 then
			for i = 0,3 do noteTweenAlpha('Alpha ' .. i, i, 0.35, 0.46 / initialPlaybackRate, 'quadOut') end
		end
		if curStep == 896 then
			resetStrums(true, true, true, true, 0, 7, 0.1 / initialPlaybackRate)
		end
	end
end

function roundDecimal(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
  	return math.floor(num * mult + 0.5) / mult
end

function lerp(a, b, t)
	return a + (b - a) * t
end

function resetStrums(resetX, resetY, resetAlpha, resetAngle, startingNote, endingNote, resetTime)
	for i = startingNote,endingNote do
		if resetX then noteTweenX("resetStrumX" .. i, i, defaultNotePos[i + 1][1], resetTime, "quadOut") end
		if resetY then noteTweenY("resetStrumY" .. i, i, defaultNotePos[i + 1][2], resetTime, "quadOut") end
		if resetAlpha then noteTweenAlpha("resetStrumAlpha" .. i, i, defaultNotePos[i + 1][3], resetTime, "quadOut") end
		if resetAngle then noteTweenAngle("resetStrumScale" .. i, i, defaultNotePos[i + 1][4], resetTime, "quadOut") end
		setPropertyFromGroup('strumLineNotes', i, 'downScroll', downscroll)
	end
end