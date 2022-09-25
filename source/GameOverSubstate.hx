package;

import lime.app.Application;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import WeekData;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'befe';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;
	public static var healthLossDecreased:Bool = false;

	public static function resetVariables() {
		characterName = 'befe';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		if(isEnding)
			isEnding = false;

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);
		Lib.application.window.title = 'Freaky Night With Soni - GAME OVER';

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName), 1.5);
		Conductor.changeBPM(84);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else if(PlayState.isCode)
				MusicBeatState.switchState(new Codes());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);

			Lib.application.window.title = 'Freaky Night With Soni';
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished)
			{
				coolStartDeath(.6);
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if(PlayState.deathCounter >= 3 && PlayState.instance.healthLoss > 0.7)
			{
				openSubState(new KillmePls(function()
				{
					shitshitshitshitshitshitshitshit();
				}, function()
				{
					healthLossDecreased = true;
					shitshitshitshitshitshitshitshit();
				}, function()
				{
					isEnding = false;
				},
				'you have died ${PlayState.deathCounter} times in a row',
				'want to decrease life drain?',
				'Yes',
				'No'));
			}
			else
			{
				shitshitshitshitshitshitshitshit();
			}
		}
	}

	function shitshitshitshitshitshitshitshit()
	{
		boyfriend.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music(endSoundName));
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				Lib.application.window.title = 'Freaky Night With Soni';
				if(!PlayState.isStoryMode)
					backOutFromFreeplayOrCodesStateIdk();
				else
					spedFuckedMyLifeIFuckingWantToDieBecauseWhenYouDieInSpedTheScreenGoBlackAndYouCantResetTheState();
			});
		});
		PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
	}

	function spedFuckedMyLifeIFuckingWantToDieBecauseWhenYouDieInSpedTheScreenGoBlackAndYouCantResetTheState()
	{
		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[PlayState.storyWeek]).songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		var resumeInfo = Progression.weekProgress.get(WeekData.weeksList[PlayState.storyWeek]);

		if (!songArray.contains(resumeInfo.song))
			songArray[songArray.length] = resumeInfo.song;

		songArray = songArray.slice(songArray.indexOf(resumeInfo.song));
		PlayState.campaignMisses = resumeInfo.weekMisses;
		PlayState.campaignScore = resumeInfo.weekScore;

		PlayState.storyPlaylist = songArray;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());

		FlxG.mouse.visible = false;
		LoadingState.loadAndSwitchState(new PlayState(), false);
	}

	function backOutFromFreeplayOrCodesStateIdk()
	{
		FlxG.sound.music.volume = 0;
		FlxG.mouse.visible = false;
		MusicBeatState.switchState(new PlayState());
	}
}
