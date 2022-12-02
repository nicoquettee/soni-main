function onCreatePost()
{
    camHUD.alpha = 0;
    camNotes.alpha = 0;
    FlxG.camera.alpha = 0.001;
    defaultCamZoom = 1;

    dad.y -= 70;
    dad.x += 100;

    blackScreen.alpha = 1;
    blackScreen.visible = true;

    PlayState.camZoomingDecay = 1.7;
}

function onUpdatePost(elapsed)
{
    if(curStep < 64) camHUD.alpha = 0;
}

var tweenBlack;
function onSongStart()
{
    PlayState.songLength = 65.78 * 1000;
    FlxG.camera.alpha = 1;
    tweenBlack = FlxTween.tween(blackScreen, {alpha: 0}, 5.33 / initialPlaybackRate);
    PlayState.eventTweens.push(tweenBlack);
}

var tweenHUDAlpha;
var tweenNoteAlpha;
var tweenLength;
function onStepHit()
{
    switch(curStep)
    {
        case 64:
            PlayState.camZoomingDecay = 1;
            tweenHUDAlpha = FlxTween.tween(camHUD, {alpha: 1}, .89 / initialPlaybackRate);
            PlayState.eventTweens.push(tweenHUDAlpha);
            tweenNoteAlpha = FlxTween.tween(camNotes, {alpha: 1}, .89 / initialPlaybackRate);
            PlayState.eventTweens.push(tweenNoteAlpha);
        case 592:
            tweenLength = FlxTween.tween(PlayState, {songLength: FlxG.sound.music.length}, .5 / initialPlaybackRate);
            PlayState.eventTweens.push(tweenLength);
        case 600:
            PlayState.camZoomingMult = 0;
        case 1128:
            PlayState.camZoomingMult = 1;
        case 1512:
            blackScreen.alpha = 1;
    }
}