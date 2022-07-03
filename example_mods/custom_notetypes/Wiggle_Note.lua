
local wiggleIntense = 20
local wiggleDurationTime = 1

function onUpdate(elapsed)
   randomThingi()
end

function randomThingi()
   for i = 0, getProperty('notes.length')-1 do
      local noteType = getPropertyFromGroup('notes', i, 'noteType');
      local distance = 0.45 * (getSongPosition() - getPropertyFromGroup('notes', i, 'strumTime')) * getProperty('songSpeed');
      local resultWiggle = math.sin(distance / (50) / wiggleDurationTime) * (wiggleIntense);
      local fixOffset = (getPropertyFromClass("PlayState", "isPixelState") and 30 or getPropertyFromClass("Notes", "swagWidth") / 2)

      if resultWiggle ~= 0 and (getPropertyFromGroup("notes", i, "noteType") == "Wiggle Note" or getPropertyFromGroup("notes", i, "noteType") == "Wiggle_Note") then 
         setPropertyFromGroup('notes', i, 'offsetX', resultWiggle + (getPropertyFromGroup('notes', i, 'isSustainNote') and fixOffset or 0)) 
      end
      
   end
end

function lerp(a, b, t)
   return a + (b - a) * t
end