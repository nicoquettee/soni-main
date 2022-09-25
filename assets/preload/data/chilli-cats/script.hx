function onCreatePost()
{
    camHUD.alpha = 0;
    camNotes.alpha = 0;
    camLyrics.alpha = 0;
    FlxG.camera.alpha = 0.001;
    defaultCamZoom = 1.2;
}

function onSongStart()
{
    FlxG.camera.alpha = 1;
    FlxG.camera.fade(0xFF000000, 32 * Conductor.crochet / 1000, true);
    FlxTween.tween(PlayState, {defaultCamZoom: 0.8}, 9.23);
}

function onUpdate(elapsed)
{
    gf.animation.finishCallback = function(anim)
    {
        if(gf.animation.curAnim.name == 'dead')
        {
            gf.playAnim('idle-dead', true);
            gf.specialAnim = true;
        }
    }
}

function onUpdatePost(elapsed)
{
    if(curBeat < 30)
    {
        camHUD.alpha = 0;
        camNotes.alpha = 0;
        camLyrics.alpha = 0;
    }

    if(curBeat == 30)
    {
        FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000 * 4.5, {ease: FlxEase.cubeOut});
        FlxTween.tween(camNotes, {alpha: 1}, Conductor.crochet / 1000 * 4.5, {ease: FlxEase.cubeOut});
        FlxTween.tween(camLyrics, {alpha: 1}, Conductor.crochet / 1000 * 4.5, {ease: FlxEase.cubeOut});
    }
}