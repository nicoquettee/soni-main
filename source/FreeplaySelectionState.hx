package; 

import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.Lib;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
using StringTools;

class FreeplaySelectionState extends MusicBeatState
{
    public static var curSelected:Int = -1;
    var sectionsArray:Array<String> = ['FanTracks', 'Covers', 'Freeplay', 'StoryMode'];
    
    var sectionSprite:FlxTypedSpriteGroup<FlxSprite>;
    var textSprite:FlxTypedSpriteGroup<FlxSprite>;

    public function new()
	{
		super();
		MusicBeatState.dumpcachetuff = false;
	}

    override function create()
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
        FlxG.mouse.visible = true;

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Selection Menu", null);
		#end

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/Fondo_Free'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

        sectionSprite = new FlxTypedSpriteGroup<FlxSprite>();
        textSprite = new FlxTypedSpriteGroup<FlxSprite>();
        for(i in 0...sectionsArray.length)
        {
            var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/section/${sectionsArray[i]}'));
			sprite.alpha = .6;
            sprite.screenCenter();
            sprite.antialiasing = ClientPrefs.globalAntialiasing;
            sprite.ID = i;
            sectionSprite.add(sprite);

            var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/text/${sectionsArray[i]}_Select'));
			sprite.alpha = 0;
            sprite.screenCenter();
            sprite.antialiasing = ClientPrefs.globalAntialiasing;
            sprite.ID = i;
            sectionSprite.add(sprite);
        }
        add(sectionSprite);
        var movile:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/movile'));
		movile.antialiasing = ClientPrefs.globalAntialiasing;
		add(movile);
		movile.screenCenter();
        add(textSprite);
        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}