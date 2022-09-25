package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import PlayerSettings;
import lime.app.Application;
import openfl.Lib;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.NumTween;
import MusicBeatState;
import StoryMenuState;
import TitleState;
import CoolUtil;
import Discord.DiscordClient;
import GameJolt.GameJoltAPI;
import GameJolt;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class Init extends FlxState
{
	public override function new()
	{
		super();
	}

	public override function create()
	{
		super.create();

		#if cpp
		CppUse.darkMode();
		#end

		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
        #end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		FlxG.sound.fullscreenKeys = TitleState.fullscreenKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.reset();

		PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		if(FlxG.save.data != null)
		{
			if(FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
			#if !html5
			@:privateAccess
			{
				switch(FlxG.save.data.resolutionn)
				{
					case '640x360':
						FlxG.resizeWindow(640,360);
						FlxG.resizeGame(640,360);
						Lib.application.window.set_maximized(false);
						Lib.application.window.set_minimized(true);
					case '768x432':
						FlxG.resizeWindow(768,432);
						FlxG.resizeGame(768,432);
						Lib.application.window.set_maximized(false);
						Lib.application.window.set_minimized(true);
					case '896x504':
						FlxG.resizeWindow(896,504);
						FlxG.resizeGame(896,504);
						Lib.application.window.set_maximized(false);
						Lib.application.window.set_minimized(true);
					case '1024x576':
						FlxG.resizeWindow(1024,576);
						FlxG.resizeGame(1024,576);
						Lib.application.window.set_maximized(false);
						Lib.application.window.set_minimized(true);
					case '1152x648':
						FlxG.resizeWindow(1152,648);
						FlxG.resizeGame(1152,648);
						Lib.application.window.set_maximized(false);
						Lib.application.window.set_minimized(true);
					case '1280x720':
						FlxG.resizeWindow(1280,720);
						FlxG.resizeGame(1280,720);
						Lib.application.window.set_maximized(false);
						Lib.application.window.set_minimized(true);
					case '1920x1080':
						FlxG.resizeWindow(1920,1080);
						FlxG.resizeGame(1920,1080);
						Lib.application.window.set_minimized(false);
						Lib.application.window.set_maximized(true);
					case '2560x1440':
						FlxG.resizeWindow(2560,1440);
						FlxG.resizeGame(2560,1440);
						Lib.application.window.set_minimized(false);
						Lib.application.window.set_maximized(true);
					case '3840x2160':
						FlxG.resizeWindow(3840,2160);
						FlxG.resizeGame(3840,2160);
						Lib.application.window.set_minimized(false);
						Lib.application.window.set_maximized(true);
				}
			}
			#end
		}

        ClientPrefs.loadPrefs();

		ColorblindFilters.applyFiltersOnGame();
		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		if (FlxG.save.data.achievementsSoni == null)
			GJAchievements.defaultAchievements(); 

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = ClientPrefs.mouseSkinn == 'System' ? true : false;

		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		FlxG.worldBounds.set(0, 0);

		#if desktop
		DiscordClient.initialize();
		DiscordClient.changePresence("Loading The Game", null);
		#end

		Application.current.onExit.add(function(exitCode)
		{
			FlxG.save.flush();
			#if deskpot
			DiscordClient.shutdown();
			#end
			#if cpp
			CppUse._setWindowLayered();

			var numTween:NumTween = FlxTween.num(1, 0, 1, {
				onComplete: function(twn:FlxTween)
				{
					Sys.exit(0);
				}
			});

			numTween.onUpdate = function(twn:FlxTween)
			{
				#if windows
				CppUse.setWindowOppacity(numTween.value);
				#end
			}
			#else
			FlxTween.tween(FlxG.camera, {alpha: 0}, 1, {
				onComplete: function(twn:FlxTween)
				{
					Sys.exit(0);
				}
			});
			#end
			FlxTween.tween(FlxG.sound, {volume: 0}, 1);
		});

		Lib.application.window.focus();

        ClientPrefs.loadDefaultKeys();
        
		FlxG.autoPause = ClientPrefs.autoPause;
		Main.canToggleFullScreen = true;
        ColorblindFilters.applyFiltersOnGame();

        Progression.load();
        
        Paths.excludeAsset('assets/preload/images/aesthetic.png');
		CoolUtil.precacheImage('aesthetic', 'preload');

		Paths.excludeAsset('assets/shared/images/go.png');
		CoolUtil.precacheImage('go', 'shared');
		Paths.excludeAsset('assets/shared/images/ready.png');
		CoolUtil.precacheImage('ready', 'shared');
		Paths.excludeAsset('assets/shared/images/set.png');
        CoolUtil.precacheImage('set', 'shared');
        
        Paths.excludeAsset('assets/shared/images/go_drawe.png');
		CoolUtil.precacheImage('go_drawe', 'shared');
		Paths.excludeAsset('assets/shared/images/ready_drawe.png');
		CoolUtil.precacheImage('ready_drawe', 'shared');
		Paths.excludeAsset('assets/shared/images/set_drawe.png');
		CoolUtil.precacheImage('set_drawe', 'shared');

		Paths.excludeAsset('assets/shared/images/bad.png');
		CoolUtil.precacheImage('bad', 'shared');
		Paths.excludeAsset('assets/shared/images/combo.png');
		CoolUtil.precacheImage('combo', 'shared');
		Paths.excludeAsset('assets/shared/images/good.png');
		CoolUtil.precacheImage('good', 'shared');
		Paths.excludeAsset('assets/shared/images/shit.png');
		CoolUtil.precacheImage('shit', 'shared');
		Paths.excludeAsset('assets/shared/images/sick.png');
		CoolUtil.precacheImage('sick', 'shared');
		for(i in 0...10)
		{
			Paths.excludeAsset('assets/preload/images/num$i.png');
			CoolUtil.precacheImage('num$i', 'preload');
		}

		Paths.excludeAsset('assets/shared/images/noteSplashes.png');
		CoolUtil.precacheImage('noteSplashes', 'shared');

		Paths.excludeAsset('assets/shared/images/NOTE_assets.png');
        CoolUtil.precacheImage('NOTE_assets', 'shared');
        
        Paths.excludeAsset('assets/shared/images/Note_kombo_soni.png');
        CoolUtil.precacheImage('Note_kombo_soni', 'shared');
        Paths.excludeAsset('assets/shared/images/numbers.png');
        CoolUtil.precacheImage('numbers', 'shared');
        
        Paths.excludeAsset('assets/preload/images/Letre.png');
		CoolUtil.precacheImage('Letre', 'preload');

		FlxG.switchState(Type.createInstance(SpecsDetector, []));
	}
}