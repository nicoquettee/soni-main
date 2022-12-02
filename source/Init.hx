package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import lime.app.Application;
import openfl.Lib;
import GameJolt.GameJoltAPI;
import GameJolt;
import sys.thread.Thread;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

//using flixel.util.FlxSpriteUtil;
using StringTools;

#if deskpot
import Discord.DiscordClient;
#end

class Init extends MusicBeatState
{
	var done:Bool = false;
	var loadS:CacheScreen;

	public function new()
	{
		super();
	}

	override function create()
	{
		super.create();

		loadS = new CacheScreen();
		add(loadS);

		build();
	}

	function build()
	{
		#if cpp
		CppUse.darkMode();
		#end

		FlxG.save.bind('funkin', 'ninjamuffin99');

		#if desktop
		Discord.DiscordClient.initialize();
		Discord.DiscordClient.changePresence("Loading The Game", null);
		#end

		PlayerSettings.init();
		ClientPrefs.loadPrefs();

		Highscore.load();
		Progression.load();
		ClientPrefs.loadDefaultKeys();

		ColorblindFilters.applyFiltersOnGame();
		Main.canToggleFullScreen = true;

		Application.current.onExit.add(function(exitCode)
		{
			FlxG.save.flush();
			Progression.save();
			Discord.DiscordClient.shutdown();
			Sys.exit(0);
		});

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		FlxG.sound.fullscreenKeys = TitleState.fullscreenKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		FlxG.autoPause = ClientPrefs.autoPause;
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = ClientPrefs.mouseSkinn == 'System' ? true : false;
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
			if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			if(FlxG.save.data.achievementsSoni == null) GJAchievements.defaultAchievements(); 
		}

		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		FlxG.worldBounds.set(0, 0);

		Lib.application.window.focus();

		Thread.create(() ->
		{
			init();
		});
	}

	function init()
	{
		loadS.max = 9;

		loadS.setLoadingText("Loading images");

		FlxGraphic.defaultPersist = true;

		// Cinematic Bars
		var aesthetic:FlxGraphic = FlxG.bitmap.add(Paths.image("aesthetic", "preload"));

		// Notes things
		var notes:FlxGraphic = FlxG.bitmap.add(Paths.image("NOTE_assets", "shared"));
		var splashes:FlxGraphic = FlxG.bitmap.add(Paths.image("noteSplashes", "shared"));

		// Note Combo things
		var noteComboSpr:FlxGraphic = FlxG.bitmap.add(Paths.image("Note_kombo_soni", "shared"));
		var numbers:FlxGraphic = FlxG.bitmap.add(Paths.image("numbers", "shared"));

		// Bruh
		var letrero:FlxGraphic = FlxG.bitmap.add(Paths.image("Letre", "preload"));

		Main.persistentAssets.push(aesthetic);
		loadS.progress = 1;
		Main.persistentAssets.push(notes);
		loadS.progress = 2;
		Main.persistentAssets.push(splashes);
		loadS.progress = 3;
		Main.persistentAssets.push(noteComboSpr);
		loadS.progress = 4;
		Main.persistentAssets.push(numbers);
		loadS.progress = 5;
		Main.persistentAssets.push(letrero);
		loadS.progress = 6;

		loadS.setLoadingText("Loading sounds");

		// GameOver
		FlxG.sound.cache(Paths.sound('fnf_loss_sfx', 'shared'));
		loadS.progress = 7;
		FlxG.sound.cache(Paths.sound('gameOver', 'shared'));
		loadS.progress = 8;
		FlxG.sound.cache(Paths.sound('gameOverEnd', 'shared'));
		loadS.progress = 9;

		FlxGraphic.defaultPersist = false;

		loadS.setLoadingText("Initializing");

		finish();
	}

	function finish()
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, false);
		
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(Type.createInstance(SpecsDetector, []));
		});
	}
}