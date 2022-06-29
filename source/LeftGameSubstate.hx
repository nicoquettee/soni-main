package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;

class LeftGameSubstate extends MusicBeatSubstate
{
    var textesito1:FlxText;
    var textesito2:FlxText;
    public static var whenAccept:Void->Void;
    public static var whenDenied:Void->Void;

    override function create()
    {
        var shitBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        shitBG.alpha = .7;
        add(shitBG);

        textesito1 = new FlxText(0,0,FlxG.width,"Uhhh looks like you left in the middle of a song",45);
        textesito1.setFormat("VCR OSD Mono", 45, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        textesito1.antialiasing = ClientPrefs.globalAntialiasing;
        textesito1.screenCenter(Y);
        textesito1.y -= 20;
        textesito2 = new FlxText(0,0,FlxG.width,"\nWould you like to continue where you left off?",45);
        textesito2.setFormat("VCR OSD Mono", 45, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        textesito2.antialiasing = ClientPrefs.globalAntialiasing;
        textesito2.screenCenter(Y);
        textesito2.y += 20;
        add(textesito1);
        add(textesito2);

        super.create();
    }

    override public function update(elapsed:Float) 
    {
        super.update(elapsed);   

        if(controls.ACCEPT)
            whenAccept();
        else if(controls.BACK)
            whenDenied();
    }
}