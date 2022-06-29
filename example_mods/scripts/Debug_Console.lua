---- CONFIG
-- You can edit aspects about the script below

local prtSt = false -- Automatically put code inside of print statement. You cannot change this ingame due to complications with loadstring
local showHelp = true -- Automatically show help. You cannot change this ingame due to complications with loadstring



-- The actual script.


-- Variables

local curText = ""
local shownText = ""
local lastText = ""
local caretPos = 0
local isShown = false
local canuse = false

local timee = 0
local lastOppacity = 1

-- I was too lazy to copy all of this with different names
function setupText(name,text,x,y)
	makeLuaText(name, text, 1000, x, y);
	setTextSize(name, 32);
	setProperty(name ..'.borderColor', getColorFromHex('000000'));
	setProperty(name ..'.borderSize', 2);
	setObjectCamera(name, 'camOther'); -- camHUD and camGame get their opacity changed, using those would defeat the purpose of changing the opacity
	addLuaText(name,true);
end

function showConsole(bool)
	setPropertyFromClass('flixel.FlxG', 'sound.music.volume',1)

	-- Hide/show shit
	setProperty('debugText.visible',bool)
	setProperty('outputText.visible',bool)
	setProperty('helpText.visible',bool and showHelp)

	-- Toggle input
	setProperty('inCutscene',bool)
	setProperty('boyfriend.stunned',bool)

	-- Really should use a black box with 0.4 opacity instead of changing camera opacity but blame psych
	setProperty("camGame.alpha",(bool and 0.7 or 1))
	setProperty("camHUD.alpha",(bool and 0.7 or 1))
	setProperty("camStrums.alpha",(bool and 0.7 or 1))
	
	-- Stores the time
	timee = getPropertyFromClass('flixel.FlxG', 'sound.music.time')
	setPropertyFromClass('flixel.FlxG', 'sound.music.volume',1)
	setProperty('vocals.volume',1)
end

function onSongStart()
	-- Can not get this to work
	-- makeLuaSprite('dbgbg', nil, 0, 60)
	-- makeGraphic('dbgbg', 1300, 1000, "white")
	-- setProperty('dbgbg.alpha',0.5)
	-- setObjectCamera('dbgbg', 'camOther')
	-- addLuaSprite('dbgbg', true);
	-- screenCenter('dbgbg')

	-- The actual line of text
	setupText('debugText', ">_", 10,60)
	setProperty('debugText.width',400)
	addLuaText('debugText', true);

	-- Output text
	setupText('outputText', "No output to show", 10,getProperty('debugText.y') + 20 + (getProperty('debugText.height')))
	setProperty('outputText.width',400)

	-- Help text
	setupText('helpText', [[Press tab to run code
Press UP to get last ran code
Press '~' to exit]], 10,getProperty('outputText.y') + 40 + (getProperty('debugText.height')))
	setProperty('helpText.color',getColorFromHex('00ee00'))
	setProperty('outputText.width',400)


	showConsole(false)
	
	setupText('dbgConsoleExists', "You can use '~' to access the Debug Console", -1000,10, 0)
	addLuaText('dbgConsoleExists', true);
	doTweenX("dbgcex",'dbgConsoleExists',10,1.2,"bounceOut")
	runTimer("dbgce", 3, 1);
	canuse = true
end
function onTweenCompleted(tag, loops, loopsLeft)
	if tag == "dbgcexx" then
		removeLuaText('dbgConsoleExists')
	end
end
sprites = {}
function onTimerCompleted(tag, loops, loopsLeft)
	if tag == "dbgce" then
		doTweenX("dbgcexx",'dbgConsoleExists',-1000,1,"cubeOut")
	end
end



