local strumy = 50;
local plushit = 10;
local doit = 1;

local anglevents = false
local angleshit = 1;
local anglevar = 1;

function onUpdate(elapsed)
	songPos = getSongPosition()
	local currentBeat = (songPos/1000)

	if curStep == 1 then
		noteTweenX('Movement X 0', 0, defaultPlayerStrumX0, 7.38)
		noteTweenX('Movement X 1', 1, defaultPlayerStrumX1, 7.38)
		noteTweenX('Movement X 2', 2, defaultPlayerStrumX2, 7.38)
		noteTweenX('Movement X 3', 3, defaultPlayerStrumX3, 7.38)
	end

	for i = 4,7 do
		if curStep == 64 then
			noteTweenX('Movement X 4', 4, defaultOpponentStrumX0, 7.38)
			noteTweenX('Movement X 5', 5, defaultOpponentStrumX1, 7.38)
			noteTweenX('Movement X 6', 6, defaultOpponentStrumX2, 7.38)
			noteTweenX('Movement X 7', 7, defaultOpponentStrumX3, 7.38)
			noteTweenAlpha('Alpha ' .. i, i, 0.35, 7.38)
			for j = 0,3 do
				noteTweenAlpha('Alpha ' .. j, j, 1, 7.38)
			end
		end
		if curStep == 188 then
			noteTweenX('Movement X 0', 0, defaultOpponentStrumX0, 0.46)
			noteTweenX('Movement X 1', 1, defaultOpponentStrumX1, 0.46)
			noteTweenX('Movement X 2', 2, defaultOpponentStrumX2, 0.46)
			noteTweenX('Movement X 3', 3, defaultOpponentStrumX3, 0.46)
			noteTweenX('Movement X 4', 4, defaultPlayerStrumX0, 0.46)
			noteTweenX('Movement X 5', 5, defaultPlayerStrumX1, 0.46)
			noteTweenX('Movement X 6', 6, defaultPlayerStrumX2, 0.46)
			noteTweenX('Movement X 7', 7, defaultPlayerStrumX3, 0.46)
			for i = 0,7 do
				noteTweenAngle('Angle ' .. i, i, 360, 0.46)
			end
			for j = 0,3 do
				noteTweenAlpha('Alpha ' .. j, j, 0.35, 0.46)
			end
			for k = 4,7 do 
				noteTweenAlpha('Alpha ' .. k, k, 1, 0.46)
			end
		end
	end
end