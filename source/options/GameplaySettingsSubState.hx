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

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence
		
		var option:Option = new Option('Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Notes Scale:', 'Changes how big the HUD receptors and notes are.\nDefault is 1',
		'noteScale', 'float', 1.0);
		option.displayFormat = 'x%v';
		option.scrollSpeed = 20;
		option.changeValue = 0.1;
		option.minValue = 0.8;
		option.maxValue = 1.2;
		addOption(option); //sexo

		var option:Option = new Option('Notes Transparency:', 'Changes how transparent the HUD receptors and notes are.\nDefault is 75%',
		'noteTransparencySoniNose', 'percent', 0.75);
		option.scrollSpeed = 1.6;
		option.changeValue = 0.05;
		option.minValue = 0.35;
		option.maxValue = 1;
		addOption(option); //sexo

		var option:Option = new Option('Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable Mechanics',
			'If unchecked, mechanics and modcharts will be turned off.',
			'mechanics',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Botplay',
			'If checked, botplay will be turned on.',
			'',
			'bool',
			false);
		option.onChange = reloadBotplay;
		addOption(option);

		var option:Option = new Option('Practice Mode',
			'If checked, practice mode will be turned on.',
			'',
			'bool',
			false);
		option.onChange = reloadPractice;
		addOption(option);

		var option:Option = new Option('Slow Down Pause',
			'If checked, when you resume the game after pause it the song will be relentized 1 second.',
			'slowdownPause',
			'bool',
			true);
		option.onChange = reloadAutopause;
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

		/*var option:Option = new Option('Note Delay',
			'Changes how late a note is spawned.\nUseful for preventing audio lag from wireless earphones.',
			'noteOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 100;
		option.minValue = 0;
		option.maxValue = 500;
		addOption(option);*/

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function reloadAutopause() {
		FlxG.autoPause = ClientPrefs.autoPause;
	}

	var bot:Bool = ClientPrefs.gameplaySettings.get('botplay');
	public function reloadBotplay()
	{
		bot = !bot;
		ClientPrefs.gameplaySettings.set('botplay', bot);
	}

	var pra:Bool = ClientPrefs.gameplaySettings.get('practice');
	public function reloadPractice()
	{
		pra = !pra;
		ClientPrefs.gameplaySettings.set('practice', pra);
	}
}