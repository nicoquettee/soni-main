package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import flixel.FlxObject;
import openfl.Lib;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	public static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	public var camFollow:FlxObject;

	var soniBG:FlxSprite;
	var basurero:FlxSprite;
	var basura:FlxSprite;
	var masBasura:FlxSprite;
	var movile:FlxSprite;
	var songList:FlxSprite;
	var weekName:FlxSprite;
	var soniChapterBack:FlxSprite;
	var chapterText:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var arm:FlxSprite;

	public function new()
	{
		super();
		MusicBeatState.dumpcachetuff = false;
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;

		Conductor.changeBPM(110);

		PlayState.isStoryMode = true;
		PlayState.isCode = false;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		soniBG = new FlxSprite().loadGraphic(Paths.image('storymode/soni/BG'));
		soniBG.screenCenter();
		soniBG.scrollFactor.set(.03,.03);
		soniBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(soniBG);

		basurero = new FlxSprite(-145,-115).loadGraphic(Paths.image('storymode/soni/Basurero'));
		basurero.scrollFactor.set(.04,.04);
		basurero.antialiasing = ClientPrefs.globalAntialiasing;
		add(basurero);

		basura = new FlxSprite(-68,255).loadGraphic(Paths.image('storymode/soni/Basura'));
		basura.scrollFactor.set(.045,.045);
		basura.antialiasing = ClientPrefs.globalAntialiasing;
		add(basura);

		masBasura = new FlxSprite(-50,155).loadGraphic(Paths.image('storymode/soni/Extr'));
		masBasura.scrollFactor.set(.05,.05);
		masBasura.antialiasing = ClientPrefs.globalAntialiasing;
		add(masBasura);

		movile = new FlxSprite(345,255);
		movile.frames = Paths.getSparrowAtlas('storymode/soni/Soni_Phone');
		movile.animation.addByPrefix('idle', 'Phone_Soni', 24, true);
		movile.animation.play('idle');
		movile.screenCenter(X);
		movile.scrollFactor.set(.055,.055);
		movile.antialiasing = ClientPrefs.globalAntialiasing;
		add(movile);

		songList = new FlxSprite(675,450).loadGraphic(Paths.image('storymode/soni/Cartel_'));
		songList.scrollFactor.set(.01,.01);
		songList.antialiasing = ClientPrefs.globalAntialiasing;
		add(songList);

		weekName = new FlxSprite(1100,130).loadGraphic(Paths.image('storymode/soni/Soni'));
		weekName.scrollFactor.set();
		weekName.antialiasing = ClientPrefs.globalAntialiasing;
		add(weekName);

		soniChapterBack = new FlxSprite(0,-25).loadGraphic(Paths.image('storymode/soni/Cartel_Chapter'));
		soniChapterBack.screenCenter(X);
		soniChapterBack.scrollFactor.set();
		soniChapterBack.antialiasing = ClientPrefs.globalAntialiasing;
		add(soniChapterBack);

		chapterText = new FlxSprite(915,30);
		chapterText.frames = Paths.getSparrowAtlas('storymode/soni/Chapter_1');
		chapterText.animation.addByPrefix('idle', 'Chapter_1', 24, true);
		chapterText.animation.play('idle');
		chapterText.screenCenter(X);
		chapterText.scrollFactor.set();
		chapterText.antialiasing = ClientPrefs.globalAntialiasing;
		add(chapterText);

		leftArrow = new FlxSprite(soniChapterBack.x-60,50);
		leftArrow.frames = Paths.getSparrowAtlas('storymode/soni/Flech');
		leftArrow.animation.addByPrefix('idle', "Flech_1", 0, false);
		leftArrow.animation.play('idle');
		leftArrow.scrollFactor.set();
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);

		rightArrow = new FlxSprite(soniChapterBack.x+soniChapterBack.width+10,50);
		rightArrow.frames = Paths.getSparrowAtlas('storymode/soni/Flech');
		rightArrow.animation.addByPrefix('idle', "Flech_2", 0, false);
		rightArrow.animation.play('idle');
		rightArrow.scrollFactor.set();
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		arm = new FlxSprite(-110,180);
		arm.frames = Paths.getSparrowAtlas('storymode/soni/Arm_BF');
		arm.animation.addByPrefix('idle', 'Arm_BF', 24, true);
		arm.animation.play('idle');
		arm.scrollFactor.set(.12,.12);
		arm.antialiasing = ClientPrefs.globalAntialiasing;
		add(arm);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Menu", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;

		FlxG.camera.follow(camFollow, null, 0.06);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		camFollow.setPosition(FlxG.mouse.getPositionInCameraView(FlxG.camera).x, FlxG.mouse.getPositionInCameraView(FlxG.camera).y);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var overlapin = FlxG.mouse.overlaps(rightArrow) || FlxG.mouse.overlaps(leftArrow);

			if (controls.UI_RIGHT)
				rightArrow.scale.set(.9,.9);
			else
				rightArrow.scale.set(1,1);

			if (controls.UI_LEFT)
				leftArrow.scale.set(.9,.9);
			else
				leftArrow.scale.set(1,1);

			if(FlxG.mouse.overlaps(rightArrow))
			{
				if(FlxG.mouse.pressed)
					rightArrow.scale.set(.9,.9);
				else
					rightArrow.scale.set(1,1);

				if(FlxG.mouse.justPressed)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else if(FlxG.mouse.overlaps(leftArrow))
			{
				if(FlxG.mouse.pressed)
					leftArrow.scale.set(.9,.9);
				else
					leftArrow.scale.set(1,1);

				if(FlxG.mouse.justPressed)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}

			if (controls.UI_RIGHT_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_LEFT_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
			else if (FlxG.mouse.justPressed && !overlapin)
			{
				selectWeek();
			}
		}

		if ((controls.BACK || FlxG.mouse.justPressedRight) && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			Lib.application.window.title = 'Freaky Night With Soni';
			MusicBeatState.dumpcachetuff = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			selectedWeek = true;
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			if (Progression.weekProgress.exists(WeekData.weeksList[curWeek]))
			{
				openSubState(new KillmePls(function()
				{
					PlayState.campaignMisses = 0;
					PlayState.campaignScore = 0;
					startWeek(songArray);
				}, function()
				{
					var resumeInfo = Progression.weekProgress.get(WeekData.weeksList[curWeek]);

					if (!songArray.contains(resumeInfo.song))
						songArray[songArray.length] = resumeInfo.song;

					songArray = songArray.slice(songArray.indexOf(resumeInfo.song));
					PlayState.campaignMisses = resumeInfo.weekMisses;
					PlayState.campaignScore = resumeInfo.weekScore;

					startWeek(songArray);
				}, function()
				{
					selectedWeek = false;
				}));
			}
			else
			{
				PlayState.campaignMisses = 0;
				PlayState.campaignScore = 0;
				startWeek(songArray);
			}
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function startWeek(songs:Array<String>)
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		PlayState.storyPlaylist = songs;
		PlayState.isStoryMode = true;
		PlayState.isCode = false;
		selectedWeek = true;

		var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
		if(diffic == null) diffic = '';

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.mouse.visible = false;
			MusicBeatState.dumpcachetuff = true;
			Lib.application.window.title = 'Freaky Night With Soni';
			LoadingState.loadAndSwitchState(new PlayState(), true);
			FreeplayState.destroyFreeplayVocals();
		});
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]));

		var diff:String = CoolUtil.difficulties[curDifficulty];
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		movile.animation.play('idle', true);
		arm.animation.play('idle', true);
	}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		Lib.application.window.title = 'Freaky Night With Soni - Story Mode - ${WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).storyName}';
		updateText();
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}
