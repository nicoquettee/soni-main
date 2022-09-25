package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
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
import GameJolt.GameJoltLogin;
import GameJolt.GameJoltAPI;
import GameJolt;
import Controls;

using StringTools;

class AccessibilitySubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Accessibility';
		rpcTitle = 'Accessibility Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Genetic Conditions',
			'',
			'',
			'string',
			'',
			['']);
		option.section = true;
		addOption(option);

		var option:Option = new Option('Colorblind Filter:',
			'If you are a colorblind person take care to enable this.',
			'colorblindMode',
			'string',
			'None', 
			[
			 'None', 
			 'Deuteranopia', 'Deuteranomaly', 
			 'Protanopia', 'Protanomaly', 
			 'Tritanopia', 'Tritanomaly', 
			 'Achromatopsia', 'Achromatomaly'
			]
		);
		option.onChange = ColorblindFilters.applyFiltersOnGame;
		addOption(option);

		var option:Option = new Option('Photosensitivity',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Screen Shake',
			"Uncheck this if you are sensitive to screen shake!",
			'shake',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Lyrics',
			'',
			'',
			'string',
			'',
			['']);
		option.section = true;
		addOption(option);

		var option:Option = new Option('Disable Lyrics',
			"If unchecked, lyrics will be turned on.",
			'disableLyrics',
			'bool',
			false);
		option.showLyrics = true;
		option.onChange = loadLyricsPrefs;
		addOption(option);
		
		var http = new haxe.Http("https://ipinfo.io/json");
        http.onData = function (data:String) {
        	var result = haxe.Json.parse(data);
        	var option:Option = new Option('Language:',
			"What language you speak?",
			'lyricsLanguagee',
			'string',
			if(result.country=='ES'||result.country=='PE'||result.country=='ARG'||result.country=='VE'||result.country=='EC')'Hispano'else if(result.country=='US'||result.country=='GB'||result.country=='UK')'English'else if(result.country=='CC'||result.country=='CL')'Chileno'else if(result.country=='PT'||result.country=='BRA'||result.country=='BR')'Brasileiro'else'English',
			['English', 'Hispano', 'Brasileiro', 'Chileno']);
			option.showLyrics = true;
			option.onChange = loadLyricsPrefs;
        	addOption(option);
		}
		http.request();
		
        var option:Option = new Option('Lyrics Color:',
			"Which color do you prefer?",
			'lyricsColorr',
			'string',
			'White',
            ['White', 'Gray', 'Black', 'Green', 'Lime', 'Yellow', 'Orange', 'Red', 
			'Purple', 'Blue', 'Brown', 'Pink', 'Magenta', 'Cyan']);
		option.showLyrics = true;
		option.onChange = loadLyricsPrefs;
        addOption(option);

		var option:Option = new Option('Lyrics Transparency:',
			'How much transparent should the lyrics be.',
			'lyricsAlpha',
			'percent',
			1);
		option.showLyrics = true;
		option.onChange = loadLyricsPrefs;
		option.scrollSpeed = 1.6;
		option.minValue = 0.05;
		option.maxValue = 1;
		option.changeValue = 0.05;
		addOption(option);

		var option:Option = new Option('GameJolt',
			'',
			'',
			'string',
			'',
			['']);
		option.section = true;
		addOption(option);

		var option:Option = new Option('Log In To GameJolt',
			"Log in to gamejolt for achievements in your gamejolt account.",
			'',
			'string',
			'',
			['']);
		option.onPress = gameJoltLogIn;
		addOption(option);

		var option:Option = new Option('Log Out Of GameJolt',
			"Log out of your GameJolt account.",
			'',
			'string',
			'',
			['']);
		option.onPress = gameJoltLogOut;
		option.locked = !GameJoltAPI.getStatus();
		addOption(option);

		super();
	}

	function gameJoltLogIn()
	{
		GameJoltLogin.fromOptions = true;
		MusicBeatState.switchState(new GameJoltLogin());
	}

	function gameJoltLogOut()
	{
		GameJoltAPI.deAuthDaUser();
		TitleState.restart();
	}
}