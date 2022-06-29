package;

import flixel.FlxSprite;

class NoteCombo extends FlxSprite
{
    public function new(?x:Float = 0, ?y:Float = 0)
    {
        super(x,y);

        frames = Paths.getSparrowAtlas('Note_kombo_soni', 'shared');
        //scrollFactor.set(.5,.5);
        scale.set(PlayState.instance.camGame.zoom-0.1,PlayState.instance.camGame.zoom-0.1);
        //screenCenter();
        //y += 300;
        //x -= 300;
        visible = false;
        active = false;
        antialiasing = ClientPrefs.globalAntialiasing;
        animation.addByPrefix('appear', 'appear', 24, false);
        animation.addByPrefix('disappear', 'disappear', 40, false);
    }

    public function playAnim(anim:String,force:Bool)
    {
        animation.play(anim,force);
        if(anim == 'disappear')
            offset.x = -150;
        else if(anim == 'appear')
        {
            active = true;
            visible = true;
        }
    }

    override function update(elapsed:Float)
    {
        if(animation.finished)
        {
            if(animation.curAnim.name == 'appear')
                playAnim('disappear',false);
            else if(animation.curAnim.name == 'disappear')
            {
                offset.x = 0;
                active = false;
                visible = false;
            }
        }
        super.update(elapsed);
    }
}