package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class CacheScreen extends FlxTypedGroup<FlxSprite>
{
    public var progress:Int = 0;
	public var max:Int = 7;
    
    var loadingImage:FlxSprite;
    var loadTxt:FlxText;
    var cText:String;
    
    public function new()
    {
        super();

		loadingImage = new FlxSprite().loadGraphic(Paths.image('Poster', 'preload'));
		loadingImage.updateHitbox();
		loadingImage.screenCenter();
		add(loadingImage);

		loadTxt = new FlxText(0, 0, 0, "Loading", 40);
		loadTxt.setFormat(Paths.font('#44.ttf'), 40, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadTxt.x = 5;
		loadTxt.y = FlxG.height - loadTxt.height - 5 + 2;
        cText = loadTxt.text;
		add(loadTxt);

        new FlxTimer().start(.5, (tmr)->{loadTxt.text += '.';}, 0);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if(loadTxt.text.length > cText.length+2) loadTxt.text = cText;

        var target:Float = progress / max;
        loadingImage.alpha = FlxMath.lerp(loadingImage.alpha, target, elapsed * 5);
        loadTxt.alpha = FlxMath.lerp(loadTxt.alpha, target, elapsed * 5);
    }

    public function setLoadingText(text:String)
    {
        loadTxt.text = text;
        cText = text;
    }
}