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

class BaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:Option = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var boyfriend:Character = null;
	private var lyrics:FlxText = null;
	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;

	public static var instance:BaseOptionsMenu;

	public function new()
	{
		super();

		instance = this;

		if(title == null) title = 'Options';
		if(rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if desktop
		DiscordClient.changePresence(rpcTitle, null);
		#end
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		var titleText:Alphabet = new Alphabet(75, 40, title, true);
		titleText.scaleX = 0.6;
		titleText.scaleY = 0.6;
		titleText.alpha = 0.4;
		add(titleText);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(290, 260, optionsArray[i].name, optionsArray[i].section);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
			optionText.yMult = 90;*/
			optionText.targetY = i;
			if(optionsArray[i].section)
			{
				optionText.scaleX = 1.2;
				optionText.scaleY = 1.2;
				optionText.startPosition.x = optionText.x - 70;
			}
			optionText.ID = i;
			grpOptions.add(optionText);

			if(optionsArray[i].type == 'bool') {
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			} else {
				optionText.x -= 80;
				optionText.startPosition.x -= 80;
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 80);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}

			if(optionsArray[i].showBoyfriend && boyfriend == null)
			{
				reloadBoyfriend();
			}
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();
	}

	public function addOption(option:Option) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;
	var changed:Bool = false;
	var loaded:Bool = false;
	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}
		if(FlxG.mouse.wheel != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-FlxG.mouse.wheel);
		}

		if(optionsArray[curSelected].section)
		{
			changed = false;
			if(lastBack)
			{
				if(!changed)
				{
					changeSelection(-1);
					changed = true;
				}
			}
			else
			{
				if(!changed)
				{
					changeSelection(1);
					changed = true;
				}
			}
		}

		if (controls.BACK || FlxG.mouse.justPressedRight) {
			enableLyrics(false);
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Lib.application.window.title = 'Freaky Night With Soni - Options';
		}

		if(nextAccept <= 0)
		{
			var usesCheckbox = true;
			if(curOption.type != 'bool')
			{
				usesCheckbox = false;
			}

			if(usesCheckbox)
			{
				if((controls.ACCEPT || FlxG.mouse.justPressed) && !optionsArray[curSelected].locked)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			} else {
				if((controls.UI_LEFT || controls.UI_RIGHT) && !optionsArray[curSelected].locked) {
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if(holdTime > 0.5 || pressed) {
						if(pressed) {
							var add:Dynamic = null;
							if(curOption.type != 'string') {
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
							}

							switch(curOption.type)
							{
								case 'int' | 'float' | 'percent':
									holdValue = curOption.getValue() + add;
									if(holdValue < curOption.minValue) holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

									switch(curOption.type)
									{
										case 'int':
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case 'float' | 'percent':
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
									}

								case 'string':
									var num:Int = curOption.curOption; //lol
									if(controls.UI_LEFT_P) --num;
									else num++;

									if(num < 0) {
										num = curOption.options.length - 1;
									} else if(num >= curOption.options.length) {
										num = 0;
									}

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); //lol
									//trace(curOption.options[num]);
							}
							updateTextFrom(curOption);
							curOption.change();
							if(!curOption.name.contains('GameJolt')) FlxG.sound.play(Paths.sound('scrollMenu'));
						} else if(curOption.type != 'string') {
							holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
							if(holdValue < curOption.minValue) holdValue = curOption.minValue;
							else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

							switch(curOption.type)
							{
								case 'int':
									curOption.setValue(Math.round(holdValue));
								
								case 'float' | 'percent':
									curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if(curOption.type != 'string') {
						holdTime += elapsed;
					}
				} else if((controls.UI_LEFT_R || controls.UI_RIGHT_R) && !optionsArray[curSelected].locked) {
					clearHold();
				} else if((controls.ACCEPT || FlxG.mouse.justPressed || FlxG.keys.justPressed.ENTER) && !optionsArray[curSelected].locked)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					Reflect.setProperty(ClientPrefs, curOption.variable, curOption.options[curOption.curOption]);
					curOption.press();
					/*if(curOption.name == 'Window Color Mode:') 
					if(Reflect.getProperty(ClientPrefs, curOption.variable) == curOption.options[curOption.curOption]) 
					TitleState.restart();*/
				}
			}

			if(controls.RESET)
			{
				for (i in 0...optionsArray.length)
				{
					var leOption:Option = optionsArray[i];
					leOption.setValue(leOption.defaultValue);
					if(leOption.type != 'bool')
					{
						if(leOption.type == 'string')
						{
							leOption.curOption = leOption.options.indexOf(leOption.getValue());
						}
						updateTextFrom(leOption);
					}
					leOption.change();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if(!loaded)
		{
			loaded = true;
			if(optionsArray[curSelected].showLyrics)
			{
				if(!lyricsEnabled)
				{
					enableLyrics(true);
					loadLyricsPrefs();
				}
			}
			else
			{
				if(lyricsEnabled)
					enableLyrics(false);
			}
		}

		for(item in grpOptions.members)
		{
			if(optionsArray[item.ID].locked)
				item.alpha = .4;
			else
				item.alpha = item.targetY == 0 ? 1 : .6;

			for(i in 0...optionsArray.length)
			if(optionsArray[curSelected].section) item.alpha = .6;
		}
		for(text in grpTexts)
		{
			if(optionsArray[text.ID].locked)
				text.alpha = .4;
			else
				text.alpha = text.ID == curSelected ? 1 : .6;

			for(i in 0...optionsArray.length)
			if(optionsArray[curSelected].section) text.alpha = 0;
		}

		if(boyfriend != null && boyfriend.animation.curAnim.finished) {
			boyfriend.dance();
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:Option) {
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == 'percent') val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if(holdTime > 0.5) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		holdTime = 0;
	}
	
	var lastBack:Bool = false;
	function changeSelection(change:Int = 0)
	{
		if(change < 0)
			lastBack = true;
		else
			lastBack = false;

		loaded = false;

		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (item.targetY == 0) {
				item.alpha = optionsArray[item.ID].locked ? 0.4 : 1;
			} else {
				item.alpha = optionsArray[item.ID].locked ? 0.4 : 0.6;
			}
		}
		for (text in grpTexts) {
			if(text.ID == curSelected) {
				text.alpha = optionsArray[text.ID].locked ? 0.4 : 1;
			} else {
				text.alpha = optionsArray[text.ID].locked ? 0.4 : 0.6;
			}
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		if(boyfriend != null)
		{
			boyfriend.visible = optionsArray[curSelected].showBoyfriend;
		}
		
		curOption = optionsArray[curSelected]; //shorter lol
	}

	public function reloadBoyfriend()
	{
		var wasVisible:Bool = false;
		if(boyfriend != null) {
			wasVisible = boyfriend.visible;
			boyfriend.kill();
			remove(boyfriend);
			boyfriend.destroy();
		}

		boyfriend = new Character(840, 170, 'befe', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		insert(1, boyfriend);
		boyfriend.visible = wasVisible;
	}

	var lyricsEnabled:Bool = false;
	public function enableLyrics(enable:Bool = true)
	{
		if(enable)
		{
			lyrics = new FlxText(800, 70, Std.int(FlxG.width * 0.4), '', 30);
			lyrics.font = Paths.font('vcr.ttf');
			lyrics.size = 120;
			lyrics.alignment = CENTER;
			lyrics.borderStyle = OUTLINE;
			lyrics.borderColor = FlxColor.BLACK;
			lyrics.antialiasing = false;
			insert(1, lyrics);
			lyricsEnabled = true;
		}
		else
		{
			if(lyrics != null)
			{
				lyrics.kill();
				remove(lyrics);
				lyrics.destroy();
			}
			lyricsEnabled = false;
		}
	}

	public function loadLyricsPrefs()
	{
		for(i in 0...optionsArray.length)
		{
			switch(optionsArray[i].name)
			{
				case 'Language:' | 'Lyrics Color:' | 'Lyrics Transparency:':
					optionsArray[i].locked = ClientPrefs.disableLyrics;
			}
		}
		if(lyrics != null)
		{
			lyrics.alpha = ClientPrefs.lyricsAlpha;
			lyrics.visible = !ClientPrefs.disableLyrics;

			switch (ClientPrefs.lyricsColorr)
			{
				case 'White':
					lyrics.color = FlxColor.WHITE;
				case 'Gray':
					lyrics.color = FlxColor.GRAY;
				case 'Black':
					lyrics.color = FlxColor.BLACK;
				case 'Green':
					lyrics.color = FlxColor.GREEN;
				case 'Lime':
					lyrics.color = FlxColor.LIME;
				case 'Yellow':
					lyrics.color = FlxColor.YELLOW;
				case 'Orange':
					lyrics.color = FlxColor.ORANGE;
				case 'Red':
					lyrics.color = FlxColor.RED;
				case 'Purple':
					lyrics.color = FlxColor.PURPLE;
				case 'Blue':
					lyrics.color = FlxColor.BLUE;
				case 'Brown':
					lyrics.color = FlxColor.BROWN;
				case 'Pink':
					lyrics.color = FlxColor.PINK;
				case 'Magenta':
					lyrics.color = FlxColor.MAGENTA;
				case 'Cyan':
					lyrics.color = FlxColor.CYAN;
			}
			if(ClientPrefs.lyricsColorr == 'Black') lyrics.borderColor = FlxColor.WHITE;
			else lyrics.borderColor = FlxColor.BLACK;

			switch (ClientPrefs.lyricsLanguagee)
			{
				case 'English':
					lyrics.text = 'TEXT';
				case 'Hispano':
					lyrics.text = 'TEXTO';
				case 'Brasileiro':
					lyrics.text = 'TEXTO';
				case 'Chileno':
					lyrics.text = 'SHDOHASOIDASGUOASGHOFUGOHNY9U7EC7SYUJDUHGASUFNLUAYODBCGFOBCFHKDSGBFUICGIUGFISKLG734RGBVDFGSKASF Ayuda llevo programando mas de 1500 horas este mod ya no se como se ve el sol';
			}
		}
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}