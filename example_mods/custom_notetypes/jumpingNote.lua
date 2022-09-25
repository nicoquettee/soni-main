local from = {x = 0, y = 0, angle = 0, time = 0};
local to = {x = 0, y = 0, angle = 0, time = 0};
local currentNote = nil;
local add360 = false;
local str = nil;
local e = false;
local songPos;

function onCreatePost()
    from.x = 1280;
    from.y = 720;

    for i = 0, getProperty('notes.length')-1 do
        setPropertyFromGroup('notes', i, 'alpha', 0)
    end

    makeAnimatedLuaSprite('jumpingNote', 'NOTE_assets_white', from.x, from.y)
    addAnimationByPrefix('jumpingNote', 'arrow', 'green', 1, true)
    objectPlayAnimation('jumpingNote', 'arrow')
    setGraphicSize('jumpingNote', 0.7, 0.7, true)
    setObjectCamera('jumpingNote', 'camHUD')

    makeAnimatedLuaSprite('coloredJumpingNote', 'NOTE_assets_white', from.x, from.y)
    addAnimationByPrefix('coloredJumpingNote', 'arrow', 'green', 1, true)
    objectPlayAnimation('coloredJumpingNote', 'arrow')
    setGraphicSize('coloredJumpingNote', 0.7, 0.7, true)
    setObjectCamera('coloredJumpingNote', 'camHUD')
    setProperty('coloredJumpingNote.alpha', 0)

    addLuaSprite('jumpingNote')
    addLuaSprite('coloredJumpingNote')
end

function onUpdate(elapsed)
    songPos = getSongPosition()
    for i = 0, getProperty('notes.length')-1 do
        setPropertyFromGroup('notes', i, 'sort', function(a,b)
            if getProperty('a.strumTime') < getProperty('b.strumTime') then return -1
            elseif getProperty('a.strumTime') < getProperty('b.strumTime') then return 1
            else return 0 end
        end)

        if getPropertyFromGroup('notes', i, 'length') < 1 then
            setProperty('jumpingNote.visible', false)
        else
            setProperty('jumpingNote.visible', true and e)
            if currentNote ~= getProperty('notes.members[0]') then
                setProperty('coloredJumpingNote.alpha', 1)
                from.x = to.x
                from.y = to.y
                from.angle = to.angle
                if currentNote ~= nil then
                    from.time = getProperty('currentNote.strumTime')
                end
                currentNote = getProperty('notes.members[0]')
                add360 = not add360
                dir = getProperty('currentNote.noteData') % getProperty('playerStrums.length')
                str = (getProperty('currentNote.mustPress') and getPropertyFromGroup('playerStrums', dir, 'members') or getPropertyFromGroup('opponentStrums', dir, 'members'))
                to.x = str.x
                to.y = str.y
                angle = 0
                if dir == 0 then angle = -90 end
                if dir == 1 then angle = 180 end
                if dir == 3 then angle = 90 end
                to.angle = angle + (add360 and 360 or -360)
                to.time = getProperty('currentNote.strumTime')
                e = true
            end
            diff = to.time - from.time
            addY = (-math.cos((songPos - from.time) / diff * math.pi * 2) + 1) * (downscroll and -200 or 200)

            setProperty('jumpingNote.x', lerp(from.x, to.x, (songPos - from.time) / diff))
            setProperty('jumpingNote.y', lerp(from.y, to.y, (songPos - from.time) / diff) + addY)
            setProperty('jumpingNote.angle', lerp(from.angle, to.angle, (songPos - from.time) / diff))
            setProperty('coloredJumpingNote.x', getProperty('jumpingNote.x'))
            setProperty('coloredJumpingNote.y', getProperty('jumpingNote.y'))
            setProperty('coloredJumpingNote.angle', getProperty('jumpingNote.angle'))
        end
        setProperty('coloredJumpingNote.alpha', lerp(getProperty('coloredJumpingNote.alpha'), 0, 0.125 * elapsed * 60))
    end
end

function lerp(a, b, t)
	return a + (b - a) * t
end