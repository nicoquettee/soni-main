package;

import flixel.util.FlxTimer;
import flixel.FlxSprite;

class Smoke extends FlxSprite
{
    var killed:Bool = false;
    public function new(x:Float = 0, y:Float = 0)
    {
        super(x,y);

        frames = Paths.getSparrowAtlas('backgrounds/soni/Humo', 'shared');
		animation.addByPrefix('nuse', 'Todo', 24, false);
        active = false;
        visible = false;
        screenCenter();
        antialiasing = ClientPrefs.globalAntialiasing;
    }

    public function startSoniCar() 
    {
        active = true;
        visible = true;
        animation.play('nuse');
    }

    override function update(elapsed:Float)
    {
        if(animation.name == 'nuse' && animation.finished && !killed)
        {
            active = false;
            visible = false;
            kill();
            //destroy();
            killed = true;
        }
        
        super.update(elapsed);
    }
}