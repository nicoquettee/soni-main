local strumy = 50;
local plushit = 10;
local doit = 1;

local anglevents = false
local angleshit = 1;
local anglevar = 1;

function onStepHit()
	if mechanics == true then
		if curStep == 408 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 512 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 624 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 656 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 708 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 760 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1088 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1152 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1168 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1232 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1240 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1244 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1288 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1296 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1320 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1328 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1344 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1348 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1360 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1376 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1384 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1408 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1424 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1476 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end
		if curStep == 1536 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			end
		end
		if curStep == 1664 then
			if downscroll == true then
				triggerEvent('Play Animation', 'singDOWN-alt', 'dad')
			else
				triggerEvent('Play Animation', 'singUP-alt', 'dad')
			end
		end

		if curStep == 412 or curStep == 540 or curStep == 616 or curStep == 764 or curStep == 1160 or 
		   curStep == 1216 or curStep == 1280 or curStep == 1292 or curStep == 1352 or curStep == 1392 or 
		   curStep == 1472 or curStep == 1532 then
			triggerEvent('Play Animation', 'singLEFT-alt', 'dad')
		end
		if curStep == 536 or curStep == 608 or curStep == 704 or curStep == 768 or curStep == 1176 or 
		   curStep == 1224 or curStep == 1284 or curStep == 1312 or curStep == 1356 or curStep == 1400 or 
		   curStep == 1528 or curStep == 1672 then
			triggerEvent('Play Animation', 'singRIGHT-alt', 'dad')
		end
	end
end

function onUpdate(elapsed)
	songPos = getSongPosition()
	local currentBeat = (songPos/1000)
	if mechanics == true then
		--Y modchart
		if curStep == 408 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 512 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 624 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 656 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 708 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 760 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1088 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1152 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1168 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1232 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1240 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1244 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1288 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1296 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1320 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1328 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1344 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1348 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1360 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1376 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1384 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1408 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1424 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1476 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1536 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and -0.45 or 0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		if curStep == 1664 then
			for i = 0,7 do
				if downscroll == true then
					noteTweenY('movementY ' .. i, i, 570, 0.4 / initialPlaybackRate, 'quadOut')
				else
					noteTweenY('movementY ' .. i, i, 50, 0.4 / initialPlaybackRate, 'quadOut')
				end
			end
			noteTweenDistance('distance', (downscroll and 0.45 or -0.45), 0.4 / initialPlaybackRate, 'quadOut');
		end
		--X modchart
		if curStep == 412 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 536 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 540 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 608 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 616 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 704 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 764 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 768 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1160 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1176 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1216 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1224 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1280 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1284 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1292 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1312 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1352 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1356 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1392 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1400 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1472 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1528 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1532 then
			noteTweenX('playerx1', 4, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1528 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
		if curStep == 1672 then
			noteTweenX('playerx1', 4, defaultPlayerStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('playerx2', 5, defaultPlayerStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('playerx3', 6, defaultPlayerStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('playerx4', 7, defaultPlayerStrumX3, 0.4 / initialPlaybackRate)

			noteTweenX('opponentx1', 0, defaultOpponentStrumX0, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx2', 1, defaultOpponentStrumX1, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx3', 2, defaultOpponentStrumX2, 0.4 / initialPlaybackRate)
			noteTweenX('opponentx4', 3, defaultOpponentStrumX3, 0.4 / initialPlaybackRate)
		end
	end
end