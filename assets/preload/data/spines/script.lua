function onUpdate(elapsed)
    if curBeat == 252 then
        noteTweenX('notexchange0', 0, defaultPlayerStrumX0, 0.29, 'quadOut')
        noteTweenX('notexchange1', 1, defaultPlayerStrumX1, 0.29, 'quadOut')
        noteTweenX('notexchange2', 2, defaultPlayerStrumX2, 0.29, 'quadOut')
        noteTweenX('notexchange3', 3, defaultPlayerStrumX3, 0.29, 'quadOut')

        noteTweenX('notexchange4', 4, defaultOpponentStrumX0, 0.29, 'quadOut')
        noteTweenX('notexchange5', 5, defaultOpponentStrumX1, 0.29, 'quadOut')
        noteTweenX('notexchange6', 6, defaultOpponentStrumX2, 0.29, 'quadOut')
        noteTweenX('notexchange7', 7, defaultOpponentStrumX3, 0.29, 'quadOut')

        for i = 0,7 do noteTweenAngle('noteanglechange'..i, i, 360, 0.29, 'quadOut') end
    end

    if curBeat == 487 then
        noteTweenX('notexchange0', 0, defaultOpponentStrumX0, 0.29, 'quadOut')
        noteTweenX('notexchange1', 1, defaultOpponentStrumX1, 0.29, 'quadOut')
        noteTweenX('notexchange2', 2, defaultOpponentStrumX2, 0.29, 'quadOut')
        noteTweenX('notexchange3', 3, defaultOpponentStrumX3, 0.29, 'quadOut')

        noteTweenX('notexchange4', 4, defaultPlayerStrumX0, 0.29, 'quadOut')
        noteTweenX('notexchange5', 5, defaultPlayerStrumX1, 0.29, 'quadOut')
        noteTweenX('notexchange6', 6, defaultPlayerStrumX2, 0.29, 'quadOut')
        noteTweenX('notexchange7', 7, defaultPlayerStrumX3, 0.29, 'quadOut')

        for i = 0,7 do noteTweenAngle('noteanglechange'..i, i, 0, 0.29, 'quadOut') end
    end
end 
--lazy code lol