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
import openfl.Lib;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Controls', 'Adjust Delay', 'Graphics & Vsync', 'Visuals and UI', 'Gameplay', 'Accessibility'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	var oldPos = FlxG.mouse.getScreenPosition();

	public function new()
	{
		super();
		MusicBeatState.dumpcachetuff = false;
	}

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics & Vsync':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
			case 'Accessibility': 
				openSubState(new options.AccessibilitySubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		Lib.application.window.title = 'Freaky Night With Soni - Options';
		FlxG.mouse.visible = true;

		if(PlayState.instance != null && PlayState.instance.backOutfromOptions) FlxG.sound.playMusic(Paths.music('freakyMenu'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.ID = i;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.mouse.getScreenPosition().x != oldPos.x || FlxG.mouse.getScreenPosition().y != oldPos.y)
		{
			oldPos = FlxG.mouse.getScreenPosition();
			for(i in 0...options.length)
			{
				var pos = FlxG.mouse.getPositionInCameraView(FlxG.camera);
				if (pos.y > i / grpOptions.length * FlxG.height && pos.y < (i + 1) / grpOptions.length * FlxG.height && curSelected != i) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curSelected = i;
					changeSelection();
					break;
				}
			}
		}
		
		if (controls.UI_UP_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}
		if(FlxG.mouse.wheel != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-FlxG.mouse.wheel);
		}

		if (controls.BACK || FlxG.mouse.justPressedRight) {
			Lib.application.window.title = 'Freaky Night With Soni';
			if (PlayState.instance != null && PlayState.instance.backOutfromOptions)
			{
				FlxG.sound.music.volume = 0;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.mouse.visible = false;
				MusicBeatState.dumpcachetuff = true;
				MusicBeatState.switchState(new PlayState());
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.dumpcachetuff = true;
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT || FlxG.mouse.justPressed) {
			Lib.application.window.title = 'Freaky Night With Soni - Options - ${options[curSelected]}';
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
	}
}