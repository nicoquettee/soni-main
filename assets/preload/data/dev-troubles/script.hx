function onCreatePost()
{
    camHUD.alpha = 0;
    camNotes.alpha = 0;
    camLyrics.alpha = 0;
    FlxG.camera.alpha = 0.001;
    defaultCamZoom = 1.2;

    PlayState.bmmo.alpha = 0;
    PlayState.mymanuel.alpha = 0;
    PlayState.dyy.alpha = 0;
    PlayState.lyd.alpha = 0;

    dad.alpha = 0.00001;
    gf.alpha = 0.00001;
    boyfriend.alpha = 0.00001;

    gf.scrollFactor.set(0.9, 0.9);

    blackScreen.alpha = 1;
    blackScreen.visible = true;

    PlayState.camZoomingMult = 0;
    trace(songLength);
}

function onUpdatePost(elapsed)
{
    if(curStep < 96) camHUD.alpha = 0;
}

var tween;
var tweenZ;
function onSongStart()
{
    PlayState.songLength = 103 * 1000;
    trace(songLength);
    FlxG.camera.alpha = 1;
    tweenZ = FlxTween.tween(blackScreen, {alpha: 0}, 13.71);
    PlayState.eventTweens.push(tweenZ);
    tween = FlxTween.tween(PlayState, {defaultCamZoom: 0.9}, 13.71);
    PlayState.eventTweens.push(tween);
}

var tween1;
var tween2;
var tween3;
var tween4;
var tweenZoom;
var tweenZoom2;
var tweenAlph;
function onStepHit()
{
    switch(curStep)
    {
        case 48:
            var objs = [
                PlayState.bmmo,
                PlayState.mymanuel
                PlayState.dyy,
                PlayState.lyd
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    tween1 = FlxTween.tween(obj, {alpha: 1}, 5.14);
                    PlayState.eventTweens.push(tween1);
                }
            }

        case 96:
            var objs = [
                dad,
                gf,
                boyfriend,
                camNotes,
                camHUD,
                camLyrics
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    tween2 = FlxTween.tween(obj, {alpha: 1}, 3);
                    PlayState.eventTweens.push(tween2);
                }
            }

        case 123:
            PlayState.camZoomingMult = 1;

        case 256:
            var objs = [
                camHUD,
                camLyrics,
                camNotes,
                PlayState.bmmo,
                PlayState.mymanuel
                PlayState.dyy,
                PlayState.lyd
                dad,
                boyfriend
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    tween3 = FlxTween.tween(obj, {alpha: 0}, 3.43);
                    PlayState.eventTweens.push(tween3);
                }
            }

            tween4 = FlxTween.tween(PlayState, {defaultCamZoom: 1.2}, 3.43);
            PlayState.eventTweens.push(tween4);

        case 288:
            var objs = [
                camHUD,
                camLyrics,
                camNotes,
                PlayState.bmmo,
                PlayState.mymanuel
                PlayState.dyy,
                PlayState.lyd
                dad,
                boyfriend
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    tween3 = FlxTween.tween(obj, {alpha: 1}, 1.5);
                    PlayState.eventTweens.push(tween3);
                }
            }

            tween4 = FlxTween.tween(PlayState, {defaultCamZoom: 0.9}, 1.5);
            PlayState.eventTweens.push(tween4);

        case 416:
            tweenZoom = FlxTween.tween(PlayState, {defaultCamZoom: 0.85}, 0.43);
            PlayState.eventTweens.push(tweenZoom);

        case 420:
            tweenZoom2 = FlxTween.tween(PlayState, {defaultCamZoom: 0.85}, 1);
            PlayState.eventTweens.push(tweenZoom2);

        case 544:
            FlxG.camera.flash(fromRGB(0,0,0), 1);

        case 545:
            var objs = [
                PlayState.bmmo,
                PlayState.mymanuel
                PlayState.dyy,
                PlayState.lyd,
                gf
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    obj.alpha = 0;
                }
            }
            blackScreen.alpha = 0.5;

        case 672:
            var objs = [
                gf
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    obj.alpha = 1;
                }
            }
            blackScreen.alpha = 0.3;

        case 928:
            tweenAlph = FlxTween.tween(blackScreen, {alpha: 1}, 1.71);
            PlayState.eventTweens.push(blackScreen);

        case 960:
            var objs = [
                PlayState.bmmo,
                PlayState.mymanuel
                PlayState.dyy,
                PlayState.lyd
            ];
            for(obj in objs)
            {
                if(obj != null)
                {
                    obj.alpha = 1;
                }
            }
            blackScreen.alpha = 0;
            PlayState.songLength = FlxG.sound.music.length;
    }    
}