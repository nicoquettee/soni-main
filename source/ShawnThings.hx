package;

import haxe.Exception;
import flixel.FlxSprite;
import Song.SwagSong;
import flixel.math.FlxMath;
import Std;
import flixel.FlxG;
import openfl.Lib;
import openfl.system.Capabilities;

using StringTools;

class ShawnThings
{
    public static var sy:Float = 50;
    public static var xlist:Array<Float> = [50,162,274,386];
    public static var oxlist:Array<Float> = [50,162,274,386];
    public static var pxlist:Array<Float> = [690,802,914,1026];
    public static var poxlist:Array<Float> = [690,802,914,1026];
    public static var nlist:Array<Float> = [50,162,274,386];
    public static var pnlist:Array<Float> = [690,802,914,1026];
    public static var times:Float = 0;
    public static var temp:Float = 0;
    public static var ptemp:Float = 0;
    public static var ylist:Array<Float> = [50,50,50,50];
    public static var ns:String = "";
    public static var stage:Array<Int> = [0,0];

    public static function reset()
    {
        sy = (ClientPrefs.downScroll?570:50);
        xlist = [50,162,274,386];
        pxlist = [690,802,914,1026];
        nlist = [50,162,274,386];
        pnlist = [690,802,914,1026];
        ylist = [50,50,50,50];
        times = 0;
        temp = 0;
        ptemp = 0;
        ns = "";
        stage = [Std.int(Capabilities.screenResolutionX),Std.int(Capabilities.screenResolutionY)];
    }

    public static function pos(daNote:Note,strumLine:FlxSprite)
    {
        if(PlayState.SONG.song.toLowerCase() == "scrapped-mouse")
        {
            if (Conductor.songPosition >= 95319.14893617031 && daNote.strumTime >= 95319 && daNote.strumTime < 122412)
            {
                if (daNote.y >= strumLine.y || daNote.strumTime <= Conductor.songPosition)
                {
                    if (daNote.mustPress)
                        daNote.x = pxlist[daNote.noteData];
                    else
                        daNote.x = xlist[daNote.noteData];
                }
                else 
                {
                    if (daNote.mustPress)
                        daNote.x = pnlist[daNote.noteData];
                    else
                        daNote.x = nlist[daNote.noteData];
                }
                if (daNote.isSustainNote)
                    daNote.x += daNote.width;
                daNote.y = -75 + 775 * (((daNote.strumTime - 95319.14893617031) % (97021.27659574478 - 95319.14893617031)) / (97021.27659574478 - 95319.14893617031));
                if(daNote.isSustainNote && daNote.animation.curAnim.name.endsWith('hold'))
                {
                    daNote.scale.y= 0.7 * Conductor.stepCrochet / 100 * 1.5 * 1;
                    daNote.updateHitbox();
                }
            }
            else if(daNote.strumTime > 13259 && daNote.strumTime < 23785)
            {
                daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));
                if (daNote.strumTime - Conductor.songPosition < 100)
                    daNote.alpha = 0;
                else if(daNote.strumTime - Conductor.songPosition < 500)
                    daNote.alpha = (daNote.strumTime - Conductor.songPosition - 100) / 400;
            }
            else if(daNote.strumTime > 66298 && daNote.strumTime < 82045)
            {
                daNote.y = (strumLine.y - ((66298.34254143645 + FlxMath.roundDecimal((Conductor.songPosition - 66298.34254143645) / 165.745856354, 0) * 165.745856354) - daNote.strumTime) * (0.3 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));
            }
        }
    }

    public static function spos(dastrum:FlxSprite,strumLine:FlxSprite)
    {
        if(PlayState.SONG.song.toLowerCase() == "scrapped-mouse")
        {
            if (Conductor.songPosition >= 95319.14893617031 && Conductor.songPosition < 122553.19148936185)
            {
                if ((Conductor.songPosition - 108936.17021276608) / (97021.27659574478 - 95319.14893617031) > times)
                {
                    temp = xlist[0];
                    ptemp = pxlist[0];
                    xlist[0] = xlist[1];
                    xlist[1] = xlist[2];
                    xlist[2] = xlist[3];
                    xlist[3] = temp;
                    pxlist[0] = pxlist[1];
                    pxlist[1] = pxlist[2];
                    pxlist[2] = pxlist[3];
                    pxlist[3] = ptemp;
                    nlist[0] = xlist[1];
                    nlist[1] = xlist[2];
                    nlist[2] = xlist[3];
                    nlist[3] = xlist[0];
                    pnlist[0] = pxlist[1];
                    pnlist[1] = pxlist[2];
                    pnlist[2] = pxlist[3];
                    pnlist[3] = pxlist[0];
                    times += 1;
                }
                if(dastrum.x > 640)
                    dastrum.x = pxlist[dastrum.ID];
                else
                    dastrum.x = xlist[dastrum.ID];
                dastrum.y = -75 + 775 * (((Conductor.songPosition - 95319.14893617031) % (97021.27659574478 - 95319.14893617031)) / (97021.27659574478 - 95319.14893617031));
                strumLine.y = dastrum.y;
            }
        }
    }

    inline static public function show(daNote:Note):Bool
    {
        if(PlayState.SONG.song.toLowerCase() == "scrapped-mouse")
        {
            if (Conductor.songPosition >= 95319.14893617031 && daNote.strumTime >= 95319 && daNote.strumTime < 122412)
            {
                return (daNote.strumTime - Conductor.songPosition) > (96595.74468085116 - 95319.14893617031);
            }
            else if(daNote.strumTime > 13259 && daNote.strumTime < 23785)
            {
                return (daNote.y > FlxG.height) || Conductor.songPosition < 13259.668508287292;
            }
            else if(daNote.strumTime > 66298 && daNote.strumTime < 82045)
            {
                return (daNote.y > FlxG.height) || Conductor.songPosition < 66298.34254143645;
            }
            else 
            {
                return (daNote.y > FlxG.height);
            }
        }
        else 
        {
            return (daNote.y > FlxG.height);
        }
    }

    inline static public function kill(daNote:Note):Bool
    {
        if(PlayState.SONG.song.toLowerCase() == "scrapped-mouse")
        {
            if (Conductor.songPosition >= 95319.14893617031 && daNote.strumTime >= 95319 && daNote.strumTime < 122412)
            {
                return (Conductor.songPosition - daNote.strumTime) > (1000 / 6);
            }
            else 
            {
                return daNote.y < -daNote.height;
            }
        }
        else 
            return daNote.y < -daNote.height;
    }

    inline static public function ups(daNote:Note,strumLine:FlxSprite)
    {
        if(PlayState.SONG.song.toLowerCase() == "scrapped-mouse")
        {
            if(Conductor.songPosition >= 95319.14893617031 && daNote.strumTime >= 95319 && daNote.strumTime < 122412)
            {
                return 2;
            }
            else 
            {
                if(strumLine.y > 300)
                    return 1;
                else
                    return 2;
            }
        }
        else 
        {
            return 2;
        }
    }

    inline static public function stry(daNote:Note,strumLine:FlxSprite)
    {
        if(PlayState.SONG.song.toLowerCase() == "scrapped-mouse")
        {
            if(Conductor.songPosition >= 95319.14893617031 && daNote.strumTime >= 95319 && daNote.strumTime < 122412)
            {
                return strumLine.y;
            }
            else 
            {
                return strumLine.y;
            }
        }
        else 
        {
            return strumLine.y;
        }
    }
}