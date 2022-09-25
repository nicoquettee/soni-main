package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics & Vsync';
		rpcTitle = 'Graphics & Vsync Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('GRAPHICS',
			'',
			'',
			'string',
			'',
			['']);
		option.section = true;
		addOption(option);

		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Shaders',
			'If checked, shaders will be turned on.', 
			'funnyShaders', 
			'bool',
			true); 
		addOption(option);

		var option:Option = new Option('VSYNC',
			'',
			'',
			'string',
			'',
			['']);
		option.section = true;
		addOption(option);
		
		#if !html5
        var option:Option = new Option('Window Resolution:',
			'Change the window resolution.\nPress "ENTER" to apply.',
			'resolutionn',
			'string',
			'1920x1080',
			['640x360', '768x432', '896x504', '1024x576', '1152x648', '1280x720', '1920x1080', '2560x1440', '3840x2160']);
		option.onPress = changeResolution;
		addOption(option);
		#end

		/*#if (cpp && !html5)
		var option:Option = new Option('Window Color Mode:',
			'Change the window bar color.\nPress "ENTER" to apply.',
			'wcolormode',
			'string',
			'Dark',
			['Dark', 'Light']);
		option.onPress = changeWindowColorMode;
		addOption(option);
		#end*/

		var option:Option = new Option('Gamma:',
			'Change the gamma of the game.',
			'gammaa',
			'float',
			1);
		option.onChange = ColorblindFilters.applyFiltersOnGame;
		option.scrollSpeed = 1;
		option.minValue = .1;
		option.maxValue = 5;
		option.changeValue = .1;
		addOption(option);

		var option:Option = new Option('Brightness:',
			'Change the brightness of the game.',
			'brightnesss',
			'float',
			0);
		option.onChange = ColorblindFilters.applyFiltersOnGame;
		option.scrollSpeed = 0;
		option.minValue = -200;
		option.maxValue = 200;
		option.changeValue = 10;
		addOption(option);

		var option:Option = new Option('Disable Auto Pause',
			'If checked, the game will stop when minimizing the window.',
			'autoPause',
			'bool',
			true);
		option.onChange = reloadAutopause;
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate:',
			"Pretty self explanatory, isn't it?",
			'framerate',
			'int',
			60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
	
	#if !html5
    function changeResolution() {
        switch(ClientPrefs.resolutionn)
        {
            case '640x360':
                FlxG.resizeWindow(640,360);
                FlxG.resizeGame(640,360);
            case '768x432':
                FlxG.resizeWindow(768,432);
                FlxG.resizeGame(768,432);
            case '896x504':
                FlxG.resizeWindow(896,504);
                FlxG.resizeGame(896,504);
            case '1024x576':
                FlxG.resizeWindow(1024,576);
                FlxG.resizeGame(1024,576);
            case '1152x648':
                FlxG.resizeWindow(1152,648);
                FlxG.resizeGame(1152,648);
            case '1280x720':
                FlxG.resizeWindow(1280,720);
                FlxG.resizeGame(1280,720);
            case '1920x1080':
                FlxG.resizeWindow(1920,1080);
                FlxG.resizeGame(1920,1080);
            case '2560x1440':
                FlxG.resizeWindow(2560,1440);
                FlxG.resizeGame(2560,1440);
            case '3840x2160':
                FlxG.resizeWindow(3840,2160);
				FlxG.resizeGame(3840,2160);
		}
	}
	#end

	function reloadAutopause() {
		FlxG.autoPause = ClientPrefs.autoPause;
	}

	/*#if (cpp && !html5)
	function changeWindowColorMode()
	{
		switch(ClientPrefs.wcolormode)
		{
			case 'Dark':
				CppUse.darkMode();
			case 'Light':
				CppUse.lightMode();
		}
	}
	#end*/
}