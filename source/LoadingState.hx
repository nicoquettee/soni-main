package;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

import lime.app.Application;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.util.FlxAxes;
import flixel.graphics.FlxGraphic;
import sys.thread.Thread;

#if desktop
import Discord.DiscordClient;
#end

import haxe.io.Path;
import openfl.Lib;

//LOADINGS SCREENS SCRIPT BY: ROYAL
class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;
	
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;

	var hasLoad:Bool = true;

	static var imagesToCache:Array<String> = [];
	static var soundsToCache:Array<String> = [];
	static var library:String = "";
	
	function new(target:FlxState, stopMusic:Bool, directory:String, ?loadingScreen:Bool = true)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
		this.hasLoad = loadingScreen;
	}

	var bg:FlxSprite;
	var loadBar:FlxSprite;
	var random:Int = FlxG.random.int(1,4);
	
	override function create()
	{
		Lib.application.window.title = 'Freaky Night With Soni - Loading';

		var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF83ff00);
		if(hasLoad)
			add(blackScreen);

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(Paths.image('loading/$random')); //💤💤💤💤💤 
		//bg.setGraphicSize(FlxG.width);
		bg.setGraphicSize(FlxG.width,FlxG.height);
		bg.updateHitbox();
		//bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		if(hasLoad)
			add(bg);
		bg.scrollFactor.set();

		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, -59694);
		loadBar.screenCenter(FlxAxes.X);
		//add(loadBar);	

		logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		//add(gfDance);
		//add(logo);
		
		initSongsManifest().onComplete
		(
			function (lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				if (PlayState.SONG != null) {
					checkLoadSong(getSongPath());
					if (PlayState.SONG.needsVoices)
						checkLoadSong(getVocalPath());
				}
				checkLibrary("shared");
				if(directory != null && directory.length > 0 && directory != 'shared') {
					checkLibrary(directory);
				}

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);

		super.create();

		if(target == new PlayState())
		{
			switch(Paths.formatToSongPath(PlayState.SONG.song))
			{
				case 'sonicando':
					library = 'preload';
					imagesToCache = ['cryaboutit'];
				case 'sped':
					library = 'shared';
					imagesToCache = ['backgrounds/soni/BackgroundA', 'backgrounds/soni/dead tais reported !!!!', 'backgrounds/soni/Humo'];
				case 'cheese':
					library = 'shared';
					var where:String = 'backgrounds/sas/black/';
					imagesToCache = ['${where}Sky_noblue_alt', '${where}sun_alt', '${where}Bg_Back_alt', '${where}BG_grillby_alt', '${where}Bg_Front_alt'];
				case 'precocious':
					library = 'shared';
					imagesToCache = ['glowShit/particle-hearth'];
				case 'spines':
					library = 'preload';
					imagesToCache = ['icons/tais-apk'];
				case 'impersonation':
					library = 'shared';
					soundsToCache = ['santiago/paper', 'santiago/bfBeep'];
				case '3am':
					library = 'shared';
					imagesToCache = ['backgrounds/halloween/pianoekis', 'backgrounds/halloween/BG_Anim', 'backgrounds/halloween/Moon_Corrida', 'backgrounds/halloween/Bg_S', 'backgrounds/events/spotlight'];
			}
		}

		Paths.setCurrentLevel('shared');
		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			for (sound in soundsToCache)
			{
				FlxG.sound.cache(Paths.sound(sound, library));
			}

			for (image in imagesToCache)
			{
				FlxG.bitmap.add(Paths.image(image, library));
			}

			FlxGraphic.defaultPersist = false;

			new FlxTimer().start(1, function(_:FlxTimer)
			{
				loadAndSwitchState2(target, false);
			});
		});
	}
	
	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
	}
	
	function checkLibrary(library:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;
			
			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		logo.animation.play('bump');
		danceLeft = !danceLeft;
		
		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (callbacks != null)
			loadBar.scale.x = callbacks.getFired().length / callbacks.getUnfired().length;

		//if (FlxG.keys.justPressed.ENTER)
			//bg.setGraphicSize(Std.int(bg.width * 0.05));
		
		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end

		#if NO_PRELOAD_ALL
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded("shared") && isLibraryLoaded(directory);
		}

		if(loaded)
			loadAndSwitchState2(target, stopMusic);
		#end
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false, ?loadingScreen:Bool = true)
	{
		Main.dumping = false;
		FlxG.switchState(getNextState(target, stopMusic, loadingScreen));
	}
	
	static function getNextState(target:FlxState, stopMusic = false, ?loadingScreen:Bool = true):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded("shared") && isLibraryLoaded(directory);
		}
		
		if (!loaded)
			return new LoadingState(target, stopMusic, directory, loadingScreen);
	
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}

	inline static public function loadAndSwitchState2(target:FlxState, stopMusic = false)
	{
		Main.dumping = false;
		FlxG.switchState(getNextState2(target, stopMusic));
	}
	
	static function getNextState2(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		#if NO_PRELOAD_ALL
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded2(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded2(getVocalPath())) && isLibraryLoaded2("shared") && isLibraryLoaded2(directory);
		}
		
		if (!loaded)
			return new LoadingState(target, stopMusic, directory);
		#end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}
	
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}

	#if NO_PRELOAD_ALL
	static function isSoundLoaded2(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded2(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}

	public static function dumpAdditionalAssets()
	{
		for (image in imagesToCache)
		{
			trace("Dumping image " + image);
			FlxG.bitmap.removeByKey(Paths.image(image, library));
		}
		soundsToCache = [];
		imagesToCache = [];
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}