keyList = { -- I hate my life
	A = "a",
	B = "b",
	C = "c",
	D = "d",
	E = "e",
	F = "f",
	G = "g",
	H = "h",
	I = "i",
	J = "j",
	K = "k",
	L = "l",
	M = "m",
	N = "n",
	O = "o",
	P = "p",
	Q = "q",
	R = "r",
	S = "s",
	T = "t",
	U = "u",
	V = "v",
	W = "w",
	X = "x",
	Y = "y",
	Z = "z",
	SPACE = " ",
	ZERO = "0",
	ONE = "1",
	TWO = "2",
	THREE = "3",
	FOUR = "4",
	FIVE = "5",
	SIX = "6",
	SEVEN = "7",
	EIGHT = "8",
	NINE = "9",
	NUMPADZERO= "0",
	NUMPADONE= "1",
	NUMPADTWO= "2",
	NUMPADTHREE= "3",
	NUMPADFOUR= "4",
	NUMPADFIVE= "5",
	NUMPADSIX= "6",
	NUMPADSEVEN= "7",
	NUMPADEIGHT= "8",
	NUMPADNINE= "9",
	NUMPADMINUS = "-",
	NUMPADPLUS = "+",
	NUMPADPERIOD = ".",
	NUMPADMULTIPLY = "*",
	LBRACKET = "[",
	RBRACKET = "]",
	BACKSLASH = "\\",
	SEMICOLON = ";",
	QUOTE = "'",
	COMMA = ",",
	PERIOD = ".",
	SLASH = "/",
	MINUS = "-",
	PLUS = "=",

}
keyListUpper = { -- I hate my life*@ (get it, because it's shif- I'll see myself out)
	ZERO = ")",
	ONE = "!",
	TWO = "@",
	THREE = "#",
	FOUR = "$",
	FIVE = "%",
	SIX = "^",
	SEVEN = "&",
	EIGHT = "*",
	NINE = "(",
	LBRACKET = "{",
	RBRACKET = "}",
	BACKSLASH = "|",
	SEMICOLON = ":",
	QUOTE = "\"",
	COMMA = "<",
	PERIOD = ">",
	SLASH = "?",
	-- GRAVEACCENT = "~",
	MINUS = "_",
	PLUS = "+",

}
-- Show text on the screen
function print(...)
	local e = {...}
	for i,v in pairs(e) do
		e[i] = v == nil and "nil" or tostring(v)
	end
	local inp = table.concat(e," ")
	showText(output,inp)
end
-- Does what it says on the tin
function handleCommand()
	fn, syntaxError = loadstring((prtSt and "print(" or "") .. curText .. (prtSt and ")" or ""), 'Eval', 't', _G)
	lastText = curText;
	curText = ""
	if(syntaxError) then showText("err",syntaxError) return end
	succ,err = pcall(function() fn() end)
	if(not succ) then showText("err",err);return end
end
-- Show text on the screen
function showText(name,text)
	setProperty("outputText.text",text)
end

function onUpdate()
	onUp()
end

function onUp()

	if(isShown) then
		setPropertyFromClass('Conductor', 'songPosition',timee)
		setPropertyFromClass('flixel.FlxG', 'sound.music.time',timee)
		setProperty('vocals.time',timee)
		setPropertyFromClass('flixel.FlxG', 'sound.music.volume',0)
		setProperty('vocals.volume',0)
		local updateText = false 
		-- Input
		if getPropertyFromClass("flixel.FlxG","keys.pressed.ANY") then
			-- Left/Right movement
			if(getPropertyFromClass("flixel.FlxG","keys.justPressed.LEFT")) then
				caretPos = caretPos - 1;
				updateText = true
			elseif(getPropertyFromClass("flixel.FlxG","keys.justPressed.RIGHT")) then
				caretPos = caretPos + 1;
				updateText = true

			-- Get last text
			elseif(getPropertyFromClass("flixel.FlxG","keys.justPressed.UP")) then
				local t = lastText;
				lastText = curText;
				curText=t
				updateText = true
			end
			if(caretPos > #curText) then caretPos = #curText end
			if(caretPos < 1) then caretPos = 1 end
			-- Handle key presses. Absolutely disgusting but I don't know of any other way of doing it
			local shift = getPropertyFromClass("flixel.FlxG","keys.pressed.SHIFT")
			for i,v in pairs(keyList) do

				if(getPropertyFromClass("flixel.FlxG","keys.justPressed." .. i)) then
					if(shift) then v = keyListUpper[i] or string.upper(v) end
					if(caretPos == #curText) then
						curText = curText .. v
					else
						curText = string.sub(curText,0,caretPos) .. v .. string.sub(curText,caretPos + 1)  
					end
					caretPos = caretPos + 1
					updateText = true
				end
			end
			-- Removes a character
			if(getPropertyFromClass("flixel.FlxG","keys.justPressed.BACKSPACE")) then
				if(caretPos == #curText) then
					curText = string.sub(curText,0,caretPos - 1)
				else
					curText = string.sub(curText,0,caretPos - 1) .. string.sub(curText,caretPos + 1)  
				end
				updateText = true
				caretPos = caretPos - 1
			end
			-- Run the text
			if(getPropertyFromClass("flixel.FlxG","keys.justPressed.TAB")) then
				handleCommand()
				updateText = true
			end
			-- Update the text
			if(updateText) then
				shownText = string.sub(curText,0,caretPos) .. "_" .. string.sub(curText,caretPos + 1)  
			end
			setProperty('debugText.text',">" .. shownText)
		end
		
	end
	if(canuse and getPropertyFromClass("flixel.FlxG","keys.justPressed.GRAVEACCENT")) then
		isShown = not isShown 
		showConsole(isShown)
	end
end





-- Credits:

-- Superpowers04#3887: Made the script
