package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ColorSwap;
import WeekData;

using StringTools;

class EndMyLife extends MusicBeatState
{
    var effect:ColorSwap = new ColorSwap();
    var effectTween:FlxTween;
    var toDoText:FlxText;
    var toDoTextSine:Float = 0;
    var numForArray:Int = FlxG.save.data.numForArray;
    
    override function create()
    {
        #if desktop
		DiscordClient.changePresence("Loading Checkpoint...", null);
        #end
        
        var chekpointTxt:FlxText = new FlxText(FlxG.width * 0.7, 10, 0, "CHECKPOINT!", 50);
        chekpointTxt.setFormat("Trebuchet MS", 40, FlxColor.WHITE, CENTER);
        chekpointTxt.screenCenter();
        chekpointTxt.shader = effect.shader;
        add(chekpointTxt);

        var chekpointInfoTxt:FlxText = new FlxText(FlxG.width * 0.7, 10, 0, "YOU HAVE A CHECKPOINT IN THE SONG: " + FlxG.save.data.songWhereYouLeave, 40);
        chekpointInfoTxt.setFormat("Trebuchet MS", 40, FlxColor.WHITE, CENTER);
        chekpointInfoTxt.screenCenter(X);
        chekpointInfoTxt.text = chekpointInfoTxt.text.toUpperCase();
        chekpointInfoTxt.y = chekpointTxt.y + 50;
        add(chekpointInfoTxt);

        toDoText = new FlxText(FlxG.width * 0.7, 10, 0, "PRESS ENTER TO ENTER THE SONG\nPRESS ESCAPE TO GO BACK");
        toDoText.setFormat("Trebuchet MS", 40, FlxColor.WHITE, CENTER);
        toDoText.screenCenter(X);
        toDoText.y = chekpointInfoTxt.y + 100;
        add(toDoText);

        //trace(curWeek);
        //trace(numForArray);
        
        effectTween = FlxTween.num(0, 359, 240, {type: LOOPING}, function(v)
		{
			effect.hue = v;
		});
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);
    
        toDoTextSine += 180 * elapsed;
        toDoText.alpha = 1 - Math.sin((Math.PI * toDoTextSine) / 180);
      
        if(!enterToCheck)
        {
            if(controls.ACCEPT || FlxG.keys.justPressed.ENTER) 
            {
                FlxG.save.data.leftDaGameInTheMiddleBRUH = false;
                goToDaCheckpoint();
            }
            if(controls.BACK || FlxG.keys.justPressed.ESCAPE) 
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.save.data.leftDaGameInTheMiddleBRUH = false;
                MusicBeatState.switchState(new StoryMenuState());
            }
        }
    }

    var nospam:Bool = false;
    var enterToCheck:Bool = false;
    var curWeek:Int = FlxG.save.data.weekWhereYouLeave;
    function goToDaCheckpoint()
    {
        if(!nospam)
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            nospam = true;
        }

        var songArray:Array<String> = [];
        switch(curWeek)
        {
            case 0:
                switch(numForArray)
                {
                    case 0:
                        songArray = ['Sonicando', 'Faster-Rapper', 'SPED'];
                    case 1:
                        songArray = ['Faster-Rapper', 'SPED'];
                    case 2:
                        songArray = ['SPED'];
                }
        } //LAZY CODE DONT KILL ME

        PlayState.storyPlaylist = songArray;
        PlayState.isStoryMode = true;
        PlayState.isCode = false;
        enterToCheck = true;

        PlayState.storyDifficulty = 1;
        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            LoadingState.loadAndSwitchState(new PlayState(), true);
            FreeplayState.destroyFreeplayVocals();
        });
    }
}