function onUpdatePost(elapsed)
    for a = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', a, 'noteType') == 'speedNote' then
            setPropertyFromGroup('notes', a, 'y', getPropertyFromGroup('notes', a, 'y') * 2.5);
        end
    end
end