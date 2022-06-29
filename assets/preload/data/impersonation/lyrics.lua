function onUpdate(elapsed)
    if curStep == 114 then
        if getProperty('language') == 'English' then
            setProperty('lyricsTxt.text', 'FUCK YOU BITCH!')
        elseif getProperty('language') == 'Hispano' then
            setProperty('lyricsTxt.text', 'COÑO DE TU MADRE!')
        elseif getProperty('language') == 'Brasileiro' then
            setProperty('lyricsTxt.text', 'SUA MALDITA MÃE!')
        elseif getProperty('language') == 'Chileno' then
            setProperty('lyricsTxt.text', 'COÑO E TU MAE!')
        end
    elseif curStep == 1075 then
        if getProperty('language') == 'English' then
            setProperty('lyricsTxt.text', "You're so slow!")
        elseif getProperty('language') == 'Hispano' then
            setProperty('lyricsTxt.text', 'Eres muy lento!')
        elseif getProperty('language') == 'Brasileiro' then
            setProperty('lyricsTxt.text', 'Você é muito lento!')
        elseif getProperty('language') == 'Chileno' then
            setProperty('lyricsTxt.text', 'Eres muy lento!')
        end
    end

    if curStep == 128 or curStep == 1088 then
        setProperty('lyricsTxt.text', '')
    end
end