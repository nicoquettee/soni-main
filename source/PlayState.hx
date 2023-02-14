package;

import flixel.addons.display.FlxBackdrop;
import Achievements;
import DialogueBoxPsych;
import FunkinLua;
import FunnyGlow;
import GameJolt.GameJoltAPI;
import GameJolt;
import Note.EventNote;
import Section.SwagSection;
import Shaders;
import Song.SwagSong;
import StageData;
import WiggleEffect.WiggleEffectType;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.app.Application;
import lime.app.Application;
import lime.utils.Assets;
import modcharts.*;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.display.Window;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import window.WindowManager;
import Conductor.Rating;
import flixel.effects.FlxFlicker;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

using StringTools;

#if desktop
import Discord.DiscordClient;
#end
#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var modchartObjects:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];

	// event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;
	public var initialPlaybackRate:Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isCode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var shaderUpdates:Array<Float->Void> = [];

	var author:String;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	var isDownscroll:Bool = false;

	public static var isMiddlescroll:Bool = false;

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = true;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var healthDisplay:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;

	public var healthBar:FlxBar;

	// Health Tween Object
	var healthTween:FlxTween;

	var songPercent:Float = 0;

	// werhog
	var ice2:BGSprite;
	var ice1:BGSprite;
	var ice3:BGSprite;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	private var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var mechanics:Bool = true;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	var letreroTween:FlxTween;
	var textoLeTween:FlxTween;
	var letreroTimer:FlxTimer = null;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FNFCamera;
	public var camLyrics:FNFCamera;
	public var camGame:FNFCamera;
	public var camOther:FNFCamera;
	public var camNotes:FNFCamera;
	public var camBars:FNFCamera;
	public var cams:Array<FNFCamera> = [];
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var blammedLightsBlackForOther:FlxSprite;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var songText:FlxText;
	var authorText:FlxText;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	public var songScore:Int = 0;
	public var visibleScore:Int = 0;
	public var vScoreTarget:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	var xtrum:Float;
	var ytrum:Float;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float = 0;

	var letrero:FlxSprite;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;

	public var luaArray:Array<FunkinLua> = [];

	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public var introSoundsSuffix:String = '';

	// Options
	public var backOutfromOptions:Bool = false;

	// Pause
	public var backOutfromPause:Bool = false;

	var pauseTween:FlxTween;

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	// Soni things for potatoes pc
	var dead:FlxSprite;
	var clouds:BGSprite;
	var tree:BGSprite;
	var goldenFlower:BGSprite;
	var bgAnim:BGSprite;
	var smoke:Smoke;
	var grpSoniStage:FlxTypedGroup<FlxSprite>;

	// bil-letes
	var nose:Float;
	var shader:BitmapFilter;
	var filters:Array<BitmapFilter> = [];
	var spriteTrail:FlxTypedGroup<FlxSprite>;
	var zoomMax:Float = 0;
	var timeBarBGFake:AttachedSprite;
	var timeBarFake:FlxBar;

	// A LOT OF SHITTT
	var defaultPlayerStrumX1:Float;
	var defaultPlayerStrumX2:Float;
	var defaultPlayerStrumX3:Float;
	var defaultPlayerStrumX4:Float;

	var defaultOpponentStrumX1:Float;
	var defaultOpponentStrumX2:Float;
	var defaultOpponentStrumX3:Float;
	var defaultOpponentStrumX4:Float;
	// END OF THE SHITTT

	// funking ass shitty soni
	// functions
	var curBeatSection:Void->Void;
	var curStepSection:Void->Void;
	var changeBG:Void->Void;
	var songEvent:(v1:Dynamic, v2:Dynamic)->Void;
	var onUpdate:Float->Void;
	var onUpdatePost:Float->Void;
	var onPause:Void->Void;
	var onResume:Void->Void;
	var onStartCountdown:Void->Void;
	var onCreatePost:Void->Void;
	// vars
	var funnyGlowGradient:FunnyGlow.FunnyGlowGradient;
	var funnyGlowParticles:FlxTypedGroup<FunnyGlow.FunnyGlowParticle>;
	var particleSufix:String = '';
	var camSwaymult:Float = 1;
	var box:Float = 100;
	var boy:Float = 100;
	var precenseIcon:String = ''; //for discord rich presence
	var hasFlippedStrums:Bool = false;

	// Offsets
	var shittyShitAssOpponent:Array<Float> = [];
	var shittyShitAssGF:Array<Float> = [];
	var shittyShitAssPlayer:Array<Float> = [];

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	var chromVal:Float = 0;
	var candisturb:Bool = false;

	// sasses?!?!?!
	var shader2:BitmapFilter;
	var graySasses:Array<Float> = [];
	var invertSasses:Array<Float> = [];
	var initialBF:String;
	var initialDad:String;
	var initialGF:String;
	var initialDSN:String;
	var initialDSE:String;
	var initialDBF:String;
	var mierdaCosa1:String = '';
	var mierdaCosa2:String = '';

	// jp vs royal shit n' stuff
	var bmmo:BGSprite;
	var mymanuel:BGSprite;
	var syj:BGSprite;
	var dyy:BGSprite;
	var lyd:BGSprite;
	var streetFront:BGSprite;
	var streetWall:BGSprite;

	// soni x h fuck my mum
	var floor:BGSprite;

	// homr stuff
	public var taisHomr:Boyfriend = null;

	// COMBO SHITS BY ROYAL (credits if is used pls)
	var lastMustHit:Bool = false;
	var noteHits:Int = 0;
	var lastNoteHits:Int = 0;
	var noteCombo:NoteCombo;
	var noteComboN1:FlxSprite;
	var noteComboN2:FlxSprite;
	var noteComboN3:FlxSprite;
	var seperatedHits:String = '';
	var count:Int = 0;

	// Modchart thingis
	var directionThingi:Float;

	public static var sliderVelocities:Array<Song.VelocityChange>;

	public var upscrollOffset:Float = 0;
	public var downscrollOffset:Float = 0;
	public var center:FlxPoint;
	public var speed:Float = 0;

	var velocityMarkers:Array<Float> = [];
	var language:String = ClientPrefs.lyricsLanguagee; // for lua shit

	// events things
	var aesthetic:FlxSprite;
	var thingiBlack:BGSprite;
	var thingiLight:BGSprite;
	var thingiSmokes:FlxSpriteGroup;
	var elShader = new PixelateShader();
	var blackScreen:FlxSprite;
	var lyricsTxt:FlxText;
	var funny:FlxSprite;
	var camPosicioning:Bool = false;
	var camTimer:FlxTimer;

	// Debug Stuff
	var canDie:Bool = true;

	var focusing:Bool = true;

	// Pause stuff bruhh
	var pauseGray:Array<Float> = [
		0.5, 0.5, 0.5, 0, 0,
		0.5, 0.5, 0.5, 0, 0,
		0.5, 0.5, 0.5, 0, 0,
		  0,   0,   0, 1, 0,
	];
	var pauseShad:Array<BitmapFilter> = [];
	var grayShader:BitmapFilter;

	// Pruebas
	var from:
		{
			x:Float,
			y:Float,
			angle:Float,
			time:Float
		} = {
			x: 0,
			y: 0,
			angle: 0,
			time: 0
		};
	var to:
		{
			x:Float,
			y:Float,
			angle:Float,
			time:Float
		} = {
			x: 0,
			y: 0,
			angle: 0,
			time: 0
		};
	var currentNote:Note = null;
	var jumpingNote:FlxSprite;
	var coloredJumpingNote:FlxSprite;
	var add360:Bool = false;
	var str = null;
	var e = false;

	public var guiSize(get, null):FlxPoint;

	private function get_guiSize():FlxPoint
	{
		return new FlxPoint(1280 / ClientPrefs.noteScale, 720 / ClientPrefs.noteScale);
	}

	// Hscript
	public var script:HScript;

	var precacheList:Map<String, String> = new Map<String, String>();

	public function new()
	{
		super();
		MusicBeatState.dumpcachetuff = false;
		dumpAddt = false;
	}

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		/*var testing = new Testeo();
			testing.x(); */

		if (script != null)
		{
			script.executeFunc("onCreate");
		}

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		Achievements.loadAchievements();

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		isDownscroll = ClientPrefs.downScroll;
		isMiddlescroll = ClientPrefs.middleScroll;
		initialPlaybackRate = playbackRate;

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		mechanics = ClientPrefs.mechanics;

		if(GameOverSubstate.healthLossDecreased) healthLoss = 0.7;

		if (Paths.formatToSongPath(SONG.song) == 'scrapped-mouse' && mechanics)
			isMiddlescroll = true;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FNFCamera();
		camBars = new FNFCamera();
		camHUD = new FNFCamera();
		camNotes = new FNFCamera();
		camLyrics = new FNFCamera();
		camOther = new FNFCamera();
		camBars.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camLyrics.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBars, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camLyrics, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		healthTween = FlxTween.tween(this, {}, 0);
		pauseTween = FlxTween.tween(this, {}, 0);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('unleashed');

		speed = SONG.speed;

		sliderVelocities = [];

		sliderVelocities.push({
			startTime: -5000,
			multiplier: 1
		});

		for (shit in SONG.sliderVelocities)
		{
			sliderVelocities.push(shit);
		}

		sliderVelocities.sort((a, b) -> Std.int(a.startTime - b.startTime));

		SONG.initialSpeed = speed * .45;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			#if PRIVATE_BUILD
			detailsText = "Story Mode: " + 'CLASSIFIED';
			#else
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
			#end
		}
		else
		{
			if (isCode)
				detailsText = "Code";
			else
				detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		cams = [camGame, camHUD, camNotes, camLyrics, camOther];
		for(cam in cams)
		{
			if(cam != null)
			{
				switch(Paths.formatToSongPath(SONG.song))
				{
					case 'broken-reality' | 'spines':
						cam.setFilters(filters);
						switch(Paths.formatToSongPath(SONG.song))
						{
							case 'spines':
								filters.push(chromaticAberration);
						}
					default:
						cam.setFilters(pauseShad);
				}
				cam.filtersEnabled = true;
			}
		}

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		// trace('stage is: ' + curStage);
		if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
		{
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		defaultCamZoom = stageData.defaultZoom;

		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.visible = false;
		blackScreen.cameras = [camOther];
		blackScreen.screenCenter();
		blackScreen.antialiasing = ClientPrefs.globalAntialiasing;
		add(blackScreen);

		switch (curStage)
		{
			case 'werhog':
				boy = 60;

				var bg:BGSprite = new BGSprite('werhog/Sky_Werhog', -500, -400, .3, .3);
				add(bg);

				var water:BGSprite = new BGSprite('werhog/Back_waterNince_Werhog', -300, 250, .5, .5);
				water.scale.set(1.2, 0.9);
				water.updateHitbox();
				add(water);

				if (!ClientPrefs.lowQuality)
				{
					ice1 = new BGSprite('werhog/IceBlock_1_Werhog', 215, 640, .7, .7, ['Ice1 instancia 1'], true);
					ice1.scale.set(1.2, 1.2);
					ice1.dance();
					add(ice1);

					ice2 = new BGSprite('werhog/IceBlock_2_Werhog', 1300, 450, .7, .7, ['Ice 2 instancia 1'], true);
					ice2.scale.set(1.2, 1.2);
					ice2.dance();
					add(ice2);
				}

				ice3 = new BGSprite('werhog/Main_IceBlock_Werhog', 270, 950, 1, 1, ['Ice plataform instancia 1'], true);
				ice3.scale.set(1.2, 1.2);
				ice3.dance();
				add(ice3);

			///CppUse.transWindowColor(143, 190, 214, 0);

			// 50, 20
			case 'soni':
				/*GameOverSubstate.characterName = 'befe-moto'; //Test
					GameOverSubstate.deathSoundName = 'moto-loss'; */
				var purpFlower:BGSprite;
				var treesBG:BGSprite;

				grpSoniStage = new FlxTypedGroup<FlxSprite>();
				add(grpSoniStage);

				var bg:BGSprite = new BGSprite('soni/Cielo', 0, 0, .3, .3);
				bg.scale.set(2, 2);
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				grpSoniStage.add(bg);

				if (!ClientPrefs.lowQuality)
				{
					clouds = new BGSprite('soni/Nubes', 0, 0, .4, 1);
					clouds.scale.set(2, 2);
					clouds.antialiasing = ClientPrefs.globalAntialiasing;
					grpSoniStage.add(clouds);
				}

				var mountains:BGSprite = new BGSprite('soni/Montanas', 0, 0, .6, 1);
				mountains.scale.set(2, 2);
				mountains.antialiasing = ClientPrefs.globalAntialiasing;
				grpSoniStage.add(mountains);

				var rocoFloor:BGSprite = new BGSprite('soni/PisoRocoso', 0, 0, .7, 1);
				rocoFloor.scale.set(2, 2);
				rocoFloor.antialiasing = ClientPrefs.globalAntialiasing;
				grpSoniStage.add(rocoFloor);

				var river:BGSprite = new BGSprite('soni/Rio', 0, 0, .7, 1);
				river.scale.set(2, 2);
				river.antialiasing = ClientPrefs.globalAntialiasing;
				grpSoniStage.add(river);

				if (!ClientPrefs.lowQuality)
				{
					treesBG = new BGSprite('soni/ArbolesDeFondo', 0, 0, .8, 1);
					treesBG.scale.set(2, 2);
					treesBG.antialiasing = ClientPrefs.globalAntialiasing;
					grpSoniStage.add(treesBG);

					tree = new BGSprite('soni/Arbolprincipal', 0, 0, .85, 1);
					tree.scale.set(2, 2);
					tree.antialiasing = ClientPrefs.globalAntialiasing;
					grpSoniStage.add(tree);

					goldenFlower = new BGSprite('soni/FlorDorada', 0, 0, .9, 1);
					goldenFlower.scale.set(2, 2);
					grpSoniStage.add(goldenFlower);
				}

				var floor:BGSprite = new BGSprite('soni/Piso', 0, 0, 1, 1);
				floor.scale.set(2, 2);
				grpSoniStage.add(floor);

				if (!ClientPrefs.lowQuality)
				{
					purpFlower = new BGSprite('soni/FloresMoradas', 0, 0, .95, 1);
					purpFlower.scale.set(2, 2);
					grpSoniStage.add(purpFlower);
				}

				if (Paths.formatToSongPath(SONG.song) == 'sped')
				{
					precacheList.set('backgrounds/soni/BackgroundA', 'image');
					precacheList.set('backgrounds/soni/dead tais reported !!!!', 'image');
					precacheList.set('backgrounds/soni/Humo', 'image');

					bgAnim = new BGSprite('soni/BackgroundA', -170, -250, .75, .75, ['BackgroundA'], true);
					bgAnim.scale.set(2, 2);
					bgAnim.visible = false;
					bgAnim.active = false;
					add(bgAnim);

					dead = new FlxSprite();
					dead.frames = Paths.getSparrowAtlas('backgrounds/soni/dead tais reported !!!!'); // Soni is the sus?!?! ding ding ding ding ding ding ding- ding ding ding tuntun
					dead.animation.addByPrefix('report', 'me muero', 24, false);
					dead.screenCenter();
					dead.antialiasing = ClientPrefs.globalAntialiasing;
					dead.cameras = [camOther];
					dead.visible = false;
					dead.active = false;
					add(dead);

					smoke = new Smoke();
					smoke.cameras = [camOther];
					add(smoke);
				}

				songEvent = function(v1,v2)
				{
					smoke.startSoniCar();
				}

				changeBG = function()
				{
					GameOverSubstate.characterName = 'befe-moto';
					GameOverSubstate.deathSoundName = 'moto-loss';
					bgAnim.visible = true;
					bgAnim.active = true;
					bgAnim.dance();
					gf.alpha = 0;
					// remove(bg);
					// grpSoniStage.kill();
					remove(grpSoniStage);
					grpSoniStage.destroy();
					dadGroup.x = -168;
					dadGroup.y = -13; // cuanto mas me la mamas mas me crece, aquí tiene pa que me la bese, entre más me la beses más me crece, busca un cura pa que me la rece, y trae un martillo pa que me la endereces, por el chiquito se te aparece toas las veces y cuando te estreses aquí te tengo éste pa que te desestreses, con este tallo el culo se te esflorece, se cumple el ciclo hasta que anochece, todos los días y todas las veces, de tanto entablar la raja del culo se te desaparece, porque este sable no se compadece, si pides ñapa se te ofrece, y si repites se te agradece, no te hace rico pero tampoco te empobrece, no te hace inteligente pero tampoco te embrutece, y no paro aquí compa que éste nuevamente se endurece, hasta que amanece, cambie esa cara que parece que se entristece, si te haces viejo éste te rejuvenece, no te hago bulla porque depronto te ensordece, y eso cuadro no te favorece, pero tranquilo que éste te abastece, porque allá abajo se te humedece, viendo como el que me cuelga resplandece, si a ti te da miedo a mí me enorgullece, y así toas las vece ¿que te parece?, y tranquilo mijo que aquí éste reaparece, no haga fuerza porque éste se sobrecrece, una fresadora te traigo pa que me la freses, así se fortalece y de nuevo la historia se establece, que no se te nuble la vista porque éste te la aclarece, y sino le entendiste nuevamente la explicación se te ofrece, pa que por el chiquito éste de nuevo te empiece... Aquí tienes para que me la beses, entre más me la beses más me crece, busca un cura para que me la rece, un martillo para que me la endereces, un chef para que me la aderece, 8000 pijas por el culo se te aparecen, si me la sobas haces que se me espese, si quieres la escaneas y te la llevas para que en tu hoja de vida la anexes, me culeo a tu maldita madre y qué te parece le meti la pija a tú mamá hace 9 meses y después la puse a escuchar René de Calle 13 Te la meto por debajo del agua como los peces, y aquella flor de pija que en tu culo crece
					boyfriendGroup.x = 962;
					boyfriendGroup.y = 77; // OMG I LOVE U YOSHI ENGINE STAGE EDITOR UWUWUUWU
					box = 350;
					boy = -10;
				}

			case 'ou':
				var guy1:BGSprite = null;
				var guy2:BGSprite = null;

				GameOverSubstate.characterName = 'befe-ou';
				GameOverSubstate.deathSoundName = 'loss_troll';

				var bg:BGSprite = new BGSprite('ou/ou-back', -650, -590, .8, .8);
				add(bg);

				var floor:BGSprite = new BGSprite('ou/ou-floor', -650, -540, 1, 1);
				add(floor);

				if (!ClientPrefs.lowQuality)
				{
					guy1 = new BGSprite('ou/CharacterOu1', -250, 340, .9, .9, ['Character_Ou_2']);
					// guy1.dance();
					guy1.scale.set(1.3, 1.3);
					add(guy1);

					guy2 = new BGSprite('ou/CharacterOu2', 1800, 310, .9, .9, ['Character_Ou_1']);
					guy2.scale.set(1.3, 1.3);
					add(guy2);
				}

				var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				black.cameras = [camHUD];
				black.visible = false;
				add(black);

				var ouBeats:Int = 0;

				onStartCountdown = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
						{
							guy1.dance(true);
							guy2.dance(true);
						}
				}
				
				curBeatSection = function()
				{
					ouBeats++;
					if (Paths.formatToSongPath(SONG.song) == 'ou')
					{
						switch (ouBeats)
						{
							case 716:
								black.visible = true;
						}
					}
					if (!ClientPrefs.lowQuality)
					{
						if (curBeat % 2 == 0)
						{
							guy1.dance(true);
							guy2.dance(true);
						}
					}
				}
			case 'idk-lol':
				var bg:BGSprite = new BGSprite('bruh/bggg', 0, 0);
				add(bg);

			case 'nft': // Bil lmaooo
				var bilY:Float = 1720;
				var isNight:Bool = Date.now().getHours() >= 20 || Date.now().getHours() < 7;

				var bg:FlxSprite = new FlxSprite().makeGraphic(5000, 5000, isNight ? 0xFF1E1E1E : FlxColor.WHITE);
				add(bg);

				camSwaymult = 2.5;

				onUpdate = function(stageElapsed)
				{
					if (!Math.isNaN(bilY) && dad.curCharacter == 'bil')
						dad.y = bilY + ((Math.sin((Conductor.songPosition / 16000) * (80 / Math.PI))) * 200);
					else
						bilY = dad.y;
				}

			case 'park':
				GameOverSubstate.characterName = 'soni-date';
				GameOverSubstate.deathSoundName = 'date_loss';
				GameOverSubstate.endSoundName = 'date_accept';
				particleSufix = '-hearth';

				var sky:BGSprite = new BGSprite('hxsoni/fondo', -808.333333333333, -261.666666666667, .5, .5);
				sky.scale.set(1.4, 1.4);
				sky.updateHitbox();
				add(sky);

				var buildings:BGSprite = new BGSprite('hxsoni/Edificios', -630, -150, .8, .8);
				buildings.scale.set(1.6, 1.4);
				buildings.updateHitbox();
				add(buildings);

				var balloon:BGSprite = new BGSprite('hxsoni/Globo', -273.333333333333, -869.999999999999, 1, 1, ['Nohay'], false);
				balloon.visible = false;
				balloon.active = false;
				// balloon.dance();
				add(balloon);

				floor = new BGSprite('hxsoni/Suelo', -650, 378.333333333333, .9, .9);
				floor.scale.set(1.65, 1.4);
				floor.updateHitbox();
				add(floor);

				songEvent = function(v1,v2)
				{
					balloon.visible = true;
					balloon.active = true;
					balloon.dance();
				}

			case 'drawe':
				var tais:BGSprite = null;
				var nuckles:BGSprite = null;

				GameOverSubstate.characterName = 'drawe-befe';
				GameOverSubstate.deathSoundName = 'loss_drawe';
				GameOverSubstate.endSoundName = 'accept_drawe';
				box = 450;

				var white:FlxSprite = new FlxSprite(-1500, -730).makeGraphic(5000, 3840, FlxColor.WHITE);
				add(white);

				if (!ClientPrefs.lowQuality)
				{
					tais = new BGSprite('origishit/Tits_assets', 150, -200, .95, .95, ['Teis idle dance']);
					tais.dance();
					add(tais);

					nuckles = new BGSprite('origishit/Nakel_assets', 800, -135, .95, .95, ['nudillos Idle dance ']);
					nuckles.dance();
					add(nuckles);
				}

				onStartCountdown = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
						{
							tais.dance(true);
							nuckles.dance(true);
						}
				}

				curBeatSection = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
						{
							tais.dance(true);
							nuckles.dance(true);
						}
				}

			case 'street':
				GameOverSubstate.characterName = 'jp';
				GameOverSubstate.deathSoundName = 'loss_tilin';

				var bg:BGSprite = new BGSprite('jpvsroyal/Bg_Back', -287, -173, .8, .8);
				add(bg);

				if (!ClientPrefs.lowQuality)
				{
					bmmo = new BGSprite('jpvsroyal/BF_M_Mo', 737, 65, .85, .85, ['BF_MyMax']);
					bmmo.dance();
					add(bmmo);

					mymanuel = new BGSprite('jpvsroyal/MyManuel', 57, 112, .85, .85, ['MyManuel']);
					mymanuel.dance();
					add(mymanuel);
				}

				streetFront = new BGSprite('jpvsroyal/Bg_Front', -397, 273, .9, .9);
				add(streetFront);

				streetWall = new BGSprite('jpvsroyal/Bg_P', -693, -107, .9, .9);
				add(streetWall);

				syj = new BGSprite('jpvsroyal/SyJ', -410, 257, .9, .9, ['SyJ']);
				syj.dance();
				add(syj);

			case 'grillby':
				var sun:BGSprite = null;
				precacheList.set('backgrounds/sas/black/Sky_noblue_alt', 'image');
				if (!ClientPrefs.lowQuality)
					precacheList.set('backgrounds/sas/black/sun_alt', 'image');
				precacheList.set('backgrounds/sas/black/Bg_Back_alt', 'image');
				precacheList.set('backgrounds/sas/black/BG_grillby_alt', 'image');
				precacheList.set('backgrounds/sas/black/Bg_Front_alt', 'image');
				changeBG = function()
				{
					var sky:BGSprite = new BGSprite('sas/${mierdaCosa1}Sky_noblue$mierdaCosa2', -1243, -533, .3, .3);
					sky.scale.set(1.5, 1.5);

					if (!ClientPrefs.lowQuality)
					{
						sun = new BGSprite('sas/${mierdaCosa1}sun$mierdaCosa2', 300, 30, .5, .5, ['Sun']);
						sun.dance();
					}

					var back:BGSprite = new BGSprite('sas/${mierdaCosa1}Bg_Back$mierdaCosa2', -317, -73, .7, .7);

					var grillby:BGSprite = new BGSprite('sas/${mierdaCosa1}BG_grillby$mierdaCosa2', -717, -20, .85, .85);

					var front:BGSprite = new BGSprite('sas/${mierdaCosa1}Bg_Front$mierdaCosa2', -400, 710, 1, 1);

					if (sky != null)
						remove(sky);
					if (sun != null)
						remove(sun);
					if (back != null)
						remove(back);
					if (grillby != null)
						remove(grillby);
					if (front != null)
						remove(front);

					insert(members.indexOf(gfGroup), sky);
					if (!ClientPrefs.lowQuality)
						insert(members.indexOf(gfGroup), sun);
					insert(members.indexOf(gfGroup), back);
					insert(members.indexOf(gfGroup), grillby);
					insert(members.indexOf(gfGroup), front);
				}

				onStartCountdown = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
						{
							if (sun != null)
								sun.dance(true);
						}
				}

				curBeatSection = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
							if (sun != null)
								sun.dance(true);
				}

				onUpdate = function(stageElapsed)
				{
					var isSas:Bool = dad.curCharacter == 'sas' || dad.curCharacter == 'sas-alt';
					var isAlt:Bool = dad.animation.curAnim.name.startsWith('sing') && dad.animation.curAnim.name.endsWith('-alt');
					if (isAlt && isSas)
						dad.specialAnim = true;
					if (isSas)
					{
						dad.animation.finishCallback = function(anim:String)
						{
							if (isAlt)
							{
								dad.dance();
							}
						}
					}
				}

			case 'forest':
				var taisIcon:HealthIcon;
				var iconDest:Float = 0;
				var numberOne:Float = 100;
				var numberTwo:Float = 100;
				var shittyTween:FlxTween = null;
				var shittyTween2:FlxTween = null;
				var switched:Bool = false;

				var value1:Float = 0;
				var value2:Float = 0;
				var value3:Float = 0;

				GameOverSubstate.characterName = 'befe_apk';
				GameOverSubstate.deathSoundName = 'real_fnf_loss_nomic';

				var forest:BGSprite = new BGSprite('apk/bosque7', -1195, -820, .5, .5);
				forest.scale.set(1.7, 1.7);
				add(forest);

				if (!ClientPrefs.lowQuality)
				{
					var bushes:BGSprite = new BGSprite('apk/Arbusto5', -1195, -820, .6, .6);
					bushes.scale.set(1.7, 1.7);
					add(bushes);

					var trees:BGSprite = new BGSprite('apk/Arboles_de_atras4', -1195, -820, .7, .7);
					trees.scale.set(1.7, 1.7);
					add(trees);
				}

				var floor:BGSprite = new BGSprite('apk/SUELITO_MALO_MALON3', -1195, -820, 1, 1);
				floor.scale.set(1.7, 1.7);
				add(floor);

				var daStatic:FlxSprite = new FlxSprite();
				daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'shared');
				daStatic.setGraphicSize(FlxG.width, FlxG.height);
				daStatic.alpha = 0.007;
				daStatic.screenCenter();
				daStatic.cameras = [camOther];
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, true);
				add(daStatic);
				daStatic.animation.play('static');

				onCreatePost = function()
				{
					taisIcon = new HealthIcon("tais-apk", false);
					taisIcon.y = healthBar.y - 75;
					taisIcon.x = iconP2.x - 400;
					taisIcon.visible = !ClientPrefs.hideHud;
					taisIcon.alpha = ClientPrefs.healthBarAlpha;
					taisIcon.cameras = [camHUD];
					taisIcon.visible = false;
					insert(members.indexOf(iconP2), taisIcon);
				}

				songEvent = function(v1,v2)
				{
					gf.visible = true;
				}

				onStartCountdown = function()
				{
					if (SONG.song.toLowerCase() == 'spines')
					{
						if (ClientPrefs.funnyShaders)
						{
							if (curBeat % 4 == 0)
							{
								chromVal = 0.0005;
								FlxTween.tween(this, {chromVal: 0}, 1.14 / initialPlaybackRate);
							}
						}
						else
						{
							FlxTween.tween(this, {chromVal: 0}, 1.14 / initialPlaybackRate);
						}
					}
				}

				curBeatSection = function()
				{
					taisIcon.scale.set(1.2, 1.2);
					taisIcon.updateHitbox();
					switch(curBeat)
					{
						case 252:
							taisIcon.visible = true;
							taisIcon.alpha = 0;
							iconDest = 1;
							numberOne = 0;
							numberTwo = 0;
							switched = true;
							var shittyTween = FlxTween.num(numberOne, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberOne = v;
							});
							eventTweens.push(shittyTween);
							var shittyTween2 = FlxTween.num(numberTwo, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberTwo = v;
							});
							eventTweens.push(shittyTween2);
							var tweenIcon1 = FlxTween.tween(taisIcon, {alpha: 1}, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut});
							var tweenIcon2 = FlxTween.tween(iconP2, {alpha: 0}, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut});
							eventTweens.push(tweenIcon1);
							eventTweens.push(tweenIcon2);
							var switchTween1 = FlxTween.num(value1, 110, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								value1 = v;
							});
							var switchTween2 = FlxTween.num(value2, 240, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								value2 = v;
							});
							var switchTween3 = FlxTween.num(value3, -100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								value3 = v;
							});
							eventTweens.push(switchTween1);
							eventTweens.push(switchTween2);
							eventTweens.push(switchTween3);
							var timer = new FlxTimer().start(((Conductor.crochet / 500) / 2) / initialPlaybackRate, (tmr)->
							{
								healthBar.flipX = true;
								iconP1.flipX = true;
								taisIcon.flipX = true;
								dad.healthColorArray = [111, 105, 99];
								reloadHealthBarColors();
								reloadTimeBarColors();
							});
							eventTimers.push(timer);
						case 486:
							iconDest = 0;
							numberOne = 0;
							numberTwo = 0;
							var shittyTween = FlxTween.num(numberOne, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberOne = v;
							});
							eventTweens.push(shittyTween);
							var shittyTween2 = FlxTween.num(numberTwo, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberTwo = v;
							});
							eventTweens.push(shittyTween2);
							var tweenIcon3 = FlxTween.tween(iconP2, {alpha: 1}, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut});
							eventTweens.push(tweenIcon3);
							var switchTween1 = FlxTween.num(value1, 0, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								value1 = v;
							});
							var switchTween2 = FlxTween.num(value2, 0, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								value2 = v;
							});
							var switchTween3 = FlxTween.num(value3, 0, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								value3 = v;
							});
							eventTweens.push(switchTween1);
							eventTweens.push(switchTween2);
							eventTweens.push(switchTween3);
							var timer = new FlxTimer().start(((Conductor.crochet / 500) / 2) / initialPlaybackRate, (tmr)->
							{
								switched = false;
								healthBar.flipX = false;
								iconP1.flipX = false;
								taisIcon.flipX = false;
								dad.healthColorArray = [59, 58, 98];
								reloadHealthBarColors();
								reloadTimeBarColors();
							});
							eventTimers.push(timer);
						case 524 | 532 | 534:
							iconDest = 1;
							numberOne = 0;
							numberTwo = 0;
							if(shittyTween != null) shittyTween.cancel();
							if(shittyTween2 != null) shittyTween2.cancel();
							shittyTween = FlxTween.num(numberOne, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberOne = v;
							});
							eventTweens.push(shittyTween);
							shittyTween2 = FlxTween.num(numberTwo, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberTwo = v;
							});
							eventTweens.push(shittyTween2);
						case 528 | 533 | 535:
							iconDest = 0;
							numberOne = 0;
							numberTwo = 0;
							if(shittyTween != null) shittyTween.cancel();
							if(shittyTween2 != null) shittyTween2.cancel();
							shittyTween = FlxTween.num(numberOne, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberOne = v;
							});
							eventTweens.push(shittyTween);
							shittyTween2 = FlxTween.num(numberTwo, 100, (Conductor.crochet / 500) / initialPlaybackRate, {ease: FlxEase.cubeOut}, function(v:Float)
							{
								numberTwo = v;
							});
							eventTweens.push(shittyTween);
					}

					if (SONG.song.toLowerCase() == 'spines')
					{
						if (ClientPrefs.funnyShaders)
						{
							if (curBeat % 4 == 0)
							{
								chromVal = 0.0005;
								var tweenChrom = FlxTween.tween(this, {chromVal: 0}, 1.16 / initialPlaybackRate);
								eventTweens.push(tweenChrom);
							}
						}
						else
						{
							var tweenChrom = FlxTween.tween(this, {chromVal: 0}, 1.16 / initialPlaybackRate);
							eventTweens.push(tweenChrom);
						}
					}
				}

				onUpdatePost = function(stageElapsed)
				{
					var mult = FlxMath.lerp(1, taisIcon.scale.x, CoolUtil.boundTo(1 - (stageElapsed * 9 * playbackRate), 0, 1));
					taisIcon.scale.set(mult, mult);
					taisIcon.updateHitbox();

					/*trace('n1: ' + numberOne);
					trace('n2: ' + numberTwo);*/
					var iconOffset:Int = 26;
					switch(iconDest)
					{
						case 0:
							iconP2.x = healthBar.x
							+ dad.daIconOffsets
							+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
							- (150 * iconP2.scale.x) / 2
							- (iconOffset * 2)
							- 100 + numberTwo;
							taisIcon.x = healthBar.x
							+ dad.daIconOffsets
							+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
							- (150 * iconP2.scale.x) / 2
							- (iconOffset * 2)
							- numberOne;
						case 1:
							iconP2.x = healthBar.x
							+ dad.daIconOffsets
							+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
							- (150 * iconP2.scale.x) / 2
							- (iconOffset * 2)
							- numberOne;
							taisIcon.x = healthBar.x
							+ dad.daIconOffsets
							+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
							- (150 * iconP2.scale.x) / 2
							- (iconOffset * 2)
							- 100 + numberTwo;
					}
					if(switched)
					{
						var p1Mult:Float = healthBar.x + ((healthBar.width * healthBar.percent * 0.01) + (150 * iconP1.scale.x - 150) / 2 - 26);
						var p2Mult:Float = healthBar.x + ((healthBar.width * healthBar.percent * 0.01) - (150 * iconP2.scale.x) / 2 - 26 * 2);
						iconP1.x = p1Mult - value1;
						iconP1.origin.x = value2;
						taisIcon.x = p2Mult + value1;
						taisIcon.origin.x = value3;
					}
				
					if (healthBar.percent > 80)
						taisIcon.animation.curAnim.curFrame = 1;
					else
						taisIcon.animation.curAnim.curFrame = 0;
				}

				onUpdate = function(stageElapsed)
				{
					if (SONG.song.toLowerCase() == 'spines')
					{
						/*if (#if PRIVATE_BUILD !TitleState.isDebug && #end candisturb && curBeat < 576)
						{
							var not:String = 'not${FlxG.random.int(1,9)}.ps1';
							errorApk(FlxG.random.int(0,4000));
							//if(FlxG.random.int(0,6000) == 69) Sys.command('PowerShell -File assets/shared/zBAT/$not');
							/*if(FlxG.random.int(0,8000) == 69) 
								makeWindow({x:FlxG.random.int(0,1280),y:FlxG.random.int(0,720),
											width:FlxG.random.int(50,1152),height:FlxG.random.int(50,1162),
											title:'SONI',borderless:false,alwaysOnTop:true});*/
						//}
						if (ClientPrefs.funnyShaders)
							setChrome(chromVal);
					}

					/*if (funnyGlowParticles != null)
					{
						var i:Int = funnyGlowParticles.members.length - 1;
						while (i > 0)
						{
							var particle = funnyGlowParticles.members[i];
							if (particle.alpha < 0)
							{
								particle.kill();
								funnyGlowParticles.remove(particle, true);
								particle.destroy();
							}
							--i;
						}
					}*/ //this was descarted lol
				}

			case 'shawn':
				var directory:String = 'shawn/';
				var pelotudo:String = '_pelotudo';
				box = 170;

				var sky:BGSprite = new BGSprite('${directory}Cielo$pelotudo', -610, -405, .3, .3);
				add(sky);

				var mountains:BGSprite = new BGSprite('${directory}Montanas$pelotudo', -610, -405, .5, .5);
				add(mountains);

				var sea:BGSprite = new BGSprite('${directory}So', -610, -405, .7, .7);
				add(sea);

				var front:BGSprite = new BGSprite('${directory}Coso$pelotudo', -610, -405, 1, 1);
				add(front);

				var mid:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/shawn/mid'), .8, .8, true, true);
				mid.x += 35;
				mid.antialiasing = ClientPrefs.globalAntialiasing;
				add(mid);

				var mid2:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/shawn/mid2'), .85, .85, true, true);
				mid2.x -= 35;
				mid2.antialiasing = ClientPrefs.globalAntialiasing;
				add(mid2);

				var storm:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/shawn/storm'), .9, .9, true, false);
				storm.screenCenter();
				storm.x += 35;
				storm.antialiasing = ClientPrefs.globalAntialiasing;
				add(storm);

				var storm2:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/shawn/storm2'), 1.25, 1.25, true, true);
				storm2.x -= 35;
				storm2.antialiasing = ClientPrefs.globalAntialiasing;

				var weak:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/shawn/weak'), 1.3, 1.3, true, true);
				weak.x += 35;
				weak.antialiasing = ClientPrefs.globalAntialiasing;

				var weak2:FlxBackdrop = new FlxBackdrop(Paths.image('backgrounds/shawn/weak2'), 1.35, 1.35, true, true);
				weak2.x -= 35;
				weak2.antialiasing = ClientPrefs.globalAntialiasing;

				onCreatePost = function()
				{
					add(storm2);
					add(weak);
					add(weak2);
				}

				onUpdate = function(stageElapsed)
				{
					mid.x -= .7*(stageElapsed/(1/120));
					mid.y += .7*(stageElapsed/(1/120));
					mid2.x -= 1*(stageElapsed/(1/120));
					mid2.y += 1*(stageElapsed/(1/120));

					storm.x += .9*(stageElapsed/(1/120));
					storm2.x -= 1.1*(stageElapsed/(1/120));

					weak.x -= .6*(stageElapsed/(1/120));
					weak.y += .6*(stageElapsed/(1/120));
					weak2.x -= .8*(stageElapsed/(1/120));
					weak2.y += .8*(stageElapsed/(1/120));
				}

			case 'toystage':
				var bg:BGSprite = new BGSprite('sas/toy/toysasfondo', -1020, -845);
				bg.scale.set(.8, .8);
				add(bg);

			case 'jungle': // (creo que se escribe asi, ni puta idea la verdad)
				var sky:BGSprite = new BGSprite('taiscnuckles/Cielo', -953, -293, .3, .3);
				sky.scale.set(2, 2);
				add(sky);

				var mountains:BGSprite = new BGSprite('taiscnuckles/Montanas', -953, -293, .4, .4);
				mountains.scale.set(2, 2);
				add(mountains);

				var valley:BGSprite = new BGSprite('taiscnuckles/Campo', -953, -293, .5, .5);
				valley.scale.set(2, 2);
				add(valley);

				if (!ClientPrefs.lowQuality)
				{
					var plane:BGSprite = new BGSprite('taiscnuckles/Avion', -953, -293, .6, .6);
					plane.scale.set(2, 2);
					add(plane);
				}

				var leafes:BGSprite = new BGSprite('taiscnuckles/Hojas', -953, -293, .7, .7);
				leafes.scale.set(2, 2);
				add(leafes);

				var floor:BGSprite = new BGSprite('taiscnuckles/Piso', -953, -293, 1, 1);
				floor.scale.set(2, 2);
				add(floor);

			case 'tm':
				GameOverSubstate.characterName = 'bf-tm';
				GameOverSubstate.deathSoundName = 'real_fnf_loss_nomic';

				var sky:BGSprite = new BGSprite('chilli/Cielo', -350, -243, .3, .3);
				add(sky);

				var mountains:BGSprite = new BGSprite('chilli/MONTANA', -176, -104, .5, .5);
				add(mountains);

				var river:BGSprite = new BGSprite('chilli/agua_de_ugu', 72, 632, .7, .7);
				add(river);

				var floor:BGSprite = new BGSprite('chilli/SUELOANA', 65, 935, 1, 1);
				add(floor);

			case 'chile':
				GameOverSubstate.characterName = 'wea';
				GameOverSubstate.deathSoundName = 'chile_sonic_loss';

				var bg:BGSprite = new BGSprite('chile/chile_bg', -575, -713);
				bg.scale.set(1.3,1.3);
				add(bg);

				curStepSection = function()
				{
					if(Paths.formatToSongPath(SONG.song) == 'pico')
					{
						switch(curStep)
						{
							case 1:
								var tweenHUD:FlxTween = FlxTween.tween(camHUD, {alpha: 0}, 1.5 / initialPlaybackRate);
								var tweenNot:FlxTween = FlxTween.tween(camNotes, {alpha: 0}, 1.5 / initialPlaybackRate);
								eventTweens.push(tweenHUD);
								eventTweens.push(tweenNot);
							case 124:
								var tweenHUD:FlxTween = FlxTween.tween(camHUD, {alpha: 1}, .5 / initialPlaybackRate);
								var tweenNot:FlxTween = FlxTween.tween(camNotes, {alpha: 1}, .5 / initialPlaybackRate);
								eventTweens.push(tweenHUD);
								eventTweens.push(tweenNot);
							case 1408:
								var t1:FlxTween = null;
								var t2:FlxTween = null;
								var tweenHUD:FlxTween = FlxTween.tween(camHUD, {alpha: 0}, 1 / initialPlaybackRate);
								for(strum in opponentStrums.members)
								t1 = FlxTween.tween(strum, {alpha: 0}, 1 / initialPlaybackRate);
								for(strum in playerStrums.members)
								t2 = FlxTween.tween(strum, {alpha: 0}, 1 / initialPlaybackRate);
								eventTweens.push(tweenHUD);
								eventTweens.push(t1);
								eventTweens.push(t2);
							case 1540:
								var t:FlxTween = null;
								for(strum in playerStrums.members)
								t = FlxTween.tween(strum, {alpha: ClientPrefs.noteTransparencySoniNose}, .7 / initialPlaybackRate);
								eventTweens.push(t);
							case 1648:
								var ts:FlxTween = null;
								for(strum in playerStrums.members)
								ts = FlxTween.tween(strum, {alpha: 0}, .3 / initialPlaybackRate);
								eventTweens.push(ts);
							case 1664: 
								var t1:FlxTween = null;
								var t2:FlxTween = null;
								var tweenHUD:FlxTween = FlxTween.tween(camHUD, {alpha: 1}, 1 / initialPlaybackRate);
								for(strum in opponentStrums.members)
								t1 = FlxTween.tween(strum, {alpha: isMiddlescroll ? ClientPrefs.opponentStrums ? 0.35 : 0 : ClientPrefs.opponentStrums ? ClientPrefs.noteTransparencySoniNose : 0}, 1 / initialPlaybackRate);
								for(strum in playerStrums.members)
								t2 = FlxTween.tween(strum, {alpha: ClientPrefs.noteTransparencySoniNose}, 1 / initialPlaybackRate);
								eventTweens.push(tweenHUD);
								eventTweens.push(t1);
								eventTweens.push(t2);
						}
					}
				}
			
			case 'halloween':
				precacheList.set('backgrounds/halloween/pianoekis', 'image');
				precacheList.set('backgrounds/halloween/BG_Anim', 'image');
				precacheList.set('backgrounds/halloween/Moon_Corrida', 'image');
				precacheList.set('backgrounds/halloween/Bg_S', 'image');
				precacheList.set('backgrounds/events/spotlight', 'image');

				GameOverSubstate.characterName = 'tais_amongus';
				GameOverSubstate.deathSoundName = 'nuevo_tais_muere_normal';

				var calavera:CalaveraBG = null;
				var moonRun:BGSprite = null;
				var minAlpha:Float = 1;
				var maxAlpha:Float = 1;

				var azu:BGSprite = new BGSprite(null, -500, -1500, 0, 0);
				azu.makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 2), 0xff000033);
				azu.screenCenter();
				add(azu);

				var sky:BGSprite = new BGSprite('halloween/BG_', -279, -150, .7, .7);
				var skyIntro:BGSprite = new BGSprite('halloween/BG_', -279, sky.y-970, .7, .7);
				add(skyIntro);
				add(sky);

				var luna:BGSprite = new BGSprite('halloween/moon', skyIntro.x+40, skyIntro.y, .7, .7);
				add(luna);

				var skyRun:BGSprite = new BGSprite('halloween/Bg_S', -27, -45, .7, .7);
				skyRun.visible = false;
				skyRun.active = false;
				add(skyRun);

				if(!ClientPrefs.lowQuality)
				{
					moonRun = new BGSprite('halloween/Moon_Corrida', 1097, 88, .8, .8, ['Moon'], true);
					moonRun.dance();
					moonRun.visible = false;
					moonRun.active = false;
					add(moonRun);
				}

				var rayoAtras:BGSprite = new BGSprite(null, -500, -400, 0, 0);
				rayoAtras.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				rayoAtras.alpha = 0;
				rayoAtras.blend = ADD;
				add(rayoAtras);

				var callejon:BGSprite = new BGSprite('halloween/Callejon', 133-55, -80-156, .9, 1);
				callejon.scale.set(1.05, 1.05);
				add(callejon);

				var casa:BGSprite = new BGSprite('halloween/frent_Casa', -307, -114-373, .95, 1);
				add(casa);

				if(!ClientPrefs.lowQuality)
				{
					calavera = new CalaveraBG(1164, 269);
					calavera.scrollFactor.set(.95,1);
					add(calavera);
				}

				var asfalto:BGSprite = new BGSprite('halloween/Frente', -340, 422, 1, 1);
				add(asfalto);

				var bgRun:BGSprite = new BGSprite('halloween/BG_Anim', 0, 0, .9, .9, ['BG_Anim'], true);
				bgRun.dance();
				bgRun.visible = false;
				bgRun.active = false;
				add(bgRun);

				var daStatic:FlxSprite = new FlxSprite();
				daStatic.frames = Paths.getSparrowAtlas('daSTAT', 'shared');
				daStatic.setGraphicSize(FlxG.width, FlxG.height);
				daStatic.alpha = 0;
				daStatic.screenCenter();
				daStatic.scrollFactor.set();
				daStatic.animation.addByPrefix('static', 'staticFLASH', 24, true);
				add(daStatic);
				daStatic.animation.play('static');

				var rayoDelante:BGSprite = new BGSprite(null, -500, -400, 0, 0);
				rayoDelante.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				rayoDelante.alpha = 0;
				rayoDelante.blend = ADD;

				onCreatePost = function()
				{
					add(rayoDelante);

					if(camFollow != null)
					{
						snapCamFollowToPos(skyIntro.getGraphicMidpoint().x,skyIntro.getGraphicMidpoint().y-200);
						isCameraOnForcedPos = true;
						camPosicioning = true;
					}

					camHUD.visible = false;
					camNotes.visible = false;
					camZoomingMult = 0;

					iconP1.flipX = true;
					iconP2.flipX = true;
					healthBar.flipX = true;
					if(gfGroup != null) gfGroup.alpha = 0.000000000001;

					for(i in 0...4)
					{
						trace('xP$i: ' + playerStrums.members[i].x);
						trace('xO$i: ' + opponentStrums.members[i].x);
					}
				}

				changeBG = function()
				{
					azu.alpha = 1;
					daStatic.alpha = 0;
					dad.alpha = 1;
					camHUD.alpha = 1;
					for(strum in opponentStrums.members) strum.alpha = isMiddlescroll ? ClientPrefs.opponentStrums ? 0.35 : 0 : ClientPrefs.opponentStrums ? ClientPrefs.noteTransparencySoniNose : 0;
					var objs:Array<FlxSprite> = [sky,luna,callejon,casa,calavera,asfalto,thingiLight];
					for(obj in objs)
					{
						if(obj != null)
						{
							obj.kill();
							remove(obj);
							obj.destroy();
						}
					}
					
					var objsR:Array<BGSprite> = [skyRun,moonRun,bgRun];
					for(obj in objsR)
					{
						if(obj != null)
						{
							obj.active = true;
							obj.visible = true;
						}
					}

					GameOverSubstate.characterName = 'tais_corrida';
					GameOverSubstate.deathSoundName = 'tais_muere';

					dadGroup.x = 855;
					dadGroup.y = 235;
					gfGroup.x = 966;
					gfGroup.y = 215;
					boyfriendGroup.x = 176;
					boyfriendGroup.y = 312;

					defaultCamZoom = 1;
					FlxG.camera.zoom = 1;
					iconP1.flipX = false;
				}

				curStepSection = function()
				{
					switch(curStep)
					{
						case 114:
							defaultCamZoom = .9;
							camFollow.set(casa.getGraphicMidpoint().x,casa.getGraphicMidpoint().y);
						case 128:
							camZoomingMult = 1.5;
							isCameraOnForcedPos = false;
							camPosicioning = false;
							var shit:Array<FNFCamera> = [camHUD, camNotes];
							for (cam in shit)
							{
								cam.alpha = 0.00000001;
								cam.visible = true;
								var t:FlxTween = FlxTween.tween(cam, {alpha: 1}, 1 / initialPlaybackRate);
								eventTweens.push(t);
							}
						case 1424:
							var zoomTween = FlxTween.num(defaultCamZoom, 1.2, 28.64 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								defaultCamZoom = v;
							});
							eventTweens.push(zoomTween);
						case 1472:
							var alphaTween = FlxTween.num(dad.alpha, 0, 5.14 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(camHUD.alpha, 0, 5.14 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								camHUD.alpha = v;
							});
							eventTweens.push(alphaTween);

							for(strum in opponentStrums.members)
							{
								var alphaTween = FlxTween.num(strum.alpha, 0, 5.14 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
								{
									strum.alpha = v;
								});
								eventTweens.push(alphaTween);
							}
						case 1536:
							var objs:Array<FlxSprite> = [azu,sky,luna,callejon,casa,calavera,asfalto];
							for(obj in objs)
							{
								if(obj != null)
								{
									var alphaTween = FlxTween.num(obj.alpha, 0, 10.27 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
									{
										obj.alpha = v;
									});
									eventTweens.push(alphaTween);
								}
							}
						case 1600:
							thingiLight = new BGSprite('events/spotlight', 400, -400);
							thingiLight.setPosition(boyfriend.getGraphicMidpoint().x - thingiLight.width / 2, boyfriend.y + boyfriend.height - thingiLight.height + 50);
							thingiLight.alpha = 0;
							thingiLight.blend = ADD;
							add(thingiLight);

							var alphaTween = FlxTween.num(thingiLight.alpha, .375, 10.27 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								thingiLight.alpha = v;
							});
							eventTweens.push(alphaTween);
						case 1664:
							var alphaTween = FlxTween.num(daStatic.alpha, .05, 10 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								daStatic.alpha = v;
							});
							eventTweens.push(alphaTween);
						case 1984:
							var alphaTween = FlxTween.num(dad.alpha, .75, 5.14 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(gf.alpha, .75, 5.14 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								gf.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .65;
							maxAlpha = .85;
						case 2296:
							var alphaTween = FlxTween.num(boyfriend.alpha, 0, .7 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								boyfriend.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(gf.alpha, .9, .7 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								gf.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(dad.alpha, .5, .7 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .5;
							maxAlpha = .9;

							var objs:Array<BGSprite> = [azu,skyRun,moonRun,bgRun];
							for(obj in objs)
							{
								if(obj != null)
								{
									var alphaTween = FlxTween.num(obj.alpha, .3, .7 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
									{
										obj.alpha = v;
									});
									eventTweens.push(alphaTween);
								}
							}

							var alphaTween = FlxTween.num(daStatic.alpha, .05, .7 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								daStatic.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(camHUD.alpha, 0, .7 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								camHUD.alpha = v;
							});
							eventTweens.push(alphaTween);
						case 2424:
							var alphaTween = FlxTween.num(dad.alpha, .7, .6 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .65;
						case 2452:
							var alphaTween = FlxTween.num(dad.alpha, .5, .5 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .5;
						case 2480:
							var alphaTween = FlxTween.num(gf.alpha, .8, .175 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								gf.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(dad.alpha, .7, .175 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .65;
							maxAlpha = .85;
						case 2483:
							var alphaTween = FlxTween.num(gf.alpha, .9, .175 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								gf.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(dad.alpha, .5, .175 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .5;
							maxAlpha = .9;
						case 2544:
							var alphaTween = FlxTween.num(gf.alpha, .8, .35 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								gf.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(dad.alpha, .7, .35 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .6;
							maxAlpha = .8;
						case 2550:
							var alphaTween = FlxTween.num(gf.alpha, .75, .175 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								gf.alpha = v;
							});
							eventTweens.push(alphaTween);

							var alphaTween = FlxTween.num(dad.alpha, .75, .175 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								dad.alpha = v;
							});
							eventTweens.push(alphaTween);

							minAlpha = .65;
							maxAlpha = .85;

							var objs:Array<BGSprite> = [azu,skyRun,moonRun,bgRun];
							for(obj in objs)
							{
								if(obj != null)
								{
									var alphaTween = FlxTween.num(obj.alpha, .5, .3 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
									{
										obj.alpha = v;
									});
									eventTweens.push(alphaTween);
								}
							}

							var alphaTween = FlxTween.num(daStatic.alpha, .005, .3 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								daStatic.alpha = v;
							});
							eventTweens.push(alphaTween);
						case 2668:
							var objs:Array<BGSprite> = [azu,skyRun,moonRun,bgRun];
							for(obj in objs)
							{
								if(obj != null)
								{
									var alphaTween = FlxTween.num(obj.alpha, .7, .3 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
									{
										obj.alpha = v;
									});
									eventTweens.push(alphaTween);
								}
							}

							var alphaTween = FlxTween.num(daStatic.alpha, .0005, .3 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								daStatic.alpha = v;
							});
							eventTweens.push(alphaTween);
						case 2752:
							var objs:Array<BGSprite> = [azu,skyRun,moonRun,bgRun];
							for(obj in objs)
							{
								if(obj != null)
								{
									var alphaTween = FlxTween.num(obj.alpha, .9, .3 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
									{
										obj.alpha = v;
									});
									eventTweens.push(alphaTween);
								}
							}

							var alphaTween = FlxTween.num(daStatic.alpha, .00005, .3 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								daStatic.alpha = v;
							});
							eventTweens.push(alphaTween);
						case 2820:
							var objs:Array<BGSprite> = [azu,skyRun,moonRun,bgRun];
							for(obj in objs)
							{
								if(obj != null)
								{
									var alphaTween = FlxTween.num(obj.alpha, 1, .9 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
									{
										obj.alpha = v;
									});
									eventTweens.push(alphaTween);
								}
							}

							var alphaTween = FlxTween.num(daStatic.alpha, 0, .9 / initialPlaybackRate, {ease: FlxEase.linear}, function(v:Float)
							{
								daStatic.alpha = v;
							});
							eventTweens.push(alphaTween);
					}
				}

				// lazy code
				onStartCountdown = function()
				{
					if(!isMiddlescroll)
					{
						var strumsPosP:Array<Float> = 
						[
							playerStrums.members[0].x, 
							playerStrums.members[1].x,
							playerStrums.members[2].x,
							playerStrums.members[3].x
						];
						var strumsPosO:Array<Float> = 
						[
							opponentStrums.members[0].x, 
							opponentStrums.members[1].x,
							opponentStrums.members[2].x,
							opponentStrums.members[3].x
						];

						for (i in 0...4)
						{
							playerStrums.members[i].x = strumsPosO[i];
							opponentStrums.members[i].x = strumsPosP[i];
						}
					}
				}

				songEvent = function(v1,v2)
				{
					if(v1 == 'skull')
					{
						if(!ClientPrefs.lowQuality)
						{
							if(calavera != null) calavera.scream();
						}
					}

					if(v1 == 'piano')
					{
						if(!ClientPrefs.lowQuality)
						{
							var piano:FlxSprite = new FlxSprite(asfalto.x+FlxG.random.float(0,1478), asfalto.y-1350);
							piano.frames = Paths.getSparrowAtlas('backgrounds/halloween/pianoekis');
							piano.animation.addByIndices('idle', 'piano ekisd', [0], '', 0, false);
							piano.animation.addByIndices('ekis', 'piano ekisd', [1], '', 0, false);
							piano.animation.play('idle');
							piano.scrollFactor.set(.95,.95);
							piano.antialiasing = ClientPrefs.globalAntialiasing;
							addBehindGF(piano);

							var pTween = FlxTween.tween(piano, {y: asfalto.y - 168}, .3 / initialPlaybackRate, {ease: FlxEase.quadIn, onComplete: (twn)->{
								piano.animation.play('ekis');
								var pTimer = new FlxTimer().start(.3 / initialPlaybackRate, (tmr)->{
									FlxFlicker.flicker(piano, .3 / initialPlaybackRate, .05 / initialPlaybackRate, false, false, (flick)->{
										piano.kill();
										remove(piano);
										piano.destroy();
									});
								});
								eventTimers.push(pTimer);
							}});
							eventTweens.push(pTween);
						}
					}

					if(v1 == 'pum')
					{
						if (ClientPrefs.camZooms)
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.03;
							camNotes.zoom += 0.03;
				
							if (!camZooming)
							{
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5 / initialPlaybackRate);
								FlxTween.tween(camHUD, {zoom: 1}, 0.5 / initialPlaybackRate);
								FlxTween.tween(camNotes, {zoom: 1}, 0.5 / initialPlaybackRate);
							}
						}
					
						if (ClientPrefs.flashing)
						{
							rayoDelante.alpha = .4;
							FlxTween.tween(rayoDelante, {alpha: .5}, .075 / initialPlaybackRate);
							FlxTween.tween(rayoDelante, {alpha: 0}, .25 / initialPlaybackRate, {startDelay: .15 / initialPlaybackRate});

							rayoAtras.alpha = .4;
							FlxTween.tween(rayoAtras, {alpha: .5}, .075 / initialPlaybackRate);
							FlxTween.tween(rayoAtras, {alpha: 0}, .35 / initialPlaybackRate, {startDelay: .15 / initialPlaybackRate});
						}
					}

					if(v1 == 'swap')
					{
						var strumsPos:Array<Float> = 
						[
							416, 
							528,
							640,
							752
						];
		
						for(i in 0...4)
						{
							FlxTween.tween(playerStrums.members[i], {x: strumsPos[i], angle: isMiddlescroll ? 0 : 360}, {ease: FlxEase.quartOut});
							FlxTween.tween(opponentStrums.members[i], {x: strumsPos[i], angle: 360, alpha: ClientPrefs.opponentStrums ? .35 : 0}, {ease: FlxEase.quartOut});
						}
					}
				}

				var camRandMovX:Float = 0;
				var camRandMovY:Float = 0;
				onUpdate = function(stageElapsed)
				{
					if(!ClientPrefs.lowQuality) 
					{
						if(dad.curCharacter == 'soni_apk_flying' || dad.curCharacter == 'soni_apk_corrida')
						{
							var fakeCurBeat = ((Conductor.songPosition / 10000) * (SONG.bpm / 60)) / 10;
							dad.y += Math.cos((fakeCurBeat*10.55) * Math.PI) / 20;
							if(SONG.notes[curSection] != null && !SONG.notes[curSection].mustHitSection)
							{
								if(curStep >= 128)
								{
									camFollow.set(dad.getMidpoint().x + 150 + dad.cameraPosition[0], dad.getMidpoint().y - 100 + dad.cameraPosition[1]);
									if(shittyShitAssOpponent[0] != 0) camFollow.x = shittyShitAssOpponent[0]; 
									if(shittyShitAssOpponent[1] != 0) camFollow.y = shittyShitAssOpponent[1]; 
								}
							}
						}
						if(gf.curCharacter == 'soni_corrida')
						{
							var fakeCurBeat = ((Conductor.songPosition / 10000) * (SONG.bpm / 60)) / 10;
							gf.y += Math.cos((fakeCurBeat*10.55) * Math.PI) / 20;
							if(SONG.notes[curSection] != null && SONG.notes[curSection].mustHitSection)
							{
								if(curStep >= 2296)
								{
									camFollow.set(dad.getMidpoint().x + 150 + dad.cameraPosition[0], dad.getMidpoint().y - 100 + dad.cameraPosition[1]);
									if(shittyShitAssOpponent[0] != 0) camFollow.x = shittyShitAssOpponent[0]; 
									if(shittyShitAssOpponent[1] != 0) camFollow.y = shittyShitAssOpponent[1]; 
								}
							}
						}
						if(curStep < 114)
						{
							if(camFollow != null)
							{
								var fakeCurBeat = ((Conductor.songPosition / 10000) * (SONG.bpm / 60)) / 10;
								camRandMovX += Math.cos((fakeCurBeat*10.55) * Math.PI) / 20;
								camRandMovY += Math.sin((fakeCurBeat*10.55) * Math.PI) / 20;
								camFollow.set(skyIntro.getGraphicMidpoint().x+camRandMovX, (skyIntro.getGraphicMidpoint().y-200)+camRandMovY);
								isCameraOnForcedPos = true;
								camPosicioning = true;
							}
						}
						if(curStep >= 2048)
						{
							var fakeCurBeat = ((Conductor.songPosition / 10000) * (SONG.bpm / 60)) / 10;
							if(dad.alpha > maxAlpha) dad.alpha -= 0.9;
							else if(dad.alpha < minAlpha) dad.alpha += 0.9;
							if(gf.alpha > maxAlpha) dad.alpha -= 0.9;
							else if(gf.alpha < minAlpha) dad.alpha += 0.9;
						}
					}
				}

				onUpdatePost = function(stageElapsed)
				{
					var p1Mult:Float = healthBar.x + ((healthBar.width * healthBar.percent * 0.01) + (150 * iconP1.scale.x - 150) / 2 - 26);
					var p2Mult:Float = healthBar.x + ((healthBar.width * healthBar.percent * 0.01) - (150 * iconP2.scale.x) / 2 - 26 * 2);
					iconP1.x = p1Mult - 110;
					iconP1.origin.x = 240;
					iconP2.x = p2Mult + 110;
					iconP2.origin.x = -100;
				}

			case 'avion':
				var bg:BGSprite = new BGSprite('avion/sky coso nose', -615, -305, .3, .3);
				add(bg);

				var nubesDetras:FlxTypedGroup<BGSprite> = new FlxTypedGroup<BGSprite>();
				add(nubesDetras);
				for(i in [FlxG.random.int(1,4),FlxG.random.int(1,4),FlxG.random.int(1,4),FlxG.random.int(1,4)]) //lmao
				{
					var nube:BGSprite = new BGSprite('avion/Nube $i', FlxG.random.float(-1850,2750), FlxG.random.float(-465,70), FlxG.random.float(.4,.6), FlxG.random.float(.4,.6));
					nubesDetras.add(nube);
				}

				var montanas:FlxTypedGroup<BGSprite> = new FlxTypedGroup<BGSprite>();
				add(montanas);
				for(i in [FlxG.random.int(1,2),FlxG.random.int(1,2),FlxG.random.int(1,2)])
				{
					var montana:BGSprite = new BGSprite('avion/montana $i', FlxG.random.float(-1850,2750), FlxG.random.float(840,970), FlxG.random.float(.5,.7), FlxG.random.float(.5,.7));
					montana.alpha = .99; // sory
					trace(montana.alpha);
					montanas.add(montana);
				}

				var nubesDelante:FlxTypedGroup<BGSprite> = new FlxTypedGroup<BGSprite>();
				onCreatePost = function()
				{
					add(nubesDelante);
					for(i in [FlxG.random.int(1,4),FlxG.random.int(1,4)])
					{
						var nube:BGSprite = new BGSprite('avion/Nube $i', FlxG.random.float(-1850,2750), FlxG.random.float(350,840), FlxG.random.float(1.1,1.3), FlxG.random.float(1.1,1.3));
						nube.alpha = .5;
						nube.scale.set(1.5,1.5);
						nube.blend = ADD;
						nubesDelante.add(nube);
					}
				}

				var linearVelocity:Array<Float> = [FlxG.random.float(10,15),FlxG.random.float(10,15),FlxG.random.float(10,15),FlxG.random.float(10,15),FlxG.random.float(10,15),FlxG.random.float(10,15)];
				function cosasMovimiento(obj:BGSprite, itenator:Int)
				{
					if(obj != null)
					{
						var randY:Float = 0;
						var randScroll:Float = .3;
						switch(obj.alpha) // im so fucking tired lmao
						{
							case 1:
								randY = FlxG.random.float(-465,70);
								randScroll = FlxG.random.float(.4,.6);
							case .99:
								randY = FlxG.random.float(840,970);
								randScroll = FlxG.random.float(.5,.7);
							case .5:
								randY = FlxG.random.float(350,840);
								randScroll = FlxG.random.float(1.1,1.3);
						}
						obj.x = FlxG.random.float(2100,2750);
						obj.y = randY;
						obj.scrollFactor.set(randScroll,randScroll);
						linearVelocity[itenator] = FlxG.random.float(10,15);
					}
				}

				var camRandMovX:Float = 0;
				var camRandMovY:Float = 0;
				onUpdate = function(elapsed)
				{
					/*if(camFollow != null)
					{
						var fakeCurBeat = ((Conductor.songPosition / 10000) * (SONG.bpm / 60)) / 10;
						camRandMovX += Math.cos((fakeCurBeat*10.55) * Math.PI) / 20;
						camRandMovY += Math.sin((fakeCurBeat*10.55) * Math.PI) / 20;
						camFollow.x += camRandMovX;
						camFollow.y += camRandMovY;
					}*/

					var objs = [nubesDetras,montanas,nubesDelante];
					for(obj in objs)
					{
						if(obj != null)
						{
							for(i in 0...obj.members.length)
							{
								obj.members[i].x -= linearVelocity[i]; //Velocity.x doesn't work
								if(obj.members[i].x < FlxG.random.float(-1850,-1500))
								{
									cosasMovimiento(obj.members[i], i);
								}
							}
						}
					}
				}

				//FlxG.camera.angleFix = false;
				/*function angleTween()
				{
					var thisTween = FlxTween.tween(FlxG.camera, {angle: -2}, 5, {onComplete: (twn)->
						{var thisOtherTween = FlxTween.tween(FlxG.camera, {angle: 2}, 5, {onComplete: (twn)->{
							angleTween();}}); eventTweens.push(thisOtherTween);}});
					eventTweens.push(thisTween);
				}
				angleTween();*/ //forget that lol

			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if (!ClientPrefs.lowQuality)
				{
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
		}
		FunnyGlowParticle.particleSufix = particleSufix;

		if (isPixelStage)
		{
			introSoundsSuffix = '-pixel';
		}

		if (Paths.formatToSongPath(SONG.song) != 'spines' || curStage != 'avion')
			add(gfGroup);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if ((!ClientPrefs.lowQuality || ClientPrefs.funnyShaders) && Paths.formatToSongPath(SONG.song) == 'broken-reality')
		{
			spriteTrail = new FlxTypedGroup<FlxSprite>();
			add(spriteTrail);
		}

		add(dadGroup);
		add(boyfriendGroup);
		if (Paths.formatToSongPath(SONG.song) == 'spines' || curStage == 'avion')
			add(gfGroup);

		switch (curStage)
		{
			case 'street':
				if (!ClientPrefs.lowQuality)
				{
					dyy = new BGSprite('jpvsroyal/DyY', 830, 590, 1.1, 1.1, ['DyY']);
					dyy.dance();
					add(dyy);

					lyd = new BGSprite('jpvsroyal/LyD', -407, 595, 1.1, 1.1, ['LyD']);
					lyd.dance();
					add(lyd);

					var missing:BGSprite = new BGSprite('jpvsroyal/Missing', 1333, -267, 1.2, 1.2);
					add(missing);
				}

				onStartCountdown = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
						{
							bmmo.dance(true);
							mymanuel.dance(true);
							syj.dance(true);
							dyy.dance(true);
							lyd.dance(true);
						}
				}

				curBeatSection = function()
				{
					if (!ClientPrefs.lowQuality)
						if (curBeat % 2 == 0)
						{
							bmmo.dance(true);
							mymanuel.dance(true);
							syj.dance(true);
							dyy.dance(true);
							lyd.dance(true);
						}
				}
			case 'forest':
				if (!ClientPrefs.lowQuality)
				{
					var nose:BGSprite = new BGSprite('apk/Yokse2', -1595, -820, 1.3, 1.3);
					nose.scale.set(1.7, 1.7);
					add(nose);

					var leafs:BGSprite = new BGSprite('apk/HOJAScccc1', -1150, -820, 1.5, 1.5);
					leafs.scale.set(1.7, 1.7);
					add(leafs);
				}
			case 'shawn':
				if (!ClientPrefs.lowQuality)
				{
					var bridge:BGSprite = new BGSprite('shawn/Puente_pelotudo', -610, -405, 1.2, 1.2);
					add(bridge);
				}
			case 'jungle':
				if (!ClientPrefs.lowQuality)
				{
					var lianas:BGSprite = new BGSprite('taiscnuckles/Lianas', -953, -293, 1.2, 1.2);
					lianas.scale.set(2, 2);
					add(lianas);
				}
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if (curStage == 'philly')
		{
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		if (!modchartSprites.exists('blammedLightsBlack'))
		{ // Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if (members.indexOf(boyfriendGroup) < position)
			{
				position = members.indexOf(boyfriendGroup);
			}
			else if (members.indexOf(dadGroup) < position)
			{
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if (curStage == 'philly')
			insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}

		switch (curStage)
		{
			case 'werhog' | 'ou' | 'idk-lol' | 'nft' | 'park' | 'toystage' | 'jungle':
				if (Paths.formatToSongPath(SONG.song) != 'dynamic-duo')
					stageData.hide_girlfriend = true;
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			if (Paths.formatToSongPath(SONG.song) != 'spines')
				gf.scrollFactor.set(0.95, 0.95);
			else
				gf.scrollFactor.set(1.15, 1.15);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		if (curStage == 'stage')
		{
			taisHomr = new Boyfriend(0, 0, "tais");
			startCharacterPos(taisHomr);
			boyfriendGroup.add(taisHomr);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		if (curStage == 'grillby')
			changeBG();

		initialBF = boyfriend.curCharacter;
		initialDad = dad.curCharacter;
		if (gf != null)
			initialGF = gf.curCharacter;

		initialDSN = GameOverSubstate.deathSoundName;
		initialDSE = GameOverSubstate.endSoundName;
		initialDBF = GameOverSubstate.characterName;

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}
		else
		{
			camPos.x += dad.getGraphicMidpoint().x + dad.cameraPosition[0];
			camPos.y += dad.getGraphicMidpoint().y + dad.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		switch (curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); // nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);

			case 'forest':
				gf.visible = false;
		}

		if (dad.curCharacter == 'bil')
		{
			dadGroup.y -= 200; // real
			dadGroup.x -= 100;
		}

		var file:String = Paths.json(songName + '/dialogue'); // Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file))
		{
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); // Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file))
		{
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		GhostSprite.initialize();

		Conductor.songPosition = -5000 / Conductor.songPosition;

		aesthetic = new FlxSprite().loadGraphic(Paths.image('aesthetic'));
		aesthetic.scale.y = 1.3;
		aesthetic.visible = true;
		aesthetic.cameras = [camBars];
		aesthetic.screenCenter();
		aesthetic.antialiasing = ClientPrefs.globalAntialiasing;
		add(aesthetic);

		lyricsTxt = new FlxText(0, 0, Std.int(FlxG.width * 0.4), '', 30);
		lyricsTxt.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		lyricsTxt.antialiasing = false;
		lyricsTxt.alpha = ClientPrefs.lyricsAlpha;
		lyricsTxt.screenCenter();
		lyricsTxt.y += 150;
		lyricsTxt.cameras = [camLyrics];
		switch (ClientPrefs.lyricsColorr)
		{
			case 'White':
				lyricsTxt.color = FlxColor.WHITE;
			case 'Gray':
				lyricsTxt.color = FlxColor.GRAY;
			case 'Black':
				lyricsTxt.color = FlxColor.BLACK;
			case 'Green':
				lyricsTxt.color = FlxColor.GREEN;
			case 'Lime':
				lyricsTxt.color = FlxColor.LIME;
			case 'Yellow':
				lyricsTxt.color = FlxColor.YELLOW;
			case 'Orange':
				lyricsTxt.color = FlxColor.ORANGE;
			case 'Red':
				lyricsTxt.color = FlxColor.RED;
			case 'Purple':
				lyricsTxt.color = FlxColor.PURPLE;
			case 'Blue':
				lyricsTxt.color = FlxColor.BLUE;
			case 'Brown':
				lyricsTxt.color = FlxColor.BROWN;
			case 'Pink':
				lyricsTxt.color = FlxColor.PINK;
			case 'Magenta':
				lyricsTxt.color = FlxColor.MAGENTA;
			case 'Cyan':
				lyricsTxt.color = FlxColor.CYAN;
		}
		if(ClientPrefs.lyricsColorr == 'Black') lyricsTxt.borderColor = FlxColor.WHITE;
		else lyricsTxt.borderColor = FlxColor.BLACK;
		lyricsTxt.visible = !ClientPrefs.disableLyrics;
		add(lyricsTxt);

		strumLine = new FlxSprite(isMiddlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (isDownscroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();
		// trace(strumLine.y);

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (isDownscroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		if (Paths.formatToSongPath(SONG.song) == 'broken-reality')
		{
			timeBarBGFake = new AttachedSprite('timeBar');
			timeBarBGFake.x = timeTxt.x;
			timeBarBGFake.y = timeTxt.y + (timeTxt.height / 4);
			timeBarBGFake.scrollFactor.set();
			timeBarBGFake.visible = false;
			timeBarBGFake.color = FlxColor.BLACK;
			timeBarBGFake.xAdd = -4;
			timeBarBGFake.yAdd = -4;
			add(timeBarBGFake);

			timeBarFake = new FlxBar(timeBarBGFake.x + 4, timeBarBGFake.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBGFake.width - 8),
				Std.int(timeBarBGFake.height - 8), null, '', 0, 1);
			timeBarFake.scrollFactor.set();
			timeBarFake.numDivisions = 800;
			timeBarFake.visible = false;
			add(timeBarFake);
			timeBarBGFake.sprTracker = timeBarFake;
		}

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		// timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		startScript();

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if (isDownscroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'healthDisplay', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		if (Paths.formatToSongPath(SONG.song) != 'dynamic-duo')
			iconP2 = new HealthIcon(dad.healthIcon, false);
		else
			iconP2 = new HealthIcon('nuckles-sing', false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		if (Paths.formatToSongPath(SONG.song) == 'dynamic-duo')
			dad.healthColorArray = [225, 0, 56];
		reloadHealthBarColors();
		reloadTimeBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (isDownscroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camNotes];
		grpNoteSplashes.cameras = [camNotes];
		notes.cameras = [camNotes];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (Paths.formatToSongPath(SONG.song) == 'broken-reality')
		{
			timeBarFake.cameras = [camHUD];
			timeBarBGFake.cameras = [camHUD];
		}

		var centerP = new FlxSprite(0, 0);
		centerP.screenCenter(XY);

		center = FlxPoint.get(centerP.x, centerP.y);

		upscrollOffset = 50;
		downscrollOffset = FlxG.height - 150;

		startingSong = true;

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'dynamic-duo':
				precenseIcon = 'tais-n-nuckles';
			default:
				precenseIcon = iconP2.getCharacter();
		}

		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if ((isStoryMode || isCode) && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if (gf != null)
						gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});

				case 'senpai' | 'roses' | 'thorns':
					if (daSong == 'roses')
						FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				/*case 'impersonation':
					santiagoIntro(); */

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			// if(Paths.formatToSongPath(SONG.song) != 'impersonation')
			switch (daSong)
			{
				case 'impersonation':
					santiagoIntro();
				default:
					startCountdown();
			}
		}
		RecalculateRating();

		if (isStoryMode && WeekData.getCurrentWeek().songs[0][0] != curSong)
			setWeekProgress(curSong);

		if (Progression.weekProgress.exists(WeekData.getWeekFileName()) && WeekData.getCurrentWeek().songs[0][0] == curSong)
		{
			Progression.weekProgress.remove(WeekData.getWeekFileName());
			Progression.save();
		}

		// PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');
		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusicSoni != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusicSoni), 'music');
		}
		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		#if PRIVATE_BUILD
		DiscordClient.changePresence(detailsText, "CLASSIFIED", 'face');
		#else
		DiscordClient.changePresence(detailsText, SONG.song, precenseIcon);
		#end
		#end

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		/*from.x = guiSize.x/2;
			from.y = guiSize.y/2;

			for(note in notes.members) note.alpha = 0;

			jumpingNote = new FlxSprite(from.x, from.y);
			jumpingNote.frames = Paths.getSparrowAtlas("NOTE_assets_white", "shared");
			jumpingNote.animation.addByPrefix("arrow", "green", 1, true);
			jumpingNote.animation.play("arrow");
			jumpingNote.scale.set(0.7, 0.7);
			jumpingNote.updateHitbox();
			jumpingNote.antialiasing = ClientPrefs.globalAntialiasing;
			jumpingNote.cameras = [camNotes];

			coloredJumpingNote = new FlxSprite(from.x, from.y);
			coloredJumpingNote.frames = Paths.getSparrowAtlas("NOTE_assets_white", "shared");
			coloredJumpingNote.animation.addByPrefix("arrow", "green", 1, true);
			coloredJumpingNote.animation.play("arrow");
			coloredJumpingNote.scale.set(0.7, 0.7);
			coloredJumpingNote.updateHitbox();
			coloredJumpingNote.antialiasing = ClientPrefs.globalAntialiasing;
			coloredJumpingNote.cameras = [camNotes];
			coloredJumpingNote.alpha = 0;

			add(jumpingNote);
			add(coloredJumpingNote); */

		if(onCreatePost != null) onCreatePost();
		callOnLuas('onCreatePost', []);

		if (script != null)
		{
			script.executeFunc("onCreatePost");
		}

		// NOTE COMBO SHIT BY ROYAL (credits if is used pls)
		if (SONG.notes[curSection] != null)
			lastMustHit = SONG.notes[curSection].mustHitSection;
		/*var bX = BF_X/10+boyfriend.x/4;
			var bY = BF_Y/10+boyfriend.y/6+300; */
		if (!ClientPrefs.hideNoteCombo)
		{
			noteCombo = new NoteCombo();
			noteCombo.cameras = [camGame];
			noteCombo.scrollFactor.set();
			noteCombo.screenCenter();
			// noteCombo.x-=2;
			add(noteCombo);

			for (i in 1...3)
			{
				noteComboN1 = new FlxSprite();
				noteComboN1.frames = Paths.getSparrowAtlas('numbers');
				// noteComboN1.scrollFactor.set(.5,.5);
				noteComboN1.scale.set(0.99, 0.99);
				noteComboN1.x = noteCombo.x + 70 + 160 * i;
				noteComboN1.y = noteCombo.y + 110 - i * 50;
				for (j in 0...10)
				{
					noteComboN1.animation.addByPrefix(j + 'a', j + '_appear', 24, false);
					noteComboN1.animation.addByPrefix(j + 'd', j + '_disappear', 24, false);
				}
				// noteComboN1.updateHitbox();
				noteComboN1.visible = false;
				noteComboN1.active = false;
				noteComboN1.cameras = [camGame];
				noteComboN1.scrollFactor.set();
				noteComboN1.antialiasing = ClientPrefs.globalAntialiasing;
				add(noteComboN1);

				noteComboN2 = new FlxSprite();
				noteComboN2.frames = Paths.getSparrowAtlas('numbers');
				// noteComboN2.scrollFactor.set(.5,.5);
				noteComboN2.scale.set(0.99, 0.99);
				noteComboN2.x = noteComboN1.x - 450 + 2 * 160;
				noteComboN2.y = noteComboN1.y + 20;
				for (j in 0...10)
				{
					noteComboN2.animation.addByPrefix(j + 'a', j + '_appear', 24, false);
					noteComboN2.animation.addByPrefix(j + 'd', j + '_disappear', 24, false);
				}
				// noteComboN2.updateHitbox();
				noteComboN2.visible = false;
				noteComboN2.active = false;
				noteComboN2.cameras = [camGame];
				noteComboN2.scrollFactor.set();
				noteComboN2.antialiasing = ClientPrefs.globalAntialiasing;
				add(noteComboN2);

				noteComboN3 = new FlxSprite();
				noteComboN3.frames = Paths.getSparrowAtlas('numbers');
				// noteComboN3.scrollFactor.set(.5,.5);
				noteComboN3.scale.set(0.99, 0.99);
				noteComboN3.x = noteComboN2.x - 450 + 3 * 160;
				noteComboN3.y = noteComboN2.y + 20;
				for (j in 0...10)
				{
					noteComboN3.animation.addByPrefix(j + 'a', j + '_appear', 24, false);
					noteComboN3.animation.addByPrefix(j + 'd', j + '_disappear', 24, false);
				}
				// noteComboN3.updateHitbox();
				noteComboN3.visible = false;
				noteComboN3.active = false;
				noteComboN3.cameras = [camGame];
				noteComboN3.scrollFactor.set();
				noteComboN3.antialiasing = ClientPrefs.globalAntialiasing;
				add(noteComboN3);
			}
		}

		// Yes, im a clown
		/*defaultPlayerStrumX1 = playerStrums.members[0].x;
			defaultPlayerStrumX2 = playerStrums.members[1].x;
			defaultPlayerStrumX3 = playerStrums.members[2].x;
			defaultPlayerStrumX4 = playerStrums.members[3].x;

			defaultOpponentStrumX1 = opponentStrums.members[0].x;
			defaultOpponentStrumX2 = opponentStrums.members[1].x;
			defaultOpponentStrumX3 = opponentStrums.members[2].x;
			defaultOpponentStrumX4 = opponentStrums.members[3].x; */
		/*trace('op1: $defaultOpponentStrumX1');
			trace('op2: $defaultOpponentStrumX2');
			trace('op3: $defaultOpponentStrumX3');
			trace('op4: $defaultOpponentStrumX4');

			trace('pl1: $defaultPlayerStrumX1');
			trace('pl2: $defaultPlayerStrumX2');
			trace('pl3: $defaultPlayerStrumX3');
			trace('pl4: $defaultPlayerStrumX4'); */

		// plsWork(); it works B)
		// plsWork2(); it works 2 B)
		// plsWork3(); it works 3 B)
		// plsWork4(); doesn't work B(

		/*camHUD.alpha = 0;
			camNotes.alpha = 0; */

		// camNotes.pitch = 45;

		if (isDownscroll)
			directionThingi = 0.45;
		else
			directionThingi = -0.45;

		super.create();

		cacheCountdown();
		cachePopUpScore();
		cacheLetrero();
		for (key => type in precacheList)
		{
			// trace('Key $key is type $type');
			switch (type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		Paths.clearUnusedMemory();

		CustomFadeTransition.nextCamera = camOther;
	}

	function cacheLetrero()
	{
		switch(Paths.formatToSongPath(SONG.song))
		{
			case '3am':
				Paths.image('Mano_APK');
			case 'origishit':
				Paths.image('Letre_drawe');
			default:
				Paths.image('Letre');
		}
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.funnyShaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.funnyShaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		for(sound in countdownSounds) if(sound != null) sound.pitch = value;
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		if(script != null) script.setVariable('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor)
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText)
		{
			spr.y += 20;
		});

		if (luaDebugGroup.members.length > 34)
		{
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors()
	{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function reloadTimeBarColors()
	{
		timeBar.createFilledBar(FlxColor.TRANSPARENT, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));

		timeBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
		{
			for (lua in luaArray)
			{
				if (lua.scriptName == luaFile)
					return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool = true):FlxSprite
	{
		if (modchartObjects.exists(tag))
			return modchartObjects.get(tag);
		if (modchartSprites.exists(tag))
			return modchartSprites.get(tag);
		if (text && modchartTexts.exists(tag))
			return modchartTexts.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void
	{
	#if VIDEOS_ALLOWED
	var foundFile:Bool = false;
	var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
	#if sys
	if (FileSystem.exists(fileName))
	{
		foundFile = true;
	}
	#end

	if (!foundFile)
	{
		fileName = Paths.video(name);
		#if sys
		if (FileSystem.exists(fileName))
		{
		#else
		if (OpenFlAssets.exists(fileName))
		{
		#end
			foundFile = true;
		}
		} if (foundFile)
		{
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function()
			{
				remove(bg);
				startAndEnd();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			startAndEnd();
		}
		#end
		startAndEnd();
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if (endingSong)
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					endSong();
				}
			}
			else
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if (endingSong)
			{
				endSong();
			}
			else
			{
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('drawe', ['ready_drawe', 'set_drawe', 'go_drawe']);
		introAssets.set('chile', ['ready_chile', 'set_chile', 'go_chile']);
		introAssets.set('majin', ['ready_majin', 'set_majin', 'go_majin']);
		introAssets.set('grasa', ['ready_grasa', 'set_grasa', 'go_grasa']);
		introAssets.set('halloween', ['ready_halloween', 'set_halloween', 'go_halloween']);

		var introAlts:Array<String> = introAssets.get('default');
		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'origishit':
				introAlts = introAssets.get('drawe');
			case 'pico':
				introAlts = introAssets.get('chile');
			case '3am':
				introAlts = introAssets.get('halloween');
		}

		for (asset in introAlts) Paths.image(asset);

		var introSounds:Map<String, Array<String>> = new Map<String, Array<String>>();
		introSounds.set('default', ['Ruedi', 'Sett', 'Gou']);
		introSounds.set('drawe', ['rredi_drawe', 'setx_drawe', 'gou_drawe']);
		introSounds.set('devs', ['Ready_JP', 'Sext_JP', 'Go_JP']);
		introSounds.set('halloween', ['readi_halloween', 'sex_halloween', 'gou_halloween']);

		var introSound:Array<String> = introSounds.get('default');
		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'origishit':
				introSound = introSounds.get('drawe');
			case 'dev-troubles':
				introSound = introSounds.get('devs');
			case '3am':
				introSound = introSounds.get('halloween');
		}

		for (sound in introSound) Paths.sound(sound);

		Paths.image(curSong.toLowerCase() == 'origishit' ? 'Letre_drawe' : 'Letre');
	}

	public var countdownSounds:Array<FlxSound> = [];
	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			callOnLuas('onStartCountdown', []);
			if (script != null)
				script.executeFunc('onStartCountdown');
			return;
		}

		inCutscene = false;
		if (script != null)
			script.executeFunc('onStartCountdown');
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if (ret != FunkinLua.Function_Stop)
		{
			if (skipCountdown || startOnTime > 0)
				skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);

			for (i in 0...playerStrums.length)
			{
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				if (script != null)
				{
					script.setVariable('defaultPlayerStrumX' + i, playerStrums.members[i].x);
					script.setVariable('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				}
			}
			for (i in 0...opponentStrums.length)
			{
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if (script != null)
				{
					script.setVariable('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
					script.setVariable('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				}
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			if (script != null)
			{
				script.setVariable('startedCountdown', true);
				script.executeFunc("onCountdownStarted");
			}

			var swagCounter:Int = 0;

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0)
			{
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / initialPlaybackRate, function(tmr:FlxTimer)
			{
				if (gf != null
					&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
					&& !gf.stunned
					&& gf.animation.curAnim.name != null
					&& !gf.animation.curAnim.name.startsWith("sing")
					&& !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
					&& boyfriend.animation.curAnim != null
					&& !boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
					&& dad.animation.curAnim != null
					&& !dad.animation.curAnim.name.startsWith('sing')
					&& !dad.stunned)
				{
					dad.dance();
				}
				if (taisHomr != null
					&& tmr.loopsLeft % taisHomr.danceEveryNumBeats == 0
					&& taisHomr.animation.curAnim != null
					&& !taisHomr.animation.curAnim.name.startsWith('sing')
					&& !taisHomr.stunned)
				{
					taisHomr.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('drawe', ['ready_drawe', 'set_drawe', 'go_drawe']);
				introAssets.set('chile', ['ready_chile', 'set_chile', 'go_chile']);
				introAssets.set('majin', ['ready_majin', 'set_majin', 'go_majin']);
				introAssets.set('grasa', ['ready_grasa', 'set_grasa', 'go_grasa']);
				introAssets.set('halloween', ['ready_halloween', 'set_halloween', 'go_halloween']);

				var introAlts:Array<String> = introAssets.get('default');
				switch(Paths.formatToSongPath(SONG.song))
				{
					case 'origishit':
						introAlts = introAssets.get('drawe');
					case 'pico':
						introAlts = introAssets.get('chile');
					case '3am':
						introAlts = introAssets.get('halloween');
				}

				var introSounds:Map<String, Array<String>> = new Map<String, Array<String>>();
				introSounds.set('default', ['Ruedi', 'Sett', 'Gou']);
				introSounds.set('drawe', ['rredi_drawe', 'setx_drawe', 'gou_drawe']);
				introSounds.set('devs', ['Ready_JP', 'Sext_JP', 'Go_JP']);
				introSounds.set('halloween', ['readi_halloween', 'sex_halloween', 'gou_halloween']);

				var introSound:Array<String> = introSounds.get('default');
				switch(Paths.formatToSongPath(SONG.song))
				{
					case 'origishit':
						introSound = introSounds.get('drawe');
					case 'dev-troubles':
						introSound = introSounds.get('devs');
					case '3am':
						introSound = introSounds.get('halloween');
				}

				// head bopping for bg characters on Mall
				if (curStage == 'mall')
				{
					if (!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				if(onStartCountdown != null)
					onStartCountdown();

				switch (swagCounter)
				{
					case 0:

					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scale.set(FlxG.camera.zoom, FlxG.camera.zoom);
						countdownReady.screenCenter();
						countdownReady.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						insert(members.indexOf(notes), countdownReady);
						var readyTween:FlxTween = FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000 / initialPlaybackRate, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						eventTweens.push(readyTween);
						var readySound:FlxSound = new FlxSound().loadEmbedded(Paths.sound(introSound[0]));
						readySound.volume = 0.6;
						countdownSounds.push(readySound);
						readySound.play(true);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scale.set(FlxG.camera.zoom, FlxG.camera.zoom);
						countdownSet.screenCenter();
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						insert(members.indexOf(notes), countdownSet);
						var setTween:FlxTween = FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000 / initialPlaybackRate, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						eventTweens.push(setTween);
						var setSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound(introSound[1]));
						setSound.volume = 0.6;
						countdownSounds.push(setSound);
						setSound.play(true);
					case 3:
						if (!skipCountdown)
						{
							countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							countdownGo.scale.set(FlxG.camera.zoom, FlxG.camera.zoom);
							countdownGo.screenCenter();
							countdownGo.scrollFactor.set();

							if (PlayState.isPixelStage)
								countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

							countdownGo.updateHitbox();

							countdownGo.screenCenter();
							insert(members.indexOf(notes), countdownGo);
							var goTween:FlxTween = FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000 / initialPlaybackRate, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									remove(countdownGo);
									countdownGo.destroy();
								}
							});
							eventTweens.push(goTween);
							var goSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound(introSound[2]));
							goSound.volume = 0.6;
							countdownSounds.push(goSound);
							goSound.play(true);
						}
					case 4:
						songName();
						candisturb = true;
				}

				notes.forEachAlive(function(note:Note)
				{
					if (ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if (isMiddlescroll && !note.mustPress)
						{
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);
				if (script != null)
					script.executeFunc('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				if (modchartObjects.exists('note${daNote.ID}'))
					modchartObjects.remove('note${daNote.ID}');
				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				if (modchartObjects.exists('note${daNote.ID}'))
					modchartObjects.remove('note${daNote.ID}');
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue()
	{
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
		if (script != null)
			script.executeFunc('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue()
	{
		callOnLuas('onSkipDialogue', [dialogueCount]);
		if (script != null)
			script.executeFunc('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		#if PRIVATE_BUILD
		DiscordClient.changePresence(detailsText, "CLASSIFIED", 'face', true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
		#else
		DiscordClient.changePresence(detailsText, SONG.song, precenseIcon, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
		#end
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);

		if (script != null)
		{
			script.setVariable('songLength', songLength);
			script.executeFunc('onSongStart');
		}
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		Lib.application.window.title = 'Freaky Night With Soni - $curSong';

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		{
		#else
		if (OpenFlAssets.exists(file))
		{
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				swagNote.ID = unspawnNotes.length;
				modchartObjects.set('note${swagNote.ID}', swagNote);
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote,
							true);

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.ID = unspawnNotes.length;
						modchartObjects.set('note${sustainNote.ID}', sustainNote);
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if (isMiddlescroll)
						{
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}
				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (isMiddlescroll)
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypeMap.exists(swagNote.noteType))
				{
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) // Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	/*function soniCar()
	{
}*/ // LMAO
	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Epic Spotlight':
				thingiBlack = new BGSprite(null, -800, -400, 0, 0);
				thingiBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				thingiBlack.alpha = 0.25;
				thingiBlack.visible = false;
				add(thingiBlack);

				thingiLight = new BGSprite('events/spotlight', 400, -400);
				thingiLight.alpha = 0.375;
				thingiLight.blend = ADD;
				thingiLight.visible = false;

				thingiSmokes = new FlxSpriteGroup();
				thingiSmokes.alpha = 0.7;
				thingiSmokes.blend = ADD;
				thingiSmokes.visible = false;
				add(thingiLight);
				add(thingiSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('events/smoke', -1550 + offsetX, 880 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				thingiSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('events/smoke', 1550 + offsetX, 880 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				thingiSmokes.add(smoke);

			case 'Funny Glow':
				blammedLightsBlackForOther = new FlxSprite(FlxG.width * -0.5,
					FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlackForOther.visible = false;
				var position:Int = members.indexOf(gfGroup);
				if (curStage != 'park')
				{
					if (members.indexOf(boyfriendGroup) < position)
					{
						position = members.indexOf(boyfriendGroup);
					}
					else if (members.indexOf(dadGroup) < position)
					{
						position = members.indexOf(dadGroup);
					}
				}
				else
				{
					position = members.indexOf(floor);
				}
				insert(position, blammedLightsBlackForOther);

				funnyGlowGradient = new FunnyGlow.FunnyGlowGradient(-400, 225); // This shit was refusing to properly load FlxGradient so fuck it
				funnyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlackForOther) + 1, funnyGlowGradient);
				if (!ClientPrefs.flashing)
					funnyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('glowShit/particle$particleSufix', 'image'); // precache particle image
				funnyGlowParticles = new FlxTypedGroup<FunnyGlow.FunnyGlowParticle>();
				funnyGlowParticles.visible = false;
				insert(members.indexOf(funnyGlowGradient) + 1, funnyGlowParticles);

			case 'Sex Mod':
				precacheList.set('funny', 'image');
				funny = new FlxSprite().loadGraphic(Paths.image('funny'));
				funny.screenCenter();
				funny.antialiasing = ClientPrefs.globalAntialiasing;
				funny.alpha = 0;
				funny.cameras = [camOther];
				add(funny);

			case 'Spongebob':
				precacheList.set('cryaboutit', 'image');
		}

		if (!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float
	{
		if (script != null)
			script.executeFunc('eventEarlyTrigger', [event.event]);
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if (returnedValue != 0)
		{
			return returnedValue;
		}

		switch (event.event)
		{
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByStrum(wat:Int, Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.DESCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; // for lua

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = ClientPrefs.noteTransparencySoniNose;
			if (player < 1)
			{
				if (!ClientPrefs.opponentStrums)
					targetAlpha = 0;
				else if (isMiddlescroll)
					targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(isMiddlescroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = isDownscroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				// babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				modchartObjects.set("playerStrum" + i, babyArrow);
				playerStrums.add(babyArrow);
			}
			else
			{
				modchartObjects.set("opponentStrum" + i, babyArrow);
				if (isMiddlescroll)
				{
					babyArrow.x += 310;
					if (i > 1)
					{ // Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			for(sound in countdownSounds) if(sound != null) sound.pause();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null && songSpeedTween != null)
				songSpeedTween.active = false;

			if (blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if (letreroTween != null)
				letreroTween.active = false;
			if (letrero != null)
				letrero.active = false;
			if (textoLeTween != null)
				textoLeTween.active = false;
			if (letreroTimer != null)
				letreroTimer.active = false;
			if (phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if (isPause)
			{
				Lib.application.window.title = 'Freaky Night With Soni - ${curSong} - PAUSED';
				grayShader = new ColorMatrixFilter(pauseGray);
				if (Paths.formatToSongPath(SONG.song) != 'broken-reality' && Paths.formatToSongPath(SONG.song) != 'spines')
					pauseShad.push(grayShader);
				else
					filters.push(grayShader);
			}

			if (carTimer != null)
				carTimer.active = false;
			if (camTimer != null)
				camTimer.active = false;

			if (!ClientPrefs.hideNoteCombo)
				if (noteCombo != null)
					noteCombo.animation.pause();

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = false;
				}
			}

			for (tween in eventTweens)
			{
				tween.active = false;
			}
			for (timer in eventTimers)
			{
				timer.active = false;
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			Lib.application.window.title = 'Freaky Night With Soni - ${curSong}';

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			for(sound in countdownSounds) if(sound != null) sound.resume();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if (blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if (letreroTween != null)
				letreroTween.active = true;
			if (letrero != null)
				letrero.active = true;
			if (textoLeTween != null)
				textoLeTween.active = true;
			if (letreroTimer != null)
				letreroTimer.active = true;
			if (phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;

			if (isPause)
			{
				if (ClientPrefs.slowdownPause)
					pitchChange(initialPlaybackRate,1);
				if (Paths.formatToSongPath(SONG.song) != 'broken-reality' && Paths.formatToSongPath(SONG.song) != 'spines')
					pauseShad.remove(grayShader);
				else
					filters.remove(grayShader);
				isPause = false;
			}

			if (carTimer != null)
				carTimer.active = true;
			if (camTimer != null)
				camTimer.active = false;

			if (!ClientPrefs.hideNoteCombo)
				if (noteCombo != null)
					noteCombo.animation.resume();

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = true;
				}
			}

			for (tween in eventTweens)
			{
				tween.active = true;
			}
			for (timer in eventTimers)
			{
				timer.active = true;
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}
			for (timer in modchartTimers)
			{
				timer.active = true;
			}
			paused = false;
			if(onResume != null) onResume();
			callOnLuas('onResume', []);
			if (script != null)
				script.executeFunc('onResume');

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED", 'face', true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				#else
				DiscordClient.changePresence(detailsText, SONG.song, precenseIcon, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				#end
			}
			else
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED", 'face');
				#else
				DiscordClient.changePresence(detailsText, SONG.song, precenseIcon);
				#end
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (healthDisplay > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED", 'face', true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				#else
				DiscordClient.changePresence(detailsText, SONG.song, precenseIcon, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				#end
			}
			else
			{
				#if PRIVATE_BUILD
				DiscordClient.changePresence(detailsText, "CLASSIFIED", 'face');
				#else
				DiscordClient.changePresence(detailsText, SONG.song, precenseIcon);
				#end
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (healthDisplay > 0 && !paused && ClientPrefs.autoPause)
		{
			#if PRIVATE_BUILD
			DiscordClient.changePresence(detailsPausedText, "CLASSIFIED", 'face');
			#else
			DiscordClient.changePresence(detailsPausedText, SONG.song, precenseIcon);
			#end
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	private function cacheComboShit()
	{
		Paths.image('Note_kombo_soni');
		Paths.image('numbers');
	}

	public var paused:Bool = false;
	public var isPause:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var coverMeInPiss:Int;
	var disappearHits:Int;
	var stageElapsed:Float;

	override public function update(elapsed:Float)
	{
		callOnLuas('onUpdate', [elapsed]);
		if (script != null)
			script.executeFunc('onUpdate', [elapsed]);

		stageElapsed = elapsed;

		if (onUpdate != null)
			onUpdate(elapsed);

		/*notes.members.sort(function(a, b) {
			if (a.strumTime < b.strumTime) return -1;
			else if (a.strumTime > b.strumTime) return 1;
			else return 0;
		});

		if (notes.members.length <= 0) {
			jumpingNote.visible = false;
		} else {
			
			jumpingNote.visible = true && e;
			if (currentNote != notes.members[0]) {
				coloredJumpingNote.alpha = 1;
				from.x = to.x;
				from.y = to.y;
				from.angle = to.angle;
				if (currentNote != null) {
					from.time = currentNote.strumTime;
				}
				currentNote = notes.members[0];
				add360 = !add360;
				var dir = currentNote.noteData % playerStrums.length;
				str = currentNote.mustPress ? playerStrums.members[dir] : opponentStrums.members[dir];
				to.x = str.x;
				to.y = str.y;
				var angle = 0;
				if (dir == 0) angle = -90;
				if (dir == 1) angle = 180;
				if (dir == 3) angle = 90;
				to.angle = angle + (add360 ? 360 : -360);
				to.time = currentNote.strumTime;
				e = true;
			}
			var diff = to.time - from.time;
			var addY = (-Math.cos((Conductor.songPosition - from.time) / diff * Math.PI * 2) + 1) * (isDownscroll ? -200 : 200);
			
			jumpingNote.x = FlxMath.lerp(from.x, to.x, (Conductor.songPosition - from.time) / diff);
			jumpingNote.y = FlxMath.lerp(from.y, to.y, (Conductor.songPosition - from.time) / diff) + addY;
			jumpingNote.angle = FlxMath.lerp(from.angle, to.angle, (Conductor.songPosition - from.time) / diff);
			coloredJumpingNote.x = jumpingNote.x;
			coloredJumpingNote.y = jumpingNote.y;
			coloredJumpingNote.angle = jumpingNote.angle;
		}
		coloredJumpingNote.alpha = FlxMath.lerp(coloredJumpingNote.alpha, 0, 0.125 * elapsed * 60); */
		/*trace('gf x: ' + gf.getMidpoint().x);
		trace('gf y: ' + gf.getMidpoint().y);
		trace('sas x: ${dad.getMidpoint().x+150+dad.cameraPosition[0]}');
		trace('sas y: ${dad.getMidpoint().y-100+dad.cameraPosition[1]}'); */
		/*if(curStage == 'grillby')
		changeBG(); */ // Mas lag que mi hermana
		/*trace('x: ' + noteCombo.x);
		trace('y: ' + noteCombo.y); */

		// noteHits = 500;

		// trace(noteHits);
		if (!ClientPrefs.hideNoteCombo)
		{
			// var seperatedNoteHits:Array<Int> = [noteHits % 10, Math.floor(noteHits / 10) % 10, noteHits>=100 ? Math.floor(noteHits / 100) % 10 : 0];
			var num:Int = noteHits % 10;
			var num2:Int = Math.floor(noteHits / 10) % 10;
			var num3:Int = Math.floor(noteHits / 100) % 10;

			var disNum:Int = disappearHits % 10;
			var disNum2:Int = Math.floor(disappearHits / 10) % 10;
			var disNum3:Int = Math.floor(disappearHits / 100) % 10;
			// trace('1: $num 2: $num2 3: $num3');
			/*seperatedNoteHits.push(noteHits % 10);
			seperatedNoteHits.push(Math.floor(noteHits / 10) % 10);
			if(noteHits >= 100)
			{seperatedNoteHits.push(Math.floor(noteHits / 100) % 10);} */
			// trace(seperatedNoteHits);
			// trace(seperatedNoteHits[0]);
			if (SONG.notes[curSection] != null)
			{
				if (lastMustHit != SONG.notes[curSection].mustHitSection)
				{
					lastMustHit = SONG.notes[curSection].mustHitSection;
					if (!lastMustHit && noteHits > 12 && (curBeat % 4 == 0 || curBeat % 6 == 0))
					{
						noteCombo.playAnim('appear', true);

						noteComboN1.visible = true;
						noteComboN1.active = true;
						noteComboN1.animation.play(Std.string(num) + 'a');

						noteComboN2.visible = true;
						noteComboN2.active = true;
						// noteComboN2.x = noteComboN1.x-noteComboN2.width+70;
						noteComboN2.animation.play(Std.string(num2) + 'a');

						if (noteHits >= 100)
						{
							noteComboN3.visible = true;
							noteComboN3.active = true;
							// noteComboN3.x = noteComboN2.x-noteComboN2.width+70;
							noteComboN3.animation.play(Std.string(num3) + 'a');
						}
						else
						{
							noteComboN3.visible = false;
							noteComboN3.active = false;
						}

						disappearHits = noteHits;
						noteHits = 0;
					}
				}
			}

			noteCombo.animation.finishCallback = function(anim:String)
			{
				if (noteCombo.animation.curAnim.name == 'appear')
				{
					noteComboN1.animation.play('${Std.string(disNum)}d');
					noteComboN2.animation.play('${Std.string(disNum2)}d');
					if (noteComboN3.active)
					{
						noteComboN3.animation.play('${Std.string(disNum3)}d'); // more juicy
					}
				}
				else if (noteCombo.animation.curAnim.name == 'disappear')
				{
					noteComboN1.visible = false;
					noteComboN1.active = false;
					noteComboN2.visible = false;
					noteComboN2.active = false;
					if (noteComboN3.active)
					{
						noteComboN3.visible = false;
						noteComboN3.active = false;
					}
				}
			}
		}

		for(i in 0...notes.length-1)
		{
			if(notes.members[i].noteType == 'Miss Note')
			{
				//notes.members[i].lateNote = true;
				notes.members[i].canBeHit = false;	
			}
		}

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if (!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		/*if(Paths.formatToSongPath(SONG.song) == 'cheese' && ClientPrefs.funnyShaders)
		{
			filters.push(shader);
			filters.push(shader2);
	}*/
		/*for(i in 0...8)
		{
			if(FlxG.keys.pressed.X)
				strumLineNotes.members[i].z -= 0.001;
			else if(FlxG.keys.pressed.X)
				strumLineNotes.members[i].z += 0.001;
			trace(strumLineNotes.members[i].z);
	}*/

		if (#if PRIVATE_BUILD !TitleState.isDebug #else true #end)
		{
			if(!ClientPrefs.autoPause)
			{
				Application.current.window.onFocusOut.add(function()
				{
					focusing = false;
				}); // this pause the game when you minimize the window
				Application.current.window.onFocusIn.add(function()
				{
					focusing = true;
				});
			}
		}

		var comboStuff:Array<FlxSprite> = [noteCombo, noteComboN1, noteComboN2, noteComboN3];
		for(spr in comboStuff) if(spr != null) spr.alpha = camHUD.alpha;
		super.update(elapsed);

		//trace(playbackRate);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if(script != null)
		{
			script.setVariable('curDecStep', curDecStep);
			script.setVariable('curDecBeat', curDecBeat);
		}

		/*if(isDownscroll)
			directionThingi = 0.45;
		else
			directionThingi = -0.45; */
		/*if (notes.countLiving() <= 0) vScoreTarget = songScore;

		var scSpd = Math.round((vScoreTarget - visibleScore) / 20 * elapsed * 60);
		if (scSpd < 10) scSpd = 10;

		if (visibleScore < vScoreTarget)
		{
			visibleScore += scSpd;
			if (visibleScore < vScoreTarget - 30000) visibleScore = vScoreTarget - 30000;
		}
		else if (visibleScore > vScoreTarget) visibleScore = vScoreTarget; */ // discarted idea

		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		/*for(i in 0...strumLineNotes.length)
		{	
			if(isDownscroll)
				directionThingi = strumLineNotes.members[i].y - 569;
			else
				directionThingi = strumLineNotes.members[i].y - 49;
	}*/
		/*notes.forEachAlive(function(daNote:Note)
		{
			if(isDownscroll)
				daNote.distance = directionThingi * (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
			else
				daNote.distance = directionThingi * (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
	}*/
		/*if(FlxG.keys.justPressed.X)
		bilHacks(); */

		if ((controls.PAUSE && startedCountdown && canPause) || (!focusing && startedCountdown && canPause))
		{
			openPauseMenu();
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
			Lib.application.window.title = 'Freaky Night With Soni';
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x
		+ boyfriend.daIconOffsets
		+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
		+ (150 * iconP1.scale.x - 150) / 2
		- iconOffset;

		if(Paths.formatToSongPath(SONG.song) != 'spines')
		{
			iconP2.x = healthBar.x
			+ dad.daIconOffsets
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;
		}

		if (health > 2)
			health = 2;

		if (healthDisplay > 2)
			healthDisplay = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
			Lib.application.window.title = 'Freaky Night With Soni';
		}

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime && !bilStarted)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if (ClientPrefs.timeBarType == 'Time Elapsed')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
				if (updateTime && bilStarted)
				{
					timeBar.visible = false;
					timeBarFake.visible = ClientPrefs.timeBarType != 'Disabled';
					if (timeBarFake.min != 0 || timeBarFake.max != 1)
						timeBarFake.setRange(0, 1);

					if (camHUD.zoom - 1 > zoomMax)
						zoomMax = camHUD.zoom - 1;
					if (zoomMax != 0)
						timeBarFake.value = (camHUD.zoom - 1) / zoomMax;
					@:privateAccess {
						timeBarFake._filledBarRect.x = timeBarFake._filledBarPoint.x = Std.int((timeBarFake.barWidth - timeBarFake._filledBarRect.width) / 2);
					}
					var angryCharacters:String = "*#_°+=%$!/\\;.";
					var newText = "";
					for (i in 0...timeTxt.text.length)
					{
						newText += angryCharacters.charAt(FlxG.random.int(0, angryCharacters.length - 1));
					}
					timeTxt.text = newText;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camNotes.zoom = FlxMath.lerp(1, camNotes.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 2000;
			if (songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				dunceNote.downscrollNote = isDownscroll;
				if (bilStarted && dunceNote.isSustainNote != true)
					dunceNote.downscrollNote = FlxG.random.bool(50);
				else if (bilStarted && dunceNote.isSustainNote)
					dunceNote.downscrollNote = dunceNote.prevNote.downscrollNote;
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if (!inCutscene)
			{
				if(!cpuControlled)
					keyShit();
				else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
				else if (taisHomr != null && taisHomr.animation.curAnim != null && taisHomr.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * taisHomr.singDuration && taisHomr.animation.curAnim.name.startsWith('sing') && !taisHomr.animation.curAnim.name.endsWith('miss'))
					taisHomr.dance();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.downscrollNote = isDownscroll;
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if (!daNote.mustPress)
						strumGroup = opponentStrums;
	
					if ((Paths.formatToSongPath(SONG.song) == 'scrapped-mouse') || (Paths.formatToSongPath(SONG.song) == 'broken-reality')) // huh
					{
						for (i in 0...playerStrums.length)
						{
							if (daNote.mustPress)
							{
								if (playerStrums.members[i].y > ((FlxG.height / 2) - (playerStrums.members[i].height / 2)))
								{
									for (k in 0...notes.length - 1)
									{
										for (j in strumGroup.members)
											j.downScroll = true;
										if (daNote.isSustainNote)
										{
											daNote.flipY = true;
										}
									}
								}
								else if (playerStrums.members[i].y < ((FlxG.height / 2) - (playerStrums.members[i].height / 2)))
								{
									for (k in 0...notes.length - 1)
									{
										for (j in strumGroup.members)
											j.downScroll = false;
										if (daNote.isSustainNote)
										{
											daNote.flipY = false;
										}
									}
								}
							}
						}
						for (i in 0...opponentStrums.length)
						{
							if (!daNote.mustPress)
							{
								if (opponentStrums.members[i].y > ((FlxG.height / 2) - (opponentStrums.members[i].height / 2)))
								{
									for (k in 0...notes.length - 1)
									{
										for (j in strumGroup.members)
											j.downScroll = true;
										if (!daNote.mustPress)
										{
											if (daNote.isSustainNote)
											{
												daNote.flipY = true;
											}
										}
									}
								}
								else if (opponentStrums.members[i].y < ((FlxG.height / 2) - (opponentStrums.members[i].height / 2)))
								{
									for (k in 0...notes.length - 1)
									{
										for (j in strumGroup.members)
											j.downScroll = false;
										if (daNote.isSustainNote)
										{
											daNote.flipY = false;
										}
									}
								}
							}
						}
					}
	
					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;
	
					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;
	
					if (Paths.formatToSongPath(SONG.song) != 'cheese')
					{
						if (strumScroll) // Downscroll
						{
							// daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed * ClientPrefs.noteScale);
						}
						else // Upscroll
						{
							// daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
							daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed * ClientPrefs.noteScale);
						}
					}
					else
						daNote.distance = (directionThingi * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed * ClientPrefs.noteScale);
	
					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth() / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}
	
					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}
	
					var center:Float = strumY + Note.swagWidth() / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && Paths.formatToSongPath(SONG.song) != 'cheese')
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
					else if (strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && Paths.formatToSongPath(SONG.song) == 'cheese')
					{
						if(directionThingi > 0 && daNote.wasGoodHit)
						{
							strumGroup.members[daNote.noteData].downScroll = true;
							if (daNote.isSustainNote)
							{
								daNote.flipY = true;
							}
							if (!daNote.mustPress)
							{
								if (daNote.isSustainNote)
								{
									daNote.flipY = true;
								}
							}
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
						else
						{
							strumGroup.members[daNote.noteData].downScroll = false;
							if (daNote.isSustainNote)
							{
								daNote.flipY = false;
							}
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
	
					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if PRIVATE_BUILD
		if (TitleState.isDebug && FlxG.keys.pressed.CONTROL)
		{
			if (FlxG.keys.justPressed.ONE) // SKIP SONG
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}

			if (FlxG.keys.justPressed.TWO) // BACK 10 SECONDS
			{
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition -= 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime + 800 >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				healthChange(2);
			}
			if (FlxG.keys.justPressed.THREE) // SKIP 10 SECONDS
			{
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime + 800 >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				healthChange(2);
			}
			if (FlxG.keys.pressed.Z) // DECREASE HEALTH
			{
				healthDisplay -= 0.01;
				health -= 0.01;
				trace(health);
			}
			if (FlxG.keys.pressed.X) // INCREASE HEALTH
			{
				healthDisplay += 0.01;
				health += 0.01;
				trace(health);
			}
			if (FlxG.keys.justPressed.V) // TOGGLE PRACTICE
			{
				canDie != canDie;
				trace(canDie);
			}
			if (FlxG.keys.pressed.N) // SLOW DOWN
			{
				if (FlxG.keys.pressed.SHIFT)
					playbackRate -= 0.01;
				else if (FlxG.keys.pressed.ALT)
					playbackRate = 1.0;
				else
					playbackRate -= 0.001;
				trace(playbackRate);
			}
			if (FlxG.keys.pressed.M) // SPEED UP
			{
				if (FlxG.keys.pressed.SHIFT)
					playbackRate += 0.01;
				else if (FlxG.keys.pressed.ALT)
					playbackRate = 1.0;
				else
					playbackRate += 0.001;
				trace(playbackRate);
			}
			if (FlxG.keys.justPressed.B) // CREATE A NEW WINDOW
			{
				makeWindow({
					x: 500,
					y: 300,
					width: 560,
					height: 380,
					title: 'test',
					borderless: false,
					alwaysOnTop: false,
				});
			}
			/*if(FlxG.keys.justPressed.A)
			{
				@:functionCode('
					printf("something not inline!\\n");
				')
		}*/
		}
		#end

		/*for(note in notes.members) note.alpha = 0;*/

		// Lib.application.onWindowClose(function(){mepicanloscoco})
		if (onUpdatePost != null)
			onUpdatePost(elapsed);

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);

		if (script != null)
		{
			script.setVariable('cameraX', camFollowPos.x);
			script.setVariable('cameraY', camFollowPos.y);
			script.setVariable('botPlay', cpuControlled);
			script.executeFunc("onUpdatePost", [elapsed]);
		}

		for (i in shaderUpdates)
		{
			i(elapsed);
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	function openPauseMenu()
	{
		if(onPause != null) onPause();
		if (script != null)
			script.executeFunc('onPause');
		var ret:Dynamic = callOnLuas('onPause', []);
		if (ret != FunkinLua.Function_Stop)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			isPause = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				cancelMusicFadeTween();
				MusicBeatState.switchState(new GitarooPause());
			}
			else { */

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			// }

			#if desktop
			#if PRIVATE_BUILD
			DiscordClient.changePresence(detailsPausedText, "CLASSIFIED", 'face');
			#else
			DiscordClient.changePresence(detailsPausedText, SONG.song, precenseIcon);
			#end
			#end
		}
	}

	function healthChange(amount:Float)
	{
		health += amount;
		healthTween.cancel();
		healthTween = FlxTween.num(healthDisplay, health, 0.2 / playbackRate, {ease: FlxEase.expoOut}, function(v:Float)
		{
			healthDisplay = v;
		});
	}

	function pitchChange(amount:Float, time:Float)
	{
		pauseTween.cancel();
		pauseTween = FlxTween.num(playbackRate, amount, time, {ease: FlxEase.linear}, function(v:Float)
		{
			playbackRate = v;
		});
		pauseTween.onUpdate = (twn)-> 
		{
			trace(playbackRate);
			set_playbackRate(playbackRate);
		}
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: ' + songScore
		+ ' | Misses: ' + songMisses
		+ ' | Rating: ' + ratingName
		+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2 / initialPlaybackRate, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
		if (script != null)
			script.executeFunc('onUpdateScore', [miss]);
	}

	public var isDead:Bool = false; // Don't mess with this on Lua!!!

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (((skipHealthCheck && instakillOnMiss) || health <= 0 && canDie) && !practiceMode && !isDead)
		{
			if (script != null)
				script.executeFunc('onGameOver');
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if (ret != FunkinLua.Function_Stop)
			{
				boyfriend.stunned = true;
				if (taisHomr != null) taisHomr.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				var cams:Array<FNFCamera> = [
					camHUD,
					camOther,
					camGame,
					camNotes,
					camLyrics,
					camBars
				];
				for(cam in cams)
				{
					if(cam != null)
					{
						cam.filtersEnabled = false;
						cam.active = true;
						cam.alpha = 1;
						cam.visible = true;
					}
				}

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens)
				{
					tween.active = true;
				}
				for (timer in modchartTimers)
				{
					timer.active = true;
				}
				for (tween in eventTweens)
				{
					tween.active = true;
				}
				for (timer in eventTimers)
				{
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0],
					boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				#if PRIVATE_BUILD
				DiscordClient.changePresence("Game Over - " + detailsText, "CLASSIFIED", 'face');
				#else
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song, precenseIcon);
				#end
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	function getPosFromTimeSV(strumTime:Float, ?svIdx:Int = 0):Float
	{
		if (svIdx == 0)
			return strumTime * SONG.initialSpeed;

		svIdx--;
		var curPos = velocityMarkers[svIdx];
		curPos += ((strumTime - sliderVelocities[svIdx].startTime) * (SONG.initialSpeed * sliderVelocities[svIdx].multiplier));
		return curPos;
	}

	function getPosFromTime(strumTime:Float):Float
	{
		var idx:Int = 0;
		while (idx < sliderVelocities.length)
		{
			if (strumTime < sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		return getPosFromTimeSV(strumTime, idx);
	}

	function songName()
	{
		var songName:String = Paths.formatToSongPath(SONG.song);
		switch (songName)
		{
			case 'sonicando' | 'scrapped-mouse':
				author = 'FrankitoLQ';
			case 'please' | 'origishit' | 'the-lean-iluminati':
				author = 'Rekym ';
			case 'faster-rapper':
				author = 'Rekym  & Yiter';
			case 'sped' | 'unleashed' | 'demand' | 'chaos-control':
				author = 'DonAlgo';
			case 'ou':
				author = 'Rekym  & DonAlgo';
			case 'broken-reality' | 'cheese' | 'dynamic-duo' | 'toy-world' |'dev-troubles':
				author = '4RN4uxd';
			case 'sonibars' | 'ardido' | 'sdlg-or-shitpost' | 'yo-y-los-funis':
				author = 'Drawebos';
			case 'money':
				author = 'RoniGames';
			case 'wed':
				author = 'BitfoxOriginal';
			case 'ovaloader-star' | 'ovaloader-star-siivagunner-edition' | 'echina-disco':
				author = 'Yiter';
			case 'rude' | 'pico':
				author = 'Sic';
			case 'precocious' | 'impersonation':
				author = 'Jomei';
			case 'spines':
				author = 'SugarMoon';
			case '3am':
				author = 'Samu';
			case 'chilli-cats':
				author = 'ShellJom';
		}

		letrero = new FlxSprite(0, 720);
		switch(songName)
		{
			case 'origishit':
				letrero.loadGraphic(Paths.image('Letre_drawe'));
				letrero.antialiasing = false;
			case '3am':
				letrero.frames = Paths.getSparrowAtlas('Mano_APK');
				letrero.animation.addByPrefix('anim', 'Cartel_Apk', 24, false);
				letrero.antialiasing = ClientPrefs.globalAntialiasing;
				letrero.y = 405;
			default:
				letrero.frames = Paths.getSparrowAtlas('Letre');
				letrero.animation.addByPrefix('up', 'Letrero_Up', 24, false);
				letrero.animation.addByPrefix('down', 'Letrero_Down', 24, false);
				letrero.animation.addByPrefix('idle', 'Letrero_Quiet', 24, true);
				letrero.animation.play('idle');
				letrero.antialiasing = ClientPrefs.globalAntialiasing;
		}
		letrero.screenCenter(X);
		letrero.cameras = [camOther];
		add(letrero);

		songText = new FlxText(495, 800, Std.int(FlxG.width * 0.6), "", 36);
		switch(songName)
		{
			case '3am':
				songText.setFormat(Paths.font('sans.ttf'), 36, FlxColor.BLACK, CENTER);
				songText.antialiasing = false;
			case 'origishit':
				songText.setFormat(Paths.font('sans.ttf'), 36, FlxColor.BLACK, CENTER);
				songText.antialiasing = false;
			default:
				songText.setFormat(Paths.font('#44.ttf'), 36, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
				songText.antialiasing = ClientPrefs.globalAntialiasing;
		}
		songText.cameras = [camOther];
		if(songName != '3am') add(songText);

		songText.text = '';
		songText.text += SONG.song + '\n' + author;
		songText.text = songText.text.toUpperCase();
		songText.screenCenter(X);

		if(songName != '3am')
		{
			letreroTimer = new FlxTimer().start((Conductor.crochet / 1000) / initialPlaybackRate, function(tmr:FlxTimer)
			{
				textoLeTween = FlxTween.tween(songText, {y: 450}, (Conductor.crochet / 1000) / initialPlaybackRate, {ease: FlxEase.backOut});
				letreroTween = FlxTween.tween(letrero, {y: 355}, (Conductor.crochet / 1000) / initialPlaybackRate, {
					ease: FlxEase.backOut,
					onComplete: function(twn:FlxTween)
					{
						letreroTimer = new FlxTimer().start((Conductor.crochet / 1000) / initialPlaybackRate, function(tmr:FlxTimer)
						{
							textoLeTween = FlxTween.tween(songText, {y: 800}, (Conductor.crochet / 1000) / initialPlaybackRate, {ease: FlxEase.backIn});
							letreroTween = FlxTween.tween(letrero, {y: 720}, (Conductor.crochet / 1000) / initialPlaybackRate, {
								ease: FlxEase.backIn,
								onComplete: function(twn:FlxTween)
								{
									letrero.kill();
									remove(letrero);
									letrero.destroy();
									songText.kill();
									remove(songText);
									songText.destroy();
								}
							});
						});
					}
				});
			});
		} else
		{
			letrero.animation.play('anim');
			letrero.animation.finishCallback = (name)->{if(name == 'anim'){letrero.kill();remove(letrero);letrero.destroy();}};
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function addInFrontOf(obj:FlxObject, obj2:FlxObject)
	{
		insert(members.indexOf(obj2)+1, obj);
	}

	function santiagoIntro()
	{
		var cutsceneHandler:CutsceneHandler = new CutsceneHandler();
		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		camNotes.visible = false;

		var santiago:FlxSprite = new FlxSprite(dad.x + 3, dad.y - 27);
		santiago.frames = Paths.getSparrowAtlas('backgrounds/santiago/the_Santi');
		santiago.antialiasing = ClientPrefs.globalAntialiasing;
		addBehindDad(santiago);
		cutsceneHandler.push(santiago);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			moveCamera(true);
			dadGroup.alpha = 1;
			startCountdown();

			if (!ClientPrefs.hideHud)
				camHUD.visible = true;
			camNotes.visible = true;
			if(boyfriend.animation.finishCallback != null)
				boyfriend.animation.finishCallback = null;
			if(gf != null)
			{
				gf.animation.finishCallback = null;
				gf.dance();
			}
		};

		camFollow.set(dad.x + 280, dad.y + 170);

		cutsceneHandler.endTime = 5.1;
		precacheList.set('santiago/paper', 'sound');
		precacheList.set('santiago/bfBeep', 'sound');

		var paper:FlxSound = new FlxSound().loadEmbedded(Paths.sound('santiago/paper'));
		FlxG.sound.list.add(paper);

		santiago.animation.addByPrefix('Enraged', 'Santiago_play', 24, false);
		santiago.animation.addByPrefix('Die', 'Santiago_play', 0, false);
		santiago.animation.play('Die', true);
		FlxG.camera.zoom *= 1.2;

		cutsceneHandler.timer(0.1, function()
		{
			camFollow.x += 750;
			camFollow.y += 100;

			// Beep!
			cutsceneHandler.timer(1.4, function()
			{
				boyfriend.playAnim('singUP', true);
				boyfriend.specialAnim = true;
				FlxG.sound.play(Paths.sound('santiago/bfBeep'));
			});

			// Move camera to Santiago
			cutsceneHandler.timer(3, function()
			{
				camFollow.x -= 750;
				camFollow.y -= 100;
				santiago.animation.play('Enraged', true);
			});

			cutsceneHandler.timer(4.09, function()
			{
				paper.play(true);
			});
		});
	}

	var bsVisible:Bool;
	var eventTweens:Array<FlxTween> = [];
	var eventTimers:Array<FlxTimer> = [];

	public function triggerEventNote(eventName:String, value1:Dynamic, value2:Dynamic)
	{
		switch (eventName)
		{
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else if (gf != null)
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if (curStage == 'mall')
					{
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if (Math.isNaN(lightId))
					lightId = 0;

				if (lightId > 0 && curLightEvent != lightId)
				{
					if (lightId > 5)
						lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					// NO MORE BLAMMED LIGHTS :DDD
					switch (lightId)
					{
						case 1: // Blue
							color = 0xffffffff;
						case 2: // Green
							color = 0xffffffff;
						case 3: // Pink
							color = 0xffffffff;
						case 4: // Red
							color = 0xffffffff;
						case 5: // Orange
							color = 0xffffffff;
					}
					curLightEvent = lightId;

					if (blammedLightsBlack.alpha == 0)
					{
						if (blammedLightsBlackTween != null)
						{
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								blammedLightsBlackTween = null;
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length)
						{
							if (chars[i].colorTween != null)
							{
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {
								onComplete: function(twn:FlxTween)
								{
									chars[i].colorTween = null;
								},
								ease: FlxEase.quadInOut
							});
						}
					}
					else
					{
						if (blammedLightsBlackTween != null)
						{
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length)
						{
							if (chars[i].colorTween != null)
							{
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						gf.color = color;
					}

					if (curStage == 'philly')
					{
						if (phillyCityLightsEvent != null)
						{
							phillyCityLightsEvent.forEach(function(spr:BGSprite)
							{
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				}
				else
				{
					if (blammedLightsBlack.alpha != 0)
					{
						if (blammedLightsBlackTween != null)
						{
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								blammedLightsBlackTween = null;
							}
						});
					}

					if (curStage == 'philly')
					{
						phillyCityLights.forEach(function(spr:BGSprite)
						{
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite)
						{
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if (memb != null)
						{
							memb.visible = true;
							memb.alpha = 1;
							if (phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {
								onComplete: function(twn:FlxTween)
								{
									phillyCityLightsEventTween = null;
								},
								ease: FlxEase.quadInOut
							});
						}
					}

					var chars:Array<Character> = [boyfriend, gf, dad];
					for (i in 0...chars.length)
					{
						if (chars[i].colorTween != null)
						{
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {
							onComplete: function(twn:FlxTween)
							{
								chars[i].colorTween = null;
							},
							ease: FlxEase.quadInOut
						});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					if(curSong.toLowerCase() == 'spines')
					{
						if(!Math.isNaN(camZoom) || camZoom != 0.015)
							camZoom /= 2;
						if(!Math.isNaN(hudZoom) || hudZoom != 0.03)
							hudZoom /= 2;
					}
					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
					camNotes.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if (curStage == 'schoolEvil' && !ClientPrefs.lowQuality)
				{
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					camPosicioning = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
						camPosicioning = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FNFCamera> = [camGame, camHUD, camNotes];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						if(ClientPrefs.shake)
							targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1)
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);
						if (script != null) script.setVariable('boyfriendName', boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if (gf != null)
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);
						if (script != null) script.setVariable('dadName', dad.curCharacter);

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
							if (script != null) script.setVariable('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				reloadTimeBarColors();

			case 'BG Freaks Expression':
				if (bgGirls != null)
					bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / initialPlaybackRate, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Spongebob':
				var cry:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cryaboutit'));
				cry.screenCenter();
				cry.antialiasing = ClientPrefs.globalAntialiasing;
				cry.alpha = 0;
				cry.cameras = [camOther];
				add(cry);
				var spongeTween:FlxTween;
				spongeTween = FlxTween.tween(cry, {alpha: 1}, 0.25 / initialPlaybackRate, {
					ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(cry, {alpha: 0}, 0.25 / initialPlaybackRate, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								cry.kill();
								remove(cry);
								cry.destroy();
							}
						});
					}
				});
				eventTweens.push(spongeTween);

			case 'Tais Sus':
				dead.visible = true;
				dead.active = true;
				dead.animation.play('report');
				var susTween:FlxTween;
				susTween = FlxTween.tween(dead, {x: dead.x - (FlxG.width + dead.width)}, 0.3 / initialPlaybackRate, {
					ease: FlxEase.smootherStepInOut,
					onComplete: function(twn:FlxTween)
					{
						dead.kill();
						remove(dead);
						dead.destroy();
					},
					startDelay: 1.72 / initialPlaybackRate
				});
				eventTweens.push(susTween);

			case 'Sex Mod':
				var sexTween:FlxTween;
				sexTween = FlxTween.tween(funny, {alpha: .3}, 27.43 / initialPlaybackRate, {
					ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
					{
						var sexTween2:FlxTween;
						sexTween2 = FlxTween.tween(funny, {alpha: 0}, 1.34 / initialPlaybackRate, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								funny.kill();
								remove(funny);
								funny.destroy();
							}
						});
						eventTweens.push(sexTween2);
					}
				});
				eventTweens.push(sexTween);

			case 'Bil Hacks':
				if (ClientPrefs.mechanics)
					bilHacks();

			case 'Bil Reset':
				resetBil();

			case 'Flip Cam':
				flipCam(value1, value2);

			case 'Shader':
				addShaderLmao(value1);

			case 'Change icon':
				switch (value1)
				{
					case 'p1':
						iconP1.changeIcon(value2);
					case 'p2':
						iconP2.changeIcon(value2);
				}
				switch (value2)
				{
					case 'tais-sing':
						dad.healthColorArray = [255, 119, 0];
					case 'nuckles-sing':
						dad.healthColorArray = [225, 0, 56];
					case 'tais-n-nuckles':
						dad.healthColorArray = [240, 59, 28];
				}
				reloadHealthBarColors();
				reloadTimeBarColors();

			case 'Undertale Start':
				var color:FlxColor = FlxColor.WHITE;
				if (!ClientPrefs.flashing)
					color.alphaFloat = 0.5;
				camOther.flash(color, .1 / initialPlaybackRate);
				if (curStage != 'grillby')
				{
					if (blammedLightsBlackTween != null)
					{
						blammedLightsBlackTween.cancel();
					}
					blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, .1 / initialPlaybackRate, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							blammedLightsBlackTween = null;
						}
					});
					eventTweens.push(blammedLightsBlackTween);
				}
				else
				{
					mierdaCosa1 = 'black/';
					mierdaCosa2 = '_alt';
					changeBG();
				}
				GameOverSubstate.characterName = 'befe-sas';
				GameOverSubstate.deathSoundName = 'loss_sas';
				GameOverSubstate.endSoundName = 'date_accept';

			case 'Undertale End':
				var color:FlxColor = FlxColor.WHITE;
				if (!ClientPrefs.flashing)
					color.alphaFloat = 0.5;
				camOther.flash(color, .1 / initialPlaybackRate);
				if (curStage != 'grillby')
				{
					if (blammedLightsBlackTween != null)
					{
						blammedLightsBlackTween.cancel();
					}
					blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, .1 / initialPlaybackRate, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							blammedLightsBlackTween = null;
						}
					});
					eventTweens.push(blammedLightsBlackTween);
				}
				else
				{
					mierdaCosa1 = '';
					mierdaCosa2 = '';
					changeBG();
				}
				GameOverSubstate.characterName = initialDBF;
				GameOverSubstate.deathSoundName = initialDSN;
				GameOverSubstate.endSoundName = initialDSE;

			case 'Funny Glow':
				var lightId:Int = Std.parseInt(value1);
				if (Math.isNaN(lightId))
					lightId = 0;

				var doFlash:Void->Void = function()
				{
					var color:FlxColor = FlxColor.WHITE;
					if (!ClientPrefs.flashing)
						color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15 / initialPlaybackRate, null, true);
				};

				switch (lightId)
				{
					case 0:
						if (funnyGlowGradient.visible)
						{
							if (curStage != 'park')
							{
								doFlash();
								if (ClientPrefs.camZooms)
								{
									FlxG.camera.zoom += 0.5;
									camHUD.zoom += 0.1;
								}
							}

							blammedLightsBlackForOther.visible = false;
							funnyGlowGradient.visible = false;
							funnyGlowParticles.visible = false;
						}

					case 1: // turn on
						var color:FlxColor = FlxColor.RED;

						if (!funnyGlowGradient.visible)
						{
							if (curStage != 'park')
							{
								doFlash();
								if (ClientPrefs.camZooms)
								{
									FlxG.camera.zoom += 0.5;
									camHUD.zoom += 0.1;
								}
							}

							blammedLightsBlackForOther.visible = false;
							blammedLightsBlackForOther.alpha = 1;
							funnyGlowGradient.visible = true;
							funnyGlowParticles.visible = true;
						}
						else if (ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5 / initialPlaybackRate, null, true);
						}

						funnyGlowParticles.forEachAlive(function(particle:FunnyGlow.FunnyGlowParticle)
						{
							particle.color = color;
						});
						funnyGlowGradient.color = color;

					case 2: // spawn particles
						if (!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = FlxColor.RED;
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:FunnyGlow.FunnyGlowParticle = new FunnyGlow.FunnyGlowParticle(-400
										+ width * i
										+ FlxG.random.float(-width / 5, width / 5),
										funnyGlowGradient.originalY
										+ 200
										+ (FlxG.random.float(0, 125) + j * 40), color);
									funnyGlowParticles.add(particle);
								}
							}
						}
						funnyGlowGradient.bop();
				}
			case 'Error Apk':
				errorApk(FlxG.random.int(0,3500));	

			case 'Aesthetic':
				aesthetic.visible = true;
				var aestheticTween:FlxTween;
				aestheticTween = FlxTween.tween(aesthetic, {"scale.y": value1}, value2 / initialPlaybackRate, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						if (value1 >= 1.3)
							aesthetic.visible = false;
					}
				});
				eventTweens.push(aestheticTween);

			case 'Epic Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if (val == null)
					val = 0;

				switch (Std.parseInt(value1))
				{
					case 1, 2, 3: // enable and target dad
						if (val == 1) // enable
						{
							thingiBlack.visible = true;
							thingiLight.visible = true;
							thingiSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if (val > 2)
							who = boyfriend;
						// 2 only targets dad
						thingiLight.alpha = 0;
						var spotTimer:FlxTimer;
						spotTimer = new FlxTimer().start(0.12 / initialPlaybackRate, function(tmr:FlxTimer)
						{
							thingiLight.alpha = 0.375;
						});
						eventTimers.push(spotTimer);
						thingiLight.setPosition(who.getGraphicMidpoint().x - thingiLight.width / 2, who.y + who.height - thingiLight.height + 50);

					default:
						thingiBlack.visible = false;
						thingiLight.visible = false;
						defaultCamZoom -= 0.12;
						var smokesTween:FlxTween;
						smokesTween = FlxTween.tween(thingiSmokes, {alpha: 0}, 1 / initialPlaybackRate, {
							onComplete: function(twn:FlxTween)
							{
								thingiSmokes.visible = false;
							}
						});
						eventTweens.push(smokesTween);
				}
			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if (killMe.length > 1)
				{
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length - 1], value2);
				}
				else
				{
					FunkinLua.setVarInArray(this, value1, value2);
				}
			case 'Song Event':
				if (songEvent != null)
					songEvent(value1, value2);
			case 'Change BG':
				if (changeBG != null)
					changeBG();
			case 'Movistar Effect':
				#if (openfl >= "8.0.0")
				elShader.data.uBlocksize.value = [value1, value1];
				#else
				elShader.uBlocksize = [value1, value1];
				#end
				switch (value2.toLowerCase())
				{
					case 'dad':
						dad.shader = elShader;
					case 'bf' | 'boyfriend':
						boyfriend.shader = elShader;
					case 'gf' | 'girlfriend':
						gf.shader = elShader;
					case 'stage':
						for (i in grpSoniStage)
							i.shader = elShader;
						for (i in strumLineNotes)
							i.shader = elShader;
						for (i in notes)
							i.shader = elShader;
				}
			case 'Black Screen':
				switch (value1.toLowerCase())
				{
					case 'true':
						bsVisible = true;
					case 'false':
						bsVisible = false;
					default:
						bsVisible = true;
				}
				blackScreen.visible = bsVisible;
			case 'Flash':
				var color:FlxColor = FlxColor.WHITE;
				if (!ClientPrefs.flashing)
					color.alphaFloat = 0.5;
				switch (value1.toLowerCase())
				{
					case 'hud':
						camHUD.flash(color, value2 / initialPlaybackRate);
					case 'game':
						camGame.flash(color, value2 / initialPlaybackRate);
					case 'other':
						camOther.flash(color, value2 / initialPlaybackRate);
					case 'notes':
						camNotes.flash(color, value2 / initialPlaybackRate);
				} // lazy code
			case 'Set Cam Zoom':
				if (value2 == '' || value2 == null)
					defaultCamZoom = value1;
				else
				{
					camGame.zoom = value1;
					defaultCamZoom = value1;
				}
			case 'End Special Anim':
				var char:Character = dad;
				switch (value2.toLowerCase())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if(char != null) 
				{
					char.specialAnim = false;
					char.dance();
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
		if (script != null)
			script.executeFunc('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if (SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x + 150, gf.getMidpoint().y - 100);
			camFollow.x += gf.cameraPosition[0];
			camFollow.y += gf.cameraPosition[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			if (script != null)
				script.executeFunc('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
			if (script != null)
				script.executeFunc('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
			if (script != null)
				script.executeFunc('onMoveCamera', ['boyfriend']);
		}
	}

	function plsWork()
	{
		FlxTween.tween(camNotes, {yaw: 360}, 1, {type: LOOPING});
	}

	function plsWork2()
	{
		FlxTween.tween(camNotes, {pitch: 360}, 1, {type: LOOPING});
	}

	function plsWork3()
	{
		FlxTween.tween(this, {directionThingi: -0.45}, 1, {type: LOOPING, startDelay: 3});
	}

	function plsWork4()
	{
		FlxTween.tween(opponentStrums, {yaw: 360}, 1, {type: LOOPING, startDelay: 3});
	}

	var windows:Array<Window> = [];
	function makeWindow(properties:lime.ui.WindowAttributes)
	{
		var window = WindowManager.addWindow('test', {
			x: properties.x,
			y: properties.y,
			width: properties.width,
			height: properties.height,
			title: properties.title,
			borderless: properties.borderless,
			alwaysOnTop: properties.alwaysOnTop,
		});
		windows.push(window);
	}
	function closeWindow(all:Bool = true)
	{
		if(all) for(window in windows) if(window != null) window.close();
		else windows[0].close();
	}

	function errorApk(probs:Int)
	{
		if (probs == 69)
		{
			var rand = FlxG.random.int(0, 18);
			var rand2 = FlxG.random.int(0, 18);
			if (rand == rand2)
				rand2 = FlxG.random.int(0, 18);
			var doxxString:String = "";
			var defaultUser:Bool = getUsername() == 'Usuario' || getUsername() == 'User' || getUsername() == 'Usuário' || getUsername() == null
				|| getUsername() == 'null';
			if (defaultUser)
				doxxString = getPC().startsWith("DESKPOT") ? getUsername() : getPC();
			var quotes:Array<String> = [
				'El pepe',
				'Eso tilin',
				'Kill yourself',
				':whenbaldo:',
				'agora quero ser o jp',
				'Potaxio',
				'El nino del oxxo',
				'Tenzubushi chupala',
				'13',
				'*sale del banio* que paso',
				'HOLA SOY JP (AYUDAAA)',
				'but te matas',
				'hola $doxxString',
				'eso pilin wow pilin',
				'ramirez al enterarse',
				'when haces tus codigos en errores de windows',
				'el futuro es hoy oiste viejo',
				'but te terminan metiendo un virus al pc',
				'NOOO MI LENTE DE CONTECTO AJSGAHGSASG'
			];
			#if cpp
			CppUse.messageBox(quotes[rand], quotes[rand2], FlxG.random.int(0, 47));
			#else
			Application.current.window.alert(cast quotes[rand], cast quotes[rand2]);
			#end
		}
	}

	function getUsername()
	{
		var envs = Sys.environment();
		if (envs.exists("USERNAME"))
		{
			return envs["USERNAME"];
		}
		if (envs.exists("USER"))
		{
			return envs["USER"];
		}
		return null;
	}

	function getPC()
	{
		var envs = Sys.environment();
		if (envs.exists("COMPUTERNAME"))
		{
			return envs["COMPUTERNAME"];
		}
		else
		{
			return null;
		}
	}

	// Bil shits bruhh
	function flipCam(camera:Int = 0, axe:Int = 0)
	{
		var cam:Array<FNFCamera> = [camGame, camHUD];
		if (camera == 0 || camera < 1 || camera > 2)
			camera = FlxG.random.int(1,2);
		if (camera == 0 || axe < 1 || axe > 2)
			axe = FlxG.random.int(1,2);
		switch (axe)
		{
			case 1:
				if (cam[camera-1] != null)
					cam[camera-1].flashSprite.scaleX *= -1;
			case 2:
				if (cam[camera-1] != null)
					cam[camera-1].flashSprite.scaleY *= -1;
		}
	}

	var bilStarted:Bool = false;
	var bilAngle:Float = 0;

	function bilHacks()
	{
		for (i in opponentStrums)
			i.alpha = 0;
		isDownscroll = FlxG.random.bool(50);
		notes.forEach(function(note:Note)
		{
			note.downscrollNote = isDownscroll;
		});
		for (i in 0...playerStrums.length)
		{
			if (i == 0)
			{
				playerStrums.members[i].x = FlxG.random.int(100, Std.int(FlxG.width / 3));
				if (isDownscroll)
					playerStrums.members[i].y = FlxG.random.int(Std.int(FlxG.height / 2), FlxG.height - 100);
				else
					playerStrums.members[i].y = FlxG.random.int(0, 300);
			}
			else
			{
				var futurex = FlxG.random.int(Std.int(playerStrums.members[i - 1].x) + 80, Std.int(playerStrums.members[i - 1].x) + 400);
				if (futurex > FlxG.width - 100)
					futurex = FlxG.width - 100;
				playerStrums.members[i].x = futurex;

				playerStrums.members[i].y = FlxG.random.int(Std.int(playerStrums.members[0].y - 50), Std.int(playerStrums.members[0].y + 50));
			}
		}
		camHUD.angle = FlxG.random.float(-5, 5);
		if (ClientPrefs.funnyShaders)
			addShaderLmao('');
		flipCam();
		var randX:Int = FlxG.random.int(-25, 25);
		var randY:Int = FlxG.random.int(-28, 28);
		Lib.application.window.move(Lib.application.window.x + randX, Lib.application.window.y + randY);
		var tmr:FlxTimer = new FlxTimer().start(0.2 / initialPlaybackRate, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x - randX, Lib.application.window.y - randY);
		});
		eventTimers.push(tmr);
		bilStarted = true;
	}

	function resetBil()
	{
		bilStarted = false;
		var color:FlxColor = FlxColor.WHITE;
		if (!ClientPrefs.flashing)
			color.alphaFloat = 0.5;
		camOther.flash(color, 0.1 / initialPlaybackRate);
		for (i in opponentStrums)
			if (ClientPrefs.opponentStrums)
				if (isMiddlescroll)
					i.alpha = 0.35;
				else
					i.alpha = ClientPrefs.noteTransparencySoniNose;

		for (i in 0...8)
			strumLineNotes.members[i].y = (ClientPrefs.downScroll ? 570 : 50);

		for(cam in cams)
		{
			if(cam != null)
			{
				cam.flashSprite.scaleX = 1;
				cam.flashSprite.scaleY = 1;
			}
		}

		camHUD.angle = 0;

		isDownscroll = ClientPrefs.downScroll;

		if (ClientPrefs.timeBarType == 'Song Name')
			timeTxt.text = SONG.song;

		timeBar.visible = ClientPrefs.timeBarType != 'Disabled';
		timeBarFake.visible = false;

		filters = [];
		for(cam in cams) if(cam != null) cam.setFilters(filters);
	}

	function addShaderLmao(shad:String)
	{
		var gray:Array<Float> = [
			0.5, 0.5, 0.5,   0,
			  0, 0.5, 0.5, 0.5,
			  0,   0, 0.5, 0.5,  
			0.5,   0,   0,   0,
			  0,   0,   1,   0,
		];
		var invert:Array<Float> = [
			-1,  0,  0, 0, 255,
			 0, -1,  0, 0, 255,
			 0,  0, -1, 0, 255,
			 0,  0,  0, 1,   0,
		];
		var deuter:Array<Float> = [
			0.43, 0.72, -.15, 0, 0,
			0.34, 0.57, 0.09, 0, 0,
			-.02, 0.03,    1, 0, 0,
			   0,    0,    0, 1, 0,
		];
		var prota:Array<Float> = [
			0.20, 0.99, -.19, 0, 0,
			0.16, 0.79, 0.04, 0, 0,
			0.01, -.01,    1, 0, 0,
			   0,    0,    0, 1, 0,
		];
		var trita:Array<Float> = [
			0.97, 0.11, -.08, 0, 0,
			0.02, 0.82, 0.16, 0, 0,
			0.06, 0.88, 0.18, 0, 0,
			   0,    0,    0, 1, 0,
		];
		if (shad == '' || shad == null)
		{
			var randomize = FlxG.random.int(0, 4);
			switch (randomize)
			{
				case 0:
					shad = 'gray';
				case 1:
					shad = 'invert';
				case 2:
					shad = 'deuter';
				case 3:
					shad = 'prota';
				case 4:
					shad = 'trita';
			}
		}
		switch (shad)
		{
			case 'gray':
				shader = new ColorMatrixFilter(gray);
			case 'invert':
				shader = new ColorMatrixFilter(invert);
			case 'deuter':
				shader = new ColorMatrixFilter(deuter);
			case 'prota':
				shader = new ColorMatrixFilter(prota);
			case 'trita':
				shader = new ColorMatrixFilter(trita);
		}
		if (filters.length > 5)
			filters.remove(filters[0]);
		filters.push(shader);
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool, ?isGF:Bool = false)
	{
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - box, boyfriend.getMidpoint().y - boy);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					healthChange((0.05 * healthLoss) * -1);
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					healthChange((0.05 * healthLoss) * -1);
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = true;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		GameOverSubstate.healthLossDecreased = false;
		seenCutscene = false;
		checkAchievements();

		if (script != null)
			script.executeFunc('onEndSong');
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			pauseTween.cancel();
			playbackRate = 1;

			Lib.application.window.title = "Freaky Night With Soni";

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn)
					{
						CustomFadeTransition.nextCamera = null;
					}
					if (Paths.formatToSongPath(SONG.song) != "sped")
						MusicBeatState.switchState(new StoryMenuState());
					else
						MusicBeatState.switchState(new End());

					if (Progression.weekProgress.exists(WeekData.getWeekFileName()))
					{
						Progression.weekProgress.remove(WeekData.getWeekFileName());
						Progression.save();
					}

					// if ()
					if (!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false))
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
						camNotes.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if (winterHorrorlandNext)
					{
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					}
					else
					{
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				// trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
				if (!isCode)
					MusicBeatState.switchState(new FreeplayState());
				else
					MusicBeatState.switchState(new Codes());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;

	function startAchievement(achieve:String)
	{
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}
	#end

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			if (modchartObjects.exists('note${daNote.ID}'))
				modchartObjects.remove('note${daNote.ID}');
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		/* if (combo > 60)
			daRating = 'sick';
		else if (combo > 12)
			daRating = 'good'
		else if (combo > 4)
			daRating = 'bad';
	 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = !ClientPrefs.hideHud;
		rating.x += 540;
		rating.y -= (ClientPrefs.downScroll ? 200 : -270); // ClientPrefs bcs bil sucks my cock

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = !ClientPrefs.hideHud;

		var ox = FlxG.width * .35 + comboSpr.width / 4.1;
		var oy = comboSpr.y + comboSpr.height / 1.45;
		if (isPixelStage)
		{
			ox += 3;
			oy += 10;
		}
		else
		{
			ox -= 14;
			oy /= 1.2;
		}
		comboSpr.x = ox + 540 - 14;
		comboSpr.y = oy - (ClientPrefs.downScroll ? 280 : -280) / 1.2; // ClientPrefs bcs bil sucks my cock

		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		insert(members.indexOf(strumLineNotes), rating);

		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (combo > 9)
			insert(members.indexOf(strumLineNotes), comboSpr);

		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += 540;
			numScore.y -= (ClientPrefs.downScroll ? 235 : -235); // ClientPrefs bcs bil sucks my cock

			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			// if (combo >= 10 || combo == 0)
			insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		/* 
		trace(combo);
		trace(seperatedScore);
	 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		// trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if ((!boyfriend.stunned || (taisHomr != null && !taisHomr.stunned)) && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if(script != null) script.executeFunc('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
			if (script != null)
				script.executeFunc('onKeyPress', [key]);
		}
		// trace('pressed: ' + controlArray);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
			if (script != null)
				script.executeFunc('onKeyRelease', [key]);
		}
		// trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if ((!boyfriend.stunned || (taisHomr != null && !taisHomr.stunned)) && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit)
				{
					goodNoteHit(daNote);
				}
			});

			if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				// boyfriend.animation.curAnim.finish();
			}
			else if (taisHomr != null && taisHomr.animation.curAnim != null 
				&& taisHomr.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * taisHomr.singDuration
				&& taisHomr.animation.curAnim.name.startsWith('sing')
				&& !taisHomr.animation.curAnim.name.endsWith('miss'))
			{
				taisHomr.dance();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				if (modchartObjects.exists('note${note.ID}'))
					modchartObjects.remove('note${note.ID}');
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		healthChange((daNote.missHealth * healthLoss) * -1);
		if (instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		// For testing purposes
		// trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if (!practiceMode)
			songScore -= 10;

		// vScoreTarget = songScore;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if (daNote.gfNote && gf != null)
		{
			char = gf;
		}
		if (daNote.taisNote && taisHomr != null)
		{
			char = taisHomr;
		}

		if (char.hasMissAnimations)
		{
			var daAlt = '';
			if (daNote.noteType == 'Alt Animation')
				daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [
			notes.members.indexOf(daNote),
			daNote.noteData,
			daNote.noteType,
			daNote.isSustainNote
		]);
		if (script != null)
			script.executeFunc('noteMiss', [
				notes.members.indexOf(daNote),
				daNote.noteData,
				daNote.noteType,
				daNote.isSustainNote
			]);

		noteHits = 0;
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if ((!boyfriend.stunned || (taisHomr != null && !taisHomr.stunned)))
		{
			healthChange((0.05 * healthLoss) * -1);
			if (instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (ClientPrefs.ghostTapping)
				return;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode) songScore -= 10;
			if (!endingSong)
			{
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
		});*/

			if (boyfriend.hasMissAnimations)
			{
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			if (taisHomr != null && taisHomr.hasMissAnimations)
			{
				taisHomr.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
		if (script != null)
			script.executeFunc('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (!note.noAnimation)
		{
			var camSwayX:Float = 0;
			var camSwayY:Float = 0;

			switch (note.noteData)
			{
				case 0:
					camSwayX = -20 * camSwaymult;
				case 1:
					camSwayY = 20 * camSwaymult;
				case 2:
					camSwayY = -20 * camSwaymult;
				case 3:
					camSwayX = 20 * camSwaymult;
			}

			var char:Character = dad;
			if (note.gfNote && gf != null)
			{
				char = gf;
			}
			if (note.taisNote && taisHomr != null)
			{
				char = taisHomr;
			}

			if (curStep >= 1)
			{
				if (!char.specialAnim)
				{
					if (!camPosicioning)
					{
						isCameraOnForcedPos = true;
						if (!SONG.notes[curSection].mustHitSection)
						{
							if (SONG.notes[curSection].gfSection)
							{
								if (!note.taisNote)
								{
									if(gf != null)
									{
										camFollow.x = gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX;
										camFollow.y = gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY;
										shittyShitAssGF = [
											gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX,
											gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY
										];
									}
								}
								else
								{
									if (taisHomr != null)
									{
										camFollow.x = taisHomr.getMidpoint().x + 150 + taisHomr.cameraPosition[0] + camSwayX;
										camFollow.y = taisHomr.getMidpoint().y - 100 + taisHomr.cameraPosition[1] + camSwayY;
									}
								}
							}
							else
							{
								if (!note.taisNote)
								{
									if(!note.gfNote)
									{
										camFollow.x = dad.getMidpoint().x + 150 + dad.cameraPosition[0] + camSwayX;
										camFollow.y = dad.getMidpoint().y - 100 + dad.cameraPosition[1] + camSwayY;
										shittyShitAssOpponent = 
										[
											dad.getMidpoint().x + 150 + dad.cameraPosition[0] + camSwayX,
											dad.getMidpoint().y - 100 + dad.cameraPosition[1] + camSwayY
										];
									} else
									{
										camFollow.x = gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX;
										camFollow.y = gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY;
										shittyShitAssGF = [
											gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX,
											gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY
										];
									}
								}
								else
								{
									if (taisHomr != null)
									{
										camFollow.x = taisHomr.getMidpoint().x + 150 + taisHomr.cameraPosition[0] + camSwayX;
										camFollow.y = taisHomr.getMidpoint().y - 100 + taisHomr.cameraPosition[1] + camSwayY;
									}
								}
							}
						}
					}
				}
			}
		}

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = "";

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation')
				{
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if (note.gfNote && gf != null)
			{
				char = gf;
			}
			if (note.taisNote && taisHomr != null)
			{
				char = taisHomr;
			}

			if (!char.specialAnim)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
		{
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [
			notes.members.indexOf(note),
			Math.abs(note.noteData),
			note.noteType,
			note.isSustainNote
		]);
		if (script != null)
			script.executeFunc('opponentNoteHit', [
				notes.members.indexOf(note),
				Math.abs(note.noteData),
				note.noteType,
				note.isSustainNote
			]);

		if (!note.isSustainNote)
		{
			if (modchartObjects.exists('note${note.ID}'))
				modchartObjects.remove('note${note.ID}');
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				switch (note.noteType)
				{
					case 'Hurt Note': // Hurt note
						if (boyfriend.animation.getByName('hurt') != null)
						{
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					if (modchartObjects.exists('note${note.ID}'))
						modchartObjects.remove('note${note.ID}');
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if (combo > 9999)
					combo = 9999;
			}
			healthChange((note.hitHealth * 1) * healthGain);

			if (!note.noAnimation)
			{
				var camSwayX:Float = 0;
				var camSwayY:Float = 0;

				switch (note.noteData)
				{
					case 0:
						camSwayX = -20 * camSwaymult;
					case 1:
						camSwayY = 20 * camSwaymult;
					case 2:
						camSwayY = -20 * camSwaymult;
					case 3:
						camSwayX = 20 * camSwaymult;
				}

				var char:Character = boyfriend;
				if (note.gfNote && gf != null)
				{
					char = gf;
				}
				if (note.taisNote && taisHomr != null)
				{
					char = taisHomr;
				}

				if (curStep >= 1)
				{
					if (!char.specialAnim)
					{
						if (!camPosicioning)
						{
							isCameraOnForcedPos = true;
							if (SONG.notes[curSection].mustHitSection)
							{
								if (SONG.notes[curSection].gfSection)
								{
									if (!note.taisNote)
									{
										if(gf != null)
										{
											camFollow.x = gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX;
											camFollow.y = gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY;
											shittyShitAssGF = [
												gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX,
												gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY
											];
										}
									}
									else
									{
										if (taisHomr != null)
										{
											camFollow.x = taisHomr.getMidpoint().x + 150 + taisHomr.cameraPosition[0] + camSwayX;
											camFollow.y = taisHomr.getMidpoint().y - 100 + taisHomr.cameraPosition[1] + camSwayY;
										}
									}
								}
								else
								{
									if (!note.taisNote)
									{
										if(!note.gfNote)
										{
											camFollow.x = boyfriend.getMidpoint().x - box - boyfriend.cameraPosition[0] + camSwayX;
											camFollow.y = boyfriend.getMidpoint().y - boy + boyfriend.cameraPosition[1] + camSwayY;
											shittyShitAssPlayer = [
												boyfriend.getMidpoint().x - box - boyfriend.cameraPosition[0] + camSwayX,
												boyfriend.getMidpoint().y - boy + boyfriend.cameraPosition[1] + camSwayY
											];
										}
										else
										{
											if(gf != null)
											{
												camFollow.x = gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX;
												camFollow.y = gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY;
												shittyShitAssGF = [
													gf.getMidpoint().x + 150 + gf.cameraPosition[0] + camSwayX,
													gf.getMidpoint().y - 100 + gf.cameraPosition[1] + camSwayY
												];
											}
										}
									}
									else
									{
										if (taisHomr != null)
										{
											camFollow.x = taisHomr.getMidpoint().x - taisHomr.cameraPosition[0] + camSwayX;
											camFollow.y = taisHomr.getMidpoint().y - taisHomr.cameraPosition[1] + camSwayY;
										}
									}
								}
							}
						}
					}
				}

				var daAlt = '';
				if (note.noteType == 'Alt Animation')
					daAlt = '-alt';

				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if (note.gfNote && gf != null)
				{
					if(!gf.specialAnim)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else if (note.taisNote && taisHomr != null && !taisHomr.specialAnim)
				{
					taisHomr.playAnim(animToPlay + daAlt, true);
					taisHomr.holdTimer = 0;
				}
				else
				{
					if (!boyfriend.specialAnim)
					{
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
					}
				}
				// }
				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if (gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			if (script != null)
				script.executeFunc('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				noteHits = noteHits + 1;
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;

	function fastCarDrive()
	{
		// trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; // Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		if (ClientPrefs.camZooms)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camNotes.zoom += 0.03;

			if (!camZooming)
			{
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
				FlxTween.tween(camNotes, {zoom: 1}, 0.5);
			}
		}

		if (ClientPrefs.flashing)
		{
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075 / initialPlaybackRate);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25 / initialPlaybackRate, {startDelay: 0.15 / initialPlaybackRate});
		}
	}

	function killHenchmen():Void
	{
		if (!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo')
		{
			if (limoKillingState < 1)
			{
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
			}
		}
	}

	function resetLimoKill():Void
	{
		if (curStage == 'limo')
		{
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;

	override function destroy()
	{
		center.put();

		preventLuaRemove = true;
		for (i in 0...luaArray.length)
		{
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];
		if (script != null)
		{
			script.executeFunc("destroy");
			script.destroy();
			script = null;
		}

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua)
	{
		if (luaArray != null && !preventLuaRemove)
		{
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();

		if (curStep == lastStepHit)
		{
			resyncVocals();
			return;
		}

		if (curStepSection != null)
			curStepSection();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'bil')
		{
			if (!ClientPrefs.lowQuality || ClientPrefs.funnyShaders)
			{
				var trail:GhostSprite = GhostSprite.createGhostSprite(dad, 0.25, 0.4);
				spriteTrail.add(trail);
			}
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
		if (script != null && script.getVariable("curStep") != curStep)
		{
			script.setVariable("curStep", curStep);
			script.executeFunc("onStepHit");
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			// trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, isDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (curBeatSection != null)
			curBeatSection();

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& !gf.stunned
			&& gf.animation.curAnim.name != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
		{
			gf.dance();
			if (!camPosicioning)
				isCameraOnForcedPos = false;
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
		{
			boyfriend.dance();
			if (!camPosicioning)
				isCameraOnForcedPos = false;
		}
		if (taisHomr != null
			&& curBeat % taisHomr.danceEveryNumBeats == 0
			&& taisHomr.animation.curAnim != null
			&& !taisHomr.animation.curAnim.name.startsWith('sing')
			&& !taisHomr.stunned)
		{
			taisHomr.dance();
			if (!camPosicioning)
				isCameraOnForcedPos = false;
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
		{
			if ((!ClientPrefs.lowQuality || ClientPrefs.funnyShaders) && dad.curCharacter == 'bil')
			{
				var trail:GhostSprite = GhostSprite.createGhostSprite(dad, 0.25, 0.4);
				spriteTrail.add(trail);
			}
			dad.dance();
			if (!camPosicioning)
				isCameraOnForcedPos = false;
		}

		switch (curStage)
		{
			case 'school':
				if (!ClientPrefs.lowQuality)
				{
					bgGirls.dance();
				}

			case 'mall':
				if (!ClientPrefs.lowQuality)
				{
					upperBoppers.dance(true);
				}

				if (heyTimer <= 0)
					bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if (!ClientPrefs.lowQuality)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); // DAWGG?????
		callOnLuas('onBeatHit', []);

		if (script != null)
		{
			script.setVariable("curBeat", curBeat);
			script.executeFunc("onBeatHit");
		}
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
				if(SONG.notes[curSection].gfSection && gf != null)
				{
					camFollow.set(gf.getMidpoint().x + 150, gf.getMidpoint().y - 100);
					camFollow.x += gf.cameraPosition[0];
					camFollow.y += gf.cameraPosition[1];
				}
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
				camNotes.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
				if (script != null)
				{
					script.setVariable('curBpm', Conductor.bpm);
					script.setVariable('crochet', Conductor.crochet);
					script.setVariable('stepCrochet', Conductor.stepCrochet);
				}
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
			if (script != null)
			{
				script.setVariable('mustHitSection', SONG.notes[curSection].mustHitSection);
				script.setVariable('altAnim', SONG.notes[curSection].altAnim);
				script.setVariable('gfSection', SONG.notes[curSection].gfSection);
			}
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
		if (script != null)
		{
			script.setVariable('curSection', curSection);
			script.executeFunc("onSectionHit");
		}
	}

	public var closeLuas:Array<FunkinLua> = [];

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = false, ?exclusions:Array<String>):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if (exclusions == null)
			exclusions = [];
		for (i in 0...luaArray.length)
		{
			if (exclusions.contains(luaArray[i].scriptName))
			{
				continue;
			}

			var ret:Dynamic = luaArray[i].call(event, args);
			if (ret == FunkinLua.Function_StopLua)
			{
				if (ignoreStops)
					ret = FunkinLua.Function_Continue;
				else
					break;
			}

			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		// trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;
		if (isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating(badHit:Bool = false)
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		if (script != null)
		{
			script.setVariable('score', songScore);
			script.setVariable('misses', songMisses);
			script.setVariable('hits', songHits);
		}

		if (script != null)
			script.executeFunc('onRecalculateRating', [badHit]);
		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit);
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
		if (script != null)
		{
			script.setVariable('rating', ratingPercent);
			script.setVariable('ratingName', ratingName);
			script.setVariable('ratingFC', ratingFC);
		}
	}

	public static var othersCodeName:String = 'otherAchievements';

	function checkAchievements()
	{
		if(#if PRIVATE_BUILD true #else !cpuControlled #end)
		{
			if(isStoryMode)
			{
				var lastSong:String = storyPlaylist[0];
				switch(lastSong.toLowerCase())
				{
					case 'sped':
						Progression.beatedSoni = true;
						GJAchievements.unlockAchievement("Not too fast!", true);
				}
			}
			else if(isCode)
			{
				switch(Paths.formatToSongPath(SONG.song))
				{
					case 'unleashed':
						Progression.beatedWerhog = true;
						GJAchievements.unlockAchievement("It's Morbin' Time!", true);
					case 'ou':
						Progression.beatedOu = true;
						GJAchievements.unlockAchievement("ou", true);
					case 'broken-reality':
						Progression.beatedBil = true;
						GJAchievements.unlockAchievement("Another reality", true);
					case 'sonibars':
						Progression.beatedSonibars = true;
						//GJAchievements.unlockAchievement("Sastastic!1!1!", true);
					case 'origishit':
						Progression.beatedOrigishit = true;
						//GJAchievements.unlockAchievement("Sastastic!1!1!", true);
					case 'cheese':
						Progression.beatedSas = true;
						GJAchievements.unlockAchievement("Sastastic!1!1!", true);
					case 'impersonation':
						Progression.beatedSantiago = true;
						GJAchievements.unlockAchievement("Lies...", true);
					case 'spines':
						Progression.beatedApk = true;
						GJAchievements.unlockAchievement("Sussy Hot Dog", true);
						closeWindow();
					case 'dev-troubles':
						Progression.beatedRoyal = true;
						GJAchievements.unlockAchievement("Decisions", true);
					case 'ovaloader-star':
						Progression.beatedLetal = true;
						GJAchievements.unlockAchievement("LETAL VICTORY", true);
					case 'scrapped-mouse':
						Progression.beatedShawn = true;
						GJAchievements.unlockAchievement("Freezy Peasy", true);
					case 'rude':
						Progression.beatedScourg = true;
						GJAchievements.unlockAchievement("Get Scourged!", true);
					case 'the-lean-iluminati':
						Progression.beatedSolean = true;
						//GJAchievements.unlockAchievement("Get Scourged!", true);
					case 'precocious':
						Progression.beatedHxSoni = true;
						//GJAchievements.unlockAchievement("Get Scourged!", true);
					case 'pico':
						Progression.beatedChile = true;
						//GJAchievements.unlockAchievement("Get Scourged!", true);
					case '3am':
						Progression.beatedHalloween = true;
						//GJAchievements.unlockAchievement("Get Scourged!", true);
					case 'chilli-cats':
						Progression.beatedTM = true;
						//GJAchievements.unlockAchievement("Get Scourged!", true);
				}
			}
			Progression.save();
			FlxG.save.flush();
		}
	}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;

	public function startScript()
	{
		var formattedFolder:String = Paths.formatToSongPath(SONG.song);

		var path:String = Paths.hscript(formattedFolder + '/script');

		var hxdata:String = "";

		if (FileSystem.exists(path))
			hxdata = File.getContent(path);

		if (hxdata != "")
		{
			script = null;
			script = new HScript();

			script.setVariable("onCreate", function()
			{
			});

			script.setVariable("onCreatePost", function()
			{
			});

			script.setVariable("onStartCountdown", function()
			{
			});

			script.setVariable("onCountdownStarted", function()
			{
			});

			script.setVariable("onCountdownTick", function(swagCounter:Int)
			{
			});

			script.setVariable("onNextDialogue", function(dialogueCount:Int)
			{
			});

			script.setVariable("onSkipDialogue", function(dialogueCount:Int)
			{
			});

			script.setVariable("onSongStart", function()
			{
			});

			script.setVariable("eventEarlyTrigger", function(event:String)
			{
			});

			script.setVariable("onResume", function()
			{
			});

			script.setVariable("onUpdate", function(elapsed:Float)
			{
			});

			script.setVariable("onPause", function()
			{
			});

			script.setVariable("onUpdatePost", function(elapsed:Float)
			{
			});

			script.setVariable("onGameOver", function()
			{
			});

			script.setVariable("onEvent", function(eventName:String, value1:Dynamic, value2:Dynamic)
			{
			});

			script.setVariable("onMoveCamera", function(char:String)
			{
			});

			script.setVariable("onEndSong", function()
			{
			});

			script.setVariable("onGhostTap", function(key:Int)
			{
			});

			script.setVariable("onKeyPress", function(key:Int)
			{
			});

			script.setVariable("onKeyRelease", function(key:Int)
			{
			});

			script.setVariable("noteMiss", function(layer:Int, noteData:Int, noteType:String, isSustainNote:Bool)
			{
			});

			script.setVariable("noteMissPress", function(direction:Int)
			{
			});

			script.setVariable("opponentNoteHit", function(layer:Int, noteData:Float, noteType:String, isSustainNote:Bool)
			{
			});

			script.setVariable("goodNoteHit", function(layer:Int, leData:Int, leType:String, isSus:Bool)
			{
			});

			script.setVariable("destroy", function()
			{
			});

			script.setVariable("onStepHit", function()
			{
			});

			script.setVariable("onBeatHit", function()
			{
			});

			script.setVariable("onSectionHit", function()
			{
			});

			script.setVariable("onRecalculateRating", function()
			{
			});

			script.setVariable("onUpdateScore", function(badHit:Bool)
			{
			});

			script.setVariable("import", function(lib:String, ?as:Null<String>) // Does this even work?
			{
				if (lib != null && Type.resolveClass(lib) != null)
				{
					script.setVariable(as != null ? as : lib, Type.resolveClass(lib));
				}
			});

			script.setVariable("fromRGB", function(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255)
			{
				return FlxColor.fromRGB(Red, Green, Blue, Alpha);
			});

			script.setVariable('noteTweenX', function(note:Int, value:Dynamic, duration:Float, ease:Float->Float, ?onComplete:FlxTween->Void)
			{
				if (note < 0)
					note = 0;
				var testicle:StrumNote = strumLineNotes.members[note % strumLineNotes.length];
				FlxTween.cancelTweensOf(testicle);

				if (testicle != null)
				{
					FlxTween.tween(testicle, {x: value}, duration, {ease: ease, onComplete: onComplete});
				}
			});

			script.setVariable('noteTweenY', function(note:Int, value:Dynamic, duration:Float, ease:Float->Float, ?onComplete:FlxTween->Void)
			{
				if (note < 0)
					note = 0;
				var testicle:StrumNote = strumLineNotes.members[note % strumLineNotes.length];
				FlxTween.cancelTweensOf(testicle);

				if (testicle != null)
				{
					FlxTween.tween(testicle, {y: value}, duration, {ease: ease, onComplete: onComplete});
				}
			});

			script.setVariable('noteTweenAngle', function(note:Int, value:Dynamic, duration:Float, ease:Float->Float, ?onComplete:FlxTween->Void)
			{
				if (note < 0)
					note = 0;
				var testicle:StrumNote = strumLineNotes.members[note % strumLineNotes.length];
				FlxTween.cancelTweensOf(testicle);

				if (testicle != null)
				{
					FlxTween.tween(testicle, {angle: value}, duration, {ease: ease, onComplete: onComplete});
				}
			});

			script.setVariable('noteTweenAlpha', function(note:Int, value:Dynamic, duration:Float, ease:Float->Float, ?onComplete:FlxTween->Void)
			{
				if (note < 0)
					note = 0;
				var testicle:StrumNote = strumLineNotes.members[note % strumLineNotes.length];
				FlxTween.cancelTweensOf(testicle);

				if (testicle != null)
				{
					FlxTween.tween(testicle, {alpha: value}, duration, {ease: ease, onComplete: onComplete});
				}
			});

			script.setVariable('noteTweenDirection', function(note:Int, value:Dynamic, duration:Float, ease:Float->Float, ?onComplete:FlxTween->Void)
			{
				if (note < 0)
					note = 0;
				var testicle:StrumNote = strumLineNotes.members[note % strumLineNotes.length];
				FlxTween.cancelTweensOf(testicle);

				if (testicle != null)
				{
					FlxTween.tween(testicle, {direction: value}, duration, {ease: ease, onComplete: onComplete});
				}
			});

			script.setVariable('noteTweenDistance', function(value:Dynamic, duration:Float, ease:Float->Float, ?onComplete:FlxTween->Void)
			{
				var testicle = this;
				FlxTween.cancelTweensOf(testicle);

				if (testicle != null)
				{
					FlxTween.tween(testicle, {directionThingi: value}, duration, {ease: ease, onComplete: onComplete});
				}
			});

			script.setVariable('strumLineNote', strumLineNotes);
			script.setVariable('opponentStrums', opponentStrums);
			script.setVariable('playerStrums', playerStrums);
			script.setVariable('grpNoteSplashes', grpNoteSplashes);
			script.setVariable('strumLine', strumLine);

			script.setVariable('notes', notes);
			script.setVariable('unspawnNotes', unspawnNotes);
			script.setVariable('eventNotes', eventNotes);

			script.setVariable('timeBar', timeBar);
			script.setVariable('timeBarBG', timeBarBG);
			script.setVariable('timeTxt', timeTxt);

			script.setVariable('iconP1', iconP1);
			script.setVariable('iconP2', iconP2);

			script.setVariable('camZooming', camZooming);
			script.setVariable('camZoomingMult', camZoomingMult);
			script.setVariable('camZoomingDecay', camZoomingDecay);

			script.setVariable('health', health);
			script.setVariable('healthDisplay', healthDisplay);

			script.setVariable('isDownscroll', isDownscroll);
			script.setVariable('isMiddlescroll', isMiddlescroll);

			script.setVariable('camGame', camGame);
			script.setVariable('camBars', camBars);
			script.setVariable('camHUD', camHUD);
			script.setVariable('camNotes', camNotes);
			script.setVariable('camLyrics', camLyrics);
			script.setVariable('camOther', camOther);
			script.setVariable('defaultCamZoom', defaultCamZoom);

			script.setVariable('curBpm', Conductor.bpm);
			script.setVariable('bpm', SONG.bpm);
			script.setVariable('scrollSpeed', SONG.speed);
			script.setVariable('crochet', Conductor.crochet);
			script.setVariable('stepCrochet', Conductor.stepCrochet);
			script.setVariable('songLength', FlxG.sound.music.length);
			script.setVariable('songName', SONG.song);
			script.setVariable('startedCountdown', false);

			script.setVariable('isStoryMode', isStoryMode);
			script.setVariable('difficulty', storyDifficulty);
			script.setVariable('difficultyName', CoolUtil.difficulties[storyDifficulty]);
			script.setVariable('weekRaw', storyWeek);
			script.setVariable('week', WeekData.weeksList[storyWeek]);
			script.setVariable('seenCutscene', seenCutscene);

			// Camera poo
			script.setVariable('cameraX', 0);
			script.setVariable('cameraY', 0);

			// Screen stuff
			script.setVariable('screenWidth', FlxG.width);
			script.setVariable('screenHeight', FlxG.height);

			// PlayState cringe ass nae nae bullcrap
			script.setVariable('curBeat', 0);
			script.setVariable('curStep', 0);
			script.setVariable('curDecBeat', 0);
			script.setVariable('curDecStep', 0);
			script.setVariable('curSection', 0);

			script.setVariable('score', 0);
			script.setVariable('misses', 0);
			script.setVariable('hits', 0);

			script.setVariable('rating', 0);
			script.setVariable('ratingName', '');
			script.setVariable('ratingFC', '');

			script.setVariable('inGameOver', false);
			script.setVariable('mustHitSection', false);
			script.setVariable('altAnim', false);
			script.setVariable('gfSection', false);

			// PRESET CLASSES
			script.setVariable("PlayState", instance);
			script.setVariable("FlxTween", FlxTween);
			script.setVariable("FlxEase", FlxEase);
			script.setVariable("FlxSprite", FlxSprite);
			script.setVariable("Math", Math);
			script.setVariable("FlxG", FlxG);
			script.setVariable("ClientPrefs", ClientPrefs);
			script.setVariable("FlxTimer", FlxTimer);
			script.setVariable("Main", Main);
			script.setVariable("Conductor", Conductor);
			script.setVariable("Std", Std);
			script.setVariable("FlxTextBorderStyle", FlxTextBorderStyle);
			script.setVariable("Paths", Paths);
			script.setVariable("CENTER", FlxTextAlign.CENTER);
			script.setVariable("FlxTextFormat", FlxTextFormat);
			script.setVariable("InputFormatter", InputFormatter);
			script.setVariable("FlxTextFormatMarkerPair", FlxTextFormatMarkerPair);
			script.setVariable("StrumNote", StrumNote);
			script.setVariable("FlxCamera", FlxCamera);
			script.setVariable("FNFCamera", FNFCamera);
			script.setVariable("HealthIcon", HealthIcon);
			script.setVariable("TitleState", TitleState);
			script.setVariable("FlxBar", FlxBar);
			script.setVariable("Note", Note);
			script.setVariable("ShaderFilter", ShaderFilter);
			script.setVariable("FlxMath", FlxMath);

			script.setVariable('healthGainMult', healthGain);
			script.setVariable('healthLossMult', healthLoss);
			script.setVariable('instakillOnMiss', instakillOnMiss);
			script.setVariable('botplay', cpuControlled);
			script.setVariable('practice', practiceMode);
			script.setVariable('mechanics', mechanics);
			script.setVariable('playbackRate', playbackRate);
			script.setVariable('initialPlaybackRate', initialPlaybackRate);
			script.setVariable('noteScale', ClientPrefs.noteScale);

			for (i in 0...4)
			{
				script.setVariable('defaultPlayerStrumX' + i, 0);
				script.setVariable('defaultPlayerStrumY' + i, 0);
				script.setVariable('defaultOpponentStrumX' + i, 0);
				script.setVariable('defaultOpponentStrumY' + i, 0);
			}

			script.setVariable('defaultBoyfriendX', BF_X);
			script.setVariable('defaultBoyfriendY', BF_Y);
			script.setVariable('defaultOpponentX', DAD_X);
			script.setVariable('defaultOpponentY', DAD_Y);
			script.setVariable('defaultGirlfriendX', GF_X);
			script.setVariable('defaultGirlfriendY', GF_Y);

			script.setVariable('boyfriendName', SONG.player1);
			script.setVariable('dadName', SONG.player2);
			script.setVariable('gfName', SONG.gfVersion);

			script.setVariable('boyfriend', boyfriend);
			script.setVariable('dad', dad);
			script.setVariable('gf', gf);

			script.setVariable('eventTweens', eventTweens);
			script.setVariable('eventTimers', eventTimers);

			script.setVariable('downscroll', ClientPrefs.downScroll);
			script.setVariable('middlescroll', ClientPrefs.middleScroll);
			script.setVariable('framerate', ClientPrefs.framerate);
			script.setVariable('ghostTapping', ClientPrefs.ghostTapping);
			script.setVariable('hideHud', ClientPrefs.hideHud);
			script.setVariable('timeBarType', ClientPrefs.timeBarType);
			script.setVariable('scoreZoom', ClientPrefs.scoreZoom);
			script.setVariable('cameraZoomOnBeat', ClientPrefs.camZooms);
			script.setVariable('flashingLights', ClientPrefs.flashing);
			script.setVariable('noteOffset', ClientPrefs.noteOffset);
			script.setVariable('healthBarAlpha', ClientPrefs.healthBarAlpha);
			script.setVariable('noResetButton', ClientPrefs.noReset);
			script.setVariable('lowQuality', ClientPrefs.lowQuality);

			script.setVariable('blackScreen', blackScreen);
			script.setVariable('aesthetic', aesthetic);
			script.setVariable('lyricsTxt', lyricsTxt);

			#if windows
			script.setVariable('buildTarget', 'windows');
			#elseif linux
			script.setVariable('buildTarget', 'linux');
			#elseif mac
			script.setVariable('buildTarget', 'mac');
			#elseif html5
			script.setVariable('buildTarget', 'browser');
			#elseif android
			script.setVariable('buildTarget', 'android');
			#else
			script.setVariable('buildTarget', 'unknown');
			#end

			script.runScript(hxdata);
		}
	}

	function setWeekProgress(song:String)
	{
		Progression.weekProgress.set(WeekData.getWeekFileName(), {song: song, weekScore: campaignScore, weekMisses: campaignMisses});

		Progression.save();
	}
}

// This is so fucking stupid but bad fps = best trail -royal
class GhostSprite extends FlxSprite
{
	private static var poolSize = 5;
	private static var INVISIBLE_ALPHA = 0.00000000001;

	private static var instanceReserve:FlxTypedGroup<GhostSprite>;
	private static var usedInstances:FlxTypedGroup<GhostSprite>;

	private var time:Float;
	private var curTime:Float;
	private var aVal:Float;

	public static function initialize()
	{
		if (instanceReserve != null && usedInstances != null)
		{
			GhostSprite.cleanPools();
		}

		instanceReserve = new FlxTypedGroup();
		usedInstances = new FlxTypedGroup();

		for (i in 0...poolSize)
		{
			instanceReserve.add(new GhostSprite());
		}
	}

	public static function createGhostSprite(Sprite:FlxSprite, ?FadeTime:Float = 1, ?AlphaStart:Float = 1)
	{
		var spookyGhost:GhostSprite;

		if (instanceReserve.length != 0)
		{
			spookyGhost = instanceReserve.members[instanceReserve.length - 1];

			instanceReserve.remove(spookyGhost, true);

			// trace(spookyGhost);
		}
		else
		{
			spookyGhost = new GhostSprite();

			poolSize++;
		}

		spookyGhost.frame = Sprite.frame;
		spookyGhost.offset = Sprite.offset;
		spookyGhost.scale = Sprite.scale;
		spookyGhost.width = Sprite.width;
		spookyGhost.frameWidth = Sprite.frameWidth;
		spookyGhost.height = Sprite.height;
		spookyGhost.frameHeight = Sprite.frameHeight;
		spookyGhost.setPosition(Sprite.getPosition().x, Sprite.getPosition().y);

		spookyGhost.updateHitbox();

		spookyGhost.time = FadeTime;
		spookyGhost.curTime = spookyGhost.time;
		spookyGhost.aVal = AlphaStart;

		usedInstances.add(spookyGhost);

		return spookyGhost;
	}

	public static function destroyGhostSprite(sprite:GhostSprite)
	{
		sprite.alpha = INVISIBLE_ALPHA;
		sprite.setPosition(0, 0);
		usedInstances.remove(sprite);
		instanceReserve.add(sprite);
	}

	private static function cleanPools()
	{
		for (i in usedInstances)
		{
			i.destroy();
		}

		for (i in instanceReserve)
		{
			i.destroy();
		}
	}

	override function update(elapsed:Float)
	{
		curTime -= elapsed * PlayState.instance.playbackRate;

		if (curTime <= 0)
		{
			destroyGhostSprite(this);
		}
		else
		{
			alpha = (curTime / time) * aVal;
		}
	}
}
