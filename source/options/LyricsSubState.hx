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
import Controls;

using StringTools;

class LyricsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Lyrics';
		rpcTitle = 'Lyrics Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Disable Lyrics',
			"If unchecked, lyrics will turn off.",
			'disableLyrics',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Language:',
			"What language you speak?",
			'lyricsLanguage',
			'string',
			'English',
			['English', 'Hispano', 'Brasileiro', 'Chileno']);
        addOption(option);
		
        var option:Option = new Option('Lyrics Color:',
			"Which color do you prefer?",
			'lyricsColor',
			'string',
			'White',
            ['White', 'Gray', 'Black', 'Green', 'Lime', 'Yellow', 'Orange', 'Red', 
            'Purple', 'Blue', 'Brown', 'Pink', 'Magenta', 'Cyan']);
        addOption(option);

		var option:Option = new Option('Lyrics Transparency',
			'How much transparent should the lyrics be.',
			'lyricsAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.1;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		super();
	}
}