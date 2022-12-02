package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import openfl.Lib;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import openfl.media.Sound;

class Jukebox extends MusicBeatState
{
    var songs:Array<String> = 
    [
        '',
        'chile',
        'skeleboom',
        'custom'
    ];
    var authors:Array<String> = 
    [
        'DonAlgo',
        'Sic',
        'Yiter',
        'Idk'
    ];
    var curSelected:Int = 0;

    var bg:FlxBackdrop;
    var grpMusic:FlxTypedGroup<Alphabet>;
    var selectedSomethin:Bool = false;

    override function create()
    {
        Lib.application.window.title = "Freaky Night With Soni - Jukebox";

        bg = new FlxBackdrop(Paths.image('credits/menuDesatCredits'), .2, .2, true, false);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.screenCenter();
        bg.x -= 35;
		add(bg);

        genMusic();
		changeSelection();

        super.create();

        for(i in 0...songs.length)
        {
            var prefix:String = songs[i] == '' ? 'freakyMenu' : 'freakyMenu_';
            if(songs[i] != 'custom') Paths.music('$prefix${songs[i]}');
        }
    }

    var holdTime:Float = 0;
    override function update(elapsed:Float)
    {
        if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
        bg.x += .5*(elapsed/(1/120));

        if (!selectedSomethin)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var accepted = controls.ACCEPT;

            if (songs.length > 1)
			{
				if (upP)
				{
					changeSelection(-1);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold));
					}
				}
			}

            if (controls.BACK)
			{
				persistentUpdate = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				Lib.application.window.title = "Freaky Night With Soni";
			}

			if (accepted)
			{
				Main.menuMusic = ClientPrefs.menuMusic;
			}
        }
        super.update(elapsed);
    }

    var musicTween:FlxTween;
    function changeSelection(change:Int = 0, playSound:Bool = true)
    {
        if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if(songs[curSelected] != 'custom')
		{
			var prefix:String = songs[curSelected] == '' ? 'freakyMenu' : 'freakyMenu_';
			if(musicTween != null) musicTween.cancel();
			musicTween = FlxTween.tween(FlxG.sound, {volume: 0}, .7, {onComplete: (twn)->
				{
					FlxG.sound.music.stop();
					FlxG.sound.playMusic('$prefix${songs[curSelected]}', .8, true);
					musicTween = FlxTween.tween(FlxG.sound, {volume: .7}, 1);
				}
			});
		}

		var bullShit:Int = 0;
        for (item in grpMusic.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.startPosition.x = 0;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.startPosition.x = 70;
			}
		}
    }

    function genMusic()
    {
        for (i in 0...songs.length)
		{
			if (grpMusic.members[i] != null)
				return;

			var musicText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true);
			musicText.isMenuItem = true;
			musicText.targetY = i;
			grpMusic.add(musicText);

			if (musicText.width > 980)
			{
				var textScale:Float = 980 / musicText.width;
				musicText.scale.x = textScale;
				for (letter in musicText.letters)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}
		}
    }
}