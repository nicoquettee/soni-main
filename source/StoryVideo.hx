package;

#if sys
import sys.FileSystem;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class StoryVideo extends MusicBeatState
{
	private var videoCurrentlyPlaying:FlxVideo = null;
	private var isVideoCurrentlyPlaying:Bool;
	public static var videoPlaying:Bool = false;

	private var videoMap:Map<String, String> = [
        'sonicando' => 'look at this shit',
        'origishit' => 'origishit'
    ];
    
	public var inCutscene:Bool = false;

	override public function create()
	{
        startVideo(videoMap.get(PlayState.SONG.song.toLowerCase()), true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.ACCEPT || controls.BACK)
		{
            videoCurrentlyPlaying.skipVideo();
			videoCurrentlyPlaying = null;
			isVideoCurrentlyPlaying = false;
		}
	}

	public function startVideo(name:String, hasSkipIcon:Bool = false):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName))
			#end
			{
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;

			isVideoCurrentlyPlaying = true;
			videoCurrentlyPlaying = new FlxVideo(fileName);
			videoCurrentlyPlaying.hasSkipIcon = hasSkipIcon;

			(videoCurrentlyPlaying).finishCallback = function() {
				isVideoCurrentlyPlaying = false;
				videoCurrentlyPlaying = null;
				LoadingState.loadAndSwitchState(new PlayState(), true, false);
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			LoadingState.loadAndSwitchState(new PlayState(), true, false);
		}
		#end
	}
}