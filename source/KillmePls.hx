package;

import Progression;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import Alphabet;
import Controls;
import openfl.Lib;
import openfl.sensors.Accelerometer;
import MusicBeatSubstate;
import flixel.math.FlxPoint;

using StringTools;

class KillmePls extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = true;
	var yesText:Alphabet;
	var noText:Alphabet;
	var text:Alphabet;
	var textCont:Alphabet;
	var selectedsomething:Bool = false;
	var canSelect:Bool = false;
	var canGoBack:Bool = false;

	public var finishedCallback:Void->Void;

	public var accepted:Void->Void;

	public var goback:Void->Void;

	public var startedSelect:Bool = false;
	public var startedBack:Bool = false;

	public static var fromTitle:Bool = false;

	var oldPos:FlxPoint;

	public function new(?finished:Void->Void, ?yes:Void->Void, ?back:Void->Void, largeText:String = 'You have a checkpoint', 
						smallText:String = 'Would you like to continue?', acceptText:String = 'Continue', declineText:String = 'Start Over')
	{
		super();

		FlxG.mouse.visible = true;

		startedSelect = controls.ACCEPT || FlxG.mouse.justPressed;
		startedBack = controls.BACK || FlxG.mouse.justPressedRight;

		canSelect = !startedSelect;
		canGoBack = !startedBack;

		oldPos = FlxG.mouse.getScreenPosition();

		if (finished != null)
			finishedCallback = finished;

		if (yes != null)
			accepted = yes;

		if (back != null)
			goback = back;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
        add(bg);

        text = new Alphabet(0, 280, largeText, true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		text.scrollFactor.set();
		add(text);

		textCont = new Alphabet(0, text.y+text.height+10, smallText, true);
		textCont.screenCenter(X);
		alphabetArray.push(textCont);
		textCont.alpha = 0;
		textCont.scrollFactor.set();
		add(textCont);

		yesText = new Alphabet(0, textCont.y + 150, acceptText, true);
		yesText.screenCenter(X);
		yesText.x -= 300;
		yesText.scrollFactor.set();
		add(yesText);

		noText = new Alphabet(0, textCont.y + 150, declineText, true);
		noText.screenCenter(X);
		noText.x += 250;
		noText.scrollFactor.set();
		add(noText);

		updateOptions();
	}

	override function update(elapsed:Float)
	{
		if (startedSelect && (!controls.ACCEPT && !FlxG.mouse.justPressed))
		{
			startedSelect = false;
			canSelect = true;
		}

		if (startedBack && (!controls.BACK && !FlxG.mouse.justPressedRight))
		{
			startedBack = false;
			canGoBack = true;
		}

		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6)
		{
			bg.alpha = 0.6;
		}

		for (i in 0...alphabetArray.length)
		{
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (!selectedsomething)
		{
			if((FlxG.mouse.getScreenPosition().x != oldPos.x || FlxG.mouse.getScreenPosition().y != oldPos.y) && canSelect)
			{
				oldPos = FlxG.mouse.getScreenPosition();
				var objs:Array<Dynamic> = [yesText, noText];
				for(obj in objs)
				{
					if(FlxG.mouse.overlaps(obj))
					{
						if((!onYes && obj == yesText) || (onYes && obj == noText))
						{
							FlxG.sound.play(Paths.sound('scrollMenu'), 1);
							if(obj == yesText) onYes = true;
							else onYes = false;
							updateOptions();
							break;
						}
					}
				}
			}
			if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && canSelect)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}
			if(FlxG.mouse.wheel != 0 && canSelect)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				onYes = !onYes;
				updateOptions();
			}
			if ((controls.BACK || FlxG.mouse.justPressedRight) && canGoBack)
			{
				selectedsomething = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'), 1);
				fadeOut(goback != null ? goback : function()
				{
				});
			}
			else if ((controls.ACCEPT || FlxG.mouse.justPressed) && canSelect)
			{
				selectedsomething = true;
				FlxG.mouse.visible = false;
				if (onYes)
				{
					fadeOut(accepted);
				}
				else
				{
					fadeOut();
				}
			}
		}
		super.update(elapsed);
	}

	function fadeOut(?callback:Void->Void)
	{
		if (callback == null)
		{
			callback = function()
			{
				if (finishedCallback != null)
				{
					finishedCallback();
				}
			};
		}

		var objs:Array<Dynamic> = [text, textCont, yesText, noText, bg];
		for (obj in objs)
		{
			FlxTween.tween(obj, {alpha: 0}, 0.5, {
				onComplete: function(twn:FlxTween)
				{
				}
			});
		}

		(new FlxTimer()).start(0.5, function(tmr:FlxTimer)
		{
			close();
			callback();
		});
	}

	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}
}