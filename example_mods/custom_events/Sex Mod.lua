function onCreate()
    makeLuaSprite('sexo', 'funny', 0,0)
    setProperty('sexo.alpha', 0)
    setObjectCamera('sexo', 'camHud')
    addLuaSprite('sexo',true)
end

function onEvent(name,value1,value2)

    if name == "Sex Mod" then
        doTweenAlpha('SexoAlpha', 'sexo', 0.3, 27.43, 'quadInOut')
    end
end

function onTweenCompleted(name)
    if name == 'SexoAlpha' then
        doTweenAlpha('SexoAlpha1', 'sexo', 0, 1.34, 'quadInOut')
    end
end