function onCreatePost()
{
    PlayState.camZoomingMult = 1.2;
}

var tween;
var tween2;
function onBeatHit()
{
    switch(curBeat)
    {
        case 487:
            tween = FlxTween.tween(camNotes, {yaw: 360}, 0.29 / initialPlaybackRate, {ease: FlxEase.quadOut});
            PlayState.eventTweens.push(tween);
        case 572:
            PlayState.blackScreen.cameras = [camHUD];
        case 588:
            tween2 = FlxTween.tween(camNotes, {alpha: 0}, 3 / initialPlaybackRate, {ease: FlxEase.quadOut});
            PlayState.eventTweens.push(tween2);
    }
}

function onStepHit()
{
    if(curStep > 127 && curStep <= 255)
    {
        PlayState.camZoomingMult = 1.5;
    }
    else if(curStep > 255 && curStep <= 767)
    {
        PlayState.camZoomingMult = 2;
    }
    else if(curStep > 767 && curStep <= 885)
    {
        PlayState.camZoomingMult = 1.5;
    }
    else if(curStep > 885 && curStep <= 1663)
    {
        PlayState.camZoomingMult = 2;
    }
    else if(curStep > 1663 && curStep <= 1951)
    {
        PlayState.camZoomingMult = 1.5;
    }
    else if(curStep > 1951 && curStep <= 2207)
    {
        PlayState.camZoomingMult = 2;
    } else if(curStep > 2207)
    {
        PlayState.camZoomingMult = 1.5;
    }
}

var tmrHUD;
function onEvent(n,v1,v2)
{
    if(n == 'Black Screen') PlayState.blackScreen.alpha = v2;
    if(n == 'Flash') if(curBeat == 584 || curBeat == 583)
    {
        tmrHUD = new FlxTimer().start(.1 / initialPlaybackRate, (tmr)->{camHUD.visible = false; camGame.visible = false;});
        PlayState.eventTimers.push(tmrHUD);
    }
}

function addCamZoom(game, hud)
{
	PlayState.camGame.zoom += game;
	PlayState.camHUD.zoom += hud;
    PlayState.camNotes.zoom += hud;
}