function onCreatePost()
{
    PlayState.blackScreen.cameras = [camHUD];
}

function onUpdate(elapsed)
{
    //trace('x: ' + dad.getMidpoint().x); -646
    //trace('y: ' + dad.getMidpoint().y); -20
}

var tween;
var tween2;
function onBeatHit()
{
    switch(curBeat)
    {
        case 487:
            tween = FlxTween.tween(camNotes, {yaw: 360}, 0.29, {ease: FlxEase.quadOut});
            PlayState.eventTweens.push(tween);
        case 588:
            tween2 = FlxTween.tween(camNotes, {alpha: 0}, 3, {ease: FlxEase.quadOut});
            PlayState.eventTweens.push(tween2);
    }
}

var tmrHUD;
function onEvent(n,v1,v2)
{
    if(n == 'Black Screen') PlayState.blackScreen.alpha = v2;
    if(n == 'Flash') if(curBeat == 584 || curBeat == 583)
    {
        tmrHUD = new FlxTimer().start(.1, (tmr)->{camHUD.visible = false; camGame.visible = false;});
        PlayState.eventTimers.push(tmrHUD);
    }
}